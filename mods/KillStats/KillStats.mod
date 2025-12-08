return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`KillStats` encountered an error loading the Darktide Mod Framework.")

		new_mod("KillStats", {
			mod_script       = "KillStats/scripts/mods/KillStats/KillStats",
			mod_data         = "KillStats/scripts/mods/KillStats/KillStats_data",
			mod_localization = "KillStats/scripts/mods/KillStats/KillStats_localization",
		})
	end,
	packages = {},
}
