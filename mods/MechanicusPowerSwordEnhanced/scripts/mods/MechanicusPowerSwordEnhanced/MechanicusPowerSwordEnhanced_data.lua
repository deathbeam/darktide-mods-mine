local mod = get_mod("MechanicusPowerSwordEnhanced")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "vanilla_enhanced_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id    = "vanilla_enhanced",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
			{
				setting_id = "toggle_mode_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id    = "toggle_mode",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "deactivate_on_depleted",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "deactivate_on_wield",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
		}
	}
}
