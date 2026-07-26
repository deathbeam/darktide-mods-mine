return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BetterNameplate` encountered an error loading the Darktide Mod Framework.")

		new_mod("BetterNameplate", {
			mod_script       = "BetterNameplate/scripts/mods/BetterNameplate/BetterNameplate",
			mod_data         = "BetterNameplate/scripts/mods/BetterNameplate/BetterNameplate_data",
			mod_localization = "BetterNameplate/scripts/mods/BetterNameplate/BetterNameplate_localization",
		})
	end,
	packages = {},
}
