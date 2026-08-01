local mod = get_mod("state_your_name")

local function checkbox(setting_id, default_value, tooltip, sub_widgets)
	local widget = {
		setting_id = setting_id,
		type = "checkbox",
		default_value = default_value,
		tooltip = tooltip,
	}

	if sub_widgets then
		widget.sub_widgets = sub_widgets
	end

	return widget
end

local function dropdown(setting_id, default_value, tooltip, options)
	return {
		setting_id = setting_id,
		type = "dropdown",
		default_value = default_value,
		tooltip = tooltip,
		options = options,
	}
end

local function numeric(setting_id, default_value, minimum, maximum, tooltip)
	return {
		setting_id = setting_id,
		type = "numeric",
		default_value = default_value,
		range = { minimum, maximum },
		step_size_value = 1,
		tooltip = tooltip,
	}
end

-- Per-surface content overrides. Every one defaults to "inherit", so a surface
-- shows exactly what the global settings say until the player deliberately
-- changes it — which is what keeps this whole system invisible to anyone who
-- does not want it, and guarantees an upgrade changes nobody's display.
local function inherit_onoff(setting_id)
	return dropdown(setting_id, "inherit", setting_id .. "_tooltip", {
		{ text = "surface_inherit", value = "inherit" },
		{ text = "surface_on", value = "on" },
		{ text = "surface_off", value = "off" },
	})
end

local function surface_widgets(prefix, enabled_default, progression_default)
	return {
		checkbox("enable_" .. prefix, enabled_default, "enable_" .. prefix .. "_tooltip"),
		checkbox(prefix .. "_progression", progression_default, prefix .. "_progression_tooltip"),
		dropdown(prefix .. "_name_style", "inherit", prefix .. "_name_style_tooltip", {
			{ text = "surface_inherit", value = "inherit" },
			{ text = "style_character_account", value = "character_account" },
			{ text = "style_account_character", value = "account_character" },
			{ text = "style_character", value = "character" },
			{ text = "style_account", value = "account" },
		}),
		inherit_onoff(prefix .. "_platform_icon"),
		inherit_onoff(prefix .. "_level"),
		inherit_onoff(prefix .. "_havoc"),
		inherit_onoff(prefix .. "_record"),
		inherit_onoff(prefix .. "_kit"),
	}
end

