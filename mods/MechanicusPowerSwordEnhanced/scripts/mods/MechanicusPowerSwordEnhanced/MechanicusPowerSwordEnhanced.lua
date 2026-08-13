---@class MechanicusPowerSwordEnhanced:DMFMod
local mod = get_mod("MechanicusPowerSwordEnhanced")

local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

---@class MechanicusPowerSwordEnhancedModSettings
local mod_settings = {
    toggle_mode = mod:get("toggle_mode"),
    deactivate_on_depleted = mod:get("deactivate_on_depleted"),
    deactivate_on_wield = mod:get("deactivate_on_wield"),
    deactivate_on_combo = mod:get("deactivate_on_combo"),
    always_toggle_on = mod:get("always_toggle_on"),
    vanilla_enhanced = mod:get("vanilla_enhanced"),
}

local MECHANICUS_POWERSOWRD_WEAPON_NAMES = {
    powersword_p3_m1 = true,
}

local special_activated = false
local remaining_combo = 0

local weapon_action_component = nil
local slot_primary_component = nil

local function get_player_data_extension()
    local player = Managers.player:local_player_safe(1)
    return player and ScriptUnit.extension(player.player_unit, "unit_data_system")
end

local function init_components(player_data_extension)
    player_data_extension = player_data_extension or get_player_data_extension()
    if not player_data_extension then
        return
    end

    weapon_action_component = player_data_extension:read_component("weapon_action")
    slot_primary_component = player_data_extension:read_component("slot_primary")
end

local function reset_components()
    weapon_action_component = nil
    slot_primary_component = nil
end

local function init_context()
    init_components()
end

local function reset_context()
    special_activated = false
    remaining_combo = 0
end

local destroy_references = function()
    reset_components()
end

local conflict_setting_ids = {
    vanilla_enhanced = true,
    toggle_mode = true,
}
local function handle_conflict_settings(setting_id, result)
    if not conflict_setting_ids[setting_id] or not result then
        return
    end

    for conflict_setting_id, _ in pairs(conflict_setting_ids) do
        if conflict_setting_id ~= setting_id then
            mod:set(conflict_setting_id, false, true)
        end
    end
end

local function init_conflict_settings()
    for setting_id, _ in pairs(conflict_setting_ids) do
        handle_conflict_settings(setting_id, mod_settings[setting_id])
    end
end


mod.on_enabled = function()
    init_conflict_settings()
    init_context()
end

mod.on_disabled = function()
    reset_context()
    destroy_references()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "GameplayStateRun" then
        if status == "enter" then
            -- Nothing
        elseif status == "exit" then
            reset_context()
        end
    end
end

mod.on_setting_changed = function(setting_id)
    local result = mod:get(setting_id)
    mod_settings[setting_id] = result
    handle_conflict_settings(setting_id, result)
end

local function get_raw_input(input_service, action_name)
    local action_rule = input_service._actions[action_name]
    local result = action_rule.default_func()
    local combiner = input_service.ACTION_TYPES[action_rule.type].combine_func
    for _, cb in ipairs(action_rule.callbacks) do
        result = combiner(result, cb())
    end
    return result
end

