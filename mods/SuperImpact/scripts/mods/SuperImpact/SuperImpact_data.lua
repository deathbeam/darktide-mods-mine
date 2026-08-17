local mod = get_mod("SuperImpact")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
	widgets = {
		{
			setting_id = "power",
			type = "numeric",
			default_value = 3,
			range = {0, 100},
			decimals_number = 1,
		},
	},
}
}
