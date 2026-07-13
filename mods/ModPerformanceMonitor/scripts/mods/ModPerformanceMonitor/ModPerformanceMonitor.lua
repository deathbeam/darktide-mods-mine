local mod = get_mod("ModPerformanceMonitor")

local unpack = unpack or table.unpack
local collectgarbage = collectgarbage
local math_min, math_max, math_huge, math_floor, math_ceil = math.min, math.max, math.huge, math.floor, math.ceil
local math_sqrt, math_abs = math.sqrt, math.abs
local string_format = string.format
local table_sort = table.sort

local function pack_returns(...)
	return select("#", ...), { ... }
end

local function obj_label(obj)
	if type(obj) == "string" then return obj end
	if type(obj) == "table" then
		return obj.__class_name or obj.name or "table"
	end
	return tostring(obj)
end

local function percentile(arr, count, p)
	if count <= 0 then return 0 end
	local tmp = {}
	for i = 1, count do tmp[i] = arr[i] end
	table_sort(tmp)
	local idx = math_max(1, math_min(count, math_ceil(p * count)))
	return tmp[idx]
end

local timer_now, timer_name, timer_res_ms

local function get_ffi()
	local ok, ffi = pcall(function()
		local Mods_g = rawget(_G, "Mods")
		return rawget(_G, "ffi")
			or (package and package.loaded and package.loaded.ffi)
			or (Mods_g and Mods_g.lua and Mods_g.lua.ffi)
			or (Mods_g and Mods_g.ffi)
			or require("ffi")
	end)
	if ok and type(ffi) == "table" then return ffi end
	return nil
end

local function try_ffi_timer()
	local ffi = get_ffi()
	if not ffi then return nil end

	pcall(ffi.cdef, [[
		int QueryPerformanceCounter(int64_t *c);
		int QueryPerformanceFrequency(int64_t *f);
	]])

	local ok, fn = pcall(function()
		local freq = ffi.new("int64_t[1]")
		if ffi.C.QueryPerformanceFrequency(freq) == 0 then error("no QPF") end
		local ticks_per_ms = tonumber(freq[0]) / 1000.0
		if ticks_per_ms <= 0 then error("bad freq") end
		local counter = ffi.new("int64_t[1]")
		local C = ffi.C
		local f = function()
			C.QueryPerformanceCounter(counter)
			return tonumber(counter[0]) / ticks_per_ms
		end
		if type(f()) ~= "number" then error("bad counter") end
		return f
	end)

	if ok and type(fn) == "function" then return fn end
	return nil
end

local TIME_ALLOW = { "time", "clock", "tick", "counter", "nanos", "micros", "perf" }
local TIME_DENY = { "set", "reset", "start", "stop", "clear", "pause", "enable", "disable",
	"sleep", "wait", "date", "scale", "delta", "budget", "sync", "limit", "frame_times" }

local function is_time_getter(n)
	local l = n:lower()
	for i = 1, #TIME_DENY do if l:find(TIME_DENY[i], 1, true) then return false end end
	for i = 1, #TIME_ALLOW do if l:find(TIME_ALLOW[i], 1, true) then return true end end
	return false
end

local function raw_resolution(fn)
	local prev = fn()
	if type(prev) ~= "number" then return nil end
	local best = math_huge
	for i = 1, 200000 do
		local t = fn()
		if type(t) ~= "number" then return nil end
		local d = t - prev
		if d < 0 then return nil end
		if d > 0 then
			if d < best then best = d end
			if i >= 1500 then break end
		end
		prev = t
	end
	if best == math_huge then return nil end
	return best
end

local function ms_per_unit(fn)
	local osc = os.clock
	local c0, r0 = osc(), fn()
	while (osc() - c0) < 0.015 do end
	local c1, r1 = osc(), fn()
	local ms, raw = (c1 - c0) * 1000.0, r1 - r0
	if ms <= 0 or raw <= 0 then return nil end
	return ms / raw
end

local function probe_timer(fn)
	local ok, raw = pcall(raw_resolution, fn)
	if not ok or not raw then return nil end
	local ok2, scale = pcall(ms_per_unit, fn)
	if not ok2 or not scale then return nil end
	local res_ms = raw * scale
	if res_ms <= 0 or res_ms ~= res_ms then return nil end
	return res_ms, scale
end