mod:hook(CLASS.InputService, "_get",
    function(func, self, action_name)
        local result = func(self, action_name)
        local weapon_name = weapon_action_component and weapon_action_component.template_name
        if not MECHANICUS_POWERSOWRD_WEAPON_NAMES[weapon_name] then
            return result
        end

        if action_name == "action_one_pressed" then
            if mod_settings.vanilla_enhanced then
                local weapon_template = WeaponTemplates[weapon_name]
                local current_action_name = weapon_action_component and weapon_action_component.current_action_name
                local action_settings = weapon_template and weapon_template.actions[current_action_name]
                local action_kind = action_settings and action_settings.kind
                if action_kind == "block" then
                    local weapon_extra_pressed = func(self, "weapon_extra_pressed") or get_raw_input(self, "weapon_extra_pressed")
                    return result or weapon_extra_pressed
                end
            end
        elseif action_name == "action_one_hold" then
            local weapon_template = WeaponTemplates[weapon_name]
            local current_action_name = weapon_action_component and weapon_action_component.current_action_name
            local action_settings = weapon_template and weapon_template.actions[current_action_name]
            local action_kind = action_settings and action_settings.kind
            local num_special_charges = slot_primary_component and slot_primary_component.num_special_charges or 0
            if mod_settings.toggle_mode then
                if action_kind == "windup" and not action_settings.activate_special_during_windup then
                    return result
                end
                if special_activated and num_special_charges >= 1 then
                    if action_kind == "block" or action_kind == "push" then
                        local action_two_hold = func(self, "action_two_hold")
                        if not action_two_hold then
                            return false
                        end
                    else
                        return false
                    end
                end
            elseif mod_settings.vanilla_enhanced then
                local weapon_extra_hold = func(self, "weapon_extra_hold")
                if action_kind == "block" or action_kind == "push" then
                    local action_two_hold = func(self, "action_two_hold")
                    if action_two_hold then
                        return result or weapon_extra_hold
                    elseif num_special_charges < 1 then
                        return result or weapon_extra_hold
                    end
                elseif action_kind == "windup" and not action_settings.activate_special_during_windup then
                    return result or weapon_extra_hold
                else
                    if num_special_charges < 1 then
                        return result or weapon_extra_hold
                    end
                end
            end
        elseif action_name == "weapon_extra_hold" then
            if mod_settings.toggle_mode then
                local weapon_template = WeaponTemplates[weapon_name]
                local current_action_name = weapon_action_component and weapon_action_component.current_action_name
                local action_settings = weapon_template and weapon_template.actions[current_action_name]
                local action_kind = action_settings and action_settings.kind
                local action_one_hold = func(self, "action_one_hold")
                if action_kind == "windup" and action_settings.activate_special_during_windup then
                    return action_one_hold
                end
                local num_special_charges = slot_primary_component and slot_primary_component.num_special_charges or 0
                if special_activated and num_special_charges >= 1 then
                    if action_kind == "block" or action_kind == "push" then
                        local action_two_hold = func(self, "action_two_hold")
                        if not action_two_hold then
                            return action_one_hold
                        end
                    else
                        return action_one_hold
                    end
                end
                return false
            end
        elseif action_name == "weapon_extra_pressed" then
            if mod_settings.toggle_mode then
                local weapon_extra_pressed = result or get_raw_input(self, "weapon_extra_pressed")
                if weapon_extra_pressed then
                    if special_activated then
                        if not mod_settings.always_toggle_on then
                            special_activated = false
                        end
                    else
                        if slot_primary_component and slot_primary_component.num_special_charges >= 1 then
                            special_activated = true
                            remaining_combo = mod_settings.deactivate_on_combo
                        end
                    end
                end
            end
            return false
        end
        return result
    end)


local SPECIAL_OFF_VFX_ALIAS = "weapon_special_end"
local SPECIAL_OFF_SFX_ALIAS = "weapon_special_end"
local INVENTORY_EVENT_POWER_OFF = "special_disabled"
local INVENTORY_EVENT_POWER_ON = "special_enabled"
local SOUND_PARAMETER_NAME = "power_resource"
mod:hook_safe(CLASS.PowerSwordP3Effects, "init",
    function(self, context, slot, weapon_template, fx_sources, item, unit_1p, unit_3p)
        local owner_unit = context.owner_unit
        local player = Managers.player:local_player_safe(1)
        local player_unit = player and player.player_unit
        if player_unit and owner_unit == player_unit then
            self._is_player_1 = true
        end
    end)

