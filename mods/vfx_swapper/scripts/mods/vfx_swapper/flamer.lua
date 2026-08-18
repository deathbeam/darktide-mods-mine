local mod = get_mod("vfx_swapper")

local _replace_purgator_vfx = nil
-- local _replace_zealot_flamer_vfx = nil
local _kill_flamer_vfx = nil

mod.refresh_flamer_vfx = function()
    _replace_purgator_vfx = mod:get("purgator_vfx")
    -- _replace_zealot_flamer_vfx = mod:get("flamer_swap")
    _kill_flamer_vfx = mod:get("kill_flamer_vfx")
end

mod.refresh_flamer_vfx()
-- ============================================================================
-- Purgator VFX (ServoSkull)
-- ============================================================================

local CompanionServoSkullFlamerSettings = require("scripts/settings/companion/companion_servo_skull_flamer_settings")
local skull_vfx = CompanionServoSkullFlamerSettings.vfx
local servo_skull_effect = require("scripts/settings/fx/effect_templates/companion_servo_skull_flamer")
local orig_skull_update = servo_skull_effect.update

mod.update_purgator_vfx = function()
	if _replace_purgator_vfx then
		CompanionServoSkullFlamerSettings.vfx.flamer_particle = "content/fx/particles/weapons/rifles/player_flamer/flamer_code_control_burst"
	else
		CompanionServoSkullFlamerSettings.vfx.flamer_particle = "content/fx/particles/abilities/cryptic/companion_servo_skull_flamer_code_control"
	end
end

mod.update_purgator_vfx()

servo_skull_effect.update = function(template_data, template_context, dt, t)
    local current_particle = skull_vfx.flamer_particle
    if template_data._last_particle and template_data._last_particle ~= current_particle then
        if template_data.stream_effect_id then
            World.stop_spawning_particles(template_context.world, template_data.stream_effect_id)
            template_data.stream_effect_id = nil
        end
        template_data._burst_create_time = nil
    end
    template_data._last_particle = current_particle

    if current_particle == "content/fx/particles/weapons/rifles/player_flamer/flamer_code_control_burst" then
        if not template_data._burst_create_time then
            template_data._burst_create_time = t
        end
        local elapsed = t - template_data._burst_create_time
        if elapsed > 2 and template_data.stream_effect_id then
            World.stop_spawning_particles(template_context.world, template_data.stream_effect_id)
            template_data.stream_effect_id = nil
            template_data._burst_create_time = t
        end
    end

    return orig_skull_update(template_data, template_context, dt, t)
end





-- ============================================================================
-- Flamer/inferno swap
-- ============================================================================

-- local _original_values = {}

-- local FlamerTemplate = require("scripts/settings/equipment/weapon_templates/flamers/flamer_p1_m1")
-- local flamer_burst_fx = FlamerTemplate.actions.action_shoot.fx
-- local flamer_stream_fx = FlamerTemplate.actions.action_shoot_braced.fx


-- local InfernoTemplate = require("scripts/settings/equipment/weapon_templates/force_staffs/forcestaff_p2_m1")
-- local inferno_burst_fx = InfernoTemplate.actions.action_shoot_flame.fx
-- local inferno_stream_fx = InfernoTemplate.actions.action_shoot_charged_flame.fx


-- _original_values.flamer_burst_stream_name      = flamer_burst_fx.stream_effect.name
-- _original_values.flamer_burst_stream_name_3p   = flamer_burst_fx.stream_effect.name_3p
-- _original_values.flamer_burst_impact           = flamer_burst_fx.impact_effect
-- _original_values.flamer_stream_stream_name     = flamer_stream_fx.stream_effect.name
-- _original_values.flamer_stream_stream_name_3p  = flamer_stream_fx.stream_effect.name_3p
-- _original_values.flamer_stream_impact          = flamer_stream_fx.impact_effect
-- _original_values.inferno_burst_stream_name     = inferno_burst_fx.stream_effect.name
-- _original_values.inferno_burst_stream_name_3p  = inferno_burst_fx.stream_effect.name_3p
-- _original_values.inferno_burst_impact          = inferno_burst_fx.impact_effect
-- _original_values.inferno_stream_stream_name    = inferno_stream_fx.stream_effect.name
-- _original_values.inferno_stream_stream_name_3p = inferno_stream_fx.stream_effect.name_3p
-- _original_values.inferno_stream_impact         = inferno_stream_fx.impact_effect

mod.swap_flamer_vfx = function()
    if mod:get("flamer_swap") then
        flamer_burst_fx.stream_effect.name     = _original_values.inferno_burst_stream_name
        flamer_burst_fx.stream_effect.name_3p  = _original_values.inferno_burst_stream_name_3p
        flamer_burst_fx.impact_effect          = _original_values.inferno_burst_impact
        flamer_stream_fx.stream_effect.name    = _original_values.inferno_stream_stream_name
        flamer_stream_fx.stream_effect.name_3p = _original_values.inferno_stream_stream_name_3p
        flamer_stream_fx.impact_effect         = _original_values.inferno_stream_impact
    else
        flamer_burst_fx.stream_effect.name     = _original_values.flamer_burst_stream_name
        flamer_burst_fx.stream_effect.name_3p  = _original_values.flamer_burst_stream_name_3p
        flamer_burst_fx.impact_effect          = _original_values.flamer_burst_impact
        flamer_stream_fx.stream_effect.name    = _original_values.flamer_stream_stream_name
        flamer_stream_fx.stream_effect.name_3p = _original_values.flamer_stream_stream_name_3p
        flamer_stream_fx.impact_effect         = _original_values.flamer_stream_impact
    end
