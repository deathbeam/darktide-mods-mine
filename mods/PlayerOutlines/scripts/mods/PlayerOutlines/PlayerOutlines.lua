PlayerOutlines = {}
local PO = PlayerOutlines
PO.dmf_mod = get_mod("PlayerOutlines")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
PO.UPDATE_INTERVAL = 0.5
PO.dmf_mod.settings = {}
PO.instances = {}
PO._delayed_outlines = {}
PO._rebuild_outlines_pending = false
PO._rebuild_outlines_delay = 0
PO._next_outline_update_t = 0
PO._last_real_time = 0
PO._hologram_units = {}
PO._body_slots_dirty = {}
PO._unit_outline_state = {}
PO._player_outline_layers = {
    "player_outline_general",
    "player_outline_general_depth",
    "player_outline_knocked_down",
    "player_outline_knocked_down_reversed_depth",
    "player_outline_target",
}
PO._SWITCH_STATES = { consumed = true }
PO._IGNORED_DISABLED_OUTLINE_STATES = { catapulted = true, grabbed = true }
PO.nil_check = function(root, ...)
    local parts = {...}
    local o = root
    for i = 1, #parts do
        if not o[parts[i]] then return nil end
        o = o[parts[i]]
    end
    return o
end
PO.clear_equipment_outlines = function(unit)
    if not unit or not Unit.alive(unit) then return end
    local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
    if not outline_ext or outline_ext._is_local_human then return end
    local visual_loadout = ScriptUnit.has_extension(unit, "visual_loadout_system")
    if not visual_loadout then return end
    local equipment = visual_loadout._equipment
    if not equipment then return end
    local layers = PO._player_outline_layers
    for slot_name, slot in pairs(equipment) do
        if slot.equipped and slot.unit_3p and Unit.alive(slot.unit_3p) then
            for i = 1, #layers do
                Unit.set_material_layer(slot.unit_3p, layers[i], false)
            end
            if slot.attachments_by_unit_3p then
                for _, attachments in pairs(slot.attachments_by_unit_3p) do
                    for j = 1, #attachments do
                        local attachment = attachments[j]
                        if Unit.alive(attachment) then
                            for i = 1, #layers do
                                Unit.set_material_layer(attachment, layers[i], false)
                            end
                        end
                    end
                end
            end
        end
    end
end
PO.apply_outline_color_to_equipment_slots = function(unit, outline_color, material_layers)
    if not unit or not Unit.alive(unit) then return end
    local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
    if not outline_ext or outline_ext._is_local_human then return end
    local visual_loadout = ScriptUnit.has_extension(unit, "visual_loadout_system")
    if not visual_loadout then return end
    local equipment = visual_loadout._equipment
    if not equipment then return end
    for slot_name, slot in pairs(equipment) do
        if slot.equipped and slot.unit_3p and Unit.alive(slot.unit_3p) then
            PO._apply_outline_to_unit_and_attachments(slot.unit_3p, slot, outline_color, material_layers)
        end
    end
end
PO._apply_outline_to_unit_and_attachments = function(unit, slot, outline_color, material_layers)
    if not unit or not material_layers then return end
    for i = 1, #material_layers do
        local layer = material_layers[i]
        if layer and layer ~= "" then
            Unit.set_material_layer(unit, layer, true)
            if outline_color then
                Unit.set_vector3_for_material(unit, layer, "outline_color", Vector3(outline_color[1], outline_color[2], outline_color[3]))
            end
        end
    end
    if slot.attachments_by_unit_3p then
        for _, attachments in pairs(slot.attachments_by_unit_3p) do
            for j = 1, #attachments do
                local attachment = attachments[j]
                if Unit.alive(attachment) then
                    for k = 1, #material_layers do
                        local layer = material_layers[k]
                        if layer and layer ~= "" then
                            Unit.set_material_layer(attachment, layer, true)
                            if outline_color then
                                Unit.set_vector3_for_material(attachment, layer, "outline_color", Vector3(outline_color[1], outline_color[2], outline_color[3]))
                            end
                        end
                    end
                end
            end
        end
    end
