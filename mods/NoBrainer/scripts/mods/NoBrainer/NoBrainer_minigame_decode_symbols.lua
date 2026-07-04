local mod = get_mod("NoBrainer")
local S = mod._S

local MinigameSettings, DecodeSymbolsViewSettings, UIWidget
local function _deps()
	if not MinigameSettings then
		MinigameSettings = require("scripts/settings/minigame/minigame_settings")
		DecodeSymbolsViewSettings = require("scripts/ui/views/scanner_display_view/scanner_display_view_decode_symbols_settings")
		UIWidget = require("scripts/managers/ui/ui_widget")
	end
end

local PREVIEW_DECODE_MAX_GRID_HEIGHT = 920

local _cached_layout_mg = nil
local _cached_layout = nil
local function _decode_layout(minigame)
	if _cached_layout_mg == minigame and _cached_layout then return _cached_layout end
	_deps()
	local bw = DecodeSymbolsViewSettings.decode_symbol_widget_size
	local bs = DecodeSymbolsViewSettings.decode_symbol_spacing
	local sa = minigame and minigame._stage_amount or MinigameSettings.decode_symbols_stage_amount
	local ips = MinigameSettings.decode_symbols_items_per_stage
	local th = bw[2] * sa + bs * (sa - 1)
	local scale = th > PREVIEW_DECODE_MAX_GRID_HEIGHT and PREVIEW_DECODE_MAX_GRID_HEIGHT / th or 1
	local ws = { bw[1] * scale, bw[2] * scale }
	local sp = bs * scale

	_cached_layout = {
		stage_amount      = sa,
		widget_size       = ws,
		spacing           = sp,
		starting_offset_x = -(ws[1] * ips + sp * (ips - 1)) * 0.5,
		starting_offset_y = -(ws[2] * sa + sp * (sa - 1)) * 0.5,
	}
	_cached_layout_mg = minigame
	return _cached_layout
end

local HIGHLIGHT = { 100, 255, 255, 165 }

local function _ensure_highlight_widgets(view, count, widget_size)
	if count <= 0 then
		view._nb_dh = nil; view._nb_dh_size = nil
		return nil
	end

	local w = view._nb_dh
	local prev_sz = view._nb_dh_size

	if w and #w == count and prev_sz
		and prev_sz[1] == widget_size[1] and prev_sz[2] == widget_size[2]
	then
		return w
	end

	_deps()
	w = {}
	for i = 1, count do
		local def = UIWidget.create_definition({{
			pass_type = "texture", style_id = "highlight",
			value     = "content/ui/materials/backgrounds/scanner/scanner_decode_symbol_highlight",
			style     = { hdr = true, color = HIGHLIGHT },
		}}, "center_pivot", nil, widget_size)
		w[i] = UIWidget.init("nb_dh_" .. i, def)
	end
	view._nb_dh = w
	view._nb_dh_size = { widget_size[1], widget_size[2] }
	return w
end