end
mod.swap_inferno_vfx = function()
    if _replace_zealot_flamer_vfx then
        inferno_burst_fx.stream_effect.name     = _original_values.flamer_burst_stream_name
        inferno_burst_fx.stream_effect.name_3p  = _original_values.flamer_burst_stream_name_3p
        inferno_burst_fx.impact_effect          = _original_values.flamer_burst_impact
        inferno_stream_fx.stream_effect.name    = _original_values.flamer_stream_stream_name
        inferno_stream_fx.stream_effect.name_3p = _original_values.flamer_stream_stream_name_3p
        inferno_stream_fx.impact_effect         = _original_values.flamer_stream_impact
    else
        inferno_burst_fx.impact_effect          = _original_values.inferno_burst_impact
        inferno_burst_fx.stream_effect.name     = _original_values.inferno_burst_stream_name
        inferno_burst_fx.stream_effect.name_3p  = _original_values.inferno_burst_stream_name_3p
        inferno_stream_fx.impact_effect         = _original_values.inferno_stream_impact
        inferno_stream_fx.stream_effect.name    = _original_values.inferno_stream_stream_name
        inferno_stream_fx.stream_effect.name_3p = _original_values.inferno_stream_stream_name_3p
    end
end

-- mod.swap_inferno_vfx()
-- mod.swap_flamer_vfx()





local Action = require("scripts/utilities/action/action")
-- local function swap_flamer(self, dt, t)
--     -- if not _replace_zealot_flamer_vfx then 
--     --     return 
--     -- end
--     local weapon_action_component = self._weapon_action_component
--     local action_settings = ActionAction.current_action_settings_from_component(weapon_action_component, self._weapon_actions)
--     if not action_settings then 
--         return 
--     end
--     local has_fire_configuration = action_settings and (action_settings.fire_configurations or action_settings.fire_configuration)
--     if has_fire_configuration then
--         -- if not _replace_zealot_flamer_vfx then 
--         -- if mod:get("kill_flamer_vfx") then
--         --     self:_destroy_effects(true, rotation)
--         --     self:_update_moving_lingering_effects(dt, t)
--         --     self:_update_impact_effects(dt, t)
--         --     return 
--         -- end
--         if mod:get("kill_flamer_vfx") then
--             self:_destroy_effects(true, rotation)
--             self:_update_moving_lingering_effects(dt, t)
--             self:_update_impact_effects(dt, t)
--             self._stop_looping_sfx_event
--             return 
--         end
--         -- else
--         --     local effects = action_settings.fx
--         --     if effects and effects.stream_effect then
--         --         local stream_effect = effects.stream_effect
--         --         if stream_effect.name_3p == "content/fx/particles/weapons/rifles/player_flamer/flamer_code_control_3p" then
--         --             stream_effect.name_3p = "content/fx/particles/weapons/flame_staff/psyker_flame_staff_code_control_3p"
--         --         end
--         --         if stream_effect.name == "content/fx/particles/weapons/rifles/player_flamer/flamer_code_control" then
--         --             stream_effect.name = "content/fx/particles/weapons/flame_staff/psyker_flame_staff_code_control"
--         --         end
--         --     end
--         -- end
--     else
-- 		self:_destroy_effects(true, rotation)
-- 	end
-- 	self:_update_moving_lingering_effects(dt, t)
-- 	self:_update_impact_effects(dt, t)
-- end
mod:hook("FlamerGasEffects", "_update_effects", function(func, self, dt, t)
    if not _kill_flamer_vfx then
        return func(self, dt, t)
    end
    -- Only compute these when we actually need them
    local weapon_action_component = self._weapon_action_component
    local action_settings = Action.current_action_settings_from_component(weapon_action_component, self._weapon_actions)
    local has_fire_configuration = action_settings and (action_settings.fire_configurations or action_settings.fire_configuration)
    if has_fire_configuration then
        -- Compute rotation only when destroying effects
        local fx_source_name = self._fx_source_name
        local spawner_pose = self._fx_extension:vfx_spawner_pose(fx_source_name)
        local from_pos = Matrix4x4.translation(spawner_pose)
        local first_person_rotation = self._first_person_component.rotation
        local max_length = self._action_flamer_gas_component.range
        local direction = Vector3.normalize(Vector3.multiply(Quaternion.forward(first_person_rotation), max_length))
        local rotation = Quaternion.look(direction)
        self:_destroy_effects(true, rotation)
        self:_update_moving_lingering_effects(dt, t)
        self:_update_impact_effects(dt, t)
    else
        return func(self, dt, t)
    end
end)