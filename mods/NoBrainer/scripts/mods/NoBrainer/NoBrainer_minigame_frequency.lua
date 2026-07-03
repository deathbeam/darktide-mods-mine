local mod = get_mod("NoBrainer")
local S = mod._S

local MinigameSettings, UIWidget
local function _deps()
    if not MinigameSettings then
        MinigameSettings = require("scripts/settings/minigame/minigame_settings")
        UIWidget = require("scripts/managers/ui/ui_widget")
    end
end

mod._freq_mg            = mod._freq_mg            or nil
mod._freq_cooldown      = mod._freq_cooldown      or 0
mod._freq_scale         = mod._freq_scale         or 0
mod._freq_last_stage    = mod._freq_last_stage    or 0
mod._freq_reaction_until = mod._freq_reaction_until or 0
mod._freq_confirm_until  = mod._freq_confirm_until  or 0
mod._freq_was_on_target  = mod._freq_was_on_target  or false
mod._freq_press_until    = mod._freq_press_until    or 0
mod._freq_release_until  = mod._freq_release_until  or 0

local ARROW_MATERIAL = "content/ui/materials/buttons/arrow_01"
local ARROW_SIZE     = { 120, 120 }
local ARROW_DEPTH    = 7
local ARROW_TOP_Y    = 200
local ARROW_COLOR    = { 255, 255, 165, 0 }
local ARROW_HIDDEN   = { 0,   255, 165, 0 }
local RAD_180       = math.rad(180)
local RAD_90        = math.rad(90)
local RAD_NEG90     = math.rad(-90)

local ARROW_SPECS = {
    x = { offset = { -385, ARROW_TOP_Y, ARROW_DEPTH } },
    y = { offset = { -240, ARROW_TOP_Y, ARROW_DEPTH } },
}
local frequency_active = false
local frequency_completed = false

local function _stage(mg)
    return mg and mg.current_stage and mg:current_stage() or mg and mg._current_stage
end

local function _point_text(point)
    if not point then return "nil" end
    return tostring(point.x) .. "," .. tostring(point.y)
end

local function _ensure_arrows(view)
    local arrows = view._nb_freq_arrows
    if arrows and arrows.x and arrows.y then
        return arrows
    end
    _deps()
    arrows = {}
    for axis, spec in pairs(ARROW_SPECS) do
        local def = UIWidget.create_definition({{
            pass_type = "rotated_texture",
            style_id  = "arrow",
            value     = ARROW_MATERIAL,
            style     = {
                hdr    = true,
                angle  = 0,
                color  = table.clone(ARROW_HIDDEN),
                offset = table.clone(spec.offset),
                pivot  = {},
            },
        }}, "center_pivot", nil, ARROW_SIZE)
        arrows[axis] = UIWidget.init("nb_freq_arrow_" .. axis, def)
    end
    view._nb_freq_arrows = arrows
    return arrows
end

local function _is_gameplay(mg)
    _deps()
    local state = mg and mg.state and mg:state()
    return not state or state == MinigameSettings.game_states.gameplay
end

mod:hook_require("scripts/ui/views/scanner_display_view/minigame_frequency_view", function(View)
	mod:hook_safe(View, "draw_widgets", function(self, dt, t, input_service, ui_renderer)
		if not S("enable_frequency_highlight") or not ui_renderer then return end
		if mod._practice_active and mod._practice_active() then return end
		_deps()

        local ext = self._minigame_extension
        if not ext then return end
        local mg = ext:minigame(MinigameSettings.types.frequency)
        if not mg or not mg.frequency or not mg.target_frequency or mg.is_completed and mg:is_completed() then
            return
        end

        local current = mg:frequency()
        local target  = mg:target_frequency()
        if not current or not target then return end

        local margin = (MinigameSettings.frequency_success_margin or 0.1) * 0.35
        local dx = target.x - current.x
        local dy = target.y - current.y

        local arrows = _ensure_arrows(self)
        if not arrows then return end

        local xw = arrows.x
        if xw then
            local active = math.abs(dx) > margin
            xw.style.arrow.color = active and ARROW_COLOR or ARROW_HIDDEN
            xw.style.arrow.angle = dx < -margin and RAD_180 or 0
            if active then UIWidget.draw(xw, ui_renderer) end
        end

        local yw = arrows.y
        if yw then
            local active = math.abs(dy) > margin
            yw.style.arrow.color = active and ARROW_COLOR or ARROW_HIDDEN
            yw.style.arrow.angle = dy > margin and RAD_90 or RAD_NEG90
            if active then UIWidget.draw(yw, ui_renderer) end
        end
    end)

    mod:hook_safe(View, "init", function(self)
        self._nb_freq_arrows = nil
    end)
    mod:hook_safe(View, "destroy", function(self)
        self._nb_freq_arrows = nil
    end)
end)