mod:hook_require("scripts/ui/views/scanner_display_view/minigame_decode_symbols_view", function(View)
	mod:hook_safe(View, "draw_widgets", function(self, dt, t, input_service, ui_renderer)
		if not S("enable_decode_highlight") then return end
		if mod._practice_active and mod._practice_active() then return end
		_deps()
		local ext = self._minigame_extension; if not ext then return end
		local mg = ext:minigame(MinigameSettings.types.decode_symbols); if not mg then return end
		local targets = mg._decode_targets
		if not targets or #targets == 0 then return end

		local stage = mg:current_stage()
		if not stage then return end
		local limit = math.min(#targets, stage + 3)
		local count = limit - stage
		if count <= 0 then
			self._nb_dh = nil; self._nb_dh_size = nil
			return
		end

		local layout = _decode_layout(mg)
		local ws = layout.widget_size

		local w = _ensure_highlight_widgets(self, count, ws)
		if not w then return end

		for i = stage + 1, limit do
			local wi = w[i - stage]
			wi.offset[1] = layout.starting_offset_x + (ws[1] + layout.spacing) * (targets[i] - 1)
			wi.offset[2] = layout.starting_offset_y + (ws[2] + layout.spacing) * (i - 1)
			wi.offset[3] = 5
			wi.style.highlight.color = HIGHLIGHT
			UIWidget.draw(wi, ui_renderer)
		end
	end)
end)

local PRESS_DURATION = 0.08
local RELEASE_DURATION = 0.12
local PRESS_LEAD = 0.095
local PRESS_GRACE = 0.060
local SUBMIT_TIMEOUT = 1.2
local PRIMARY_HOLD_ACTIONS = {
	action_one_hold = true,
	interact_hold = true,
	interact_primary_hold = true,
	jump_held = true,
}

mod._ds_mg = nil
mod._ds_state_mg = nil
mod._ds_submitted_stage = nil
mod._ds_submitted_until = 0
mod._ds_press_until = 0
mod._ds_release_until = 0
local decode_active = false
local decode_completed = false

local function ds_reset(reason)
	if decode_active and reason then
		mod._debug_event("decode", reason, { stage = mod._ds_state_mg and mod._ds_state_mg._current_stage or mod._ds_submitted_stage })
	end

	decode_active = false
	decode_completed = reason == "complete"
	mod._ds_mg = nil
	mod._ds_state_mg = nil
	mod._ds_submitted_stage = nil
	mod._ds_submitted_until = 0
	mod._ds_press_until = 0
	mod._ds_release_until = 0
end

local function game_time()
	return mod._time("gameplay")
end

local function debug_value(value)
	if value == nil then return "nil" end
	return value
end

local function next_center_delta(mg, now, start_time, target, margin)
	local sweep_duration = mg._decode_symbols_sweep_duration
	if not sweep_duration or sweep_duration <= 0 then return nil end

	local period = sweep_duration * 2
	local center = (target - 1) * margin
	local mirror = period - center
	local phase = (now - start_time) % period
	local delta_a = center - phase
	local delta_b = mirror - phase

	if delta_a < -PRESS_GRACE then delta_a = delta_a + period end
	if delta_b < -PRESS_GRACE then delta_b = delta_b + period end

	return math.abs(delta_a) < math.abs(delta_b) and delta_a or delta_b
end

local function should_press_decode(now)
	local mg = mod._ds_mg
	if not mg then
		mod._debug_event_throttle("decode_no_mg_event", 1.5, "decode", "wait", { reason = "no_minigame" })
		return false
	end
	if mg:is_completed() then
		mod._debug_event_change("decode_completed", true, "decode", "wait", { reason = "completed", stage = mg._current_stage })
		return false
	end

	local stage = mg:current_stage()
	local start_time = mg:start_time()
	local targets = mg._decode_targets
	local target = targets and targets[stage]
	local items_per_stage = mg._decode_symbols_items_per_stage
	local sweep_duration = mg._decode_symbols_sweep_duration

	if not stage or not start_time or not target
		or not items_per_stage or items_per_stage <= 1
		or not sweep_duration or sweep_duration <= 0 then
		mod._debug_event_throttle("decode_missing_fields_event", 1.5, "decode", "wait", {
			items = debug_value(items_per_stage),
			reason = "missing_fields",
			server = mg._is_server,
			stage = debug_value(stage),
			start = debug_value(start_time),
			sweep = debug_value(sweep_duration),
			target = debug_value(target),
		})
		return false
	end

	if mod._ds_submitted_stage ~= stage then
		if mod._ds_submitted_stage ~= nil then
			mod._debug_event("decode", "stage_changed", { from = mod._ds_submitted_stage, to = stage })
		end

		mod._ds_submitted_stage = nil
		mod._ds_submitted_until = 0
	elseif now < mod._ds_submitted_until then
		mod._debug_event_throttle("decode_submit_pending_event", 0.75, "decode", "submit_pending", { stage = stage, until_t = mod._ds_submitted_until })
		return false
	end

	local margin = sweep_duration / (items_per_stage - 1)
	local delta = next_center_delta(mg, now, start_time, target, margin)

	if not delta or delta > PRESS_LEAD or delta < -PRESS_GRACE then
		mod._debug_event_throttle("decode_delta_event", 1.0, "decode", "wait", { delta = debug_value(delta), max = PRESS_LEAD, min = -PRESS_GRACE, reason = "outside_window", stage = stage, target = target })
		return false
	end

	mod._debug_event("decode", "press_window", { delta = delta, max = PRESS_LEAD, min = -PRESS_GRACE, server = mg._is_server, stage = stage, target = target, window = "synthetic_press" })
	return true
end

local function submit_decode(now)
	local stage = mod._ds_mg and mod._ds_mg:current_stage()
	mod._ds_submitted_stage = stage
	mod._ds_submitted_until = now + SUBMIT_TIMEOUT
	mod._ds_press_until = now + PRESS_DURATION
	mod._ds_release_until = mod._ds_press_until + RELEASE_DURATION
	mod._debug_event("decode", "submit_state", { press_until = mod._ds_press_until, release_until = mod._ds_release_until, stage = stage, submitted_until = mod._ds_submitted_until })
end

local function looks_like_decode_symbols(minigame)
	return minigame
		and minigame._decode_symbols_sweep_duration ~= nil
		and minigame._decode_symbols_items_per_stage ~= nil
		and minigame._decode_targets ~= nil
end

function mod._ds_input(action, result)
	if not S("enable_decode_auto") then return result end
	if not mod._ds_state_mg then return result end
	if not PRIMARY_HOLD_ACTIONS[action] then return result end

	local now = game_time()
	if not now then return result end

	if mod._ds_release_until > now then
		mod._debug_event_throttle("decode_input_release_event", 1.0, "decode", "synthetic_release", { action = action, stage = mod._ds_submitted_stage, until_t = mod._ds_release_until })
		return false
	end
	if mod._ds_press_until > now then
		mod._debug_event_throttle("decode_input_hold_event", 1.0, "decode", "synthetic_hold", { action = action, stage = mod._ds_submitted_stage, until_t = mod._ds_press_until })
		return true
	end
	if result then return result end
	if not should_press_decode(now) then return result end

	submit_decode(now)
	mod._debug_event("decode", "synthetic_press", { action = action, stage = mod._ds_submitted_stage })
	return true
end

mod:hook_safe("MinigameDecodeSymbols", "start", function(self, player)
	if not mod._is_local_minigame_player(player) then return end

	if S("enable_decode_auto") then
		decode_active = true
		decode_completed = false
		mod._debug_event("decode", "start", { items = debug_value(self._decode_symbols_items_per_stage), server = self._is_server, stage = debug_value(self._current_stage), start = debug_value(self._decode_start_time), sweep = debug_value(self._decode_symbols_sweep_duration) })
	end
end)
mod:hook_safe("MinigameDecodeSymbols", "stop",  function(self) if S("enable_decode_auto") and self == mod._ds_state_mg then ds_reset(decode_active and not decode_completed and "stop" or nil) end end)
mod:hook_safe("MinigameDecodeSymbols", "complete", function(self) if S("enable_decode_auto") and self == mod._ds_state_mg then ds_reset("complete") end end)

local function on_update(dt)
	if not mod._ds_state_mg and mod._ds_submitted_until <= 0 then return end

	local now = game_time()
	local mg = mod._ds_state_mg

	if now and mg and mg._is_server and should_press_decode(now) then
		submit_decode(now)
		mod._debug_event("decode", "server_fallback", { stage = mg._current_stage })
		mg:on_action_pressed(now)
	end

	if now and mod._ds_submitted_until > 0 and now >= mod._ds_submitted_until then
		mod._debug_event("decode", "submit_timeout", { stage = mod._ds_submitted_stage })
		mod._ds_submitted_stage = nil
		mod._ds_submitted_until = 0
	end
end
local function on_round_end() ds_reset(decode_active and "round_end" or nil) end
local function on_setting(id) if id == "enable_decode_auto" then ds_reset(decode_active and "setting_changed" or nil) end end

mod._reg("update", on_update)
mod._reg("round_end", on_round_end)
mod._reg("setting_changed", on_setting)

local function hook_decode_state_input(PlayerCharacterStateMinigame)
	if mod._ds_state_input_hooked then
		return
	end

	mod._ds_state_input_hooked = true

	mod:hook(PlayerCharacterStateMinigame, "_update_input", function(func, self, t, fixed_frame, input_extension)
		if not S("enable_decode_auto") then
			return func(self, t, fixed_frame, input_extension)
		end

		local minigame = self and self._minigame
		local player = self and self._player

		if not mod._is_local_minigame_player(player) then
			return func(self, t, fixed_frame, input_extension)
		end

		if not looks_like_decode_symbols(minigame) then
			return func(self, t, fixed_frame, input_extension)
		end

		if mod._ds_state_mg and mod._ds_state_mg ~= minigame then
			ds_reset(decode_active and "minigame_changed" or nil)
		end

		decode_active = true
		mod._ds_mg = minigame
		mod._ds_state_mg = minigame
		mod._debug_event_throttle("decode_state_hook_event", 1.5, "decode", "state", { held = debug_value(minigame._action_held), server = minigame._is_server, stage = debug_value(minigame._current_stage) })

		local action_one_hold = input_extension:get("action_one_hold")
		local interact_hold = input_extension:get("interact_hold")
		local jump_held = input_extension:get("jump_held")

		if action_one_hold ~= self._previous_action_one_hold then
			self._previous_action_one_hold = action_one_hold
			self._previous_input = action_one_hold
		elseif interact_hold ~= self._previous_interact_hold then
			self._previous_interact_hold = interact_hold
			self._previous_input = interact_hold
		elseif jump_held ~= self._previous_jump_held then
			self._previous_jump_held = jump_held
			self._previous_input = jump_held
		end

		local primary_input = self._previous_input or false
		local action_two_pressed = input_extension:get("action_two_pressed")
		local cancel = action_two_pressed
		local block_weapon_actions = false

		if not self:_is_wielding_minigame_device() then
			return true
		end

		if mod._ds_release_until > t then
			primary_input = false
		elseif mod._ds_press_until > t then
			primary_input = true
		elseif should_press_decode(t) then
			submit_decode(t)
			primary_input = true
		end

		local synthetic_phase = mod._ds_release_until > t and "release"
			or mod._ds_press_until > t and "hold"
			or "passthrough"

		mod._debug_event_change("decode_primary", tostring(primary_input) .. ":" .. synthetic_phase .. ":" .. tostring(minigame._current_stage), "decode", "primary_input", { input = primary_input, phase = synthetic_phase, previous = debug_value(self._previous_input), stage = debug_value(minigame._current_stage) })

		if minigame:uses_action() and minigame:action(primary_input, t) then
			mod._debug_event("decode", "action_accepted", { input = primary_input, phase = synthetic_phase, stage = debug_value(minigame._current_stage) })
			local animation_extension = self._animation_extension

			if animation_extension then
				animation_extension:anim_event_1p("button_press")

				if minigame:is_completed() then
					animation_extension:anim_event_1p("scan_end")
				end
			end
		end

		if minigame:uses_joystick() then
			local move_input = input_extension:get("move") or Vector3.zero()

			minigame:on_axis_set(t, move_input.x or 0, move_input.y or 0)
		end

		cancel = minigame:escape_action(action_two_pressed)
		block_weapon_actions = minigame:blocks_weapon_actions()

		if not cancel and not block_weapon_actions then
			local weapon_extension = self._weapon_extension

			if weapon_extension then
				weapon_extension:update_weapon_actions(fixed_frame)
			end
		end

		return cancel
	end)
end

hook_decode_state_input("PlayerCharacterStateMinigame")

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/player_character_state_minigame", function(PlayerCharacterStateMinigame)
	hook_decode_state_input(PlayerCharacterStateMinigame)
end)

return true
