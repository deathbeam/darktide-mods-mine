local mod = get_mod("NoBrainer")

local DEBUG_RATE_LIMIT = 100
local DEBUG_RATE_WINDOW = 30

local cache = {}
mod._S = function(k) if cache[k] == nil then cache[k] = mod:get(k) end return cache[k] end
mod._clear_cache = function() for k in pairs(cache) do cache[k] = nil end end
mod._debug_state = { throttle = {}, changes = {}, rate = { window_start = 0, count = 0, suppressed = false } }
mod._time = function(clock)
	local time_manager = Managers.time
	if not time_manager then return nil end

	local ok, value = pcall(time_manager.time, time_manager, clock or "gameplay")
	return ok and value or nil
end
mod._debug_enabled = function()
	return mod._S("enable_debug_messages") == true
end
local function debug_now()
	return mod._time("gameplay") or mod._time("main") or 0
end

local function debug_rate_allows()
	local now = debug_now()
	local rate = mod._debug_state.rate

	if now - (rate.window_start or 0) >= DEBUG_RATE_WINDOW or now < (rate.window_start or 0) then
		rate.window_start = now
		rate.count = 0
		rate.suppressed = false
	end

	if rate.count >= DEBUG_RATE_LIMIT then
		return false
	end

	if rate.count >= DEBUG_RATE_LIMIT - 1 then
		if not rate.suppressed then
			rate.suppressed = true
			mod:echo(string.format("[NB debug][core][rate_limit] suppressed=true limit=%s window=%ss", tostring(DEBUG_RATE_LIMIT), tostring(DEBUG_RATE_WINDOW)))
			rate.count = DEBUG_RATE_LIMIT
		end

		return false
	end

	rate.count = rate.count + 1
	return true
end

local function format_debug_value(value)
	if value == nil then return "nil" end
	if type(value) == "number" then return string.format("%.3f", value) end
	return tostring(value)
end

