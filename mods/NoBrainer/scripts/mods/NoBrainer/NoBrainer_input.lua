local mod = get_mod("NoBrainer")
local S = mod._S

local Managers = Managers
local ScriptUnit = ScriptUnit
local Unit = Unit
local math_abs = math.abs
local math_max = math.max
local math_random = math.random

local PRACTICE_VIEW = "nobrainer_practice_view"
local PRIMARY_HOLD_ACTIONS = {
	action_one_hold = true,
	interact_hold = true,
	interact_primary_hold = true,
	jump_held = true,
}
local MOVE_ACTIONS = {
	move = true,
	move_controller = true,
}

local function _is_primary_hold_action(action)
	return PRIMARY_HOLD_ACTIONS[action] == true
end

local function _minigame_view_active()
	local ui = Managers.ui
	if not ui then return false end
	return ui:view_active("scanner_display_view") or ui:view_active(PRACTICE_VIEW)
end

local function _decode(action, result)
	if mod._ds_input then
		return mod._ds_input(action, result)
	end

	return result
end

local function _exp_move(action, result, source)
	if not S("enable_expedition_auto_solve") then return result end
	local mg = mod._exp_move_mg
	if not mg or not mg.cursor_position then return result end
	if (mod._exp_startup_delay or 0) > 0 then return result end
	if not _minigame_view_active() then return result end

	local now = mod._time("gameplay")

	if MOVE_ACTIONS[action] then
		if not now then return result end
		if mod._exp_move_blocked and mod._exp_move_blocked(now) then return result end

		local dir = source == "player_unit_input" and mod._exp_take_move_dir and mod._exp_take_move_dir(mg, now)
			or mod._exp_find_move_dir and mod._exp_find_move_dir(mg)
		if not dir then return result end

		return Vector3(dir.x or 0, dir.y or 0, 0)
	end

	if mod._exp_move_cooldown > 0 or mod._exp_move_blocked and mod._exp_move_blocked(now) then
		if action == "move_left" or action == "move_right"
			or action == "move_forward" or action == "move_backward" then
			return result
		end
	end

	local dir = mod._exp_find_move_dir and mod._exp_find_move_dir(mg)
	if not dir then return result end

	if action == "move_left"      and dir.x < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_right"     and dir.x >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_forward"   and dir.y >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end
	if action == "move_backward"  and dir.y < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end

	return result
end

local function _expedition(action, result)
	if not S("enable_expedition_auto_solve") then return result end
	local mg = mod._exp_mg
	if not mg or not mg.cursor_position then return result end
	if (mod._exp_startup_delay or 0) > 0 then return result end

	local now = mod._time("gameplay")
	if not now then return result end
	local is_submit_action = _is_primary_hold_action(action)
	local stage = mg._current_stage

	if mod._exp_press_until > now and is_submit_action then
		mod._debug_event_throttle("search_input_press_event", 1.0, "search", "synthetic_hold", { action = action, stage = stage, until_t = mod._exp_press_until })
		return true
	end
	if mod._exp_release_until > now and is_submit_action then
		mod._debug_event_throttle("search_input_release_event", 1.0, "search", "synthetic_release", { action = action, stage = stage, until_t = mod._exp_release_until })
		return false
	end

	if mod._exp_submitted_stage and mod._exp_submitted_stage ~= stage then
		if mod._exp_submitted_stage and mod._exp_handle_stage_changed then
			mod._exp_handle_stage_changed(mod._exp_submitted_stage, stage)
		else
			mod._exp_submitted_stage = nil
			mod._exp_submitted_until = 0
		end

		return result
	elseif now < (mod._exp_submitted_until or 0) then
		return result
	else
		mod._exp_submitted_stage = nil
		mod._exp_submitted_until = 0
	end

	if result or not is_submit_action then
		return result
	end
	if not _minigame_view_active() then
		return result
	end

	if mod._exp_ready_to_submit and mod._exp_ready_to_submit(mg, now) then
		mod._exp_press_until = now + 0.08
		mod._exp_release_until = mod._exp_press_until + 0.12
		mod._exp_submitted_stage = stage
		mod._exp_submitted_until = now + 1.2
		mod._debug_event("search", "synthetic_press", { action = action, press_until = mod._exp_press_until, release_until = mod._exp_release_until, stage = stage, submitted_until = mod._exp_submitted_until })
		return true
	end
	return result
