local mod = get_mod("Muzzle")
local widgets = {
    {
        setting_id  = "mod_settings",
        type        = "group",
        sub_widgets = {
            {
                setting_id    = "ENABLED",
                type          = "checkbox",
                default_value = true,
            },
            {
                setting_id = "FOCUS",
                type = "checkbox",
                default_value = false,
            }
        }
    }
}

return {
    name         = mod:localize("mod_name"),
    description  = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = widgets
    }
}
