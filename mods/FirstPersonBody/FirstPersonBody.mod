return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FirstPersonBody` could not load the Darktide Mod Framework.")

		new_mod("FirstPersonBody", {
			mod_script       = "FirstPersonBody/scripts/mods/FirstPersonBody/FirstPersonBody",
			mod_data         = "FirstPersonBody/scripts/mods/FirstPersonBody/FirstPersonBody_data",
			mod_localization = "FirstPersonBody/scripts/mods/FirstPersonBody/FirstPersonBody_localization",
		})
	end,
	packages = {},
}
