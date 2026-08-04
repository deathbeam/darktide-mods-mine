#!/usr/bin/env python3
"""Apply the Darktide performance edits after a game update.

This script is intended to be run through the repository Makefile. It edits the
three files documented by Darktide-Performance-Optimizations and keeps a backup
beside every file it changes.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import stat
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

GAME_NAME = "Warhammer 40,000 DARKTIDE"
BACKUP_SUFFIX = ".darktide-mods.bak"
COMMON_FILE = "settings_common.ini"
WIN32_FILE = "win32_settings.ini"
LAUNCHER_FILE = "Launcher.exe.config"
LAUNCHER_ARGS = "--bundle-dir ../bundle --ini settings --lua-heap-mb-size 2048"

FEEDBACK_SETTINGS = [
    ("feedback_buffer_size", "4"),
    ("max_age_out_tiles_per_frame", "16"),
    ("max_streaming_tiles_per_frame", "16"),
    ("max_texture_pool_size", "1024"),
    ("max_write_feedback_threshold", "0.009"),
    ("min_write_feedback_threshold", "0.005"),
    ("staging_buffer_size", "4"),
    ("threaded_streamer", "true"),
    ("tile_age_out_time_ms", "5000"),
    ("tile_staging_buffer_size", "128"),
]
TEXTURE_SETTINGS = [
    ("streaming_buffer_size", "128"),
    ("streaming_texture_pool_size", "1024"),
]
COMMON_VALUES = {
    "streaming_buffer_size": "32",
    "streaming_max_open_streams": "38",
    "streaming_texture_pool_size": "400",
    "surface_properties": '"application_settings/global"',
}

BLOCK_RE = re.compile(
    r"^[ \t]*(?P<key>[A-Za-z_][A-Za-z0-9_]*)[ \t]*=[ \t]*\{[ \t]*(?:[#;].*)?$"
)
SETTING_RE = re.compile(
    r'<setting\b(?=[^>]*\bname\s*=\s*["\']ExeArgs["\'])[^>]*>',
    re.IGNORECASE,
)
VALUE_RE = re.compile(
    r"(?P<open><value(?:\s[^>]*)?>)(?P<value>[^<]*)(?P<close></value>)",
    re.IGNORECASE,
)


class ConfigError(RuntimeError):
    pass


@dataclass
class Document:
    path: Path
    lines: list[str]
    newline: str
    bom: bool

    @classmethod
    def load(cls, path: Path) -> "Document":
        raw = path.read_bytes()
        bom = raw.startswith(b"\xef\xbb\xbf")
        try:
            text = raw[3:].decode("utf-8") if bom else raw.decode("utf-8")
        except UnicodeDecodeError as error:
            raise ConfigError(f"{path} is not UTF-8: {error}") from error
        newline = "\r\n" if "\r\n" in text else "\n"
        return cls(path, text.splitlines(keepends=True), newline, bom)

    def bytes(self) -> bytes:
        text = "".join(self.lines).encode("utf-8")
        return (b"\xef\xbb\xbf" if self.bom else b"") + text

    def replace_lines(self, start: int, end: int, replacement: list[str]) -> None:
        had_newline = self.lines[end].endswith(("\n", "\r"))
        rendered = []
        for index, line in enumerate(replacement):
            suffix = self.newline if index < len(replacement) - 1 or had_newline else ""
            rendered.append(line + suffix)
        self.lines[start : end + 1] = rendered


def body(line: str) -> str:
    return line.rstrip("\r\n")


def brace_delta(line: str) -> int:
    quoted = False
    escaped = False
    delta = 0
    for char in line:
        if escaped:
            escaped = False
        elif quoted and char == "\\":
            escaped = True
        elif char == '"':
            quoted = not quoted
        elif not quoted and char == "{":
            delta += 1
        elif not quoted and char == "}":
            delta -= 1
    return delta


def find_block(document: Document, key: str) -> tuple[int, int]:
    starts = [
        index
        for index, line in enumerate(document.lines)
        if (match := BLOCK_RE.match(body(line))) and match.group("key") == key
    ]
    if not starts:
        raise ConfigError(f"could not find '{key} = {{ ... }}'")
    if len(starts) > 1:
        raise ConfigError(f"found multiple '{key}' blocks; refusing an ambiguous edit")

    depth = 0
    for end in range(starts[0], len(document.lines)):
        depth += brace_delta(body(document.lines[end]))
        if depth == 0:
            return starts[0], end
    raise ConfigError(f"'{key} = {{' has no matching closing brace")


def replace_block(document: Document, key: str, settings: list[tuple[str, str]]) -> None:
    start, end = find_block(document, key)
    opening = body(document.lines[start])
    indent = opening[: len(opening) - len(opening.lstrip(" \t"))]
    replacement = [
        f"{indent}{key} = {{",
        *(f"{indent}    {name} = {value}" for name, value in settings),
        f"{indent}}}",
    ]
    document.replace_lines(start, end, replacement)


def replace_value(
    document: Document,
    key: str,
    value: str,
    excluded_blocks: tuple[str, ...] = (),
) -> None:
    excluded = [find_block(document, block) for block in excluded_blocks]
    pattern = re.compile(rf"^(?P<indent>[ \t]*){re.escape(key)}[ \t]*=")
    matches = [
        index
        for index, line in enumerate(document.lines)
        if pattern.match(body(line))
        and not any(start <= index <= end for start, end in excluded)
    ]
    if not matches:
        raise ConfigError(f"could not find an editable '{key}' setting")

    for index in matches:
        old = document.lines[index]
        old_body = body(old)
        indent = old_body[: len(old_body) - len(old_body.lstrip(" \t"))]
        document.lines[index] = f"{indent}{key} = {value}{old[len(old_body):]}"


def optimize_common(document: Document) -> None:
    replace_block(document, "feedback_streamer_settings", FEEDBACK_SETTINGS)
    replace_block(document, "texture_streamer_settings", TEXTURE_SETTINGS)
    excluded = ("feedback_streamer_settings", "texture_streamer_settings")
    for key, value in COMMON_VALUES.items():
        replace_value(document, key, value, excluded)


def optimize_win32(document: Document) -> None:
    replace_value(document, "fullscreen", "true")
    replace_value(document, "streaming_texture_pool_size", "1024")


def optimize_launcher(document: Document) -> None:
    starts = [
        index for index, line in enumerate(document.lines) if SETTING_RE.search(body(line))
    ]
    if not starts:
        raise ConfigError('could not find a <setting name="ExeArgs"> element')

    for start in starts:
        end = next(
            (
                index
                for index in range(start, len(document.lines))
                if "</setting>" in body(document.lines[index]).lower()
            ),
            None,
        )
        if end is None:
            raise ConfigError("an ExeArgs setting has no closing </setting> tag")

        values = []
        for index in range(start, end + 1):
            match = VALUE_RE.search(body(document.lines[index]))
            if match:
                values.append((index, match))
        if len(values) != 1:
            raise ConfigError("an ExeArgs setting must contain exactly one <value> element")

        index, match = values[0]
        old = document.lines[index]
        old_body = body(old)
        document.lines[index] = (
            old_body[: match.start("value")]
            + LAUNCHER_ARGS
            + old_body[match.end("value") :]
            + old[len(old_body) :]
        )


def case_insensitive_file(directory: Path, name: str) -> Path:
    exact = directory / name
    if exact.is_file():
        return exact
    try:
        for child in directory.iterdir():
            if child.is_file() and child.name.lower() == name.lower():
                return child
    except FileNotFoundError:
        pass
    return exact


def settings_dir() -> Path:
    configured = os.environ.get("DARKTIDE_SETTINGS_DIR")
    if configured:
        path = Path(configured).expanduser()
        if path.name != "application_settings":
            path = path / "bundle" / "application_settings"
        return path.resolve()

    candidates = [
        Path.home() / ".local/share/Steam/steamapps/common" / GAME_NAME / "bundle/application_settings",
        Path.home() / ".steam/steam/steamapps/common" / GAME_NAME / "bundle/application_settings",
        Path.home() / ".steam/root/steamapps/common" / GAME_NAME / "bundle/application_settings",
    ]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate
    raise ConfigError(
        "Darktide was not found in the standard Linux Steam locations; "
        "set DARKTIDE_SETTINGS_DIR to bundle/application_settings"
    )


def target_paths(directory: Path, skip_launcher: bool) -> list[Path]:
    paths = [
        case_insensitive_file(directory, COMMON_FILE),
        case_insensitive_file(directory, WIN32_FILE),
    ]
    if not skip_launcher:
        launcher_dir = directory.parent.parent / "launcher"
        paths.append(case_insensitive_file(launcher_dir, LAUNCHER_FILE))
    return paths


def backup_path(path: Path) -> Path:
    return path.with_name(path.name + BACKUP_SUFFIX)


def atomic_write(path: Path, data: bytes) -> None:
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
    temporary_name = None
    try:
        with tempfile.NamedTemporaryFile(mode="wb", dir=path.parent, delete=False) as temporary:
            temporary_name = temporary.name
            temporary.write(data)
            temporary.flush()
            os.fsync(temporary.fileno())
        os.chmod(temporary_name, mode)
        os.replace(temporary_name, path)
    finally:
        if temporary_name:
            try:
                os.unlink(temporary_name)
            except FileNotFoundError:
                pass


def restore(directory: Path, skip_launcher: bool) -> int:
    paths = target_paths(directory, skip_launcher)
    restored = 0
    for path in paths:
        backup = backup_path(path)
        if backup.is_file():
            atomic_write(path, backup.read_bytes())
            print(f"Restored {path}")
            restored += 1
        else:
            print(f"Skipped {path}: no backup exists")
    if not restored:
        print("No backups found.", file=sys.stderr)
        return 1
    return 0


def prepare(directory: Path, skip_launcher: bool) -> list[tuple[Document, bytes]]:
    paths = target_paths(directory, skip_launcher)
    missing = [path for path in paths if not path.is_file()]
    if missing:
        message = "Required config file(s) not found:\n" + "\n".join(f"  {path}" for path in missing)
        if not skip_launcher:
            message += "\nUse --skip-launcher-config to apply only the two INI files."
        raise ConfigError(message)

    documents = [(Document.load(path), path.read_bytes()) for path in paths]
    optimize_common(documents[0][0])
    optimize_win32(documents[1][0])
    if not skip_launcher:
        optimize_launcher(documents[2][0])
    return documents


def apply(changed: list[tuple[Document, bytes]]) -> None:
    try:
        for document, _ in changed:
            shutil.copy2(document.path, backup_path(document.path))
            atomic_write(document.path, document.bytes())
    except Exception:
        for document, before in changed:
            try:
                atomic_write(document.path, before)
            except OSError:
                pass
        raise


def run(args: argparse.Namespace) -> int:
    directory = settings_dir()
    if not directory.is_dir():
        raise ConfigError(f"application_settings directory does not exist: {directory}")
    if args.restore:
        return restore(directory, args.skip_launcher_config)

    documents = prepare(directory, args.skip_launcher_config)
    changed = [
        (document, before)
        for document, before in documents
        if document.bytes() != before
    ]
    if not changed:
        print(f"Already optimized: {directory}")
        return 0
    if args.check:
        for document, _ in changed:
            print(f"Needs update: {document.path}")
        return 1

    apply(changed)
    for document, _ in changed:
        print(f"Updated: {document.path}")
        print(f"  backup: {backup_path(document.path)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply Darktide performance settings on Linux.")
    parser.add_argument("--check", action="store_true", help="check only; exit 1 if changes are needed")
    parser.add_argument("--restore", action="store_true", help="restore backups made by this script")
    parser.add_argument(
        "--skip-launcher-config",
        action="store_true",
        help="apply only settings_common.ini and win32_settings.ini",
    )
    args = parser.parse_args()
    try:
        return run(args)
    except (ConfigError, OSError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