end


local function _drill(action, result)
	if not S("enable_drill_auto") then return result end
	local mg = mod._drill_active_mg and mod._drill_active_mg() or mod._drill_mg
	if not mg then return result end
	if (mod._drill_startup_delay or 0) > 0 then return result end
	if not _minigame_view_active() then
		return result
	end

	if _is_primary_hold_action(action) then
		local now = mod._time("gameplay")
		if not now then return result end
		local stage = mg.current_stage and mg:current_stage() or mg._current_stage
		if mod._drill_release_until > now then
			mod._debug_event_throttle("drill_input_release_event", 1.0, "drill", "synthetic_release", { action = action, stage = stage, until_t = mod._drill_release_until })
			return false
		end
		if mod._drill_press_until > now then
			mod._debug_event_throttle("drill_input_press_event", 1.0, "drill", "synthetic_hold", { action = action, stage = stage, until_t = mod._drill_press_until })
			return true
		end
		if result then return result end
		if mod._drill_cooldown > 0 then return result end
		if not mod._drill_should_submit(mg, now) then return result end

		mod._drill_cooldown = 0.15
		mod._drill_press_until = now + 0.08
		mod._drill_release_until = mod._drill_press_until + 0.12
		mod._debug_event("drill", "synthetic_press", { action = action, press_until = mod._drill_press_until, release_until = mod._drill_release_until, stage = stage })
		return true
	end

	if MOVE_ACTIONS[action] then
		if mod._drill_move_cooldown > 0 then return result end

		local dir = mod._drill_move_vec(mg)
		if not dir then return result end

		return Vector3(dir.x or 0, dir.y or 0, 0)
	end

	if mod._drill_move_cooldown > 0 then
		if action == "move_left" or action == "move_right"
			or action == "move_forward" or action == "move_backward" then
			return result
		end
	end

	local dir = mod._drill_move_vec(mg)
	if not dir then return result end

	if action == "move_left"      and dir.x < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_right"     and dir.x >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_forward"   and dir.y >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end
	if action == "move_backward"  and dir.y < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end

	return result
end

local function _frequency(action, result)
	if not S("enable_frequency_auto") then return result end
	local mg = mod._freq_mg
	if not mg then return result end
	if (mod._freq_startup_delay or 0) > 0 then return result end
	if not _minigame_view_active() then return result end

	local now = mod._time("gameplay")
	if not now then return result end

	if _is_primary_hold_action(action) then
		local stage = mg.current_stage and mg:current_stage() or mg._current_stage
		if mod._freq_release_until > now then
			mod._debug_event_throttle("frequency_input_release_event", 1.0, "frequency", "synthetic_release", { action = action, stage = stage, until_t = mod._freq_release_until })
			return false
		end
		if mod._freq_press_until > now then
			mod._debug_event_throttle("frequency_input_hold_event", 1.0, "frequency", "synthetic_hold", { action = action, stage = stage, until_t = mod._freq_press_until })
			return true
		end
		if result then return result end

		if mod._freq_try_submit and mod._freq_try_submit(mg, now) then
			mod._debug_event("frequency", "synthetic_press", { action = action, press_until = mod._freq_press_until, release_until = mod._freq_release_until, stage = stage })
			return true
		end

		return result
	end

	if MOVE_ACTIONS[action] then
		local dir = mod._freq_move_vec and mod._freq_move_vec(mg)
		if not dir then return result end

		return Vector3(dir.x or 0, dir.y or 0, 0)
	end

	local dir = mod._freq_move_vec and mod._freq_move_vec(mg)
	if not dir then return result end

	if action == "move_left"      and dir.x < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_right"     and dir.x >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.x)) end
	if action == "move_forward"   and dir.y >  0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end
	if action == "move_backward"  and dir.y < -0.15 then return math_max(type(result) == "number" and result or 0, math_abs(dir.y)) end

	return result
end

