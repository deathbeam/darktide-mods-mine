return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LoadoutPreviews` encountered an error loading the Darktide Mod Framework.")

		new_mod("LoadoutPreviews", {
			mod_script       = "LoadoutPreviews/scripts/mods/LoadoutPreviews/loadout_previews",
			mod_data         = "LoadoutPreviews/scripts/mods/LoadoutPreviews/loadout_previews_data",
			mod_localization = "LoadoutPreviews/scripts/mods/LoadoutPreviews/loadout_previews_localization",
		})
	end,
	packages = {},
}
