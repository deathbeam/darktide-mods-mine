local mod = get_mod("NoBrainer")
local S = mod._S
local MinigameSettings = require("scripts/settings/minigame/minigame_settings")

local PRACTICE_VIEW = "nobrainer_practice_view"
local practice_session = nil
local _practice_action_held = false
local _practice_action_name = nil
local _practice_frame_axis_x = 0
local _practice_frame_axis_y = 0

local function _reset_input_state()
	_practice_action_held = false
	_practice_action_name = nil
	_practice_frame_axis_x = 0
	_practice_frame_axis_y = 0
end

local function _register_view()
	mod:add_require_path("NoBrainer/scripts/mods/NoBrainer/NoBrainer_practice_view")
	mod:register_view({
		view_name = PRACTICE_VIEW,
		view_settings = {
			allow_hud = true,
			class = "NoBrainerPracticeView",
			close_on_hotkey_pressed = false,
			disable_game_world = false,
			init_view_function = function() return true end,
			load_always = true,
			load_in_hub = true,
			package = "packages/ui/views/scanner_display_view/scanner_display_view",
			path = "NoBrainer/scripts/mods/NoBrainer/NoBrainer_practice_view",
			state_bound = false,
			use_transition_ui = false,
		},
		view_transitions = {},
		view_options = {
			close_all = false,
			close_previous = false,
		},
	})
	mod:io_dofile("NoBrainer/scripts/mods/NoBrainer/NoBrainer_practice_view")
end

local function _practice_is_allowed()
	local gm = Managers.state and Managers.state.game_mode
	if not gm then return false end
	local name = gm:game_mode_name()
	return name == "hub" or name == "prologue_hub" or name == "training_grounds" or name == "shooting_range"
end

local function _close_practice()
	_reset_input_state()

	local ui = Managers.ui
	if ui then
		if ui:view_active(PRACTICE_VIEW) or ui:is_view_closing(PRACTICE_VIEW) then
			ui:close_view(PRACTICE_VIEW, true)
		end
	end

	practice_session = nil
end

local function _open_practice()
	if not _practice_is_allowed() then
		mod._debug_event("practice", "open_blocked", { reason = "not_allowed" })
		mod:echo(mod:localize("practice_not_allowed"))
		return
	end

	if practice_session then
		_close_practice()
		return
	end

	local ui = Managers.ui
	if not ui then return end
	if ui:view_active(PRACTICE_VIEW) or ui:is_view_closing(PRACTICE_VIEW) then return end

	local minigame_type = S("practice_type") or "decode_symbols"
	local create = mod._practice_create
	if type(create) ~= "function" then return end

	local ext, mg = create(minigame_type)
	if not ext or not mg then mod._debug_event("practice", "open_failed", { ext = tostring(ext), mg = tostring(mg), type = minigame_type }); return end

	local player_manager = Managers.player
	local player = player_manager and player_manager:local_player_safe(1)
	if not player then return end

	mg:setup_game()
	mg:start(player)

	local context = {
		minigame_extension = ext,
		minigame_type = minigame_type,
		auspex_unit = nil,
		device_owner_unit = nil,
	}

	practice_session = {
		minigame_type = minigame_type,
		minigame = mg,
		minigame_extension = ext,
		context = context,
	}

	ui:open_view(PRACTICE_VIEW, nil, false, false, nil, context)
	mod._debug_event("practice", "opened", { type = minigame_type })

	mod:echo(mod:localize("practice_opened", mod:localize("practice_type_" .. minigame_type)))
end

function mod.toggle_practice()
	if not S("enable_practice") then return end
	_open_practice()
end

function mod._practice_active()
	return practice_session ~= nil
end

local function _practice_update(dt)
	local session = practice_session
	if not session then return end

	local ui = Managers.ui
	if not ui or not ui:view_active(PRACTICE_VIEW) then
		_close_practice()
		return
	end

	local mg = session.minigame
	if not mg then return end

	if mg:is_completed() then
		local elapsed = (mod._time("gameplay") or 0) - (mg._practice_start or 0)
		local type_name = mod:localize("practice_type_" .. session.minigame_type)
		mod:echo(string.format("[Practice] Finished %s in %.2f seconds!", type_name, elapsed))
		mod._debug_event("practice", "completed", { elapsed = elapsed, type = session.minigame_type })
		_close_practice()
		return
	end

	if mg.should_exit and mg:should_exit() then
		_close_practice()
		return
	end

	if mg:uses_joystick() then
		local ax, ay = _practice_frame_axis_x, _practice_frame_axis_y
		_practice_frame_axis_x = 0
		_practice_frame_axis_y = 0
		if ax ~= 0 or ay ~= 0 then
		local t = mod._time("gameplay") or 0
		mg:on_axis_set(t, ax, ay)
	end
end

	local t = mod._time("gameplay") or 0
	mg:update(dt, t)
end

function mod._practice_route_input(action, r)
	local session = practice_session
	if not session then return r end
	if not Managers.ui or not Managers.ui:view_active(PRACTICE_VIEW) then return r end

	local mg = session.minigame
	if not mg then return r end

	local t = mod._time("gameplay") or 0

	if mg:uses_action() then
		if action == "interact_hold" or action == "action_one_hold" then
			if r and not _practice_action_held then
				_practice_action_held = true
				_practice_action_name = action
				mg:action(true, t)
			elseif not r and _practice_action_held and action == _practice_action_name then
				_practice_action_held = false
				_practice_action_name = nil
				mg:action(false, t)
			end
		end
	end

	if mg:uses_joystick() then
		if action == "move" and type(r) == "userdata" then
			_practice_frame_axis_x = _practice_frame_axis_x + r.x
			_practice_frame_axis_y = _practice_frame_axis_y + r.y
		elseif action == "move_controller" and type(r) == "userdata" then
			_practice_frame_axis_x = _practice_frame_axis_x + r.x
			_practice_frame_axis_y = _practice_frame_axis_y + r.y
		else
			if action == "move_right" and type(r) == "number" and r > 0 then _practice_frame_axis_x = _practice_frame_axis_x + r end
			if action == "move_left" and type(r) == "number" and r > 0 then _practice_frame_axis_x = _practice_frame_axis_x - r end
			if action == "move_forward" and type(r) == "number" and r > 0 then _practice_frame_axis_y = _practice_frame_axis_y - r end
			if action == "move_backward" and type(r) == "number" and r > 0 then _practice_frame_axis_y = _practice_frame_axis_y + r end
		end
	end

	if action == "action_two_pressed" and r then
		mg:escape_action(true)
	end

	return r
end

local function on_update(dt)
	if practice_session then
		_practice_update(dt)
	end
end

local function on_round_end()
	_close_practice()
end

local function on_setting(id)
	if (id == "practice_type" or id == "enable_practice") and practice_session then
		_close_practice()
	end
end

mod._reg("update", on_update)
mod._reg("round_end", on_round_end)
mod._reg("disabled", _close_practice)
mod._reg("unload", _close_practice)
mod._reg("setting_changed", on_setting)

_register_view()

return true
