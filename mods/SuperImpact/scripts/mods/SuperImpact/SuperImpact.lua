local mod = get_mod("SuperImpact")
--[[
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│ Mod Name: Super Impact                                                                    │
│ Mod Description: Amplifies impact force applied to enemies on death                       │
│ Mod Author: Seph (Steam: Concoction of Constitution)                                      │
└───────────────────────────────────────────────────────────────────────────────────────────┘
--]]
mod:hook("MinionRagdoll", "create_ragdoll", function(f, s, death_data)
    local strength = mod:get("power")
    local AD = death_data.attack_direction:unbox()
    local DV = Vector3Box(AD[1]*strength, AD[2]*strength, AD[3]*strength)
    death_data.death_velocity = DV
    --mod:dtf(death_data, "dump", 6)
    return f(s, death_data)
end)