local mod = get_mod("pointer")

-- ActionOrderCompanion.fixed_update
-- action_order_companion.lua's start function was used to get pointing code. fixed_update to get explosion

local banned_weapons = {
    "dual_autopistols_p1_m1", -- Hive scum dual auto-pistols
    "dual_stubpistols_p1_m1", -- Hive scum dual stub pistols
    "missile_launcher",       -- Hive Scum rocket launcher
    "saw_p1_m1",              -- Hive scum bone saw (rag clips through hand)
    "powersword_2h_p1_m2"     -- Zealot power sword
}

local function is_banned(name)
    for _, banned_name in ipairs(banned_weapons) do
        if name == banned_name then return true end
    end
    return false
end

mod.last_anim_time = 0

mod.trigger_point_animation = function(self)
    local current_time = Managers.time:time("main")
    local tagging_delay = mod:get("tagging_delay") or 0.0
    -- If not enough time has passed since the last trigger, stop here
    if current_time < (mod.last_anim_time + tagging_delay) then
        return
    end

    local player = Managers.player:local_player(1)
    local player_unit = player and player.player_unit
    if not player_unit or not ALIVE[player_unit] then return end

    local anim_extension = ScriptUnit.has_extension(player_unit, "animation_system")

    -- Check if this weapon is one that the pointing animation is bugged, and stop
    local weapon_extension = ScriptUnit.extension(player_unit, "weapon_system")
    local weapon_template = weapon_extension:weapon_template()
    if weapon_template then
        local weapon_name = weapon_template.name
        -- print(weapon_name)
        if is_banned(weapon_name) then
            return
        end
    end
    
    -- Check if the player is in an action we don't want to play an animation in, like charging or attacking
    if(mod:get("disable_attacking_during_action") == true) then 
        local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
        local weapon_action_component = unit_data_extension:read_component("weapon_action")
        if weapon_action_component.current_action_name ~= "none" then
            return
        end
    end

    -- Play the animation
    if anim_extension then
        local anim_event = "ability_point"
        mod.last_anim_time = current_time
        
        pcall(function()
            anim_extension:anim_event_1p(anim_event)
        end)
    end
end





mod.on_all_mods_loaded = function()
    mod:hook_safe("SmartTag", "init", function(self, tag_id, template, tagger_unit, target_unit, ...)
        local local_player_unit = Managers.player:local_player_safe(1).player_unit
        
        if tagger_unit == local_player_unit then
            if mod:get("point_when_tagging") == true then
                mod.trigger_point_animation()
            end
        end
    end)
end