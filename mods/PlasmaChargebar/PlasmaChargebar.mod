return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PlasmaChargebar` encountered an error loading the Darktide Mod Framework.")

		new_mod("PlasmaChargebar", {
			mod_script       = "PlasmaChargebar/scripts/mods/PlasmaChargebar/PlasmaChargebar",
			mod_data         = "PlasmaChargebar/scripts/mods/PlasmaChargebar/PlasmaChargebar_data",
			mod_localization = "PlasmaChargebar/scripts/mods/PlasmaChargebar/PlasmaChargebar_localization",
		})
	end,
	packages = {},
}
