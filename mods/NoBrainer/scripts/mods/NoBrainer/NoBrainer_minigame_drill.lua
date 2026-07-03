local mod = get_mod("NoBrainer")
local S = mod._S

local MinigameSettings = require("scripts/settings/minigame/minigame_settings")
local drill_active = false
local drill_completed = false

mod:hook_require("scripts/ui/views/scanner_display_view/minigame_drill_view", function(View)
	mod:hook_safe(View, "_update_target", function(self, _, minigame, _)
		if not S("enable_drill") then return end
		if mod._practice_active and mod._practice_active() then return end
		mod._drill_view_mg = minigame
		local stage = minigame:current_stage()
		if not self._target_widgets or not stage or stage > #self._target_widgets then return end
		local tw = self._target_widgets[stage]; if not tw then return end
		local correct = minigame:correct_targets()
		local w = correct and correct[stage] and tw[correct[stage]]
		if w and w.style and w.style.highlight then
			w.style.highlight.color = { 255, 255, 255, 255 }
		end
	end)
end)

local function _drill_move_delay()
	local speed = mod._N("drill_solve_speed", 5, 1, 10)

	return (10 - speed) * 0.4
end

local function _is_gameplay(mg)
	local state = mg and mg.state and mg:state()
	return not state or state == MinigameSettings.game_states.gameplay
end

mod:hook_safe("MinigameDrill", "start", function(self)
	if not S("enable_drill_auto") then return end
	drill_active = true
	drill_completed = false
	mod._drill_mg = self
	mod._drill_move_cooldown = _drill_move_delay()
	mod._debug_event("drill", "start", { move_cooldown = mod._drill_move_cooldown, server = self._is_server, stage = self._current_stage })
end)

mod:hook("MinigameDrill", "on_axis_set", function(func, self, t, x, y)
	if S("enable_drill_auto") then
		local pos = self._cursor_position
		local cx, cy = pos and pos.x, pos and pos.y

		func(self, t, x, y)

		local np = self._cursor_position
		if np and (np.x ~= cx or np.y ~= cy) then
			local delay = _drill_move_delay()
			mod._debug_event("drill", "cursor_moved", { cooldown = delay, from = tostring(cx) .. "," .. tostring(cy), stage = self.current_stage and self:current_stage() or self._current_stage, to = tostring(np.x) .. "," .. tostring(np.y) })
			if delay > 0 then
				mod._drill_move_cooldown = delay
			else
				mod._drill_move_cooldown = 0
			end
		end

		return
	end
	return func(self, t, x, y)
end)

local function _drill_cleanup(reason)
	if drill_active and reason then
		mod._debug_event("drill", reason, { stage = mod._drill_mg and mod._drill_mg.current_stage and mod._drill_mg:current_stage() or nil })
	end

	drill_active = false
	drill_completed = reason == "complete"
	mod._drill_mg = nil
	mod._drill_view_mg = nil
	mod._drill_cooldown = 0
	mod._drill_press_until = 0
	mod._drill_release_until = 0
	mod._drill_move_cooldown = 0
	mod._drill_startup_delay = 0
	mod._drill_prev_cursor = nil
end

mod:hook_safe("MinigameDrill", "stop", function()
	_drill_cleanup(drill_active and not drill_completed and "stop" or nil)
end)
mod:hook_safe("MinigameDrill", "complete", function()
	_drill_cleanup("complete")
end)

local function _target_for(mg)
	if not mg then return nil end

	local stage = mg:current_stage()
	local correct = stage and mg:correct_targets()
	local idx = correct and correct[stage]
	local targets = stage and mg:targets()

	return stage, idx, idx and targets and targets[stage] and targets[stage][idx]
end

local function _same_solution(a, b)
	if not a or not b or a == b then return true end

	local stage_a, idx_a, target_a = _target_for(a)
	local stage_b, idx_b, target_b = _target_for(b)

	return stage_a == stage_b
		and idx_a == idx_b
		and target_a and target_b
		and math.abs(target_a.x - target_b.x) < 0.001
		and math.abs(target_a.y - target_b.y) < 0.001
end

function mod._drill_active_mg()
	local view_mg = mod._drill_view_mg

	if view_mg and _is_gameplay(view_mg) then
		return view_mg
	end

	return mod._drill_mg
end

