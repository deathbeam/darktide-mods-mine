--[[
Title: SoloMinigames
Author: SPEED-PRIEST
Date: 08-06-2025
Version: 1.1.0
--]]

local mod = get_mod("SoloMinigames")
-- ================================================================
-- --------------------------- Requires ---------------------------
-- ================================================================
local CorruptorSettings = require("scripts/settings/corruptor/corruptor_settings")
local InteractionSettings = require("scripts/settings/interaction/interaction_settings")
local WorldMarkerTemplateObjective = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_objective")

-- ================================================================
-- -------------------------- Variables ---------------------------
-- ================================================================
local math_huge = math.huge
local interaction_results = InteractionSettings.results

local _minigame_start_time_decoder = math_huge
local _minigame_start_time_marker = math_huge
local _set_minigame_start_time_flag_decoder = false
local _set_minigame_start_time_flag_marker = false

local auto_complete_interaction_types = {
    "default", -- Some doors, Mercantile's first event completion "Retrieve Cypher", Mercantile's final event signal flares
    -- "servo_skull_activator", -- Hab Dreyko's first event - deploying the Servo-skull -- Don't want to auto-complete this one through InteracteeExtension, as it is a bit more complicated
    "setup_breach_charge",
}

mod.settings = mod:persistent_table("settings")
mod.color = { 255, 0, 255, 0 }

-- ================================================================
-- -------------------------- Functions ---------------------------
-- ================================================================
local initialize_settings_cache = function ()
    mod.settings["sm_penalty"] = mod:get("sm_penalty")
    mod.settings["sm_corruptor_arm_difficulty"] = mod:get("sm_corruptor_arm_difficulty")
    mod.settings["sm_completion_color_r"] = mod:get("sm_completion_color_r")
    mod.settings["sm_completion_color_g"] = mod:get("sm_completion_color_g")
    mod.settings["sm_completion_color_b"] = mod:get("sm_completion_color_b")
    mod.update_color()
end

local set_minigame_start_time_decoder = function (t)
    _minigame_start_time_decoder = t + mod.settings["sm_penalty"]
end

local set_minigame_start_time_marker = function (t)
    _minigame_start_time_marker = t + mod.settings["sm_penalty"]
end

local is_server = function ()
    local game_session = Managers.state.game_session
    if not game_session then
        return false
    end
    return game_session:is_server()
end

mod.update_color = function ()
    mod.color = {
        255,
        mod.settings["sm_completion_color_r"],
        mod.settings["sm_completion_color_g"],
        mod.settings["sm_completion_color_b"],
    }
end

mod.on_setting_changed = function (setting_name)
    mod.settings[setting_name] = mod:get(setting_name)
    mod.update_color()
end

mod.on_game_state_changed = function (status, state_name)
    if status == "enter" and state_name == "StateGameplay" then
        _minigame_start_time_decoder = math_huge
        _minigame_start_time_marker = math_huge
        _set_minigame_start_time_flag_decoder = false
        _set_minigame_start_time_flag_marker = false
    end
end

initialize_settings_cache()

-- ================================================================
-- ---------------------------- Hooks -----------------------------
-- ================================================================

-- ---------------------- Completes minigame ----------------------
mod:hook_safe("DecoderSynchronizerExtension", "pause_event", function (self)
    if is_server() then
        _set_minigame_start_time_flag_decoder = true
        _set_minigame_start_time_flag_marker = true
    end
end)

mod:hook_safe("DecoderDeviceExtension", "update", function (self, unit, dt, t)
    if self._is_server and self._decoding_interrupted then
        if _set_minigame_start_time_flag_decoder == true then
            set_minigame_start_time_decoder(t)
            _set_minigame_start_time_flag_decoder = false
        end
    end
end)

mod:hook_safe(WorldMarkerTemplateObjective, "update_function", function (parent, ui_renderer, widget, marker, self, dt, t)
    if is_server() then
        if _set_minigame_start_time_flag_marker == true then
            set_minigame_start_time_marker(t)
            _set_minigame_start_time_flag_marker = false
        end
        if t > _minigame_start_time_marker then
            widget.style.icon.color = mod.color
        end
    end
end)