local function _balance(action, result)
	if not S("enable_balance") then return result end
	local bal = mod._bal
	if not bal or bal.timer <= 0 or not bal.enabled then return result end

	local scale = bal.scale or 0

	local use_x, use_y, use_dist = bal.x, bal.y, bal.dist
	local gate_vx, gate_vy = bal.vx, bal.vy
	local lazy_limit = bal.lazy_limit or 0.35

	if scale < 0.95 then
		use_x, use_y, use_dist = bal.delayed_x, bal.delayed_y, bal.delayed_dist
		gate_vx, gate_vy = bal.delayed_vx, bal.delayed_vy
		if math_random() < (bal.skip_chance or 0) then return result end
	end

	if use_dist <= lazy_limit then
		if scale < 0.95 or (math_abs(gate_vx) <= 0.05 and math_abs(gate_vy) <= 0.05) then
			return result
		end
	end

	local correction_x = mod._bal_correction(use_x, gate_vx, use_dist, bal.strength)
	local correction_y = mod._bal_correction(use_y, gate_vy, use_dist, bal.strength)

	if MOVE_ACTIONS[action] then
		local x = correction_x and -correction_x or 0
		local y = correction_y or 0

		if x == 0 and y == 0 then return result end
		if scale < 0.95 and math_random() < (bal.apply_skip_chance or 0) then return result end

		mod._debug_event_throttle("balance_correction_event", 1.0, "balance", "correction", {
			action = action,
			correction_x = correction_x or 0,
			correction_y = correction_y or 0,
			dist = use_dist or 0,
			out_x = x,
			out_y = y,
			scale = scale,
			vx = gate_vx or 0,
			vy = gate_vy or 0,
			x = use_x or 0,
			y = use_y or 0,
		})
		return Vector3(x, y, 0)
	end

	local v, current

	if correction_x and correction_x > 0 and action == "move_left" then
		v, current = correction_x, result
	elseif correction_x and correction_x < 0 and action == "move_right" then
		v, current = -correction_x, result
	elseif correction_y and correction_y > 0 and action == "move_forward" then
		v, current = correction_y, result
	elseif correction_y and correction_y < 0 and action == "move_backward" then
		v, current = -correction_y, result
	else
		return result
	end

	if scale < 0.95 and v and math_random() < (bal.apply_skip_chance or 0) then
		return result
	end

	if v then
		local cur = type(current) == "number" and current or 0
		mod._debug_event_throttle("balance_correction_event", 1.0, "balance", "correction", {
			action = action,
			correction_x = correction_x or 0,
			correction_y = correction_y or 0,
			dist = use_dist or 0,
			out = math_max(cur, v),
			scale = scale,
			vx = gate_vx or 0,
			vy = gate_vy or 0,
			x = use_x or 0,
			y = use_y or 0,
		})
		return math_max(cur, v)
	end
	return result
end

local scan_hold_duration = nil
local function _scan_hold_duration()
	if scan_hold_duration then return scan_hold_duration end

	local duration = 1
	local ok, scanner = pcall(require, "scripts/settings/equipment/weapon_templates/devices/scanner_equip")
	local actions = ok and scanner and scanner.actions
	local action = actions and (actions.action_scan_confirm or actions.action_scan)
	local scan_settings = action and action.scan_settings

	if scan_settings and tonumber(scan_settings.confirm_time) then
		duration = tonumber(scan_settings.confirm_time)
	end

	scan_hold_duration = duration + 0.15
	return scan_hold_duration
end

