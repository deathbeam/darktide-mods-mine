local mod = get_mod("KillStats")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "min_buff_uptime",
                type = "numeric",
                default_value = 0,
                range = { 0, 90 },
                decimals_number = 0,
            },
            {
                setting_id = "max_kill_history",
                type = "numeric",
                default_value = 10,
                range = { 5, 50 },
                decimals_number = 0,
            },
            {
                setting_id = "toggle_stats_keybind",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_kill_stats",
            },
        },
    },
}
