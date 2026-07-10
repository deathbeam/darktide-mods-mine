local mod = get_mod("ModPerformanceMonitor")

local unpack = unpack or table.unpack
local collectgarbage = collectgarbage
local math_min, math_max, math_huge, math_floor, math_ceil = math.min, math.max, math.huge, math.floor, math.ceil
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

local function try_ffi_timer()
	local ok_ffi, ffi = pcall(function()
		local Mods_g = rawget(_G, "Mods")
		return rawget(_G, "ffi")
			or (package and package.loaded and package.loaded.ffi)
			or (Mods_g and Mods_g.lua and Mods_g.lua.ffi)
			or (Mods_g and Mods_g.ffi)
			or require("ffi")
	end)
	if not ok_ffi or type(ffi) ~= "table" then return nil end

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

local function measure_res(fn)
	local best = math_huge
	local prev = fn()
	for i = 1, 500000 do
		local t = fn()
		local d = t - prev
		if d > 0 then
			if d < best then best = d end
			if i >= 2000 then break end
		end
		prev = t
	end
	return best
end

do
	local builders = {
		function()
			local f = try_ffi_timer()
			if f then return f, "ffi.QueryPerformanceCounter" end
			return nil
		end,
		function()
			if rawget(_G, "os") and type(os.clock) == "function" then
				return function() return os.clock() * 1000.0 end, "os.clock"
			end
			return nil
		end,
		function()
			local App = rawget(_G, "Application")
			if App and type(App.time_since_launch) == "function" then
				return function() return App.time_since_launch() * 1000.0 end, "Application.time_since_launch"
			end
			return nil
		end,
	}
	local best_fn, best_name, best_res
	local fallback_fn, fallback_name
	for _, build in ipairs(builders) do
		local ok, fn, name = pcall(build)
		if ok and type(fn) == "function" then
			fallback_fn, fallback_name = fallback_fn or fn, fallback_name or name
			local res = measure_res(fn)
			if res < math_huge and (not best_res or res < best_res) then
				best_fn, best_name, best_res = fn, name, res
			end
		end
	end
	if best_fn then
		timer_now, timer_name, timer_res_ms = best_fn, best_name, best_res
	elseif fallback_fn then
		timer_now, timer_name, timer_res_ms = fallback_fn, fallback_name, 0.0
	else
		timer_now, timer_name, timer_res_ms = function() return 0.0 end, "none", 0.0
	end
end

mod._timer_name = timer_name
mod._timer_res_ms = timer_res_ms
local TIMER_OK = (timer_name == "ffi.QueryPerformanceCounter") or (timer_res_ms > 0 and timer_res_ms <= 0.2)
mod:info("Timer: %s (resolution ~%.5f ms, usable=%s)", timer_name, timer_res_ms, tostring(TIMER_OK))

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

local function get_bucket(name)
	local b = stats[name]
	if not b then
		b = {
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

local function make_wrapper(bucket, handler, source_label)
	local sources = bucket.sources
	local w = function(...)
		if not ENABLED then
			return handler(...)
		end
		depth = depth + 1
		local my = depth
		child_ms[my] = 0
		local mem0
		if TRACK_MEM then
			child_kb[my] = 0
			mem0 = collectgarbage("count")
		end

		local t0 = timer_now()
		local n, r = pack_returns(handler(...))
		local incl = timer_now() - t0
		if incl < 0 then incl = 0 end

		local incl_mem = 0
		if TRACK_MEM then incl_mem = collectgarbage("count") - mem0 end

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
					cls.update = make_wrapper(bucket, cls.update, "hud " .. class_name .. ".update")
				end
				if type(cls.draw) == "function" then
					cls.draw = make_wrapper(bucket, cls.draw, "hud " .. class_name .. ".draw")
				end
				hud_wrapped[class_name] = true
			end
		end
	end
end

if WRAP_OK then
	local pt = get_persist("mpm_originals")
	if type(pt.new_mod) ~= "function" then
		local cur = rawget(_G, "new_mod")
		if type(cur) == "function" then pt.new_mod = cur end
	end
	local orig_new_mod = pt.new_mod
	if type(orig_new_mod) == "function" then
		local nm = function(name, resources)
			local t0 = timer_now()
			local result = orig_new_mod(name, resources)
			local dt = timer_now() - t0
			if type(name) == "string" and name ~= SELF_NAME then
				get_bucket(name).load_ms = dt
			end
			return result
		end
		SHIM_SKIP[nm] = true
		rawset(_G, "new_mod", nm)
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
					other[ev] = make_wrapper(bucket, fn, "event " .. ev)
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

		if fs > top_fs then top_fs = fs; top_name = name end
		total = total + b.self_ms

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
	self   = "CPU time",
	incl   = "CPU time (inclusive)",
	calls  = "calls per frame",
	mem    = "memory per frame",
	total  = "total time",
	peak   = "peak (worst frame)",
	spikes = "stutters caused",
	load   = "load time",
}
local current_sort = "self"
local current_mode = "simplified"
local current_tab = "all"