function mod._freq_move_vec(mg)
    if not mg then return nil end
    if mg.is_completed and mg:is_completed() then return nil end
    if not _is_gameplay(mg) then mod._debug_event_throttle("freq_not_gameplay_event", 1.5, "frequency", "wait", { reason = "not_gameplay", stage = _stage(mg) }); return nil end

    _deps()
    local current = mg.frequency and mg:frequency()
    local target  = mg.target_frequency and mg:target_frequency()
    if not current or not target then mod._debug_event_throttle("freq_missing_event", 1.5, "frequency", "wait", { current = _point_text(current), reason = "missing_current_or_target", stage = _stage(mg), target = _point_text(target) }); return nil end

    local margin  = (MinigameSettings.frequency_success_margin or 0.1) * 0.35
    local range_x = math.max((MinigameSettings.frequency_width_max_scale  or 3.0) - (MinigameSettings.frequency_width_min_scale  or 1.5), 0.01)
    local range_y = math.max((MinigameSettings.frequency_height_max_scale or 3.5) - (MinigameSettings.frequency_height_min_scale or 1.5), 0.01)
    local dx      = target.x - current.x
    local dy      = target.y - current.y

    local ix = math.abs(dx) <= margin and 0 or math.clamp(dx / (range_x * 0.2), -1, 1)
    local iy = math.abs(dy) <= margin and 0 or math.clamp(dy / (range_y * 0.2), -1, 1)

    mod._debug_event_throttle("freq_move_plan_event", 1.0, "frequency", "move_plan", { current = _point_text(current), dx = dx, dy = dy, input = string.format("%.3f,%.3f", ix, iy), margin = margin, stage = _stage(mg), target = _point_text(target) })

    if mod._freq_scale < 0.95 then
        local strength = 0.03 + mod._freq_scale * 0.97
        local noise = 1 - mod._freq_scale

		local now = mod._time("gameplay")
        if now and mod._freq_reaction_until > now then
            return Vector3(0, 0, 0)
        end

        ix = ix * strength * (1.0 - noise * 0.12 + math.random() * noise * 0.24)
        iy = iy * strength * (1.0 - noise * 0.12 + math.random() * noise * 0.24)

        if math.random() < noise * 0.05 then
            return Vector3(math.random() * 0.3 - 0.15, math.random() * 0.3 - 0.15, 0)
        end
    end

    return Vector3(ix, iy, 0)
end

function mod._freq_on_target(mg)
    if not mg or not mg.is_visually_on_target then return false end
    if not _is_gameplay(mg) then return false end

    local ok, on_target = pcall(mg.is_visually_on_target, mg)
    return ok and on_target == true
end

local function _freq_update_state(mg, now)
    if not mg or not now then return false end
    if not mg.current_stage then return false end

    local stage = mg:current_stage()
    if not stage then return false end

    if stage ~= mod._freq_last_stage then
        if mod._freq_last_stage and mod._freq_last_stage ~= 0 then
            mod._debug_event("frequency", "stage_changed", { from = mod._freq_last_stage, to = stage })
        end

        mod._freq_last_stage = stage
        mod._freq_confirm_until = 0

        if mod._freq_scale < 0.95 then
            local delay = (1 - mod._freq_scale) * 4.0
            mod._freq_reaction_until = now + delay * (0.4 + math.random() * 0.6)
        end
    end

    local on_target = mod._freq_on_target(mg)
    if on_target ~= mod._freq_was_on_target then
        mod._debug_event("frequency", "target_state", { on_target = on_target, stage = stage })
    end

    if on_target and not mod._freq_was_on_target and mod._freq_scale < 0.95 then
        local delay = (1 - mod._freq_scale) * 2.0
        mod._freq_confirm_until = now + delay * (0.3 + math.random() * 0.7)
    end

    mod._freq_was_on_target = on_target

    return on_target
end