end
PO._get_active_outline_data = function(unit)
    if not unit or not Unit.alive(unit) then return nil end
    local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
    if not outline_ext then return nil end
    local extension_data = PO.nil_check(PO.get_outline_system(), "_unit_extension_data")
    if not extension_data then return nil end
    local ext_data = extension_data[unit]
    if not ext_data or not ext_data.outlines or #ext_data.outlines == 0 then return nil end
    local top_outline = ext_data.outlines[1]
    if not top_outline or not top_outline.material_layers then return nil end
    return {
        color = top_outline.color,
        material_layers = top_outline.material_layers,
    }
end
PO.is_in_hub = function()
    return Managers and Managers.state and Managers.state.game_mode and
        Managers.state.game_mode.game_mode_name and
        Managers.state.game_mode:game_mode_name() == "hub"
end
PO.get_outline_system = function()
    local ext = PO.nil_check(Managers, "state", "extension")
    if not ext then return end
    return ext:system("outline_system")
end
PO.spawn_hologram = function(world, resources, parent_unit, state_name)
    if not world or not resources or not parent_unit then return end
    local resource = state_name == "consumed" and resources[state_name] or
        resources.default
    local hologram_unit = World.spawn_unit_ex(world, resource)
    World.link_unit(world, hologram_unit, 1, parent_unit, 1, true)
    Unit.set_unit_culling(hologram_unit, false, true)
    local player_visibility_system = ScriptUnit.has_extension(parent_unit,
        "player_visibility_system")
    if player_visibility_system and not player_visibility_system:visible() then
        Unit.set_unit_visibility(hologram_unit, false, true)
    end
    return hologram_unit
end
PO.despawn_hologram = function(world, hologram_unit)
    if not world or not hologram_unit then return end
    if not Unit.alive(hologram_unit) then return end
    pcall(World.unlink_unit, world, hologram_unit, true)
    pcall(World.destroy_unit, world, hologram_unit)
end
PO._remove_hologram = function(unit)
    if not unit then return end
    local holo_info = PO._hologram_units[unit]
    if holo_info and holo_info.hologram_unit then
        local world = Managers.world and Managers.world:world("level_world")
        if world then
            PO.despawn_hologram(world, holo_info.hologram_unit)
        end
    end
    PO._hologram_units[unit] = nil
end
PO._update_hologram = function(unit, t, is_local_player_unit, player_outlines_enabled, is_in_hub)
    if not unit or not Unit.alive(unit) then
        PO._remove_hologram(unit)
        return
    end
    if ScriptUnit.has_extension(unit, "hologram_system") then
        PO._remove_hologram(unit)
        return
    end
    if is_local_player_unit then
        return
    end
    if not player_outlines_enabled then
        PO._remove_hologram(unit)
        return
    end
    if not PO.dmf_mod.settings["show_hologram"] or
            (is_in_hub and not PO.dmf_mod.settings["show_in_hub"]) then
        PO._remove_hologram(unit)
        return
    end
    local unit_data = ScriptUnit.extension(unit, "unit_data_system")
    local character_state = unit_data:read_component("character_state")
    local state_name = character_state.state_name
    if state_name == "dead" then
        PO._remove_hologram(unit)
        return
    end
    local health_ext = ScriptUnit.has_extension(unit, "health_system")
    if not health_ext then
        PO._remove_hologram(unit)
        return
    end
    local SWITCH_STATES = PO._SWITCH_STATES
    local holo_info = PO._hologram_units[unit]
    local should_switch = false
    if holo_info and holo_info.hologram_unit and Unit.alive(holo_info.hologram_unit) then
        local current_state = holo_info.current_spawned_state
        if SWITCH_STATES[state_name] and current_state ~= state_name then
            should_switch = true
        elseif SWITCH_STATES[current_state] and not SWITCH_STATES[state_name] then
            should_switch = true
        end
    end
    local world = Managers.world and Managers.world:world("level_world")
    if not world then return end
    if not holo_info or not holo_info.hologram_unit or not Unit.alive(holo_info.hologram_unit) or should_switch then
        if holo_info and holo_info.hologram_unit then
            PO.despawn_hologram(world, holo_info.hologram_unit)
        end
        local breed = unit_data:breed()
        local resources = breed.hologram_units
        local resource = SWITCH_STATES[state_name] and resources[state_name] or resources.default
        local hologram_unit = World.spawn_unit_ex(world, resource)
        World.link_unit(world, hologram_unit, 1, unit, 1, true)
        Unit.set_unit_culling(hologram_unit, false, true)
        local player_visibility_system = ScriptUnit.has_extension(unit, "player_visibility_system")
        if player_visibility_system and not player_visibility_system:visible() then
            Unit.set_unit_visibility(hologram_unit, false, true)
        end
        PO._hologram_units[unit] = {
            hologram_unit = hologram_unit,
            current_spawned_state = state_name,
            health_percent = 1,
            was_disabled = false,
        }
        holo_info = PO._hologram_units[unit]
    end
    local health_percent = health_ext:current_health_percent()
    local is_disabled = PlayerUnitStatus.is_disabled(character_state) and not PO._IGNORED_DISABLED_OUTLINE_STATES[state_name]
    if health_percent ~= holo_info.health_percent or is_disabled ~= holo_info.was_disabled then
        local shader_input = 1
        if not is_disabled then
            shader_input = 1 - health_percent
        end
        Unit.set_scalar_for_materials(holo_info.hologram_unit, "health_value", shader_input, false)
        holo_info.health_percent = health_percent
        holo_info.was_disabled = is_disabled
    end
