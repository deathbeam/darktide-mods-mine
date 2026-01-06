local mod = get_mod("machine_gods_beacon")

local DARKNESS_MUTATOR = "mutator_darkness_los"
local VENTILATION_MUTATOR = "mutator_ventilation_purge_los"
local DARKNESS_THEME = "darkness"
local VENTILATION_THEME = "ventilation_purge"

local _state = mod:persistent_table("state", {
    is_darkness_mission = false,
    is_ventilation_mission = false,
    in_mission = false,
    hooks_called = {},
    original_themes = nil,
    themes_cleared = false,
    light_groups_cache = {},
    original_extension_weights = {},
    intended_light_states = {},
})

if not _state.flicker then _state.flicker = {} end
if not _state.flicker.active_flickers then _state.flicker.active_flickers = {} end
if not _state.flicker.cooldowns then _state.flicker.cooldowns = {} end
if not _state.flicker.last_cycle_time then _state.flicker.last_cycle_time = 0 end
if not _state.flicker.stutter_state then _state.flicker.stutter_state = {} end
if not _state.flicker.cascade_waves then _state.flicker.cascade_waves = {} end
if not _state.flicker.cascade_next_time then _state.flicker.cascade_next_time = 0 end
if not _state.flicker.sorted_lights_cache then _state.flicker.sorted_lights_cache = nil end
if not _state.flicker.last_sort_time then _state.flicker.last_sort_time = 0 end

local _timer = 0
local _flicker_time = 0
local _perf_batch_size = 10

local function log(fmt, ...)
    if mod:get("debug_mode") then
        mod:echo("[MGB] " .. string.format(fmt, ...))
    end
end

local function get_system(name)
    local ext = Managers.state and Managers.state.extension
    return ext and ext:system(name)
end

local function get_circumstance_template()
    local cm = Managers.state and Managers.state.circumstance
    return cm and cm.template and cm:template()
end

local function is_in_mission_or_training()
    if not Managers.state or not Managers.state.game_mode then return false end
    local gsm = Managers.state.game_mode
    local mode = gsm:game_mode_name()
    return mode == "coop_complete_objective" or mode == "training_grounds" or mode == "shooting_range"
end

local function update_mission_state()
    local template = get_circumstance_template()
    if not template then return end
    local theme = template.theme_tag
    _state.is_darkness_mission = theme == DARKNESS_THEME
    _state.is_ventilation_mission = theme == VENTILATION_THEME
    if template.mutators then
        for _, mutator in pairs(template.mutators) do
            if mutator == DARKNESS_MUTATOR then _state.is_darkness_mission = true end
            if mutator == VENTILATION_MUTATOR then _state.is_ventilation_mission = true end
        end
    end
end

local function should_block_darkness()
    return mod:get("disable_darkness")
end

local function should_block_fog()
    return mod:get("disable_fog")
end

local function should_control_lights()
    return mod:get("enable_light_control")
end

local function is_special_mission()
    return _state.is_darkness_mission or _state.is_ventilation_mission
end

local function should_apply_lighting()
    if is_special_mission() then
        return mod:get("opt_in_special_missions")
    end
    return true
end

local function should_apply_fog_darkness()
    if not is_special_mission() then return false end
    return mod:get("opt_in_special_missions")
end

local function get_light_percentage()
    return mod:get("light_percentage") / 100.0
end

local function get_light_state()
    return mod:get("light_state") or "static"
end

local function get_flicker_default()
    return mod:get("flicker_default") or "on"
end

local function is_flicker_mode()
    local state = get_light_state()
    return state == "flicker" or state == "flicker_cascade" or state == "flicker_random"
end

local function get_flicker_interval()
    return mod:get("flicker_interval") or 5.0
end

local function get_flicker_percentage()
    return (mod:get("flicker_percentage") or 10) / 100.0
end

local function get_flicker_duration()
    return mod:get("flicker_duration") or 0.5
end

local function get_flicker_cooldown()
    return mod:get("flicker_cooldown") or 3.0
end

local function get_stutter_count_for_light()
    local base = mod:get("stutter_count") or 3
    return base + math.random(0, 3)
end

local function get_stutter_interval()
    return get_flicker_duration() / 4
end

local function get_cascade_delay()
    return 0.03
end

local function record_intended_group_state(light_group_name, is_enabled)
    if _state.intended_light_states[light_group_name] == nil then
        _state.intended_light_states[light_group_name] = is_enabled
        log("recorded intended state: %s = %s", light_group_name, tostring(is_enabled))
    end
end

local function get_intended_light_states_count()
    local count = 0
    for _ in pairs(_state.intended_light_states) do count = count + 1 end
    return count
end

local function is_light_assigned_on(group_name, index)
    local cache = _state.light_groups_cache[group_name]
    if not cache or not cache.indices then return true end
    return cache.indices[index] == true
end

local function clear_flicker_caches()
    local flicker = _state.flicker
    if flicker then
        flicker.sorted_lights_cache = nil
        flicker.sorted_on = nil
        flicker.sorted_off = nil
        flicker.last_sort_time = 0
    end
end

local function reset_all_lights(enabled)
    local light_sys = get_system("light_controller_system")
    if not light_sys or not light_sys._light_group_extensions then return false end
    for _, extensions in pairs(light_sys._light_group_extensions) do
        for _, ext in ipairs(extensions) do
            pcall(function() ext:set_enabled(enabled, true) end)
        end
    end
    return true
end