local function _scan(action, result)
    if not S("enable_auto_scan") then return result end

	if mod._scan_holding then
		if action == "action_one_hold" then
			local now = mod._time("gameplay")
			if now and now > mod._scan_hold_until then
				mod._debug_event("scan", "hold_finished", { action = action, hold_until = mod._scan_hold_until, now = now, target = tostring(mod._scan_hold_target) })
				mod._scan_holding = false
				mod._scan_hold_target = nil
				return result
            end
            return true
        end
        if action == "action_one_released" then
            return false
        end
        return result
    end

    if (mod._current_action or "") ~= "action_scan" then return result end
    if not mod._scan_auto_pending then return result end
    if action == "action_one_pressed" then
        local player_manager = Managers.player
        local player = player_manager and player_manager:local_player_safe(1)
        local unit = player and player.player_unit
        local ext = unit and ScriptUnit.has_extension(unit, "unit_data_system")
		local scan = ext and ext:read_component("scanning")
		local target = scan and scan.scannable_unit
		if not target then
			mod._debug_event_throttle("scan_hold_blocked_event", 0.5, "scan", "hold_blocked", { action = action, reason = "no_target" })
			return result
		end

		if not scan.line_of_sight then
			mod._debug_event_throttle("scan_hold_blocked_event", 0.5, "scan", "hold_blocked", { action = action, reason = "no_line_of_sight", target = tostring(target) })
			return result
		end

		if target and scan.line_of_sight then
			local scannable_ext = Unit.alive(target) and ScriptUnit.has_extension(target, "mission_objective_zone_scannable_system")
			if scannable_ext and scannable_ext:is_active() then
				local now = mod._time("gameplay")
				if not now then return result end
				mod._scan_auto_pending = false
				mod._scan_holding = true
				mod._scan_hold_target = target
				mod._scan_hold_until = now + _scan_hold_duration()
                mod._scan_cooldown = 0.3
				mod._debug_event("scan", "hold_started", { action = action, hold_until = mod._scan_hold_until, target = tostring(target) })
                return true
            end

			mod._debug_event_throttle("scan_hold_blocked_event", 0.5, "scan", "hold_blocked", { action = action, reason = "inactive_target", target = tostring(target) })
        end
    end
    return result
end

local function _any_minigame_active()
	local bal = mod._bal

	return mod._exp_mg ~= nil
		or mod._exp_move_mg ~= nil
		or mod._freq_mg ~= nil
		or mod._drill_mg ~= nil
		or mod._ds_mg ~= nil
		or mod._scan_holding
		or mod._scan_auto_pending
		or (bal and bal.enabled and (bal.timer or 0) > 0)
end

local function _apply_route(fn, action, result)
	local next_result = fn(action, result)

	if next_result == nil then
		return result
	end

	return next_result
end

function mod._route_input(action, result, source)
	local r = result

	if not mod:is_enabled() then return r end

	if mod._practice_active and mod._practice_active() then
		if action == "sprint" or action == "crouch" or action == "jump"
			or action == "weapon_reload" or action == "wield_scroll" or action == "wield_switch"
			or action == "action_one_pressed" or action == "action_one_released"
			or action == "weapon_extra" or action == "companion_attack" then
			return false
		end
		if action == "interact_hold" or action == "action_one_hold" then
			if mod._practice_route_input then mod._practice_route_input(action, r) end
			return false
		end
		if mod._practice_route_input then mod._practice_route_input(action, r) end
		if action == "move" or action == "move_controller" then
			return Vector3(0, 0, 0)
		elseif action == "move_right" or action == "move_left"
			or action == "move_forward" or action == "move_backward" then
			return 0
		end
		return r
	end

	if not _any_minigame_active() then return r end
	r = _apply_route(_decode, action, r)
	r = _apply_route(function(a, value) return _exp_move(a, value, source) end, action, r)
	r = _apply_route(_expedition, action, r)
	r = _apply_route(_drill, action, r)
	r = _apply_route(_frequency, action, r)
	r = _apply_route(_scan, action, r)
	r = _apply_route(_balance, action, r)
	return r
end

local function hook_fn(func, self, action)
	local r = func(self, action)
	return mod._route_input(action, r, "input_service")
end

mod:hook(CLASS.InputService, "_get", hook_fn)
if rawget(CLASS.InputService, "_get_simulate") then
	mod:hook(CLASS.InputService, "_get_simulate", hook_fn)
end

mod:hook_require("scripts/extension_systems/input/player_unit_input_extension", function(PlayerUnitInputExtension)
	mod:hook(PlayerUnitInputExtension, "get", function(func, self, action)
		local r = func(self, action)
		local player = self and self._player

		if player and player.is_human_controlled and not player:is_human_controlled() then
			return r
		end

		return mod._route_input(action, r, "player_unit_input")
	end)
end)

return true
