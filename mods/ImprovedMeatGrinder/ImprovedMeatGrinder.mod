return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ImprovedMeatGrinder` encountered an error loading the Darktide Mod Framework.")

		new_mod("ImprovedMeatGrinder", {
			mod_script       = "ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder",
			mod_data         = "ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_data",
			mod_localization = "ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_localization",
		})
	end,

	load_after = {
		"SimpleAssets",
		"DarktideLocalServer",
	},
	packages = {},
}
