local mod = get_mod("FirstPersonBody")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "fp_lower_body",
				type = "checkbox",
				default_value = true,
				tooltip = "fp_lower_body_tooltip",
			},
			{
				setting_id = "fp_fov_boost",
				type = "numeric",
				default_value = -15,
				range = { -30, 30 },
				step_size_value = 1,
				tooltip = "fp_fov_boost_tooltip",
			},
			{
				setting_id = "fp_ads_reveal",
				type = "checkbox",
				default_value = true,
				tooltip = "fp_ads_reveal_tooltip",
				sub_widgets = {
					{
						setting_id = "fp_ads_angle",
						type = "numeric",
						default_value = 42.1,
						range = { 10, 80 },
						decimals_number = 1,
						step_size_value = 0.1,
						tooltip = "fp_ads_angle_tooltip",
					},
				},
			},
			{
				setting_id = "fp_pitch_clamp",
				type = "checkbox",
				default_value = true,
				tooltip = "fp_pitch_clamp_tooltip",
				sub_widgets = {
					{
						setting_id = "fp_pitch_soft",
						type = "numeric",
						default_value = 51.1,
						range = { 30, 85 },
						decimals_number = 1,
						step_size_value = 0.1,
						tooltip = "fp_pitch_soft_tooltip",
					},
					{
						setting_id = "fp_pitch_hard",
						type = "numeric",
						default_value = 53.7,
						range = { 30, 89 },
						decimals_number = 1,
						step_size_value = 0.1,
						tooltip = "fp_pitch_hard_tooltip",
					},
					{
						setting_id = "fp_pitch_sprint",
						type = "numeric",
						default_value = 44.1,
						range = { 20, 89 },
						decimals_number = 1,
						step_size_value = 0.1,
						tooltip = "fp_pitch_sprint_tooltip",
					},
				},
			},
			{
				setting_id = "fp_fx_sources",
				type = "checkbox",
				default_value = true,
				tooltip = "fp_fx_sources_tooltip",
			},
			{
				setting_id = "fp_diagnostics",
				type = "checkbox",
				default_value = false,
				tooltip = "fp_diagnostics_tooltip",
			},
		},
	},
}
