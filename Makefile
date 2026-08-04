.PHONY: sync status force clean optimize optimize-check optimize-restore
# Override this for a non-standard Steam library.
DARKTIDE_SETTINGS_DIR ?= $(HOME)/.local/share/Steam/steamapps/common/Warhammer 40,000 DARKTIDE/bundle/application_settings
export DARKTIDE_SETTINGS_DIR

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

# Apply the post-update settings from Darktide-Performance-Optimizations.
# Set DARKTIDE_SETTINGS_DIR to override the default Linux Steam path.
optimize:
	python3 scripts/optimize_darktide.py

# Check without editing; returns non-zero when a game update removed changes.
optimize-check:
	python3 scripts/optimize_darktide.py --check

# Restore the backups made by optimize.
optimize-restore:
	python3 scripts/optimize_darktide.py --restore
