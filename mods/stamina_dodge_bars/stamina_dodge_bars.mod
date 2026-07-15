return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`stamina_dodge_bars` encountered an error loading the Darktide Mod Framework.")

		new_mod("stamina_dodge_bars", {
			mod_script       = "stamina_dodge_bars/scripts/mods/stamina_dodge_bars/stamina_dodge_bars",
			mod_data         = "stamina_dodge_bars/scripts/mods/stamina_dodge_bars/stamina_dodge_bars_data",
			mod_localization = "stamina_dodge_bars/scripts/mods/stamina_dodge_bars/stamina_dodge_bars_localization",
		})
	end,
	packages = {},
}
