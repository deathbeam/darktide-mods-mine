local mod = get_mod("ChemicalAutoStim")

local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

local STIMM_SLOT_NAME = "slot_pocketable_small"
local CHEM_DEP_BUFF = "broker_keystone_chemical_dependency_stack"

local AUTO_STIMM_STAGES = {
    NONE = 0,
    SWITCH_TO = 1,
    WAITING_FOR_INJECT = 2,
    SWITCH_BACK = 3,
}

local last_check_time = 0
local CHECK_INTERVAL = 0.5
local last_injection_time = 0
local auto_stimm_stage = AUTO_STIMM_STAGES.NONE
local current_wield_slot = nil
local unwield_to_slot = nil
local input_request = nil

local function _get_player_unit()
    local player = Managers.player and Managers.player:local_player_safe(1)
    return player and player.player_unit
end

local function _get_gameplay_time()
    return Managers.time and Managers.time:has_timer("gameplay") and Managers.time:time("gameplay") or 0
end

local function _has_chemical_dependency()
    local player_unit = _get_player_unit()
    if not player_unit then return false end
    
    local buff_ext = ScriptUnit.has_extension(player_unit, "buff_system")
    if not buff_ext then return false end
    
    return buff_ext:has_buff_using_buff_template("broker_keystone_chemical_dependency")
end

local function _get_chem_dep_stacks()
    local player_unit = _get_player_unit()
    if not player_unit then return 0, 3 end
    
    local buff_ext = ScriptUnit.has_extension(player_unit, "buff_system")
    if not buff_ext or not buff_ext._stacking_buffs then return 0, 3 end
    
    local buff_instance = buff_ext._stacking_buffs[CHEM_DEP_BUFF]
    if not buff_instance then return 0, 3 end
    
    return buff_instance:stack_count(), buff_instance:max_stacks() or 3
end

local function _has_broker_stim()
    local player_unit = _get_player_unit()
    if not player_unit then return false end
    
    local visual_loadout_ext = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
    if not visual_loadout_ext then return false end
    
    return PlayerUnitVisualLoadout.has_weapon_keyword_from_slot(visual_loadout_ext, STIMM_SLOT_NAME, "pocketable_broker_syringe")
end

local function _can_use_stim()
    local player_unit = _get_player_unit()
    if not player_unit then return false end
    
    local ability_ext = ScriptUnit.has_extension(player_unit, "ability_system")
    if not ability_ext then return false end
    
    return ability_ext:can_use_ability("pocketable_ability")
end

local function _is_weapon_switching()
    local player_unit = _get_player_unit()
    if not player_unit then return false end
    
    local unit_data_ext = ScriptUnit.has_extension(player_unit, "unit_data_system")
    if not unit_data_ext then return false end
    
    local weapon_action_comp = unit_data_ext:read_component("weapon_action")
    if not weapon_action_comp then return false end
    
    local current_action = weapon_action_comp.current_action_name
    return current_action == "action_wield" or current_action == "action_unwield" or 
           current_action == "action_unwield_to_previous" or current_action == "action_unwield_to_specific"
end

local function _is_weapon_template_valid(slot_name)
    if not slot_name then return false end
    
    local player_unit = _get_player_unit()
    if not player_unit then return false end
    
    local visual_loadout_ext = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
    if not visual_loadout_ext then return false end
    
    local success, weapon_template = pcall(function()
        return visual_loadout_ext:weapon_template_from_slot(slot_name)
    end)
    
    return success and weapon_template ~= nil
end

local function _reset_auto_stimm_state()
    auto_stimm_stage = AUTO_STIMM_STAGES.NONE
    input_request = nil
    unwield_to_slot = nil
end

local function _start_auto_inject()
    if not _has_broker_stim() then return false end
    if not _can_use_stim() then return false end
    if _is_weapon_switching() then return false end
    if not _is_weapon_template_valid(STIMM_SLOT_NAME) then return false end
    
    if current_wield_slot == STIMM_SLOT_NAME then
        auto_stimm_stage = AUTO_STIMM_STAGES.WAITING_FOR_INJECT
    else
        if not _is_weapon_template_valid(current_wield_slot) then return false end
        auto_stimm_stage = AUTO_STIMM_STAGES.SWITCH_TO
    end
    
    return true
end

mod.update = function(dt)
    if auto_stimm_stage ~= AUTO_STIMM_STAGES.NONE then
        return
    end
    
    local has_chem_dep = _has_chemical_dependency()
    if not has_chem_dep then
        return
    end
    
    local has_stim = _has_broker_stim()
    if not has_stim then
        return
    end
    
    local current_time = _get_gameplay_time()
    if current_time - last_check_time < CHECK_INTERVAL then
        return
    end
    last_check_time = current_time
    
    local can_use = _can_use_stim()
    if not can_use then
        return
    end
    
    local current_stacks, max_stacks = _get_chem_dep_stacks()
    if current_stacks >= max_stacks then
        return
    end
    
    local time_since_last = current_time - last_injection_time
    if time_since_last < 1.0 then
        return
    end
    
    if _start_auto_inject() then
        last_injection_time = current_time
    end
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name)
    if self._player == Managers.player:local_player(1) then
        current_wield_slot = slot_name
        if auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_BACK then
            if input_request and (not unwield_to_slot or slot_name == unwield_to_slot) then
                _reset_auto_stimm_state()
            end
        elseif auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_TO and slot_name == STIMM_SLOT_NAME then
            auto_stimm_stage = AUTO_STIMM_STAGES.WAITING_FOR_INJECT
        end
    end
end)

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input)
    if _get_player_unit() == self._unit then
        if auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_BACK and (action_name == "action_unwield_to_previous" or action_name == "action_wield") and used_input ~= "quick_wield" then
            input_request = unwield_to_slot == "slot_secondary" and "wield_2"
                or unwield_to_slot == "slot_grenade_ability" and "grenade_ability_pressed"
                or "wield_1"
            unwield_to_slot = input_request == "wield_1" and "slot_primary"
                or input_request == "wield_2" and "slot_secondary"
                or input_request == "grenade_ability_pressed" and "slot_grenade_ability"
                or nil
        elseif action_name == "action_wield" then
            local slot_name = self._inventory_component.wielded_slot
            unwield_to_slot = slot_name ~= STIMM_SLOT_NAME and slot_name or unwield_to_slot
        elseif auto_stimm_stage == AUTO_STIMM_STAGES.WAITING_FOR_INJECT and current_wield_slot == STIMM_SLOT_NAME and action_name == "action_use_self" then
            auto_stimm_stage = AUTO_STIMM_STAGES.SWITCH_BACK
            last_injection_time = _get_gameplay_time()
        end
    end
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    
    return input_request and action_name == input_request
        or auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_TO and action_name == "wield_4"
        or val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" or state_name == "StateGameplay" then
        last_check_time = 0
        last_injection_time = 0
        _reset_auto_stimm_state()
        current_wield_slot = nil
        unwield_to_slot = nil
    end
end
