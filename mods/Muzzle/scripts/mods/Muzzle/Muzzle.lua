local mod = get_mod("Muzzle")

local MOD = {
    ENABLED = true,
    FOCUS = false,
}

mod.on_enabled = function()
    MOD.ENABLED = true
end

mod.on_disabled = function()
    MOD.ENABLED = false
end

mod.on_all_mods_loaded = function()
    MOD.ENABLED = mod:get("ENABLED")
    MOD.FOCUS = mod:get("FOCUS")
end

mod.on_setting_changed = function(setting_id)
    if MOD[setting_id] ~= nil then
        MOD[setting_id] = mod:get(setting_id)
    end
end

mod.has_aggro_target = function(unit)
    local game_session = Managers.state.game_session and Managers.state.game_session:game_session()
    local game_object_id = Managers.state.unit_spawner and Managers.state.unit_spawner:game_object_id(unit)
    local target_unit_id = game_object_id and game_session and GameSession.game_object_field(game_session, game_object_id, "target_unit_id")
    local target_unit = target_unit_id and Managers.state.unit_spawner:unit(target_unit_id)
    return target_unit and true or false
end

mod:hook(CLASS.SmartTagSystem, "set_tag", function(func, self, template_name, tagger_unit, target_unit, target_location)
    if not MOD.ENABLED then
        return func(self, template_name, tagger_unit, target_unit, target_location)
    end
    -- Templates
    local non_standard_names = {
        enemy_over_here_veteran = true,
        enemy_companion_target = true,
        servo_skull_enemy_companion_target = true
    }
    local standard_name = "enemy_over_here"

    -- Breeds
    local daemonhost = {
        chaos_daemonhost = true,
        chaos_mutator_daemonhost = true,
    }
    local bomber = "chaos_poxwalker_bomber"

    -- Replacement
    if non_standard_names[template_name] then
        if template_name == "enemy_over_here_veteran" and not MOD.FOCUS then
            return func(self, template_name, tagger_unit, target_unit, target_location)
        end
        local breed
        local aggro
        if target_unit then
            breed = ScriptUnit.has_extension(target_unit, "unit_data_system") and ScriptUnit.extension(target_unit, "unit_data_system"):breed()
            aggro = mod.has_aggro_target(target_unit)
        end
        
        if breed then
            if (daemonhost[breed.name] and not aggro) or (breed.name == bomber) then
                return func(self, standard_name, tagger_unit, target_unit, target_location)
            end
        end
    end
    return func(self, template_name, tagger_unit, target_unit, target_location)
end)