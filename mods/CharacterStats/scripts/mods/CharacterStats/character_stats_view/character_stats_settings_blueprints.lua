local mod = get_mod('CharacterStats')

local CheckboxPassTemplates = mod:original_require('scripts/ui/pass_templates/checkbox_pass_templates')
local DropdownPassTemplates = mod:original_require('scripts/ui/pass_templates/dropdown_pass_templates')
local SliderPassTemplates = mod:original_require('scripts/ui/pass_templates/slider_pass_templates')
local UIFontSettings = mod:original_require('scripts/managers/ui/ui_font_settings')

local CONTROL_HEIGHT = 48
local LABEL_HEIGHT = 20
local MAX_VISIBLE_OPTIONS = 5

local label_style = table.clone(UIFontSettings.header_4)
label_style.font_size = 16
label_style.text_color = Color.terminal_text_body(255, true)
label_style.text_vertical_alignment = 'bottom'
label_style.text_horizontal_alignment = 'left'
label_style.offset = { 0, 0, 2 }

-- Build the settings-list blueprints. Each setting is two rows: a label row (our own text,
-- mod:localize, no re-localization) and below it the game's control (checkbox/slider/dropdown)
-- at full row width. We reuse the game's visual pass templates but write our own init/update,
-- so drag/fold/click logic is small and self-contained — no OptionsView focus coupling.
local function make_blueprints(width)
    local blueprints = {}

    blueprints.setting = {
        size = { width, CONTROL_HEIGHT },
        pass_template_function = function(_, entry)
            local passes = {}
            local control_type = entry.control_type
            if control_type == 'checkbox' then
                passes = CheckboxPassTemplates.settings_checkbox(width, CONTROL_HEIGHT, width, 2, true)
            elseif control_type == 'value_slider' then
                -- settings_area_width (arg 3) is the control area right-aligned in the row;
                -- the remaining header_width (width - settings_area_width) holds the value
                -- text and must be >= ~100 or its offset goes negative. Leave 110 for it.
                local slider_area = width - 110
                passes = SliderPassTemplates.settings_value_slider(width, CONTROL_HEIGHT, slider_area, true)
            elseif control_type == 'dropdown' then
                local options = entry.options or {}
                local num_visible = math.min(#options, MAX_VISIBLE_OPTIONS)
                passes = DropdownPassTemplates.settings_dropdown(width, CONTROL_HEIGHT, width, num_visible, true)
            end
            return passes
        end,
        init = function(_, widget, entry)
            local content = widget.content
            content.entry = entry

            if entry.control_type == 'checkbox' then
                content.option_1 = Localize('loc_setting_checkbox_on')
                content.option_2 = Localize('loc_setting_checkbox_off')
            elseif entry.control_type == 'value_slider' then
                content.area_length = width - 110
                content.step_size = entry.normalized_step_size
                content.apply_on_drag = entry.apply_on_drag and true
                local value = entry.get_function(entry)
                content.slider_value = math.normalize_01(value, entry.min_value, entry.max_value)
            elseif entry.control_type == 'dropdown' then
                local options = entry.options or {}
                local options_by_value = {}
                for i = 1, #options do
                    options_by_value[options[i].value] = options[i]
                end
                content.options = options
                content.options_by_value = options_by_value
                content.num_visible_options = math.min(#options, MAX_VISIBLE_OPTIONS)
                content.area_length = CONTROL_HEIGHT * content.num_visible_options
                content.scroll_length = math.max(CONTROL_HEIGHT * #options - content.area_length, 0)
                content.scroll_amount = content.scroll_length > 0 and (CONTROL_HEIGHT / content.scroll_length) or 0
            end
        end,
        update = function(parent, widget, input_service, dt, t)
            local content = widget.content
            local entry = content.entry
            local control_type = entry.control_type
            local hotspot = content.hotspot

            if control_type == 'checkbox' then
                local value = entry.get_function(entry)
                if hotspot.on_pressed then
                    value = not value
                    entry.on_activated(value, entry)
                end
                content.option_hotspot_1.is_selected = value
                content.option_hotspot_2.is_selected = not value
            elseif control_type == 'value_slider' then
                local drag_active = content.drag_active
                local slider_value = content.slider_value
                if drag_active and slider_value ~= content.previous_slider_value then
                    entry.on_activated(entry.explode_function(slider_value, entry), entry)
                elseif input_service:get('confirm_pressed') and (hotspot.is_focused or hotspot.is_selected) then
                    entry.on_activated(entry.explode_function(slider_value, entry), entry)
                end
                if not drag_active then
                    local value = entry.get_function(entry)
                    content.slider_value = math.normalize_01(value, entry.min_value, entry.max_value)
                end
                content.previous_slider_value = content.slider_value
                content.value_text = entry.format_value_function(entry.explode_function(content.slider_value, entry))
            elseif control_type == 'dropdown' then
                local options = content.options
                local style = widget.style

                if hotspot.on_pressed then
                    content.exclusive_focus = not content.exclusive_focus
                    content.anim_exclusive_focus_progress = content.exclusive_focus and 1 or 0
                    content.selected_index = nil
                end

                local focused = content.exclusive_focus
                content.grow_downwards = true
                local value = entry.get_function(entry)
                local current_index = 1
                for i = 1, #options do
                    if options[i].value == value then
                        current_index = i
                        break
                    end
                end
                content.value_text = options[current_index].display_name

                if focused then
                    local selected_index = content.selected_index or current_index

                    if input_service:get('navigate_up_continuous') then
                        selected_index = math.max(1, selected_index - 1)
                    elseif input_service:get('navigate_down_continuous') then
                        selected_index = math.min(#options, selected_index + 1)
                    end

                    -- Mouse selection: left_pressed lands on the hovered option row this
                    -- frame (same frame as the click), so check is_hover directly rather
                    -- than waiting for on_pressed (which is only set on the next draw).
                    local end_index = math.min(content.num_visible_options, #options)
                    for i = 1, end_index do
                        local option_hotspot = content['option_hotspot_' .. i]
                        if option_hotspot and option_hotspot.is_hover and input_service:get('left_pressed') then
                            selected_index = i
                            entry.on_activated(options[i].value, entry)
                            content.exclusive_focus = false
                            content.anim_exclusive_focus_progress = 0
                            break
                        end
                    end

                    if input_service:get('confirm_pressed') and not hotspot.on_pressed then
                        entry.on_activated(options[selected_index].value, entry)
                        content.exclusive_focus = false
                        content.anim_exclusive_focus_progress = 0
                    end

                    -- Click-away only when the cursor isn't over the dropdown itself nor
                    -- any of its option rows (otherwise the option click is treated as a close).
                    local cursor_on_option = false
                    for i = 1, end_index do
                        local option_hotspot = content['option_hotspot_' .. i]
                        if option_hotspot and option_hotspot.is_hover then
                            cursor_on_option = true
                            break
                        end
                    end
                    if input_service:get('left_pressed') and not hotspot.is_hover and not cursor_on_option then
                        content.exclusive_focus = false
                        content.anim_exclusive_focus_progress = 0
                    end

                    content.selected_index = selected_index

                    for i = 1, end_index do
                        local option_hotspot = content['option_hotspot_' .. i]
                        if option_hotspot then
                            option_hotspot.is_selected = i == selected_index
                        end
                        local y = CONTROL_HEIGHT * i
                        if style['option_hotspot_' .. i] then
                            style['option_hotspot_' .. i].offset[2] = y
                        end
                        if style['option_text_' .. i] then
                            style['option_text_' .. i].offset[2] = y
                            content['option_text_' .. i] = options[i].display_name
                        end
                    end
                end
            end
        end,
    }

    blueprints.setting_label = {
        size = { width, LABEL_HEIGHT },
        pass_template = {
            {
                pass_type = 'text',
                value_id = 'text',
                style = label_style,
                value = '',
            },
        },
        init = function(_, widget, entry)
            widget.content.text = entry.display_name or ''
        end,
    }

    return blueprints
end

return make_blueprints
