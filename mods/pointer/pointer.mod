return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`pointer` encountered an error loading the Darktide Mod Framework.")

		new_mod("pointer", {
			mod_script       = "pointer/scripts/mods/pointer/pointer",
			mod_data         = "pointer/scripts/mods/pointer/pointer_data",
			mod_localization = "pointer/scripts/mods/pointer/pointer_localization",
		})
	end,
	packages = {},
}