local function apply_light_settings()
    if not _state.in_mission then return end
    if not should_apply_lighting() then return end
    if not should_control_lights() then return end

    local light_sys = get_system("light_controller_system")
    if not light_sys or not light_sys._light_group_extensions then return end

    clear_flicker_caches()

    local percentage = get_light_percentage()
    local selection_mode = mod:get("light_selection")

    if percentage >= 1.0 then
        reset_all_lights(true)
        for group_name, extensions in pairs(light_sys._light_group_extensions) do
            if not _state.light_groups_cache[group_name] then _state.light_groups_cache[group_name] = {} end
            local cache = _state.light_groups_cache[group_name]
            cache.indices = {}
            cache.keep_on = #extensions
            cache.mode = selection_mode
            cache.total = #extensions
            for i = 1, #extensions do cache.indices[i] = true end
        end
        log("lights: 100pct ON")
        return
    end

    if percentage <= 0 then
        reset_all_lights(false)
        for group_name, extensions in pairs(light_sys._light_group_extensions) do
            if not _state.light_groups_cache[group_name] then _state.light_groups_cache[group_name] = {} end
            local cache = _state.light_groups_cache[group_name]
            cache.indices = {}
            cache.keep_on = 0
            cache.mode = selection_mode
            cache.total = #extensions
        end
        log("lights: 0pct OFF")
        return
    end

    reset_all_lights(true)

    local total_on, total_lights = 0, 0

    for group_name, extensions in pairs(light_sys._light_group_extensions) do
        local group_total = #extensions
        local keep_on = math.max(0, math.min(group_total, math.floor(group_total * percentage + 0.5)))
        total_lights = total_lights + group_total
        total_on = total_on + keep_on

        if not _state.light_groups_cache[group_name] then
            _state.light_groups_cache[group_name] = {}
        end

        local cache = _state.light_groups_cache[group_name]
        local need_recache = not cache.indices or cache.keep_on ~= keep_on or cache.mode ~= selection_mode or cache.total ~= group_total

        if need_recache then
            cache.indices = {}
            cache.keep_on = keep_on
            cache.mode = selection_mode
            cache.total = group_total

            if selection_mode == "random" then
                local shuffled = {}
                for i = 1, group_total do shuffled[i] = i end
                for i = group_total, 2, -1 do
                    local j = math.random(i)
                    shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
                end
                for i = 1, keep_on do
                    cache.indices[shuffled[i]] = true
                end
            elseif selection_mode == "alternating" then
                local count = 0
                local idx = 1
                while count < keep_on and idx <= group_total do
                    cache.indices[idx] = true
                    count = count + 1
                    idx = idx + 2
                end
                idx = 2
                while count < keep_on and idx <= group_total do
                    cache.indices[idx] = true
                    count = count + 1
                    idx = idx + 2
                end
            elseif selection_mode == "spread" then
                if keep_on >= group_total then
                    for i = 1, group_total do cache.indices[i] = true end
                elseif keep_on > 0 then
                    local step = group_total / keep_on
                    for i = 0, keep_on - 1 do
                        local idx = math.floor(i * step + step / 2) + 1
                        idx = math.max(1, math.min(group_total, idx))
                        cache.indices[idx] = true
                    end
                end
            else
                for i = 1, keep_on do cache.indices[i] = true end
            end
        end

        for i, ext in ipairs(extensions) do
            if not cache.indices[i] then
                pcall(function() ext:set_enabled(false, true) end)
            end
        end
    end

    log("lights: %d/%d [%s]", total_on, total_lights, selection_mode)
end

local function reset_shading_to_default()
    local sys = get_system("shading_environment_system")
    if not sys then return false end
    if _state.original_themes and #_state.original_themes > 0 then
        pcall(function() sys:on_theme_changed(_state.original_themes, true) end)
        return true
    end
    return false
end

local function store_original_extension_weights()
    local sys = get_system("shading_environment_system")
    if not sys or not sys._unit_to_extension_map then return end
    for unit, ext in pairs(sys._unit_to_extension_map) do
        local name = ext._shading_environment_resource_name
        if name and not _state.original_extension_weights[name] then
            _state.original_extension_weights[name] = { base_weight = ext._base_weight, current_weight = ext._current_weight }
        end
    end
end

local function restore_extension_weights()
    local sys = get_system("shading_environment_system")
    if not sys or not sys._unit_to_extension_map then return end
    for unit, ext in pairs(sys._unit_to_extension_map) do
        local name = ext._shading_environment_resource_name
        if name and _state.original_extension_weights[name] then
            local orig = _state.original_extension_weights[name]
            if orig.base_weight then ext._base_weight = orig.base_weight end
            if orig.current_weight then ext._current_weight = orig.current_weight end
        end
    end
end

local function restore_light_states()
    local light_sys = get_system("light_controller_system")
    if not light_sys or not light_sys._light_group_extensions then return end

    local intended_count = get_intended_light_states_count()
    log("restore: intended_states=%d persisted=%s", intended_count, tostring(intended_count > 0))

    if intended_count == 0 then
        log("restore: no intended states recorded, turning all lights OFF")
        reset_all_lights(off)
        return
    end

    local on_count, off_count = 0, 0
    for group_name, extensions in pairs(light_sys._light_group_extensions) do
        local intended_enabled = _state.intended_light_states[group_name]
        if intended_enabled ~= nil then
            for _, ext in ipairs(extensions) do
                pcall(function() ext:set_enabled(intended_enabled, true) end)
                if intended_enabled then on_count = on_count + 1 else off_count = off_count + 1 end
            end
        else
            for _, ext in ipairs(extensions) do
                pcall(function() ext:set_enabled(true, true) end)
                on_count = on_count + 1
            end
        end
    end
    log("restore: %d on %d off", on_count, off_count)
end

local function get_lights_by_assignment(want_assigned_on)
    local light_sys = get_system("light_controller_system")
    if not light_sys or not light_sys._light_group_extensions then return {} end
    local lights = {}
    for group_name, extensions in pairs(light_sys._light_group_extensions) do
        for i, ext in ipairs(extensions) do
            local assigned_on = is_light_assigned_on(group_name, i)
            if assigned_on == want_assigned_on then
                table.insert(lights, { key = group_name .. ":" .. i, group = group_name, index = i, ext = ext, assigned_on = assigned_on })
            end
        end
    end
    return lights
