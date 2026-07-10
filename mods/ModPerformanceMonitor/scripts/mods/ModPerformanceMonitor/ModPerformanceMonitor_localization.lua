return {
	mod_name = {
		en = "Mod Performance Monitor",
	},
	mod_description = {
		en = "Shows which of your installed mods use the most CPU each frame, colour-coded from light to heavy. A Simplified view for a quick read, and a Detailed view with full numbers.",
	},

	display_mode = {
		en = "Display mode",
	},
	display_mode_tooltip = {
		en = "Simplified = plain-language, colour-coded list (recommended). Detailed = full numeric table.",
	},
	display_mode_simplified = {
		en = "Simplified (recommended)",
	},
	display_mode_detailed = {
		en = "Detailed",
	},

	sort_mode = {
		en = "Sort by",
	},
	sort_mode_tooltip = {
		en = "Which value to rank mods by.",
	},
	sort_self = {
		en = "CPU time (a mod's own work)",
	},
	sort_peak = {
		en = "Peak (worst single frame)",
	},
	sort_spikes = {
		en = "Stutters caused",
	},
	sort_load = {
		en = "Load time (startup cost)",
	},
	sort_incl = {
		en = "CPU time (including nested calls)",
	},
	sort_calls = {
		en = "Calls per frame",
	},
	sort_mem = {
		en = "Memory used per frame",
	},
	sort_total = {
		en = "Total time since reset",
	},

	show_graph = {
		en = "Show session graph",
	},
	show_graph_tooltip = {
		en = "Draw a live graph of the last ~30 seconds of total mod CPU at the bottom of the panel.",
	},

	smoothing = {
		en = "Number stability",
	},
	smoothing_tooltip = {
		en = "How steady the on-screen numbers are. Measurement stays exact either way; this only affects the display. 'Smooth' is easiest to read.",
	},
	smoothing_smooth = {
		en = "Smooth (easiest to read)",
	},
	smoothing_balanced = {
		en = "Balanced",
	},
	smoothing_responsive = {
		en = "Responsive (jumpy)",
	},

	safe_mode = {
		en = "Safe mode",
	},
	safe_mode_tooltip = {
		en = "Stop the monitor touching any other mod at all. No timings will be collected. You should not need this: the monitor hides its own stack frames so mods that read the call stack keep working. Turn it on only if another mod starts erroring after you install this one, then please report it. Takes effect after a relaunch.",
	},
	subtract_overhead = {
		en = "Subtract profiler overhead",
	},
	subtract_overhead_tooltip = {
		en = "Subtract the monitor's own per-call cost so you see each mod's real time rather than the measurement tax. Recommended on.",
	},
	enabled_profiling = {
		en = "Profiling enabled",
	},
	enabled_profiling_tooltip = {
		en = "Master switch. When off, the monitor collects nothing and adds almost no overhead.",
	},
	track_memory = {
		en = "Track memory (approximate)",
	},
	track_memory_tooltip = {
		en = "Also estimate per-mod Lua memory allocation each frame. Heavier and noisier; off by default.",
	},

	max_rows = {
		en = "Max mods shown",
	},
	max_rows_tooltip = {
		en = "How many mods to list on the overlay. The full log report always includes every mod.",
	},
	overlay_font_size = {
		en = "Font size",
	},
	overlay_font_size_tooltip = {
		en = "Text size of the on-screen panel.",
	},
	panel_width = {
		en = "Panel width",
	},
	panel_width_tooltip = {
		en = "Fixed width of the Simplified panel, in pixels. A fixed width keeps the columns aligned and stops the panel resizing as numbers change.",
	},
	refresh_hz = {
		en = "Refresh rate (Hz)",
	},
	refresh_hz_tooltip = {
		en = "How often the panel text updates per second. Timing is still measured every frame.",
	},
	hitch_ms = {
		en = "Stutter threshold (ms)",
	},
	hitch_ms_tooltip = {
		en = "A frame slower than this (and slower than ~1.8x your average) counts as a stutter, blamed on whichever mod dominated it. 28 ms is roughly a hitch below 36 FPS.",
	},
	overlay_x = {
		en = "Panel X position",
	},
	overlay_x_tooltip = {
		en = "Horizontal position of the panel, in pixels from the left edge.",
	},
	overlay_y = {
		en = "Panel Y position",
	},
	overlay_y_tooltip = {
		en = "Vertical position of the panel, in pixels from the top edge.",
	},

	keybind_toggle_overlay = {
		en = "Show / hide overlay",
	},
	keybind_toggle_overlay_tooltip = {
		en = "Show or hide the on-screen panel. The overlay always starts hidden when you launch the game - press this to bring it up.",
	},
	keybind_toggle_mode = {
		en = "Switch Simplified / Detailed",
	},
	keybind_toggle_mode_tooltip = {
		en = "Flip between the Simplified and Detailed views.",
	},
	keybind_cycle_tab = {
		en = "Next tab (All / CPU / Memory / ...)",
	},
	keybind_cycle_tab_tooltip = {
		en = "Cycle through the overlay tabs (All / CPU / Memory / Stutters / Loading).",
	},
	keybind_toggle_freeze = {
		en = "Freeze / unfreeze panel",
	},
	keybind_toggle_freeze_tooltip = {
		en = "Freeze the panel so you can read it. Measurement keeps running; press again to resume live updates.",
	},
	keybind_dump_report = {
		en = "Dump full report to log",
	},
	keybind_dump_report_tooltip = {
		en = "Write a full report of every mod (with a breakdown of where each spends its time) to the DMF log, and echo the top 5 to chat. Works everywhere, including menus.",
	},
	keybind_export_report = {
		en = "Export report (text file)",
	},
	keybind_export_report_tooltip = {
		en = "Write a timestamped, readable text report of every mod into the mods/ModPerformanceMonitor/reports folder.",
	},
	keybind_reset_stats = {
		en = "Reset stats",
	},
	keybind_reset_stats_tooltip = {
		en = "Clear all timings and start measuring fresh.",
	},
}
