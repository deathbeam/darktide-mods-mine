return {
	mod_name = {
		en = "Mod Performance Monitor",
		["zh-cn"] = "模组性能监视器"
	},
	mod_description = {
		en = "Shows which of your installed mods use the most CPU each frame, colour-coded from light to heavy. A Simplified view for a quick read, and a Detailed view with full numbers.",
		["zh-cn"] = "显示每帧占用CPU最高的模组，按负载轻重使用不同颜色区分。简易视图方便快速查看，详细视图展示完整数值。"
	},

	display_mode = {
		en = "Display mode",
		["zh-cn"] = "显示模式"
	},
	display_mode_tooltip = {
		en = "Simplified = plain-language, colour-coded list (recommended). Detailed = full numeric table.",
		["zh-cn"] = "简易：文字+彩色列表（推荐）；详细：完整数字表格。"
	},
	display_mode_simplified = {
		en = "Simplified (recommended)",
		["zh-cn"] = "简易模式（推荐）"
	},
	display_mode_detailed = {
		en = "Detailed",
		["zh-cn"] = "详细模式"
	},

	sort_mode = {
		en = "Sort by",
		["zh-cn"] = "排序依据"
	},
	sort_mode_tooltip = {
		en = "Which value to rank mods by.",
		["zh-cn"] = "选择模组列表的排序维度。"
	},
	sort_self = {
		en = "CPU time (a mod's own work)",
		["zh-cn"] = "CPU耗时（模组自身运算）"
	},
	sort_peak = {
		en = "Peak (worst single frame)",
		["zh-cn"] = "峰值（单帧最高占用）"
	},
	sort_spikes = {
		en = "Stutters caused",
		["zh-cn"] = "造成卡顿次数"
	},
	sort_load = {
		en = "Load time (startup cost)",
		["zh-cn"] = "加载耗时（启动开销）"
	},
	sort_incl = {
		en = "CPU time (including nested calls)",
		["zh-cn"] = "CPU耗时（含嵌套调用）"
	},
	sort_calls = {
		en = "Calls per frame",
		["zh-cn"] = "每帧调用次数"
	},
	sort_mem = {
		en = "Memory used per frame",
		["zh-cn"] = "每帧内存占用"
	},
	sort_total = {
		en = "Total time since reset",
		["zh-cn"] = "重置后总耗时"
	},

	show_graph = {
		en = "Show session graph",
		["zh-cn"] = "显示实时曲线图"
	},
	show_graph_tooltip = {
		en = "Draw a live graph of the last ~30 seconds of total mod CPU at the bottom of the panel.",
		["zh-cn"] = "面板底部绘制近30秒模组总CPU占用实时曲线。"
	},

	smoothing = {
		en = "Number stability",
		["zh-cn"] = "数值平滑度"
	},
	smoothing_tooltip = {
		en = "How steady the on-screen numbers are. Measurement stays exact either way; this only affects the display. 'Smooth' is easiest to read.",
		["zh-cn"] = "控制屏幕数值跳动幅度，原始测量数据不受影响，仅改变显示效果。平滑模式更易阅读。"
	},
	smoothing_smooth = {
		en = "Smooth (easiest to read)",
		["zh-cn"] = "平滑（阅读舒适）"
	},
	smoothing_balanced = {
		en = "Balanced",
		["zh-cn"] = "均衡"
	},
	smoothing_responsive = {
		en = "Responsive (jumpy)",
		["zh-cn"] = "灵敏（数值跳动大）"
	},

	safe_mode = {
		en = "Safe mode",
		["zh-cn"] = "安全模式"
	},
	safe_mode_tooltip = {
		en = "Stop the monitor touching any other mod at all. No timings will be collected. You should not need this: the monitor hides its own stack frames so mods that read the call stack keep working. Turn it on only if another mod starts erroring after you install this one, then please report it. Takes effect after a relaunch.",
		["zh-cn"] = "完全停止监测、不采集任何性能数据。一般无需开启；本模组会隐藏自身调用栈避免冲突。仅在其他模组报错时启用，重启生效。"
	},
	subtract_overhead = {
		en = "Subtract profiler overhead",
		["zh-cn"] = "扣除监测自身开销"
	},
	subtract_overhead_tooltip = {
		en = "Subtract the monitor's own per-call cost so you see each mod's real time rather than the measurement tax. Recommended on.",
		["zh-cn"] = "扣除监视器本身产生的性能损耗，显示模组真实耗时，推荐开启。"
	},
	enabled_profiling = {
		en = "Profiling enabled",
		["zh-cn"] = "启用性能采集"
	},
	enabled_profiling_tooltip = {
		en = "Master switch. When off, the monitor collects nothing and adds almost no overhead.",
		["zh-cn"] = "总开关，关闭后不采集任何数据，几乎无性能消耗。"
	},
	track_memory = {
		en = "Track memory (approximate)",
		["zh-cn"] = "追踪内存（估算值）"
	},
	track_memory_tooltip = {
		en = "Also estimate per-mod Lua memory allocation each frame. Heavier and noisier; off by default.",
		["zh-cn"] = "额外估算每个模组每帧Lua内存分配，开销更高、数值波动大，默认关闭。"
	},

	max_rows = {
		en = "Max mods shown",
		["zh-cn"] = "最大显示模组条数"
	},
	max_rows_tooltip = {
		en = "How many mods to list on the overlay. The full log report always includes every mod.",
		["zh-cn"] = "悬浮面板最多展示多少个模组，完整日志会记录全部模组。"
	},
	overlay_font_size = {
		en = "Font size",
		["zh-cn"] = "字体大小"
	},
	overlay_font_size_tooltip = {
		en = "Text size of the on-screen panel.",
		["zh-cn"] = "屏幕悬浮面板文字尺寸。"
	},
	panel_width = {
		en = "Panel width",
		["zh-cn"] = "面板宽度"
	},
	panel_width_tooltip = {
		en = "Fixed width of the Simplified panel, in pixels. A fixed width keeps the columns aligned and stops the panel resizing as numbers change.",
		["zh-cn"] = "简易面板固定像素宽度，保证列对齐，避免数值变化导致面板拉伸。"
	},
	refresh_hz = {
		en = "Refresh rate (Hz)",
		["zh-cn"] = "刷新频率(赫兹)"
	},
	refresh_hz_tooltip = {
		en = "How often the panel text updates per second. Timing is still measured every frame.",
		["zh-cn"] = "面板文字每秒更新次数，性能数据依旧逐帧采集。"
	},
	hitch_ms = {
		en = "Stutter threshold (ms)",
		["zh-cn"] = "卡顿阈值(毫秒)"
	},
	hitch_ms_tooltip = {
		en = "A frame slower than this (and slower than ~1.8x your average) counts as a stutter, blamed on whichever mod dominated it. 28 ms is roughly a hitch below 36 FPS.",
		["zh-cn"] = "单帧耗时超过该数值（且高于平均帧1.8倍）判定为卡顿，归属占用最高模组。28ms约等于帧率低于36帧。"
	},
	overlay_x = {
		en = "Panel X position",
		["zh-cn"] = "面板横向坐标"
	},
	overlay_x_tooltip = {
		en = "Horizontal position of the panel, in pixels from the left edge.",
		["zh-cn"] = "面板距离屏幕左边缘的像素位置。"
	},
	overlay_y = {
		en = "Panel Y position",
		["zh-cn"] = "面板纵向坐标"
	},
	overlay_y_tooltip = {
		en = "Vertical position of the panel, in pixels from the top edge.",
		["zh-cn"] = "面板距离屏幕上边缘的像素位置。"
	},

	keybind_toggle_overlay = {
		en = "Show / hide overlay",
		["zh-cn"] = "显示/隐藏面板"
	},
	keybind_toggle_overlay_tooltip = {
		en = "Show or hide the on-screen panel. The overlay always starts hidden when you launch the game - press this to bring it up.",
		["zh-cn"] = "开关屏幕悬浮面板，游戏启动默认隐藏，按快捷键调出。"
	},
	keybind_toggle_mode = {
		en = "Switch Simplified / Detailed",
		["zh-cn"] = "切换简易/详细模式"
	},
	keybind_toggle_mode_tooltip = {
		en = "Flip between the Simplified and Detailed views.",
		["zh-cn"] = "在简易视图与详细视图之间切换。"
	},
	keybind_cycle_tab = {
		en = "Next tab (All / CPU / Memory / ...)",
		["zh-cn"] = "切换标签（全部/CPU/内存等）"
	},
	keybind_cycle_tab_tooltip = {
		en = "Cycle through the overlay tabs (All / CPU / Memory / Stutters / Loading).",
		["zh-cn"] = "循环切换面板标签：全部、CPU、内存、卡顿、加载。"
	},
	keybind_toggle_freeze = {
		en = "Freeze / unfreeze panel",
		["zh-cn"] = "冻结/解除面板更新"
	},
	keybind_toggle_freeze_tooltip = {
		en = "Freeze the panel so you can read it. Measurement keeps running; press again to resume live updates.",
		["zh-cn"] = "暂停面板刷新方便查看，后台持续采集数据，再次按键恢复实时更新。"
	},
	keybind_dump_report = {
		en = "Dump full report to log",
		["zh-cn"] = "输出完整报告到日志"
	},
	keybind_dump_report_tooltip = {
		en = "Write a full report of every mod (with a breakdown of where each spends its time) to the DMF log, and echo the top 5 to chat. Works everywhere, including menus.",
		["zh-cn"] = "将所有模组完整性能明细写入DMF日志，同时前5项输出聊天栏，菜单/对局均可使用。"
	},
	keybind_export_report = {
		en = "Export report (text file)",
		["zh-cn"] = "导出报告（文本文件）"
	},
	keybind_export_report_tooltip = {
		en = "Write a timestamped, readable text report into the mods/ModPerformanceMonitor/reports folder.",
		["zh-cn"] = "生成带时间戳的可读文本报告，保存至模组目录下的reports文件夹。"
	},
	keybind_reset_stats = {
		en = "Reset stats",
		["zh-cn"] = "重置统计数据"
	},
	keybind_reset_stats_tooltip = {
		en = "Clear all timings and start measuring fresh.",
		["zh-cn"] = "清空全部计时数据，重新开始采集。"
	},

	tab_all = {
		en = "All",
		["zh-cn"] = "全部"
	},
	tab_cpu = {
		en = "CPU",
		["zh-cn"] = "CPU"
	},
	tab_mem = {
		en = "Memory",
		["zh-cn"] = "内存"
	},
	tab_spikes = {
		en = "Stutters",
		["zh-cn"] = "卡顿"
	},
	tab_load = {
		en = "Loading",
		["zh-cn"] = "加载"
	},

	title_all = {
		en = "MOD PERFORMANCE",
		["zh-cn"] = "模组性能总览"
	},
	title_tab = {
		en = "MOD PERFORMANCE - %s",
		["zh-cn"] = "模组性能 - %s"
	},
	title_detailed = {
		en = "MOD PERFORMANCE MONITOR - detailed",
		["zh-cn"] = "模组性能监视器 - 详细"
	},
	state_frozen = {
		en = "[FROZEN]",
		["zh-cn"] = "[已冻结]"
	},
	state_paused = {
		en = "[PAUSED]",
		["zh-cn"] = "[已暂停]"
	},

	stat_cpu_used = {
		en = "CPU used by mods",
		["zh-cn"] = "模组占用CPU"
	},
	stat_smoothness = {
		en = "Smoothness (worst 1%% of frames)",
		["zh-cn"] = "流畅度（最慢1%%帧）"
	},
	stat_memory = {
		en = "Memory (Lua)",
		["zh-cn"] = "内存（Lua）"
	},
	stat_gc = {
		en = "Garbage collection",
		["zh-cn"] = "垃圾回收"
	},
	stat_load_slow = {
		en = "Slowed loading by",
		["zh-cn"] = "加载额外耗时"
	},
	stat_stutters_detected = {
		en = "Stutters detected",
		["zh-cn"] = "检测到卡顿"
	},
	stat_stutters = {
		en = "Stutters",
		["zh-cn"] = "卡顿"
	},
	stat_impact_low = {
		en = "Overall mod impact is low right now",
		["zh-cn"] = "当前模组总体影响较低"
	},
	stat_coarse_timer = {
		en = "Coarse timer: averages OK, single-frame peaks approximate",
		["zh-cn"] = "计时器精度较低：平均值可靠，单帧峰值仅供参考"
	},
	stat_safe_mode = {
		en = "Safe mode on: no mods are being measured",
		["zh-cn"] = "安全模式已开启：未测量任何模组"
	},
	stat_shim_inactive = {
		en = "Stack shim inactive: measuring is off so nothing can break",
		["zh-cn"] = "堆栈桥接未激活：测量已关闭，不会影响其他模组"
	},
	stat_coverage_full = {
		en = "Hook coverage: full (loaded first)",
		["zh-cn"] = "Hook覆盖：完整（最先加载）"
	},
	stat_coverage_partial = {
		en = "Hooks not measured for: %s",
		["zh-cn"] = "未测量的Hook：%s"
	},
	stat_coverage_earlier = {
		en = "Hook coverage: %d earlier mod%s not measured",
		["zh-cn"] = "Hook覆盖：%d 个前置模组未被测量"
	},
	stat_suspects = {
		en = "Suspects",
		["zh-cn"] = "嫌疑模组"
	},
	stat_load_added = {
		en = "Mods added to loading",
		["zh-cn"] = "模组加载增加耗时"
	},
	stat_track_memory_hint1 = {
		en = "Turn on 'Track memory' in options",
		["zh-cn"] = "在选项中开启“追踪内存”"
	},
	stat_track_memory_hint2 = {
		en = "to see per-mod memory here.",
		["zh-cn"] = "可在此查看每个模组的内存占用"
	},
	stat_detailed_summary = {
		en = "total %.2f ms/frame   Lua %.0f MB   %d mods   %d FPS (1%% low %d)",
		["zh-cn"] = "总耗时 %.2f ms/帧   Lua %.0f MB   %d 个模组   %d FPS (1%%低帧 %d)"
	},
	stat_detailed_footer = {
		en = "worst frame %.1f ms   mods added ~%.1fs to load   sort: %s",
		["zh-cn"] = "最差帧 %.1f ms   模组加载增加 ~%.1fs   排序：%s"
	},
	stat_timer_info = {
		en = "timer %s ~%.4fms   overhead ~%.4fms/call %s   (estimates)",
		["zh-cn"] = "计时器 %s ~%.4fms   开销 ~%.4fms/次 %s   （估算值）"
	},

	col_mod = {
		en = "MOD",
		["zh-cn"] = "模组"
	},
	col_time = {
		en = "TIME",
		["zh-cn"] = "耗时"
	},
	col_share = {
		en = "SHARE",
		["zh-cn"] = "占比"
	},
	col_kb_frame = {
		en = "KB/frame",
		["zh-cn"] = "KB/帧"
	},
	col_stutters = {
		en = "stutters",
		["zh-cn"] = "卡顿次数"
	},
	col_load_time = {
		en = "load time",
		["zh-cn"] = "加载时间"
	},
	col_self = {
		en = "self",
		["zh-cn"] = "自身"
	},
	col_p95 = {
		en = "p95",
		["zh-cn"] = "95%%分位"
	},
	col_peak = {
		en = "peak",
		["zh-cn"] = "峰值"
	},
	col_calls = {
		en = "calls",
		["zh-cn"] = "调用/帧"
	},
	col_share_detail = {
		en = "share",
		["zh-cn"] = "占比"
	},

	msg_no_cpu_measurable = {
		en = "no mod is using measurable CPU right now",
		["zh-cn"] = "当前没有模组产生可测量的CPU占用"
	},
	msg_negligible_more = {
		en = "+ %d more with negligible impact",
		["zh-cn"] = "+ %d 个影响可忽略"
	},
	msg_no_cpu_use = {
		en = "no measurable CPU use",
		["zh-cn"] = "无可测量的CPU使用"
	},
	msg_no_allocation = {
		en = "no measurable allocation",
		["zh-cn"] = "无可测量的内存分配"
	},
	msg_none_recently = {
		en = "none recently",
		["zh-cn"] = "近期无"
	},
	msg_no_stutters = {
		en = "no stutters recorded",
		["zh-cn"] = "未记录到卡顿"
	},
	msg_no_load_cost = {
		en = "no measurable load cost",
		["zh-cn"] = "无显著的加载开销"
	},
	msg_rows_more = {
		en = "... %d more (raise Max rows, or dump full report)",
		["zh-cn"] = "... 还有 %d 个（可提高“最大显示条数”或导出完整报告）"
	},

	graph_title = {
		en = "last %ds - all mods   now %.2f  peak %.2f   (line = %.2f ms)",
		["zh-cn"] = "近 %d 秒 - 所有模组  当前 %.2f  峰值 %.2f  （参考线 = %.2f ms）"
	},

	report_header = {
		en = "===== Mod Performance Report =====",
		["zh-cn"] = "===== 模组性能报告 ====="
	},
	report_note = {
		en = "NOTE: these figures cover Lua MAIN-THREAD cost only. They are a RANKING, not an absolute measurement: GPU and engine C++ work are invisible here, so a mod can look cheap and still cost you frames. Spike blame is a heuristic. Please don't cite this as proof against a mod author.",
		["zh-cn"] = "注意：以下数值仅涵盖Lua主线程开销，是排名参考而非绝对测量：GPU与引擎C++运算在此不可见，因此模组可能显示开销很低却仍拖慢帧率。卡顿归因为启发式判断。请勿以此作为指责模组作者的依据。"
	},
	report_uncertainty = {
		en = "timer resolution is %.3f ms; values below are averages over many frames. The +/- column is a 95%% confidence interval, so a mod whose cost is smaller than its own +/- is not distinguishable from noise. Use the A/B keybind for a single trustworthy number.",
		["zh-cn"] = "计时器精度为 %.3f ms；下列数值为多帧平均值。± 列为95%%置信区间：若某模组开销小于其 ± 值，则与噪声无法区分。如需单个可信数值，请使用 A/B 快捷键。"
	},
	report_stats = {
		en = "timer: %s (~%.5f ms) | overhead ~%.5f ms/call | Lua %.0f MB | total mod CPU %.3f ms/frame | 1%% low %d FPS | worst frame %.1f ms",
		["zh-cn"] = "计时器：%s （~%.5f ms）| 开销 ~%.5f ms/次 | Lua %.0f MB | 模组总CPU %.3f ms/帧 | 1%%低帧 %d FPS | 最差帧 %.1f ms"
	},
	report_sorted = {
		en = "sorted by: %s | mods tracked: %d | memory tracking: %s",
		["zh-cn"] = "排序依据：%s | 追踪模组：%d | 内存追踪：%s"
	},
	report_shim = {
		en = "stack shim: %s (%s) | safe mode: %s | instrumenting: %s",
		["zh-cn"] = "堆栈桥接：%s （%s）| 安全模式：%s | 正在监测：%s"
	},
	report_columns = {
		en = "rank  self_ms    +/-    conf   p95    peak   spikes  calls/f   total_ms  load_ms   mod",
		["zh-cn"] = "排名  自身(ms)   ±    置信   p95   峰值  卡顿次数  调用/帧  总耗时(ms)  加载(ms)  模组"
	},

	feedback_dump_log = {
		en = "Full report written to the DMF log (%d mods).",
		["zh-cn"] = "完整报告已写入 DMF 日志（%d 个模组）。"
	},
	feedback_export_saved = {
		en = "Saved to mods/ModPerformanceMonitor/reports/perf_%s.txt",
		["zh-cn"] = "已保存至 mods/ModPerformanceMonitor/reports/perf_%s.txt"
	},
	feedback_reset = {
		en = "Stats reset.",
		["zh-cn"] = "统计数据已重置。"
	},
	feedback_export_fail = {
		en = "[PerfMonitor] Could not write the report file (see log).",
		["zh-cn"] = "[性能监视器] 无法写入报告文件（请查看日志）。"
	},
	feedback_no_io = {
		en = "[PerfMonitor] File writing isn't available in this environment.",
		["zh-cn"] = "[性能监视器] 当前环境不支持文件写入。"
	},

	init_instrumented = {
		en = "Instrumented %d mods (+%d HUD elements). Loaded after %d other mods. Hook patch: %s.",
		["zh-cn"] = "已监测 %d 个模组（+%d 个HUD元素），在 %d 个其他模组之后加载。Hook补丁：%s。"
	},
	init_loaded_after = {
		en = "Loaded after these mods (their hooks are not measured): %s",
		["zh-cn"] = "在此之后加载的模组（其Hook未被测量）：%s"
	},

	stat_frame_pct = {
		en = "~%.0f%% of a frame at %d FPS",
		["zh-cn"] = "约占一帧 ~%.0f%% （%d FPS下）"
	},
	stat_fps_avg = {
		en = "%d FPS avg",
		["zh-cn"] = "平均 %d FPS"
	},
	stat_fps_low = {
		en = "%d FPS low",
		["zh-cn"] = "低帧 %d FPS"
	},
	stat_worst_frame = {
		en = "Worst frame",
		["zh-cn"] = "最差帧"
	},
	stat_see_stutters_tab = {
		en = "see Stutters tab",
		["zh-cn"] = "查看卡顿标签"
	},
	stat_rec_heaviest = {
		en = "Your 3 heaviest mods use %.2f ms/frame combined",
		["zh-cn"] = "最耗时的3个模组合计占用 %.2f ms/帧"
	},
	stat_frame_pct_simple = {
		en = "~%.0f%% of a frame",
		["zh-cn"] = "约占一帧 ~%.0f%%"
	},
	removed = {
		en = "removed",
		["zh-cn"] = "已扣除"
	},
	shown = {
		en = "shown",
		["zh-cn"] = "显示"
	},
	on = {
		en = "on",
		["zh-cn"] = "开启"
	},
	off = {
		en = "off",
		["zh-cn"] = "关闭"
	},
	active = {
		en = "active",
		["zh-cn"] = "启用"
	},
	inactive = {
		en = "inactive",
		["zh-cn"] = "未启用"
	},
	yes = {
		en = "yes",
		["zh-cn"] = "是"
	},
	no = {
		en = "no",
		["zh-cn"] = "否"
	},

	col_ci = {
		en = "+/-",
		["zh-cn"] = "±"
	},
	col_conf = {
		en = "conf",
		["zh-cn"] = "置信"
	},
	conf_high = {
		en = "high",
		["zh-cn"] = "高"
	},
	conf_med = {
		en = "med",
		["zh-cn"] = "中"
	},
	conf_low = {
		en = "low",
		["zh-cn"] = "低"
	},
	conf_dash = {
		en = "-",
		["zh-cn"] = "-"
	},
	stat_ranks_hint = {
		en = "This list ranks mods. For one mod's true cost, use the A/B keybind.",
		["zh-cn"] = "此列表用于排名。要测量单个模组的真实开销，请使用 A/B 快捷键。"
	},

	keybind_ab_test = {
		en = "Measure the heaviest mod (A/B)",
		["zh-cn"] = "测量最耗时的模组（A/B）"
	},
	keybind_ab_test_tooltip = {
		en = "Turns the heaviest mod's work on and off many times over about 11 seconds and measures the real frame-time difference, with a 95%% confidence interval. If the result is indistinguishable from noise it says so instead of inventing a number. Stand still somewhere calm. The mod is briefly disabled during the test.",
		["zh-cn"] = "在约11秒内反复开关最耗时模组的运算，测量真实帧时间差异并给出95%%置信区间。若结果与噪声无法区分，则如实说明而非编造数值。请在安静处站立不动。测试期间该模组会被短暂禁用。"
	},
	keybind_calibrate = {
		en = "Check accuracy (calibration)",
		["zh-cn"] = "校准精度（自检）"
	},
	keybind_calibrate_tooltip = {
		en = "Runs a workload of a known size and compares what the profiler reports against the real frame-time cost. Tells you how much to trust the numbers on this machine. Stand still somewhere calm.",
		["zh-cn"] = "运行已知大小的负载，将监测器读数与真实帧时间开销对比，评估本机数值的可信度。请在安静处站立不动。"
	},

	ab_start = {
		en = "[A/B] Testing '%s' for ~%.0fs. It is briefly disabled; stand still.",
		["zh-cn"] = "[A/B] 正在测试 '%s'，约 %.0f 秒。测试期间会短暂禁用该模组，请站立不动。"
	},
	ab_result = {
		en = "[A/B] '%s' costs %.3f +/- %.3f ms/frame (95%% CI, %d blocks)",
		["zh-cn"] = "[A/B] '%s' 开销 %.3f +/- %.3f ms/帧（95%% 置信区间，%d 组）"
	},
	ab_no_impact = {
		en = "[A/B] '%s': no measurable impact (%.3f +/- %.3f ms/frame)",
		["zh-cn"] = "[A/B] '%s'：无可测量影响（%.3f +/- %.3f ms/帧）"
	},
	ab_no_mod = {
		en = "[A/B] No mod has measurable cost yet.",
		["zh-cn"] = "[A/B] 目前没有模组产生可测量的开销。"
	},
	ab_cancelled = {
		en = "[PerfMonitor] Measurement cancelled.",
		["zh-cn"] = "[性能监视器] 测量已取消。"
	},
	ab_running = {
		en = "[PerfMonitor] A measurement is already running.",
		["zh-cn"] = "[性能监视器] 已有测量正在进行。"
	},
	ab_nothing = {
		en = "[PerfMonitor] Nothing is instrumented, so there is nothing to measure.",
		["zh-cn"] = "[性能监视器] 未监测任何模组，无可测量对象。"
	},
	ab_need_enabled = {
		en = "[PerfMonitor] Turn on 'Profiling enabled' first.",
		["zh-cn"] = "[性能监视器] 请先开启“启用性能采集”。"
	},
	ab_failed = {
		en = "[PerfMonitor] Measurement failed: not enough data.",
		["zh-cn"] = "[性能监视器] 测量失败：数据不足。"
	},

	calib_start = {
		en = "[Calibration] Measuring a known load for ~%.0fs. Stand still.",
		["zh-cn"] = "[校准] 正在测量已知负载，约 %.0f 秒。请站立不动。"
	},
	calib_header = {
		en = "[Calibration] known load, %d blocks",
		["zh-cn"] = "[校准] 已知负载，%d 组"
	},
	calib_profiler = {
		en = "  profiler reported : %.3f ms/frame",
		["zh-cn"] = "  监测器报告：%.3f ms/帧"
	},
	calib_true = {
		en = "  true cost (frame) : %.3f +/- %.3f ms/frame",
		["zh-cn"] = "  真实开销（帧）：%.3f +/- %.3f ms/帧"
	},
	calib_ratio = {
		en = "  profiler reads %.0f%% of the real cost",
		["zh-cn"] = "  监测器读数约为真实开销的 %.0f%%"
	},
	calib_toosmall = {
		en = "  load too small to verify; try again while standing still",
		["zh-cn"] = "  负载过小无法验证；请站立不动后重试"
	},
	stat_mem_unavailable = {
		en = "Per-mod memory isn't available in this game build.",
		["zh-cn"] = "当前游戏版本无法获取各模组的内存数据。"
	},
	stat_load_unavailable1 = {
		en = "Per-mod load timing isn't tracked.",
		["zh-cn"] = "不再统计各模组的加载耗时。"
	},
	stat_load_unavailable2 = {
		en = "(removed so it can't interfere with reloading mods)",
		["zh-cn"] = "（为避免干扰模组热重载已移除该功能）"
	},
}