return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SuperImpact` encountered an error loading the Darktide Mod Framework.")

		new_mod("SuperImpact", {
			mod_script       = "SuperImpact/scripts/mods/SuperImpact/SuperImpact",
			mod_data         = "SuperImpact/scripts/mods/SuperImpact/SuperImpact_data",
			mod_localization = "SuperImpact/scripts/mods/SuperImpact/SuperImpact_localization",
		})
	end,
	packages = {},
}
