local mod = get_mod("extended_weapon_customization_syn_edits")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{["setting_id"] = "group_misc",
  				["type"] = "group",
				["sub_widgets"] = {
					{["setting_id"] = "mod_option_scope_randomization",
						["type"] = "checkbox",
						["default_value"] = false,
						["tooltip"] = "mod_option_scope_randomization_tooltip",
					},
					{["setting_id"] = "mod_option_receiver_ext_randomization",
						["type"] = "checkbox",
						["default_value"] = false,
						["tooltip"] = "mod_option_receiver_ext_randomization_tooltip",
					},
					{["setting_id"] = "mod_option_magwell_randomization",
						["type"] = "checkbox",
						["default_value"] = false,
						["tooltip"] = "mod_option_magwell_randomization_tooltip",
					},
					{["setting_id"] = "mod_option_bipod_randomization",
						["type"] = "checkbox",
						["default_value"] = false,
						["tooltip"] = "mod_option_bipod_randomization_tooltip",
					},
				},
			},
		},
	},
}
