return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`state_your_name` could not load the Darktide Mod Framework.")

		new_mod("state_your_name", {
			mod_script = "state_your_name/scripts/mods/state_your_name/state_your_name",
			mod_data = "state_your_name/scripts/mods/state_your_name/state_your_name_data",
			mod_localization = "state_your_name/scripts/mods/state_your_name/state_your_name_localization",
		})
	end,
	packages = {},
}