end

local function get_sorted_lights_by_assignment(want_assigned_on, current_time)
    local flicker = _state.flicker
    local cache_key = want_assigned_on and "sorted_on" or "sorted_off"

    if flicker[cache_key] and (current_time - flicker.last_sort_time) < 0.5 then
        return flicker[cache_key]
    end

    local lights = get_lights_by_assignment(want_assigned_on)
    table.sort(lights, function(a, b)
        if a.group == b.group then return a.index < b.index end
        return a.group < b.group
    end)

    flicker[cache_key] = lights
    flicker.last_sort_time = current_time
    return lights
end

local function apply_fog_settings()
    if not _state.in_mission then return end
    if not is_special_mission() then return end
    if not should_apply_fog_darkness() then return end

    local sys = get_system("shading_environment_system")
    if not sys then return end

    store_original_extension_weights()

    local block_dark = should_block_darkness()
    local block_fog = should_block_fog()

    log("fog: block_dark=%s block_fog=%s themes=%s cleared=%s", tostring(block_dark), tostring(block_fog), tostring(_state.original_themes ~= nil), tostring(_state.themes_cleared))

    if not block_dark and not block_fog then
        restore_extension_weights()
        if _state.themes_cleared and _state.original_themes then
            log("themes: restoring")
            pcall(function() sys:on_theme_changed(_state.original_themes, true) end)
            _state.themes_cleared = false
        end
        return
    end

    if (block_dark or block_fog) and not _state.themes_cleared then
        pcall(function() sys:on_theme_changed({}, true) end)
        _state.themes_cleared = true
        log("themes: cleared")
    end
end

local function revert_fog_settings()
    if not _state.in_mission then return end
    restore_extension_weights()
    if _state.themes_cleared and _state.original_themes then
        reset_shading_to_default()
        _state.themes_cleared = false
    end
    log("fog: reverted")
end

local function revert_light_settings()
    if not _state.in_mission then return end
    restore_light_states()
    log("lights: reverted")
end

local function process_stutter(current_time, light_sys)
    local flicker = _state.flicker
    local stutter_interval = get_stutter_interval()
    local keys_done = {}

    for key, stutter in pairs(flicker.stutter_state or {}) do
        if current_time >= stutter.next_toggle then
            local group_name, idx_str = string.match(key, "(.+):(%d+)")
            local idx = tonumber(idx_str)
            if group_name and idx then
                local extensions = light_sys._light_group_extensions[group_name]
                if extensions and extensions[idx] then
                    stutter.is_on = not stutter.is_on
                    pcall(function() extensions[idx]:set_enabled(stutter.is_on, true) end)
                    stutter.toggles_remaining = stutter.toggles_remaining - 1
                    stutter.next_toggle = current_time + stutter_interval

                    if stutter.toggles_remaining <= 0 then
                        local restore_state = is_light_assigned_on(group_name, idx)
                        pcall(function() extensions[idx]:set_enabled(restore_state, true) end)
                        table.insert(keys_done, key)
                        flicker.cooldowns[key] = current_time + get_flicker_cooldown()
                    end
                end
            end
        end
    end

    for _, key in ipairs(keys_done) do
        flicker.stutter_state[key] = nil
    end
end

local function process_active_flickers(current_time, light_sys)
    local flicker = _state.flicker
    local cooldown = get_flicker_cooldown()
    local keys_to_remove = {}

    for key, flicker_end_time in pairs(flicker.active_flickers or {}) do
        if current_time >= flicker_end_time then
            local group_name, idx_str = string.match(key, "(.+):(%d+)")
            local idx = tonumber(idx_str)
            if group_name and idx then
                local extensions = light_sys._light_group_extensions[group_name]
                if extensions and extensions[idx] then
                    local restore_state = is_light_assigned_on(group_name, idx)
                    pcall(function() extensions[idx]:set_enabled(restore_state, true) end)
                end
            end
            table.insert(keys_to_remove, key)
            flicker.cooldowns[key] = current_time + cooldown
        end
    end
    for _, key in ipairs(keys_to_remove) do flicker.active_flickers[key] = nil end
end

local function start_light_flicker(light, current_time, use_stutter)
    local flicker = _state.flicker
    local duration = get_flicker_duration()
    local flicker_to_state = not light.assigned_on

    if use_stutter then
        local stutter_cycles = get_stutter_count_for_light()
        flicker.stutter_state[light.key] = { is_on = light.assigned_on, toggles_remaining = stutter_cycles * 2, next_toggle = current_time }
    else
        pcall(function() light.ext:set_enabled(flicker_to_state, true) end)
        flicker.active_flickers[light.key] = current_time + duration
    end
end

local function is_light_available(light, current_time)
    local flicker = _state.flicker
    local cd = flicker.cooldowns and flicker.cooldowns[light.key]
    local in_active = flicker.active_flickers and flicker.active_flickers[light.key]
    local in_stutter = flicker.stutter_state and flicker.stutter_state[light.key]
    return (not cd or current_time >= cd) and not in_active and not in_stutter
end

local function get_eligible_lights(current_time)
    local target_assigned_on = get_flicker_default() == "on"
    local lights = get_sorted_lights_by_assignment(target_assigned_on, current_time)
    local eligible = {}
    for _, light in ipairs(lights) do
        if is_light_available(light, current_time) then
            table.insert(eligible, light)
        end
    end
    return eligible
end

local function trigger_flicker_all(current_time, use_stutter)
    local eligible = get_eligible_lights(current_time)
    for _, light in ipairs(eligible) do
        start_light_flicker(light, current_time, use_stutter)
    end
end

