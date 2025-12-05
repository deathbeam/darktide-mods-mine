local mod = get_mod("hub_hotkey_menus")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local hotkey_entries = {
    { key = "open_mission_board_view_key" },
    { key = "open_contracts_view_key" },
    { key = "open_crafting_view_key" },
    { key = "open_credits_vendor_view_key" },
    { key = "open_premium_store_view_key" },
    { key = "open_barber_view_key" },
    { key = "open_commissary_view_key" },
    { key = "open_penance_view_key" },
    { key = "open_training_grounds_view_key" },
    { key = "open_social_view_key" },
    { key = "open_inbox_view_key" },
    { key = "open_havoc_background_view" },
}

local entry_height = 24
local text_size = 18
local key_width = 50
local label_width = 150
local padding = 6
local key_label_gap = 10
local total_width = key_width + key_label_gap + label_width + padding * 2
local total_height = #hotkey_entries * entry_height + padding * 2

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    hotkey_list = {
        parent = "screen",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { total_width, 600 },
        position = { 10, 0, 3 }
    }
}

local widget_definitions = {}

for i, entry in ipairs(hotkey_entries) do
    widget_definitions["hotkey_entry_" .. i] = UIWidget.create_definition({
        {
            pass_type = "text",
            value_id = "keybind_text",
            style_id = "keybind_text",
            value = "",
            style = {
                font_type = "proxima_nova_bold",
                font_size = text_size,
                text_color = { 255, 255, 220, 120 },
                text_horizontal_alignment = "right",
                text_vertical_alignment = "center",
                offset = { padding, padding + (i - 1) * entry_height, 1 },
                size = { key_width, entry_height }
            },
            visibility_function = function(content, style)
                return content.visible
            end
        },
        {
            pass_type = "text",
            value_id = "label_text",
            style_id = "label_text",
            value = "loc_" .. entry.key,
            style = {
                font_type = "proxima_nova_bold",
                font_size = text_size,
                text_color = { 255, 220, 220, 220 },
                text_horizontal_alignment = "left",
                text_vertical_alignment = "center",
                offset = { padding + key_width + key_label_gap, padding + (i - 1) * entry_height, 1 },
                size = { label_width, entry_height }
            },
            change_function = function(content, style)
                return mod:localize(content.label_text)
            end,
            visibility_function = function(content, style)
                return content.visible
            end
        }
    }, "hotkey_list")
end

return {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
    hotkey_entries = hotkey_entries,
    entry_height = entry_height,
    padding = padding
}
