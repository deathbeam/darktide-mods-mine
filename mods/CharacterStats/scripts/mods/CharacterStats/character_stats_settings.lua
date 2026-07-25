local mod = get_mod('CharacterStats')

-- Build the settings-list entries for CharacterStatsView's left panel. Each setting is two
-- rows: a `setting_label` (rendered by our blueprint via mod:localize, no re-localization)
-- and the game's control (`setting`, full width). `on_activated` writes through mod:set, so
-- the existing on_setting_changed hook re-presents the detail panel live. Titles/option texts
-- reuse the same mod loc keys the DMF options menu already defines.
local function build_settings_entries()
    local mod_name = mod:get_name()
    local entries = {}

    local function add(widget_data)
        -- Label row.
        entries[#entries + 1] = {
            widget_type = 'setting_label',
            display_name = widget_data.title,
        }

        local entry = {
            on_activated = function(new_value)
                get_mod(mod_name):set(widget_data.setting_id, new_value, true)
                return true
            end,
            get_function = function()
                return get_mod(mod_name):get(widget_data.setting_id)
            end,
        }

        if widget_data.type == 'checkbox' then
            entry.widget_type = 'setting'
            entry.control_type = 'checkbox'
            entry.default_value = widget_data.default_value
        elseif widget_data.type == 'dropdown' then
            entry.widget_type = 'setting'
            entry.control_type = 'dropdown'
            entry.default_value = widget_data.default_value
            entry.options = {}
            for i = 1, #widget_data.options do
                local src = widget_data.options[i]
                entry.options[i] = {
                    value = src.value,
                    display_name = src.text,
                }
            end
        elseif widget_data.type == 'numeric' then
            entry.widget_type = 'setting'
            entry.control_type = 'value_slider'
            entry.default_value = widget_data.default_value
            entry.min_value = widget_data.range[1]
            entry.max_value = widget_data.range[2]
            local value_range = entry.max_value - entry.min_value
            local step = widget_data.step_size_value or 1
            entry.step_size_value = step
            entry.normalized_step_size = step / value_range
            entry.explode_function = function(normalized)
                local v = entry.min_value + normalized * value_range
                return math.round(v / step) * step
            end
            entry.format_value_function = function(value)
                return string.format('%d', value)
            end
            entry.apply_on_drag = true
        end

        entries[#entries + 1] = entry
    end

    -- Only the stats-affecting options belong in the in-view panel. The keybind and
    -- ESC-menu toggle stay in the DMF options menu where users expect them.
    add({
        setting_id = 'weapon_slot',
        type = 'dropdown',
        title = mod:localize('weapon_slot'),
        default_value = mod:get('weapon_slot'),
        options = {
            { value = 'slot_primary', text = mod:localize('weapon_slot_primary') },
            { value = 'slot_secondary', text = mod:localize('weapon_slot_secondary') },
        },
    })

    add({
        setting_id = 'assume_proc_stacks',
        type = 'checkbox',
        title = mod:localize('assume_proc_stacks'),
        default_value = mod:get('assume_proc_stacks'),
    })

    add({
        setting_id = 'coherency_allies',
        type = 'numeric',
        title = mod:localize('coherency_allies'),
        default_value = mod:get('coherency_allies'),
        range = { 0, 3 },
        step_size_value = 1,
    })

    add({
        setting_id = 'havoc_rank',
        type = 'numeric',
        title = mod:localize('havoc_rank'),
        default_value = mod:get('havoc_rank'),
        range = { 0, 40 },
        step_size_value = 1,
    })

    return entries
end

return {
    build_settings_entries = build_settings_entries,
}