function mod._freq_try_submit(mg, now)
    if not mg or not now then return false end
	if mod._freq_startup_delay > 0 then mod._debug_event_throttle("freq_startup_event", 1.0, "frequency", "wait", { reason = "startup", remaining = mod._freq_startup_delay, stage = _stage(mg) }); return false end
	if mod._freq_cooldown > 0 then mod._debug_event_throttle("freq_cooldown_event", 1.0, "frequency", "wait", { reason = "cooldown", remaining = mod._freq_cooldown, stage = _stage(mg) }); return false end
	if not _freq_update_state(mg, now) then mod._debug_event_throttle("freq_off_target_event", 1.0, "frequency", "wait", { reason = "off_target", stage = _stage(mg) }); return false end
	if mod._freq_confirm_until > now or mod._freq_reaction_until > now then mod._debug_event_throttle("freq_confirm_event", 1.0, "frequency", "wait", { confirm_until = mod._freq_confirm_until, now = now, reaction_until = mod._freq_reaction_until, reason = "reaction_confirm" }); return false end

    local scale = mod._freq_scale or 0
    mod._freq_cooldown = 0.08 + (1 - scale) * 0.22
    mod._freq_press_until = now + 0.08
    mod._freq_release_until = mod._freq_press_until + 0.12
	mod._debug_event("frequency", "submit_ready", { stage = mg.current_stage and mg:current_stage() or mg._current_stage })

    return true
end

local function _freq_cleanup(reason)
    if frequency_active and reason then
        mod._debug_event("frequency", reason, { stage = mod._freq_mg and _stage(mod._freq_mg) })
    end

    frequency_active = false
    frequency_completed = reason == "complete"
    mod._freq_mg            = nil
    mod._freq_cooldown      = 0
    mod._freq_startup_delay = 0
    mod._freq_last_stage    = 0
    mod._freq_reaction_until = 0
    mod._freq_confirm_until  = 0
    mod._freq_was_on_target  = false
    mod._freq_press_until    = 0
    mod._freq_release_until  = 0
end

mod:hook_safe("MinigameFrequency", "start", function(self)
    if not S("enable_frequency_auto") then return end

    frequency_active = true
    frequency_completed = false
    mod._freq_mg            = self
    mod._freq_scale         = mod._speed_scale("frequency_solve_speed")
    mod._freq_last_stage    = 0
    mod._freq_reaction_until = 0
    mod._freq_confirm_until  = 0
    mod._freq_was_on_target  = false
    mod._freq_press_until    = 0
    mod._freq_release_until  = 0

    local speed = mod._N("frequency_solve_speed", 2, 1, 10)
    if speed >= 8 then
        mod._freq_startup_delay = 0.5
    elseif speed >= 6 then
        mod._freq_startup_delay = 0.3
    elseif speed <= 3 then
        mod._freq_startup_delay = 2.5
    else
        mod._freq_startup_delay = 1.0
    end

    if mod._freq_scale < 0.95 then
        local delay = (1 - mod._freq_scale) * 4.0
		local now = mod._time("gameplay")
        if now then
            mod._freq_reaction_until = now + delay * (0.5 + math.random() * 0.5)
        end
    end

    mod._debug_event("frequency", "start", { reaction_until = mod._freq_reaction_until, server = self._is_server, speed = speed, stage = self._current_stage, startup_delay = mod._freq_startup_delay })
end)

mod:hook_safe("MinigameFrequency", "stop", function()
    _freq_cleanup(frequency_active and not frequency_completed and "stop" or nil)
end)
mod:hook_safe("MinigameFrequency", "complete", function()
    _freq_cleanup("complete")
end)

local function on_update(dt)
    if mod._freq_startup_delay > 0 then
        mod._freq_startup_delay = math.max(mod._freq_startup_delay - dt, 0)
    end
    if mod._freq_cooldown > 0 then
        mod._freq_cooldown = math.max(mod._freq_cooldown - dt, 0)
    end

    local mg = mod._freq_mg
    if not mg or not S("enable_frequency_auto") then return end
    if mg.is_completed and mg:is_completed() then
        _freq_cleanup("complete")
        return
    end
    if not _is_gameplay(mg) then return end

	local now = mod._time("gameplay")
    if not now then return end

    local on_target = _freq_update_state(mg, now)

    if mg._is_server and mod._freq_startup_delay <= 0 then
        local move_vec = mod._freq_move_vec(mg)
        if move_vec then
            mg._last_axis_set = now - 0.02
            mg:on_axis_set(now, move_vec.x, move_vec.y)
        end
    end

	if mg._is_server and on_target and mod._freq_try_submit(mg, now) then
		mod._debug_event("frequency", "server_fallback", { stage = _stage(mg) })
		mg:test_frequency(mg._frequency.x, mg._frequency.y)
	end
end

local function on_setting(id)
    if id == "frequency_solve_speed" then
        mod._freq_scale = mod._speed_scale("frequency_solve_speed")
    end
    if id == "enable_frequency_auto" and not S("enable_frequency_auto") then
        _freq_cleanup(frequency_active and "setting_changed" or nil)
    end
end

local function on_round_end()
    _freq_cleanup(frequency_active and "round_end" or nil)
end

mod._reg("update",          on_update)
mod._reg("setting_changed", on_setting)
mod._reg("round_end",       on_round_end)

return true
