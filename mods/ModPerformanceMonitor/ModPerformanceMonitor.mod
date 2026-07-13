return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ModPerformanceMonitor` encountered an error loading the Darktide Mod Framework.")

		new_mod("ModPerformanceMonitor", {
			mod_script       = "ModPerformanceMonitor/scripts/mods/ModPerformanceMonitor/ModPerformanceMonitor",
			mod_data         = "ModPerformanceMonitor/scripts/mods/ModPerformanceMonitor/ModPerformanceMonitor_data",
			mod_localization = "ModPerformanceMonitor/scripts/mods/ModPerformanceMonitor/ModPerformanceMonitor_localization",
		})
	end,
	packages = {},
	version = "1.2.2",

	load_after = { "dmf" },
}