mod:hook("SetupDecodingInteraction", "start", function (func, self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    if not interactor_is_server then
        return func(self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    end

    local target_unit = unit_data_component.target_unit
    local decoder_device_extension = ScriptUnit.extension(target_unit, "decoder_device_system")

    decoder_device_extension:decoder_setup_success()
end)

mod:hook("DecodingInteraction", "stop", function (func, self, world, interactor_unit, unit_data_component, t, result, interactor_is_server)
    if not interactor_is_server then
        return func(self, world, interactor_unit, unit_data_component, t, result, interactor_is_server)
    end

    if result ~= interaction_results.success then
        return func(self, world, interactor_unit, unit_data_component, t, result, interactor_is_server)
    end

    if result == interaction_results.success then
        if t > _minigame_start_time_decoder then
            local target_unit = unit_data_component.target_unit
            local decoder_device_extension = ScriptUnit.has_extension(target_unit, "decoder_device_system")

            local minigame_extension = decoder_device_extension._minigame_extension
            if minigame_extension then
                local minigame = minigame_extension._minigame
                local minigame_unit = minigame._minigame_unit

                minigame:set_current_stage(minigame._stage_amount)
                -- ^ A crash can occur because Minigames get initialized with _current_stage = nil,
                -- and a comparison may occur between a number and nil as a result

                Unit.flow_event(minigame_unit, "lua_minigame_success_last")
                -- ^ This bit makes certain level animations play (like Hab Dreyko's tree spew!)
                minigame_extension:set_active(false)
                decoder_device_extension._decoder_synchronizer_extension:unblock_decoding_progression()
                _minigame_start_time_decoder = math_huge
                _minigame_start_time_marker = math_huge
            end
        else
            func(self, world, interactor_unit, unit_data_component, t, result, interactor_is_server)
        end
    end
end)

mod:hook("InteracteeExtension", "started", function (func, self, interactor_unit)
    if not self._is_server then
        return func(self, interactor_unit)
    end
    local active_interaction_type = self._active_interaction_type
    -- print("active_interaction_type = " .. active_interaction_type)
    if table.contains(auto_complete_interaction_types, active_interaction_type) then
        self:stopped(interaction_results.success)
    else
        return func(self, interactor_unit)
    end
end)

-- Hab Dreyko's first event - deploying the Servo-skull so that the player may begin scanning
mod:hook("ServoSkullActivatorInteraction", "start", function (func, self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    if not interactor_is_server then
        return func(self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    end
    self:stop(world, interactor_unit, unit_data_component, t, interaction_results.success, interactor_is_server)
end)

-- After completion of a stage in Hab Dreyko's first event - i.e., scanned three things, now player must interact with Servo-skull to progress to next scan location
mod:hook("ServoSkullInteraction", "start", function (func, self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    if not interactor_is_server then
        return func(self, world, interactor_unit, unit_data_component, t, interactor_is_server)
    end
    self:stop(world, interactor_unit, unit_data_component, t, interaction_results.success, interactor_is_server)
end)

-- Gives player more time before corruptor arms move back in to position in corruptor minigame (e.g. end of Smelter Complex)
mod:hook("CorruptorArmExtension", "set_animation_target", function (func, self, target, speed_multiplier_type, optional_hot_join_animation_pos)
    if not self._is_server or speed_multiplier_type ~= "regrowth" then
        return func(self, target, speed_multiplier_type, optional_hot_join_animation_pos)
    end
	local speed_multiplier =  mod.settings["sm_corruptor_arm_difficulty"]

	self._animation_speed_multiplier_type = speed_multiplier_type
	self._animation_target = target
	self._animation_speed = (target - self._animation_pos) / math.lerp(1, self._arm_length, CorruptorSettings.animation_length_impact) * speed_multiplier

	local unit = self._unit

	if optional_hot_join_animation_pos then
		self._animation_pos = optional_hot_join_animation_pos

		Component.event(unit, "set_animation_pos", optional_hot_join_animation_pos)
	end

	if target > 0 then
		Unit.flow_event(unit, "lua_start_extending")
		self:_start_extending()
	else
		Unit.flow_event(unit, "lua_start_retracting")

		if self._is_extending then
			self:_stop_extending()
		end
	end

	if self._is_server then
		local unit_level_index = Managers.state.unit_spawner:level_index(unit)
		local speed_multiplier_type_id = NetworkLookup.corruptor_arm_animation_speed_types[speed_multiplier_type]

		Managers.state.game_session:send_rpc_clients("rpc_set_animation_target", unit_level_index, target, speed_multiplier_type_id)
	end
end)