local function format_debug_fields(fields)
	if type(fields) ~= "table" then return "" end

	local keys = {}
	for key in pairs(fields) do
		keys[#keys + 1] = key
	end
	table.sort(keys)

	local parts = {}
	for i = 1, #keys do
		local key = keys[i]
		parts[#parts + 1] = tostring(key) .. "=" .. format_debug_value(fields[key])
	end

	return table.concat(parts, " ")
end

mod._debug = function(tag, message)
	if not mod._debug_enabled() then return end
	if not debug_rate_allows() then return end
	mod:echo(string.format("[NB debug][%s] %s", tostring(tag or "general"), tostring(message or "")))
end
mod._debug_event = function(tag, event, fields)
	if not mod._debug_enabled() then return end
	if not debug_rate_allows() then return end

	local formatted = format_debug_fields(fields)
	if formatted ~= "" then
		mod:echo(string.format("[NB debug][%s][%s] %s", tostring(tag or "general"), tostring(event or "event"), formatted))
	else
		mod:echo(string.format("[NB debug][%s][%s]", tostring(tag or "general"), tostring(event or "event")))
	end
end
mod._debug_throttle = function(key, seconds, tag, message)
	if not mod._debug_enabled() then return end

	local now = debug_now()
	local throttle = mod._debug_state.throttle
	local next_at = throttle[key] or 0

	if now < next_at then return end

	throttle[key] = now + (seconds or 1)
	mod._debug(tag, message)
end
mod._debug_event_throttle = function(key, seconds, tag, event, fields)
	if not mod._debug_enabled() then return end

	local now = debug_now()
	local throttle = mod._debug_state.throttle
	local next_at = throttle[key] or 0

	if now < next_at then return end

	throttle[key] = now + (seconds or 1)
	mod._debug_event(tag, event, fields)
end
mod._debug_change = function(key, value, tag, message)
	if not mod._debug_enabled() then return end

	local changes = mod._debug_state.changes
	local value_text = tostring(value)

	if changes[key] == value_text then return end

	changes[key] = value_text
	mod._debug(tag, message or value_text)
end
mod._debug_event_change = function(key, value, tag, event, fields)
	if not mod._debug_enabled() then return end

	local changes = mod._debug_state.changes
	local value_text = tostring(value)

	if changes[key] == value_text then return end

	changes[key] = value_text
	mod._debug_event(tag, event, fields)
end
mod._clear_debug_state = function()
	table.clear(mod._debug_state.throttle)
	table.clear(mod._debug_state.changes)
	mod._debug_state.rate.window_start = 0
	mod._debug_state.rate.count = 0
	mod._debug_state.rate.suppressed = false
end
mod._N = function(k, fallback, min, max)
	local raw = mod._S(k)
	local val = tonumber(raw)

	if not val then
		mod:warning("NoBrainer: setting '%s' is %s (expected number), using fallback", k, type(raw))
		val = fallback or 0
	end

	if min and val < min then val = min end
	if max and val > max then val = max end

	return val
end
mod._speed_scale = function(id)
	local val = mod._N(id, 1, 1, 10)
	return (val - 1) / 9
end

do
	local numeric_ids = { "balance_solve_speed", "expedition_solve_speed", "drill_solve_speed", "frequency_solve_speed" }
	for _, id in ipairs(numeric_ids) do
		local val = mod:get(id)
		if type(val) == "string" then
			if val == "inhuman" then
				mod:set(id, 10, false)
			else
				mod:set(id, 5, false)
			end
		elseif type(val) ~= "number" then
			mod:set(id, 5, false)
		end
	end
end

local callback_errors = {}
local function _fire(list, ...)
	if type(list) ~= "table" then return end
	for _, cb in ipairs(list) do
		local ok, err = pcall(cb, ...)

		if not ok and not callback_errors[cb] then
			callback_errors[cb] = true
			mod._debug_event("core", "callback_error", { callback = tostring(cb), err = tostring(err) })
			mod:error("NoBrainer callback failed: %s", tostring(err))
		end
	end
end
mod._reg = function(ev, cb) mod["_on_" .. ev] = mod["_on_" .. ev] or {}; mod["_on_" .. ev][#mod["_on_" .. ev] + 1] = cb end
mod._is_local_minigame_player = function(player)
	local player_manager = Managers.player
	local local_player = player_manager and player_manager:local_player_safe(1)

	return player ~= nil and local_player ~= nil and player == local_player
end

local function _reset_runtime(reason)
	_fire(mod._on_runtime_reset, reason)
	_fire(mod._on_round_end, reason)
end

mod._exp_mg            = nil
mod._exp_move_mg       = nil
mod._exp_press_until   = 0
mod._exp_release_until = 0
mod._exp_move_cooldown = 0
mod._exp_startup_delay = 0
mod._exp_submitted_stage = nil
mod._exp_submitted_until = 0
mod._exp_press_cooldown = 0
mod._exp_prev_cursor = nil
mod._drill_mg            = nil
mod._drill_cooldown      = 0
mod._drill_press_until   = 0
mod._drill_release_until = 0
mod._drill_move_cooldown = 0
mod._drill_startup_delay = 0
mod._freq_startup_delay = 0
mod._freq_mg            = nil
mod._freq_cooldown      = 0
mod._freq_last_stage    = 0
mod._freq_reaction_until = 0
mod._freq_confirm_until  = 0
mod._freq_was_on_target  = false
mod._freq_press_until    = 0
mod._freq_release_until  = 0
mod._scan_auto_pending   = false
mod._scan_holding        = false
mod._scan_hold_until     = 0
mod._scan_cooldown       = 0
mod._scan_refresh_timer  = nil
mod._current_action      = ""
mod._bal = { timer = 0, enabled = false,
	x = 0, y = 0, vx = 0, vy = 0, dist = 0,
	prev_x = 0, prev_y = 0,
	delayed_x = 0, delayed_y = 0, delayed_dist = 0,
	delayed_vx = 0, delayed_vy = 0 }

local mod_dir = "NoBrainer/scripts/mods/NoBrainer/"
local function _load(path)
	if not mod:io_dofile(mod_dir .. path) then
		mod:echo("NoBrainer: failed to load " .. path)
	end
end

for _, m in ipairs({
	"decode_symbols", "decode_search", "expedition_map", "drill", "scan", "balance", "frequency",
}) do _load("NoBrainer_minigame_" .. m) end

_load("NoBrainer_input")
_load("NoBrainer_practice_minigames")
_load("NoBrainer_practice")

mod.update                = function(dt) if mod:is_enabled() then _fire(mod._on_update, dt) end end
mod.on_setting_changed     = function(id) mod._clear_cache(); if id == "enable_debug_messages" then mod._clear_debug_state() end; _fire(mod._on_setting_changed, id) end
mod.on_enabled             = function() mod._clear_cache(); mod._clear_debug_state(); _fire(mod._on_enabled) end
mod.on_disabled            = function() mod._clear_cache(); mod._clear_debug_state(); _fire(mod._on_disabled); _reset_runtime("disabled") end
mod.on_game_state_changed = function(st, name)
	if st == "exit" and name == "StateGameplay" then mod._clear_debug_state(); _reset_runtime("gameplay_exit") end
end
mod.on_unload = function(exit_game)
	_reset_runtime("unload")
	_fire(mod._on_unload, exit_game)
	mod._clear_debug_state()
	mod._clear_cache()
end
