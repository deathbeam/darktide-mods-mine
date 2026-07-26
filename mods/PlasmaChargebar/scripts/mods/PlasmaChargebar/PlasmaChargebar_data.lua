local mod = get_mod("PlasmaChargebar")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "bar_distance",
				type = "numeric",
				default_value = 32,
				range = { 10, 200 },
				step_size_value = 1,
				decimals_number = 0,
			},
		},
	},
}
