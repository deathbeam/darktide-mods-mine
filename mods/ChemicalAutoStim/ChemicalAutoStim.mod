return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ChemicalAutoStim` encountered an error loading the Darktide Mod Framework.")

		new_mod("ChemicalAutoStim", {
			mod_script       = "ChemicalAutoStim/scripts/mods/ChemicalAutoStim/ChemicalAutoStim",
			mod_data         = "ChemicalAutoStim/scripts/mods/ChemicalAutoStim/ChemicalAutoStim_data",
			mod_localization = "ChemicalAutoStim/scripts/mods/ChemicalAutoStim/ChemicalAutoStim_localization",
		})
	end,
	packages = {},
}