local TABS = {
	{ id = "all",    label = "All" },
	{ id = "cpu",    label = "CPU" },
	{ id = "mem",    label = "Memory" },
	{ id = "spikes", label = "Stutters" },
	{ id = "load",   label = "Loading" },
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
		n = n + 1
		arr[n] = { name = name, key = value_for(b, sort_key) }
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
		if not seen[name] then n = n + 1; out[n] = { name = name, b = b } end
	end
	return out
end

local function trunc(s, w)
	if #s > w then return s:sub(1, w - 1) .. "." end
	return s
end

local function lua_mem_mb()
	local ok, mem = pcall(function()
		local Prof = rawget(_G, "Profiler")
		if Prof and Prof.lua_stats then return (Prof.lua_stats()) end
		return collectgarbage("count")
	end)
	local kb = (ok and type(mem) == "number") and mem or collectgarbage("count")
	return kb / 1024
end

local function lua_gc_stats()
	local ok, m, g, _pct, _est, actual = pcall(function()
		local Prof = rawget(_G, "Profiler")
		if Prof and Prof.lua_stats then return Prof.lua_stats() end
		return collectgarbage("count"), 0, 0, 0, 0
	end)
	if not ok then return collectgarbage("count") / 1024, 0, 0 end
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

local function p95(b)
	return percentile(b.hist, b.hist_n, 0.95)
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

local function coverage_line()
	local n = mod._mods_before
	if n == nil then return nil end
	if n <= 0 then
		return "Hook coverage: full (loaded first)", COL.good
	end
	local names = mod._mods_before_names
	if names and #names > 0 and #names <= 2 then
		return "Hooks not measured for: " .. table.concat(names, ", "), COL.warn
	end
	return string_format("Hook coverage: %d earlier mod%s not measured", n, n == 1 and "" or "s"), COL.warn
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
	return string_format("Your 3 heaviest mods use %.2f ms/frame combined", save)
end

local function build_tab_all(lines)
	local arr = ordered_entries()
	local fps, ms = frame_fps()
	local frame_pct = ms > 0 and (total_self_ms / ms * 100) or 0
	local max_rows = mod:get("max_rows") or 12

	local title = "MOD PERFORMANCE"
	if frozen then title = title .. "   [FROZEN]" end
	if not ENABLED then title = title .. "   [PAUSED]" end
	add_line(lines, title, COL.title, true)

	add_line(lines, "CPU used by mods", COL.sub,
		false, string_format("%.1f ms/frame", total_self_ms))
	add_line(lines, string_format("~%.0f%% of a frame at %d FPS", frame_pct, fps), COL.dim,
		false, string_format("%d FPS avg", fps))
	add_line(lines, "Smoothness (worst 1% of frames)", COL.dim,
		false, string_format("%d FPS low", one_percent_low_fps()))

	local mb, mtrend, mwarn = mem_trend()
	add_line(lines, "Memory (Lua)", mwarn and COL.warn or COL.dim,
		false, string_format("%.0f MB, %s", mb, mtrend))
	add_line(lines, "Garbage collection", gc_ms_ema > 2 and COL.warn or COL.dim,
		false, string_format("%.1f ms", gc_ms_ema))

	local _, load_total = slowest_loads(1)
	if load_total > 50 then
		add_line(lines, "Slowed loading by", COL.dim,
			false, string_format("%.1f s", load_total / 1000))
	end

	if spike_summary() then
		add_line(lines, "Stutters detected", COL.warn, false, "see Stutters tab")
	else
		add_line(lines, "Stutters", COL.dim, false, "none recently")
	end

	local rec = recommendation_line()
	add_line(lines, rec or "Overall mod impact is low right now", rec and COL.sub or COL.good)

	if not TIMER_OK then
		add_line(lines, "Coarse timer: averages OK, single-frame peaks approximate", COL.warn)
	end
	if mod._safe_mode then
		add_line(lines, "Safe mode on: no mods are being measured", COL.warn)
	elseif not mod._shim_ok then
		add_line(lines, "Stack shim inactive: measuring is off so nothing can break", COL.warn)
	end
	local cov, covcol = coverage_line()
	if cov then add_line(lines, cov, covcol) end

	add_graph(lines)

	add_line(lines, "MOD", COL.head, false, "TIME      SHARE")

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
	if shown == 0 then add_line(lines, "no mod is using measurable CPU right now", COL.good) end
	if negligible > 0 then
		add_line(lines, string_format("+ %d more with negligible impact", negligible), COL.dim)
	end
end

local function build_tab_generic(lines)
	local tab = current_tab
	local max_rows = mod:get("max_rows") or 12
	local fps, ms = frame_fps()
	local names = { cpu = "CPU", mem = "MEMORY", spikes = "STUTTERS", load = "LOADING" }

	local title = "MOD PERFORMANCE - " .. (names[tab] or "")
	if frozen then title = title .. "   [FROZEN]" end
	if not ENABLED then title = title .. "   [PAUSED]" end
	add_line(lines, title, COL.title, true)

	if tab == "cpu" then
		add_line(lines, "CPU used by mods", COL.sub, false, string_format("%.1f ms/frame", total_self_ms))
		add_line(lines, string_format("~%.0f%% of a frame", ms > 0 and total_self_ms / ms * 100 or 0), COL.dim,
			false, string_format("%d FPS avg", fps))
		add_graph(lines)
		add_line(lines, "MOD", COL.head, false, "TIME      SHARE")
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
		if shown == 0 then add_line(lines, "no measurable CPU use", COL.good) end
		if neg > 0 then add_line(lines, string_format("+ %d more negligible", neg), COL.dim) end

	elseif tab == "mem" then
		local mb, mtrend, mwarn = mem_trend()
		add_line(lines, "Memory (Lua)", mwarn and COL.warn or COL.sub, false, string_format("%.0f MB, %s", mb, mtrend))
		add_line(lines, "Garbage collection", gc_ms_ema > 2 and COL.warn or COL.dim, false, string_format("%.1f ms/frame", gc_ms_ema))
		if TRACK_MEM then
			add_line(lines, "MOD", COL.head, false, "KB/frame")
			local arr = ordered_entries()
			local shown = 0
			for _, e in ipairs(arr) do
				if e.b.mem_kb >= 1 and shown < max_rows then
					shown = shown + 1
					add_line(lines, trunc(e.name, 30), COL.text, false, string_format("%.0f KB", e.b.mem_kb))
				end
			end
			if shown == 0 then add_line(lines, "no measurable allocation", COL.good) end
		else
			add_line(lines, "", COL.dim)
			add_line(lines, "Turn on 'Track memory' in options", COL.dim)
			add_line(lines, "to see per-mod memory here.", COL.dim)
		end

	elseif tab == "spikes" then
		add_line(lines, "Smoothness (worst 1% of frames)", COL.sub, false, string_format("%d FPS low", one_percent_low_fps()))
		add_line(lines, "Worst frame", COL.dim, false, string_format("%.1f ms", worst_frame_ms))
		local spikes = spike_summary()
		add_line(lines, "Suspects", spikes and COL.warn or COL.dim, false, spikes or "none recently")
		add_line(lines, "MOD", COL.head, false, "stutters")
		local arr = ordered_entries()
		local shown = 0
		for _, e in ipairs(arr) do
			if e.b.spike_count > 0 and shown < max_rows then
				shown = shown + 1
				add_line(lines, trunc(e.name, 26), COL.warn, false,
					string_format("%d  (peak %.0fms)", e.b.spike_count, e.b.worst_spike_ms))
			end
		end
		if shown == 0 then add_line(lines, "no stutters recorded", COL.good) end

	elseif tab == "load" then
		local _, load_total = slowest_loads(1)
		add_line(lines, "Mods added to loading", COL.sub, false, string_format("%.1f s", load_total / 1000))
		add_line(lines, "MOD", COL.head, false, "load time")
		local arr = ordered_entries()
		local shown = 0
		for _, e in ipairs(arr) do
			if (e.b.load_ms or 0) >= 50 and shown < max_rows then
				shown = shown + 1
				add_line(lines, trunc(e.name, 30), COL.text, false, string_format("%.2f s", e.b.load_ms / 1000))
			end
		end
		if shown == 0 then add_line(lines, "no measurable load cost", COL.good) end
	end
end

local function build_detailed(lines)
	local arr = ordered_entries()
	local fps = frame_fps()
	local max_rows = mod:get("max_rows") or 12

	local _, load_total = slowest_loads(1)

	local title = "MOD PERFORMANCE MONITOR - detailed"
	if frozen then title = title .. "   [FROZEN]" end
	if not ENABLED then title = title .. "   [PAUSED]" end
	add_line(lines, title, COL.title, true)

	add_line(lines, string_format("total %.2f ms/frame   Lua %.0f MB   %d mods   %d FPS (1%% low %d)",
		total_self_ms, lua_mem_mb(), #arr, fps, one_percent_low_fps()), COL.sub)
	add_line(lines, string_format("worst frame %.1f ms   mods added ~%.1fs to load   sort: %s",
		worst_frame_ms, load_total / 1000, SORT_LABELS[active_sort()] or active_sort()), COL.dim)
	add_line(lines, string_format("timer %s ~%.4fms   overhead ~%.4fms/call %s   (estimates)",
		timer_name, timer_res_ms, SHIM_OVERHEAD_MS, SUBTRACT_OVERHEAD and "removed" or "shown"),
		TIMER_OK and COL.dim or COL.warn)
	local cov, covcol = coverage_line()
	if cov then add_line(lines, cov, covcol) end

	if tab_shows_graph() then add_graph(lines) end
	add_cols(lines, COL.head, "MOD", { "self", "p95", "peak", "calls", "share" })

	local shown = 0
	for _, e in ipairs(arr) do
		if shown >= max_rows then break end
		shown = shown + 1
		local b = e.b
		local _, col = severity(b.self_ms)
		local share = total_self_ms > 0 and (b.self_ms / total_self_ms * 100) or 0
		add_cols(lines, col, trunc(e.name, 22), {
			string_format("%.3f", b.self_ms),
			string_format("%.3f", p95(b)),
			string_format("%.3f", b.peak_ms),
			string_format("%.0f", b.calls),
			string_format("%.0f%%", share),
		})
	end
	if #arr > shown then
		add_line(lines, string_format("... %d more (raise Max rows, or dump full report)", #arr - shown), COL.dim)
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
		title = string_format("last %ds - all mods   now %.2f  peak %.2f   (line = %.2f ms)",
			math_floor(cnt * graph_interval + 0.5), vals[cnt] or 0, mx, mid),
	}
end

local function build_full_report()
	refresh_order()
	local arr = ordered_entries()
	local lines = {}
	lines[#lines + 1] = "===== Mod Performance Report ====="
	lines[#lines + 1] = "NOTE: figures estimate Lua MAIN-THREAD cost only (relative, not absolute). Spike blame is a heuristic. Not a substitute for engine profiling; please don't cite as proof against a mod author."
	lines[#lines + 1] = string_format("timer: %s (~%.5f ms) | overhead ~%.5f ms/call | Lua %.0f MB | total mod CPU %.3f ms/frame | 1%% low %d FPS | worst frame %.1f ms",
		timer_name, timer_res_ms, SHIM_OVERHEAD_MS, lua_mem_mb(), total_self_ms, one_percent_low_fps(), worst_frame_ms)
	lines[#lines + 1] = string_format("sorted by: %s | mods tracked: %d | memory tracking: %s",
		SORT_LABELS[current_sort], #arr, TRACK_MEM and "on" or "off")
	lines[#lines + 1] = string_format("stack shim: %s (%s) | safe mode: %s | instrumenting: %s",
		mod._shim_ok and "active" or "INACTIVE", tostring(mod._shim_note),
		mod._safe_mode and "on" or "off", mod._wrap_ok and "yes" or "no")
	lines[#lines + 1] = "rank  self_ms   p95    peak   spikes  calls/f   total_ms  load_ms   mod"
	for i, e in ipairs(arr) do
		local b = e.b
		lines[#lines + 1] = string_format("%3d  %8.4f %6.3f %6.3f %6d %8.0f %10.1f %8.0f   %s",
			i, b.self_ms, p95(b), b.peak_ms, b.spike_count, b.calls, b.total_ms, b.load_ms, e.name)
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
	safe_echo("[PerfMonitor] Full report written to the DMF log (%d mods).", #arr)
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
		safe_echo("[PerfMonitor] File writing isn't available in this environment.")
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
		safe_echo("[PerfMonitor] Saved to mods/ModPerformanceMonitor/reports/perf_%s.txt", stamp)
		mod:info("Wrote report: %s", txt_path)
	else
		safe_echo("[PerfMonitor] Could not write the report file (see log).")
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
	safe_echo("[PerfMonitor] Stats reset.")
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
	TRACK_MEM = on and (mod:get("track_memory") == true)
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
				mod:info("Loaded after these mods (their hooks are not measured): %s", table.concat(before_names, ", "))
			end
		end
	end

	refresh_order()
	rebuild_view()
	local n = 0
	for _ in pairs(instrumented) do n = n + 1 end
	mod:info("Instrumented %d mods (+%d HUD elements). Loaded after %d other mods. Hook patch: %s.",
		n, (function() local c = 0 for _ in pairs(hud_wrapped) do c = c + 1 end return c end)(),
		mod._mods_before or -1, hook_patch_ok and "ok" or "FAILED")
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