local function trigger_flicker_random(current_time, use_stutter)
    local eligible = get_eligible_lights(current_time)
    if #eligible == 0 then return end

    local flicker_count = math.max(1, math.floor(#eligible * get_flicker_percentage() + 0.5))

    for i = #eligible, 2, -1 do
        local j = math.random(i)
        eligible[i], eligible[j] = eligible[j], eligible[i]
    end

    for i = 1, math.min(flicker_count, #eligible) do
        start_light_flicker(eligible[i], current_time, use_stutter)
    end
end

local function spawn_cascade_wave(start_index, total_lights)
    local flicker = _state.flicker
    local half = math.floor(total_lights / 2)
    table.insert(flicker.cascade_waves, { index = start_index, end_index = total_lights, spawn_at = start_index + half, spawned = false })
end

local function update_cascade(current_time, use_stutter)
    local flicker = _state.flicker
    local target_assigned_on = get_flicker_default() == "on"
    local sorted = get_sorted_lights_by_assignment(target_assigned_on, current_time)
    local total = #sorted

    if total == 0 then return end
    if current_time < flicker.cascade_next_time then return end

    if #flicker.cascade_waves == 0 then
        spawn_cascade_wave(1, total)
        flicker.cascade_next_time = current_time
    end

    local waves_to_add = {}
    local waves_to_remove = {}
    local triggered_count = 0
    local max_per_tick = _perf_batch_size

    for i, wave in ipairs(flicker.cascade_waves) do
        if triggered_count >= max_per_tick then break end

        local light = sorted[wave.index]
        if light and is_light_available(light, current_time) then
            start_light_flicker(light, current_time, use_stutter)
            triggered_count = triggered_count + 1
        end

        if not wave.spawned and wave.index >= wave.spawn_at then
            wave.spawned = true
            table.insert(waves_to_add, { start = 1, total = total })
        end

        wave.index = wave.index + 1
        if wave.index > wave.end_index then
            table.insert(waves_to_remove, i)
        end
    end

    for i = #waves_to_remove, 1, -1 do
        table.remove(flicker.cascade_waves, waves_to_remove[i])
    end

    for _, new_wave in ipairs(waves_to_add) do
        spawn_cascade_wave(new_wave.start, new_wave.total)
    end

    if triggered_count > 0 or #flicker.cascade_waves > 0 then
        flicker.cascade_next_time = current_time + get_cascade_delay()
    end
end

local function trigger_new_flickers(current_time)
    local flicker = _state.flicker
    local interval = get_flicker_interval()
    local light_state = get_light_state()
    local use_stutter = mod:get("enable_stutter")

    if light_state == "flicker_cascade" then
        update_cascade(current_time, use_stutter)
        return
    end

    if current_time - (flicker.last_cycle_time or 0) < interval then return end
    flicker.last_cycle_time = current_time

    if light_state == "flicker" then
        trigger_flicker_all(current_time, use_stutter)
    elseif light_state == "flicker_random" then
        trigger_flicker_random(current_time, use_stutter)
    end
end

local function update_flicker_system(current_time)
    if not _state.in_mission then return end
    if not should_apply_lighting() then return end
    if not is_flicker_mode() or not should_control_lights() then return end

    local light_sys = get_system("light_controller_system")
    if not light_sys or not light_sys._light_group_extensions then return end

    local flicker = _state.flicker
    if not flicker then return end

    process_stutter(current_time, light_sys)
    process_active_flickers(current_time, light_sys)
    trigger_new_flickers(current_time)
end

local function stop_all_flickers()
    local light_sys = get_system("light_controller_system")
    local flicker = _state.flicker
    if not flicker then return end

    if light_sys and light_sys._light_group_extensions then
        for key, _ in pairs(flicker.active_flickers or {}) do
            local group_name, idx_str = string.match(key, "(.+):(%d+)")
            local idx = tonumber(idx_str)
            if group_name and idx then
                local extensions = light_sys._light_group_extensions[group_name]
                if extensions and extensions[idx] then
                    local restore_state = is_light_assigned_on(group_name, idx)
                    pcall(function() extensions[idx]:set_enabled(restore_state, true) end)
                end
            end
        end
        for key, _ in pairs(flicker.stutter_state or {}) do
            local group_name, idx_str = string.match(key, "(.+):(%d+)")
            local idx = tonumber(idx_str)
            if group_name and idx then
                local extensions = light_sys._light_group_extensions[group_name]
                if extensions and extensions[idx] then
                    local restore_state = is_light_assigned_on(group_name, idx)
                    pcall(function() extensions[idx]:set_enabled(restore_state, true) end)
                end
            end
        end
    end

    flicker.active_flickers = {}
    flicker.cooldowns = {}
    flicker.last_cycle_time = 0
    flicker.stutter_state = {}
    flicker.cascade_waves = {}
    flicker.cascade_next_time = 0
    flicker.sorted_lights_cache = nil
    flicker.sorted_on = nil
    flicker.sorted_off = nil
    flicker.last_sort_time = 0
end

local function is_dominated_theme(themes)
    if not themes then return false end
    for _, theme in ipairs(themes) do
        local t = type(theme) == "string" and string.lower(theme) or ""
        if t == DARKNESS_THEME or t == VENTILATION_THEME or string.find(t, "dark") or string.find(t, "fog") or string.find(t, "vent") then
            return true
        end
    end
    return false
end

local function should_block_in_hook()
    if not is_in_mission_or_training() then return false end
    update_mission_state()
    if not is_special_mission() then return false end
    if not mod:get("opt_in_special_missions") then return false end
    return should_block_darkness() or should_block_fog()
end

mod:hook(CLASS.ShadingEnvironmentSystem, "on_theme_changed", function(func, self, themes, force_reset, ...)
    _state.hooks_called["ShadingEnvironmentSystem.on_theme_changed"] = true
    if themes and #themes > 0 then _state.original_themes = themes end

    if is_dominated_theme(themes) and should_block_in_hook() then
        log("hook: theme_changed blocked")
        return func(self, {}, force_reset, ...)
    end
    return func(self, themes, force_reset, ...)
end)

mod:hook(CLASS.ShadingEnvironmentSystem, "on_gameplay_post_init", function(func, self, level, themes, ...)
    _state.hooks_called["ShadingEnvironmentSystem.on_gameplay_post_init"] = true
    if themes and #themes > 0 then _state.original_themes = themes end

    if is_in_mission_or_training() then
        _state.in_mission = true
        update_mission_state()
    end

    if is_dominated_theme(themes) and should_block_in_hook() then
        log("hook: gameplay_init blocked")
        return func(self, level, {}, ...)
    end
    return func(self, level, themes, ...)
end)

mod:hook(CLASS.ShadingEnvironmentSystem, "_fetch_theme_shading_environments", function(func, self, themes, ...)
    _state.hooks_called["ShadingEnvironmentSystem._fetch_theme_shading_environments"] = true
    if not is_in_mission_or_training() then return func(self, themes, ...) end
    if not should_block_in_hook() then return func(self, themes, ...) end

    if themes then
        for _, theme in ipairs(themes) do
            local t = type(theme) == "string" and string.lower(theme) or ""
            if (t == DARKNESS_THEME or string.find(t, "dark")) and should_block_darkness() then
                log("hook: fetch_dark blocked")
                return
            end
            if (t == VENTILATION_THEME or string.find(t, "fog") or string.find(t, "vent")) and should_block_fog() then
                log("hook: fetch_fog blocked")
                return
            end
        end
    end
    return func(self, themes, ...)
end)

mod:hook(CLASS.ShadingEnvironmentSystem, "theme_environment_from_slot", function(func, self, slot_id, ...)
    _state.hooks_called["ShadingEnvironmentSystem.theme_environment_from_slot"] = true
    local result = func(self, slot_id, ...)
    if not is_in_mission_or_training() or not result then return result end
    if not should_block_in_hook() then return result end

    local r = string.lower(result)
    if string.find(r, "dark") and should_block_darkness() then return nil end
    if (string.find(r, "fog") or string.find(r, "vent")) and should_block_fog() then return nil end
    return result
end)

mod:hook(CLASS.ShadingEnvironmentExtension, "setup_theme", function(func, self, shading_env_system, force_reset, ...)
    _state.hooks_called["ShadingEnvironmentExtension.setup_theme"] = true
    if not is_in_mission_or_training() then return func(self, shading_env_system, force_reset, ...) end
    if not should_block_in_hook() then return func(self, shading_env_system, force_reset, ...) end

    local slot = self._slot
    if slot and slot > -1 and shading_env_system then
        local env = shading_env_system:theme_environment_from_slot(slot)
        if env then
            local e = string.lower(env)
            if string.find(e, "dark") and should_block_darkness() then return end
            if (string.find(e, "fog") or string.find(e, "vent")) and should_block_fog() then return end
        end
    end
    return func(self, shading_env_system, force_reset, ...)
end)

mod:hook(CLASS.ShadingEnvironmentExtension, "enable", function(func, self, ...)
    _state.hooks_called["ShadingEnvironmentExtension.enable"] = true
    if not is_in_mission_or_training() then return func(self, ...) end
    if not should_block_in_hook() then return func(self, ...) end

    local name = self._shading_environment_resource_name
    if name then
        local n = string.lower(name)
        if string.find(n, "dark") and should_block_darkness() then return end
        if (string.find(n, "fog") or string.find(n, "vent")) and should_block_fog() then return end
    end
    return func(self, ...)
end)

mod:hook_safe(CLASS.DarknessSystem, "init", function(self, ...)
    _state.hooks_called["DarknessSystem.init"] = true
end)

mod:hook(CLASS.DarknessSystem, "update", function(func, self, ...)
    _state.hooks_called["DarknessSystem.update"] = true
    if is_in_mission_or_training() and is_special_mission() and should_block_in_hook() and should_block_darkness() then
        return
    end
    return func(self, ...)
end)

mod:hook(CLASS.DarknessSystem, "is_in_darkness_volume", function(func, self, position, ...)
    if is_in_mission_or_training() and is_special_mission() and should_block_in_hook() and should_block_darkness() then
        return false
    end
    return func(self, position, ...)
end)

mod:hook(CLASS.DarknessSystem, "set_global_darkness", function(func, self, set, ...)
    _state.hooks_called["DarknessSystem.set_global_darkness"] = true
    if is_in_mission_or_training() and is_special_mission() and should_block_in_hook() and should_block_darkness() and set then
        return func(self, false, ...)
    end
    return func(self, set, ...)
end)

local function should_control_lights_in_hook()
    if not is_in_mission_or_training() then return false end
    if not should_control_lights() then return false end
    update_mission_state()
    return should_apply_lighting()
end

mod:hook(CLASS.LightControllerSystem, "init", function(func, self, extension_init_context, system_init_data, ...)
    _state.hooks_called["LightControllerSystem.init"] = true
    local themes = system_init_data and system_init_data.themes
    if themes then
        for _, theme in ipairs(themes) do
            local t = string.lower(tostring(theme))
            if string.find(t, "darkness") then _state.is_darkness_mission = true
            elseif string.find(t, "ventilation") or string.find(t, "fog") then _state.is_ventilation_mission = true end
        end
    end
    if should_control_lights_in_hook() then
        if system_init_data then system_init_data.themes = {} end
        log("hook: light_init themes cleared")
    end
    return func(self, extension_init_context, system_init_data, ...)
end)

mod:hook(CLASS.LightControllerSystem, "on_theme_changed", function(func, self, themes, ...)
    _state.hooks_called["LightControllerSystem.on_theme_changed"] = true
    if should_control_lights_in_hook() then return end
    return func(self, themes, ...)
end)

mod:hook(CLASS.LightControllerSystem, "setup_light_groups", function(func, self, themes, ...)
    _state.hooks_called["LightControllerSystem.setup_light_groups"] = true
    if should_control_lights_in_hook() then
        return func(self, {}, ...)
    end
    return func(self, themes, ...)
end)

mod:hook(CLASS.LightControllerSystem, "_set_light_group_enabled", function(func, self, light_group_name, is_enabled, is_deterministic, ...)
    _state.hooks_called["LightControllerSystem._set_light_group_enabled"] = true

    record_intended_group_state(light_group_name, is_enabled)

    if should_control_lights_in_hook() and not is_enabled then
        return
    end
    return func(self, light_group_name, is_enabled, is_deterministic, ...)
end)

mod:hook(CLASS.LightControllerSystem, "on_gameplay_post_init", function(func, self, level, ...)
    _state.hooks_called["LightControllerSystem.on_gameplay_post_init"] = true
    local result = func(self, level, ...)

    log("post_init: intended_states=%d", get_intended_light_states_count())

    if should_control_lights_in_hook() then
        Promise.delay(0.5):next(function()
            apply_light_settings()
        end)
    end
    return result
end)

mod:hook_safe(CLASS.MutatorHandler, "activate_mutator", function(self, mutator_name, ...)
    _state.hooks_called["MutatorHandler.activate_mutator"] = true
    if mutator_name == DARKNESS_MUTATOR then _state.is_darkness_mission = true end
    if mutator_name == VENTILATION_MUTATOR then _state.is_ventilation_mission = true end
    log("mutator: %s", mutator_name)
end)

mod:hook_safe(CLASS.CameraManager, "add_environment", function(self, ...) _state.hooks_called["CameraManager.add_environment"] = true end)
mod:hook_safe(CLASS.SmokeFogSystem, "init", function(self, ...) _state.hooks_called["SmokeFogSystem.init"] = true end)
mod:hook_safe(CLASS.World, "create_shading_environment", function(world, ...) _state.hooks_called["World.create_shading_environment"] = true end)
mod:hook(CLASS.World, "create_shading_environment_resource", function(func, world, name, ...)
    _state.hooks_called["World.create_shading_environment_resource"] = true
    return func(world, name, ...)
end)

local function get_status_info()
    local has_themes = _state.original_themes ~= nil and #_state.original_themes > 0
    return {
        mission = _state.in_mission,
        dark = _state.is_darkness_mission,
        vent = _state.is_ventilation_mission,
        opt_in = mod:get("opt_in_special_missions"),
        should_apply = should_apply_lighting(),
        should_fog = should_apply_fog_darkness(),
        block_dark = mod:get("disable_darkness"),
        block_fog = mod:get("disable_fog"),
        light_enabled = mod:get("enable_light_control"),
        light_pct = mod:get("light_percentage"),
        light_mode = mod:get("light_selection"),
        light_state = mod:get("light_state"),
        flicker_default = mod:get("flicker_default"),
        weights_count = table.size(_state.original_extension_weights or {}),
        intended_count = get_intended_light_states_count(),
        themes_cleared = _state.themes_cleared,
        has_themes = has_themes,
    }
end

local function get_hooks_list()
    local hooks = {}
    for name, _ in pairs(_state.hooks_called) do table.insert(hooks, name) end
    table.sort(hooks)
    return hooks
end

local function get_shading_extensions(filter)
    local sys = get_system("shading_environment_system")
    if not sys or not sys._unit_to_extension_map then return nil end
    local exts = {}
    for unit, ext in pairs(sys._unit_to_extension_map) do
        local name = ext._shading_environment_resource_name
        if name then
            local n = string.lower(name)
            local match = not filter
            if filter == "dark" and string.find(n, "dark") then match = true end
            if filter == "fog" and (string.find(n, "fog") or string.find(n, "vent")) then match = true end
            if match then
                table.insert(exts, { name = name, base = ext._base_weight or 0, current = ext._current_weight or 0, enabled = ext._enabled })
            end
        end
    end
    return exts
end

local function get_darkness_system_state()
    if not Managers.state or not Managers.state.extension then return nil end
    local ds = Managers.state.extension:system("darkness_system")
    if not ds then return nil end
    return { global = ds._global_darkness, in_darkness = ds._in_darkness, volumes = ds._num_volumes }
end

local function get_light_groups_info()
    local sys = get_system("light_controller_system")
    if not sys or not sys._light_group_extensions then return nil, 0 end
    local groups = {}
    local total = 0
    for name, exts in pairs(sys._light_group_extensions) do
        table.insert(groups, { name = name, count = #exts })
        total = total + #exts
    end
    return groups, total
end

local function get_intended_light_states_info()
    local states = {}
    for group, enabled in pairs(_state.intended_light_states) do
        table.insert(states, { name = group, enabled = enabled })
    end
    table.sort(states, function(a, b) return a.name < b.name end)
    return states
end

local function get_assignment_info()
    local assigned_on, assigned_off = 0, 0
    for group_name, cache in pairs(_state.light_groups_cache) do
        if cache.indices then
            for i = 1, (cache.total or 0) do
                if cache.indices[i] then assigned_on = assigned_on + 1 else assigned_off = assigned_off + 1 end
            end
        end
    end
    return assigned_on, assigned_off
end

local function get_flicker_info()
    local flicker = _state.flicker
    if not flicker then return nil end
    local active = 0
    for _ in pairs(flicker.active_flickers or {}) do active = active + 1 end
    local cds = 0
    for _ in pairs(flicker.cooldowns or {}) do cds = cds + 1 end
    local stuttering = 0
    for _ in pairs(flicker.stutter_state or {}) do stuttering = stuttering + 1 end
    local waves = #(flicker.cascade_waves or {})
    local assigned_on, assigned_off = get_assignment_info()
    return {
        state = get_light_state(),
        default = get_flicker_default(),
        interval = get_flicker_interval(),
        duration = get_flicker_duration(),
        cooldown = get_flicker_cooldown(),
        pct = get_flicker_percentage(),
        stutter = mod:get("enable_stutter"),
        stutter_count = mod:get("stutter_count"),
        active = active,
        cooldowns = cds,
        stuttering = stuttering,
        waves = waves,
        last_cycle = _flicker_time - (flicker.last_cycle_time or 0),
        assigned_on = assigned_on,
        assigned_off = assigned_off,
    }
end

local function kill_darkness_system()
    if not Managers.state or not Managers.state.extension then return false end
    local ds = Managers.state.extension:system("darkness_system")
    if not ds then return false end
    if ds._global_darkness ~= nil then ds._global_darkness = false end
    if ds._in_darkness ~= nil then ds._in_darkness = false end
    if ds._num_volumes ~= nil then ds._num_volumes = 0 end
    if ds._player_unit_darkness_data then
        for unit, data in pairs(ds._player_unit_darkness_data) do
            if type(data) == "table" then
                for k, v in pairs(data) do
                    if type(v) == "boolean" then data[k] = false
                    elseif type(v) == "number" then data[k] = 0 end
                end
            end
        end
    end
    return true
end

local function kill_fog_extensions()
    local sys = get_system("shading_environment_system")
    if not sys or not sys._unit_to_extension_map then return 0 end
    local killed = 0
    for unit, ext in pairs(sys._unit_to_extension_map) do
        local name = ext._shading_environment_resource_name
        if name then
            local n = string.lower(name)
            if string.find(n, "fog") or string.find(n, "vent") then
                if ext._base_weight then ext._base_weight = 0 end
                if ext._current_weight then ext._current_weight = 0 end
                if ext._enabled and ext.disable then pcall(function() ext:disable() end) end
                killed = killed + 1
            end
        end
    end
    local smoke_sys = get_system("smoke_fog_system")
    if smoke_sys and smoke_sys._active_fog_volumes then table.clear(smoke_sys._active_fog_volumes) end
    return killed
end

mod:command("mgb_status", "status", function()
    local s = get_status_info()
    log("mission=%s dark=%s vent=%s", tostring(s.mission), tostring(s.dark), tostring(s.vent))
    log("opt_in=%s apply=%s apply_fog=%s", tostring(s.opt_in), tostring(s.should_apply), tostring(s.should_fog))
    log("blk_dark=%s blk_fog=%s", tostring(s.block_dark), tostring(s.block_fog))
    log("light_en=%s pct=%d mode=%s state=%s default=%s", tostring(s.light_enabled), s.light_pct, s.light_mode, s.light_state, s.flicker_default)
    log("weights=%d intended=%d themes_clr=%s has_themes=%s", s.weights_count, s.intended_count, tostring(s.themes_cleared), tostring(s.has_themes))
end)

mod:command("mgb_hooks", "hooks", function()
    local hooks = get_hooks_list()
    for _, name in ipairs(hooks) do log("  %s", name) end
    log("total: %d", #hooks)
end)

mod:command("mgb_apply", "force apply", function()
    if not _state.in_mission then log("not in mission"); return end
    log("applying...")
    reset_all_lights(true)
    reset_shading_to_default()
    Promise.delay(0.3):next(function()
        apply_fog_settings()
        apply_light_settings()
        log("done")
    end)
end)

mod:command("mgb_fog", "fog ext", function()
    local exts = get_shading_extensions("fog")
    if not exts then log("unavailable"); return end
    for _, e in ipairs(exts) do log("  %s b=%.2f c=%.2f %s", e.name, e.base, e.current, e.enabled and "ON" or "OFF") end
    log("total: %d", #exts)
end)

mod:command("mgb_darkness", "darkness", function()
    local ds = get_darkness_system_state()
    if ds then log("global=%s in=%s vols=%s", tostring(ds.global), tostring(ds.in_darkness), tostring(ds.volumes))
    else log("darkness_system unavailable") end
    local exts = get_shading_extensions("dark")
    if exts then
        for _, e in ipairs(exts) do log("  %s b=%.2f c=%.2f %s", e.name, e.base, e.current, e.enabled and "ON" or "OFF") end
        log("dark ext: %d", #exts)
    end
end)

mod:command("mgb_lights", "light groups", function()
    local groups, total = get_light_groups_info()
    if not groups then log("unavailable"); return end
    for _, g in ipairs(groups) do log("  %s: %d", g.name, g.count) end
    log("total: %d", total)
end)

mod:command("mgb_intended", "intended light states", function()
    local states = get_intended_light_states_info()
    if #states == 0 then log("no intended states recorded"); return end
    for _, s in ipairs(states) do log("  %s: %s", s.name, s.enabled and "ON" or "OFF") end
    log("total: %d groups", #states)
end)

mod:command("mgb_assigned", "assigned light states", function()
    local on, off = get_assignment_info()
    log("assigned ON=%d OFF=%d", on, off)
    for group_name, cache in pairs(_state.light_groups_cache) do
        if cache.indices then
            local group_on = 0
            for i = 1, (cache.total or 0) do
                if cache.indices[i] then group_on = group_on + 1 end
            end
            log("  %s: %d/%d on", group_name, group_on, cache.total or 0)
        end
    end
end)

mod:command("mgb_flicker", "flicker info", function()
    local f = get_flicker_info()
    if not f then log("unavailable"); return end
    log("state=%s default=%s int=%.2fs dur=%.3fs cd=%.2fs pct=%d", f.state, f.default, f.interval, f.duration, f.cooldown, math.floor(f.pct * 100))
    log("stutter=%s count=%d active=%d cds=%d stuttering=%d", tostring(f.stutter), f.stutter_count, f.active, f.cooldowns, f.stuttering)
    log("waves=%d last_cycle=%.1fs ago assigned_on=%d assigned_off=%d", f.waves, f.last_cycle, f.assigned_on, f.assigned_off)
end)

mod:command("mgb_flicker_stop", "stop flickers", function()
    stop_all_flickers()
    log("stopped")
end)

mod:command("mgb_kill_darkness", "kill darkness", function()
    if kill_darkness_system() then log("killed") else log("failed") end
end)

mod:command("mgb_kill_fog", "kill fog", function()
    log("killed %d ext", kill_fog_extensions())
end)

mod:command("mgb_lights_on", "all on", function()
    if reset_all_lights(true) then log("ON") else log("failed") end
end)

mod:command("mgb_lights_off", "all off", function()
    if reset_all_lights(false) then log("OFF") else log("failed") end
end)

mod:command("mgb_restore", "restore", function()
    mod:set("disable_darkness", false)
    mod:set("disable_fog", false)
    mod:set("enable_light_control", false)
    revert_fog_settings()
    revert_light_settings()
    log("restored")
end)

mod:command("mgb_shading", "shading", function()
    local sys = get_system("shading_environment_system")
    if not sys then log("unavailable"); return end
    if sys._theme_shading_environment_slots then
        for slot, env in pairs(sys._theme_shading_environment_slots) do log("  [%s]=%s", tostring(slot), tostring(env)) end
    end
    if sys._unit_to_extension_map then
        local total, enabled = 0, 0
        for _, ext in pairs(sys._unit_to_extension_map) do total = total + 1; if ext._enabled then enabled = enabled + 1 end end
        log("ext: %d total %d on", total, enabled)
    end
end)

mod.on_setting_changed = function(setting_id)
    if not _state.in_mission then return end

    if setting_id == "disable_darkness" or setting_id == "disable_fog" then
        if is_special_mission() and should_apply_fog_darkness() then
            Promise.delay(0.1):next(function()
                apply_fog_settings()
            end)
        end
    end

    if setting_id == "opt_in_special_missions" then
        if should_apply_lighting() then
            Promise.delay(0.1):next(function()
                if is_special_mission() and should_apply_fog_darkness() then
                    apply_fog_settings()
                end
            end):next(function()
                apply_light_settings()
            end)
        else
            stop_all_flickers()
            Promise.delay(0.1):next(function()
                revert_fog_settings()
                revert_light_settings()
            end)
        end
        return
    end

    if setting_id == "enable_light_control" then
        if not mod:get("enable_light_control") then
            stop_all_flickers()
            Promise.delay(0.1):next(function()
                revert_light_settings()
            end)
        else
            if should_apply_lighting() then
                Promise.delay(0.1):next(function()
                    apply_light_settings()
                end)
            end
        end
        return
    end

    if not should_apply_lighting() then return end
    if not should_control_lights() then return end

    if setting_id == "light_percentage" or setting_id == "light_selection" then
        if setting_id == "light_selection" then _state.light_groups_cache = {} end
        stop_all_flickers()
        Promise.delay(0.1):next(function()
            apply_light_settings()
        end)
    end

    if setting_id == "light_state" or setting_id == "flicker_default" then
        stop_all_flickers()
        clear_flicker_caches()
    end

    if setting_id == "flicker_interval" or setting_id == "flicker_percentage" or setting_id == "flicker_duration" or setting_id == "flicker_cooldown" or setting_id == "enable_stutter" or setting_id == "stutter_count" then
        _state.flicker.cooldowns = {}
    end
end

mod.on_enabled = function(initial_call)
    log("enabled: initial=%s in_mission=%s intended=%d", tostring(initial_call), tostring(_state.in_mission), get_intended_light_states_count())

    if is_in_mission_or_training() then
        _state.in_mission = true
        update_mission_state()

        Promise.delay(0.5):next(function()
            if is_special_mission() and should_apply_fog_darkness() then
                apply_fog_settings()
            end
        end):next(function()
            if should_apply_lighting() then
                apply_light_settings()
            end
        end)
    end
end

mod.on_disabled = function(initial_call)
    log("disabled: initial=%s", tostring(initial_call))
    stop_all_flickers()
    revert_fog_settings()
    revert_light_settings()
    _state.in_mission = false
    _state.is_darkness_mission = false
    _state.is_ventilation_mission = false
end

local function clear_mission_state()
    _state.hooks_called = {}
    _state.light_groups_cache = {}
    _state.original_extension_weights = {}
    _state.intended_light_states = {}
    _state.original_themes = nil
    _state.themes_cleared = false
    _state.in_mission = false
    _state.is_darkness_mission = false
    _state.is_ventilation_mission = false
    if _state.flicker then
        _state.flicker.active_flickers = {}
        _state.flicker.cooldowns = {}
        _state.flicker.last_cycle_time = 0
        _state.flicker.stutter_state = {}
        _state.flicker.cascade_waves = {}
        _state.flicker.cascade_next_time = 0
        _state.flicker.sorted_lights_cache = nil
        _state.flicker.sorted_on = nil
        _state.flicker.sorted_off = nil
        _state.flicker.last_sort_time = 0
    end
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" then
        if status == "enter" then
            _state.hooks_called = {}
            _state.light_groups_cache = {}
            _state.in_mission = is_in_mission_or_training()
            update_mission_state()
            Promise.delay(0.5):next(function()
                if _state.in_mission then
                    log("enter: dark=%s vent=%s intended=%d", tostring(_state.is_darkness_mission), tostring(_state.is_ventilation_mission), get_intended_light_states_count())
                end
            end)
        elseif status == "exit" then
            clear_mission_state()
        end
    end
end

mod.update = function(dt)
    if not _state.in_mission then return end
    _timer = _timer + dt
    if _timer >= 2.0 then
        _timer = 0
        update_mission_state()
    end
    _flicker_time = _flicker_time + dt
    update_flicker_system(_flicker_time)
end