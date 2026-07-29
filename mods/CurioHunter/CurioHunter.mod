return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CurioHunter` encountered an error loading the Darktide Mod Framework.")

		new_mod("CurioHunter", {
			mod_script       = "CurioHunter/scripts/mods/CurioHunter/CurioHunter",
			mod_data         = "CurioHunter/scripts/mods/CurioHunter/CurioHunter_data",
			mod_localization = "CurioHunter/scripts/mods/CurioHunter/CurioHunter_localization",
		})
	end,
	packages = {},
}