end
PO.selected_outline_name = function()
    local show_outline = PO.dmf_mod.settings["show_outline"]
    local show_mesh = PO.dmf_mod.settings["show_mesh"]
    if show_outline then
        if show_mesh then return "default_both_always" end
        return "default_outlines_always"
    end
    return show_mesh and "default_mesh_always" or nil
end
PO.clear_outlines = function(unit)
    if not unit or not Unit.alive(unit) then return end
    local outline_sys = PO.get_outline_system()
    if not outline_sys then return end
    local ext_data = PO.nil_check(outline_sys, "_unit_extension_data")
    if not ext_data then return end
    if ext_data[unit] then
        outline_sys:remove_all_outlines(unit)
    end
    PO.clear_equipment_outlines(unit)
    PO._unit_outline_state[unit] = nil
end
PO.update_outline = function(ext, unit)
    if not unit or not Unit.alive(unit) then return end
    local outline_sys = ext._outline_system
    if not outline_sys then return end
    local added_outline = ext._added_disabled_outline
    local is_disabled = PlayerUnitStatus.is_disabled(
        ext._character_state_component)
    if is_disabled and not added_outline then
        outline_sys:add_outline(unit, "knocked_down")
        ext._added_disabled_outline = true
    elseif added_outline and not is_disabled then
        outline_sys:remove_outline(unit, "knocked_down")
        ext._added_disabled_outline = false
    end
    if not ext._is_local_human then
        local outline_name = PO.selected_outline_name()
        if outline_name then
            local outline_data = PO._get_active_outline_data(unit)
            local cached = PO._unit_outline_state[unit]
            local color_unchanged = false
            if outline_data and cached and cached.outline_name == outline_name and cached.color and outline_data.color then
                local c = outline_data.color
                color_unchanged = c[1] == cached.color[1] and c[2] == cached.color[2] and c[3] == cached.color[3]
            end
            if not color_unchanged then
                outline_sys:add_outline(unit, outline_name)
                outline_data = PO._get_active_outline_data(unit)
                if outline_data then
                    PO.apply_outline_color_to_equipment_slots(unit, outline_data.color, outline_data.material_layers)
                    local c = outline_data.color
                    PO._unit_outline_state[unit] = {
                        outline_name = outline_name,
                        color = c and { c[1], c[2], c[3] } or nil,
                    }
                else
                    PO._unit_outline_state[unit] = { outline_name = outline_name, color = nil }
                end
            end
        else
            PO.clear_outlines(unit)
        end
    end
end
PO.clear_all_outlines = function()
    if not Managers.player then return end
    for _, player in pairs(Managers.player:players()) do
        local unit = player.player_unit
        if unit and Unit.alive(unit) then
            PO.clear_outlines(unit)
        end
        PO._remove_hologram(unit)
    end
    table.clear(PO._body_slots_dirty)
end
PO._apply_outline_to_current_outlines = function(unit)
    if not unit or not Unit.alive(unit) then return end
    local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
    if not outline_ext or outline_ext._is_local_human then return end
    local outline_data = PO._get_active_outline_data(unit)
    if not outline_data then return end
    PO.apply_outline_color_to_equipment_slots(unit, outline_data.color, outline_data.material_layers)