function mod._drill_move_vec(mg)
	if not mg then return nil end
	if not _is_gameplay(mg) then
		mod._debug_event_throttle("drill_not_gameplay_event", 1.5, "drill", "wait", { reason = "not_gameplay", stage = mg.current_stage and mg:current_stage() or mg._current_stage })
		return nil
	end
	local cursor = mg:cursor_position()
	if not cursor then
		mod._debug_event_throttle("drill_no_cursor_event", 1.5, "drill", "wait", { reason = "no_cursor", stage = mg.current_stage and mg:current_stage() or mg._current_stage })
		return nil
	end
	local stage, target_index, target = _target_for(mg)
	if not target then
		mod._debug_event_throttle("drill_no_target_event", 1.5, "drill", "wait", { reason = "no_target", stage = stage })
		return nil
	end

	mod._debug_event_change("drill_target", tostring(stage) .. ":" .. tostring(target_index), "drill", "target", { stage = stage, target = tostring(target.x) .. "," .. tostring(target.y), target_index = target_index })

	local dx = target.x - cursor.x
	local dy = -(target.y - cursor.y)
	local len = math.sqrt(dx * dx + dy * dy)
	if len <= 0.01 then return nil end
	local x = dx / len
	local y = dy / len
	mod._debug_event_throttle("drill_move_plan_event", 1.0, "drill", "move_plan", { cursor = tostring(cursor.x) .. "," .. tostring(cursor.y), dir = string.format("%.3f,%.3f", x, y), move_cooldown = mod._drill_move_cooldown or 0, stage = stage, target = tostring(target.x) .. "," .. tostring(target.y), target_index = target_index })
	return Vector3(x, y, 0)
end

function mod._drill_should_submit(mg, t)
	if not _is_gameplay(mg) then mod._debug_event_throttle("drill_submit_not_gameplay_event", 1.5, "drill", "wait", { reason = "not_gameplay", stage = mg.current_stage and mg:current_stage() or mg._current_stage }); return false end
	if not mg:is_searching() then mod._debug_event_throttle("drill_not_searching_event", 1.5, "drill", "wait", { reason = "not_searching", stage = mg:current_stage() }); return false end
	local search = mg:search_percentage(t)
	if search < 1 then mod._debug_event_throttle("drill_search_event", 1.0, "drill", "wait", { reason = "search_progress", search = search, stage = mg:current_stage() }); return false end
	if not mg:is_on_target() then mod._debug_event_throttle("drill_off_target_event", 1.5, "drill", "wait", { reason = "off_target", stage = mg:current_stage() }); return false end
	mod._debug_event("drill", "submit_ready", { stage = mg:current_stage() })
	return true
end

local function on_update(dt)
	if mod._drill_startup_delay > 0 then mod._drill_startup_delay = math.max(mod._drill_startup_delay - dt, 0) end
	if mod._drill_cooldown > 0 then mod._drill_cooldown = math.max(mod._drill_cooldown - dt, 0) end
	if mod._drill_move_cooldown > 0 then mod._drill_move_cooldown = math.max(mod._drill_move_cooldown - dt, 0) end

	local mg = mod._drill_mg
	if mg then
		local pos = mg:cursor_position()
		local prev = mod._drill_prev_cursor
		if pos and prev and (pos.x ~= prev.x or pos.y ~= prev.y) then
			local delay = _drill_move_delay()
			mod._debug_event("drill", "cursor_sync", { cooldown = delay, from = tostring(prev.x) .. "," .. tostring(prev.y), stage = mg.current_stage and mg:current_stage() or mg._current_stage, to = tostring(pos.x) .. "," .. tostring(pos.y) })
			if delay > 0 then
				mod._drill_move_cooldown = delay
			else
				mod._drill_move_cooldown = 0
			end
		end
		mod._drill_prev_cursor = pos and { x = pos.x, y = pos.y } or nil

		local now = mod._time("gameplay")

		if now and mg._is_server and mod._drill_cooldown <= 0
			and _same_solution(mg, mod._drill_view_mg)
			and mod._drill_should_submit(mg, now) then
			mod._drill_cooldown = 0.15
			mod._debug_event("drill", "server_fallback", { stage = mg:current_stage() })
			mg:on_action_pressed(now)
		end
	end
end

local function on_setting(id)
	if id == "enable_drill_auto" then
		_drill_cleanup(drill_active and "setting_changed" or nil)
	end
end

local function on_round_end() _drill_cleanup(drill_active and "round_end" or nil) end

mod._reg("update", on_update)
mod._reg("setting_changed", on_setting)
mod._reg("round_end", on_round_end)

return true
