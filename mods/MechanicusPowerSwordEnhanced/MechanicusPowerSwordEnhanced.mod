return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MechanicusPowerSwordEnhanced` encountered an error loading the Darktide Mod Framework.")

		new_mod("MechanicusPowerSwordEnhanced", {
			mod_script       = "MechanicusPowerSwordEnhanced/scripts/mods/MechanicusPowerSwordEnhanced/MechanicusPowerSwordEnhanced",
			mod_data         = "MechanicusPowerSwordEnhanced/scripts/mods/MechanicusPowerSwordEnhanced/MechanicusPowerSwordEnhanced_data",
			mod_localization = "MechanicusPowerSwordEnhanced/scripts/mods/MechanicusPowerSwordEnhanced/MechanicusPowerSwordEnhanced_localization",
		})
	end,
	packages = {},
}