end
PO.update_settings_cache = function()
    PO.dmf_mod.settings["assist_marker_max_distance"] = PO.dmf_mod:get("assist_marker_max_distance")
    PO.dmf_mod.settings["mission_nameplates_max_distance"] = PO.dmf_mod:get("mission_nameplates_max_distance")
    PO.dmf_mod.settings["show_hologram"] = PO.dmf_mod:get("show_hologram")
    PO.dmf_mod.settings["show_in_hub"] = PO.dmf_mod:get("show_in_hub")
    PO.dmf_mod.settings["show_mesh"] = PO.dmf_mod:get("show_mesh")
    PO.dmf_mod.settings["show_outline"] = PO.dmf_mod:get("show_outline")
end
PO.update_settings_cache()
PO._delayed_apply_outline = function(unit, t)
    if not unit or not Unit.alive(unit) then return end
    PO._unit_outline_state[unit] = nil
    PO._delayed_outlines[unit] = t + 0.2
end

PO._check_delayed_outlines = function(t)
    for unit, execute_t in pairs(PO._delayed_outlines) do
        if t >= execute_t then
            PO._delayed_outlines[unit] = nil
            if Unit.alive(unit) then
                local outline_data = PO._get_active_outline_data(unit)
                if outline_data then
                    PO.apply_outline_color_to_equipment_slots(unit, outline_data.color, outline_data.material_layers)
                end
            end
        end
    end
end

PO._cleanup_stale_state = function()
    local active_units = {}

    if Managers.player then
        for _, player in pairs(Managers.player:players()) do
            local unit = player.player_unit
            if unit then
                active_units[unit] = true
            end
        end
    end

    for unit, _ in pairs(PO._delayed_outlines) do
        if not active_units[unit] then
            PO._delayed_outlines[unit] = nil
        end
    end

    for unit, _ in pairs(PO._unit_outline_state) do
        if not active_units[unit] then
            PO._unit_outline_state[unit] = nil
        end
    end

    for unit, _ in pairs(PO._hologram_units) do
        if not active_units[unit] then
            PO._remove_hologram(unit)
        end
    end

    for unit, _ in pairs(PO._body_slots_dirty) do
        if not active_units[unit] then
            PO._body_slots_dirty[unit] = nil
        end
    end
end
PO._rebuild_all_outlines = function()
    PO.clear_all_outlines()
    PO._rebuild_outlines_pending = true
    PO._rebuild_outlines_delay = 0.05
end
PO._check_rebuild_outlines = function(t)
    if PO._rebuild_outlines_pending then
        PO._rebuild_outlines_delay = PO._rebuild_outlines_delay - PO.UPDATE_INTERVAL
        if PO._rebuild_outlines_delay <= 0 then
            PO._rebuild_outlines_pending = false
            local players = Managers.player and Managers.player:players()
            if players then
                for _, player in pairs(players) do
                    local unit = player.player_unit
                    if unit and Unit.alive(unit) then
                        local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
                        if outline_ext then
                            PO.update_outline(outline_ext, unit)
                        end
                    end
                end
            end
        end
    end
end
PO.dmf_mod:hook_origin("GameModeManager", "disable_hologram", function()
    return false
end)
PO.dmf_mod:hook("OutlineSystem", "update", function(func, self, context, dt, t)
    func(self, context, dt, t)

    local real_t = Managers.time:time("main")
    if real_t < PO._last_real_time + PO.UPDATE_INTERVAL then
        return
    end
    PO._last_real_time = real_t
    PO._check_delayed_outlines(t)
    PO._check_rebuild_outlines(t)
    PO._cleanup_stale_state()
    if not Managers.player then return end
    local is_in_hub = PO.is_in_hub()
    local local_player = Managers.player:local_player()
    local local_player_unit = local_player and local_player.player_unit
    local player_outlines_enabled = nil
    local save_data = Managers.save and Managers.save:account_data()
    if save_data and save_data.interface_settings then
        player_outlines_enabled = save_data.interface_settings.player_outlines
    end
    for _, player in pairs(Managers.player:players()) do
        local unit = player.player_unit
        if unit and Unit.alive(unit) then
            local outline_ext = ScriptUnit.has_extension(unit, "outline_system")
            if outline_ext then
                if is_in_hub and not PO.dmf_mod.settings["show_in_hub"] then
                    PO.clear_outlines(unit)
                else
                    PO.update_outline(outline_ext, unit)
                end
            end
            local visual_loadout = ScriptUnit.has_extension(unit, "visual_loadout_system")
            if visual_loadout then
                if not PO._body_slots_dirty[unit] then
                    PO._force_show_body_slots(visual_loadout)
                else
                    PO._body_slots_dirty[unit] = nil
                end
            end
            PO._update_hologram(unit, t, unit == local_player_unit, player_outlines_enabled, is_in_hub)
        end
    end
end)
PO.dmf_mod:hook("PlayerUnitHologramExtension", "update", function(func, self, unit, dt, t)
    if not PO.dmf_mod.settings["show_hologram"] or
            (PO.is_in_hub() and not PO.dmf_mod.settings["show_in_hub"]) then
        if self._hologram_unit then
            PO.despawn_hologram(self._world, self._hologram_unit)
            self._hologram_unit = nil
        end
        return
    end
    func(self, unit, dt, t)
end)
PO.dmf_mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_player_assistance", function(instance)
    PO.instances.wmt_player_assistance = instance
    PO.dmf_mod.on_setting_changed("assist_marker_max_distance")
