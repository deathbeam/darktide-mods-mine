local mod = get_mod("SoloMinigames")

return {
	name = "SoloMinigames",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "sm_penalty",
				type = "numeric",
				range = {5, 120},
				default_value = 30,
			},
			{
				setting_id = "sm_corruptor_arm_difficulty",
				type = "dropdown",
				default_value = 1.50,
				options = {
					{ text = "sm_corruptor_difficulty_1", value = 0.25 },
					{ text = "sm_corruptor_difficulty_2", value = 0.50 },
					{ text = "sm_corruptor_difficulty_3", value = 0.75 },
					{ text = "sm_corruptor_difficulty_4", value = 1.00 },
					{ text = "sm_corruptor_difficulty_5", value = 1.50 },
				},
			},
			{
				setting_id = "sm_completion_color",
				type = "group",
				sub_widgets = {
					{
						setting_id = "sm_completion_color_r",
						type = "numeric",
						range = {0, 255},
						default_value = 0,
					},
					{
						setting_id = "sm_completion_color_g",
						type = "numeric",
						range = {0, 255},
						default_value = 255,
					},
					{
						setting_id = "sm_completion_color_b",
						type = "numeric",
						range = {0, 255},
						default_value = 0,
					},
				},
			},
		},
	},
}