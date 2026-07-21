local mod = get_mod("LoadoutPreviews")

local function checkbox(setting_id, default_value, tooltip)
	return {
		setting_id = setting_id,
		type = "checkbox",
		default_value = default_value,
		tooltip = tooltip,
	}
end

local function keybind(setting_id, tooltip, function_name)
	return {
		setting_id = setting_id,
		type = "keybind",
		default_value = {},
		tooltip = tooltip,
		keybind_global = true,
		keybind_trigger = "pressed",
		keybind_type = "function_call",
		function_name = function_name,
	}
end

local function preview_mode_dropdown(setting_id, tooltip)
	return {
		setting_id = setting_id,
		type = "dropdown",
		default_value = "tree",
		tooltip = tooltip,
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
	}
end

local function valkyrie_preview_mode_dropdown()
	return {
		setting_id = "valkyrie_team_preview_mode",
		type = "dropdown",
		default_value = "compact",
		tooltip = "valkyrie_team_preview_mode_tooltip",
		options = {
			{
				text = "valkyrie_team_preview_mode_compact",
				tooltip = "valkyrie_team_preview_mode_compact_tooltip",
				value = "compact",
			},
			{
				text = "valkyrie_team_preview_mode_tree",
				tooltip = "valkyrie_team_preview_mode_tree_tooltip",
				value = "tree",
			},
			{
				text = "valkyrie_team_preview_mode_tree_gear",
				tooltip = "valkyrie_team_preview_mode_tree_gear_tooltip",
				value = "tree_gear",
			},
		},
	}
end

local function preview_delay_slider(setting_id, tooltip)
	return {
		setting_id = setting_id,
		type = "numeric",
		range = { 0, 3 },
		default_value = 0,
		decimals_number = 1,
		step_size_value = 0.1,
		tooltip = tooltip,
	}
end

local function weapon_settings_group(group_id, tooltip, ids, text_mode_default)
	return {
		setting_id = group_id,
		type = "group",
		tooltip = tooltip,
		sub_widgets = {
			checkbox(ids.show, true, ids.show_tooltip),
			checkbox(ids.icons, true, ids.icons_tooltip),
			checkbox(ids.text_mode, text_mode_default, ids.text_mode_tooltip),
			checkbox(ids.blessings, true, ids.blessings_tooltip),
			checkbox(ids.blessing_descriptions, false, ids.blessing_descriptions_tooltip),
			checkbox(ids.perks, true, ids.perks_tooltip),
		},
	}
end

local function curio_settings_group(group_id, tooltip, ids)
	return {
		setting_id = group_id,
		type = "group",
		tooltip = tooltip,
		sub_widgets = {
			checkbox(ids.show, true, ids.show_tooltip),
			checkbox(ids.perks, true, ids.perks_tooltip),
		},
	}
end

local self_weapon_ids = {
	show = "show_weapon_preview",
	show_tooltip = "show_weapon_preview_tooltip",
	icons = "show_weapon_icons_preview",
	icons_tooltip = "show_weapon_icons_preview_tooltip",
	text_mode = "weapon_preview_text_mode",
	text_mode_tooltip = "weapon_preview_text_mode_tooltip",
	blessings = "show_weapon_blessings_preview",
	blessings_tooltip = "show_weapon_blessings_preview_tooltip",
	blessing_descriptions = "show_weapon_blessing_descriptions_preview",
	blessing_descriptions_tooltip = "show_weapon_blessing_descriptions_preview_tooltip",
	perks = "show_weapon_perks_preview",
	perks_tooltip = "show_weapon_perks_preview_tooltip",
}

local self_curio_ids = {
	show = "show_curio_preview",
	show_tooltip = "show_curio_preview_tooltip",
	perks = "show_curio_perks_preview",
	perks_tooltip = "show_curio_perks_preview_tooltip",
}

local team_weapon_ids = {
	show = "show_team_weapon_preview",
	show_tooltip = "show_team_weapon_preview_tooltip",
	icons = "show_team_weapon_icons_preview",
	icons_tooltip = "show_team_weapon_icons_preview_tooltip",
	text_mode = "team_weapon_preview_text_mode",
	text_mode_tooltip = "team_weapon_preview_text_mode_tooltip",
	blessings = "show_team_weapon_blessings_preview",
	blessings_tooltip = "show_team_weapon_blessings_preview_tooltip",
	blessing_descriptions = "show_team_weapon_blessing_descriptions_preview",
	blessing_descriptions_tooltip = "show_team_weapon_blessing_descriptions_preview_tooltip",
	perks = "show_team_weapon_perks_preview",
	perks_tooltip = "show_team_weapon_perks_preview_tooltip",
}

local team_curio_ids = {
	show = "show_team_curio_preview",
	show_tooltip = "show_team_curio_preview_tooltip",
	perks = "show_team_curio_perks_preview",
	perks_tooltip = "show_team_curio_perks_preview_tooltip",
}

local valkyrie_weapon_ids = {
	show = "show_valkyrie_weapon_preview",
	show_tooltip = "show_valkyrie_weapon_preview_tooltip",
	icons = "show_valkyrie_weapon_icons_preview",
	icons_tooltip = "show_valkyrie_weapon_icons_preview_tooltip",
	text_mode = "valkyrie_weapon_preview_text_mode",
	text_mode_tooltip = "valkyrie_weapon_preview_text_mode_tooltip",
	blessings = "show_valkyrie_weapon_blessings_preview",
	blessings_tooltip = "show_valkyrie_weapon_blessings_preview_tooltip",
	blessing_descriptions = "show_valkyrie_weapon_blessing_descriptions_preview",
	blessing_descriptions_tooltip = "show_valkyrie_weapon_blessing_descriptions_preview_tooltip",
	perks = "show_valkyrie_weapon_perks_preview",
	perks_tooltip = "show_valkyrie_weapon_perks_preview_tooltip",
}

