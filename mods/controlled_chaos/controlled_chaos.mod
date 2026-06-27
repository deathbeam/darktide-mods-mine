return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`controlled_chaos` encountered an error loading the Darktide Mod Framework.")

		new_mod("controlled_chaos", {
			mod_script       = "controlled_chaos/scripts/mods/controlled_chaos/controlled_chaos",
			mod_data         = "controlled_chaos/scripts/mods/controlled_chaos/controlled_chaos_data",
			mod_localization = "controlled_chaos/scripts/mods/controlled_chaos/controlled_chaos_localization",
		})
	end,
	packages = {},
}
