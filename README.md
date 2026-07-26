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