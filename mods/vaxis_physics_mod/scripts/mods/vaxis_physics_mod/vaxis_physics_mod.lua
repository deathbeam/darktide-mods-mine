local mod = get_mod("vaxis_physics_mod")

mod.update = function(dt)
    if not Managers.state or not Managers.state.extension then return end
    
    local player_manager = Managers.player
    if not player_manager then return end
    
    local local_player = player_manager:local_player(1)
    if not local_player or not local_player.player_unit then return end
    
    local player_unit = local_player.player_unit

    local unit_data_ext = ScriptUnit.has_extension(player_unit, "unit_data_system")
    if not unit_data_ext then return end
    
    local locomotion_comp = unit_data_ext:read_component("locomotion")
    if not locomotion_comp then return end
    
    local velocity = locomotion_comp.velocity_current
    local speed = Vector3.length(velocity)
    
    if speed < 1.0 then return end
    
    local player_pos = Unit.world_position(player_unit, 1)

    local minion_death_manager = Managers.state.minion_death
    if not minion_death_manager then return end
    
    local minion_ragdoll = minion_death_manager._minion_ragdoll 
    if not minion_ragdoll or not minion_ragdoll._ragdolls then return end

    local ragdolls = minion_ragdoll._ragdolls
    
    
    local push_radius = mod:get("push_radius") or 1.0
    local base_push_force = mod:get("base_push_force") or 10
    
    for i = 1, #ragdolls do
        local ragdoll_unit = ragdolls[i]
        
        if ragdoll_unit and Unit.alive(ragdoll_unit) then
            local hips_node = Unit.has_node(ragdoll_unit, "j_hips") and Unit.node(ragdoll_unit, "j_hips") or 1
            local ragdoll_pos = Unit.world_position(ragdoll_unit, hips_node)
            
            local distance = Vector3.distance(player_pos, ragdoll_pos)
            
           
            if distance <= push_radius then
                
                local push_direction = Vector3.normalize(velocity)
                
                
                local force = push_direction * (base_push_force * speed)
                force.z = base_push_force * 0.2 
                
                local target_unit_data = ScriptUnit.has_extension(ragdoll_unit, "unit_data_system")
                if target_unit_data then
                    local breed = target_unit_data:breed()
                    local hit_zone_pushes = breed and breed.hit_zone_ragdoll_pushes
                    local push_data = hit_zone_pushes and hit_zone_pushes["torso"]
                    
                    if push_data then
                        for actor_name, force_scale in pairs(push_data) do
                            local actor = Unit.actor(ragdoll_unit, actor_name)
                            if actor and Actor.is_dynamic(actor) then
                                pcall(Actor.wake_up, actor)
                                local applied_force = force * force_scale
                                pcall(Actor.add_impulse, actor, applied_force)
                            end
                        end
                    else
                        local hips_actor = Unit.actor(ragdoll_unit, "c_hips")
                        if hips_actor and Actor.is_dynamic(hips_actor) then
                            pcall(Actor.wake_up, hips_actor)
                            pcall(Actor.add_impulse, hips_actor, force)
                        end
                    end
                end
            end
        end
    end
end