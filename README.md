# darktide-mods

Mods that I use + some of my own mods

## Syncing mods

Mods are tracked in [`mods.txt`](mods.txt), a lockfile with one line per mod:

```
folder mod_id version
```

Requires `NEXUSMODS_APIKEY` in the environment (Premium is needed for direct
API downloads; non-premium users get a link to download manually). Both `.zip`
and `.7z` archives are handled.

```
make sync    # download outdated mods
make status  # report outdated mods without downloading
make force   # re-download every mod
make clean   # delete leftover Nexus download archives from mods/
```

To add a new mod: find its mod_id (the number in its
`nexusmods.com/.../mods/<id>` URL), add a line `folder mod_id` to `mods.txt`,
then `make sync`.

Extracted folders are normalised to `0o755`/`0o644` so they stay writable and
re-syncable, regardless of the perms the author shipped in the archive.


## Applying Darktide performance settings

The post-update edits from [Darktide-Performance-Optimizations](https://github.com/thyazide/Darktide-Performance-Optimizations) can be applied without manually editing the game files:

```sh
make optimize
```

The script updates `settings_common.ini`, `win32_settings.ini`, and the existing `launcher/Launcher.exe.config`. It creates a `.darktide-mods.bak` backup beside each changed file, so close Darktide before running it and rerun it after game updates. Linux Steam locations are discovered automatically; use an explicit path if needed:

```sh
make optimize DARKTIDE_SETTINGS_DIR="/path/to/bundle/application_settings"
make optimize-check       # check only; exit 1 if changes are needed
make optimize-restore     # restore script backups
```

If `Launcher.exe.config` is unavailable, run with `--skip-launcher-config` to apply only the two INI files. The script does not modify launcher executables or install/enable mods.