do
	local found = {}

	local ffi_fn = try_ffi_timer()
	if ffi_fn then found[#found + 1] = { name = "ffi.QueryPerformanceCounter", fn = ffi_fn, scale = 1 } end

	if rawget(_G, "os") and type(os.clock) == "function" then
		found[#found + 1] = { name = "os.clock", fn = os.clock, scale = 1000.0 }
	end

	local Mods_g = rawget(_G, "Mods")
	local containers = {
		{ "Application", rawget(_G, "Application") },
		{ "Renderer", rawget(_G, "Renderer") },
		{ "Profiler", rawget(_G, "Profiler") },
		{ "Script", rawget(_G, "Script") },
		{ "Engine", rawget(_G, "Engine") },
		{ "Mods.lua", Mods_g and Mods_g.lua },
	}
	for _, c in ipairs(containers) do
		local cname, tbl = c[1], c[2]
		if type(tbl) == "table" then
			pcall(function()
				for k, v in pairs(tbl) do
					if type(k) == "string" and type(v) == "function" and is_time_getter(k) then
						found[#found + 1] = { name = cname .. "." .. k, fn = v }
					end
				end
			end)
		end
	end

	local report = {}
	local best
	for _, cand in ipairs(found) do
		local res_ms, scale
		if cand.scale then
			local ok, raw = pcall(raw_resolution, cand.fn)
			if ok and raw then res_ms, scale = raw * cand.scale, cand.scale end
		else
			res_ms, scale = probe_timer(cand.fn)
		end
		if res_ms then
			report[#report + 1] = string_format("%s=%.5fms", cand.name, res_ms)
			if not best or res_ms < best.res then
				best = { name = cand.name, fn = cand.fn, scale = scale, res = res_ms }
			end
		else
			report[#report + 1] = cand.name .. "=unusable"
		end
	end

	if best then
		local f, s = best.fn, best.scale
		if s == 1 then
			timer_now = f
		else
			timer_now = function() return f() * s end
		end
		timer_name, timer_res_ms = best.name, best.res
	else
		timer_now, timer_name, timer_res_ms = function() return 0.0 end, "none", 0.0
	end

	mod:info("Timer candidates: %s", #report > 0 and table.concat(report, "  ") or "(none found)")
	if Mods_g and type(Mods_g.lua) == "table" then
		local keys = {}
		pcall(function() for k in pairs(Mods_g.lua) do keys[#keys + 1] = tostring(k) end end)
		table.sort(keys)
		mod:info("Mods.lua contains: %s", table.concat(keys, ", "))
	end
end

mod._timer_name = timer_name
mod._timer_res_ms = timer_res_ms
local TIMER_OK = timer_res_ms > 0 and timer_res_ms <= 0.05
mod._timer_ok = TIMER_OK
mod:info("Timer: %s (resolution ~%.5f ms, high-resolution=%s)", timer_name, timer_res_ms, tostring(TIMER_OK))

local SHIM_OVERHEAD_MS = 0
local SUBTRACT_OVERHEAD = true
do
	local function noop() return end
	for _ = 1, 200 do local _n, _r = pack_returns(noop()) end
	local total, samples = 0, 0
	for _ = 1, 6000 do
		local t0 = timer_now()
		local _n, _r = pack_returns(noop())
		local d = timer_now() - t0
		if d > 0 then total = total + d; samples = samples + 1 end
	end
	SHIM_OVERHEAD_MS = samples > 0 and (total / samples) or 0
end
mod._shim_overhead_ms = SHIM_OVERHEAD_MS

local ENABLED   = true
local TRACK_MEM = false
local DISPLAY_ALPHA = 0.05
local HITCH_ABS_MS = 28
local HITCH_MULT = 1.8
local SPIKE_MIN_MS = 3.0
local HIST = 128
local FT_N = 512

local stats = {}
mod._stats = stats

local depth = 0
local child_ms = {}
local child_kb = {}

local SELF_NAME = "ModPerformanceMonitor"
local CALIB_NAME = "__calibration__"

local function is_internal(name)
	return type(name) == "string" and name:sub(1, 2) == "__"
end

local EXCLUDED = {}
do
	local ok, saved = pcall(function() return mod:get("excluded_mods") end)
	if ok and type(saved) == "table" then
		for name, v in pairs(saved) do if v then EXCLUDED[name] = true end end
	end
end
mod._excluded = EXCLUDED

local WRAP_OK = false

local SHIM_SKIP = setmetatable({}, { __mode = "k" })

local ft_vals, ft_n, ft_w = {}, 0, 1
local worst_frame_ms = 0

local function mem_kb()
	local Prof = rawget(_G, "Profiler")
	if Prof and type(Prof.lua_stats) == "function" then
		local ok, m = pcall(Prof.lua_stats)
		if ok and type(m) == "number" then return m end
	end
	local ok2, c = pcall(collectgarbage, "count")
	if ok2 and type(c) == "number" then return c end
	return nil
end

local function get_bucket(name)
	local b = stats[name]
	if not b then
		b = {
			name = name,
			frame_self = 0, frame_incl = 0, frame_calls = 0, frame_mem = 0,
			self_ms = 0, incl_ms = 0, calls = 0, mem_kb = 0,
			peak_ms = 0, total_ms = 0, total_calls = 0,
			spike_count = 0, worst_spike_ms = 0,
			load_ms = 0,
			hist = {}, hist_n = 0, hist_w = 1,
			sources = {},
		}
		stats[name] = b
	end
	return b
end

local SUPPRESSED = {}

local function make_wrapper(bucket, handler, source_label, suppressible)
	local sources = bucket.sources
	local bname = bucket.name
	local w = function(...)
		if suppressible and SUPPRESSED[bname] then
			return
		end
		if not ENABLED then
			return handler(...)
		end
		depth = depth + 1
		local my = depth
		child_ms[my] = 0
		local mem0
		if TRACK_MEM then
			child_kb[my] = 0
			mem0 = mem_kb()
		end

		local t0 = timer_now()
		local n, r = pack_returns(handler(...))
		local incl = timer_now() - t0
		if incl < 0 then incl = 0 end

		local incl_mem = 0
		if TRACK_MEM and mem0 then
			local m1 = mem_kb()
			if m1 then incl_mem = m1 - mem0 end
			if incl_mem < 0 then incl_mem = 0 end
		end

		local self_ms = incl - (child_ms[my] or 0)
		if self_ms < 0 then self_ms = 0 end
		local self_mem = 0
		if TRACK_MEM then
			self_mem = incl_mem - (child_kb[my] or 0)
			if self_mem < 0 then self_mem = 0 end
		end

		depth = depth - 1
		if depth > 0 then
			child_ms[depth] = (child_ms[depth] or 0) + incl
			if TRACK_MEM then child_kb[depth] = (child_kb[depth] or 0) + incl_mem end
		end

		bucket.frame_self  = bucket.frame_self  + self_ms
		bucket.frame_incl  = bucket.frame_incl  + incl
		bucket.frame_calls = bucket.frame_calls + 1
		if TRACK_MEM then bucket.frame_mem = bucket.frame_mem + self_mem end

		local s = sources[source_label]
		if not s then s = { frame_self = 0, self_ms = 0 }; sources[source_label] = s end
		s.frame_self = s.frame_self + self_ms

		return unpack(r, 1, n)
	end
	SHIM_SKIP[w] = true
	return w
end

local hud_map = {}
local hud_wrapped = {}
local hook_patch_ok = false

local function get_persist(name)
	local ok, tbl = pcall(function() return mod:persistent_table(name) end)
	if ok and type(tbl) == "table" then return tbl end
	return {}
end

local shim_active, shim_note = false, "not attempted"

do
	local dbg = rawget(_G, "debug")
	if type(dbg) ~= "table" then
		shim_note = "debug table unavailable"
	else
		local orig = get_persist("mpm_debug_originals")
		if type(orig.getinfo) ~= "function" then orig.getinfo = dbg.getinfo end
		if type(orig.getlocal) ~= "function" then orig.getlocal = dbg.getlocal end
		local real_getinfo, real_getlocal = orig.getinfo, orig.getlocal

		if type(real_getinfo) ~= "function" or type(real_getlocal) ~= "function" then
			shim_note = "debug.getinfo/getlocal missing"
		else
			local shim_getlocal, shim_getinfo

			shim_getlocal = function(a, b, c)
				if type(a) == "thread" then
					local n, v = real_getlocal(a, b, c)
					return n, v
				end
				if type(a) ~= "number" then
					local n, v = real_getlocal(a, b)
					return n, v
				end
				if depth == 0 or a < 1 then
					local n, v = real_getlocal(a + 1, b)
					return n, v
				end
				local lvl, seen = 1, 0
				while true do
					local info = real_getinfo(lvl, "f")
					if not info then break end
					if not SHIM_SKIP[info.func] then
						seen = seen + 1
						if seen == a then
							local n, v = real_getlocal(lvl, b)
							return n, v
						end
					end
					lvl = lvl + 1
				end
				local n, v = real_getlocal(a + 1, b)
				return n, v
			end

			shim_getinfo = function(a, b, c)
				if type(a) == "thread" then
					local res = real_getinfo(a, b, c)
					return res
				end
				if type(a) ~= "number" then
					local res = real_getinfo(a, b)
					return res
				end
				if a == 0 then
					local res = real_getinfo(0, b)
					return res
				end
				if depth == 0 then
					local res = real_getinfo(a + 1, b)
					return res
				end
				local lvl, seen = 1, 0
				while true do
					local info = real_getinfo(lvl, "f")
					if not info then break end
					if not SHIM_SKIP[info.func] then
						seen = seen + 1
						if seen == a then
							local res = real_getinfo(lvl, b)
							return res
						end
					end
					lvl = lvl + 1
				end
				local res = real_getinfo(a + 1, b)
				return res
			end

			SHIM_SKIP[shim_getlocal] = true
			SHIM_SKIP[shim_getinfo] = true

			local ok = pcall(function()
				dbg.getlocal = shim_getlocal
				dbg.getinfo = shim_getinfo
			end)
			if ok and dbg.getlocal == shim_getlocal and dbg.getinfo == shim_getinfo then
				shim_active, shim_note = true, "installed"
			else
				shim_note = "could not replace debug.getlocal/getinfo"
			end
		end
	end
end

local function shim_self_test()
	if not shim_active then return false, shim_note end
	local probe = function()
		local n, v = debug.getlocal(2, 1)
		return n, v
	end
	local bucket = get_bucket("__shim_selftest__")
	local wrapped = make_wrapper(bucket, probe, "selftest")
	local caller = function()
		local marker = "MPM_PROBE"
		local n, v = wrapped()
		return n, v
	end
	local saved_enabled, saved_depth = ENABLED, depth
	ENABLED, depth = true, 0
	local ok, n, v = pcall(caller)
	ENABLED, depth = saved_enabled, saved_depth
	stats["__shim_selftest__"] = nil
	if not ok then return false, "error: " .. tostring(n) end
	if v == "MPM_PROBE" then return true, "wrapper frame hidden from debug.getlocal" end
	return false, string_format("saw %s=%s, expected marker=MPM_PROBE", tostring(n), tostring(v))
end

do
	local safe_mode = false
	pcall(function() safe_mode = mod:get("safe_mode") == true end)

	local ok, why = shim_self_test()
	mod._shim_ok = ok
	mod._shim_note = why
	mod._safe_mode = safe_mode

	WRAP_OK = ok and not safe_mode
	mod._wrap_ok = WRAP_OK

	if WRAP_OK then
		mod:info("Stack-frame shim ACTIVE (%s). Measuring every mod; nothing is skipped.", why)
	elseif safe_mode then
		mod:info("Safe mode is on: not instrumenting any mod. No timings will be collected.")
	else
		mod:info("Stack-frame shim INACTIVE (%s). Not instrumenting any mod, so nothing can break. No timings will be collected.", why)
	end
end

do
	local DMFMod = rawget(_G, "DMFMod")
	if not DMFMod then
		local self_mt = getmetatable(mod)
		if self_mt and type(self_mt.__index) == "table" then DMFMod = self_mt.__index end
	end

	if DMFMod then
		local pt = get_persist("mpm_originals")
		pt.dmf = pt.dmf or {}

		local function patch(method_name)
			if type(pt.dmf[method_name]) ~= "function" then
				local cur = DMFMod[method_name]
				if type(cur) ~= "function" then return end
				pt.dmf[method_name] = cur
			end
			local orig = pt.dmf[method_name]
			DMFMod[method_name] = function(self, obj, method, handler)
				local mod_name = (self.get_name and self:get_name()) or "unknown"
				if WRAP_OK and mod_name ~= SELF_NAME and not EXCLUDED[mod_name] then
					local bucket = get_bucket(mod_name)
					if type(handler) == "function" then
						handler = make_wrapper(bucket, handler, string_format("hook %s.%s", obj_label(obj), tostring(method)))
					elseif handler == nil and type(method) == "function" then
						method = make_wrapper(bucket, method, string_format("hook %s", tostring(obj)))
					end
				end
				return orig(self, obj, method, handler)
			end
		end
		patch("hook")
		patch("hook_safe")
		patch("hook_origin")

		if type(pt.dmf.register_hud_element) ~= "function" then
			local cur = DMFMod.register_hud_element
			if type(cur) == "function" then pt.dmf.register_hud_element = cur end
		end
		local orig_rhe = pt.dmf.register_hud_element
		if type(orig_rhe) == "function" then
			DMFMod.register_hud_element = function(self, settings)
				local nm = self.get_name and self:get_name()
				if nm and nm ~= SELF_NAME and type(settings) == "table" and type(settings.class_name) == "string" then
					hud_map[settings.class_name] = nm
				end
				return orig_rhe(self, settings)
			end
		end

		hook_patch_ok = true
	end
end
mod._hook_patch_ok = hook_patch_ok

local function wrap_hud_elements()
	if not WRAP_OK then return end
	local CLS = rawget(_G, "CLASS")
	if not CLS then return end
	for class_name, mod_name in pairs(hud_map) do
		if not hud_wrapped[class_name] and not EXCLUDED[mod_name] then
			local cls = CLS[class_name]
			if cls then
				local bucket = get_bucket(mod_name)
				if type(cls.update) == "function" then
					cls.update = make_wrapper(bucket, cls.update, "hud " .. class_name .. ".update", true)
				end
				if type(cls.draw) == "function" then
					cls.draw = make_wrapper(bucket, cls.draw, "hud " .. class_name .. ".draw", true)
				end
				hud_wrapped[class_name] = true
			end
		end
	end
end

local EVENT_NAMES = {
	"update", "on_game_state_changed", "on_setting_changed",
	"on_enabled", "on_disabled", "on_user_joined", "on_user_left", "on_unload",
}
local instrumented = {}

local function instrument_events()
	if not WRAP_OK then return end
	local dmf = get_mod("DMF")
	local all_mods = dmf and dmf.mods
	if not all_mods then return end
	for name, other in pairs(all_mods) do
		if name ~= SELF_NAME and name ~= "DMF" and not instrumented[name] and not EXCLUDED[name] then
			local bucket = get_bucket(name)
			for _, ev in ipairs(EVENT_NAMES) do
				local fn = rawget(other, ev)
				if type(fn) == "function" then
					other[ev] = make_wrapper(bucket, fn, "event " .. ev, ev == "update")
				end
			end
			instrumented[name] = true
		end
	end
end

local refresh_interval = 0.33
local refresh_accum = 0
local rank_interval = 1.5
local rank_accum = 0
local frozen = false
local total_self_ms = 0
local frame_ms_ema = 16.7
mod._total_self_ms = 0

local GRAPH_MAX = 120
local graph_interval = 0.25
local graph_accum = 0
local graph_vals, graph_n, graph_w = {}, 0, 1

local mem_mb_ema, gc_ms_ema = 0, 0
local MEM_HIST_MAX = 12
local mem_hist, mem_hist_n, mem_hist_w = {}, 0, 1
local mem_sample_accum = 0

local function fold_frame(frame_ms, baseline)
	local total = 0
	local top_name, top_fs = nil, 0

	for name, b in pairs(stats) do
		local fs = b.frame_self
		if SUBTRACT_OVERHEAD and SHIM_OVERHEAD_MS > 0 then
			fs = fs - SHIM_OVERHEAD_MS * b.frame_calls
			if fs < 0 then fs = 0 end
		end

		b.self_ms = b.self_ms + DISPLAY_ALPHA * (fs - b.self_ms)
		b.incl_ms = b.incl_ms + DISPLAY_ALPHA * (b.frame_incl - b.incl_ms)
		b.calls   = b.calls   + DISPLAY_ALPHA * (b.frame_calls - b.calls)
		if b.calls < 0 then b.calls = 0 end
		if TRACK_MEM then b.mem_kb = b.mem_kb + DISPLAY_ALPHA * (b.frame_mem - b.mem_kb) end

		if fs > b.peak_ms then b.peak_ms = fs end
		b.total_ms = b.total_ms + fs
		b.total_calls = b.total_calls + b.frame_calls

		b.hist[b.hist_w] = fs
		b.hist_w = (b.hist_w % HIST) + 1
		if b.hist_n < HIST then b.hist_n = b.hist_n + 1 end

		if not is_internal(name) then
			if fs > top_fs then top_fs = fs; top_name = name end
			total = total + b.self_ms
		end

		for _, s in pairs(b.sources) do
			s.self_ms = s.self_ms + DISPLAY_ALPHA * (s.frame_self - s.self_ms)
			s.frame_self = 0
		end
		b.frame_self, b.frame_incl, b.frame_calls, b.frame_mem = 0, 0, 0, 0
	end

	total_self_ms = total
	mod._total_self_ms = total

	ft_vals[ft_w] = frame_ms
	ft_w = (ft_w % FT_N) + 1
	if ft_n < FT_N then ft_n = ft_n + 1 end
	if frame_ms > worst_frame_ms then worst_frame_ms = frame_ms end

	local threshold = math_max(HITCH_ABS_MS, (baseline or frame_ms_ema) * HITCH_MULT)
	if frame_ms > threshold and top_name and top_fs >= SPIKE_MIN_MS then
		local b = stats[top_name]
		b.spike_count = b.spike_count + 1
		if top_fs > b.worst_spike_ms then b.worst_spike_ms = top_fs end
	end
end

local COL = {
	title  = { 255, 120, 205, 255 },
	accent = { 255, 120, 205, 255 },
	sub    = { 255, 175, 182, 198 },
	head   = { 255, 140, 148, 165 },
	text   = { 255, 226, 228, 234 },
	dim    = { 255, 150, 156, 172 },
	heavy  = { 255, 244,  96,  96 },
	medium = { 255, 245, 190,  92 },
	light  = { 255, 138, 210, 150 },
	good   = { 255, 138, 210, 150 },
	warn   = { 255, 250, 208,  80 },
}

local HEAVY_MS  = 0.50
local MEDIUM_MS = 0.10
local NEGLIGIBLE_MS = 0.03
local SEV_WORD = { heavy = "HEAVY", medium = "medium", light = "light" }

local function severity(ms)
	if ms >= HEAVY_MS then return "heavy", COL.heavy
	elseif ms >= MEDIUM_MS then return "medium", COL.medium
	else return "light", COL.light end
end

local SORT_LABELS = {
	self   = mod:localize("sort_self"),
	incl   = mod:localize("sort_incl"),
	calls  = mod:localize("sort_calls"),
	mem    = mod:localize("sort_mem"),
	total  = mod:localize("sort_total"),
	peak   = mod:localize("sort_peak"),
	spikes = mod:localize("sort_spikes"),
	load   = mod:localize("sort_load"),
}
local current_sort = "self"
local current_mode = "simplified"
local current_tab = "all"

local TABS = {
	{ id = "all",    label = mod:localize("tab_all") },
	{ id = "cpu",    label = mod:localize("tab_cpu") },
	{ id = "mem",    label = mod:localize("tab_mem") },
	{ id = "spikes", label = mod:localize("tab_spikes") },
	{ id = "load",   label = mod:localize("tab_load") },
}
mod._tabs = TABS
mod._active_tab = current_tab
mod._allow_tab_click = true

local TAB_SORT = { cpu = "self", mem = "mem", spikes = "spikes", load = "load" }

local function active_sort()
	return TAB_SORT[current_tab] or current_sort
end

local function tab_shows_graph()
	return current_tab == "all" or current_tab == "cpu"
end

function mod.get_tabs()
	return TABS, current_tab
end

local function value_for(b, mode)
	if mode == "incl" then return b.incl_ms
	elseif mode == "calls" then return b.calls
	elseif mode == "mem" then return b.mem_kb
	elseif mode == "total" then return b.total_ms
	elseif mode == "peak" then return b.peak_ms
	elseif mode == "spikes" then return b.spike_count
	elseif mode == "load" then return b.load_ms
	else return b.self_ms end
end

local cached_order = {}

local function refresh_order()
	local arr, n = {}, 0
	local sort_key = active_sort()
	for name, b in pairs(stats) do
		if not is_internal(name) then
			n = n + 1
			arr[n] = { name = name, key = value_for(b, sort_key) }
		end
	end
	table_sort(arr, function(x, y) return x.key > y.key end)
	local order = {}
	for i = 1, #arr do order[i] = arr[i].name end
	cached_order = order
end

local function ordered_entries()
	local out, seen, n = {}, {}, 0
	for _, name in ipairs(cached_order) do
		local b = stats[name]
		if b then n = n + 1; out[n] = { name = name, b = b }; seen[name] = true end
	end
	for name, b in pairs(stats) do
		if not seen[name] and not is_internal(name) then n = n + 1; out[n] = { name = name, b = b } end
	end
	return out
end

local function trunc(s, w)
	if #s > w then return s:sub(1, w - 1) .. "." end
	return s
end

local function lua_mem_mb()
	return (mem_kb() or 0) / 1024
end

local function lua_gc_stats()
	local ok, m, g, _pct, _est, actual = pcall(function()
		local Prof = rawget(_G, "Profiler")
		if Prof and Prof.lua_stats then return Prof.lua_stats() end
		return mem_kb(), 0, 0, 0, 0
	end)
	if not ok then return (mem_kb() or 0) / 1024, 0, 0 end
	return (m or 0) / 1024, (g or 0), (actual or 0)
end

local function mem_trend()
	local mb = mem_mb_ema
	if mem_hist_n < 2 then return mb, "steady", false end
	local oldest = (mem_hist_n < MEM_HIST_MAX) and mem_hist[1] or mem_hist[mem_hist_w]
	local delta = mb - (oldest or mb)
	if delta > 80 then return mb, "climbing", true
	elseif delta > 20 then return mb, "rising", false
	elseif delta < -20 then return mb, "falling", false
	else return mb, "steady", false end
end

local function median(t)
	local n = #t
	if n == 0 then return 0 end
	local c = {}
	for i = 1, n do c[i] = t[i] end
	table_sort(c)
	if n % 2 == 1 then return c[(n + 1) / 2] end
	return (c[n / 2] + c[n / 2 + 1]) * 0.5
end

local T95 = { 12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228,
	2.201, 2.179, 2.160, 2.145, 2.131, 2.120, 2.110, 2.101, 2.093, 2.086,
	2.080, 2.074, 2.069, 2.064, 2.060, 2.056, 2.052, 2.048, 2.045, 2.042 }

local function t95(df)
	if df < 1 then return 0 end
	if df <= 30 then return T95[df] end
	return 1.96
end

local function mean_ci(t)
	local n = #t
	if n == 0 then return 0, 0, 0 end
	local sum = 0
	for i = 1, n do sum = sum + t[i] end
	local m = sum / n
	if n < 2 then return m, 0, n end
	local ss = 0
	for i = 1, n do local d = t[i] - m; ss = ss + d * d end
	local sd = math_sqrt(ss / (n - 1))
	return m, t95(n - 1) * sd / math_sqrt(n), n
end

local function p95(b)
	return percentile(b.hist, b.hist_n, 0.95)
end

local function self_ci(b)
	local n = b.hist_n
	if n < 2 then return b.self_ms, 0, n end
	local h, sum = b.hist, 0
	for i = 1, n do sum = sum + h[i] end
	local m = sum / n
	local ss = 0
	for i = 1, n do local d = h[i] - m; ss = ss + d * d end
	local sd = math_sqrt(ss / (n - 1))
	return m, t95(n - 1) * sd / math_sqrt(n), n
end

local function confidence_word(b)
	local m, ci = self_ci(b)
	if m <= 0 then return mod:localize("conf_dash") end
	local rel = ci / m
	if not TIMER_OK then
		if rel < 0.25 then return mod:localize("conf_med") end
		return mod:localize("conf_low")
	end
	if rel < 0.15 then return mod:localize("conf_high") end
	if rel < 0.40 then return mod:localize("conf_med") end
	return mod:localize("conf_low")
end

local function one_percent_low_fps()
	if ft_n < 20 then return 0 end
	local slow = percentile(ft_vals, ft_n, 0.99)
	if slow <= 0.1 then return 0 end
	return math_floor(1000 / slow + 0.5)
end

local function top_self_sum(k)
	local vals, n = {}, 0
	for _, b in pairs(stats) do n = n + 1; vals[n] = b.self_ms end
	table_sort(vals, function(a, c) return a > c end)
	local sum = 0
	for i = 1, math_min(k, n) do sum = sum + vals[i] end
	return sum
end

local function slowest_loads(k)
	local arr, n = {}, 0
	for name, b in pairs(stats) do
		if b.load_ms and b.load_ms > 1 then n = n + 1; arr[n] = { name = name, ms = b.load_ms } end
	end
	table_sort(arr, function(x, y) return x.ms > y.ms end)
	local out, total = {}, 0
	for _, e in ipairs(arr) do total = total + e.ms end
	for i = 1, math_min(k, #arr) do out[i] = string_format("%s %.2fs", arr[i].name, arr[i].ms / 1000) end
	return out, total
end

mod._view = { lines = {} }
mod._overlay_on = false

local function frame_fps()
	local ms = frame_ms_ema > 0.001 and frame_ms_ema or 16.7
	return math_floor(1000 / ms + 0.5), ms
end

local function add_line(lines, text, color, big, rtext)
	local cells
	if rtext then
		cells = { { t = text, a = "left", w = 2 }, { t = rtext, a = "right", w = 1 } }
	else
		cells = { { t = text, a = "left", w = 1 } }
	end
	lines[#lines + 1] = { cells = cells, color = color, big = big or false }
end

local function add_cols(lines, color, name, cols)
	local cells = { { t = name, a = "left", w = 2.5 } }
	for i = 1, #cols do
		cells[#cells + 1] = { t = cols[i], a = "right", w = 1 }
	end
	lines[#lines + 1] = { cells = cells, color = color, big = false }
end

local function add_graph(lines)
	lines[#lines + 1] = { graph = true }
end

local function spike_summary()
	local arr, n = {}, 0
	for name, b in pairs(stats) do
		if b.spike_count > 0 then n = n + 1; arr[n] = { name = name, c = b.spike_count } end
	end
	if n == 0 then return nil end
	table_sort(arr, function(x, y) return x.c > y.c end)
	local parts = {}
	for i = 1, math_min(3, #arr) do parts[i] = string_format("%s (%d)", arr[i].name, arr[i].c) end
	return table.concat(parts, ", ")
end

local function recommendation_line()
	local save = top_self_sum(3)
	if save < 0.3 then return nil end
	return mod:localize("stat_rec_heaviest", save)
end

local function build_tab_all(lines)
	local arr = ordered_entries()
	local fps, ms = frame_fps()
	local frame_pct = ms > 0 and (total_self_ms / ms * 100) or 0
	local max_rows = mod:get("max_rows") or 12

	local title = mod:localize("title_all")
	if frozen then title = title .. "   " .. mod:localize("state_frozen") end
	if not ENABLED then title = title .. "   " .. mod:localize("state_paused") end
	add_line(lines, title, COL.title, true)

	add_line(lines, mod:localize("stat_cpu_used"), COL.sub,
		false, string_format("%.1f ms/frame", total_self_ms))
	add_line(lines, mod:localize("stat_frame_pct", frame_pct, fps), COL.dim,
		false, mod:localize("stat_fps_avg", fps))
	add_line(lines, mod:localize("stat_smoothness"), COL.dim,
		false, mod:localize("stat_fps_low", one_percent_low_fps()))

	local mb, mtrend, mwarn = mem_trend()
	add_line(lines, mod:localize("stat_memory"), mwarn and COL.warn or COL.dim,
		false, string_format("%.0f MB, %s", mb, mtrend))
	add_line(lines, mod:localize("stat_gc"), gc_ms_ema > 2 and COL.warn or COL.dim,
		false, string_format("%.1f ms", gc_ms_ema))

	local _, load_total = slowest_loads(1)
	if load_total > 50 then
		add_line(lines, mod:localize("stat_load_slow"), COL.dim,
			false, string_format("%.1f s", load_total / 1000))
	end

	if spike_summary() then
		add_line(lines, mod:localize("stat_stutters_detected"), COL.warn, false, mod:localize("stat_see_stutters_tab"))
	else
		add_line(lines, mod:localize("stat_stutters"), COL.dim, false, mod:localize("msg_none_recently"))
	end

	local rec = recommendation_line()
	add_line(lines, rec or mod:localize("stat_impact_low"), rec and COL.sub or COL.good)

	if not TIMER_OK then
		add_line(lines, mod:localize("stat_coarse_timer"), COL.warn)
	end
	if mod._safe_mode then
		add_line(lines, mod:localize("stat_safe_mode"), COL.warn)
	elseif not mod._shim_ok then
		add_line(lines, mod:localize("stat_shim_inactive"), COL.warn)
	end

	add_graph(lines)

	add_line(lines, mod:localize("col_mod"), COL.head, false, mod:localize("col_time") .. "      " .. mod:localize("col_share"))

	local shown, negligible = 0, 0
	for _, e in ipairs(arr) do
		local b = e.b
		if b.self_ms < NEGLIGIBLE_MS then
			negligible = negligible + 1
		elseif shown < max_rows then
			shown = shown + 1
			local _, col = severity(b.self_ms)
			local share = total_self_ms > 0 and (b.self_ms / total_self_ms * 100) or 0
			add_line(lines, trunc(e.name, 30), col,
				false, string_format("%.2f ms    %2.0f%%", b.self_ms, share))
		end
	end
	if shown == 0 then add_line(lines, mod:localize("msg_no_cpu_measurable"), COL.good) end
	if negligible > 0 then
		add_line(lines, mod:localize("msg_negligible_more", negligible), COL.dim)
	end
	add_line(lines, mod:localize("stat_ranks_hint"), COL.dim)
end

local function build_tab_generic(lines)
	local tab = current_tab
	local max_rows = mod:get("max_rows") or 12
	local fps, ms = frame_fps()
	local names = { cpu = "CPU", mem = "MEMORY", spikes = "STUTTERS", load = "LOADING" }

	local title = mod:localize("title_tab", names[tab] or "")
	if frozen then title = title .. "   " .. mod:localize("state_frozen") end
	if not ENABLED then title = title .. "   " .. mod:localize("state_paused") end
	add_line(lines, title, COL.title, true)

	if tab == "cpu" then
		add_line(lines, mod:localize("stat_cpu_used"), COL.sub, false, string_format("%.1f ms/frame", total_self_ms))
		add_line(lines, mod:localize("stat_frame_pct_simple", ms > 0 and total_self_ms / ms * 100 or 0), COL.dim,
			false, mod:localize("stat_fps_avg", fps))
		add_graph(lines)
		add_line(lines, mod:localize("col_mod"), COL.head, false, mod:localize("col_time") .. "      " .. mod:localize("col_share"))
		local arr = ordered_entries()
		local shown, neg = 0, 0
		for _, e in ipairs(arr) do
			local b = e.b
			if b.self_ms < NEGLIGIBLE_MS then neg = neg + 1
			elseif shown < max_rows then
				shown = shown + 1
				local _, col = severity(b.self_ms)
				local share = total_self_ms > 0 and (b.self_ms / total_self_ms * 100) or 0
				add_line(lines, trunc(e.name, 30), col, false, string_format("%.2f ms    %2.0f%%", b.self_ms, share))
			end
		end
		if shown == 0 then add_line(lines, mod:localize("msg_no_cpu_use"), COL.good) end
		if neg > 0 then add_line(lines, mod:localize("msg_negligible_more", neg), COL.dim) end

	elseif tab == "mem" then
		local mb, mtrend, mwarn = mem_trend()
		add_line(lines, mod:localize("stat_memory"), mwarn and COL.warn or COL.sub, false, string_format("%.0f MB, %s", mb, mtrend))
		add_line(lines, mod:localize("stat_gc"), gc_ms_ema > 2 and COL.warn or COL.dim, false, string_format("%.1f ms/frame", gc_ms_ema))
		if TRACK_MEM then
			add_line(lines, mod:localize("col_mod"), COL.head, false, mod:localize("col_kb_frame"))
			local arr = ordered_entries()
			local shown = 0
			for _, e in ipairs(arr) do
				if e.b.mem_kb >= 1 and shown < max_rows then
					shown = shown + 1
					add_line(lines, trunc(e.name, 30), COL.text, false, string_format("%.0f KB", e.b.mem_kb))
				end
			end
			if shown == 0 then add_line(lines, mod:localize("msg_no_allocation"), COL.good) end
		elseif mod._mem_available == false then
			add_line(lines, "", COL.dim)
			add_line(lines, mod:localize("stat_mem_unavailable"), COL.dim)
		else
			add_line(lines, "", COL.dim)
			add_line(lines, mod:localize("stat_track_memory_hint1"), COL.dim)
			add_line(lines, mod:localize("stat_track_memory_hint2"), COL.dim)
		end

	elseif tab == "spikes" then
		add_line(lines, mod:localize("stat_smoothness"), COL.sub, false, mod:localize("stat_fps_low", one_percent_low_fps()))
		add_line(lines, mod:localize("stat_worst_frame"), COL.dim, false, string_format("%.1f ms", worst_frame_ms))
		local spikes = spike_summary()
		add_line(lines, mod:localize("stat_suspects"), spikes and COL.warn or COL.dim, false, spikes or mod:localize("msg_none_recently"))
		add_line(lines, mod:localize("col_mod"), COL.head, false, mod:localize("col_stutters"))
		local arr = ordered_entries()
		local shown = 0
		for _, e in ipairs(arr) do
			if e.b.spike_count > 0 and shown < max_rows then
				shown = shown + 1
				add_line(lines, trunc(e.name, 26), COL.warn, false,
					string_format("%d  (peak %.0fms)", e.b.spike_count, e.b.worst_spike_ms))
			end
		end
		if shown == 0 then add_line(lines, mod:localize("msg_no_stutters"), COL.good) end

	elseif tab == "load" then
		add_line(lines, "", COL.dim)
		add_line(lines, mod:localize("stat_load_unavailable1"), COL.sub)
		add_line(lines, mod:localize("stat_load_unavailable2"), COL.dim)
	end
end

local function build_detailed(lines)
	local arr = ordered_entries()
	local fps = frame_fps()
	local max_rows = mod:get("max_rows") or 12

	local _, load_total = slowest_loads(1)

	local title = mod:localize("title_detailed")
	if frozen then title = title .. "   " .. mod:localize("state_frozen") end
	if not ENABLED then title = title .. "   " .. mod:localize("state_paused") end
	add_line(lines, title, COL.title, true)

	add_line(lines, mod:localize("stat_detailed_summary",
		total_self_ms, lua_mem_mb(), #arr, fps, one_percent_low_fps()), COL.sub)
	add_line(lines, mod:localize("stat_detailed_footer",
		worst_frame_ms, load_total / 1000, SORT_LABELS[active_sort()] or active_sort()), COL.dim)
	add_line(lines, mod:localize("stat_timer_info",
		timer_name, timer_res_ms, SHIM_OVERHEAD_MS, SUBTRACT_OVERHEAD and mod:localize("removed") or mod:localize("shown")),
		TIMER_OK and COL.dim or COL.warn)

	if tab_shows_graph() then add_graph(lines) end
	add_cols(lines, COL.head, mod:localize("col_mod"),
		{ mod:localize("col_self"), mod:localize("col_ci"), mod:localize("col_conf"), mod:localize("col_calls"), mod:localize("col_share_detail") })

	local shown = 0
	for _, e in ipairs(arr) do
		if shown >= max_rows then break end
		shown = shown + 1
		local b = e.b
		local _, col = severity(b.self_ms)
		local share = total_self_ms > 0 and (b.self_ms / total_self_ms * 100) or 0
		local mean, ci = self_ci(b)
		add_cols(lines, col, trunc(e.name, 22), {
			string_format("%.3f", mean),
			string_format("%.3f", ci),
			confidence_word(b),
			string_format("%.0f", b.calls),
			string_format("%.0f%%", share),
		})
	end
	if #arr > shown then
		add_line(lines, mod:localize("msg_rows_more", #arr - shown), COL.dim)
	end
end

local function rebuild_view()
	local lines = {}
	if mod._overlay_on then
		if current_mode == "detailed" then
			build_detailed(lines)
		elseif current_tab == "all" then
			build_tab_all(lines)
		else
			build_tab_generic(lines)
		end
	end
	mod._view = { lines = lines }
end

function mod.get_view() return mod._view end
function mod.get_overlay_font_size() return mod:get("overlay_font_size") or 18 end
function mod.get_overlay_offset()
	return mod:get("overlay_x") or 40, mod:get("overlay_y") or 90
end
function mod.get_overlay_width() return mod:get("panel_width") or 560 end

function mod.set_active_tab(id)
	local valid = false
	for _, t in ipairs(TABS) do if t.id == id then valid = true; break end end
	if not valid then return end
	current_tab = id
	mod._active_tab = id
	pcall(function() mod:set("active_tab", id, false) end)
	refresh_order()
	rebuild_view()
end

function mod.cycle_tab(is_pressed)
	if is_pressed == false then return end
	local idx = 1
	for i, t in ipairs(TABS) do if t.id == current_tab then idx = i; break end end
	mod.set_active_tab(TABS[(idx % #TABS) + 1].id)
end

local function graph_series()
	local out, mx, cnt = {}, 0.0001, 0
	if graph_n < GRAPH_MAX then
		for i = 1, graph_n do
			out[i] = graph_vals[i]
			if graph_vals[i] > mx then mx = graph_vals[i] end
		end
		cnt = graph_n
	else
		local idx = 0
		for i = graph_w, GRAPH_MAX do idx = idx + 1; out[idx] = graph_vals[i]; if graph_vals[i] > mx then mx = graph_vals[i] end end
		for i = 1, graph_w - 1 do idx = idx + 1; out[idx] = graph_vals[i]; if graph_vals[i] > mx then mx = graph_vals[i] end end
		cnt = GRAPH_MAX
	end
	return out, cnt, mx
end

function mod.get_graph()
	if mod:get("show_graph") == false or not mod._overlay_on then return nil end
	local vals, cnt, mx = graph_series()
	if cnt < 2 then return nil end
	local hi = 3.0
	local mid = 1.0
	local ceiling = math_max(mx * 1.1, hi)
	return {
		vals = vals,
		n = cnt,
		max = mx,
		hi = hi,
		mid = mid,
		ceiling = ceiling,
		title = mod:localize("graph_title",
			math_floor(cnt * graph_interval + 0.5), vals[cnt] or 0, mx, mid),
	}
end

local function build_full_report()
	refresh_order()
	local arr = ordered_entries()
	local lines = {}
	lines[#lines + 1] = mod:localize("report_header")
	lines[#lines + 1] = mod:localize("report_note")
	lines[#lines + 1] = mod:localize("report_stats",
		timer_name, timer_res_ms, SHIM_OVERHEAD_MS, lua_mem_mb(), total_self_ms, one_percent_low_fps(), worst_frame_ms)
	lines[#lines + 1] = mod:localize("report_sorted",
		SORT_LABELS[current_sort], #arr, TRACK_MEM and mod:localize("on") or mod:localize("off"))
	lines[#lines + 1] = mod:localize("report_shim",
		mod._shim_ok and mod:localize("active") or mod:localize("inactive"),
		tostring(mod._shim_note),
		mod._safe_mode and mod:localize("on") or mod:localize("off"),
		mod._wrap_ok and mod:localize("yes") or mod:localize("no"))
	lines[#lines + 1] = mod:localize("report_uncertainty", timer_res_ms)
	lines[#lines + 1] = mod:localize("report_columns")
	for i, e in ipairs(arr) do
		local b = e.b
		local mean, ci = self_ci(b)
		lines[#lines + 1] = string_format("%3d  %8.4f %6.4f %6s %6.3f %6.3f %6d %8.0f %10.1f %8.0f   %s",
			i, mean, ci, confidence_word(b), p95(b), b.peak_ms, b.spike_count, b.calls, b.total_ms, b.load_ms, e.name)
		if i <= 8 and b.self_ms > 0.001 then
			local srcs = {}
			for label, s in pairs(b.sources) do srcs[#srcs + 1] = { label = label, self_ms = s.self_ms } end
			table_sort(srcs, function(x, y) return x.self_ms > y.self_ms end)
			for j = 1, math_min(4, #srcs) do
				if srcs[j].self_ms > 0.0005 then
					lines[#lines + 1] = string_format("        - %8.4f ms  %s", srcs[j].self_ms, srcs[j].label)
				end
			end
		end
	end
	return lines, arr
end

local function safe_echo(fmt, ...)
	local text = string_format(fmt, ...)
	if not pcall(function() return mod:echo(text) end) then mod:info(text) end
end

local function echo_loc(key, ...)
	safe_echo("%s", mod:localize(key, ...))
end

local AB_WINDOW = 0.4
local AB_BLOCKS = 6
local AB_WARM = 5
local AB_PATTERN = { true, false, false, true }
local AB_SECONDS = AB_BLOCKS * 4 * (AB_WINDOW + 0.06)

local calib_iters = 0
local calib_wrapped = nil

local function calib_work(n)
	local x = 0.0
	for i = 1, n do x = x + i * 0.5 end
	return x
end

local function tune_calib_iters(target_ms)
	local osc = os.clock
	local n, ms = 20000, 0
	for _ = 1, 14 do
		local c0 = osc()
		calib_work(n)
		ms = (osc() - c0) * 1000.0
		if ms >= 5 then break end
		n = n * 2
		if n > 40000000 then break end
	end
	if ms <= 0 then return 200000 end
	local want = math_floor(target_ms / (ms / n))
	if want < 1 then want = 1 end
	return want
end

local ab = { active = false }

local function ab_reset()
	ab.active = false
	ab.mode = nil
	ab.target = nil
	ab.step = 1
	ab.block = 0
	ab.t = 0
	ab.warm = AB_WARM
	ab.calib_n = 0
	ab.samples = {}
	ab.on_vals, ab.off_vals = {}, {}
	ab.on_prof, ab.off_prof = {}, {}
	ab.diffs, ab.pdiffs = {}, {}
	ab.win_frames = 0
	ab.win_total0 = 0
end
ab_reset()

local function mod_set_hooks(name, enabled)
	pcall(function()
		local m = get_mod(name)
		if m then
			if enabled and m.enable_all_hooks then m:enable_all_hooks()
			elseif not enabled and m.disable_all_hooks then m:disable_all_hooks() end
		end
	end)
end

local function ab_apply(on)
	if ab.mode == "calib" then
		calib_iters = on and ab.calib_n or 0
	elseif ab.target then
		mod_set_hooks(ab.target, on)
		SUPPRESSED[ab.target] = (not on) or nil
	end
end

local function ab_restore()
	if ab.mode == "calib" then
		calib_iters = 0
	elseif ab.target then
		mod_set_hooks(ab.target, true)
		SUPPRESSED[ab.target] = nil
	end
end

local function ab_finish()
	local n = #ab.diffs
	if n < 2 then
		echo_loc("ab_failed")
		ab_restore()
		ab_reset()
		return
	end

	local d, ci = mean_ci(ab.diffs)

	if ab.mode == "calib" then
		local p = mean_ci(ab.pdiffs)
		echo_loc("calib_header", n)
		echo_loc("calib_profiler", p)
		echo_loc("calib_true", d, ci)
		if d > 0.02 then
			echo_loc("calib_ratio", p / d * 100.0)
		else
			echo_loc("calib_toosmall")
		end
		mod:info("Calibration: profiler=%.4f true=%.4f +/- %.4f (n=%d)", p, d, ci, n)
	else
		local t = tostring(ab.target)
		if math_abs(d) <= ci then
			echo_loc("ab_no_impact", t, d, ci)
		else
			echo_loc("ab_result", t, d, ci, n)
		end
		mod:info("A/B %s: delta=%.4f ci=%.4f n=%d", t, d, ci, n)
	end

	ab_restore()
	ab_reset()
end

local function ab_update(dt, frame_ms)
	if not ab.active then return end

	if ab.warm > 0 then
		ab.warm = ab.warm - 1
		if ab.warm == 0 then
			local b = stats[CALIB_NAME]
			ab.win_total0 = (b and b.total_ms) or 0
			ab.t = 0
			ab.win_frames = 0
			ab.samples = {}
		end
		return
	end

	ab.t = ab.t + dt
	ab.win_frames = ab.win_frames + 1
	ab.samples[#ab.samples + 1] = frame_ms
	if ab.t < AB_WINDOW then return end

	local med = median(ab.samples)
	local prof = 0
	if ab.mode == "calib" then
		local b = stats[CALIB_NAME]
		local total = (b and b.total_ms) or 0
		prof = (total - ab.win_total0) / math_max(1, ab.win_frames)
	end

	if AB_PATTERN[ab.step] then
		ab.on_vals[#ab.on_vals + 1] = med
		ab.on_prof[#ab.on_prof + 1] = prof
	else
		ab.off_vals[#ab.off_vals + 1] = med
		ab.off_prof[#ab.off_prof + 1] = prof
	end

	if ab.step == 4 then
		ab.diffs[#ab.diffs + 1] =
			(ab.on_vals[1] + ab.on_vals[2]) * 0.5 - (ab.off_vals[1] + ab.off_vals[2]) * 0.5
		if ab.mode == "calib" then
			ab.pdiffs[#ab.pdiffs + 1] =
				(ab.on_prof[1] + ab.on_prof[2]) * 0.5 - (ab.off_prof[1] + ab.off_prof[2]) * 0.5
		end
		ab.on_vals, ab.off_vals = {}, {}
		ab.on_prof, ab.off_prof = {}, {}
		ab.block = ab.block + 1
		ab.step = 1
		if ab.block >= AB_BLOCKS then
			ab_finish()
			return
		end
	else
		ab.step = ab.step + 1
	end

	ab_apply(AB_PATTERN[ab.step])
	ab.warm = AB_WARM
	ab.samples = {}
	ab.t = 0
	ab.win_frames = 0
end

local function ab_can_start()
	if ab.active then
		echo_loc("ab_running")
		return false
	end
	if not WRAP_OK then
		echo_loc("ab_nothing")
		return false
	end
	if not ENABLED then
		echo_loc("ab_need_enabled")
		return false
	end
	return true
end

function mod.calibrate(is_pressed)
	if is_pressed == false then return end
	if ab.active then
		ab_restore()
		ab_reset()
		echo_loc("ab_cancelled")
		return
	end
	if not ab_can_start() then return end

	if not calib_wrapped then
		calib_wrapped = make_wrapper(get_bucket(CALIB_NAME), calib_work, "calibration load")
	end

	local n = tune_calib_iters(0.4)
	ab_reset()
	ab.mode = "calib"
	ab.calib_n = n
	calib_iters = n
	ab.active = true
	echo_loc("calib_start", AB_SECONDS)
end

function mod.ab_test(is_pressed)
	if is_pressed == false then return end
	if ab.active then
		ab_restore()
		ab_reset()
		echo_loc("ab_cancelled")
		return
	end
	if not ab_can_start() then return end

	local top, topv = nil, -1
	for name, b in pairs(stats) do
		if not is_internal(name) and b.self_ms > topv then topv = b.self_ms; top = name end
	end
	if not top then
		echo_loc("ab_no_mod")
		return
	end

	ab_reset()
	ab.mode = "mod"
	ab.target = top
	ab.active = true
	echo_loc("ab_start", top, AB_SECONDS)
end

function mod.toggle_overlay(is_pressed)
	if is_pressed == false then return end
	mod._overlay_on = not mod._overlay_on
	rebuild_view()
end

function mod.toggle_mode(is_pressed)
	if is_pressed == false then return end
	current_mode = (current_mode == "simplified") and "detailed" or "simplified"
	pcall(function() mod:set("display_mode", current_mode, false) end)
	rebuild_view()
end

function mod.toggle_freeze(is_pressed)
	if is_pressed == false then return end
	frozen = not frozen
	if not frozen then refresh_order() end
	rebuild_view()
end

function mod.dump_report(is_pressed)
	if is_pressed == false then return end
	local lines, arr = build_full_report()
	for _, line in ipairs(lines) do mod:info("%s", line) end
	safe_echo("[PerfMonitor] " .. mod:localize("feedback_dump_log", #arr))
end

local function get_io_lib()
	local Mods_g = rawget(_G, "Mods")
	local io_lib = Mods_g and Mods_g.lua and Mods_g.lua.io
	return io_lib or rawget(_G, "io")
end

local function write_file(io_lib, path, content)
	return pcall(function()
		local f = io_lib.open(path, "w")
		if not f then error("could not open " .. path) end
		f:write(content)
		f:close()
	end)
end

local function ensure_reports_dir()
	local Mods_g = rawget(_G, "Mods")
	local os_lib = (Mods_g and Mods_g.lua and Mods_g.lua.os) or rawget(_G, "os")
	if os_lib and os_lib.execute then
		pcall(function() os_lib.execute('mkdir "..\\mods\\ModPerformanceMonitor\\reports" 2>nul') end)
	end
end

function mod.export_report(is_pressed)
	if is_pressed == false then return end
	local io_lib = get_io_lib()
	if not (io_lib and io_lib.open) then
		safe_echo("[PerfMonitor] " .. mod:localize("feedback_no_io"))
		return
	end

	local stamp = "latest"
	pcall(function() stamp = os.date("%Y%m%d_%H%M%S") end)
	local dir = "./../mods/ModPerformanceMonitor/reports"
	local txt_path = dir .. "/perf_" .. stamp .. ".txt"

	local txt = table.concat((build_full_report()), "\n")

	local ok_txt = write_file(io_lib, txt_path, txt)
	if not ok_txt then
		ensure_reports_dir()
		ok_txt = write_file(io_lib, txt_path, txt)
	end

	if ok_txt then
		safe_echo("[PerfMonitor] " .. mod:localize("feedback_export_saved", stamp))
		mod:info("Wrote report: %s", txt_path)
	else
		safe_echo("[PerfMonitor] " .. mod:localize("feedback_export_fail"))
	end
end

function mod.reset_stats(is_pressed)
	if is_pressed == false then return end
	for _, b in pairs(stats) do
		b.self_ms, b.incl_ms, b.calls, b.mem_kb = 0, 0, 0, 0
		b.peak_ms, b.total_ms, b.total_calls = 0, 0, 0
		b.spike_count, b.worst_spike_ms = 0, 0
		b.hist, b.hist_n, b.hist_w = {}, 0, 1
		b.frame_self, b.frame_incl, b.frame_calls, b.frame_mem = 0, 0, 0, 0
		b.sources = {}
	end
	ft_vals, ft_n, ft_w = {}, 0, 1
	worst_frame_ms = 0
	total_self_ms = 0
	refresh_order()
	rebuild_view()
	safe_echo("[PerfMonitor] " .. mod:localize("feedback_reset"))
end

local CE_DEF = {
	class_name = "ConstantElementModPerf",
	filename = "ModPerformanceMonitor/scripts/mods/ModPerformanceMonitor/ConstantElementModPerf",
	visibility_groups = { "default" },
}
pcall(function() mod:add_require_path(CE_DEF.filename) end)

local function ensure_constant_element()
	local mgr = Managers and Managers.ui and Managers.ui._ui_constant_elements
	if mgr and mgr._elements and not mgr._elements[CE_DEF.class_name] then
		pcall(function() mgr:_setup_element(CE_DEF) end)
	end
end

local SMOOTH_MAP = { responsive = 0.20, balanced = 0.06, smooth = 0.02 }

local function apply_settings()
	local on = mod:is_enabled()
	ENABLED   = on and (mod:get("enabled_profiling") ~= false)
	local mem_ok = type(mem_kb()) == "number"
	mod._mem_available = mem_ok
	TRACK_MEM = on and (mod:get("track_memory") == true) and mem_ok
	SUBTRACT_OVERHEAD = mod:get("subtract_overhead") ~= false
	current_sort = mod:get("sort_mode") or "self"
	current_mode = mod:get("display_mode") or "simplified"
	current_tab = mod:get("active_tab") or "all"
	mod._active_tab = current_tab
	DISPLAY_ALPHA = SMOOTH_MAP[mod:get("smoothing") or "smooth"] or 0.02
	HITCH_ABS_MS = mod:get("hitch_ms") or 28
	local hz = mod:get("refresh_hz")
	refresh_interval = hz and (1 / math_max(1, hz)) or 0.33
end

function mod.on_setting_changed()
	apply_settings()
	refresh_order()
	rebuild_view()
end

function mod.on_enabled() apply_settings() end
function mod.on_disabled() ENABLED = false end

function mod.on_all_mods_loaded()
	apply_settings()
	instrument_events()
	wrap_hud_elements()
	ensure_constant_element()

	local dmf = get_mod("DMF")
	local uo = dmf and dmf.mods_unloading_order
	if uo then
		local our_rev
		for i = 1, #uo do if uo[i] == SELF_NAME then our_rev = i; break end end
		if our_rev then
			local before_names = {}
			for i = our_rev + 1, #uo do
				local nm = uo[i]
				if nm ~= "DMF" and nm ~= "dmf" then before_names[#before_names + 1] = nm end
			end
			mod._mods_before = #before_names
			mod._mods_before_names = before_names
			if #before_names > 0 then
				mod:info(mod:localize("init_loaded_after", table.concat(before_names, ", ")))
			end
		end
	end

	refresh_order()
	rebuild_view()
	local n = 0
	for _ in pairs(instrumented) do n = n + 1 end
	local hud_count = 0
	for _ in pairs(hud_wrapped) do hud_count = hud_count + 1 end
	mod:info(mod:localize("init_instrumented", n, hud_count, mod._mods_before or -1, hook_patch_ok and "ok" or "FAILED"))
end

function mod.on_game_state_changed(status, state_name)
	if status == "enter" then
		instrument_events()
		wrap_hud_elements()
		ensure_constant_element()

		mem_hist, mem_hist_n, mem_hist_w, mem_sample_accum = {}, 0, 1, 0

		local sn = tostring(state_name or ""):lower()
		mod._allow_tab_click = not (sn:find("loading") or sn:find("splash") or sn:find("boot"))
	end
end

function mod.update(dt)
	depth = 0
	local frame_ms = dt * 1000
	local baseline = frame_ms_ema
	fold_frame(frame_ms, baseline)
	frame_ms_ema = frame_ms_ema + 0.1 * (frame_ms - frame_ms_ema)

	if ab.active and ab.mode == "calib" and calib_wrapped then
		calib_wrapped(calib_iters)
	end
	ab_update(dt, frame_ms)

	if frozen then return end

	graph_accum = graph_accum + dt
	if graph_accum >= graph_interval then
		graph_accum = 0
		local v = total_self_ms
		graph_vals[graph_w] = v
		graph_w = (graph_w % GRAPH_MAX) + 1
		if graph_n < GRAPH_MAX then graph_n = graph_n + 1 end

		local mb, _gkb, gcms = lua_gc_stats()
		mem_mb_ema = mem_mb_ema > 0 and (mem_mb_ema + 0.1 * (mb - mem_mb_ema)) or mb
		gc_ms_ema = gc_ms_ema + 0.1 * (gcms - gc_ms_ema)
		mem_sample_accum = mem_sample_accum + graph_interval
		if mem_sample_accum >= 5 then
			mem_sample_accum = 0
			mem_hist[mem_hist_w] = mem_mb_ema
			mem_hist_w = (mem_hist_w % MEM_HIST_MAX) + 1
			if mem_hist_n < MEM_HIST_MAX then mem_hist_n = mem_hist_n + 1 end
		end
	end

	rank_accum = rank_accum + dt
	if rank_accum >= rank_interval then
		rank_accum = 0
		refresh_order()
		wrap_hud_elements()
		ensure_constant_element()
	end
	refresh_accum = refresh_accum + dt
	if refresh_accum >= refresh_interval then refresh_accum = 0; rebuild_view() end
end

ensure_constant_element()
pcall(apply_settings)