local valkyrie_curio_ids = {
	show = "show_valkyrie_curio_preview",
	show_tooltip = "show_valkyrie_curio_preview_tooltip",
	perks = "show_valkyrie_curio_perks_preview",
	perks_tooltip = "show_valkyrie_curio_perks_preview_tooltip",
}

local party_finder_weapon_ids = {
	show = "show_party_finder_weapon_preview",
	show_tooltip = "show_party_finder_weapon_preview_tooltip",
	icons = "show_party_finder_weapon_icons_preview",
	icons_tooltip = "show_party_finder_weapon_icons_preview_tooltip",
	text_mode = "party_finder_weapon_preview_text_mode",
	text_mode_tooltip = "party_finder_weapon_preview_text_mode_tooltip",
	blessings = "show_party_finder_weapon_blessings_preview",
	blessings_tooltip = "show_party_finder_weapon_blessings_preview_tooltip",
	blessing_descriptions = "show_party_finder_weapon_blessing_descriptions_preview",
	blessing_descriptions_tooltip = "show_party_finder_weapon_blessing_descriptions_preview_tooltip",
	perks = "show_party_finder_weapon_perks_preview",
	perks_tooltip = "show_party_finder_weapon_perks_preview_tooltip",
}

local party_finder_curio_ids = {
	show = "show_party_finder_curio_preview",
	show_tooltip = "show_party_finder_curio_preview_tooltip",
	perks = "show_party_finder_curio_perks_preview",
	perks_tooltip = "show_party_finder_curio_perks_preview_tooltip",
}

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
					checkbox("loadout_preview_enabled", true, "loadout_preview_enabled_tooltip"),
					preview_mode_dropdown("talent_preview_mode", "talent_preview_mode_tooltip"),
					preview_delay_slider("preview_delay", "preview_delay_tooltip"),
					checkbox("show_stats_preview", true, "show_stats_preview_tooltip"),
					checkbox("show_stimm_lab_preview", true, "show_stimm_lab_preview_tooltip"),
					weapon_settings_group("weapon_settings", "weapon_settings_tooltip", self_weapon_ids, false),
					curio_settings_group("curio_settings", "curio_settings_tooltip", self_curio_ids),
				},
			},
			{
				setting_id = "team_settings",
				type = "group",
				tooltip = "team_settings_tooltip",
				sub_widgets = {
					checkbox("show_lobby_team_previews", true, "show_lobby_team_previews_tooltip"),
					keybind("lobby_team_preview_keybind", "lobby_team_preview_keybind_tooltip", "lobby_team_preview_keybind_pressed"),
					checkbox("show_own_lobby_team_preview", false, "show_own_lobby_team_preview_tooltip"),
					checkbox("show_lobby_tree_on_hover", false, "show_lobby_tree_on_hover_tooltip"),
					checkbox("show_team_stimm_lab_preview", true, "show_team_stimm_lab_preview_tooltip"),
					weapon_settings_group("team_weapon_settings", "team_weapon_settings_tooltip", team_weapon_ids, true),
					curio_settings_group("team_curio_settings", "team_curio_settings_tooltip", team_curio_ids),
				},
			},
			{
				setting_id = "valkyrie_settings",
				type = "group",
				tooltip = "valkyrie_settings_tooltip",
				sub_widgets = {
					checkbox("show_mission_intro_team_previews", true, "show_mission_intro_team_previews_tooltip"),
					keybind("mission_intro_team_preview_keybind", "mission_intro_team_preview_keybind_tooltip", "mission_intro_team_preview_keybind_pressed"),
					valkyrie_preview_mode_dropdown(),
					checkbox("show_valkyrie_stimm_lab_preview", true, "show_valkyrie_stimm_lab_preview_tooltip"),
					weapon_settings_group("valkyrie_weapon_settings", "valkyrie_weapon_settings_tooltip", valkyrie_weapon_ids, true),
					curio_settings_group("valkyrie_curio_settings", "valkyrie_curio_settings_tooltip", valkyrie_curio_ids),
				},
			},
			{
				setting_id = "party_finder_settings",
				type = "group",
				tooltip = "party_finder_settings_tooltip",
				sub_widgets = {
					checkbox("show_group_finder_applicant_previews", true, "show_group_finder_applicant_previews_tooltip"),
					preview_mode_dropdown("party_finder_preview_mode", "party_finder_preview_mode_tooltip"),
					preview_delay_slider("party_finder_preview_delay", "party_finder_preview_delay_tooltip"),
					checkbox("show_party_finder_stats_preview", true, "show_party_finder_stats_preview_tooltip"),
					checkbox("show_party_finder_stimm_lab_preview", true, "show_party_finder_stimm_lab_preview_tooltip"),
					weapon_settings_group("party_finder_weapon_settings", "party_finder_weapon_settings_tooltip", party_finder_weapon_ids, false),
					curio_settings_group("party_finder_curio_settings", "party_finder_curio_settings_tooltip", party_finder_curio_ids),
				},
			},
			{
				setting_id = "other_settings",
				type = "group",
				tooltip = "other_settings_tooltip",
				sub_widgets = {
					checkbox("name_pizazz", true, "name_pizazz_tooltip"),
					checkbox("use_cn_localization", false, "use_cn_localization_tooltip"),
				},
			},
		},
	},
}