mod:hook(CLASS.PowerSwordP3Effects, "_update_active",
    function(func, self)
        local weapon_name = weapon_action_component and weapon_action_component.template_name
        if mod_settings.toggle_mode and self._is_player_1 and MECHANICUS_POWERSOWRD_WEAPON_NAMES[weapon_name] then
            local is_active = self._is_active
            local special_active = self._inventory_slot_component.special_active
            local weapon_template = WeaponTemplates[weapon_name]
            local current_action_name = weapon_action_component and weapon_action_component.current_action_name
            local action_settings = weapon_template and weapon_template.actions[current_action_name]
            local action_kind = action_settings and action_settings.kind
            if action_kind ~= "windup" and action_kind ~= "sweep" then
                special_active = special_active or special_activated and slot_primary_component and slot_primary_component.num_special_charges >= 1
            end
            local current_playing_id = self._looping_playing_id
            local should_start = not current_playing_id and not is_active and special_active
            local should_stop = current_playing_id and is_active and not special_active

            if not self._emit_fx_running then
                self:_start_emit_vfx_loop()
            end

            if should_start then
                self:_start_sfx_loop()
                self:_start_vfx_loop()
                PlayerUnitVisualLoadout.slot_flow_event(self._first_person_extension, self._visual_loadout_extension, self._slot_name, INVENTORY_EVENT_POWER_ON)
                self:_set_charge_level(1)
            elseif should_stop then
                self:_stop_sfx_loop()
                self:_stop_vfx_loop()
                self:_play_single_sfx(SPECIAL_OFF_SFX_ALIAS, self._special_active_fx_source_name)
                self:_play_single_vfx(SPECIAL_OFF_VFX_ALIAS, self._special_active_fx_source_name)
                PlayerUnitVisualLoadout.slot_flow_event(self._first_person_extension, self._visual_loadout_extension, self._slot_name, INVENTORY_EVENT_POWER_OFF)
                self:_set_charge_level(0)
            end

            if special_active then
                local source = self._fx_extension:sound_source(self._special_active_fx_source_name)

                WwiseWorld.set_source_parameter(self._wwise_world, source, SOUND_PARAMETER_NAME, 20)
            end

            self._is_active = special_active
        else
            return func(self)
        end
    end)

mod:hook_safe(CLASS.WeaponSpecialCooldownCharges, "on_special_activation",
    function(self, t)
        if self._unit_data_extension._player.viewport_name ~= 'player1' then
            return
        end

        if mod_settings.deactivate_on_combo > 0 then
            remaining_combo = remaining_combo - 1
            if remaining_combo <= 0 then
                special_activated = false
            end
        end
    end)

local function on_action_start(id, action_name, action_settings)
    if id == "weapon_action" then
        if mod_settings.toggle_mode and weapon_action_component and MECHANICUS_POWERSOWRD_WEAPON_NAMES[weapon_action_component.template_name] then
            if mod_settings.deactivate_on_wield and action_name == "action_wield" then
                special_activated = false
            end
        end
    end
end

local function on_action_finish(id, previous_action_name)
    if id == "weapon_action" then
        if mod_settings.toggle_mode and mod_settings.deactivate_on_depleted and weapon_action_component and MECHANICUS_POWERSOWRD_WEAPON_NAMES[weapon_action_component.template_name] and slot_primary_component and slot_primary_component.num_special_charges < 1 then
            special_activated = false
        end
    end
end

mod:hook_safe(CLASS.ActionHandler, "start_action",
    function(self, id, action_objects, action_name, action_params, action_settings, used_input, t, transition_type,
             condition_func_params, automatic_input, reset_combo_override)
        if self._unit_data_extension._player.viewport_name ~= 'player1' then
            return
        end

        on_action_start(id, action_name, action_settings)
    end)

mod:hook_safe(CLASS.ActionHandler, "server_correction_occurred",
    function(self, id, action_objects, action_params, actions)
        if self._unit_data_extension._player.viewport_name ~= 'player1' then
            return
        end

        local handler_data = self._registered_components[id]
        local component = handler_data.component
        local current_action_name = component.current_action_name
        if current_action_name == "none" then
            local previous_action_name = component.previous_action_name
            on_action_finish(id, previous_action_name)
        end
    end)

mod:hook_safe(CLASS.ActionHandler, "_finish_action",
    function(self, handler_data, reason, data, t, next_action_params, condition_func_params)
        if self._unit_data_extension._player.viewport_name ~= 'player1' then
            return
        end

        local id = handler_data.id
        local component = handler_data.component
        local previous_action_name = component.previous_action_name
        on_action_finish(id, previous_action_name)
    end)

mod:hook_safe(CLASS.PlayerUnitDataExtension, "init",
    function(self)
        if self._player.viewport_name == "player1" then
            init_components(self)
        end
    end)

mod:hook_safe(CLASS.PlayerUnitDataExtension, "destroy",
    function(self)
        if self._player.viewport_name == "player1" then
            reset_components()
        end
    end)
