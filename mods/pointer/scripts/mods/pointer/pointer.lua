local mod = get_mod("pointer")

-- ActionOrderCompanion.fixed_update
-- action_order_companion.lua's start function was used to get pointing code. fixed_update to get explosion

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