end)
PO.dmf_mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_combat", function(instance)
    PO.instances.wmt_nameplate_combat = instance
    PO.dmf_mod.on_setting_changed("mission_nameplates_max_distance")
end)
PO.dmf_mod:hook_safe("PlayerUnitOutlineExtension", "extensions_ready", function(self, world, unit)
    if self._is_local_human then return end
    local outline_name = PO.selected_outline_name()
    if outline_name then
        self._outline_system:add_outline(unit, outline_name)
    end
    PO._apply_outline_to_current_outlines(unit)
end)
PO.dmf_mod:hook_safe("PlayerUnitVisualLoadoutExtension", "_equip_item_to_slot", function(self, item, slot_name, t, optional_existing_unit_3p, from_server_correction_occurred)
    local unit = self._unit
    if not unit or not Unit.alive(unit) then return end
    PO._delayed_apply_outline(unit, t)
end)
PO.dmf_mod:hook_safe("PlayerUnitVisualLoadoutExtension", "_unequip_item_from_slot", function(self, slot_name, from_server_correction_occurred, fixed_frame, from_destroy)
    local unit = self._unit
    if not unit or not Unit.alive(unit) then return end
    PO._delayed_apply_outline(unit, 0)
end)
PO._body_slots = {
    slot_body_torso = true,
    slot_body_arms = true,
    slot_body_legs = true,
    slot_body_face = true,
    slot_body_hair = true,
}
PO.dmf_mod:hook("PlayerUnitVisualLoadoutExtension", "_update_item_visibility", function(func, self, first_person_mode)
    func(self, first_person_mode)
    PO._force_show_body_slots(self)
    local unit = self._unit
    if unit then PO._body_slots_dirty[unit] = true end
end)
PO._force_show_body_slots = function(self)
    if not PO.dmf_mod.settings["show_outline"] and not PO.dmf_mod.settings["show_mesh"] then
        return
    end
    local equipment = self._equipment
    if not equipment then return end
    for slot_name, _ in pairs(PO._body_slots) do
        local slot = equipment[slot_name]
        if slot and slot.unit_3p and Unit.alive(slot.unit_3p) then
            Unit.set_unit_visibility(slot.unit_3p, true, true)
        end
    end
end
PO.dmf_mod.on_setting_changed = function(setting_id)
    PO.update_settings_cache()
    if setting_id == "show_hologram"
                or setting_id == "show_mesh"
                or setting_id == "show_outline"
                or setting_id == "show_in_hub" then
            table.clear(PO._body_slots_dirty)
            PO._rebuild_all_outlines()
            if setting_id == "show_hologram" or setting_id == "show_in_hub" then
                for _, player in pairs(Managers.player:players()) do
                    PO._remove_hologram(player.player_unit)
                end
            end
        elseif setting_id == "mission_nameplates_max_distance" and
                PlayerOutlines.instances.wmt_nameplate_combat then
            PlayerOutlines.instances.wmt_nameplate_combat.max_distance =
                PO.dmf_mod.settings["mission_nameplates_max_distance"]
        elseif setting_id == "assist_marker_max_distance" and
                PlayerOutlines.instances.wmt_player_assistance then
            PlayerOutlines.instances.wmt_player_assistance.max_distance =
                PO.dmf_mod.settings["assist_marker_max_distance"]
        end
end
PO.dmf_mod.on_unload = PlayerOutlines.clear_all_outlines
