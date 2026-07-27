#!/usr/bin/env python3
"""Sync Darktide mods from Nexus Mods.

Reads ``mods.txt`` (a lockfile of ``folder mod_id version`` lines), fetches each
mod's current MAIN file from the Nexus Mods API, and downloads + extracts
anything missing or out of date. Handles both ``.zip`` and ``.7z`` archives.

Usage:
    python3 scripts/sync_mods.py             # download outdated mods
    python3 scripts/sync_mods.py --status    # only report outdated, no download
    python3 scripts/sync_mods.py --force     # re-download even if up to date

Env:
    NEXUSMODS_APIKEY         required
    NEXUSMODS_GAME_DOMAIN    default: warhammer40kdarktide
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

import requests

V1_BASE = os.environ.get("NEXUSMODS_API_BASE", "https://api.nexusmods.com/v1").rstrip("/")
GAME_DOMAIN = os.environ.get("NEXUSMODS_GAME_DOMAIN", "warhammer40kdarktide")
USER_AGENT = "deathbeam/darktide-mods sync script"

REPO_ROOT = Path(__file__).resolve().parent.parent
MODS_DIR = REPO_ROOT / "mods"
LOCKFILE = REPO_ROOT / "mods.txt"

# 1=MAIN, 2=UPDATED, 3=OPTIONAL, 4=OLD_VERSION, 5=MISCELLANEOUS,
# 6=ARCHIVED, 7=REMOVED. Only the first three are live.
DEAD_CATEGORIES = {4, 6, 7}
VERSION_RE = re.compile(r"\bversion\s*=\s*[\"']([^\"']+)[\"']")
USE_COLOR = sys.stderr.isatty()


def colorize(code: str, msg: str) -> str:
    return f"\033[{code}m{msg}\033[0m" if USE_COLOR else msg


def log_ok(msg: str) -> None:
    print(f"  {colorize('32', '✓')} {msg}")


def log_skip(msg: str) -> None:
    print(f"  {colorize('33', '·')} {msg}")


def log_fail(msg: str) -> None:
    print(f"  {colorize('31', '✗')} {msg}")


def log_info(msg: str) -> None:
    print(f"  {colorize('36', '→')} {msg}")


def log_section(title: str) -> None:
    print(f"\n{colorize('1', f'== {title} ==')}")


class NexusError(RuntimeError):
    """Non-2xx Nexus API response, preserving status + body."""

    def __init__(self, status: int, body: str, url: str):
        super().__init__(f"HTTP {status} from {url}: {body}")
        self.status = status
        self.body = body
        self.url = url


class NexusAPI:
    """Thin client over the Nexus Mods v1 REST API."""

    def __init__(self, api_key: str):
        self.session = requests.Session()
        self.session.headers.update({"apikey": api_key, "User-Agent": USER_AGENT})

    def v1(self, method: str, path: str) -> dict:
        url = f"{V1_BASE}{path}"
        resp = self.session.request(method, url)
        if not resp.ok:
            raise NexusError(resp.status_code, resp.text, url)
        return resp.json()

    def download_stream(self, url: str, dest: Path) -> None:
        """Stream a presigned CDN URL to ``dest``."""
        with self.session.get(url, stream=True) as resp:
            if not resp.ok:
                raise RuntimeError(f"HTTP {resp.status_code} downloading {url}: {resp.text}")
            with open(dest, "wb") as f:
                for chunk in resp.iter_content(chunk_size=1 << 16):
                    if chunk:
                        f.write(chunk)


class LockEntry:
    __slots__ = ("folder", "mod_id", "version")

    def __init__(self, folder: str, mod_id: str, version: str):
        self.folder = folder
        self.mod_id = mod_id
        self.version = version


def read_lockfile(path: Path) -> list[LockEntry]:
    """Parse ``mods.txt`` into ordered entries (comments/blank lines skipped)."""
    if not path.exists():
        return []
    entries: list[LockEntry] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 2:
            print(f"Warning: skipping malformed lockfile line: {raw!r}", file=sys.stderr)
            continue
        entries.append(LockEntry(parts[0], parts[1], parts[2] if len(parts) >= 3 else ""))
    return entries


def write_lockfile(path: Path, entries: list[LockEntry]) -> None:
    """Rewrite ``mods.txt`` preserving comments/blank lines and entry order,
    only touching the version column. Writes the header once on a new file."""
    header = (
        "# Darktide mod lockfile.\n"
        "# Each line: <folder> <mod_id> <version>\n"
        "#   folder  - install folder under mods/ (usually the mod name)\n"
        "#   mod_id  - Nexus Mods mod id (the number in the mod's URL)\n"
        "#   version - currently installed version (auto-updated by sync)\n"
    )
    by_key = {(e.folder, e.mod_id): e.version for e in entries}

    if not path.exists():
        lines_out = [header.rstrip("\n")]
        for e in entries:
            lines_out.append(f"{e.folder} {e.mod_id} {e.version}".strip())
        path.write_text("\n".join(lines_out) + "\n", encoding="utf-8")
        return

    lines_out = []
    present = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            lines_out.append(raw)
            continue
        parts = stripped.split()
        if len(parts) >= 2 and (parts[0], parts[1]) in by_key:
            present.add((parts[0], parts[1]))
            lines_out.append(f"{parts[0]} {parts[1]} {by_key[(parts[0], parts[1])]}".strip())
        else:
            lines_out.append(raw)
    for e in entries:
        if (e.folder, e.mod_id) not in present:
            lines_out.append(f"{e.folder} {e.mod_id} {e.version}".strip())
    path.write_text("\n".join(lines_out) + "\n", encoding="utf-8")


def read_local_version(folder: str) -> str | None:
    """Parse ``version`` from ``mods/<folder>/<folder>.mod``.

    Only used to back-fill the lockfile version on a first sync of a freshly
    added ``folder mod_id`` line."""
    mod_file = MODS_DIR / folder / f"{folder}.mod"
    if not mod_file.exists():
        return None
    m = VERSION_RE.search(mod_file.read_text(encoding="utf-8"))
    return m.group(1) if m else None


def get_main_file(api: NexusAPI, mod_id: str) -> dict | None:
    """Resolve the current MAIN file: prefer ``category_id == 1``/``"MAIN"``,
    else the most recent non-dead file. Returns ``{version, file_id,
    file_name, size_kb}`` or ``None``."""
    data = api.v1("GET", f"/games/{GAME_DOMAIN}/mods/{mod_id}/files.json")
    files = data.get("files", [])
    if not files:
        return None
    main = next(
        (f for f in files if f.get("category_id") == 1 or f.get("category_name") == "MAIN"),
        None,
    )
    if main is None:
        live = [f for f in files if f.get("category_id") not in DEAD_CATEGORIES]
        main = max(live or files, key=lambda x: x.get("uploaded_time", ""))
    return {
        "version": main.get("version"),
        "file_id": main.get("file_id"),
        "file_name": main.get("file_name"),
        "size_kb": main.get("size_kb", main.get("size")),
    }


def fetch_download_url(api: NexusAPI, mod_id: str, file_id: str) -> str:
    """Get the first CDN URL for a file via ``download_link.json`` (Premium)."""
    data = api.v1("GET", f"/games/{GAME_DOMAIN}/mods/{mod_id}/files/{file_id}/download_link.json")
    for entry in data:
        uri = entry.get("URI")
        if uri:
            return uri
    raise RuntimeError("download_link.json returned no URIs")


def remove_tree(path: Path) -> None:
    """``shutil.rmtree`` that clears read-only bits first. Some extracted mod
    folders land as ``dr-xr-xr-x`` (archives preserve author perms), which
    blocks a plain rmtree with EACCES."""
    try:
        os.chmod(path, 0o755)
    except OSError:
        pass
    for root, dirs, files in os.walk(path, topdown=False):
        for name in files + dirs:
            try:
                os.chmod(Path(root) / name, 0o755)
            except OSError:
                pass
    shutil.rmtree(path)


def extract_archive(archive_path: Path, dest_dir: Path) -> None:
    """Extract a ``.zip`` or ``.7z`` archive into ``dest_dir`` (must exist)."""
    name = archive_path.name.lower()
    if name.endswith(".7z"):
        try:
            import py7zr
            with py7zr.SevenZipFile(archive_path, mode="r") as z:
                z.extractall(path=dest_dir)
            return
        except ImportError:
            pass
        result = subprocess.run(
            ["7z", "x", "-y", f"-o{dest_dir}", str(archive_path)],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"7z extraction failed (status {result.returncode}): {result.stderr.strip()}"
            )
    else:
        with zipfile.ZipFile(archive_path) as zf:
            zf.extractall(dest_dir)


def extract_mod(archive_path: Path, folder: str) -> None:
    """Extract into ``mods/<folder>/``. Perms are deliberately not retained
    from the archive — some authors ship ``0o555`` dirs, which would make the
    folder undeletable later."""
    with tempfile.TemporaryDirectory(prefix="nx-mod-") as tmp:
        tmp_path = Path(tmp)
        extract_archive(archive_path, tmp_path)
        entries = [p for p in tmp_path.iterdir()]
        src = entries[0] if len(entries) == 1 and entries[0].is_dir() else tmp_path
        dest = MODS_DIR / folder
        if dest.exists():
            remove_tree(dest)
        MODS_DIR.mkdir(parents=True, exist_ok=True)
        for root, dirs, files in os.walk(src):
            os.chmod(root, 0o755)
            for fname in files:
                os.chmod(Path(root) / fname, 0o644)
        shutil.move(str(src), str(dest))


def cmd_sync(api: NexusAPI, args: argparse.Namespace) -> int:
    entries = read_lockfile(LOCKFILE)
    log_section(f"{'Checking' if args.status else 'Syncing'} {len(entries)} mod(s)")

    updated: list[str] = []
    skipped: list[str] = []
    failed: list[str] = []
    changed_entries: list[LockEntry] = []

    def mark_failed(entry: LockEntry, msg: str) -> None:
        log_fail(msg)
        failed.append(entry.folder)
        changed_entries.append(entry)

    for e in entries:
        effective = e.version if e.version else read_local_version(e.folder)

        try:
            published = get_main_file(api, e.mod_id)
        except Exception as ex:
            mark_failed(e, f"{e.folder}: could not fetch published version ({ex})")
            continue
        if not published or not published["version"]:
            mark_failed(e, f"{e.folder}: no published MAIN file found")
            continue
        pub_version = published["version"]

        pub = f"v{pub_version}"
        cur = f"v{effective}" if effective else "none"
        is_current = effective == pub_version

        if args.status:
            if not is_current:
                log_fail(f"{e.folder}: {cur} -> {pub} (outdated)")
            else:
                log_skip(f"{e.folder}: {cur} (up to date)")
            continue

        if is_current and not args.force:
            log_skip(f"{e.folder}: {cur} (up to date)")
            skipped.append(e.folder)
            changed_entries.append(LockEntry(e.folder, e.mod_id, pub_version))
            continue

        log_info(f"{e.folder}: {cur} -> {pub} (downloading)")
        try:
            url = fetch_download_url(api, e.mod_id, published["file_id"])
            ext = Path(published["file_name"]).suffix or ".zip"
            with tempfile.NamedTemporaryFile(prefix=f"{e.folder}-", suffix=ext, delete=False) as tf:
                tmp_archive = Path(tf.name)
            try:
                api.download_stream(url, tmp_archive)
                extract_mod(tmp_archive, e.folder)
            finally:
                if tmp_archive.exists():
                    tmp_archive.unlink()
        except NexusError as ex:
            if ex.status == 403 and "premium" in ex.body.lower():
                mark_failed(
                    e,
                    f"{e.folder}: download requires Premium (or a website key); "
                    f"grab it manually: https://www.nexusmods.com/{GAME_DOMAIN}/mods/{e.mod_id}?tab=files",
                )
            else:
                mark_failed(e, f"{e.folder}: download failed ({ex})")
            continue
        except Exception as ex:
            mark_failed(e, f"{e.folder}: download/extract failed ({ex})")
            continue

        log_ok(f"{e.folder}: updated to {pub}")
        updated.append(e.folder)
        changed_entries.append(LockEntry(e.folder, e.mod_id, pub_version))

    if not args.status:
        log_section("Summary")
        if updated:
            log_ok(f"Updated {len(updated)} mod(s): {', '.join(updated)}")
        else:
            log_skip("no mods to download")
        if skipped:
            log_skip(f"skipped {len(skipped)} mod(s): {', '.join(skipped)}")
        if failed:
            log_fail(f"failed {len(failed)} mod(s): {', '.join(failed)}")

    if not args.status:
        write_lockfile(LOCKFILE, changed_entries)

    return 1 if failed else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync Darktide mods from Nexus Mods.")
    parser.add_argument("--status", action="store_true", help="only report outdated mods, no download")
    parser.add_argument("--force", action="store_true", help="re-download even if up to date")
    args = parser.parse_args()

    api_key = os.environ.get("NEXUSMODS_APIKEY", "")
    if not api_key:
        print("Error: NEXUSMODS_APIKEY is not set", file=sys.stderr)
        return 1

    return cmd_sync(NexusAPI(api_key), args)


if __name__ == "__main__":
    sys.exit(main())
