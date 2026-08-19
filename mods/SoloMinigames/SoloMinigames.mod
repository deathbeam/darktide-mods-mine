return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SoloMinigames` encountered an error loading the Darktide Mod Framework.")

		new_mod("SoloMinigames", {
			mod_script       = "SoloMinigames/scripts/mods/SoloMinigames/SoloMinigames",
			mod_data         = "SoloMinigames/scripts/mods/SoloMinigames/SoloMinigames_data",
			mod_localization = "SoloMinigames/scripts/mods/SoloMinigames/SoloMinigames_localization",
		})
	end,
	packages = {},
}
