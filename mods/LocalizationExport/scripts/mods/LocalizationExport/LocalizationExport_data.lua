local mod = get_mod("LocalizationExport")
if not mod then
    return
end

return {
    name = mod:localize("mod_title"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    allow_rehooking = true,
    options = {
        widgets = {},
    },
}
