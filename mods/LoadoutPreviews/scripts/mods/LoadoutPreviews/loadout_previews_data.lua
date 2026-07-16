local mod = get_mod("LoadoutPreviews")

return {
	name = mod:get("name_pizazz") ~= false and mod:localize("mod_name_pizazz") or mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "preview_settings",
				type = "group",
				tooltip = "preview_settings_tooltip",
				sub_widgets = {
					{
						setting_id = "loadout_preview_enabled",
						type = "checkbox",
						default_value = true,
						tooltip = "loadout_preview_enabled_tooltip",
					},
					{
						setting_id = "talent_preview_mode",
						type = "dropdown",
						default_value = "tree",
						tooltip = "talent_preview_mode_tooltip",
						options = {
							{
								text = "talent_preview_mode_disabled",
								tooltip = "talent_preview_mode_disabled_tooltip",
								value = "disabled",
							},
							{
								text = "talent_preview_mode_tree",
								tooltip = "talent_preview_mode_tree_tooltip",
								value = "tree",
							},
							{
								text = "talent_preview_mode_tree_stats",
								tooltip = "talent_preview_mode_tree_stats_tooltip",
								value = "tree_stats",
							},
							{
								text = "talent_preview_mode_compact",
								tooltip = "talent_preview_mode_compact_tooltip",
								value = "compact",
							},
							{
								text = "talent_preview_mode_compact_stats",
								tooltip = "talent_preview_mode_compact_stats_tooltip",
								value = "compact_stats",
							},
							{
								text = "talent_preview_mode_stats",
								tooltip = "talent_preview_mode_stats_tooltip",
								value = "stats",
							},
						},
					},
					{
						setting_id = "preview_delay",
						type = "numeric",
						range = { 0, 3 },
						default_value = 0,
						decimals_number = 1,
						step_size_value = 0.1,
						tooltip = "preview_delay_tooltip",
					},
				},
			},
			{
				setting_id = "weapon_settings",
				type = "group",
				tooltip = "weapon_settings_tooltip",
				sub_widgets = {
					{
						setting_id = "show_weapon_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_weapon_preview_tooltip",
					},
					{
						setting_id = "show_weapon_icons_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_weapon_icons_preview_tooltip",
					},
					{
						setting_id = "weapon_preview_text_mode",
						type = "checkbox",
						default_value = false,
						tooltip = "weapon_preview_text_mode_tooltip",
					},
					{
						setting_id = "show_weapon_blessings_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_weapon_blessings_preview_tooltip",
					},
					{
						setting_id = "show_weapon_blessing_descriptions_preview",
						type = "checkbox",
						default_value = false,
						tooltip = "show_weapon_blessing_descriptions_preview_tooltip",
					},
					{
						setting_id = "show_weapon_perks_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_weapon_perks_preview_tooltip",
					},
				},
			},
			{
				setting_id = "curio_settings",
				type = "group",
				tooltip = "curio_settings_tooltip",
				sub_widgets = {
					{
						setting_id = "show_curio_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_curio_preview_tooltip",
					},
					{
						setting_id = "show_curio_perks_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_curio_perks_preview_tooltip",
					},
				},
			},
			{
				setting_id = "other_settings",
				type = "group",
				tooltip = "other_settings_tooltip",
				sub_widgets = {
					{
						setting_id = "name_pizazz",
						type = "checkbox",
						default_value = true,
						tooltip = "name_pizazz_tooltip",
					},
					{
						setting_id = "show_stimm_lab_preview",
						type = "checkbox",
						default_value = true,
						tooltip = "show_stimm_lab_preview_tooltip",
					},
				},
			},
		},
	},
}
