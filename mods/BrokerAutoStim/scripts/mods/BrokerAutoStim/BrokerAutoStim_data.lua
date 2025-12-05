local mod = get_mod("BrokerAutoStim")

	return {
		name = mod:localize("mod_name"),
		description = mod:localize("mod_description"),
		is_togglable = true,
		options = {
			widgets = {
				{
					setting_id      = "toggle_hotkey",
					type            = "keybind",
					default_value   = {},
					keybind_trigger = "pressed",
					keybind_type    = "function_call",
					function_name   = "toggle_auto_stim"
				},
				{
					setting_id      = "combat_duration",
					type            = "numeric",
					default_value   = 5.0,
					range           = { 0.5, 30.0 },
					decimals_number = 1
				},
				{
					setting_id      = "out_of_combat_timeout",
					type            = "numeric",
					default_value   = 5.0,
					range           = { 1.0, 30.0 },
					decimals_number = 1
				},
				{
					setting_id    = "only_with_chemical_dependency",
					type          = "checkbox",
					default_value = false
				},
				{
					setting_id    = "always_with_chemical_dependency",
					type          = "checkbox",
					default_value = false
				},
				{
					setting_id    = "enable_debug",
					type          = "checkbox",
					default_value = false
				},
			}
		}
	}

