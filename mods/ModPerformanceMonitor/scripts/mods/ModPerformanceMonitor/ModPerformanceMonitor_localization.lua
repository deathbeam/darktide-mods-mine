return {
	mod_name = {
		en = "Mod Performance Monitor",
		["zh-cn"] = "模组性能监视器"
	},
	mod_description = {
		en = "Shows which of your installed mods use the most CPU each frame, colour-coded from light to heavy. A Simplified view for a quick read, and a Detailed view with full numbers.",
		["zh-cn"] = "显示各模组每帧CPU占用，颜色越深表示越吃性能。简易视图方便快速查看，详细视图展示完整数值。"
	},

	display_mode = {
		en = "Display mode",
		["zh-cn"] = "显示模式"
	},
	display_mode_tooltip = {
		en = "Simplified = plain-language, colour-coded list (recommended). Detailed = full numeric table.",
		["zh-cn"] = "简易：文字+颜色排名（推荐）；详细：完整数字表格。"
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
		["zh-cn"] = "CPU耗时（模组自身运算时间）"
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
		["zh-cn"] = "CPU耗时（连它调用的其他东西也算上）"
	},
	sort_calls = {
		en = "Calls per frame",
		["zh-cn"] = "每帧被调用的次数"
	},
	sort_mem = {
		en = "Memory used per frame",
		["zh-cn"] = "每帧内存占用"
	},
	sort_total = {
		en = "Total time since reset",
		["zh-cn"] = "从重置算起的总耗时"
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
		["zh-cn"] = "控制屏幕上数字的跳动程度，实际测量不会变。平滑模式看着最舒服。"
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
		["zh-cn"] = "彻底关闭监视器的所有动作，不再采集任何数据。一般情况下不用开——监视器会把自己藏好，不影响别的模组。只有当你装了它后其他模组报错时才打开，然后请上报问题。重启游戏生效。"
	},
	subtract_overhead = {
		en = "Subtract profiler overhead",
		["zh-cn"] = "扣掉监视器自身的开销"
	},
	subtract_overhead_tooltip = {
		en = "Subtract the monitor's own per-call cost so you see each mod's real time rather than the measurement tax. Recommended on.",
		["zh-cn"] = "把监视器自己测速消耗的那点时间扣掉，显示模组真实耗时。推荐开启。"
	},
	enabled_profiling = {
		en = "Profiling enabled",
		["zh-cn"] = "启用性能采集"
	},
	enabled_profiling_tooltip = {
		en = "Master switch. When off, the monitor collects nothing and adds almost no overhead.",
		["zh-cn"] = "总开关。关掉后监视器不再采集任何数据，对游戏性能的影响几乎为零。"
	},
	track_memory = {
		en = "Track memory (approximate)",
		["zh-cn"] = "追踪内存占用（估算值）"
	},
	track_memory_tooltip = {
		en = "Also estimate per-mod Lua memory allocation each frame. Heavier and noisier; off by default.",
		["zh-cn"] = "额外估算每个模组每帧吃掉了多少Lua内存，开销更大且数字跳动厉害，默认关闭。"
	},

	max_rows = {
		en = "Max mods shown",
		["zh-cn"] = "最多显示几个模组"
	},
	max_rows_tooltip = {
		en = "How many mods to list on the overlay. The full log report always includes every mod.",
		["zh-cn"] = "悬浮面板最多列出多少个模组，不影响日志，日志里会完整记录全部信息。"
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
		["zh-cn"] = "简易面板的固定宽度（像素），这样数字变化时不会把面板撑大撑小，列对齐也好看。"
	},
	refresh_hz = {
		en = "Refresh rate (Hz)",
		["zh-cn"] = "刷新频率（每秒几次）"
	},
	refresh_hz_tooltip = {
		en = "How often the panel text updates per second. Timing is still measured every frame.",
		["zh-cn"] = "面板文字每秒更新几次，计时依然是每帧都在测。"
	},
	hitch_ms = {
		en = "Stutter threshold (ms)",
		["zh-cn"] = "卡顿判定阈值（毫秒）"
	},
	hitch_ms_tooltip = {
		en = "A frame slower than this (and slower than ~1.8x your average) counts as a stutter, blamed on whichever mod dominated it. 28 ms is roughly a hitch below 36 FPS.",
		["zh-cn"] = "单帧超过这个时间（并且比平均帧慢约1.8倍以上）就记一次卡顿，然后把锅扣给当时最费时的模组。28毫秒差不多就是帧率掉到36帧以下。"
	},
	overlay_x = {
		en = "Panel X position",
		["zh-cn"] = "面板水平位置"
	},
	overlay_x_tooltip = {
		en = "Horizontal position of the panel, in pixels from the left edge.",
		["zh-cn"] = "面板离屏幕左边缘的距离（像素）。"
	},
	overlay_y = {
		en = "Panel Y position",
		["zh-cn"] = "面板垂直位置"
	},
	overlay_y_tooltip = {
		en = "Vertical position of the panel, in pixels from the top edge.",
		["zh-cn"] = "面板离屏幕上边缘的距离（像素）。"
	},

	keybind_toggle_overlay = {
		en = "Show / hide overlay",
		["zh-cn"] = "显示/隐藏面板"
	},
	keybind_toggle_overlay_tooltip = {
		en = "Show or hide the on-screen panel. The overlay always starts hidden when you launch the game - press this to bring it up.",
		["zh-cn"] = "开关屏幕上的悬浮面板。游戏启动时默认是隐藏的，按这个快捷键把它叫出来。"
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
		["zh-cn"] = "循环切换面板上的不同标签页：全部、CPU、内存、卡顿、加载。"
	},
	keybind_toggle_freeze = {
		en = "Freeze / unfreeze panel",
		["zh-cn"] = "冻结/解除面板更新"
	},
	keybind_toggle_freeze_tooltip = {
		en = "Freeze the panel so you can read it. Measurement keeps running; press again to resume live updates.",
		["zh-cn"] = "让面板画面停住，方便你仔细看。后台仍在继续测量，再按一次恢复实时刷新。"
	},
	keybind_dump_report = {
		en = "Dump full report to log",
		["zh-cn"] = "把完整报告写进日志"
	},
	keybind_dump_report_tooltip = {
		en = "Write a full report of every mod (with a breakdown of where each spends its time) to the DMF log, and echo the top 5 to chat. Works everywhere, including menus.",
		["zh-cn"] = "把所有模组的详细耗时（连每部分在哪花的都能看）输出到DMF日志文件，同时前5名会显示在聊天栏。菜单里也能用。"
	},
	keybind_export_report = {
		en = "Export report (text file)",
		["zh-cn"] = "导出报告（文本文件）"
	},
	keybind_export_report_tooltip = {
		en = "Write a timestamped, readable text report into the mods/ModPerformanceMonitor/reports folder.",
		["zh-cn"] = "生成一份带时间戳、容易读的文本报告，保存到 mods/ModPerformanceMonitor/reports 文件夹里。"
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
		["zh-cn"] = "安全模式已开启：不会测量任何模组"
	},
	stat_shim_inactive = {
		en = "Stack shim inactive: measuring is off so nothing can break",
		["zh-cn"] = "为了绝对安全，监视器已彻底休眠，不会干扰任何其他模组正常运行"
	},
	stat_coverage_full = {
		en = "Hook coverage: full (loaded first)",
		["zh-cn"] = "监测覆盖：全部（最先加载，都能测到）"
	},
	stat_coverage_partial = {
		en = "Hooks not measured for: %s",
		["zh-cn"] = "以下模组启动太早，没装上测速器：%s"
	},
	stat_coverage_earlier = {
		en = "Hook coverage: %d earlier mod%s not measured",
		["zh-cn"] = "监测覆盖：有 %d 个前置模组没被测到"
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
		["zh-cn"] = "总耗时 %.2f 毫秒/帧  Lua内存 %.0f MB  模组数 %d  帧率 %d  FPS（最低1%%帧 %d）"
	},
	stat_detailed_footer = {
		en = "worst frame %.1f ms   mods added ~%.1fs to load   sort: %s",
		["zh-cn"] = "最卡帧 %.1f 毫秒  模组把加载拖慢了约 %.1f 秒  排序依据：%s"
	},
	stat_timer_info = {
		en = "timer %s ~%.4fms   overhead ~%.4fms/call %s   (estimates)",
		["zh-cn"] = "计时器 %s 精度约 %.4f 毫秒  每次测量多耗约 %.4f 毫秒 %s（估算值）"
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
		["zh-cn"] = "最近没有"
	},
	msg_no_stutters = {
		en = "no stutters recorded",
		["zh-cn"] = "没记录到卡顿"
	},
	msg_no_load_cost = {
		en = "no measurable load cost",
		["zh-cn"] = "没有可测的加载开销"
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
		["zh-cn"] = "注意：这些数据只统计Lua主线程的开销，是排名参考，不是精确绝对值。显卡和游戏引擎底层的C++运算在这里看不到，所以某个模组显示很省，实际可能照样拖慢你的帧率。卡顿归因也只是靠算法猜测。请勿拿这份报告去指责模组作者。"
	},
	report_uncertainty = {
		en = "timer resolution is %.3f ms; values below are averages over many frames. The +/- column is a 95%% confidence interval, so a mod whose cost is smaller than its own +/- is not distinguishable from noise. Use the A/B keybind for a single trustworthy number.",
		["zh-cn"] = "计时器精度为 %.3f 毫秒，下方数值是多帧平均值。± 列表示95%%的误差范围——如果某个模组的耗时比它的±误差还小，那就说明这个数字跟随机噪音没啥区别，不太可信。想得到一个靠谱的单个数值，请用 A/B 测试快捷键。"
	},
	report_stats = {
		en = "timer: %s (~%.5f ms) | overhead ~%.5f ms/call | Lua %.0f MB | total mod CPU %.3f ms/frame | 1%% low %d FPS | worst frame %.1f ms",
		["zh-cn"] = "计时器：%s（约 %.5f 毫秒）| 每次测量多耗约 %.5f 毫秒 | Lua内存 %.0f MB | 模组总CPU %.3f 毫秒/帧 | 1%%低帧 %d FPS | 最卡帧 %.1f 毫秒"
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
		["zh-cn"] = "排名  自身(ms)   ±    可信度   p95   峰值  卡顿次数  调用/帧  总耗时(ms)  加载(ms)  模组"
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
		["zh-cn"] = "最低帧 %d FPS"
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
		["zh-cn"] = "可信度"
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
		["zh-cn"] = "这个排名仅供横向对比。要测单个模组的真实开销，请用 A/B 测试快捷键。"
	},

	keybind_ab_test = {
		en = "Measure the heaviest mod (A/B)",
		["zh-cn"] = "测量最耗时的模组（A/B）"
	},
	keybind_ab_test_tooltip = {
		en = "Turns the heaviest mod's work on and off many times over about 11 seconds and measures the real frame-time difference, with a 95%% confidence interval. If the result is indistinguishable from noise it says so instead of inventing a number. Stand still somewhere calm. The mod is briefly disabled during the test.",
		["zh-cn"] = "在大约11秒内反复开关最耗时的那个模组，对比帧数的真实变化，并给出95%%的误差范围。如果结果跟随机波动没区别，它会如实告诉你，而不是瞎编一个数字。测试时请站在一个安静的地方别动。测试期间那个模组会被临时禁用。"
	},
	keybind_calibrate = {
		en = "Check accuracy (calibration)",
		["zh-cn"] = "校准精度（自检）"
	},
	keybind_calibrate_tooltip = {
		en = "Runs a workload of a known size and compares what the profiler reports against the real frame-time cost. Tells you how much to trust the numbers on this machine. Stand still somewhere calm.",
		["zh-cn"] = "跑一段已知大小的计算任务，然后对比监视器测出来的值和真实帧时间差了多少，让你知道这台电脑上的数据有多靠谱。测试时请站着别动。"
	},

	ab_start = {
		en = "[A/B] Testing '%s' for ~%.0fs. It is briefly disabled; stand still.",
		["zh-cn"] = "[A/B] 正在测试 '%s'，约 %.0f 秒。测试期间会短暂禁用该模组，请站立不动。"
	},
	ab_result = {
		en = "[A/B] '%s' costs %.3f +/- %.3f ms/frame (95%% CI, %d blocks)",
		["zh-cn"] = "[A/B] “%s” 开销 %.3f ± %.3f 毫秒/帧（95%%置信度，%d 组数据）"
	},
	ab_no_impact = {
		en = "[A/B] '%s': no measurable impact (%.3f +/- %.3f ms/frame)",
		["zh-cn"] = "[A/B] '%s'：无可测量影响（%.3f +/- %.3f ms/帧）"
	},
	ab_no_mod = {
		en = "[A/B] No mod has measurable cost yet.",
		["zh-cn"] = "[A/B] 目前还没有哪个模组有明显开销。"
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
		["zh-cn"] = "  任务太小测不准；请站着别动再试一次"
	},
	stat_mem_unavailable = {
		en = "Per-mod memory isn't available in this game build.",
		["zh-cn"] = "当前游戏版本没法获取各模组的内存数据。"
	},
	stat_load_unavailable1 = {
		en = "Per-mod load timing isn't tracked.",
		["zh-cn"] = "不再统计各模组的加载耗时。"
	},
	stat_load_unavailable2 = {
		en = "(removed so it can't interfere with reloading mods)",
		["zh-cn"] = "（为了避免干扰模组热重载，已移除这个功能）"
	},
}