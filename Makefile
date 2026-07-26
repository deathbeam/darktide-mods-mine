.PHONY: sync status force clean

# Sync mods from Nexus Mods: download anything outdated in mods.txt.
sync:
	python3 scripts/sync_mods.py

# Report which mods are outdated, without downloading anything.
status:
	python3 scripts/sync_mods.py --status

# Re-download every mod even if already up to date.
force:
	python3 scripts/sync_mods.py --force

# Remove leftover Nexus download archives from mods/ (ignored by .gitignore
# and not needed once extracted; sync always extracts into a folder).
clean:
	@find mods -maxdepth 1 \( -name '*.zip' -o -name '*.7z' \) -print -delete