-- Shared option list for the per-tracker icon pickers. Every value maps to a
-- glyph the game itself renders (the mod's verified level/Havoc insignia, or an
-- archetype icon read live from the game's own table) — never an emoji or an
-- unproven codepoint, so a picked icon can only ever appear or fall back to a
-- text label, never a missing-glyph box.
local function tracker_icon_options()
	return {
		{ text = "tracker_icon_default", value = "default" },
		{ text = "tracker_icon_none", value = "none" },
		{ text = "tracker_icon_level", value = "level" },
		{ text = "tracker_icon_havoc", value = "havoc" },
		{ text = "tracker_icon_veteran", value = "veteran" },
		{ text = "tracker_icon_zealot", value = "zealot" },
		{ text = "tracker_icon_psyker", value = "psyker" },
		{ text = "tracker_icon_ogryn", value = "ogryn" },
		{ text = "tracker_icon_adamant", value = "adamant" },
		{ text = "tracker_icon_broker", value = "broker" },
		{ text = "tracker_icon_cryptic", value = "cryptic" },
		{ text = "tracker_icon_operative", value = "operative" },
		{ text = "tracker_icon_companion", value = "companion" },
		{ text = "tracker_icon_penance", value = "penance" },
		{ text = "tracker_icon_credits", value = "credits" },
		{ text = "tracker_icon_marks", value = "marks" },
		{ text = "tracker_icon_aquila", value = "aquila" },
		{ text = "tracker_icon_plasteel", value = "plasteel" },
		{ text = "tracker_icon_diamantine", value = "diamantine" },
		{ text = "tracker_icon_salvage", value = "salvage" },
		{ text = "tracker_icon_loot", value = "loot" },
	}
end

local function color_override(prefix, defaults)
	return checkbox(prefix .. "_color_override", false, prefix .. "_color_override_tooltip", {
		numeric(prefix .. "_color_r", defaults[1], 0, 255),
		numeric(prefix .. "_color_g", defaults[2], 0, 255),
		numeric(prefix .. "_color_b", defaults[3], 0, 255),
	})
end

return {
	name = "State Your Name",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "inspection_group",
				type = "group",
				sub_widgets = {
					checkbox("enable_inspection", true, "enable_inspection_tooltip"),
					checkbox("inspect_party_finder", true, "inspect_party_finder_tooltip"),
					checkbox("inspect_social", true, "inspect_social_tooltip"),
					checkbox("inspect_lobby", true, "inspect_lobby_tooltip"),
				},
			},
			{
				setting_id = "identity_group",
				type = "group",
				sub_widgets = {
					dropdown("presentation_style", "aquila", "presentation_style_tooltip", {
						{ text = "presentation_aquila", value = "aquila" },
						{ text = "presentation_cogitator", value = "cogitator" },
						{ text = "presentation_litany", value = "litany" },
						{ text = "presentation_registry", value = "registry" },
						{ text = "presentation_dossier", value = "dossier" },
						{ text = "presentation_rail", value = "rail" },
						{ text = "presentation_classic", value = "classic" },
					}),
					dropdown("name_style", "character_account", "name_style_tooltip", {
						{ text = "style_character_account", value = "character_account" },
						{ text = "style_account_character", value = "account_character" },
						{ text = "style_character", value = "character" },
						{ text = "style_account", value = "account" },
					}),
					numeric("font_size", 0, 0, 40, "font_size_tooltip"),
					checkbox("dim_account_name", true, "dim_account_name_tooltip"),
					dropdown("progression_position", "after", "progression_position_tooltip", {
						{ text = "position_after", value = "after" },
						{ text = "position_before", value = "before" },
						{ text = "position_second_line", value = "second_line" },
					}),
					dropdown("separator_glyph", "auto", "separator_glyph_tooltip", {
						{ text = "separator_auto", value = "auto" },
						{ text = "separator_star", value = "star" },
						{ text = "separator_diamond", value = "diamond" },
						{ text = "separator_dot", value = "dot" },
						{ text = "separator_pipe", value = "pipe" },
						{ text = "separator_dash", value = "dash" },
					}),
					checkbox("show_platform_icon", true, "show_platform_icon_tooltip"),
					checkbox("hide_discriminator", true, "hide_discriminator_tooltip"),
					checkbox("deduplicate_names", true, "deduplicate_names_tooltip"),
					numeric("max_name_length", 24, 8, 48, "max_name_length_tooltip"),
					checkbox("show_self", true, "show_self_tooltip"),
					checkbox("show_own_account_name", true, "show_own_account_name_tooltip"),
					{
						setting_id = "expand_identity_key",
						type = "keybind",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "held",
						keybind_type = "function_call",
						function_name = "expand_identity",
						tooltip = "expand_identity_key_tooltip",
					},
					{
						setting_id = "cycle_name_style_key",
						type = "keybind",
						default_value = {},
						keybind_global = true,
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						function_name = "cycle_name_style",
						tooltip = "cycle_name_style_key_tooltip",
					},
				},
			},
			{
				setting_id = "colors_group",
				type = "group",
				sub_widgets = {
					dropdown("accent_theme", "imperial_gold", "accent_theme_tooltip", {
						{ text = "accent_imperial_gold", value = "imperial_gold" },
						{ text = "accent_servo_green", value = "servo_green" },
						{ text = "accent_arterial_red", value = "arterial_red" },
						{ text = "accent_bone_white", value = "bone_white" },
						{ text = "accent_player_slot", value = "player_slot" },
						{ text = "accent_custom", value = "custom" },
					}),
					numeric("accent_custom_r", 230, 0, 255, "accent_custom_r_tooltip"),
					numeric("accent_custom_g", 190, 0, 255, "accent_custom_g_tooltip"),
					numeric("accent_custom_b", 90, 0, 255, "accent_custom_b_tooltip"),
					dropdown("color_selection_scope", "character", "color_selection_scope_tooltip", {
						{ text = "color_selection_scope_character", value = "character" },
						{ text = "color_selection_scope_character_account", value = "character_and_account" },
						{ text = "color_selection_scope_line", value = "whole_line" },
					}),
					color_override("character", { 255, 235, 190 }),
					color_override("account", { 138, 132, 116 }),
					color_override("level", { 226, 220, 193 }),
					color_override("prestige", { 226, 220, 193 }),
					color_override("havoc", { 230, 190, 90 }),
					color_override("history", { 80, 205, 95 }),
					color_override("steam", { 102, 192, 244 }),
					color_override("xbox", { 16, 185, 16 }),
					color_override("psn", { 0, 112, 209 }),
				},
			},
			{
				setting_id = "progression_group",
				type = "group",
					sub_widgets = {
						checkbox("use_game_icons", true, "use_game_icons_tooltip"),
						checkbox("show_true_level", true, "show_true_level_tooltip"),
						checkbox("show_level_label", true, "show_level_label_tooltip"),
						checkbox("true_level_xp_bar", true, "true_level_xp_bar_tooltip"),
						dropdown("level_format", "total", "level_format_tooltip", {
							{ text = "level_format_total", value = "total" },
							{ text = "level_format_over_cap", value = "over_cap" },
						}),
						checkbox("show_prestige", false, "show_prestige_tooltip"),
						checkbox("char_select_all_trackers", false, "char_select_all_trackers_tooltip"),
					checkbox("level_tier_colors", true, "level_tier_colors_tooltip"),
					checkbox("milestone_flair", true, "milestone_flair_tooltip"),
					checkbox("show_havoc_assignments", true, "show_havoc_assignments_tooltip"),
					checkbox("show_havoc_weekly", true, "show_havoc_weekly_tooltip"),
					checkbox("show_havoc_all_time", false, "show_havoc_all_time_tooltip"),
					checkbox("havoc_heat_colors", true, "havoc_heat_colors_tooltip"),
					checkbox("collapse_equal_havoc", true, "collapse_equal_havoc_tooltip"),
				},
			},
			{
				setting_id = "tracker_icons_group",
				type = "group",
				sub_widgets = {
					dropdown("level_icon", "default", "level_icon_tooltip", tracker_icon_options()),
					dropdown("prestige_icon", "default", "prestige_icon_tooltip", tracker_icon_options()),
					dropdown("havoc_icon", "default", "havoc_icon_tooltip", tracker_icon_options()),
				},
			},
			{
				setting_id = "kit_group",
				type = "group",
				sub_widgets = {
					checkbox("show_kit", false, "show_kit_tooltip"),
					dropdown("kit_detail", "ability", "kit_detail_tooltip", {
						{ text = "kit_detail_ability", value = "ability" },
						{ text = "kit_detail_ability_blitz", value = "ability_blitz" },
						{ text = "kit_detail_full", value = "ability_blitz_aura" },
					}),
					dropdown("kit_class_name", "auto", "kit_class_name_tooltip", {
						{ text = "kit_class_auto", value = "auto" },
						{ text = "kit_class_always", value = "always" },
						{ text = "kit_class_never", value = "never" },
					}),
					dropdown("kit_surfaces", "all", "kit_surfaces_tooltip", {
						{ text = "kit_surfaces_all", value = "all" },
						{ text = "kit_surfaces_mission", value = "mission" },
						{ text = "kit_surfaces_menus", value = "menus" },
					}),
					color_override("kit", { 145, 180, 205 }),
				},
			},
			{
				setting_id = "history_group",
				type = "group",
				sub_widgets = {
					checkbox("track_history", true, "track_history_tooltip"),
					dropdown("record_style", "winrate_games", "record_style_tooltip", {
						{ text = "record_winrate_games", value = "winrate_games" },
						{ text = "record_wins_losses", value = "wins_losses" },
						{ text = "record_games", value = "games" },
					}),
					numeric("record_min_games", 1, 1, 100, "record_min_games_tooltip"),
					checkbox("show_quits", true, "show_quits_tooltip"),
					checkbox("first_drop_marker", true, "first_drop_marker_tooltip"),
					checkbox("winrate_tint", true, "winrate_tint_tooltip"),
				},
			},
			{
				setting_id = "surfaces_group",
				type = "group",
				sub_widgets = {
					{ setting_id = "team_hud_group", type = "group", sub_widgets = surface_widgets("team_hud", true, true) },
					{ setting_id = "nameplates_hub_group", type = "group", sub_widgets = surface_widgets("nameplates_hub", true, true) },
					{ setting_id = "nameplates_mission_group", type = "group", sub_widgets = surface_widgets("nameplates_mission", true, true) },
					{ setting_id = "lobby_group", type = "group", sub_widgets = surface_widgets("lobby", true, true) },
					{ setting_id = "party_finder_group", type = "group", sub_widgets = surface_widgets("party_finder", true, true) },
					{ setting_id = "chat_group", type = "group", sub_widgets = surface_widgets("chat", true, false) },
					{ setting_id = "combat_feed_group", type = "group", sub_widgets = surface_widgets("combat_feed", true, false) },
					{ setting_id = "menus_group", type = "group", sub_widgets = surface_widgets("menus", true, true) },
					{ setting_id = "social_group", type = "group", sub_widgets = surface_widgets("social", true, true) },
					{ setting_id = "spectator_group", type = "group", sub_widgets = surface_widgets("spectator", true, true) },
				},
			},
		},
	},
}
