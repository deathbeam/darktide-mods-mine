local mod = get_mod("NoBrainer")

return {
	name        = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable    = true,
	allow_rehooking = true,
		options = {
		widgets = {
			{
				setting_id    = "enable_debug_messages",
				type          = "checkbox",
				default_value = false,
				tooltip       = "enable_debug_messages_tooltip",
			},

			{
				setting_id  = "decode_symbols_group",
				type        = "group",
				title       = "decode_symbols_group",
				sub_widgets = {
					{
						setting_id    = "enable_decode_highlight",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_decode_highlight_tooltip",
					},
					{
						setting_id    = "enable_decode_auto",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_decode_auto_tooltip",
					},
				},
			},
			{
				setting_id  = "matching_group",
				type        = "group",
				title       = "matching_group",
				sub_widgets = {
					{
						setting_id    = "enable_matching",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_matching_tooltip",
					},
					{
						setting_id    = "enable_expedition_auto_solve",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_expedition_auto_solve_tooltip",
					},
					{
						setting_id    = "expedition_solve_speed",
						type          = "numeric",
						default_value = 5,
						range         = { 1, 10 },
						decimals_number = 0,
						tooltip       = "expedition_solve_speed_tooltip",
					},
				},
			},

			{
				setting_id  = "scan_group",
				type        = "group",
				title       = "scan_group",
				sub_widgets = {
					{
						setting_id    = "enable_scan",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_scan_tooltip",
					},
					{
						setting_id    = "enable_auto_scan",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_auto_scan_tooltip",
					},
				},
			},

			{
				setting_id  = "balance_group",
				type        = "group",
				title       = "balance_group",
				sub_widgets = {
					{
						setting_id    = "enable_balance",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_balance_tooltip",
					},
					{
						setting_id    = "balance_solve_speed",
						type          = "numeric",
						default_value = 5,
						range         = { 1, 10 },
						decimals_number = 0,
						tooltip       = "balance_solve_speed_tooltip",
					},
				},
			},

			{
				setting_id  = "drill_group",
				type        = "group",
				title       = "drill_group",
				sub_widgets = {
					{
						setting_id    = "enable_drill",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_drill_tooltip",
					},
					{
						setting_id    = "enable_drill_auto",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_drill_auto_tooltip",
					},
					{
						setting_id    = "drill_solve_speed",
						type          = "numeric",
						default_value = 5,
						range         = { 1, 10 },
						decimals_number = 0,
						tooltip       = "drill_solve_speed_tooltip",
					},
	
				},
			},

			{
				setting_id  = "frequency_group",
				type        = "group",
				title       = "frequency_group",
				sub_widgets = {
					{
						setting_id    = "enable_frequency_highlight",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_frequency_highlight_tooltip",
					},
					{
						setting_id    = "enable_frequency_auto",
						type          = "checkbox",
						default_value = true,
						tooltip       = "enable_frequency_auto_tooltip",
					},
					{
						setting_id    = "frequency_solve_speed",
						type          = "numeric",
						default_value = 2,
						range         = { 1, 10 },
						decimals_number = 0,
						tooltip       = "frequency_solve_speed_tooltip",
					},
				},
			},

			{
				setting_id  = "expedition_group",
				type        = "group",
				title       = "expedition_group",
				sub_widgets = {
					{
						setting_id    = "enable_expedition_automark",
						type          = "checkbox",
						default_value = false,
						tooltip       = "enable_expedition_automark_tooltip",
					},
					{
						setting_id    = "expedition_automark_silent",
						type          = "checkbox",
						default_value = true,
						tooltip       = "expedition_automark_silent_tooltip",
					},
					{
						setting_id    = "enable_expedition_automark_vault",
						type          = "checkbox",
						default_value = false,
						tooltip       = "enable_expedition_automark_vault_tooltip",
					},
				},
			},

			{
				setting_id  = "practice_group",
				type        = "group",
				title       = "practice_group",
				sub_widgets = {
					{
						setting_id    = "enable_practice",
						type          = "checkbox",
						default_value = false,
						tooltip       = "enable_practice_tooltip",
					},
					{
						setting_id    = "practice_type",
						type          = "dropdown",
						default_value = "decode_symbols",
						tooltip       = "practice_type_tooltip",
						options       = {
							{ text = "practice_type_decode_symbols", value = "decode_symbols" },
							{ text = "practice_type_decode_search",  value = "decode_search" },
							{ text = "practice_type_drill",          value = "drill" },
							{ text = "practice_type_frequency",      value = "frequency" },
							{ text = "practice_type_balance",        value = "balance" },
						},
					},
					{
						setting_id       = "practice_toggle_key",
						type             = "keybind",
						default_value    = { "f10" },
						keybind_trigger  = "pressed",
						keybind_type     = "function_call",
						function_name    = "toggle_practice",
						tooltip          = "practice_toggle_key_tooltip",
					},
				},
			},

		},
	},
}
