local mod = get_mod("LoadoutPreviews")
local lobby_team_previews_keybind_hidden = false
local mission_intro_team_previews_keybind_hidden = false

mod.lobby_team_preview_keybind_pressed = function (is_pressed)
	if is_pressed ~= false then
		lobby_team_previews_keybind_hidden = not lobby_team_previews_keybind_hidden
	end
end

mod.mission_intro_team_preview_keybind_pressed = function (is_pressed)
	if is_pressed ~= false then
		mission_intro_team_previews_keybind_hidden = not mission_intro_team_previews_keybind_hidden
	end
end

mod.on_setting_changed = function (setting_id)
	if setting_id == "show_lobby_team_previews" then
		lobby_team_previews_keybind_hidden = false
	elseif setting_id == "show_mission_intro_team_previews" then
		mission_intro_team_previews_keybind_hidden = false
	end
end

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local ItemUtils = require("scripts/utilities/items")
local MasterItems = require("scripts/backend/master_items")
local ProfileUtils = require("scripts/utilities/profile_utils")
local TalentBuilderViewSettings = require("scripts/ui/views/talent_builder_view/talent_builder_view_settings")
local TalentLayoutParser = require("scripts/ui/views/talent_builder_view/utilities/talent_layout_parser")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local Game = {
	BuffSettings = require("scripts/settings/buff/buff_settings"),
	BuffTemplates = require("scripts/settings/buff/buff_templates"),
	CharacterSheet = require("scripts/utilities/character_sheet"),
	PlayerDifficultySettings = require("scripts/settings/difficulty/player_difficulty_settings"),
	ToughnessSettings = require("scripts/settings/toughness/toughness_settings"),
	Weapon = require("scripts/extension_systems/weapon/weapon"),
	WeaponTemplate = require("scripts/utilities/weapon/weapon_template"),
	WeaponTweakTemplateSettings = require("scripts/settings/equipment/weapon_templates/weapon_tweak_template_settings"),
}

local valid_material_path
local safe_material_path

local PREVIEW_MODE = {
	disabled = "disabled",
	tree = "tree",
	tree_gear = "tree_gear",
	compact = "compact",
	stats = "stats",
	tree_stats = "tree_stats",
	compact_stats = "compact_stats",
}

local function preview_mode_is_compact(mode)
	return mode == PREVIEW_MODE.compact or mode == PREVIEW_MODE.compact_stats
end

local function preview_mode_is_tree(mode)
	return mode == PREVIEW_MODE.tree or mode == PREVIEW_MODE.tree_gear or mode == PREVIEW_MODE.tree_stats
end

local function preview_mode_has_stats(mode)
	return mode == PREVIEW_MODE.stats or mode == PREVIEW_MODE.tree_stats or mode == PREVIEW_MODE.compact_stats
end

local function preview_mode_stats_only(mode)
	return mode == PREVIEW_MODE.stats
end
local TOOLTIP_LAYOUT = {
	width = 300,
	grid_width = 225,
	grid_position_x = 37.5,
	grid_mask_padding = 40,
	preview_horizontal_padding = 80,
	preview_grid_vertical_padding = 20,
	preview_vertical_padding = 60,
}
local BETTER_LOADOUTS_LAYOUT = {
	side_picker_grid_position_x = -5,
	wide_picker_grid_position_x = 0,
	screen_margin_x = 24,
	screen_margin_bottom = 24,
}
local PREVIEW_LAYOUTS = {
	fallback_texture = "content/ui/materials/base/ui_default_base",
	fallback_talent_icon = "content/ui/textures/icons/talents/zealot/zealot_default_general_talent",
	stat_node_material = "content/ui/materials/frames/talents/circular_small_bg",
	talent_icon_material = "content/ui/materials/frames/talents/talent_icon_container",
	default = {
		map_width = 420,
		map_height = 752,
		map_padding = 0,
		node_edge_padding = 0,
		tree_vertical_stretch = 0.75,
		tree_vertical_offset = -10,
	},
	compact = {
		map_width = 320,
		map_height = 136,
		map_padding = 0,
		node_edge_padding = 0,
		tree_vertical_stretch = 1,
		tree_vertical_offset = 0,
		tooltip_grid_vertical_padding = 0,
		tooltip_vertical_padding = 0,
		grid_height_padding = 0,
		tooltip_height_padding = 0,
		icon_vertical_offset = -12,
	},
	tree = {
		min_width = 420,
		max_width = 700,
		min_height = 480,
		max_height = 760,
		target_height = 660,
		active_line_color = {
			230,
			125,
			205,
			255,
		},
	},
	compact_talent = {
		icon_gap = 18,
		node_order = {
			"tactical",
			"aura",
			"ability",
			"keystone",
		},
	},
	stimm = {
		gap = 8,
		height = 190,
		map_padding = 4,
		node_edge_padding = 0,
		node_size_scale = 0.72,
		tree_vertical_offset = 0,
		tree_vertical_stretch = 0.68,
	},
}
local MOVE_LAYOUT = {
	left = -1,
	right = 1,
	row_width = 225,
	row_height = 44,
	button_width = 107,
	button_height = 40,
}
MOVE_LAYOUT.button_gap = MOVE_LAYOUT.row_width - MOVE_LAYOUT.button_width * 2
local IMPORTANT_NODE_TYPES = {
	ability = "preview_ability",
	aura = "preview_aura",
	keystone = "preview_keystone",
	tactical = "preview_blitz",
}
local GEAR_LAYOUT = {
	panel_gap = 16,
	panel_width = 380,
	panel_padding = 16,
	section_gap = 14,
	section_header_height = 22,
	compact_preview_width = 380,
	compact_talent_height = 80,
	compact_content_gap = 6,
	compact_content_padding_top = 10,
	compact_content_padding_bottom = 40,
}
local TEAM_PREVIEW_LAYOUT = {
	canvas_width = 1920,
	canvas_height = 1080,
	applicant_scale = 0.74,
	applicant_draw_layer = 5000,
	applicant_z = 5000,
	content_padding_bottom = 18,
	content_padding_top = 18,
	lobby_bottom_y = 744,
	lobby_min_height = 810,
	lobby_min_width = 460,
	lobby_scale = 0.68,
	lobby_tree_hover_scale = 0.82,
	loading_gap = 28,
	loading_min_height = 810,
	loading_min_width = 460,
	loading_scale = 0.82,
	loading_title_text_y = 22,
	loading_tree_gear_min_scale = 0.32,
	loading_tree_scale = 0.56,
	loading_top_y = 34,
	margin = 24,
	mission_brief_default_clear_y = 360,
	mission_brief_gap = 32,
	panel_padding = 12,
	title_height = 54,
	title_text_height = 30,
	title_text_y = 14,
	z = 900,
	applicant_scenegraph_id = "loadout_previews_applicant_overlay",
	scenegraph_id = "loadout_previews_overlay",
}
local WEAPON_LAYOUT = {
	fallback_icon = "content/ui/materials/icons/weapons/hud/combat_blade_01",
	row_height = 58,
	row_height_text = 76,
	row_height_details = 104,
	icon_width = 128,
	icon_height = 48,
	icon_name_gap = 2,
	row_vertical_padding = 8,
	name_line_height = 20,
	detail_line_height = 16,
	name_top_padding = 8,
	detail_gap = 6,
	name_average_char_width = 8,
	detail_average_char_width = 6.5,
	detail_group_gap = 2,
	blessing_indent = 4,
	blessing_name_color = {
		0,
		102,
		0,
	},
	blessing_max = 2,
	perk_max = 2,
	blessing_prefix = "",
	preview_slots = {
		"slot_primary",
		"slot_secondary",
	},
}
local CURIO_LAYOUT = {
	perk_max = 3,
	row_height = 30,
	row_height_perks = 88,
	preview_slots = {
		"slot_attachment_1",
		"slot_attachment_2",
		"slot_attachment_3",
	},
	main_trait_hints = {
		gadget_innate_toughness_increase = true,
		gadget_innate_health_increase = true,
		gadget_innate_max_wounds_increase = true,
		gadget_stamina_increase = true,
		health_segment = true,
	},
}
local STAT_LAYOUT = {
	panel_width = 350,
	panel_padding = 18,
	title_height = 26,
	row_height = 26,
	row_gap = 2,
	title_gap = 8,
	min_height = 110,
	label_width = 164,
	value_width = 124,
	pair_separator = " / ",
	stat_rows = {
		{
			key = "wounds",
			label = "preview_stats_wounds",
		},
		{
			key = "health",
			label = "preview_stats_health",
		},
		{
			key = "toughness",
			label = "preview_stats_toughness",
		},
		{
			key = "stamina",
			label = "preview_stats_stamina",
		},
		{
			key = "stamina_regen",
			label = "preview_stats_stamina_regen",
		},
		{
			key = "crit_chance",
			label = "preview_stats_crit_chance",
		},
		{
			key = "crit_damage",
			label = "preview_stats_crit_damage",
		},
		{
			key = "dodges",
			label = "preview_stats_dodges",
		},
		{
			key = "dodge_distance",
			label = "preview_stats_dodge_distance",
		},
		{
			key = "sprint_speed",
			label = "preview_stats_sprint_speed",
		},
		{
			key = "sprint_time",
			label = "preview_stats_sprint_time",
		},
		{
			key = "toughness_regen_delay",
			label = "preview_stats_toughness_regen_delay",
		},
		{
			key = "toughness_regen_still",
			label = "preview_stats_toughness_regen_still",
		},
		{
			key = "toughness_regen_moving",
			label = "preview_stats_toughness_regen_moving",
		},
		{
			key = "toughness_melee_kill",
			label = "preview_stats_toughness_melee_kill",
		},
	},
	trait_stat_rules = {
		{
			match = "gadget_innate_toughness_increase",
			stat = "toughness_bonus",
		},
		{
			match = "gadget_toughness_increase",
			stat = "toughness_bonus",
			fallback = 0.05,
		},
		{
			match = "gadget_innate_health_increase",
			stat = "max_health_modifier",
		},
		{
			match = "gadget_health_increase",
			stat = "max_health_modifier",
			fallback = 0.05,
		},
		{
			match = "gadget_innate_max_wounds_increase",
			stat = "extra_max_amount_of_wounds",
			fallback = 1,
		},
		{
			match = "gadget_stamina_increase",
			stat = "stamina_modifier",
			fallback_by_rarity = {
				1,
				2,
				3,
			},
		},
		{
			match = "gadget_stamina_regeneration",
			stat = "stamina_regeneration_modifier",
			fallback_by_rarity = {
				0.06,
				0.08,
				0.1,
				0.12,
			},
		},
		{
			match = "weapon_trait_increase_crit_chance",
			stat = "critical_strike_chance",
			fallback = 0.05,
		},
		{
			match = "weapon_trait_ranged_increase_crit_chance",
			stat = "critical_strike_chance",
			fallback = 0.05,
		},
		{
			match = "weapon_trait_increase_crit_damage",
			stat = "critical_strike_damage",
			fallback = 0.1,
		},
		{
			match = "weapon_trait_ranged_increase_crit_damage",
			stat = "critical_strike_damage",
			fallback = 0.1,
		},
		{
			match = "weapon_trait_increase_stamina",
			stat = "stamina_modifier",
			fallback_by_rarity = {
				1,
				1.25,
				1.5,
				2,
			},
		},
		{
			match = "weapon_trait_ranged_increase_stamina",
			stat = "stamina_modifier",
			fallback_by_rarity = {
				1,
				1.25,
				1.5,
				2,
			},
		},
		{
			match = "weapon_trait_reduce_sprint_cost",
			stat = "sprinting_cost_multiplier",
			fallback_by_rarity = {
				0.94,
				0.91,
				0.88,
				0.85,
			},
		},
	},
}
local Settings = {}
local Layouts = {}
local Stats = {}
local TeamPreview = {}
local ApplicantPreview = {}
local PREVIEW_WIDGET_NAME_PREFIX = "loadout_previews_"
local active_preview_setting_scope
local PREVIEW_SETTING_SCOPES = {
	self = {
		enabled = "loadout_preview_enabled",
		mode = "talent_preview_mode",
		delay = "preview_delay",
		stats = "show_stats_preview",
		stimm = "show_stimm_lab_preview",
		weapons = "show_weapon_preview",
		weapon_icons = "show_weapon_icons_preview",
		weapon_text = "weapon_preview_text_mode",
		weapon_blessings = "show_weapon_blessings_preview",
		weapon_blessing_descriptions = "show_weapon_blessing_descriptions_preview",
		weapon_perks = "show_weapon_perks_preview",
		curios = "show_curio_preview",
		curio_perks = "show_curio_perks_preview",
	},
	team = {
		stimm = "show_team_stimm_lab_preview",
		weapons = "show_team_weapon_preview",
		weapon_icons = "show_team_weapon_icons_preview",
		weapon_text = "team_weapon_preview_text_mode",
		weapon_blessings = "show_team_weapon_blessings_preview",
		weapon_blessing_descriptions = "show_team_weapon_blessing_descriptions_preview",
		weapon_perks = "show_team_weapon_perks_preview",
		curios = "show_team_curio_preview",
		curio_perks = "show_team_curio_perks_preview",
	},
	valkyrie = {
		stimm = "show_valkyrie_stimm_lab_preview",
		weapons = "show_valkyrie_weapon_preview",
		weapon_icons = "show_valkyrie_weapon_icons_preview",
		weapon_text = "valkyrie_weapon_preview_text_mode",
		weapon_blessings = "show_valkyrie_weapon_blessings_preview",
		weapon_blessing_descriptions = "show_valkyrie_weapon_blessing_descriptions_preview",
		weapon_perks = "show_valkyrie_weapon_perks_preview",
		curios = "show_valkyrie_curio_preview",
		curio_perks = "show_valkyrie_curio_perks_preview",
	},
	party_finder = {
		enabled = "show_group_finder_applicant_previews",
		mode = "party_finder_preview_mode",
		delay = "party_finder_preview_delay",
		stats = "show_party_finder_stats_preview",
		stimm = "show_party_finder_stimm_lab_preview",
		weapons = "show_party_finder_weapon_preview",
		weapon_icons = "show_party_finder_weapon_icons_preview",
		weapon_text = "party_finder_weapon_preview_text_mode",
		weapon_blessings = "show_party_finder_weapon_blessings_preview",
		weapon_blessing_descriptions = "show_party_finder_weapon_blessing_descriptions_preview",
		weapon_perks = "show_party_finder_weapon_perks_preview",
		curios = "show_party_finder_curio_preview",
		curio_perks = "show_party_finder_curio_perks_preview",
	},
}

function Settings.report_guarded_error(context, error_message)
	local message = string.format("%s: %s", tostring(context or "guarded call"), tostring(error_message))

	if mod._loadout_previews_last_guarded_error == message then
		return
	end

	mod._loadout_previews_last_guarded_error = message

	if mod.warning then
		mod:warning("%s", "[LoadoutPreviews] " .. message)
	end
end

function Settings.safe_call(context, func, ...)
	if type(func) ~= "function" then
		return false, nil
	end

	local ok, result = pcall(func, ...)

	if not ok then
		Settings.report_guarded_error(context, result)

		return false, nil
	end

	return true, result
end

function Settings.safe_method(context, object, method_name, ...)
	local ok, method = pcall(function ()
		return object and object[method_name]
	end)

	if not ok then
		Settings.report_guarded_error(context, method)

		return false, nil
	end

	if type(method) ~= "function" then
		return false, nil
	end

	return Settings.safe_call(context, method, object, ...)
end

function Settings.get(setting_id)
	local ok, value = Settings.safe_call("read setting " .. tostring(setting_id), mod.get, mod, setting_id)

	if ok then
		return value
	end

	return nil
end

function Settings.localize(key, fallback)
	local ok, value = Settings.safe_call("localize " .. tostring(key), mod.localize, mod, key)

	if ok and value then
		return value
	end

	return fallback or tostring(key or "")
end

local function better_loadouts_mod()
	local ok, better_loadouts = pcall(get_mod, "BetterLoadouts")

	if ok and better_loadouts then
		return better_loadouts
	end

	return nil
end

local function better_loadouts_loaded()
	return better_loadouts_mod() ~= nil
end

local function better_loadouts_layout(better_loadouts)
	local namespace = better_loadouts and better_loadouts.BL

	if not namespace then
		return nil
	end

	if namespace.layout then
		local ok, layout = pcall(namespace.layout)

		if ok then
			return layout
		end
	end

	if namespace.layout_for_limit then
		local ok, layout = pcall(namespace.layout_for_limit, better_loadouts.preset_limit or 28)

		if ok then
			return layout
		end
	end
end

local function better_loadouts_is_wide(better_loadouts)
	if not better_loadouts then
		return false
	end

	if better_loadouts._bl_is_wide_preset_layout ~= nil then
		return better_loadouts._bl_is_wide_preset_layout == true
	end

	local columns = better_loadouts._bl_profile_preset_num_cols or 0
	local rows = better_loadouts._bl_profile_preset_num_rows or 0

	return columns > rows
end

local function better_loadouts_node_bottom(node)
	if not node or not node.position or not node.size then
		return nil
	end

	return (node.position[2] or 0) + (node.size[2] or 0)
end

local function better_loadouts_picker_grid_position_x()
	local better_loadouts = better_loadouts_mod()

	if better_loadouts_is_wide(better_loadouts) then
		return BETTER_LOADOUTS_LAYOUT.wide_picker_grid_position_x
	end

	return BETTER_LOADOUTS_LAYOUT.side_picker_grid_position_x
end

local function use_vertical_move_labels()
	local better_loadouts = better_loadouts_mod()

	return better_loadouts ~= nil and not better_loadouts_is_wide(better_loadouts)
end

local function move_row_label_keys()
	if use_vertical_move_labels() then
		return "move_up", "move_down"
	end

	return "move_left", "move_right"
end

local function screen_height()
	local resolution_lookup = rawget(_G, "RESOLUTION_LOOKUP")

	return resolution_lookup and resolution_lookup.height or 1080
end

local function screen_width()
	local resolution_lookup = rawget(_G, "RESOLUTION_LOOKUP")

	return resolution_lookup and resolution_lookup.width or 1920
end

local function better_loadouts_tooltip_dimensions()
	local better_loadouts = better_loadouts_mod()
	local layout = better_loadouts_layout(better_loadouts) or {}
	local max_columns = layout.MAX_COLUMNS or 0
	local rows_per_column = layout.ROWS_PER_COL or 0

	if max_columns > rows_per_column then
		if max_columns >= 80 then
			return {
				tooltip_width = 600,
				tooltip_height = 360,
				grid_width = 560,
			}
		end

		return {
			tooltip_width = 500,
			tooltip_height = 340,
			grid_width = 460,
		}
	end

	return {
		tooltip_width = 265,
		tooltip_height = 460,
		grid_width = 225,
	}
end

local function active_preview_settings()
	return PREVIEW_SETTING_SCOPES[active_preview_setting_scope or "self"] or PREVIEW_SETTING_SCOPES.self
end

local function scoped_setting_id(key)
	return active_preview_settings()[key]
end

function Settings.value_is_false(value)
	if type(value) == "string" then
		value = string.lower(value)
		value = string.gsub(value, "^%s+", "")
		value = string.gsub(value, "%s+$", "")
	end

	return value == false or value == 0 or value == "false" or value == "0" or value == "off" or value == "disabled"
end

function Settings.value_is_true(value)
	if type(value) == "string" then
		value = string.lower(value)
		value = string.gsub(value, "^%s+", "")
		value = string.gsub(value, "%s+$", "")
	end

	return value == true or value == 1 or value == "true" or value == "1" or value == "on" or value == "enabled"
end

local function scoped_preview_bool(key, disabled_by_default)
	local setting_id = scoped_setting_id(key)

	if not setting_id then
		return false
	end

	local value = Settings.get(setting_id)

	if disabled_by_default then
		return Settings.value_is_true(value)
	end

	return not Settings.value_is_false(value)
end

function Settings.preview_mode()
	local setting_id = scoped_setting_id("mode") or "talent_preview_mode"
	local mode = Settings.get(setting_id)

	if mode == PREVIEW_MODE.disabled or mode == PREVIEW_MODE.tree or mode == PREVIEW_MODE.tree_gear or mode == PREVIEW_MODE.compact or mode == PREVIEW_MODE.stats or mode == PREVIEW_MODE.tree_stats or mode == PREVIEW_MODE.compact_stats then
		return mode
	end

	return PREVIEW_MODE.tree
end

function Settings.loadout_preview_enabled()
	return scoped_preview_bool("enabled")
end

function Settings.with_preview_settings(scope, callback)
	local previous_scope = active_preview_setting_scope

	active_preview_setting_scope = scope

	local ok, result = Settings.safe_call("preview settings scope " .. tostring(scope), callback)

	active_preview_setting_scope = previous_scope

	if not ok then
		return nil
	end

	return result
end

function Settings.with_team_preview_settings(callback)
	return Settings.with_preview_settings("team", callback)
end

function Settings.with_party_finder_preview_settings(callback)
	return Settings.with_preview_settings("party_finder", callback)
end

function Settings.with_valkyrie_preview_settings(callback)
	return Settings.with_preview_settings("valkyrie", callback)
end

function Settings.show_lobby_team_previews()
	return not Settings.value_is_false(Settings.get("show_lobby_team_previews"))
end

function Settings.show_mission_intro_team_previews()
	return not Settings.value_is_false(Settings.get("show_mission_intro_team_previews"))
end

function Settings.show_group_finder_applicant_previews()
	return not Settings.value_is_false(Settings.get("show_group_finder_applicant_previews"))
end

function Settings.show_own_lobby_team_preview()
	return Settings.value_is_true(Settings.get("show_own_lobby_team_preview"))
end

function Settings.show_lobby_tree_on_hover()
	return Settings.value_is_true(Settings.get("show_lobby_tree_on_hover"))
end

function Settings.valkyrie_team_preview_mode()
	local mode = Settings.get("valkyrie_team_preview_mode")

	if mode == PREVIEW_MODE.tree_gear then
		return PREVIEW_MODE.tree_gear
	end

	if mode == PREVIEW_MODE.tree then
		return PREVIEW_MODE.tree
	end

	return PREVIEW_MODE.compact
end

function Settings.preview_delay()
	local setting_id = scoped_setting_id("delay")
	local delay = tonumber(setting_id and Settings.get(setting_id)) or 0

	return math.min(math.max(delay, 0), 3)
end

function Settings.show_stats_preview()
	return scoped_preview_bool("stats")
end

function Settings.show_weapon_preview()
	return scoped_preview_bool("weapons")
end

function Settings.show_weapon_icons_preview()
	return scoped_preview_bool("weapon_icons")
end

function Settings.show_curio_preview()
	return scoped_preview_bool("curios")
end

function Settings.show_stimm_lab_preview()
	return scoped_preview_bool("stimm")
end

function Settings.show_stimm_lab_preview_for_scope(scope)
	local visible = Settings.with_preview_settings(scope, function ()
		return Settings.show_stimm_lab_preview()
	end)

	return visible == true
end

function Settings.show_team_stimm_lab_preview()
	return Settings.show_stimm_lab_preview_for_scope("team")
end

function Settings.show_valkyrie_stimm_lab_preview()
	return Settings.show_stimm_lab_preview_for_scope("valkyrie")
end

function Settings.show_party_finder_stimm_lab_preview()
	return Settings.show_stimm_lab_preview_for_scope("party_finder")
end

function Settings.weapon_preview_text_mode()
	return scoped_preview_bool("weapon_text", true)
end

function Settings.show_weapon_blessings_preview()
	return scoped_preview_bool("weapon_blessings")
end

function Settings.show_weapon_blessing_descriptions_preview()
	return scoped_preview_bool("weapon_blessing_descriptions", true)
end

function Settings.show_weapon_perks_preview()
	return scoped_preview_bool("weapon_perks")
end

function Settings.show_curio_perks_preview()
	return scoped_preview_bool("curio_perks")
end

function Settings.preview_key(mode)
	return string.format("%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s", mode, tostring(Settings.show_stats_preview()), tostring(Settings.show_stimm_lab_preview()), tostring(Settings.show_weapon_preview()), tostring(Settings.show_weapon_icons_preview()), tostring(Settings.show_curio_preview()), tostring(Settings.weapon_preview_text_mode()), tostring(Settings.show_weapon_blessings_preview()), tostring(Settings.show_weapon_blessing_descriptions_preview()), tostring(Settings.show_weapon_perks_preview()), tostring(Settings.show_curio_perks_preview()))
end

function Layouts.local_player_profile()
	local player_manager = Managers and Managers.player
	local ok, player = Settings.safe_method("get local player", player_manager, "local_player", 1)

	if not ok or not player then
		return nil
	end

	local profile_read_ok, profile = pcall(function ()
		return player.profile
	end)

	if not profile_read_ok or type(profile) ~= "function" then
		return nil
	end

	local profile_ok, result = Settings.safe_call("get local player profile", profile, player)

	if profile_ok and result then
		return result
	end

	return nil
end

function Layouts.require(path)
	if not path then
		return nil
	end

	local ok, layout = pcall(require, path)

	if ok and layout then
		return layout
	end

	return nil
end

function Layouts.archetype_talent(archetype)
	return archetype and Layouts.require(archetype.talent_layout_file_path) or nil
end

function Layouts.archetype_stimm(archetype)
	local layout = archetype and Layouts.require(archetype.specialization_talent_layout_file_path) or nil

	if layout and layout.archetype_name == "broker" then
		return layout
	end

	return nil
end

local function preview_layout_settings(mode)
	if preview_mode_is_compact(mode) then
		return PREVIEW_LAYOUTS.compact
	end

	return PREVIEW_LAYOUTS.default
end

local function preview_layout_from_grid_layout(layout)
	if type(layout) == "table" then
		for i = 1, #layout do
			local element = layout[i]

			if element.loadout_organizer_preview_layout then
				return element.loadout_organizer_preview_layout
			end
		end
	end

	return PREVIEW_LAYOUTS.default
end

local function preview_tooltip_width(preview_layout)
	return (preview_layout.preview_width or preview_layout.map_width) + TOOLTIP_LAYOUT.preview_horizontal_padding
end

local function preview_tooltip_grid_height(preview_layout)
	return (preview_layout.preview_height or preview_layout.map_height) + (preview_layout.tooltip_grid_vertical_padding or TOOLTIP_LAYOUT.preview_grid_vertical_padding)
end

local function preview_tooltip_height(preview_layout)
	return (preview_layout.preview_height or preview_layout.map_height) + (preview_layout.tooltip_vertical_padding or TOOLTIP_LAYOUT.preview_vertical_padding)
end

local function layout_contains_reorder_controls(layout)
	if type(layout) ~= "table" then
		return false
	end

	for i = 1, #layout do
		if layout[i].loadout_organizer_move_direction or layout[i].loadout_organizer_move_row then
			return true
		end
	end

	return false
end

local function layout_contains_widget_type(layout, widget_type)
	if type(layout) ~= "table" then
		return false
	end

	for i = 1, #layout do
		if layout[i].widget_type == widget_type then
			return true
		end
	end

	return false
end

local function layout_contains_preview(layout)
	if type(layout) ~= "table" then
		return false
	end

	for i = 1, #layout do
		if layout[i].loadout_organizer_preview_layout then
			return true
		end
	end

	return false
end

local function layout_is_profile_preset_customize(layout)
	if type(layout) ~= "table" then
		return false
	end

	for i = 1, #layout do
		if layout[i].delete_button then
			return true
		end
	end

	return false
end

local function layout_spacing_width(layout)
	if type(layout) == "table" then
		for i = 1, #layout do
			local element = layout[i]
			local size = element and element.size

			if element.widget_type == "dynamic_spacing" and size and size[1] then
				return size[1]
			end
		end
	end

	return MOVE_LAYOUT.row_width
end

local function insert_reorder_controls_before_delete(layout)
	if type(layout) ~= "table" then
		return layout
	end

	local injected_layout = {}
	local inserted = false
	local spacing_width = layout_spacing_width(layout)

	for i = 1, #layout do
		local element = layout[i]

		if element.delete_button and not inserted then
			injected_layout[#injected_layout + 1] = {
				widget_type = "loadout_organizer_move_row",
				loadout_organizer_move_row = true,
			}
			injected_layout[#injected_layout + 1] = {
				widget_type = "dynamic_spacing",
				size = {
					spacing_width,
					10,
				},
			}
			inserted = true
		end

		injected_layout[#injected_layout + 1] = element
	end

	return injected_layout
end

local function inject_reorder_controls(layout)
	if better_loadouts_loaded() then
		return layout
	end

	if not layout_is_profile_preset_customize(layout) or layout_contains_reorder_controls(layout) then
		return layout
	end

	return insert_reorder_controls_before_delete(layout)
end

local function apply_tooltip_dimensions(view, layout)
	if not view then
		return
	end

	local preview = layout_contains_preview(layout)
	local preview_layout = preview_layout_from_grid_layout(layout)
	local tooltip_width = preview and preview_tooltip_width(preview_layout) or TOOLTIP_LAYOUT.width
	local tooltip_height = preview and preview_tooltip_height(preview_layout) or nil
	local grid_width = preview and (preview_layout.preview_width or preview_layout.map_width) or TOOLTIP_LAYOUT.grid_width
	local grid_height = preview and preview_tooltip_grid_height(preview_layout) or nil
	local better_loadouts_preview = preview and better_loadouts_loaded()
	local grid_position_x = preview and (better_loadouts_preview and 0 or (tooltip_width - grid_width) * 0.5) or TOOLTIP_LAYOUT.grid_position_x
	local grid = view._profile_preset_tooltip_grid
	local _, menu_settings = Settings.safe_method("profile preset tooltip menu settings", grid, "menu_settings")

	if menu_settings then
		menu_settings.grid_size[1] = grid_width
		menu_settings.mask_size[1] = grid_width + TOOLTIP_LAYOUT.grid_mask_padding

		if preview then
			menu_settings.grid_size[2] = grid_height
			menu_settings.mask_size[2] = grid_height
		end
	end

	Settings.safe_method("set tooltip scenegraph size", view, "_set_scenegraph_size", "profile_preset_tooltip", tooltip_width, tooltip_height)
	Settings.safe_method("set tooltip grid scenegraph size", view, "_set_scenegraph_size", "profile_preset_tooltip_grid", grid_width, grid_height)
	Settings.safe_method("set tooltip grid scenegraph position", view, "_set_scenegraph_position", "profile_preset_tooltip_grid", grid_position_x, 0)

	if grid and grid._update_window_size then
		Settings.safe_method("update tooltip window size", grid, "_update_window_size")
	elseif grid and grid.force_update_list_size then
		Settings.safe_method("force tooltip list size update", grid, "force_update_list_size")
	end

	if view._update_profile_preset_tooltip_grid_position then
		Settings.safe_method("update tooltip grid position", view, "_update_profile_preset_tooltip_grid_position")
	end
end

local function fit_better_loadouts_tooltip_to_screen(view, tooltip_width, tooltip_height)
	if not view then
		return
	end

	local tooltip_node = view._ui_scenegraph and view._ui_scenegraph.profile_preset_tooltip
	local tooltip_position = tooltip_node and tooltip_node.position

	if not tooltip_position then
		return
	end

	if view._force_update_scenegraph then
		Settings.safe_method("force profile preset scenegraph update", view, "_force_update_scenegraph")
	end

	local _, world_position = Settings.safe_method("profile preset tooltip world position", view, "scenegraph_world_position", "profile_preset_tooltip")
	local world_y = world_position and world_position[2]
	local world_x = world_position and world_position[1]

	if not world_x and not world_y then
		return
	end

	local adjusted_x = tooltip_position[1]
	local adjusted_y = tooltip_position[2]

	if world_x and tooltip_width then
		local right_overflow = world_x + tooltip_width - (screen_width() - BETTER_LOADOUTS_LAYOUT.screen_margin_x)

		if right_overflow > 0 then
			adjusted_x = adjusted_x - right_overflow
		elseif world_x < BETTER_LOADOUTS_LAYOUT.screen_margin_x then
			adjusted_x = adjusted_x + (BETTER_LOADOUTS_LAYOUT.screen_margin_x - world_x)
		end
	end

	if world_y and tooltip_height then
		local bottom_overflow = world_y + tooltip_height - (screen_height() - BETTER_LOADOUTS_LAYOUT.screen_margin_bottom)

		if bottom_overflow > 0 then
			adjusted_y = adjusted_y - bottom_overflow
		end
	end

	if adjusted_x ~= tooltip_position[1] or adjusted_y ~= tooltip_position[2] then
		Settings.safe_method("fit tooltip scenegraph position", view, "_set_scenegraph_position", "profile_preset_tooltip", adjusted_x, adjusted_y, tooltip_position[3])
	end
end

local function apply_better_loadouts_tooltip_position(view, tooltip_width, tooltip_height)
	local better_loadouts = better_loadouts_mod()

	if not view or not better_loadouts then
		return
	end

	local layout = better_loadouts_layout(better_loadouts) or {}
	local panel_node = view._ui_scenegraph and view._ui_scenegraph.profile_preset_button_panel
	local panel_width = better_loadouts._bl_profile_preset_panel_width
		or (panel_node and panel_node.size and panel_node.size[1])
		or ((layout.BUTTON_WIDTH or 44) * 2 + (layout.COLUMN_GAP or 12))
	local tooltip_def = view._definitions
		and view._definitions.scenegraph_definition
		and view._definitions.scenegraph_definition.profile_preset_tooltip
	local tooltip_position = tooltip_def and tooltip_def.position
	local x
	local y = tooltip_position and tooltip_position[2] or 0
	local z = tooltip_position and tooltip_position[3] or 1

	if better_loadouts_is_wide(better_loadouts) then
		local panel_bottom_y = better_loadouts._bl_profile_preset_panel_bottom_y
			or ((better_loadouts._bl_profile_preset_panel_top_y or y) + (better_loadouts._bl_profile_preset_panel_height or 0))

		x = math.floor(((tooltip_width or TOOLTIP_LAYOUT.width) - panel_width) * 0.5)
		y = panel_bottom_y + 16
	else
		x = -(panel_width + (layout.SAFE_GAP or 40)) + 12
	end

	if better_loadouts._has_loadoutnames then
		local scenegraph = view._ui_scenegraph
		local loadout_name_bottom = math.max(
			better_loadouts_node_bottom(scenegraph and scenegraph.loadout_name_tbox_area) or -math.huge,
			better_loadouts_node_bottom(scenegraph and scenegraph.loadout_name_tooltip_area) or -math.huge
		)

		if loadout_name_bottom > -math.huge then
			y = math.max(y, loadout_name_bottom + 16)
		end
	end

	Settings.safe_method("set BetterLoadouts tooltip position", view, "_set_scenegraph_position", "profile_preset_tooltip", x, y, z)

	fit_better_loadouts_tooltip_to_screen(view, tooltip_width, tooltip_height)

	if view._update_profile_preset_tooltip_grid_position then
		Settings.safe_method("update BetterLoadouts tooltip grid position", view, "_update_profile_preset_tooltip_grid_position")
	end
end

local function restore_better_loadouts_tooltip_dimensions(view)
	if not view or not better_loadouts_loaded() then
		return
	end

	local dimensions = better_loadouts_tooltip_dimensions()
	local grid = view._profile_preset_tooltip_grid
	local _, menu_settings = Settings.safe_method("restore tooltip menu settings", grid, "menu_settings")

	if menu_settings then
		menu_settings.grid_size[1] = dimensions.grid_width
		menu_settings.grid_size[2] = 1
		menu_settings.mask_size[1] = dimensions.grid_width + TOOLTIP_LAYOUT.grid_mask_padding
		menu_settings.mask_size[2] = 1 + TOOLTIP_LAYOUT.grid_mask_padding
	end

	Settings.safe_method("restore tooltip scenegraph size", view, "_set_scenegraph_size", "profile_preset_tooltip", dimensions.tooltip_width, dimensions.tooltip_height)
	Settings.safe_method("restore tooltip grid scenegraph size", view, "_set_scenegraph_size", "profile_preset_tooltip_grid", dimensions.grid_width, 1)
	Settings.safe_method("restore tooltip grid scenegraph position", view, "_set_scenegraph_position", "profile_preset_tooltip_grid", better_loadouts_picker_grid_position_x(), 0)
	apply_better_loadouts_tooltip_position(view, dimensions.tooltip_width, dimensions.tooltip_height)

	local _, scrollbar = Settings.safe_method("restore profile preset tooltip scrollbar", grid, "grid_scrollbar")
	local content = scrollbar and scrollbar.content
	local hotspot = content and content.hotspot

	if content then
		content.thumb_disabled = false
	end

	if hotspot then
		hotspot.disabled = false
		hotspot.force_disabled = false
	end

	if grid and grid.force_update_list_size then
		Settings.safe_method("force restored tooltip list size update", grid, "force_update_list_size")
	end
end

local function hide_preview_scrollbar(view)
	local grid = view and view._profile_preset_tooltip_grid
	local _, scrollbar = Settings.safe_method("profile preset tooltip scrollbar", grid, "grid_scrollbar")

	if not scrollbar then
		return
	end

	local content = scrollbar.content

	content.scroll_length = 0
	content.area_length = 1
	content.value = 0
	content.scroll_value = nil
	content.scroll_add = nil
	content.drag_active = nil
	content.thumb_disabled = true

	local hotspot = content.hotspot

	if hotspot then
		hotspot.disabled = true
		hotspot.force_disabled = true
		hotspot.is_hover = false
		hotspot.on_pressed = false
	end

	if grid._set_scenegraph_size then
		Settings.safe_method("hide tooltip scrollbar scenegraph", grid, "_set_scenegraph_size", "grid_scrollbar", 0, 0)
	end
end

local function move_row_button_change_function(hotspot_id)
	return function (content, style)
		ButtonPassTemplates.terminal_button_change_function(content, style, hotspot_id)
	end
end

local function move_row_background_change_function(hotspot_id)
	return function (content, style)
		ButtonPassTemplates.terminal_button_change_function(content, style, hotspot_id)
		ButtonPassTemplates.terminal_button_hover_change_function(content, style, hotspot_id)
	end
end

local function move_row_button_passes(hotspot_id, text_id, x, base_style_id)
	return {
		{
			content_id = hotspot_id,
			pass_type = "hotspot",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				offset = {
					x,
					0,
					0,
				},
				size = {
					MOVE_LAYOUT.button_width,
					MOVE_LAYOUT.button_height,
				},
			},
			content = {
				on_pressed_sound = nil,
				on_released_sound = nil,
				on_hover_sound = UISoundEvents.default_mouse_hover,
			},
		},
		{
			pass_type = "texture",
			style_id = base_style_id .. "_background",
			value = "content/ui/materials/gradients/gradient_vertical",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				default_color = Color.terminal_background_gradient(nil, true),
				hover_color = Color.terminal_frame_selected(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				disabled_color = Color.ui_grey_medium(140, true),
				offset = {
					x,
					0,
					2,
				},
				size = {
					MOVE_LAYOUT.button_width,
					MOVE_LAYOUT.button_height,
				},
			},
			change_function = move_row_background_change_function(hotspot_id),
		},
		{
			pass_type = "texture",
			style_id = base_style_id .. "_frame",
			value = "content/ui/materials/frames/frame_tile_2px",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				default_color = Color.terminal_frame(nil, true),
				hover_color = Color.terminal_frame_hover(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				disabled_color = Color.ui_grey_medium(120, true),
				offset = {
					x,
					0,
					3,
				},
				size = {
					MOVE_LAYOUT.button_width,
					MOVE_LAYOUT.button_height,
				},
			},
			change_function = move_row_button_change_function(hotspot_id),
		},
		{
			pass_type = "texture",
			style_id = base_style_id .. "_corner",
			value = "content/ui/materials/frames/frame_corner_2px",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				default_color = Color.terminal_corner(nil, true),
				hover_color = Color.terminal_corner_hover(nil, true),
				selected_color = Color.terminal_corner_selected(nil, true),
				disabled_color = Color.ui_grey_medium(120, true),
				offset = {
					x,
					0,
					4,
				},
				size = {
					MOVE_LAYOUT.button_width,
					MOVE_LAYOUT.button_height,
				},
			},
			change_function = move_row_button_change_function(hotspot_id),
		},
		{
			pass_type = "text",
			style_id = base_style_id .. "_text",
			value = "",
			value_id = text_id,
			style = {
				font_size = 18,
				font_type = "proxima_nova_bold",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_header(255, true),
				default_color = Color.terminal_text_header(255, true),
				hover_color = Color.white(255, true),
				selected_color = Color.white(255, true),
				disabled_color = Color.ui_grey_medium(160, true),
				offset = {
					x,
					0,
					5,
				},
				size = {
					MOVE_LAYOUT.button_width,
					MOVE_LAYOUT.button_height,
				},
			},
			change_function = move_row_button_change_function(hotspot_id),
		},
	}
end

local function append_preview_detail_lines(lines, values)
	if type(values) ~= "table" then
		return
	end

	for i = 1, #values do
		local value = values[i]

		if value and value ~= "" then
			lines[#lines + 1] = WEAPON_LAYOUT.blessing_prefix .. value
		end
	end
end

local function preview_detail_line_count(first, second)
	local count = 0

	if type(first) == "table" then
		count = count + #first
	end

	if type(second) == "table" then
		count = count + #second
	end

	return count
end

local function format_preview_detail_text(first, second)
	if preview_detail_line_count(first, second) == 0 then
		return ""
	end

	local lines = {}

	append_preview_detail_lines(lines, first)
	append_preview_detail_lines(lines, second)

	return table.concat(lines, "\n")
end

local function visible_text_for_measurement(text)
	if not text or text == "" then
		return ""
	end

	return string.gsub(tostring(text), "%{#.-%}", "")
end

local function estimated_wrapped_line_count(text, width, average_char_width)
	if not text or text == "" then
		return 0
	end

	local visible_text = visible_text_for_measurement(text)
	local chars_per_line = math.max(math.floor(math.max(width or 1, 1) / (average_char_width or 7)), 1)
	local count = 0
	local start_index = 1

	while true do
		local newline_start, newline_end = string.find(visible_text, "\n", start_index, true)
		local segment = newline_start and string.sub(visible_text, start_index, newline_start - 1) or string.sub(visible_text, start_index)
		local segment_lines = 1
		local line_length = 0
		local found_word = false

		for word in string.gmatch(segment or "", "%S+") do
			local word_length = string.len(word)

			found_word = true

			if word_length > chars_per_line then
				if line_length > 0 then
					segment_lines = segment_lines + 1
					line_length = 0
				end

				segment_lines = segment_lines + math.ceil(word_length / chars_per_line) - 1
			else
				local next_length = line_length == 0 and word_length or line_length + 1 + word_length

				if next_length > chars_per_line then
					segment_lines = segment_lines + 1
					line_length = word_length
				else
					line_length = next_length
				end
			end
		end

		count = count + (found_word and segment_lines or 1)

		if not newline_end then
			break
		end

		start_index = newline_end + 1
	end

	return count
end

function valid_material_path(value)
	return type(value) == "string"
		and (string.sub(value, 1, 21) == "content/ui/materials/" or string.sub(value, 1, 20) == "content/ui/textures/")
end

function safe_material_path(value, fallback)
	if valid_material_path(value) then
		return value
	end

	return fallback or PREVIEW_LAYOUTS.fallback_texture
end

local sanitize_widget_texture_content

local function init_gear_preview_widget(parent, widget, element)
	local content = widget and widget.content

	if not content or not element then
		return
	end

	local gear_data = element.gear_preview_data

	content.element = element
	content.preview_no_talents = Settings.localize("preview_no_talents")
	content.preview_weapons_title = Settings.localize("preview_weapons_title")
	content.preview_curios_title = Settings.localize("preview_curios_title")
	content.preview_stats_title = Settings.localize("preview_stats_title")

	if element.stats_preview_data then
		local rows = element.stats_preview_data.rows or {}

		for i = 1, #rows do
			local row = rows[i]

			content["stats_label_" .. i] = row and row.label or ""
			content["stats_value_" .. i] = row and row.value or ""
		end
	end

	if gear_data then
		local weapons = gear_data.weapons or {}
		local curios = gear_data.curios or {}

		for i = 1, #weapons do
			local weapon = weapons[i]
			local blessings = weapon.blessings
			local perks = weapon.perks

			content["weapon_text_" .. i] = weapon.text or ""
			content["weapon_icon_" .. i] = safe_material_path(weapon.icon, WEAPON_LAYOUT.fallback_icon)

			if preview_detail_line_count(perks) > 0 then
				content["weapon_perk_text_" .. i] = format_preview_detail_text(perks)
			end

			if preview_detail_line_count(blessings) > 0 then
				content["weapon_blessing_text_" .. i] = format_preview_detail_text(blessings)
			end
		end

		for i = 1, #curios do
			local curio = curios[i]

			content["curio_text_" .. i] = curio.text or Settings.localize("preview_missing_curio")
			content["curio_perk_text_" .. i] = format_preview_detail_text(curio.perks)
		end
	end

	if sanitize_widget_texture_content then
		sanitize_widget_texture_content(widget)
	end
end

mod:hook_require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_definitions", function (definitions)
	local blueprints = definitions and definitions.profile_preset_grid_blueprints

	if not blueprints then
		return
	end

	local move_row_pass_template = {}
	local left_passes = move_row_button_passes("left_hotspot", "left_text", 0, "left")
	local right_passes = move_row_button_passes("right_hotspot", "right_text", MOVE_LAYOUT.button_width + MOVE_LAYOUT.button_gap, "right")
	local preview_blueprint = {
		size_function = function (parent, element)
			return element and element.size or {
				0,
				0,
			}
		end,
		pass_template_function = function (parent, element)
			return element and element.pass_template or {}
		end,
		init = function (parent, widget, element)
			if widget and widget.content then
				widget.content.element = element
			end

			if sanitize_widget_texture_content then
				sanitize_widget_texture_content(widget)
			end
		end,
	}

	for i = 1, #left_passes do
		move_row_pass_template[#move_row_pass_template + 1] = left_passes[i]
	end

	for i = 1, #right_passes do
		move_row_pass_template[#move_row_pass_template + 1] = right_passes[i]
	end

	blueprints.loadout_organizer_preview = {
		size_function = function (parent, element)
			return element and element.size or {
				0,
				0,
			}
		end,
		pass_template_function = function (parent, element)
			return element and element.pass_template or {}
		end,
		init = init_gear_preview_widget,
	}
	blueprints.loadout_organizer_talent_map = preview_blueprint
	blueprints.loadout_organizer_compact_talents = preview_blueprint
	blueprints.loadout_organizer_move_row = {
		size = {
			MOVE_LAYOUT.row_width,
			MOVE_LAYOUT.row_height,
		},
		pass_template = move_row_pass_template,
		init = function (parent, widget, element, callback_name)
			local content = widget and widget.content

			if not content then
				return
			end

			local left_label_key, right_label_key = move_row_label_keys()

			content.element = element
			content.left_text = Settings.localize(left_label_key)
			content.right_text = Settings.localize(right_label_key)

			if callback_name then
				if content.left_hotspot then
					content.left_hotspot.pressed_callback = callback(parent, callback_name, widget, {
						loadout_organizer_move_direction = MOVE_LAYOUT.left,
					})
				end

				if content.right_hotspot then
					content.right_hotspot.pressed_callback = callback(parent, callback_name, widget, {
						loadout_organizer_move_direction = MOVE_LAYOUT.right,
					})
				end
			end
		end,
	}
end)

local function set_reorder_button_states(view)
	local grid = view and view._profile_preset_tooltip_grid
	local _, widgets = Settings.safe_method("profile preset tooltip widgets", grid, "widgets")

	if not widgets then
		return
	end

	local index = view._active_customize_preset_index
	local _, presets = Settings.safe_call("get profile presets for move buttons", ProfileUtils and ProfileUtils.get_profile_presets)
	local count = presets and #presets or 0

	for i = 1, #widgets do
		local widget = widgets[i]
		local content = widget and widget.content
		local element = content and content.element
		local direction = element and element.loadout_organizer_move_direction

		if element and element.loadout_organizer_move_row then
			local left_label_key, right_label_key = move_row_label_keys()

			content.left_text = Settings.localize(left_label_key)
			content.right_text = Settings.localize(right_label_key)

			if content.left_hotspot then
				content.left_hotspot.disabled = not index or index <= 1
			end

			if content.right_hotspot then
				content.right_hotspot.disabled = not index or index >= count
			end
		elseif direction then
			local hotspot = content.hotspot

			if hotspot then
				hotspot.disabled = not index or index + direction < 1 or index + direction > count
			end
		end
	end
end

local function restore_customize_grid(view)
	if view and view._custom_icons_initialized and view._setup_custom_icons_grid then
		Settings.safe_method("restore customize icon grid", view, "_setup_custom_icons_grid")
	end
end

local function set_grid_widget_visible(grid, widget_name, visible)
	local widgets_by_name = grid and grid._widgets_by_name
	local widget = widgets_by_name and widgets_by_name[widget_name]
	local content = widget and widget.content

	if content then
		content.visible = visible
	end
end

local function apply_preview_grid_rendering(view, preview)
	local grid = view and view._profile_preset_tooltip_grid

	if not grid then
		return
	end

	grid._no_resource_rendering = false

	set_grid_widget_visible(grid, "grid_background", true)
	set_grid_widget_visible(grid, "grid_divider_top", true)
	set_grid_widget_visible(grid, "grid_divider_bottom", true)
	set_grid_widget_visible(grid, "grid_empty", false)
	set_grid_widget_visible(grid, "grid_loading", false)
end

local function clear_preview_delay(view)
	if not view then
		return
	end

	view._loadout_organizer_pending_preset_id = nil
	view._loadout_organizer_pending_preview_key = nil
	view._loadout_organizer_pending_since = nil
end

local function hide_preview(view, restore_grid)
	if not view then
		return
	end

	clear_preview_delay(view)

	if not view._loadout_organizer_preview_visible then
		return
	end

	view._loadout_organizer_preview_visible = nil
	view._loadout_organizer_hovered_preset_id = nil
	view._loadout_organizer_preview_mode = nil
	view._loadout_organizer_preview_key = nil
	view._loadout_organizer_preview_layout_active = nil
	view._loadout_organizer_preview_layout = nil
	view._loadout_organizer_preview_grid_layout = nil

	apply_preview_grid_rendering(view, false)
	Settings.safe_method("hide profile preset tooltip", view, "_set_tooltip_visibility", false, false)

	if restore_grid then
		restore_better_loadouts_tooltip_dimensions(view)
		restore_customize_grid(view)
	end
end

local function sorted_selected_nodes(profile_preset, profile)
	profile = profile or Layouts.local_player_profile()

	local archetype = profile and profile.archetype
	local talents = profile_preset and profile_preset.talents

	if not archetype or type(talents) ~= "table" then
		return {}, 0
	end

	local layout = Layouts.archetype_talent(archetype)
	local selected_nodes = {}
	local total_points = 0
	local nodes = layout and layout.nodes

	if type(nodes) == "table" then
		for i = 1, #nodes do
			local node = nodes[i]
			local node_name = node and node.widget_name
			local points = node_name and talents[node_name]

			if points and points > 0 and node and node.type ~= "start" then
				selected_nodes[#selected_nodes + 1] = {
					node = node,
					points = points,
				}
				total_points = total_points + points
			end
		end
	end

	table.sort(selected_nodes, function (left, right)
		local left_node = left and left.node or {}
		local right_node = right and right.node or {}
		local left_important = IMPORTANT_NODE_TYPES[left_node.type] and 0 or 1
		local right_important = IMPORTANT_NODE_TYPES[right_node.type] and 0 or 1
		local left_y = left_node.y or 0
		local right_y = right_node.y or 0
		local left_x = left_node.x or 0
		local right_x = right_node.x or 0

		if left_important ~= right_important then
			return left_important < right_important
		end

		if left_y ~= right_y then
			return left_y < right_y
		end

		return left_x < right_x
	end)

	return selected_nodes, total_points
end

local function talent_name(archetype, node, points)
	local talent_key = node and node.talent
	local talent_definition = talent_key and archetype and archetype.talents and archetype.talents[talent_key]

	if talent_definition then
		local ok, title = Settings.safe_call("parse talent title", TalentLayoutParser and TalentLayoutParser.talent_title, talent_definition, points, Color.ui_terminal(255, true))

		if ok and title then
			return title
		end
	end

	return talent_key or node and node.widget_name or "n/a"
end

local function add_spacing(layout, height, preview_layout)
	layout[#layout + 1] = {
		widget_type = "dynamic_spacing",
		size = {
			preview_layout.map_width,
			height,
		},
	}
end

local function add_header(layout, text)
	layout[#layout + 1] = {
		widget_type = "header",
		text = text,
	}
end

local function shallow_copy(source)
	local copy = {}

	for key, value in pairs(source or {}) do
		copy[key] = value
	end

	return copy
end

local function loadout_slot_gear_id(loadout, slot_name)
	local slot_data = loadout and loadout[slot_name]

	if type(slot_data) == "table" then
		return slot_data.gear_id or slot_data.id or slot_data.name
	end

	return type(slot_data) == "string" and slot_data or nil
end

local function resolve_loadout_item(view, profile_preset, slot_name)
	local loadout = profile_preset and profile_preset.loadout
	local slot_data = loadout and loadout[slot_name]
	local gear_id = loadout_slot_gear_id(loadout, slot_name)
	local parent = view and view._parent

	if gear_id and parent and parent._get_inventory_item_by_id then
		local ok, item = pcall(parent._get_inventory_item_by_id, parent, gear_id)

		if ok and item then
			return item, gear_id
		end
	end

	if type(slot_data) == "table" then
		return slot_data, gear_id
	end

	return nil, gear_id
end

local function safe_item_display_name(item)
	if not item then
		return nil
	end

	local ok, display_name = Settings.safe_call("get item display name", ItemUtils and ItemUtils.display_name, item)

	if ok and display_name and display_name ~= "" then
		return display_name
	end

	local read_ok, display_name_key = pcall(function ()
		return item.display_name
	end)
	local localize_ok, localized = false, nil
	local name_ok, name = pcall(function ()
		return item.name
	end)

	if read_ok and display_name_key then
		localize_ok, localized = Settings.safe_call("localize item display name", Localize, display_name_key)
	end

	if localize_ok and localized and localized ~= "" then
		return localized
	end

	return name_ok and tostring(name or "") or nil
end

local function weapon_preview_icon(item)
	if not item then
		return nil
	end

	local ok, icon = pcall(function ()
		return item.hud_icon
	end)

	if not ok then
		return WEAPON_LAYOUT.fallback_icon
	end

	return safe_material_path(icon, WEAPON_LAYOUT.fallback_icon)
end

local function modifier_item(modifier)
	local modifier_id = modifier and (modifier.id or modifier.name)

	if not modifier_id then
		return nil
	end

	local ok, item = Settings.safe_call("get modifier master item", MasterItems and MasterItems.get_item, modifier_id)

	if ok and item then
		return item
	end

	return nil
end

local function modifier_trait_name(modifier, item)
	return modifier and (modifier.trait or modifier.name or modifier.id) or item and (item.trait or item.name) or nil
end

local function is_main_curio_trait(modifier, item)
	local trait_name = modifier_trait_name(modifier, item)

	if not trait_name then
		return false
	end

	trait_name = tostring(trait_name)

	for hint, _ in pairs(CURIO_LAYOUT.main_trait_hints) do
		if string.find(trait_name, hint, 1, true) then
			return true
		end
	end

	return false
end

local function trait_description(modifier, item)
	if not item then
		return nil
	end

	local rarity = modifier and modifier.rarity
	local value = modifier and modifier.value or 0
	local ok, description = Settings.safe_call("get trait description", ItemUtils and ItemUtils.trait_description, item, rarity, value)

	if ok and description then
		return description
	end

	return nil
end

local function inline_description_text(text)
	if not text or text == "" then
		return nil
	end

	local value = string.gsub(tostring(text), "\n", " ")

	value = string.gsub(value, "%s+", " ")
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")

	return value ~= "" and value or nil
end

local function curio_main_stat_text(item)
	local traits = item and item.traits
	local perks = item and item.perks
	local fallback_modifier
	local fallback_item

	if type(traits) == "table" then
		for i = 1, #traits do
			local modifier = traits[i]
			local trait_item = modifier_item(modifier)

			if trait_item then
				if is_main_curio_trait(modifier, trait_item) then
					return trait_description(modifier, trait_item)
				end

				fallback_modifier = fallback_modifier or modifier
				fallback_item = fallback_item or trait_item
			end
		end
	end

	if fallback_item then
		return trait_description(fallback_modifier, fallback_item)
	end

	if type(perks) == "table" then
		for i = 1, #perks do
			local modifier = perks[i]
			local perk_item = modifier_item(modifier)
			local description = trait_description(modifier, perk_item)

			if description then
				return description
			end
		end
	end

	return nil
end

local function perk_description_list(item, max_count)
	local descriptions = {}
	local perks = item and item.perks

	if type(perks) ~= "table" then
		return descriptions
	end

	for i = 1, #perks do
		local modifier = perks[i]
		local perk_item = modifier_item(modifier)
		local description = trait_description(modifier, perk_item)

		if description and description ~= "" then
			descriptions[#descriptions + 1] = description

			if #descriptions >= max_count then
				break
			end
		end
	end

	return descriptions
end

local function weapon_blessing_lines(item, include_descriptions)
	local blessings = {}
	local traits = item and item.traits

	if type(traits) ~= "table" then
		return blessings
	end

	for i = 1, #traits do
		local modifier = traits[i]
		local trait_item = modifier_item(modifier)
		local display_name = trait_item and safe_item_display_name(trait_item)

		if display_name and display_name ~= "" then
			local color = WEAPON_LAYOUT.blessing_name_color
			local description = include_descriptions and inline_description_text(trait_description(modifier, trait_item)) or nil
			local colored_display_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", color[1], color[2], color[3], display_name)

			blessings[#blessings + 1] = description and string.format("%s: %s", colored_display_name, description) or colored_display_name

			if #blessings >= WEAPON_LAYOUT.blessing_max then
				break
			end
		end
	end

	return blessings
end

local function collect_gear_preview_data(view, profile_preset)
	local weapons = {}
	local curios = {}
	local text_mode = Settings.weapon_preview_text_mode()
	local blessings_visible = Settings.show_weapon_blessings_preview()
	local blessing_descriptions_visible = Settings.show_weapon_blessing_descriptions_preview()
	local weapon_perks_visible = Settings.show_weapon_perks_preview()
	local curio_perks_visible = Settings.show_curio_perks_preview()
	local weapon_icons_visible = Settings.show_weapon_icons_preview()

	if Settings.show_weapon_preview() then
		for i = 1, #WEAPON_LAYOUT.preview_slots do
			local slot_name = WEAPON_LAYOUT.preview_slots[i]
			local item, gear_id = resolve_loadout_item(view, profile_preset, slot_name)

			if item or gear_id then
				local display_text = item and safe_item_display_name(item) or Settings.localize("preview_missing_weapon")

				weapons[#weapons + 1] = {
					blessings = blessings_visible and item and weapon_blessing_lines(item, blessing_descriptions_visible) or nil,
					blessing_descriptions_visible = blessing_descriptions_visible,
					icon = weapon_preview_icon(item),
					item = item,
					perks = weapon_perks_visible and item and perk_description_list(item, WEAPON_LAYOUT.perk_max) or nil,
					slot_name = slot_name,
					text = display_text,
				}
			end
		end
	end

	if Settings.show_curio_preview() then
		for i = 1, #CURIO_LAYOUT.preview_slots do
			local slot_name = CURIO_LAYOUT.preview_slots[i]
			local item, gear_id = resolve_loadout_item(view, profile_preset, slot_name)

			if item or gear_id then
				curios[#curios + 1] = {
					perks = curio_perks_visible and item and perk_description_list(item, CURIO_LAYOUT.perk_max) or nil,
					slot_name = slot_name,
					text = item and curio_main_stat_text(item) or Settings.localize("preview_missing_curio"),
				}
			end
		end
	end

	if #weapons == 0 and #curios == 0 then
		return nil
	end

	return {
		weapons = weapons,
		curios = curios,
		blessing_descriptions_visible = blessing_descriptions_visible,
		blessings_visible = blessings_visible,
		text_mode = text_mode,
		weapon_icons_visible = weapon_icons_visible,
	}
end

function Stats.buff_key(stat_name)
	local stat_buffs = Game.BuffSettings.stat_buffs

	return stat_buffs and stat_buffs[stat_name] or stat_name
end

function Stats.buff_type(stat_key)
	local stat_types = Game.BuffSettings and Game.BuffSettings.stat_buff_types

	return stat_types and stat_types[stat_key] or "value"
end

function Stats.base_value(stat_key)
	local base_values = Game.BuffSettings and Game.BuffSettings.stat_buff_type_base_values

	return base_values and base_values[stat_key] or 0
end

function Stats.number(value, tier)
	local value_type = type(value)

	if value_type == "number" then
		return value
	end

	if value_type ~= "table" then
		return tonumber(value)
	end

	local count = #value

	if count > 0 then
		local index = math.min(math.max(tonumber(tier) or 1, 1), count)

		return Stats.number(value[index])
	end

	local lerp_basic = tonumber(value.lerp_basic)
	local lerp_perfect = tonumber(value.lerp_perfect)

	if lerp_basic and lerp_perfect then
		return (lerp_basic + lerp_perfect) * 0.5
	end

	for _, nested_value in pairs(value) do
		local number = Stats.number(nested_value, tier)

		if number then
			return number
		end
	end

	return nil
end

function Stats.apply_value(stats, stat_key, raw_value, tier)
	if type(stats) ~= "table" or not stat_key or raw_value == nil then
		return
	end

	local value = Stats.number(raw_value, tier)

	if not value then
		return
	end

	local buff_type = Stats.buff_type(stat_key)
	local current = stats[stat_key]

	if current == nil then
		current = Stats.base_value(stat_key)
	end

	if buff_type == "multiplicative_multiplier" then
		stats[stat_key] = current * value
	elseif buff_type == "max_value" then
		stats[stat_key] = math.max(current, value)
	else
		stats[stat_key] = current + value
	end
end

function Stats.apply_table(stats, stat_table, tier)
	if type(stat_table) ~= "table" then
		return
	end

	for stat_key, value in pairs(stat_table) do
		Stats.apply_value(stats, stat_key, value, tier)
	end
end

function Stats.apply_buff_template(stats, buff_template_name, tier, include_conditionals)
	local template = buff_template_name and Game.BuffTemplates and Game.BuffTemplates[buff_template_name]

	if not template then
		return
	end

	Stats.apply_table(stats, template.stat_buffs, tier)

	if include_conditionals then
		Stats.apply_table(stats, template.conditional_stat_buffs, tier)
	end
end

function Stats.copy_values(source)
	local copy = {}

	for stat_key, value in pairs(source or {}) do
		copy[stat_key] = value
	end

	return copy
end

function Stats.value(stats, stat_name)
	local stat_key = Stats.buff_key(stat_name)
	local value = type(stats) == "table" and stats[stat_key] or nil

	if value == nil then
		value = Stats.base_value(stat_key)
	end

	return value or 0
end

function Stats.modifier_rule_value(modifier, rule)
	local value = tonumber(modifier and modifier.value)

	if value then
		return value
	end

	local rarity = tonumber(modifier and modifier.rarity) or 1
	local fallback_by_rarity = rule.fallback_by_rarity

	if fallback_by_rarity then
		return fallback_by_rarity[math.min(math.max(rarity, 1), #fallback_by_rarity)]
	end

	return rule.fallback
end

function Stats.apply_modifier_rule(stats, modifier, trait_name)
	if not trait_name then
		return false
	end

	trait_name = tostring(trait_name)

	for i = 1, #STAT_LAYOUT.trait_stat_rules do
		local rule = STAT_LAYOUT.trait_stat_rules[i]

		if string.find(trait_name, rule.match, 1, true) then
			local value = Stats.modifier_rule_value(modifier, rule)

			if value then
				Stats.apply_value(stats, Stats.buff_key(rule.stat), value)

				return true
			end
		end
	end

	return false
end

function Stats.apply_modifier(stats, modifier, include_template_fallback)
	local trait_item = modifier_item(modifier)
	local trait_name = modifier_trait_name(modifier, trait_item)
	local applied = Stats.apply_modifier_rule(stats, modifier, trait_name)

	if not applied and include_template_fallback and trait_name then
		Stats.apply_buff_template(stats, tostring(trait_name), modifier and modifier.rarity, false)
	end
end

function Stats.apply_item_modifiers(stats, item, include_template_fallback)
	local traits = item and item.traits
	local perks = item and item.perks

	if type(traits) == "table" then
		for i = 1, #traits do
			Stats.apply_modifier(stats, traits[i], include_template_fallback)
		end
	end

	if type(perks) == "table" then
		for i = 1, #perks do
			Stats.apply_modifier(stats, perks[i], include_template_fallback)
		end
	end
end

function Stats.apply_talents(stats, profile, profile_preset)
	local archetype = profile and profile.archetype
	local talents = profile_preset and profile_preset.talents

	if not archetype or not talents then
		return
	end

	if not Game.CharacterSheet or type(Game.CharacterSheet.convert_selected_nodes_to_selected_talents) ~= "function" or type(Game.CharacterSheet.class_loadout) ~= "function" then
		return
	end

	local ok, selected_talents = Settings.safe_call("convert selected talents", Game.CharacterSheet.convert_selected_nodes_to_selected_talents, archetype, talents)

	if not ok or not selected_talents then
		return
	end

	local class_loadout = {
		ability = {},
		aura = {},
		blitz = {},
		buff_template_tiers = {},
		coherency = {},
		passives = {},
		pocketable = {},
		special_rules = {},
	}
	local loaded = Settings.safe_call("build class loadout", Game.CharacterSheet.class_loadout, profile, class_loadout, nil, selected_talents, true)

	if not loaded then
		return
	end

	local function apply_loadout_buffs(loadout_buffs)
		if type(loadout_buffs) ~= "table" then
			return
		end

		for _, buff_template_names in pairs(loadout_buffs) do
			if type(buff_template_names) == "table" then
				for i = 1, #buff_template_names do
					local buff_template_name = buff_template_names[i]

					Stats.apply_buff_template(stats, buff_template_name, class_loadout.buff_template_tiers[buff_template_name], false)
				end
			end
		end
	end

	apply_loadout_buffs(class_loadout.passives)
	apply_loadout_buffs(class_loadout.coherency)
end

function Stats.weapon_tweak_template(weapon_tweak_templates, template_type, template_name)
	local template_types = Game.WeaponTweakTemplateSettings and Game.WeaponTweakTemplateSettings.template_types
	local typed_templates = template_types and weapon_tweak_templates and weapon_tweak_templates[template_types[template_type]]

	if not typed_templates then
		return nil
	end

	local name = template_name or "none"

	return typed_templates[name] or typed_templates["base_" .. name] or typed_templates.base or typed_templates.none
end

function Stats.scrub_tweak(subtweak, report_parent, skip)
	if type(subtweak) ~= "table" then
		return
	end

	for key, value in pairs(subtweak) do
		local value_type = type(value)

		if value_type == "table" then
			if skip then
				Stats.scrub_tweak(value, report_parent)
			else
				report_parent[key] = report_parent[key] or {}
				Stats.scrub_tweak(value, report_parent[key])
			end
		elseif value_type == "number" then
			report_parent[key] = report_parent[key] or {
				count = 0,
				stat_type = "number",
				sum = 0,
			}
			report_parent[key].sum = report_parent[key].sum + value
			report_parent[key].count = report_parent[key].count + 1
		elseif value_type == "string" then
			report_parent[key] = report_parent[key] or {
				sample = {},
				stat_type = "string",
			}
			report_parent[key].sample[value] = (report_parent[key].sample[value] or 0) + 1
		end
	end
end

function Stats.finalize_tweak_report(report)
	local final_tweak = {}

	for key, value in pairs(report) do
		if type(value) == "table" then
			if value.stat_type == "number" then
				if value.count and value.count > 0 then
					final_tweak[key] = value.sum / value.count
				end
			elseif value.stat_type == "string" then
				local highest_count = 0
				local highest_string = ""

				for sample, count in pairs(value.sample) do
					if count > highest_count then
						highest_string = sample
						highest_count = count
					end
				end

				final_tweak[key] = highest_string
			else
				final_tweak[key] = Stats.finalize_tweak_report(value)
			end
		else
			final_tweak[key] = value
		end
	end

	return final_tweak
end

function Stats.create_tweak_exhaustive(weapon_tweak_templates)
	local report = {}

	if not weapon_tweak_templates then
		return report
	end

	for key, subtweak in pairs(weapon_tweak_templates) do
		report[key] = {}
		Stats.scrub_tweak(subtweak, report[key], true)
	end

	return Stats.finalize_tweak_report(report)
end

function Stats.collect_weapon_context(item, base_stats)
	if not item then
		return nil
	end

	local ok_template, weapon_template = Settings.safe_call("resolve weapon template", Game.WeaponTemplate and Game.WeaponTemplate.weapon_template_from_item, item)

	if not ok_template or not weapon_template then
		return nil
	end

	local stats = Stats.copy_values(base_stats)

	Stats.apply_item_modifiers(stats, item, false)

	local ok_tweaks, weapon_tweak_templates = Settings.safe_call("initialize weapon trait tweaks", Game.Weapon and Game.Weapon._init_traits, nil, weapon_template, item, nil, nil)
	local stamina_template
	local dodge_template
	local sprint_template
	local toughness_template
	local weapon_handling_template

	if ok_tweaks and weapon_tweak_templates then
		local override_tweak = Stats.create_tweak_exhaustive(weapon_tweak_templates)

		stamina_template = override_tweak.stamina or Stats.weapon_tweak_template(weapon_tweak_templates, "stamina", weapon_template.stamina_template)
		dodge_template = override_tweak.dodge or Stats.weapon_tweak_template(weapon_tweak_templates, "dodge", weapon_template.dodge_template)
		sprint_template = override_tweak.sprint or Stats.weapon_tweak_template(weapon_tweak_templates, "sprint", weapon_template.sprint_template)
		toughness_template = override_tweak.toughness or Stats.weapon_tweak_template(weapon_tweak_templates, "toughness", weapon_template.toughness_template)
		weapon_handling_template = override_tweak.weapon_handling
	end

	local ok_melee, is_melee = Settings.safe_call("check melee weapon template", Game.WeaponTemplate and Game.WeaponTemplate.is_melee, weapon_template)
	local ok_ranged, is_ranged = Settings.safe_call("check ranged weapon template", Game.WeaponTemplate and Game.WeaponTemplate.is_ranged, weapon_template)

	return {
		dodge_template = dodge_template,
		is_melee = ok_melee and is_melee == true,
		is_ranged = ok_ranged and is_ranged == true,
		sprint_template = sprint_template,
		stats = stats,
		stamina_template = stamina_template,
		toughness_template = toughness_template,
		weapon_handling_template = weapon_handling_template,
	}
end

function Stats.collect_weapon_contexts(view, profile_preset, base_stats)
	local contexts = {}

	for i = 1, #WEAPON_LAYOUT.preview_slots do
		local item = resolve_loadout_item(view, profile_preset, WEAPON_LAYOUT.preview_slots[i])
		local context = Stats.collect_weapon_context(item, base_stats)

		if context then
			contexts[#contexts + 1] = context
		end
	end

	return contexts
end

function Stats.preferred_context(contexts, ranged)
	for i = 1, #contexts do
		local context = contexts[i]

		if ranged and context.is_ranged or not ranged and context.is_melee then
			return context
		end
	end

	return contexts[1]
end

function Stats.archetype_key(archetype)
	local wounds_by_archetype = Game.PlayerDifficultySettings and Game.PlayerDifficultySettings.archetype_wounds or {}
	local direct_name = archetype and (archetype.name or archetype.archetype)

	if direct_name and wounds_by_archetype[direct_name] then
		return direct_name
	end

	local talent_path = archetype and (archetype.talent_layout_file_path or archetype.talents_package_path or "")

	for key, _ in pairs(wounds_by_archetype) do
		if string.find(talent_path, key, 1, true) then
			return key
		end
	end

	return direct_name
end

function Stats.highest_difficulty_wounds(archetype)
	local archetype_name = Stats.archetype_key(archetype)
	local archetype_wounds = Game.PlayerDifficultySettings and Game.PlayerDifficultySettings.archetype_wounds or {}
	local wound_table = archetype_name and archetype_wounds[archetype_name]

	if wound_table and #wound_table > 0 then
		return wound_table[#wound_table]
	end

	return archetype_name == "ogryn" and 3 or 2
end

function Stats.format_number(value, decimals)
	if decimals and decimals > 0 then
		local scale = 10 ^ decimals
		local rounded_value = math.floor(value * scale + 0.5) / scale

		return string.format("%." .. decimals .. "f", rounded_value)
	end

	return tostring(math.floor(value + 0.5))
end

function Stats.format_optional_number(value, decimals, suffix)
	if not value then
		return "-"
	end

	return Stats.format_number(value, decimals) .. (suffix or "")
end

function Stats.format_percent(value)
	return string.format("%d%%", math.floor(value * 100 + 0.5))
end

function Stats.format_percent_bonus(value)
	local rounded_value = math.floor(value * 100 + 0.5)

	if rounded_value > 0 then
		return "+" .. tostring(rounded_value) .. "%"
	end

	return tostring(rounded_value) .. "%"
end

function Stats.paired_text(left, right)
	if left == right or not right then
		return left
	end

	if not left then
		return right
	end

	return left .. STAT_LAYOUT.pair_separator .. right
end

function Stats.weapon_pair(contexts, formatter, fallback)
	local melee_context = Stats.preferred_context(contexts, false)
	local ranged_context = Stats.preferred_context(contexts, true)
	local melee_text = melee_context and formatter(melee_context) or fallback
	local ranged_text = ranged_context and formatter(ranged_context) or fallback

	return Stats.paired_text(melee_text, ranged_text)
end

function Stats.context_stamina(archetype, context)
	local archetype_stamina = archetype and archetype.stamina or {}
	local weapon_stamina = context and context.stamina_template and Stats.number(context.stamina_template.stamina_modifier) or 0

	return (archetype_stamina.base_stamina or 0) + weapon_stamina + Stats.value(context and context.stats or {}, "stamina_modifier")
end

function Stats.context_weapon_crit_modifier(context)
	local weapon_handling_template = context and context.weapon_handling_template
	local critical_strike = weapon_handling_template and weapon_handling_template.critical_strike

	return Stats.number(critical_strike and critical_strike.chance_modifier) or 0
end

function Stats.context_crit_chance(archetype, context)
	local stats = context and context.stats or {}
	local chance = (archetype and archetype.base_critical_strike_chance or 0) + Stats.value(stats, "critical_strike_chance") + Stats.context_weapon_crit_modifier(context)

	if context and context.is_melee then
		chance = chance + Stats.value(stats, "melee_critical_strike_chance")
	elseif context and context.is_ranged then
		chance = chance + Stats.value(stats, "ranged_critical_strike_chance")
	end

	return math.max(math.min(chance, 1), 0)
end

function Stats.context_crit_damage(context)
	local stats = context and context.stats or {}
	local damage = Stats.value(stats, "critical_strike_damage") - 1

	if context and context.is_melee then
		damage = damage + Stats.value(stats, "melee_critical_strike_damage") - 1
	elseif context and context.is_ranged then
		damage = damage + Stats.value(stats, "ranged_critical_strike_damage") - 1
	end

	return damage
end

function Stats.context_dodges(context)
	local dodge_template = context and context.dodge_template
	local base_dodges = Stats.number(dodge_template and dodge_template.diminishing_return_start) or 2

	return math.ceil(base_dodges + Stats.value(context and context.stats or {}, "extra_consecutive_dodges"))
end

function Stats.context_dodge_distance(archetype, context)
	local dodge_template = context and context.dodge_template
	local archetype_dodge = archetype and archetype.dodge or {}
	local base_distance = Stats.number(dodge_template and dodge_template.base_distance) or archetype_dodge.base_distance or archetype_dodge.distance or 2.5
	local distance_scale = Stats.number(dodge_template and dodge_template.distance_scale) or 1
	local stats = context and context.stats or {}

	return base_distance * distance_scale * Stats.value(stats, "dodge_distance_modifier")
end

function Stats.context_sprint_speed(archetype, context)
	local sprint_template = archetype and archetype.sprint or {}
	local weapon_sprint_template = context and context.sprint_template
	local weapon_speed_mod = Stats.number(weapon_sprint_template and weapon_sprint_template.sprint_speed_mod) or 1
	local base_speed = (sprint_template.sprint_move_speed or 0) + weapon_speed_mod
	local stats = context and context.stats or {}

	return base_speed * Stats.value(stats, "sprint_movement_speed") * Stats.value(stats, "movement_speed")
end

function Stats.context_sprint_time(archetype, context)
	local max_stamina = Stats.context_stamina(archetype, context)
	local sprint_cost = Stats.number(context and context.stamina_template and context.stamina_template.sprint_cost_per_second)
	local cost_multiplier = Stats.value(context and context.stats or {}, "sprinting_cost_multiplier")

	if not sprint_cost or sprint_cost <= 0 or cost_multiplier <= 0 then
		return nil
	end

	return max_stamina / (sprint_cost * cost_multiplier)
end

function Stats.context_toughness_regen(archetype, context, standing_still)
	local toughness_template = archetype and archetype.toughness or {}
	local weapon_toughness_template = context and context.toughness_template
	local regeneration_speed = toughness_template.regeneration_speed or {}
	local weapon_regeneration_speed = weapon_toughness_template and weapon_toughness_template.regeneration_speed_modifier or {}
	local base_rate = standing_still and regeneration_speed.still or regeneration_speed.moving
	local weapon_rate_modifier = standing_still and weapon_regeneration_speed.still or weapon_regeneration_speed.moving
	local stats = context and context.stats or {}

	return (Stats.number(base_rate) or 0) * (Stats.number(weapon_rate_modifier) or 1) * Stats.value(stats, "toughness_regen_rate_modifier") * Stats.value(stats, "toughness_regen_rate_multiplier")
end

function Stats.context_toughness_regen_delay(archetype, context)
	local toughness_template = archetype and archetype.toughness or {}
	local weapon_toughness_template = context and context.toughness_template
	local weapon_modifier = Stats.number(weapon_toughness_template and weapon_toughness_template.regeneration_delay_modifier) or 1
	local stats = context and context.stats or {}

	return (toughness_template.regeneration_delay or 0) * weapon_modifier * Stats.value(stats, "toughness_regen_delay_modifier") * Stats.value(stats, "toughness_regen_delay_multiplier")
end

function Stats.context_toughness_melee_kill(archetype, context, max_toughness)
	if not context or not context.is_melee then
		return 0
	end

	local replenish_types = Game.ToughnessSettings and Game.ToughnessSettings.replenish_types or {}
	local recovery_type = replenish_types.melee_kill or "melee_kill"
	local toughness_template = archetype and archetype.toughness or {}
	local recovery_percentages = toughness_template.recovery_percentages or {}
	local weapon_toughness_template = context.toughness_template
	local weapon_modifiers = weapon_toughness_template and weapon_toughness_template.recovery_percentage_modifiers or {}
	local modifier = Stats.number(weapon_modifiers[recovery_type]) or 1
	local stats = context.stats
	local stat_buff_multiplier = Stats.value(stats, "toughness_melee_replenish") + Stats.value(stats, "toughness_replenish_modifier") - 1

	stat_buff_multiplier = stat_buff_multiplier * Stats.value(stats, "toughness_replenish_multiplier")

	return max_toughness * (recovery_percentages[recovery_type] or 0) * stat_buff_multiplier * modifier
end

function Stats.collect_preview_data(view, profile_preset, profile)
	profile = profile or Layouts.local_player_profile()

	local archetype = profile and profile.archetype

	if not archetype then
		return nil
	end

	local stats = {}

	Stats.apply_talents(stats, profile, profile_preset)

	for i = 1, #CURIO_LAYOUT.preview_slots do
		local item = resolve_loadout_item(view, profile_preset, CURIO_LAYOUT.preview_slots[i])

		Stats.apply_item_modifiers(stats, item, true)
	end

	local contexts = Stats.collect_weapon_contexts(view, profile_preset, stats)
	local primary_context = contexts[1] or {
		stats = stats,
	}
	local health = math.ceil((archetype.health or 0) * Stats.value(stats, "max_health_multiplier") * Stats.value(stats, "max_health_modifier"))
	local toughness_template = archetype.toughness or {}
	local toughness = math.ceil(((toughness_template.max or 0) + Stats.value(stats, "toughness")) * Stats.value(stats, "toughness_bonus")) + Stats.value(stats, "toughness_bonus_flat")
	local stamina_regen = (archetype.stamina and archetype.stamina.regeneration_per_second or 0) * Stats.value(stats, "stamina_regeneration_modifier") * Stats.value(stats, "stamina_regeneration_multiplier")
	local wounds = math.max(Stats.highest_difficulty_wounds(archetype) + Stats.value(stats, "extra_max_amount_of_wounds"), 1)
	local melee_context = Stats.preferred_context(contexts, false)
	local rows_by_key = {
		crit_chance = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_percent(Stats.context_crit_chance(archetype, context))
		end, Stats.format_percent(Stats.context_crit_chance(archetype, primary_context))) or Stats.format_percent(Stats.context_crit_chance(archetype, primary_context)),
		crit_damage = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_percent_bonus(Stats.context_crit_damage(context))
		end, Stats.format_percent_bonus(Stats.context_crit_damage(primary_context))) or Stats.format_percent_bonus(Stats.context_crit_damage(primary_context)),
		dodge_distance = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_dodge_distance(archetype, context), 1) .. "m"
		end, Stats.format_number(Stats.context_dodge_distance(archetype, primary_context), 1) .. "m") or Stats.format_number(Stats.context_dodge_distance(archetype, primary_context), 1) .. "m",
		dodges = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_dodges(context), 0)
		end, Stats.format_number(Stats.context_dodges(primary_context), 0)) or Stats.format_number(Stats.context_dodges(primary_context), 0),
		health = Stats.format_number(health, 0),
		stamina = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_stamina(archetype, context), 1)
		end, Stats.format_number(Stats.context_stamina(archetype, primary_context), 1)) or Stats.format_number(Stats.context_stamina(archetype, primary_context), 1),
		stamina_regen = Stats.format_number(stamina_regen, 1) .. "/s",
		sprint_speed = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_sprint_speed(archetype, context), 2)
		end, Stats.format_number(Stats.context_sprint_speed(archetype, primary_context), 2)) or Stats.format_number(Stats.context_sprint_speed(archetype, primary_context), 2),
		sprint_time = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_optional_number(Stats.context_sprint_time(archetype, context), 1, "s")
		end, Stats.format_optional_number(Stats.context_sprint_time(archetype, primary_context), 1, "s")) or Stats.format_optional_number(Stats.context_sprint_time(archetype, primary_context), 1, "s"),
		toughness = Stats.format_number(toughness, 0),
		toughness_melee_kill = Stats.format_number(Stats.context_toughness_melee_kill(archetype, melee_context, toughness), 1),
		toughness_regen_delay = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_toughness_regen_delay(archetype, context), 1) .. "s"
		end, Stats.format_number(Stats.context_toughness_regen_delay(archetype, primary_context), 1) .. "s") or Stats.format_number(Stats.context_toughness_regen_delay(archetype, primary_context), 1) .. "s",
		toughness_regen_moving = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_toughness_regen(archetype, context, false), 1) .. "/s"
		end, Stats.format_number(Stats.context_toughness_regen(archetype, primary_context, false), 1) .. "/s") or Stats.format_number(Stats.context_toughness_regen(archetype, primary_context, false), 1) .. "/s",
		toughness_regen_still = #contexts > 0 and Stats.weapon_pair(contexts, function (context)
			return Stats.format_number(Stats.context_toughness_regen(archetype, context, true), 1) .. "/s"
		end, Stats.format_number(Stats.context_toughness_regen(archetype, primary_context, true), 1) .. "/s") or Stats.format_number(Stats.context_toughness_regen(archetype, primary_context, true), 1) .. "/s",
		wounds = Stats.format_number(wounds, 0),
	}
	local rows = {}

	for i = 1, #STAT_LAYOUT.stat_rows do
		local row = STAT_LAYOUT.stat_rows[i]

		rows[#rows + 1] = {
			label = Settings.localize(row.label),
			value = rows_by_key[row.key] or "",
		}
	end

	return {
		rows = rows,
	}
end

local function selected_talents_for_layout(profile_preset, layout)
	local talents = profile_preset and profile_preset.talents
	local selected = {}
	local total_points = 0

	if type(talents) ~= "table" or not layout or type(layout.nodes) ~= "table" then
		return selected, total_points
	end

	local nodes = layout.nodes

	for i = 1, #nodes do
		local node = nodes[i]
		local node_name = node and node.widget_name
		local tier = node_name and talents[node_name]

		if tier and tier > 0 and node then
			selected[node_name] = tier
			total_points = total_points + tier * (node.cost or 0)
		end
	end

	return selected, total_points
end

local function collect_stimm_preview_data(profile_preset, profile, force_visible)
	if force_visible ~= true then
		return nil
	end

	profile = profile or Layouts.local_player_profile()

	local archetype = profile and profile.archetype
	local layout = Layouts.archetype_stimm(archetype)
	local selected, points = selected_talents_for_layout(profile_preset, layout)

	if points <= 0 then
		return nil
	end

	return {
		layout = layout,
		points = points,
		selected = selected,
	}
end

local function primary_preview_layout(profile_preset, profile)
	profile = profile or Layouts.local_player_profile()

	local archetype = profile and profile.archetype

	if not archetype then
		return nil, nil, 0
	end

	local layout = Layouts.archetype_talent(archetype)
	local selected, points = selected_talents_for_layout(profile_preset, layout)

	return layout, selected, points
end

local function node_type_size(node_type, selected, scale)
	scale = scale or 1

	if node_type == "stat" or node_type == "iconic" then
		return (selected and 22 or 16) * scale
	end

	if node_type == "start" then
		return 42 * scale
	end

	if node_type == "ability" or node_type == "aura" or node_type == "tactical" or node_type == "keystone" or node_type == "broker_stimm" then
		return (selected and 46 or 24) * scale
	end

	if node_type == "ability_modifier" or node_type == "aura_modifier" or node_type == "tactical_modifier" or node_type == "keystone_modifier" then
		return (selected and 26 or 18) * scale
	end

	return (selected and 24 or 16) * scale
end

local function is_stat_node(node_type, icon)
	return node_type == "stat" or node_type == "iconic" or icon == "content/ui/textures/frames/talents/circular_small_frame" or icon == "content/ui/materials/frames/talents/circular_small_bg"
end

function sanitize_widget_texture_content(widget)
	local content = widget and widget.content
	local passes = widget and widget.passes

	if type(content) ~= "table" or type(passes) ~= "table" then
		return
	end

	for i = 1, #passes do
		local pass = passes[i]
		local pass_type = pass and pass.pass_type

		if pass_type == "texture" or pass_type == "rotated_texture" then
			local value_id = pass.value_id
			local style = pass.style_id and widget.style and widget.style[pass.style_id] or nil
			local material_values = style and style.material_values

			if value_id and not valid_material_path(content[value_id]) then
				content[value_id] = string.sub(value_id, 1, 12) == "weapon_icon_" and WEAPON_LAYOUT.fallback_icon or PREVIEW_LAYOUTS.fallback_texture
			elseif not value_id and not valid_material_path(pass.value) then
				pass.value = PREVIEW_LAYOUTS.fallback_texture
			end

			if type(material_values) == "table" then
				if material_values.icon ~= nil and not valid_material_path(material_values.icon) then
					material_values.icon = PREVIEW_LAYOUTS.fallback_talent_icon
				end

				if material_values.icon_mask ~= nil and not valid_material_path(material_values.icon_mask) then
					material_values.icon_mask = nil
				end

				if material_values.frame ~= nil and not valid_material_path(material_values.frame) then
					material_values.frame = nil
				end

				if material_values.texture_map ~= nil and not valid_material_path(material_values.texture_map) then
					material_values.texture_map = PREVIEW_LAYOUTS.fallback_texture
				end
			end
		end
	end
end

local function source_node_size(node_type)
	local settings_by_node_type = TalentBuilderViewSettings and TalentBuilderViewSettings.settings_by_node_type or {}
	local settings = settings_by_node_type[node_type]
	local size = settings and settings.size

	return size and size[1] or 144, size and size[2] or 144
end

local function source_node_center(node)
	if not node then
		return 0, 0
	end

	local width, height = source_node_size(node.type)

	return (node.x or 0) + width * 0.5, (node.y or 0) + height * 0.5
end

local function source_node_connector(node)
	local center_x, center_y = source_node_center(node)
	local connector_offset = node and node.connector_offset

	if connector_offset then
		center_x = center_x + (connector_offset[1] or 0)
		center_y = center_y + (connector_offset[2] or 0)
	end

	return center_x, center_y
end

local function clamp(value, min_value, max_value)
	return math.max(min_value, math.min(max_value, value))
end

local function rounded(value)
	return math.floor(value + 0.5)
end

local function talent_layout_source_bounds(layout)
	local nodes = layout and layout.nodes

	if type(nodes) ~= "table" then
		return nil
	end

	local min_x, max_x, min_y, max_y

	for i = 1, #nodes do
		local node = nodes[i]

		if node then
			local center_x, center_y = source_node_center(node)
			local connector_x, connector_y = source_node_connector(node)
			local source_width, source_height = source_node_size(node.type)
			local half_width = source_width * 0.5
			local half_height = source_height * 0.5
			local node_min_x = center_x - half_width
			local node_max_x = center_x + half_width
			local node_min_y = center_y - half_height
			local node_max_y = center_y + half_height

			min_x = min_x and math.min(min_x, node_min_x, connector_x) or math.min(node_min_x, connector_x)
			max_x = max_x and math.max(max_x, node_max_x, connector_x) or math.max(node_max_x, connector_x)
			min_y = min_y and math.min(min_y, node_min_y, connector_y) or math.min(node_min_y, connector_y)
			max_y = max_y and math.max(max_y, node_max_y, connector_y) or math.max(node_max_y, connector_y)
		end
	end

	if not min_x then
		return nil
	end

	return {
		width = math.max(max_x - min_x, 1),
		height = math.max(max_y - min_y, 1),
	}
end

local function dynamic_tree_preview_layout(talent_layout)
	local layout = shallow_copy(PREVIEW_LAYOUTS.default)
	local bounds = talent_layout_source_bounds(talent_layout)

	if not bounds then
		return layout
	end

	local source_aspect = bounds.width / math.max(bounds.height, 1)
	local stretch_progress = clamp((source_aspect - 0.55) / 0.45, 0, 1)
	local vertical_stretch = 0.76 + stretch_progress * 0.24
	local target_aspect = bounds.width / math.max(bounds.height * vertical_stretch, 1)
	local map_width = clamp(rounded(PREVIEW_LAYOUTS.tree.target_height * target_aspect), PREVIEW_LAYOUTS.tree.min_width, PREVIEW_LAYOUTS.tree.max_width)
	local map_height = rounded(map_width / math.max(target_aspect, 0.1))

	if map_height > PREVIEW_LAYOUTS.tree.max_height then
		map_height = PREVIEW_LAYOUTS.tree.max_height
		map_width = clamp(rounded(map_height * target_aspect), PREVIEW_LAYOUTS.tree.min_width, PREVIEW_LAYOUTS.tree.max_width)
	elseif map_height < PREVIEW_LAYOUTS.tree.min_height then
		map_height = PREVIEW_LAYOUTS.tree.min_height
		map_width = clamp(rounded(map_height * target_aspect), PREVIEW_LAYOUTS.tree.min_width, PREVIEW_LAYOUTS.tree.max_width)
	end

	layout.map_width = map_width
	layout.map_height = map_height
	layout.tree_vertical_stretch = vertical_stretch
	layout.tree_vertical_offset = source_aspect < 0.58 and -10 or 0

	return layout
end

local function trim_line_endpoints(from_x, from_y, to_x, to_y, from_radius, to_radius)
	local distance = math.distance_2d(to_x, to_y, from_x, from_y)

	if distance <= 1 then
		return from_x, from_y, to_x, to_y, distance
	end

	local trim_start = math.min(from_radius * 0.65, distance * 0.4)
	local trim_end = math.min(to_radius * 0.65, distance * 0.4)
	local direction_x = (to_x - from_x) / distance
	local direction_y = (to_y - from_y) / distance
	local start_x = from_x + direction_x * trim_start
	local start_y = from_y + direction_y * trim_start
	local end_x = to_x - direction_x * trim_end
	local end_y = to_y - direction_y * trim_end

	return start_x, start_y, end_x, end_y, math.distance_2d(end_x, end_y, start_x, start_y)
end

local function add_line_pass(pass_template, index, from_x, from_y, to_x, to_y, selected, from_radius, to_radius)
	from_x, from_y, to_x, to_y = trim_line_endpoints(from_x, from_y, to_x, to_y, from_radius or 0, to_radius or 0)

	local distance = math.distance_2d(to_x, to_y, from_x, from_y)

	if distance <= 1 then
		return index
	end

	local angle = math.angle(to_x, to_y, from_x, from_y)
	local thickness = selected and 2 or 1
	local active_line_color = PREVIEW_LAYOUTS.tree.active_line_color
	local alpha = selected and active_line_color[1] or 55
	local color = selected and {
		active_line_color[1],
		active_line_color[2],
		active_line_color[3],
		active_line_color[4],
	} or {
		alpha,
		90,
		105,
		90,
	}

	index = index + 1
	pass_template[index] = {
		pass_type = "rotated_texture",
		style_id = "line_" .. index,
		value = "content/ui/materials/backgrounds/default_square",
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			angle = math.pi - angle,
			pivot = {
				0,
				thickness * 0.5,
			},
			offset = {
				from_x,
				from_y,
				selected and 2 or 1,
			},
			size = {
				distance,
				thickness,
			},
			color = color,
		},
	}

	return index
end

local function add_start_node_pass(pass_template, index, node, x, y, node_size_scale)
	if not valid_material_path(node.icon) then
		return index
	end

	local size = node_type_size(node.type, true, node_size_scale)
	local half_size = size * 0.5
	local style = {
		horizontal_alignment = "left",
		vertical_alignment = "top",
		offset = {
			x - half_size,
			y - half_size,
			7,
		},
		size = {
			size,
			size,
		},
		color = Color.white(255, true),
	}

	index = index + 1
	pass_template[index] = {
		pass_type = "texture",
		style_id = "node_start_" .. index,
		value = node.icon,
		style = style,
	}

	return index
end

local function add_node_marker_pass(pass_template, index, node_type, x, y, size, selected, has_icon)
	local marker_size = has_icon and math.max(size * 0.72, 10) or size
	local half_size = marker_size * 0.5
	local square = node_type == "tactical"
		or node_type == "tactical_modifier"
		or node_type == "ability_modifier"
		or node_type == "aura_modifier"
		or node_type == "keystone_modifier"
	local selected_color = has_icon and {
		110,
		34,
		50,
		34,
	} or {
		145,
		210,
		194,
		142,
	}
	local inactive_color = {
		has_icon and 55 or 70,
		55,
		70,
		55,
	}

	index = index + 1
	pass_template[index] = {
		pass_type = square and "rect" or "circle",
		style_id = "node_marker_" .. index,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = {
				x - half_size,
				y - half_size,
				selected and 4 or 2,
			},
			size = {
				marker_size,
				marker_size,
			},
			color = selected and selected_color or inactive_color,
		},
	}

	return index
end

local function add_stat_node_pass(pass_template, index, x, y, size, selected)
	local half_size = size * 0.5

	index = index + 1
	pass_template[index] = {
		pass_type = "texture",
		style_id = "node_stat_" .. index,
		value = PREVIEW_LAYOUTS.stat_node_material,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			ignore_icon = true,
			offset = {
				x - half_size,
				y - half_size,
				selected and 6 or 4,
			},
			size = {
				size,
				size,
			},
			color = selected and {
				255,
				125,
				205,
				255,
			} or {
				80,
				70,
				85,
				75,
			},
			material_values = {
				intensity = selected and -0.1 or -0.65,
				saturation = selected and 1 or 0.25,
			},
		},
	}

	return index
end

local function node_icon_material_values(node_type, icon, selected)
	local settings_by_node_type = TalentBuilderViewSettings and TalentBuilderViewSettings.settings_by_node_type or {}
	local settings = settings_by_node_type[node_type] or settings_by_node_type.default or {}

	return {
		frame = safe_material_path(settings.frame, "content/ui/textures/frames/talents/circular_frame"),
		frame_intensity = selected and 1 or 0.35,
		gradient_map = valid_material_path(settings.gradient_map) and settings.gradient_map or nil,
		icon = icon,
		icon_mask = safe_material_path(settings.icon_mask, "content/ui/textures/frames/talents/circular_frame_mask"),
		intensity = selected and -0.1 or -0.65,
		saturation = selected and 1 or 0.25,
	}
end

local function add_talent_icon_pass(pass_template, index, node_type, icon, x, y, size, selected)
	local icon_size = size
	local icon_half_size = icon_size * 0.5

	index = index + 1
	pass_template[index] = {
		pass_type = "texture",
		style_id = "node_icon_" .. index,
		value = PREVIEW_LAYOUTS.talent_icon_material,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = {
				x - icon_half_size,
				y - icon_half_size,
				selected and 6 or 4,
			},
			size = {
				icon_size,
				icon_size,
			},
			color = Color.white(selected and 255 or 135, true),
			material_values = node_icon_material_values(node_type, icon, selected),
		},
	}

	return index
end

local function add_node_passes(pass_template, index, node, x, y, selected, node_size_scale)
	local node_type = node.type
	local size = node_type_size(node_type, selected, node_size_scale)
	local icon = valid_material_path(node.icon) and node.icon or nil
	local stat_node = is_stat_node(node_type, icon)
	local has_icon = icon and not stat_node

	if node_type == "start" and icon then
		index = add_start_node_pass(pass_template, index, node, x, y, node_size_scale)
	elseif stat_node then
		index = add_stat_node_pass(pass_template, index, x, y, size, selected)
	elseif has_icon then
		index = add_node_marker_pass(pass_template, index, node_type, x, y, size, selected, true)
		index = add_talent_icon_pass(pass_template, index, node_type, icon, x, y, size, selected)
	else
		index = add_node_marker_pass(pass_template, index, node_type, x, y, size, selected, false)
	end

	return index
end

local function line_is_selected(parent, child, selected)
	selected = selected or {}

	return parent and child and selected[child.widget_name] and (parent.type == "start" or selected[parent.widget_name])
end

local function compact_selected_nodes(talent_layout, selected)
	local nodes = talent_layout and talent_layout.nodes
	local nodes_by_type = {}
	local ordered_nodes = {}

	if type(nodes) ~= "table" then
		return ordered_nodes
	end

	for i = 1, #nodes do
		local node = nodes[i]

		if node and selected[node.widget_name] and not nodes_by_type[node.type] then
			for j = 1, #PREVIEW_LAYOUTS.compact_talent.node_order do
				if node.type == PREVIEW_LAYOUTS.compact_talent.node_order[j] then
					nodes_by_type[node.type] = node

					break
				end
			end
		end
	end

	for i = 1, #PREVIEW_LAYOUTS.compact_talent.node_order do
		local node = nodes_by_type[PREVIEW_LAYOUTS.compact_talent.node_order[i]]

		if node then
			ordered_nodes[#ordered_nodes + 1] = node
		end
	end

	return ordered_nodes
end

local function build_compact_talents_pass_template(nodes, preview_layout)
	nodes = type(nodes) == "table" and nodes or {}
	preview_layout = preview_layout or PREVIEW_LAYOUTS.compact

	local pass_template = {}
	local icon_count = #nodes

	if icon_count == 0 then
		return pass_template
	end

	local total_width = PREVIEW_LAYOUTS.compact_talent.icon_gap * (icon_count - 1)

	for i = 1, icon_count do
		local node = nodes[i]

		if node then
			total_width = total_width + node_type_size(node.type, true)
		end
	end

	local x = (preview_layout.map_width - total_width) * 0.5
	local y = preview_layout.map_height * 0.5 + (preview_layout.icon_vertical_offset or 0)
	local pass_index = 0

	for i = 1, icon_count do
		local node = nodes[i]

		if node then
			local size = node_type_size(node.type, true)

			pass_index = add_node_passes(pass_template, pass_index, node, x + size * 0.5, y, true)
			x = x + size + PREVIEW_LAYOUTS.compact_talent.icon_gap
		end
	end

	return pass_template
end

local function build_talent_map_pass_template(layout, selected, preview_layout)
	local nodes = layout and layout.nodes
	local pass_template = {}

	if type(nodes) ~= "table" then
		return pass_template
	end

	selected = selected or {}
	preview_layout = preview_layout or PREVIEW_LAYOUTS.default

	local min_x, max_x, min_y, max_y
	local max_node_radius = 0
	local node_size_scale = preview_layout.node_size_scale or 1

	for i = 1, #nodes do
		local node = nodes[i]

		if node then
			local center_x, center_y = source_node_center(node)
			local connector_x, connector_y = source_node_connector(node)
			local node_radius = node_type_size(node.type, selected[node.widget_name], node_size_scale) * 0.5

			max_node_radius = math.max(max_node_radius, node_radius)
			min_x = min_x and math.min(min_x, center_x, connector_x) or math.min(center_x, connector_x)
			max_x = max_x and math.max(max_x, center_x, connector_x) or math.max(center_x, connector_x)
			min_y = min_y and math.min(min_y, center_y, connector_y) or math.min(center_y, connector_y)
			max_y = max_y and math.max(max_y, center_y, connector_y) or math.max(center_y, connector_y)
		end
	end

	if not min_x then
		return pass_template
	end

	local map_width = preview_layout.map_width or PREVIEW_LAYOUTS.default.map_width
	local map_height = preview_layout.map_height or PREVIEW_LAYOUTS.default.map_height
	local map_padding = preview_layout.map_padding or 0
	local node_edge_padding = preview_layout.node_edge_padding or 0
	local tree_vertical_stretch = preview_layout.tree_vertical_stretch or 1
	local tree_vertical_offset = preview_layout.tree_vertical_offset or 0
	local edge_radius = max_node_radius + node_edge_padding
	local width = math.max(max_x - min_x, 1)
	local height = math.max(max_y - min_y, 1)
	local usable_width = map_width - map_padding * 2
	local usable_height = map_height - map_padding * 2
	local center_usable_width = math.max(usable_width - edge_radius * 2, 1)
	local center_usable_height = math.max(usable_height - edge_radius * 2, 1)
	local scale = math.min(center_usable_width / width, center_usable_height / (height * tree_vertical_stretch))
	local source_padding_x = edge_radius / math.max(scale, 0.001)
	local source_padding_y = edge_radius / math.max(scale * tree_vertical_stretch, 0.001)

	min_x = min_x - source_padding_x
	max_x = max_x + source_padding_x
	min_y = min_y - source_padding_y
	max_y = max_y + source_padding_y

	width = math.max(max_x - min_x, 1)
	height = math.max(max_y - min_y, 1)
	scale = math.min(usable_width / width, usable_height / (height * tree_vertical_stretch))

	local scaled_width = width * scale
	local scaled_height = height * scale * tree_vertical_stretch
	local left = (map_width - scaled_width) * 0.5
	local top = (map_height - scaled_height) * 0.5 + tree_vertical_offset
	local positions = {}
	local connector_positions = {}
	local nodes_by_name = {}

	for i = 1, #nodes do
		local node = nodes[i]

		if node and node.widget_name then
			local center_x, center_y = source_node_center(node)
			local connector_x, connector_y = source_node_connector(node)
			local x = left + (center_x - min_x) * scale
			local y = top + (center_y - min_y) * scale * tree_vertical_stretch
			local line_x = left + (connector_x - min_x) * scale
			local line_y = top + (connector_y - min_y) * scale * tree_vertical_stretch

			positions[node.widget_name] = {
				x,
				y,
			}
			connector_positions[node.widget_name] = {
				line_x,
				line_y,
			}
			nodes_by_name[node.widget_name] = node
		end
	end

	local pass_index = 0

	for i = 1, #nodes do
		local node = nodes[i]
		local from = node and connector_positions[node.widget_name]
		local children = node and node.children

		if type(children) == "table" and from then
			for j = 1, #children do
				local child_name = children[j]
					local child = nodes_by_name[child_name]
					local to = connector_positions[child_name]

					if child and to then
						local is_selected_line = line_is_selected(node, child, selected)
						local from_radius = node_type_size(node.type, selected[node.widget_name], node_size_scale) * 0.5
						local to_radius = node_type_size(child.type, selected[child.widget_name], node_size_scale) * 0.5

						pass_index = add_line_pass(pass_template, pass_index, from[1], from[2], to[1], to[2], is_selected_line, from_radius, to_radius)
					end
			end
		end
	end

	for i = 1, #nodes do
		local node = nodes[i]
		local position = node and positions[node.widget_name]

		if position then
			pass_index = add_node_passes(pass_template, pass_index, node, position[1], position[2], selected[node.widget_name], node_size_scale)
		end
	end

	return pass_template
end

local function append_passes_with_offset(destination, source, offset_x, offset_y, style_id_prefix)
	if not source then
		return
	end

	for i = 1, #source do
		local pass = table.clone(source[i])
		local style = pass.style

		if style_id_prefix and pass.style_id then
			pass.style_id = style_id_prefix .. pass.style_id
		end

		if style then
			style = table.clone(style)
			pass.style = style

			if style.material_values then
				style.material_values = table.clone(style.material_values)
			end

			if style.offset then
				style.offset = table.clone(style.offset)
				style.offset[1] = (style.offset[1] or 0) + offset_x
				style.offset[2] = (style.offset[2] or 0) + offset_y
			end
		end

		destination[#destination + 1] = pass
	end
end

local function stimm_preview_extra_height(stimm_data)
	return stimm_data and (PREVIEW_LAYOUTS.stimm.gap + PREVIEW_LAYOUTS.stimm.height) or 0
end

local function stimm_preview_map_layout(width)
	return {
		map_width = width,
		map_height = PREVIEW_LAYOUTS.stimm.height,
		map_padding = PREVIEW_LAYOUTS.stimm.map_padding,
		node_edge_padding = PREVIEW_LAYOUTS.stimm.node_edge_padding,
		node_size_scale = PREVIEW_LAYOUTS.stimm.node_size_scale,
		tree_vertical_offset = PREVIEW_LAYOUTS.stimm.tree_vertical_offset,
		tree_vertical_stretch = PREVIEW_LAYOUTS.stimm.tree_vertical_stretch,
	}
end

local function preview_layout_with_stimm(preview_layout, stimm_data)
	if not stimm_data then
		return preview_layout
	end

	local layout = shallow_copy(preview_layout)

	layout.map_height = preview_layout.map_height + stimm_preview_extra_height(stimm_data)

	return layout
end

local function build_talent_preview_pass_template(talent_pass_template, stimm_data, preview_layout)
	if not stimm_data then
		return talent_pass_template
	end

	local pass_template = {}

	append_passes_with_offset(pass_template, talent_pass_template, 0, 0)

	local stimm_y = preview_layout.map_height + PREVIEW_LAYOUTS.stimm.gap
	local stimm_layout = stimm_preview_map_layout(preview_layout.map_width)
	local stimm_pass_template = build_talent_map_pass_template(stimm_data.layout, stimm_data.selected, stimm_layout)

	append_passes_with_offset(pass_template, stimm_pass_template, 0, stimm_y, "stimm_")

	return pass_template
end

local function weapon_row_layout(weapon, text_mode, panel_width, weapon_icons_visible)
	local inner_width = (panel_width or GEAR_LAYOUT.panel_width) - GEAR_LAYOUT.panel_padding * 2
	local blessings = weapon and type(weapon.blessings) == "table" and weapon.blessings or {}
	local perks = weapon and type(weapon.perks) == "table" and weapon.perks or {}
	local blessing_descriptions_visible = weapon and weapon.blessing_descriptions_visible == true
	local blessing_count = preview_detail_line_count(blessings)
	local perk_count = preview_detail_line_count(perks)
	local detail_count = blessing_count + perk_count
	local show_icon = false

	if weapon_icons_visible ~= false and weapon and valid_material_path(weapon.icon) then
		show_icon = true
	end

	local show_text = text_mode or detail_count > 0 or not show_icon
	local text_width = inner_width - 20
	local detail_width = math.max(inner_width - 20, 60)
	local blessing_indent = blessing_descriptions_visible and WEAPON_LAYOUT.blessing_indent or 0
	local blessing_width = math.max(detail_width - blessing_indent, 40)
	local perk_text = perk_count > 0 and format_preview_detail_text(perks) or ""
	local blessing_text = blessing_count > 0 and format_preview_detail_text(blessings) or ""
	local name_lines = show_text and math.max(estimated_wrapped_line_count(weapon and weapon.text or "", text_width, WEAPON_LAYOUT.name_average_char_width), 1) or 0
	local perk_lines = perk_count > 0 and math.max(estimated_wrapped_line_count(perk_text, detail_width, WEAPON_LAYOUT.detail_average_char_width), perk_count) or 0
	local blessing_lines = blessing_count > 0 and math.max(estimated_wrapped_line_count(blessing_text, blessing_width, WEAPON_LAYOUT.detail_average_char_width), blessing_count) or 0
	local detail_group_gap = perk_lines > 0 and blessing_lines > 0 and WEAPON_LAYOUT.detail_group_gap or 0
	local detail_height = perk_lines * WEAPON_LAYOUT.detail_line_height + detail_group_gap + blessing_lines * WEAPON_LAYOUT.detail_line_height
	local name_height = name_lines * WEAPON_LAYOUT.name_line_height
	local header_height = show_icon and (WEAPON_LAYOUT.icon_height + (show_text and WEAPON_LAYOUT.icon_name_gap + name_height or 0)) or name_height

	return {
		blessing_count = blessing_count,
		blessing_descriptions_visible = blessing_descriptions_visible,
		blessing_indent = blessing_indent,
		blessing_lines = blessing_lines,
		blessing_text = blessing_text,
		blessing_width = blessing_width,
		detail_count = detail_count,
		detail_group_gap = detail_group_gap,
		detail_height = detail_height,
		detail_width = detail_width,
		header_height = header_height,
		inner_width = inner_width,
		name_height = name_height,
		name_lines = name_lines,
		perk_count = perk_count,
		perk_lines = perk_lines,
		perk_text = perk_text,
		show_icon = show_icon,
		show_text = show_text,
		text_width = text_width,
	}
end

local function gear_weapon_row_height(gear_data, weapon, compact, panel_width)
	local layout = weapon_row_layout(weapon, gear_data.text_mode, panel_width, gear_data.weapon_icons_visible)
	local icon_height = layout.show_icon and WEAPON_LAYOUT.icon_height + WEAPON_LAYOUT.row_vertical_padding or 0

	if layout.detail_count > 0 then
		local text_height = WEAPON_LAYOUT.name_top_padding + layout.header_height + WEAPON_LAYOUT.detail_gap + layout.detail_height + WEAPON_LAYOUT.row_vertical_padding

		return math.max(WEAPON_LAYOUT.row_height_details, icon_height, text_height)
	end

	if layout.show_text then
		local text_height = WEAPON_LAYOUT.name_top_padding + layout.header_height + WEAPON_LAYOUT.row_vertical_padding

		return math.max(WEAPON_LAYOUT.row_height_text, icon_height, text_height)
	end

	return math.max(WEAPON_LAYOUT.row_height, icon_height)
end

local function gear_curio_row_height(curio)
	local perks = curio and type(curio.perks) == "table" and curio.perks or nil

	if perks and #perks > 0 then
		return CURIO_LAYOUT.row_height_perks
	end

	return CURIO_LAYOUT.row_height
end

local function gear_content_height(gear_data, compact, panel_width)
	local height = 0
	local weapons = gear_data and type(gear_data.weapons) == "table" and gear_data.weapons or nil
	local curios = gear_data and type(gear_data.curios) == "table" and gear_data.curios or nil

	if weapons and #weapons > 0 then
		height = height + GEAR_LAYOUT.section_header_height

		for i = 1, #weapons do
			height = height + gear_weapon_row_height(gear_data, weapons[i], compact, panel_width)
		end
	end

	if curios and #curios > 0 then
		if weapons and #weapons > 0 then
			height = height + GEAR_LAYOUT.section_gap
		end

		height = height + GEAR_LAYOUT.section_header_height

		for i = 1, #curios do
			height = height + gear_curio_row_height(curios[i])
		end
	end

	return height
end

local function gear_panel_height(gear_data, compact, panel_width)
	return math.max(GEAR_LAYOUT.panel_padding * 2 + gear_content_height(gear_data, compact, panel_width), 80)
end

local function stats_panel_height(stats_data)
	local rows = stats_data and stats_data.rows
	local row_count = rows and #rows or 0
	local rows_height = row_count > 0 and row_count * STAT_LAYOUT.row_height + (row_count - 1) * STAT_LAYOUT.row_gap or 0

	return math.max(STAT_LAYOUT.panel_padding * 2 + STAT_LAYOUT.title_height + STAT_LAYOUT.title_gap + rows_height, STAT_LAYOUT.min_height)
end

local function add_stats_panel_passes(pass_template, stats_data, panel_x, panel_y, panel_width)
	local rows = stats_data and stats_data.rows
	local width = panel_width or STAT_LAYOUT.panel_width
	local inner_width = width - STAT_LAYOUT.panel_padding * 2
	local cursor_y = panel_y + STAT_LAYOUT.panel_padding
	local x = panel_x + STAT_LAYOUT.panel_padding

	pass_template[#pass_template + 1] = {
		pass_type = "text",
		style_id = "preview_stats_title",
		value = "",
		value_id = "preview_stats_title",
		style = {
			font_size = 18,
			font_type = "proxima_nova_bold",
			text_horizontal_alignment = "center",
			text_vertical_alignment = "center",
			text_color = Color.terminal_text_header(255, true),
			offset = {
				x,
				cursor_y,
				5,
			},
			size = {
				inner_width,
				STAT_LAYOUT.title_height,
			},
		},
	}

	cursor_y = cursor_y + STAT_LAYOUT.title_height + STAT_LAYOUT.title_gap

	if not rows then
		return
	end

	for i = 1, #rows do
		local row_y = cursor_y
		local label_id = "stats_label_" .. i
		local value_id = "stats_value_" .. i

		pass_template[#pass_template + 1] = {
			pass_type = "rect",
			style_id = "stats_row_bg_" .. i,
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				offset = {
					x,
					row_y,
					1,
				},
				size = {
					inner_width,
					STAT_LAYOUT.row_height,
				},
				color = Color.terminal_background_dark(95, true),
			},
		}
		pass_template[#pass_template + 1] = {
			pass_type = "text",
			style_id = label_id,
			value = "",
			value_id = label_id,
			style = {
				font_size = 15,
				font_type = "proxima_nova_medium",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_body(220, true),
				offset = {
					x + 8,
					row_y,
					5,
				},
				size = {
					STAT_LAYOUT.label_width,
					STAT_LAYOUT.row_height,
				},
			},
		}
		pass_template[#pass_template + 1] = {
			pass_type = "text",
			style_id = value_id,
			value = "",
			value_id = value_id,
			style = {
				font_size = 15,
				font_type = "proxima_nova_bold",
				text_horizontal_alignment = "right",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_header(255, true),
				offset = {
					x + inner_width - STAT_LAYOUT.value_width - 8,
					row_y,
					6,
				},
				size = {
					STAT_LAYOUT.value_width,
					STAT_LAYOUT.row_height,
				},
			},
		}

		cursor_y = cursor_y + STAT_LAYOUT.row_height + STAT_LAYOUT.row_gap
	end
end

local function tree_preview_layout_for_gear(preview_layout, gear_data, extra_talent_height)
	local gear_height = gear_data and gear_panel_height(gear_data, false, GEAR_LAYOUT.panel_width) or 0
	local target_height = gear_height - (extra_talent_height or 0)

	if target_height <= (preview_layout.map_height or 0) then
		return preview_layout
	end

	local layout = shallow_copy(preview_layout)

	layout.map_height = target_height

	return layout
end

local function add_gear_section_header(pass_template, text_id, x, y, panel_width)
	local inner_width = (panel_width or GEAR_LAYOUT.panel_width) - GEAR_LAYOUT.panel_padding * 2

	pass_template[#pass_template + 1] = {
		pass_type = "text",
		style_id = text_id,
		value = "",
		value_id = text_id,
		style = {
			font_size = 18,
			font_type = "proxima_nova_bold",
			text_horizontal_alignment = "center",
			text_vertical_alignment = "center",
			text_color = Color.terminal_text_header(255, true),
			offset = {
				x,
				y,
				5,
			},
			size = {
				inner_width,
				GEAR_LAYOUT.section_header_height,
			},
		},
	}
end

local function add_weapon_row_passes(pass_template, weapon_index, weapon, x, y, text_mode, panel_width, row_height, weapon_icons_visible)
	local layout = weapon_row_layout(weapon, text_mode, panel_width, weapon_icons_visible)
	local inner_width = layout.inner_width
	local blessing_count = layout.blessing_count
	local detail_count = layout.detail_count
	local perk_count = layout.perk_count
	local show_icon = layout.show_icon
	local show_text = layout.show_text
	row_height = row_height or WEAPON_LAYOUT.row_height

	local header_y = detail_count > 0 and y + WEAPON_LAYOUT.name_top_padding or y + math.max((row_height - layout.header_height) * 0.5, 4)
	local icon_x = x + (inner_width - WEAPON_LAYOUT.icon_width) * 0.5
	local icon_y = show_icon and header_y or y
	local text_x = x + 10
	local text_width = layout.text_width
	local detail_width = layout.detail_width
	local name_height = layout.name_height
	local perk_height = layout.perk_lines * WEAPON_LAYOUT.detail_line_height + 2
	local blessing_height = layout.blessing_lines * WEAPON_LAYOUT.detail_line_height + 2
	local detail_y = y + WEAPON_LAYOUT.name_top_padding + layout.header_height + WEAPON_LAYOUT.detail_gap
	local detail_x = x + 10
	local blessing_x = detail_x + layout.blessing_indent
	local blessing_y = detail_y + (perk_count > 0 and perk_height + layout.detail_group_gap or 0)
	local icon_value_id = "weapon_icon_" .. weapon_index
	local name_y = show_icon and icon_y + WEAPON_LAYOUT.icon_height + WEAPON_LAYOUT.icon_name_gap or header_y
	local icon = show_icon and safe_material_path(weapon.icon, WEAPON_LAYOUT.fallback_icon) or nil

	pass_template[#pass_template + 1] = {
		pass_type = "rect",
		style_id = "weapon_row_bg_" .. weapon_index,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = {
				x,
				y + 4,
				1,
			},
			size = {
				inner_width,
				math.max(row_height - 8, WEAPON_LAYOUT.icon_height),
			},
			color = Color.terminal_background_dark(120, true),
		},
	}
	if show_icon then
		pass_template[#pass_template + 1] = {
			pass_type = "texture",
			style_id = icon_value_id,
			value = icon,
			value_id = icon_value_id,
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_text_body(255, true),
				offset = {
					icon_x,
					icon_y,
					5,
				},
				size = {
					WEAPON_LAYOUT.icon_width,
					WEAPON_LAYOUT.icon_height,
				},
				uvs = {
					{
						0,
						0,
					},
					{
						1,
						1,
					},
				},
			},
		}
	end

	if show_text then
		pass_template[#pass_template + 1] = {
			pass_type = "text",
			style_id = "weapon_text_" .. weapon_index,
			value = "",
			value_id = "weapon_text_" .. weapon_index,
			style = {
				font_size = 16,
				font_type = "proxima_nova_medium",
				text_horizontal_alignment = show_icon and "center" or "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_body(235, true),
				offset = {
					text_x,
					name_y,
					6,
				},
				size = {
					text_width,
					name_height,
				},
			},
		}

		if detail_count > 0 then
			if perk_count > 0 then
				pass_template[#pass_template + 1] = {
					pass_type = "text",
					style_id = "weapon_perk_text_" .. weapon_index,
					value = "",
					value_id = "weapon_perk_text_" .. weapon_index,
					style = {
						font_size = 13,
						font_type = "proxima_nova_medium",
						text_horizontal_alignment = "center",
						text_vertical_alignment = "top",
						text_color = Color.terminal_text_body(205, true),
						offset = {
							detail_x,
							detail_y,
							6,
						},
						size = {
							detail_width,
							perk_height,
						},
					},
				}
			end

			if blessing_count > 0 then
				pass_template[#pass_template + 1] = {
					pass_type = "text",
					style_id = "weapon_blessing_text_" .. weapon_index,
					value = "",
					value_id = "weapon_blessing_text_" .. weapon_index,
					style = {
						font_size = 13,
						font_type = "proxima_nova_bold",
						text_horizontal_alignment = layout.blessing_descriptions_visible and "left" or "center",
						text_vertical_alignment = "top",
						text_color = Color.terminal_text_body(205, true),
						offset = {
							blessing_x,
							blessing_y,
							6,
						},
						size = {
							layout.blessing_width,
							blessing_height,
						},
					},
				}
			end
		end
	end
end

local function add_curio_row_passes(pass_template, curio_index, curio, x, y, panel_width, row_height)
	local inner_width = (panel_width or GEAR_LAYOUT.panel_width) - GEAR_LAYOUT.panel_padding * 2
	local perks = curio and curio.perks
	local perk_count = perks and #perks or 0

	row_height = row_height or CURIO_LAYOUT.row_height

	pass_template[#pass_template + 1] = {
		pass_type = "rect",
		style_id = "curio_row_bg_" .. curio_index,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = {
				x,
				y + 2,
				1,
			},
			size = {
				inner_width,
				row_height - 4,
			},
			color = Color.terminal_background_dark(95, true),
		},
	}
	pass_template[#pass_template + 1] = {
		pass_type = "text",
		style_id = "curio_text_" .. curio_index,
		value = "",
		value_id = "curio_text_" .. curio_index,
		style = {
			font_size = 17,
			font_type = "proxima_nova_bold",
			text_horizontal_alignment = "center",
			text_vertical_alignment = perk_count > 0 and "top" or "center",
			text_color = Color.terminal_text_header(255, true),
			offset = {
				x + 8,
				perk_count > 0 and y + 4 or y,
				5,
			},
			size = {
				inner_width - 16,
				CURIO_LAYOUT.row_height,
			},
		},
	}

	if perk_count > 0 then
		pass_template[#pass_template + 1] = {
			pass_type = "text",
			style_id = "curio_perk_text_" .. curio_index,
			value = "",
			value_id = "curio_perk_text_" .. curio_index,
			style = {
				font_size = 12,
				font_type = "proxima_nova_medium",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_body(205, true),
				offset = {
					x + 8,
					y + 31,
					6,
				},
				size = {
					math.max(inner_width - 16, 60),
					perk_count * 15 + 4,
				},
			},
		}
	end
end

local function add_gear_content_passes(pass_template, gear_data, content_x, cursor_y, panel_width, compact)
	local weapons = gear_data and type(gear_data.weapons) == "table" and gear_data.weapons or nil
	local curios = gear_data and type(gear_data.curios) == "table" and gear_data.curios or nil

	if weapons and #weapons > 0 then
		add_gear_section_header(pass_template, "preview_weapons_title", content_x, cursor_y, panel_width)
		cursor_y = cursor_y + GEAR_LAYOUT.section_header_height

		for i = 1, #weapons do
			local weapon = weapons[i]
			local weapon_row_height = gear_weapon_row_height(gear_data, weapon, compact, panel_width)

			add_weapon_row_passes(pass_template, i, weapon, content_x, cursor_y, gear_data.text_mode, panel_width, weapon_row_height, gear_data.weapon_icons_visible)
			cursor_y = cursor_y + weapon_row_height
		end
	end

	if curios and #curios > 0 then
		if weapons and #weapons > 0 then
			cursor_y = cursor_y + GEAR_LAYOUT.section_gap
		end

		add_gear_section_header(pass_template, "preview_curios_title", content_x, cursor_y, panel_width)
		cursor_y = cursor_y + GEAR_LAYOUT.section_header_height

		for i = 1, #curios do
			local curio = curios[i]
			local curio_row_height = gear_curio_row_height(curio)

			add_curio_row_passes(pass_template, i, curio, content_x, cursor_y, panel_width, curio_row_height)
			cursor_y = cursor_y + curio_row_height
		end
	end
end

local function build_gear_pass_template(gear_data, panel_x, panel_y, panel_width)
	local pass_template = {}
	local width = panel_width or GEAR_LAYOUT.panel_width
	local cursor_y = panel_y + GEAR_LAYOUT.panel_padding
	local content_x = panel_x + GEAR_LAYOUT.panel_padding

	add_gear_content_passes(pass_template, gear_data, content_x, cursor_y, width)

	return pass_template
end

local function build_no_talents_pass_template(preview_layout)
	return {
		{
			pass_type = "text",
			style_id = "preview_no_talents",
			value = "",
			value_id = "preview_no_talents",
			style = {
				font_size = 20,
				font_type = "proxima_nova_bold",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_body(220, true),
				offset = {
					0,
					preview_layout.map_height * 0.5 - 20,
					6,
				},
				size = {
					preview_layout.map_width,
					40,
				},
			},
		},
	}
end

local function compact_gear_talent_layout(preview_layout)
	local layout = shallow_copy(preview_layout)

	layout.map_width = GEAR_LAYOUT.compact_preview_width
	layout.map_height = GEAR_LAYOUT.compact_talent_height
	layout.icon_vertical_offset = 0

	return layout
end

local function compact_gear_content_y(preview_layout)
	return preview_layout.map_height + GEAR_LAYOUT.compact_content_gap + GEAR_LAYOUT.compact_content_padding_top
end

local function compact_gear_preview_layout(preview_layout, gear_data)
	local combined_layout = shallow_copy(preview_layout)

	combined_layout.preview_width = preview_layout.map_width
	combined_layout.preview_height = compact_gear_content_y(preview_layout) + gear_content_height(gear_data, true, combined_layout.preview_width) + GEAR_LAYOUT.compact_content_padding_bottom

	return combined_layout
end

local function combined_preview_layout(preview_layout, gear_data, talents_visible)
	local combined_layout = shallow_copy(preview_layout)
	local talent_width = talents_visible and preview_layout.map_width or 0
	local talent_height = talents_visible and preview_layout.map_height or 0
	local gear_width = gear_data and GEAR_LAYOUT.panel_width or 0
	local gear_height = gear_data and gear_panel_height(gear_data, false, gear_width) or 0
	local gap = talents_visible and gear_data and GEAR_LAYOUT.panel_gap or 0

	combined_layout.preview_width = talent_width + gap + gear_width
	combined_layout.preview_height = math.max(talent_height, gear_height)

	return combined_layout
end

local function build_compact_gear_preview_pass_template(talent_pass_template, gear_data, preview_layout)
	local pass_template = {}
	local preview_width = preview_layout.preview_width or preview_layout.map_width

	if talent_pass_template then
		append_passes_with_offset(pass_template, talent_pass_template, 0, 0)
	end

	add_gear_content_passes(pass_template, gear_data, GEAR_LAYOUT.panel_padding, compact_gear_content_y(preview_layout), preview_width, true)

	return pass_template
end

local function build_preview_pass_template(talent_pass_template, gear_data, preview_layout, talents_visible)
	local pass_template = {}

	if talent_pass_template then
		append_passes_with_offset(pass_template, talent_pass_template, 0, 0)
	end

	if gear_data then
		local panel_x = talents_visible and preview_layout.map_width + GEAR_LAYOUT.panel_gap or 0
		local panel_y = math.max(((preview_layout.preview_height or preview_layout.map_height) - gear_panel_height(gear_data, false, GEAR_LAYOUT.panel_width)) * 0.5, 0)
		local gear_pass_template = build_gear_pass_template(gear_data, panel_x, panel_y, GEAR_LAYOUT.panel_width)

		append_passes_with_offset(pass_template, gear_pass_template, 0, 0)
	end

	return pass_template
end

local function stats_combined_preview_layout(stats_data, gear_data)
	local layout = {
		map_width = STAT_LAYOUT.panel_width,
		map_height = stats_panel_height(stats_data),
	}
	local gear_width = gear_data and GEAR_LAYOUT.panel_width or 0
	local gear_height = gear_data and gear_panel_height(gear_data, false, gear_width) or 0
	local gap = gear_data and GEAR_LAYOUT.panel_gap or 0

	layout.preview_width = STAT_LAYOUT.panel_width + gap + gear_width
	layout.preview_height = math.max(layout.map_height, gear_height)

	return layout
end

local function build_stats_preview_pass_template(stats_data, gear_data, preview_layout)
	local pass_template = {}
	local stats_y = math.max(((preview_layout.preview_height or preview_layout.map_height) - stats_panel_height(stats_data)) * 0.5, 0)

	add_stats_panel_passes(pass_template, stats_data, 0, stats_y, STAT_LAYOUT.panel_width)

	if gear_data then
		local panel_x = STAT_LAYOUT.panel_width + GEAR_LAYOUT.panel_gap
		local panel_y = math.max(((preview_layout.preview_height or preview_layout.map_height) - gear_panel_height(gear_data, false, GEAR_LAYOUT.panel_width)) * 0.5, 0)
		local gear_pass_template = build_gear_pass_template(gear_data, panel_x, panel_y, GEAR_LAYOUT.panel_width)

		append_passes_with_offset(pass_template, gear_pass_template, 0, 0)
	end

	return pass_template
end

local function stats_left_preview_layout(stats_data, content_layout)
	local layout = shallow_copy(content_layout)
	local content_width = content_layout.preview_width or content_layout.map_width
	local content_height = content_layout.preview_height or content_layout.map_height
	local stats_width = stats_data and STAT_LAYOUT.panel_width or 0
	local stats_height = stats_data and stats_panel_height(stats_data) or 0
	local gap = stats_data and content_width > 0 and GEAR_LAYOUT.panel_gap or 0

	layout.preview_width = stats_width + gap + content_width
	layout.preview_height = math.max(stats_height, content_height)

	return layout
end

local function build_stats_left_preview_pass_template(stats_data, content_pass_template, content_layout, preview_layout)
	local pass_template = {}
	local preview_height = preview_layout.preview_height or preview_layout.map_height
	local stats_y = math.max((preview_height - stats_panel_height(stats_data)) * 0.5, 0)
	local content_x = STAT_LAYOUT.panel_width + GEAR_LAYOUT.panel_gap
	local content_y = math.max((preview_height - (content_layout.preview_height or content_layout.map_height)) * 0.5, 0)

	add_stats_panel_passes(pass_template, stats_data, 0, stats_y, STAT_LAYOUT.panel_width)
	append_passes_with_offset(pass_template, content_pass_template, content_x, content_y)

	return pass_template
end

local function add_talent_map(layout, talent_layout, selected, preview_layout)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_talent_map",
		loadout_organizer_preview_layout = preview_layout,
		size = {
			preview_layout.map_width,
			preview_layout.map_height,
		},
		pass_template = build_talent_map_pass_template(talent_layout, selected, preview_layout),
	}
end

local function add_compact_talents(layout, nodes, preview_layout)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_compact_talents",
		loadout_organizer_preview_layout = preview_layout,
		size = {
			preview_layout.map_width,
			preview_layout.map_height,
		},
		pass_template = build_compact_talents_pass_template(nodes, preview_layout),
	}
end

local function add_combined_preview(layout, talent_pass_template, gear_data, preview_layout, talents_visible)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_preview",
		loadout_organizer_preview_layout = preview_layout,
		gear_preview_data = gear_data,
		size = {
			preview_layout.preview_width or preview_layout.map_width,
			preview_layout.preview_height or preview_layout.map_height,
		},
		pass_template = build_preview_pass_template(talent_pass_template, gear_data, preview_layout, talents_visible),
	}
end

local function add_stats_combined_preview(layout, stats_data, gear_data, preview_layout)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_preview",
		loadout_organizer_preview_layout = preview_layout,
		gear_preview_data = gear_data,
		stats_preview_data = stats_data,
		size = {
			preview_layout.preview_width or preview_layout.map_width,
			preview_layout.preview_height or preview_layout.map_height,
		},
		pass_template = build_stats_preview_pass_template(stats_data, gear_data, preview_layout),
	}
end

local function add_stats_left_combined_preview(layout, stats_data, gear_data, content_pass_template, content_layout, preview_layout)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_preview",
		loadout_organizer_preview_layout = preview_layout,
		gear_preview_data = gear_data,
		stats_preview_data = stats_data,
		size = {
			preview_layout.preview_width or preview_layout.map_width,
			preview_layout.preview_height or preview_layout.map_height,
		},
		pass_template = build_stats_left_preview_pass_template(stats_data, content_pass_template, content_layout, preview_layout),
	}
end

local function add_compact_combined_preview(layout, talent_pass_template, gear_data, preview_layout)
	layout[#layout + 1] = {
		widget_type = "loadout_organizer_preview",
		loadout_organizer_preview_layout = preview_layout,
		gear_preview_data = gear_data,
		size = {
			preview_layout.preview_width or preview_layout.map_width,
			preview_layout.preview_height or preview_layout.map_height,
		},
		pass_template = build_compact_gear_preview_pass_template(talent_pass_template, gear_data, preview_layout),
	}
end

local function add_talent_only_preview(layout, talent_pass_template, preview_layout, mode)
	if not talent_pass_template or #talent_pass_template == 0 then
		return
	end

	layout[#layout + 1] = {
		widget_type = preview_mode_is_compact(mode) and "loadout_organizer_compact_talents" or "loadout_organizer_talent_map",
		loadout_organizer_preview_layout = preview_layout,
		size = {
			preview_layout.map_width,
			preview_layout.map_height,
		},
		pass_template = talent_pass_template,
	}
end

local function build_preview_layout(view, profile_preset, mode, profile, options)
	options = options or {}

	local layout = {}
	local stats_visible = not options.hide_stats and preview_mode_has_stats(mode) and Settings.show_stats_preview()
	local stats_only = preview_mode_stats_only(mode)
	local talents_visible = mode ~= PREVIEW_MODE.disabled and not stats_only
	local base_preview_layout = preview_layout_settings(mode)
	local gear_data
	local stats_data
	local stimm_data

	if not options.hide_gear then
		local _

		_, gear_data = Settings.safe_call("collect gear preview data", collect_gear_preview_data, view, profile_preset)
	end

	if stats_visible then
		local _

		_, stats_data = Settings.safe_call("collect stats preview data", Stats.collect_preview_data, view, profile_preset, profile)
	end

	local stimm_visible = options.show_stimm

	if stimm_visible == nil then
		stimm_visible = not options.hide_stimm and Settings.show_stimm_lab_preview()
	end

	if stimm_visible and talents_visible then
		local _

		_, stimm_data = Settings.safe_call("collect Stimm Lab preview data", collect_stimm_preview_data, profile_preset, profile, true)
	end
	local talent_preview_layout = base_preview_layout
	local talent_pass_template
	local compact_with_gear

	if stats_only then
		if not stats_data and not gear_data then
			return layout
		end

		local preview_layout = stats_data and stats_combined_preview_layout(stats_data, gear_data) or combined_preview_layout(base_preview_layout, gear_data, false)

		if stats_data then
			add_stats_combined_preview(layout, stats_data, gear_data, preview_layout)
		else
			add_combined_preview(layout, nil, gear_data, preview_layout, false)
		end

		return layout
	end

	if not talents_visible and not gear_data then
		return layout
	end

	if talents_visible then
		local _, selected_nodes = Settings.safe_call("collect selected talent nodes", sorted_selected_nodes, profile_preset, profile)
		local _, talent_result = Settings.safe_call("collect primary talent layout", function ()
			local talent_layout, map_selected = primary_preview_layout(profile_preset, profile)

			return {
				layout = talent_layout,
				selected = map_selected,
			}
		end)
		local talent_layout = talent_result and talent_result.layout
		local map_selected = talent_result and talent_result.selected or {}

		selected_nodes = selected_nodes or {}

		if talent_layout and preview_mode_is_tree(mode) then
			base_preview_layout = dynamic_tree_preview_layout(talent_layout)

			if mode ~= PREVIEW_MODE.tree_gear then
				base_preview_layout = tree_preview_layout_for_gear(base_preview_layout, gear_data, stimm_preview_extra_height(stimm_data))
			end

			talent_preview_layout = base_preview_layout
		end

		compact_with_gear = gear_data and preview_mode_is_compact(mode)

		if compact_with_gear then
			talent_preview_layout = compact_gear_talent_layout(base_preview_layout)
		end

		if #selected_nodes == 0 then
			if not gear_data and not stimm_data and not stats_data then
				add_spacing(layout, 10, talent_preview_layout)
				add_header(layout, Settings.localize("preview_no_talents"))
				add_spacing(layout, 10, talent_preview_layout)

				return layout
			end

			talent_pass_template = build_no_talents_pass_template(talent_preview_layout)
		elseif talent_layout and preview_mode_is_compact(mode) then
			talent_pass_template = build_compact_talents_pass_template(compact_selected_nodes(talent_layout, map_selected), talent_preview_layout)
		elseif talent_layout then
			talent_pass_template = build_talent_map_pass_template(talent_layout, map_selected, talent_preview_layout)
		end

		talent_pass_template = build_talent_preview_pass_template(talent_pass_template, stimm_data, talent_preview_layout)
		talent_preview_layout = preview_layout_with_stimm(talent_preview_layout, stimm_data)
	end

	if not gear_data then
		if stats_data and talent_pass_template then
			local preview_layout = stats_left_preview_layout(stats_data, talent_preview_layout)

			add_stats_left_combined_preview(layout, stats_data, nil, talent_pass_template, talent_preview_layout, preview_layout)

			return layout
		elseif stats_data then
			local preview_layout = stats_combined_preview_layout(stats_data)

			add_stats_combined_preview(layout, stats_data, nil, preview_layout)

			return layout
		end

		add_talent_only_preview(layout, talent_pass_template, talent_preview_layout, mode)

		return layout
	end

	if compact_with_gear then
		local content_layout = compact_gear_preview_layout(talent_preview_layout, gear_data)

		if stats_data then
			local content_pass_template = build_compact_gear_preview_pass_template(talent_pass_template, gear_data, content_layout)
			local preview_layout = stats_left_preview_layout(stats_data, content_layout)

			add_stats_left_combined_preview(layout, stats_data, gear_data, content_pass_template, content_layout, preview_layout)

			return layout
		end

		add_compact_combined_preview(layout, talent_pass_template, gear_data, content_layout)

		return layout
	end

	local content_layout = combined_preview_layout(talent_preview_layout, gear_data, talents_visible)

	if stats_data then
		local content_pass_template = build_preview_pass_template(talent_pass_template, gear_data, content_layout, talents_visible)
		local preview_layout = stats_left_preview_layout(stats_data, content_layout)

		add_stats_left_combined_preview(layout, stats_data, gear_data, content_pass_template, content_layout, preview_layout)

		return layout
	end

	add_combined_preview(layout, talent_pass_template, gear_data, content_layout, talents_visible)

	return layout
end

function TeamPreview.inject_overlay_scenegraph(definitions)
	local scenegraph_definition = definitions and definitions.scenegraph_definition

	if scenegraph_definition and not scenegraph_definition[TEAM_PREVIEW_LAYOUT.scenegraph_id] then
		scenegraph_definition[TEAM_PREVIEW_LAYOUT.scenegraph_id] = {
			horizontal_alignment = "left",
			parent = "canvas",
			vertical_alignment = "top",
			size = {
				0,
				0,
			},
			position = {
				0,
				0,
				TEAM_PREVIEW_LAYOUT.z,
			},
		}
	end

	if scenegraph_definition and not scenegraph_definition[TEAM_PREVIEW_LAYOUT.applicant_scenegraph_id] then
		scenegraph_definition[TEAM_PREVIEW_LAYOUT.applicant_scenegraph_id] = {
			horizontal_alignment = "left",
			parent = "canvas",
			vertical_alignment = "top",
			size = {
				0,
				0,
			},
			position = {
				0,
				0,
				TEAM_PREVIEW_LAYOUT.applicant_z,
			},
		}
	end
end

function TeamPreview.enabled(context)
	if context == "lobby" then
		return Settings.show_lobby_team_previews() and not lobby_team_previews_keybind_hidden
	elseif context == "mission_intro" then
		return Settings.show_mission_intro_team_previews() and not mission_intro_team_previews_keybind_hidden
	elseif context == "applicant" then
		return Settings.show_group_finder_applicant_previews()
	end

	return false
end

function TeamPreview.player_method(player, method_name)
	if not player then
		return nil, false
	end

	local ok, method = pcall(function ()
		return player[method_name]
	end)

	if not ok then
		return nil, false
	end

	if type(method) == "function" then
		return method, true
	end

	return nil, true
end

function TeamPreview.is_human_player(player)
	local is_human_controlled, valid_player = TeamPreview.player_method(player, "is_human_controlled")

	if not valid_player then
		return false
	end

	if not is_human_controlled then
		return true
	end

	local ok, is_human = pcall(is_human_controlled, player)

	if ok then
		return is_human == true
	end

	return false
end

function TeamPreview.is_local_player(player)
	local player_manager = Managers and Managers.player

	if not player or not player_manager then
		return false
	end

	local method_ok, local_player_method = pcall(function ()
		return player_manager.local_player
	end)

	if not method_ok or type(local_player_method) ~= "function" then
		return false
	end

	local ok, local_player = Settings.safe_call("get local player for team preview", local_player_method, player_manager, 1)

	if ok then
		return player == local_player
	end

	return false
end

function TeamPreview.should_show_lobby_slot(slot)
	if not slot or not slot.occupied then
		return false
	end

	local player = slot.player

	if not TeamPreview.is_human_player(player) then
		return false
	end

	if TeamPreview.is_local_player(player) and not Settings.show_own_lobby_team_preview() then
		return false
	end

	return true
end

function TeamPreview.player_profile(player)
	local profile = TeamPreview.player_method(player, "profile")

	if not profile then
		return nil
	end

	local ok, result = pcall(profile, player)

	if ok and result then
		return result
	end

	return nil
end

function TeamPreview.player_name(player)
	local name = TeamPreview.player_method(player, "name")

	if not name then
		return nil
	end

	local ok, result = pcall(name, player)

	if ok and result then
		return result
	end

	return nil
end

function TeamPreview.profile_title(player, profile)
	local name = tostring(TeamPreview.player_name(player) or Settings.localize("team_preview_unknown_player"))
	local ok, archetype_title = Settings.safe_call("team preview archetype title", ProfileUtils and ProfileUtils.character_archetype_title, profile)

	if ok and archetype_title and archetype_title ~= "" then
		return string.format("%s - %s", name, archetype_title)
	end

	return name
end

function TeamPreview.slot_key(slot)
	local player = slot and slot.player
	local unique_id = TeamPreview.player_method(player, "unique_id")

	if unique_id then
		local ok, value = pcall(unique_id, player)

		if ok and value ~= nil then
			return tostring(value)
		end
	end

	local name = TeamPreview.player_name(player)

	return tostring(name or slot and slot.index or "")
end

function TeamPreview.profile_preset(profile)
	if not profile then
		return nil
	end

	local ok, data = pcall(function ()
		return {
			loadout = profile.loadout,
			talents = profile.selected_nodes or {},
		}
	end)

	if not ok then
		Settings.report_guarded_error("read player profile preset", data)

		return nil
	end

	return data
end

function TeamPreview.profile_key(player, profile, title)
	return TeamPreview.profile_key_for_mode(player, profile, title, PREVIEW_MODE.compact, false)
end

function TeamPreview.setting_scope(context)
	return context == "mission_intro" and "valkyrie" or "team"
end

function TeamPreview.with_context_settings(context, callback)
	return Settings.with_preview_settings(TeamPreview.setting_scope(context), callback)
end

function TeamPreview.profile_key_for_mode(player, profile, title, mode, tree_only, context)
	local settings_key = TeamPreview.with_context_settings(context, function ()
		return Settings.preview_key(mode or PREVIEW_MODE.compact)
	end) or ""
	local stimm_visible = TeamPreview.with_context_settings(context, function ()
		return Settings.show_stimm_lab_preview()
	end)
	local pieces = {
		tostring(settings_key),
		"stimm=" .. tostring(stimm_visible),
		tree_only and "tree_only" or "standard",
		tostring(title or ""),
	}

	local unique_id = TeamPreview.player_method(player, "unique_id")

	if unique_id then
		local ok, value = pcall(unique_id, player)

		if ok then
			unique_id = value
		else
			unique_id = nil
		end
	end

	pieces[#pieces + 1] = tostring(unique_id)

	local loadout = profile and profile.loadout

	for i = 1, #WEAPON_LAYOUT.preview_slots do
		pieces[#pieces + 1] = tostring(loadout_slot_gear_id(loadout, WEAPON_LAYOUT.preview_slots[i]))
	end

	for i = 1, #CURIO_LAYOUT.preview_slots do
		pieces[#pieces + 1] = tostring(loadout_slot_gear_id(loadout, CURIO_LAYOUT.preview_slots[i]))
	end

	local selected_nodes = profile and profile.selected_nodes

	if type(selected_nodes) == "table" then
		local names = {}

		for name, _ in pairs(selected_nodes) do
			names[#names + 1] = name
		end

		table.sort(names)

		for i = 1, #names do
			local name = names[i]

			pieces[#pieces + 1] = tostring(name) .. "=" .. tostring(selected_nodes[name])
		end
	end

	return table.concat(pieces, "|")
end

function TeamPreview.preview_element(layout)
	if type(layout) ~= "table" then
		return nil
	end

	for i = 1, #layout do
		local element = layout[i]
		local widget_type = element.widget_type

		if element.pass_template and element.size and (widget_type == "loadout_organizer_preview" or widget_type == "loadout_organizer_compact_talents" or widget_type == "loadout_organizer_talent_map") then
			return element
		end
	end
end

function TeamPreview.add_panel_passes(pass_template, width, height, has_title, has_hotspot, title_text_y)
	pass_template[#pass_template + 1] = {
		pass_type = "rect",
		style_id = "team_preview_tooltip_icon_bg",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			offset = {
				0,
				0,
				0,
			},
			size_addition = {
				-24,
				-24,
			},
			color = Color.terminal_grid_background_icon(255, true),
		},
	}
	pass_template[#pass_template + 1] = {
		pass_type = "texture",
		style_id = "team_preview_tooltip_bg",
		value = "content/ui/materials/backgrounds/terminal_basic",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			offset = {
				0,
				0,
				1,
			},
			color = Color.terminal_grid_background(255, true),
		},
	}

	if has_title then
		pass_template[#pass_template + 1] = {
			pass_type = "text",
			style_id = "team_preview_title",
			value = "",
			value_id = "team_preview_title",
			style = {
				font_size = 18,
				font_type = "proxima_nova_bold",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_header(255, true),
				offset = {
					0,
					title_text_y or TEAM_PREVIEW_LAYOUT.title_text_y,
					6,
				},
				size = {
					width,
					TEAM_PREVIEW_LAYOUT.title_text_height,
				},
			},
		}
	end

	if has_hotspot then
		pass_template[#pass_template + 1] = {
			content_id = "team_preview_hotspot",
			pass_type = "hotspot",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				offset = {
					0,
					0,
					8,
				},
				size = {
					width,
					height,
				},
			},
			content = {},
		}
	end
end

function TeamPreview.min_frame_size(context)
	if context == "lobby" then
		return TEAM_PREVIEW_LAYOUT.lobby_min_width, TEAM_PREVIEW_LAYOUT.lobby_min_height
	elseif context == "mission_intro" then
		return TEAM_PREVIEW_LAYOUT.loading_min_width, TEAM_PREVIEW_LAYOUT.loading_min_height
	end

	return nil, nil
end

function TeamPreview.wrap_element(element, title, context)
	if not element or type(element.size) ~= "table" then
		return nil
	end

	local has_title = title ~= nil and title ~= ""
	local content_width = element.size[1]
	local content_height = element.size[2]
	local preview_layout = element.loadout_organizer_preview_layout or {
		preview_width = content_width,
		preview_height = content_height,
	}
	local title_height = has_title and TEAM_PREVIEW_LAYOUT.title_height or 0
	local min_width, min_height = TeamPreview.min_frame_size(context)
	local width = math.max(preview_tooltip_width(preview_layout), min_width or 0)
	local content_area_height = preview_tooltip_height(preview_layout)
	local content_padding_top = TEAM_PREVIEW_LAYOUT.content_padding_top
	local content_padding_bottom = TEAM_PREVIEW_LAYOUT.content_padding_bottom
	local height = content_area_height + title_height + content_padding_top + content_padding_bottom

	if min_height and height < min_height then
		content_area_height = content_area_height + min_height - height
		height = min_height
	end

	local content_x = math.max((width - content_width) * 0.5, 0)
	local content_y = title_height + content_padding_top + math.max((content_area_height - content_height) * 0.5, 0)
	local has_hotspot = context == "lobby"
	local title_text_y = context == "mission_intro" and TEAM_PREVIEW_LAYOUT.loading_title_text_y or TEAM_PREVIEW_LAYOUT.title_text_y
	local pass_template = {}

	TeamPreview.add_panel_passes(pass_template, width, height, has_title, has_hotspot, title_text_y)
	append_passes_with_offset(pass_template, element.pass_template, content_x, content_y, "team_preview_")

	return {
		gear_preview_data = element.gear_preview_data,
		loadout_organizer_preview_layout = element.loadout_organizer_preview_layout,
		pass_template = pass_template,
		size = {
			width,
			height,
		},
		stats_preview_data = element.stats_preview_data,
		team_preview_title = title,
	}
end

function TeamPreview.scale_pass_template(pass_template, scale)
	if not pass_template or scale == 1 then
		return pass_template
	end

	local scaled_pass_template = {}

	for i = 1, #pass_template do
		local pass = table.clone(pass_template[i])
		local style = pass.style

		if style then
			style = table.clone(style)
			pass.style = style

			if style.material_values then
				style.material_values = table.clone(style.material_values)
			end

			if style.offset then
				style.offset = table.clone(style.offset)
				style.offset[1] = (style.offset[1] or 0) * scale
				style.offset[2] = (style.offset[2] or 0) * scale
			end

			if style.size then
				style.size = table.clone(style.size)
				style.size[1] = (style.size[1] or 0) * scale
				style.size[2] = (style.size[2] or 0) * scale
			end

			if style.size_addition then
				style.size_addition = table.clone(style.size_addition)
				style.size_addition[1] = (style.size_addition[1] or 0) * scale
				style.size_addition[2] = (style.size_addition[2] or 0) * scale
			end

			if style.pivot then
				style.pivot = table.clone(style.pivot)
				style.pivot[1] = (style.pivot[1] or 0) * scale
				style.pivot[2] = (style.pivot[2] or 0) * scale
			end

			if style.font_size then
				style.font_size = math.max(math.floor(style.font_size * scale + 0.5), 8)
			end
		end

		scaled_pass_template[i] = pass
	end

	return scaled_pass_template
end

function TeamPreview.scale_element(element, scale)
	if not element or scale == 1 then
		return element
	end

	return {
		gear_preview_data = element.gear_preview_data,
		loadout_organizer_preview_layout = element.loadout_organizer_preview_layout,
		pass_template = TeamPreview.scale_pass_template(element.pass_template, scale),
		size = {
			element.size[1] * scale,
			element.size[2] * scale,
		},
		stats_preview_data = element.stats_preview_data,
		team_preview_title = element.team_preview_title,
	}
end

function TeamPreview.mission_brief_mod()
	local ok, mission_brief = pcall(get_mod, "MissionBrief")

	if ok and mission_brief then
		return mission_brief
	end

	return nil
end

function TeamPreview.mission_brief_show_mission(mission_brief)
	if not mission_brief then
		return false
	end

	if type(mission_brief.get) ~= "function" then
		return true
	end

	local ok, show_mission = pcall(mission_brief.get, mission_brief, "show_mission")

	return not ok or show_mission ~= false
end

function TeamPreview.mission_brief_show_fluff(mission_brief)
	if not mission_brief then
		return false
	end

	if type(mission_brief.get) ~= "function" then
		return true
	end

	local ok, show_fluff = pcall(mission_brief.get, mission_brief, "show_fluff")

	return not ok or show_fluff ~= false
end

function TeamPreview.mission_brief_panel_height(view, widget_name)
	local widgets_by_name = view and view._widgets_by_name
	local widget = widgets_by_name and widgets_by_name[widget_name]

	if not widget or widget.visible == false then
		return 0
	end

	local style = widget.style and widget.style.fade
	local size = style and style.size
	local height = type(size) == "table" and tonumber(size[2]) or nil

	return height or 0
end

function TeamPreview.mission_brief_clear_y(view)
	local mission_brief = TeamPreview.mission_brief_mod()

	if not mission_brief then
		return nil
	end

	local clear_y = 0

	if TeamPreview.mission_brief_show_mission(mission_brief) then
		clear_y = math.max(clear_y, TeamPreview.mission_brief_panel_height(view, "mb_left_background"))
	end

	if TeamPreview.mission_brief_show_fluff(mission_brief) then
		clear_y = math.max(clear_y, TeamPreview.mission_brief_panel_height(view, "mb_right_background"))
	end

	if clear_y <= 0 then
		clear_y = TEAM_PREVIEW_LAYOUT.mission_brief_default_clear_y
	end

	return clear_y + TEAM_PREVIEW_LAYOUT.mission_brief_gap
end

function TeamPreview.context_scale(context, mode, tree_only)
	if context == "lobby" then
		if tree_only then
			return TEAM_PREVIEW_LAYOUT.lobby_tree_hover_scale
		end

		return TEAM_PREVIEW_LAYOUT.lobby_scale
	elseif context == "mission_intro" then
		if mode == PREVIEW_MODE.tree_gear then
			return TeamPreview._mission_intro_tree_gear_scale or TEAM_PREVIEW_LAYOUT.loading_tree_scale
		end

		if tree_only or mode == PREVIEW_MODE.tree then
			return TEAM_PREVIEW_LAYOUT.loading_tree_scale
		end

		return TEAM_PREVIEW_LAYOUT.loading_scale
	elseif context == "applicant" then
		return TEAM_PREVIEW_LAYOUT.applicant_scale
	end

	return 1
end

function TeamPreview.build_element(view, player, profile, include_title, context, mode, tree_only)
	local profile_preset = TeamPreview.profile_preset(profile)
	local preview_mode = mode or PREVIEW_MODE.compact
	local layout = profile_preset and TeamPreview.with_context_settings(context, function ()
		local options = {
			show_stimm = tree_only ~= true and Settings.show_stimm_lab_preview(),
		}

		if tree_only then
			options.hide_gear = true
			options.hide_stats = true
		end

		return build_preview_layout(view, profile_preset, preview_mode, profile, options)
	end)
	local element = TeamPreview.preview_element(layout)

	if not element then
		return nil
	end

	local title = include_title and TeamPreview.profile_title(player, profile) or nil

	local wrapped = TeamPreview.wrap_element(element, title, context)

	return wrapped and TeamPreview.scale_element(wrapped, TeamPreview.context_scale(context, preview_mode, tree_only)) or nil
end

function TeamPreview.preview_widget_name(name)
	return type(name) == "string" and string.sub(name, 1, #PREVIEW_WIDGET_NAME_PREFIX) == PREVIEW_WIDGET_NAME_PREFIX
end

function TeamPreview.remove_widget_from_view_array(view, widget)
	local widgets = view and view._widgets

	if type(widgets) ~= "table" or not widget then
		return
	end

	for i = #widgets, 1, -1 do
		local existing_widget = widgets[i]

		if existing_widget == widget or existing_widget and TeamPreview.preview_widget_name(existing_widget.name) and existing_widget.name == widget.name then
			table.remove(widgets, i)
		end
	end
end

function TeamPreview.unregister_widget(view, widget, context)
	local name = widget and widget.name

	if not view or not TeamPreview.preview_widget_name(name) then
		return
	end

	if view._unregister_widget_name then
		Settings.safe_method(context or "unregister loadout preview widget", view, "_unregister_widget_name", name)
	elseif type(view._widgets_by_name) == "table" then
		view._widgets_by_name[name] = nil
	end

	if type(view._widgets_by_name) == "table" then
		view._widgets_by_name[name] = nil
	end

	TeamPreview.remove_widget_from_view_array(view, widget)
end

function TeamPreview.destroy_widget_resources(view, widget, context, optional_renderer)
	if not widget or widget._loadout_previews_destroyed then
		return true
	end

	local ui_renderer = optional_renderer or widget._loadout_previews_ui_renderer or view and view._ui_renderer
	local ok = true

	if ui_renderer then
		ok = Settings.safe_call(context or "destroy loadout preview widget resources", UIWidget and UIWidget.destroy, ui_renderer, widget)
	end

	if not ok then
		widget.visible = false
		widget._loadout_previews_ui_renderer = nil

		return false
	end

	widget._loadout_previews_ui_renderer = nil
	widget._loadout_previews_destroyed = true

	return true
end

function TeamPreview.detach_widget(view, widget, context)
	if not widget then
		return true
	end

	widget.visible = false
	widget._loadout_previews_ui_renderer = nil
	widget._loadout_previews_destroyed = true
	widget._loadout_previews_detached = true

	TeamPreview.unregister_widget(view, widget, context or "detach loadout preview widget")

	return true
end

function TeamPreview.destroy_slot_widget(view, slot, optional_renderer, context, detach_only)
	local widget = slot and slot._loadout_previews_widget

	if widget then
		local destroyed

		if detach_only ~= false then
			destroyed = TeamPreview.detach_widget(view, widget, context or "detach team preview widget")
		else
			destroyed = TeamPreview.destroy_widget_resources(view, widget, context or "destroy team preview widget resources", optional_renderer)

			if destroyed then
				TeamPreview.unregister_widget(view, widget, "unregister team preview widget")
			else
				destroyed = TeamPreview.detach_widget(view, widget, "detach team preview widget after failed destroy")
			end
		end

		if not destroyed then
			return false
		end
	end

	if slot then
		slot._loadout_previews_widget = nil
		slot._loadout_previews_widget_key = nil
	end

	return true
end

function TeamPreview.lobby_tree_slot_keys(view)
	if not view then
		return nil
	end

	local keys = view._loadout_previews_lobby_tree_slot_keys

	if type(keys) ~= "table" then
		keys = {}
		view._loadout_previews_lobby_tree_slot_keys = keys
	end

	return keys
end

function TeamPreview.toggle_lobby_tree(view, slot_key)
	if not view or not slot_key or slot_key == "" then
		return
	end

	local keys = TeamPreview.lobby_tree_slot_keys(view)

	if not keys then
		return
	end

	view._loadout_previews_lobby_tree_slot_key = nil

	if keys[slot_key] then
		keys[slot_key] = nil
	else
		keys[slot_key] = true
	end
end

function TeamPreview.bind_lobby_toggle(view, slot, widget)
	local hotspot = widget and widget.content and widget.content.team_preview_hotspot

	if not hotspot then
		return
	end

	local slot_key = TeamPreview.slot_key(slot)

	hotspot.pressed_callback = function ()
		TeamPreview.toggle_lobby_tree(view, slot_key)
	end
end

function TeamPreview.refresh_slot_widget(view, slot, context, include_title, mode, tree_only)
	if view and (view._loadout_previews_exiting or view._destroyed) then
		return nil
	end

	if not TeamPreview.enabled(context) or not slot or not slot.occupied then
		TeamPreview.destroy_slot_widget(view, slot)

		return nil
	end

	local player = slot.player

	if not TeamPreview.is_human_player(player) then
		TeamPreview.destroy_slot_widget(view, slot)

		return nil
	end

	local profile = TeamPreview.player_profile(player)
	local title = include_title and TeamPreview.profile_title(player, profile) or nil
	local key = profile and TeamPreview.profile_key_for_mode(player, profile, title, mode or PREVIEW_MODE.compact, tree_only == true, context)

	if not key then
		TeamPreview.destroy_slot_widget(view, slot)

		return nil
	end

	key = table.concat({
		key,
		tostring(context or ""),
		tostring(TeamPreview.context_scale(context, mode or PREVIEW_MODE.compact, tree_only == true)),
	}, "|")

	if slot._loadout_previews_widget and slot._loadout_previews_widget_key == key then
		return slot._loadout_previews_widget
	end

	TeamPreview.destroy_slot_widget(view, slot)

	local element = TeamPreview.build_element(view, player, profile, include_title, context, mode, tree_only)

	if not element then
		return nil
	end

	local ok_definition, widget_definition = Settings.safe_call("create team preview widget definition", UIWidget and UIWidget.create_definition, element.pass_template, TEAM_PREVIEW_LAYOUT.scenegraph_id, nil, element.size)

	if not ok_definition or not widget_definition then
		return nil
	end

	local widget_name = string.format("loadout_previews_%s_%s", context, tostring(slot.index or 0))
	local ok_widget, widget = Settings.safe_method("create team preview widget", view, "_create_widget", widget_name, widget_definition)

	if not ok_widget or not widget then
		return nil
	end

	init_gear_preview_widget(view, widget, element)

	if widget.content then
		widget.content.team_preview_title = element.team_preview_title or ""
	end

	widget._loadout_previews_size = element.size
	slot._loadout_previews_widget = widget
	slot._loadout_previews_widget_key = key

	if context == "lobby" then
		TeamPreview.bind_lobby_toggle(view, slot, widget)
	end

	return widget
end

function TeamPreview.set_widget_offset(widget, x, y)
	if not widget then
		return
	end

	widget.offset = widget.offset or {
		0,
		0,
		0,
	}
	widget.offset[1] = math.floor(x + 0.5)
	widget.offset[2] = math.floor(y + 0.5)
	widget.offset[3] = TEAM_PREVIEW_LAYOUT.z
end

function TeamPreview.widget_size(widget)
	local size = widget and widget._loadout_previews_size

	return size and size[1] or 0, size and size[2] or 0
end

function TeamPreview.draw_widget(widget, ui_renderer, context)
	if not widget or not ui_renderer then
		return false
	end

	sanitize_widget_texture_content(widget)

	widget._loadout_previews_ui_renderer = ui_renderer

	local ok = Settings.safe_call(context or "draw loadout preview widget", UIWidget and UIWidget.draw, widget, ui_renderer)

	return ok
end

function TeamPreview.clear_registered_view_widgets(view, context, optional_renderer, detach_only)
	local widgets_by_name = view and view._widgets_by_name

	if type(widgets_by_name) ~= "table" then
		return
	end

	local preview_widgets = {}

	for name, widget in pairs(widgets_by_name) do
		if TeamPreview.preview_widget_name(name) then
			preview_widgets[#preview_widgets + 1] = widget
		end
	end

	for i = 1, #preview_widgets do
		local widget = preview_widgets[i]

		if detach_only ~= false then
			TeamPreview.detach_widget(view, widget, context or "detach registered loadout preview widget")
		elseif TeamPreview.destroy_widget_resources(view, widget, context or "destroy registered loadout preview widget resources", optional_renderer) then
			TeamPreview.unregister_widget(view, widget, "unregister registered loadout preview widget")
		else
			TeamPreview.detach_widget(view, widget, "detach registered loadout preview widget after failed destroy")
		end
	end
end

function TeamPreview.clear_view_widgets(view, context, optional_renderer, detach_only)
	local spawn_slots = view and view._spawn_slots

	if type(spawn_slots) == "table" then
		for i = 1, #spawn_slots do
			TeamPreview.destroy_slot_widget(view, spawn_slots[i], optional_renderer, context, detach_only)
		end
	end

	TeamPreview.clear_registered_view_widgets(view, context, optional_renderer, detach_only)

	if view then
		view._loadout_previews_lobby_tree_slot_key = nil
		view._loadout_previews_lobby_tree_slot_keys = nil
	end
end

function TeamPreview.lobby_slot_hovered(slot)
	local panel_hotspot = slot and slot.panel_widget and slot.panel_widget.content and slot.panel_widget.content.hotspot

	if panel_hotspot and (panel_hotspot.is_hover or panel_hotspot.is_selected) then
		return true
	end

	local weapon_widgets = slot and slot.weapon_widgets

	if type(weapon_widgets) == "table" then
		for i = 1, #weapon_widgets do
			local widget = weapon_widgets[i]
			local hotspot = widget and widget.content and widget.content.hotspot

			if hotspot and (hotspot.is_hover or hotspot.is_selected) then
				return true
			end
		end
	end

	local talent_widgets = slot and slot.talent_widgets

	if type(talent_widgets) == "table" then
		for i = 1, #talent_widgets do
			local widget = talent_widgets[i]
			local hotspot = widget and widget.content and widget.content.hotspot

			if hotspot and (hotspot.is_hover or hotspot.is_selected) then
				return true
			end
		end
	end

	local preview_widget = slot and slot._loadout_previews_widget
	local preview_hotspot = preview_widget and preview_widget.content and preview_widget.content.team_preview_hotspot

	if preview_hotspot and (preview_hotspot.is_hover or preview_hotspot.is_selected) then
		return true
	end

	return false
end

function TeamPreview.hovered_lobby_slot(view)
	local spawn_slots = view and view._spawn_slots

	if type(spawn_slots) ~= "table" then
		return nil
	end

	for i = 1, #spawn_slots do
		local slot = spawn_slots[i]

		if slot and slot.occupied and TeamPreview.lobby_slot_hovered(slot) then
			return slot
		end
	end
end

function TeamPreview.position_lobby_widget(widget, slot)
	local width, height = TeamPreview.widget_size(widget)
	local panel_x = slot and slot.panel_widget and slot.panel_widget.offset and slot.panel_widget.offset[1] or TEAM_PREVIEW_LAYOUT.canvas_width * 0.5
	local x = panel_x - width * 0.5
	local y = TEAM_PREVIEW_LAYOUT.lobby_bottom_y - height
	local margin = TEAM_PREVIEW_LAYOUT.margin

	x = clamp(x, margin, TEAM_PREVIEW_LAYOUT.canvas_width - width - margin)
	y = clamp(y, margin, TEAM_PREVIEW_LAYOUT.canvas_height - height - margin)

	TeamPreview.set_widget_offset(widget, x, y)
end

function TeamPreview.position_lobby_hover_widgets(entries)
	entries = type(entries) == "table" and entries or {}

	if #entries <= 0 then
		return
	end

	local margin = TEAM_PREVIEW_LAYOUT.margin
	local gap = TEAM_PREVIEW_LAYOUT.loading_gap
	local total_width = 0

	for i = 1, #entries do
		local entry = entries[i]
		local width, height = TeamPreview.widget_size(entry and entry.widget)
		local panel_x = entry and entry.slot and entry.slot.panel_widget and entry.slot.panel_widget.offset and entry.slot.panel_widget.offset[1] or TEAM_PREVIEW_LAYOUT.canvas_width * 0.5

		entry.width = width
		entry.height = height
		entry.desired_x = panel_x - width * 0.5
		total_width = total_width + width
	end

	gap = total_width + math.max(#entries - 1, 0) * gap > TEAM_PREVIEW_LAYOUT.canvas_width - margin * 2
		and math.max((TEAM_PREVIEW_LAYOUT.canvas_width - margin * 2 - total_width) / math.max(#entries - 1, 1), 6)
		or gap

	table.sort(entries, function (a, b)
		return (a.desired_x or 0) < (b.desired_x or 0)
	end)

	local x = margin

	for i = 1, #entries do
		local entry = entries[i]

		entry.x = math.max(entry.desired_x or margin, x)
		x = entry.x + (entry.width or 0) + gap
	end

	local overflow = x - gap - (TEAM_PREVIEW_LAYOUT.canvas_width - margin)

	if overflow > 0 then
		local shift = math.min(overflow, (entries[1].x or margin) - margin)

		for i = 1, #entries do
			entries[i].x = (entries[i].x or margin) - shift
		end
	end

	for i = 1, #entries do
		local entry = entries[i]
		local height = entry.height or 0
		local max_y = TEAM_PREVIEW_LAYOUT.canvas_height - height - margin
		local y = max_y >= margin and clamp(TEAM_PREVIEW_LAYOUT.lobby_bottom_y - height, margin, max_y) or margin

		TeamPreview.set_widget_offset(entry.widget, entry.x or margin, y)
	end
end

function TeamPreview.position_lobby_widgets(widgets)
	widgets = type(widgets) == "table" and widgets or {}

	local total_width = 0
	local max_height = 0
	local gap = TEAM_PREVIEW_LAYOUT.loading_gap

	for i = 1, #widgets do
		local width, height = TeamPreview.widget_size(widgets[i])

		total_width = total_width + width
		max_height = math.max(max_height, height)
	end

	total_width = total_width + math.max(#widgets - 1, 0) * gap

	local margin = TEAM_PREVIEW_LAYOUT.margin
	local x = math.max((TEAM_PREVIEW_LAYOUT.canvas_width - total_width) * 0.5, margin)
	local y = clamp(TEAM_PREVIEW_LAYOUT.lobby_bottom_y - max_height, margin, TEAM_PREVIEW_LAYOUT.canvas_height - max_height - margin)

	for i = 1, #widgets do
		local widget = widgets[i]
		local width = TeamPreview.widget_size(widget)

		TeamPreview.set_widget_offset(widget, x, y)

		x = x + width + gap
	end
end

function TeamPreview.draw_lobby(view, ui_renderer)
	if view and (view._loadout_previews_exiting or view._destroyed) then
		TeamPreview.clear_view_widgets(view, "detach exiting lobby team preview widgets", ui_renderer, true)

		return
	end

	local spawn_slots = view and view._spawn_slots

	if type(spawn_slots) ~= "table" or not TeamPreview.enabled("lobby") then
		TeamPreview.clear_view_widgets(view)

		return
	end

	local tree_toggle_enabled = Settings.show_lobby_tree_on_hover()
	local legacy_slot_key = tree_toggle_enabled and view._loadout_previews_lobby_tree_slot_key or nil
	local toggled_slot_keys = tree_toggle_enabled and view._loadout_previews_lobby_tree_slot_keys or nil
	local entries = {}
	local tree_active = false
	local active_tree_keys = {}

	if not tree_toggle_enabled then
		view._loadout_previews_lobby_tree_slot_keys = nil
		view._loadout_previews_lobby_tree_slot_key = nil
	elseif legacy_slot_key and legacy_slot_key ~= "" then
		toggled_slot_keys = TeamPreview.lobby_tree_slot_keys(view)
		toggled_slot_keys[legacy_slot_key] = true
		view._loadout_previews_lobby_tree_slot_key = nil
	end

	for i = 1, #spawn_slots do
		local slot = spawn_slots[i]

		if TeamPreview.should_show_lobby_slot(slot) then
			local slot_key = TeamPreview.slot_key(slot)
			local tree_only = type(toggled_slot_keys) == "table" and toggled_slot_keys[slot_key] == true
			local mode = tree_only and PREVIEW_MODE.tree or PREVIEW_MODE.compact
			local widget = TeamPreview.refresh_slot_widget(view, slot, "lobby", false, mode, tree_only)

			if widget then
				local hotspot = widget.content and widget.content.team_preview_hotspot

				if hotspot then
					hotspot.is_selected = tree_only
				end

				entries[#entries + 1] = {
					slot = slot,
					widget = widget,
				}
				tree_active = tree_active or tree_only

				if tree_only then
					active_tree_keys[slot_key] = true
				end
			end
		else
			TeamPreview.destroy_slot_widget(view, slot)
		end
	end

	if type(toggled_slot_keys) == "table" then
		local has_tree_keys = false

		for key, _ in pairs(toggled_slot_keys) do
			if active_tree_keys[key] then
				has_tree_keys = true
			else
				toggled_slot_keys[key] = nil
			end
		end

		if not has_tree_keys then
			view._loadout_previews_lobby_tree_slot_keys = nil
		end
	end

	if tree_active then
		TeamPreview.position_lobby_hover_widgets(entries)
	else
		for i = 1, #entries do
			local entry = entries[i]

			TeamPreview.position_lobby_widget(entry.widget, entry.slot)
		end
	end

	for i = 1, #entries do
		TeamPreview.draw_widget(entries[i].widget, ui_renderer, "draw lobby team preview widget")
	end
end

function TeamPreview.lobby_tree_on_hover(slot)
	if not Settings.show_lobby_tree_on_hover() then
		return false
	end

	local widget = slot and slot._loadout_previews_widget
	local hotspot = widget and widget.content and widget.content.team_preview_hotspot

	return hotspot and (hotspot.is_hover or hotspot.is_selected) == true
end

function TeamPreview.fit_mission_intro_tree_gear_scale(widgets)
	if type(widgets) ~= "table" or #widgets <= 0 then
		return false
	end

	local width_sum = 0

	for i = 1, #widgets do
		local width = TeamPreview.widget_size(widgets[i])

		width_sum = width_sum + width
	end

	if width_sum <= 0 then
		return false
	end

	local gap = TEAM_PREVIEW_LAYOUT.loading_gap
	local available_width = TEAM_PREVIEW_LAYOUT.canvas_width - TEAM_PREVIEW_LAYOUT.margin * 2 - math.max(#widgets - 1, 0) * gap
	local current_scale = TeamPreview._mission_intro_tree_gear_scale or TEAM_PREVIEW_LAYOUT.loading_tree_scale
	local fitted_scale = current_scale * available_width / width_sum

	fitted_scale = clamp(fitted_scale, TEAM_PREVIEW_LAYOUT.loading_tree_gear_min_scale, TEAM_PREVIEW_LAYOUT.loading_tree_scale)
	fitted_scale = math.floor(fitted_scale * 100 + 0.5) / 100

	if math.abs(fitted_scale - current_scale) <= 0.005 then
		return false
	end

	TeamPreview._mission_intro_tree_gear_scale = fitted_scale

	return true
end

function TeamPreview.position_mission_widgets(view, widgets)
	widgets = type(widgets) == "table" and widgets or {}

	local total_width = 0
	local max_height = 0
	local gap = TEAM_PREVIEW_LAYOUT.loading_gap

	for i = 1, #widgets do
		local width, height = TeamPreview.widget_size(widgets[i])

		total_width = total_width + width
		max_height = math.max(max_height, height)
	end

	total_width = total_width + math.max(#widgets - 1, 0) * gap

	local margin = TEAM_PREVIEW_LAYOUT.margin
	local x = math.max((TEAM_PREVIEW_LAYOUT.canvas_width - total_width) * 0.5, margin)
	local mission_brief_y = TeamPreview.mission_brief_clear_y(view)
	local y = mission_brief_y or TEAM_PREVIEW_LAYOUT.loading_top_y
	local max_y = TEAM_PREVIEW_LAYOUT.canvas_height - max_height - margin

	if max_y >= margin then
		y = clamp(y, margin, max_y)
	end

	for i = 1, #widgets do
		local widget = widgets[i]
		local width = TeamPreview.widget_size(widget)

		TeamPreview.set_widget_offset(widget, x, y)

		x = x + width + gap
	end
end

function TeamPreview.refresh_mission_intro_widgets(view, spawn_slots, mode, tree_only)
	local widgets = {}

	for i = 1, #spawn_slots do
		local slot = spawn_slots[i]
		local widget = TeamPreview.refresh_slot_widget(view, slot, "mission_intro", true, mode, tree_only)

		if widget then
			widgets[#widgets + 1] = widget
		end
	end

	return widgets
end

function TeamPreview.draw_mission_intro(view, ui_renderer)
	local spawn_slots = view and view._spawn_slots

	if type(spawn_slots) ~= "table" or not TeamPreview.enabled("mission_intro") then
		TeamPreview.clear_view_widgets(view)

		return
	end

	local mode = Settings.valkyrie_team_preview_mode()
	local tree_only = mode == PREVIEW_MODE.tree

	if mode ~= PREVIEW_MODE.tree_gear then
		TeamPreview._mission_intro_tree_gear_scale = nil
	end

	local widgets = TeamPreview.refresh_mission_intro_widgets(view, spawn_slots, mode, tree_only)

	if mode == PREVIEW_MODE.tree_gear and TeamPreview.fit_mission_intro_tree_gear_scale(widgets) then
		widgets = TeamPreview.refresh_mission_intro_widgets(view, spawn_slots, mode, tree_only)
	end

	TeamPreview.position_mission_widgets(view, widgets)

	for i = 1, #widgets do
		TeamPreview.draw_widget(widgets[i], ui_renderer, "draw mission intro team preview widget")
	end
end

function TeamPreview.render_pass(context, ui_renderer, ui_scenegraph, input_service, dt, render_settings, start_layer, render_scale, draw_callback)
	if not ui_renderer or not ui_scenegraph or not render_settings or type(draw_callback) ~= "function" then
		return
	end

	local alpha_multiplier = render_settings.alpha_multiplier
	local previous_layer = render_settings.start_layer
	local previous_scale = render_settings.scale
	local previous_inverse_scale = render_settings.inverse_scale
	local pass_started = false
	local ok, error_message = pcall(function ()
		render_settings.start_layer = start_layer or 0
		render_settings.scale = render_scale
		render_settings.inverse_scale = render_scale and render_scale ~= 0 and 1 / render_scale or nil

		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)
		pass_started = true
		draw_callback(ui_renderer)
		UIRenderer.end_pass(ui_renderer)
		pass_started = false
	end)

	if not ok then
		if pass_started then
			Settings.safe_call("end failed " .. tostring(context), UIRenderer and UIRenderer.end_pass, ui_renderer)
		end

		Settings.report_guarded_error(context, error_message)
	end

	render_settings.alpha_multiplier = alpha_multiplier
	render_settings.start_layer = previous_layer
	render_settings.scale = previous_scale
	render_settings.inverse_scale = previous_inverse_scale
end

function TeamPreview.draw_mission_intro_pass(view, dt, t, input_service, layer)
	if view and (view._loadout_previews_exiting or view._destroyed) then
		TeamPreview.clear_view_widgets(view, "detach exiting mission intro preview widgets", view and view._ui_renderer, true)

		return
	end

	local ui_renderer = view and view._ui_renderer
	local ui_scenegraph = view and view._ui_scenegraph
	local render_settings = view and view._render_settings

	if not ui_renderer or not ui_scenegraph or not render_settings then
		return
	end

	local render_scale = view._render_scale

	TeamPreview.render_pass("draw mission intro team previews", ui_renderer, ui_scenegraph, input_service, dt, render_settings, layer or 0, render_scale, function (renderer)
		TeamPreview.draw_mission_intro(view, renderer)
	end)
end

function ApplicantPreview.destroy_widget(view, detach_only)
	local widget = view and view._loadout_previews_applicant_widget

	if widget then
		if detach_only ~= false then
			TeamPreview.detach_widget(view, widget, "detach party finder applicant preview widget")
		elseif TeamPreview.destroy_widget_resources(view, widget, "destroy party finder applicant preview widget resources") then
			TeamPreview.unregister_widget(view, widget, "unregister party finder applicant preview widget")
		else
			TeamPreview.detach_widget(view, widget, "detach party finder applicant preview widget after failed destroy")
		end
	end

	if view then
		view._loadout_previews_applicant_widget = nil
		view._loadout_previews_applicant_widget_key = nil
	end

	return true
end

function ApplicantPreview.profile(element)
	local presence_info = element and element.presence_info

	return presence_info and presence_info.profile or nil
end

function ApplicantPreview.profile_key(profile)
	return Settings.with_party_finder_preview_settings(function ()
		local mode = Settings.preview_mode()
		local pieces = {
			Settings.preview_key(mode),
			"party_stimm=" .. tostring(Settings.show_party_finder_stimm_lab_preview()),
		}
		local loadout = profile and profile.loadout

		for i = 1, #WEAPON_LAYOUT.preview_slots do
			pieces[#pieces + 1] = tostring(loadout_slot_gear_id(loadout, WEAPON_LAYOUT.preview_slots[i]))
		end

		for i = 1, #CURIO_LAYOUT.preview_slots do
			pieces[#pieces + 1] = tostring(loadout_slot_gear_id(loadout, CURIO_LAYOUT.preview_slots[i]))
		end

		local selected_nodes = profile and profile.selected_nodes

		if type(selected_nodes) == "table" then
			local names = {}

			for name, _ in pairs(selected_nodes) do
				names[#names + 1] = name
			end

			table.sort(names)

			for i = 1, #names do
				local name = names[i]

				pieces[#pieces + 1] = tostring(name) .. "=" .. tostring(selected_nodes[name])
			end
		end

		return table.concat(pieces, "|")
	end)
end

function ApplicantPreview.wrap_tooltip_element(element)
	if not element or type(element.size) ~= "table" then
		return nil
	end

	local content_width = element.size[1]
	local content_height = element.size[2]
	local preview_layout = element.loadout_organizer_preview_layout or {
		preview_width = content_width,
		preview_height = content_height,
	}
	local width = preview_tooltip_width(preview_layout)
	local height = preview_tooltip_height(preview_layout)
	local content_x = math.max((width - content_width) * 0.5, 0)
	local content_y = math.max((height - content_height) * 0.5, 0)
	local pass_template = {
		{
			pass_type = "rect",
			style_id = "applicant_preview_tooltip_icon_bg",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = Color.terminal_grid_background_icon(255, true),
				size_addition = {
					-24,
					-24,
				},
				offset = {
					0,
					0,
					0,
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "applicant_preview_tooltip_bg",
			value = "content/ui/materials/backgrounds/terminal_basic",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = Color.terminal_grid_background(255, true),
				offset = {
					0,
					0,
					1,
				},
			},
		},
	}

	append_passes_with_offset(pass_template, element.pass_template, content_x, content_y, "applicant_preview_")

	return {
		gear_preview_data = element.gear_preview_data,
		loadout_organizer_preview_layout = element.loadout_organizer_preview_layout,
		pass_template = pass_template,
		size = {
			width,
			height,
		},
		stats_preview_data = element.stats_preview_data,
	}
end

function ApplicantPreview.build_element(view, profile)
	local profile_preset = TeamPreview.profile_preset(profile)

	return Settings.with_party_finder_preview_settings(function ()
		local options = {
			show_stimm = Settings.show_party_finder_stimm_lab_preview(),
		}
		local layout = profile_preset and build_preview_layout(view, profile_preset, Settings.preview_mode(), profile, options)
		local element = TeamPreview.preview_element(layout)

		return element and ApplicantPreview.wrap_tooltip_element(element) or nil
	end)
end

function ApplicantPreview.entry_hovered(widget)
	local content = widget and widget.content
	local element = content and content.element

	if not element or element.widget_type ~= "player_request_entry" then
		return false
	end

	local hotspot = content.hotspot

	if not hotspot or not (hotspot.is_hover or hotspot.is_selected) then
		return false
	end

	local accept_hotspot = content.accept_hotspot
	local decline_hotspot = content.decline_hotspot

	return not ((accept_hotspot and accept_hotspot.is_hover) or (decline_hotspot and decline_hotspot.is_hover))
end

function ApplicantPreview.hovered_entry(view)
	local grid = view and view._player_request_grid
	local _, widgets = Settings.safe_method("party finder request grid widgets", grid, "widgets")

	if type(widgets) ~= "table" then
		return nil, nil
	end

	for i = 1, #widgets do
		local widget = widgets[i]

		if ApplicantPreview.entry_hovered(widget) then
			local element = widget.content and widget.content.element
			local profile = ApplicantPreview.profile(element)

			if profile then
				return widget, element
			end
		end
	end

	return nil, nil
end

function ApplicantPreview.refresh_widget(view, element, cached_key)
	if not TeamPreview.enabled("applicant") then
		ApplicantPreview.destroy_widget(view)

		return nil
	end

	local profile = ApplicantPreview.profile(element)
	local key = cached_key or profile and ApplicantPreview.profile_key(profile)

	if not key then
		ApplicantPreview.destroy_widget(view)

		return nil
	end

	if view._loadout_previews_applicant_widget and view._loadout_previews_applicant_widget_key == key then
		return view._loadout_previews_applicant_widget
	end

	ApplicantPreview.destroy_widget(view)

	local element_preview = ApplicantPreview.build_element(view, profile)

	if not element_preview then
		return nil
	end

	local ok_definition, widget_definition = Settings.safe_call("create party finder applicant preview definition", UIWidget and UIWidget.create_definition, element_preview.pass_template, TEAM_PREVIEW_LAYOUT.applicant_scenegraph_id, nil, element_preview.size)

	if not ok_definition or not widget_definition then
		return nil
	end

	local ok_widget, widget = Settings.safe_method("create party finder applicant preview widget", view, "_create_widget", "loadout_previews_group_finder_applicant", widget_definition)

	if not ok_widget or not widget then
		return nil
	end

	init_gear_preview_widget(view, widget, element_preview)

	if widget.content then
		widget.content.team_preview_title = ""
	end
	widget._loadout_previews_size = element_preview.size
	view._loadout_previews_applicant_widget = widget
	view._loadout_previews_applicant_widget_key = key

	return widget
end

function ApplicantPreview.clear_hover_delay(view)
	if view then
		view._loadout_previews_applicant_hover_key = nil
		view._loadout_previews_applicant_pending_since = nil
	end
end

function ApplicantPreview.scenegraph_position(view, scenegraph_id)
	if not view or not view._scenegraph_world_position then
		return nil
	end

	local ok, position = pcall(view._scenegraph_world_position, view, scenegraph_id)

	if ok and position then
		return position
	end

	return nil
end

function ApplicantPreview.scenegraph_size(view, scenegraph_id)
	local scenegraph = view and view._ui_scenegraph and view._ui_scenegraph[scenegraph_id]

	return scenegraph and scenegraph.size or nil
end

function ApplicantPreview.position_widget(view, widget)
	local width, height = TeamPreview.widget_size(widget)
	local position = ApplicantPreview.scenegraph_position(view, "player_request_window")
	local size = ApplicantPreview.scenegraph_size(view, "player_request_window")
	local margin = TEAM_PREVIEW_LAYOUT.margin
	local x = TEAM_PREVIEW_LAYOUT.canvas_width - width - margin
	local y = margin

	if position and size then
		x = position[1] - width - 16
		y = position[2] + (size[2] - height) * 0.5
	end

	x = clamp(x, margin, TEAM_PREVIEW_LAYOUT.canvas_width - width - margin)
	y = clamp(y, margin, TEAM_PREVIEW_LAYOUT.canvas_height - height - margin)

	TeamPreview.set_widget_offset(widget, x, y)
	widget.offset[3] = TEAM_PREVIEW_LAYOUT.applicant_z
end

function ApplicantPreview.delay_elapsed(view, key, t)
	local delay = Settings.with_party_finder_preview_settings(function ()
		return Settings.preview_delay()
	end) or 0

	if delay <= 0 then
		return true
	end

	local current_time = t or 0

	if view._loadout_previews_applicant_hover_key ~= key then
		view._loadout_previews_applicant_hover_key = key
		view._loadout_previews_applicant_pending_since = current_time

		ApplicantPreview.destroy_widget(view)

		return false
	end

	return current_time - (view._loadout_previews_applicant_pending_since or current_time) >= delay
end

function ApplicantPreview.draw(view, ui_renderer, t)
	if view and (view._loadout_previews_exiting or view._destroyed) then
		ApplicantPreview.destroy_widget(view, true)
		ApplicantPreview.clear_hover_delay(view)

		return
	end

	if not TeamPreview.enabled("applicant") then
		ApplicantPreview.destroy_widget(view)
		ApplicantPreview.clear_hover_delay(view)

		return
	end

	local _, element = ApplicantPreview.hovered_entry(view)

	if not element then
		ApplicantPreview.destroy_widget(view)
		ApplicantPreview.clear_hover_delay(view)

		return
	end

	local profile = ApplicantPreview.profile(element)
	local key = profile and ApplicantPreview.profile_key(profile)

	if not key then
		ApplicantPreview.destroy_widget(view)
		ApplicantPreview.clear_hover_delay(view)

		return
	end

	if not ApplicantPreview.delay_elapsed(view, key, t) then
		return
	end

	local widget = ApplicantPreview.refresh_widget(view, element, key)

	if widget then
		ApplicantPreview.position_widget(view, widget)
		TeamPreview.draw_widget(widget, ui_renderer, "draw party finder applicant preview widget")
	end
end

function ApplicantPreview.overlay_renderer(view)
	local player_request_grid = view and view._player_request_grid
	local group_grid = view and view._group_grid
	local preview_grid = view and view._preview_grid

	return player_request_grid and player_request_grid._ui_grid_renderer
		or group_grid and group_grid._ui_grid_renderer
		or preview_grid and preview_grid._ui_grid_renderer
		or view and view._ui_renderer
end

function ApplicantPreview.draw_pass(view, dt, t, input_service, layer)
	local ui_renderer = ApplicantPreview.overlay_renderer(view)
	local ui_scenegraph = view and view._ui_scenegraph
	local render_settings = view and view._render_settings

	if not ui_renderer or not ui_scenegraph or not render_settings then
		return
	end

	local render_scale = view._render_scale
	local start_layer = render_settings.start_layer

	TeamPreview.render_pass("draw party finder applicant preview", ui_renderer, ui_scenegraph, input_service, dt, render_settings, (layer or 0) + TEAM_PREVIEW_LAYOUT.applicant_draw_layer, render_scale, function (renderer)
		ApplicantPreview.draw(view, renderer, t)
	end)

	render_settings.start_layer = start_layer
end

mod:hook_require("scripts/ui/views/lobby_view/lobby_view_definitions", TeamPreview.inject_overlay_scenegraph)
mod:hook_require("scripts/ui/views/mission_intro_view/mission_intro_view_definitions", TeamPreview.inject_overlay_scenegraph)
mod:hook_require("scripts/ui/views/group_finder_view/group_finder_view_definitions", TeamPreview.inject_overlay_scenegraph)

local function refresh_active_preview_geometry(view)
	if not view or not view._loadout_organizer_preview_visible then
		return
	end

	local layout = view._loadout_organizer_preview_grid_layout

	if not layout or not layout_contains_preview(layout) then
		return
	end

	local preview_layout = preview_layout_from_grid_layout(layout)
	local tooltip_width = preview_tooltip_width(preview_layout)
	local tooltip_height = preview_tooltip_height(preview_layout)

	apply_tooltip_dimensions(view, layout)

	if better_loadouts_loaded() then
		apply_better_loadouts_tooltip_position(view, tooltip_width, tooltip_height)
	end

	hide_preview_scrollbar(view)
end

local function present_preview_layout(view, layout)
	if not view then
		return false
	end

	local has_preview_layout = layout_contains_preview(layout)
	local preview_layout = has_preview_layout and preview_layout_from_grid_layout(layout) or nil
	local tooltip_width = has_preview_layout and preview_tooltip_width(preview_layout) or TOOLTIP_LAYOUT.width
	local tooltip_height = has_preview_layout and preview_tooltip_height(preview_layout) or nil

	view._loadout_organizer_preview_layout_active = has_preview_layout
	view._loadout_organizer_preview_layout = preview_layout
	view._loadout_organizer_preview_grid_layout = layout

	apply_preview_grid_rendering(view, false)
	apply_tooltip_dimensions(view, layout)

	if better_loadouts_loaded() then
		apply_better_loadouts_tooltip_position(view, tooltip_width, tooltip_height)
	end

	local definitions = view._definitions
	local blueprints = definitions and definitions.profile_preset_grid_blueprints
	local grid = view._profile_preset_tooltip_grid

	if not grid or not blueprints then
		return false
	end

	local ok = Settings.safe_method(
		"present profile preset preview grid",
		grid,
		"present_grid_layout",
		layout,
		blueprints,
		callback(view, "cb_on_profile_preset_icon_grid_left_pressed"),
		nil,
		nil,
		nil,
		callback(view, "cb_on_profile_preset_icon_grid_layout_changed"),
		nil
	)

	if not ok then
		apply_preview_grid_rendering(view, false)

		return false
	end

	apply_preview_grid_rendering(view, has_preview_layout)
	refresh_active_preview_geometry(view)

	return true
end

local function hovered_preset_id(view)
	local widgets = view and view._profile_buttons_widgets

	if type(widgets) ~= "table" then
		return nil
	end

	for i = 1, #widgets do
		local widget = widgets[i]
		local content = widget and widget.content
		local hotspot = content and content.hotspot

		if hotspot and hotspot.is_hover then
			return content.profile_preset_id
		end
	end
end

local function current_preview_time(view, dt, t)
	if type(t) == "number" then
		return t
	end

	local time_manager = Managers and Managers.time

	if time_manager then
		local ok, current_time = pcall(function ()
			return time_manager:time("main")
		end)

		if ok and type(current_time) == "number" then
			return current_time
		end
	end

	view._loadout_organizer_preview_delay_clock = (view._loadout_organizer_preview_delay_clock or 0) + (type(dt) == "number" and dt or 0)

	return view._loadout_organizer_preview_delay_clock
end

local function preview_delay_elapsed(view, preset_id, key, delay, dt, t)
	if delay <= 0 then
		clear_preview_delay(view)

		return true
	end

	local current_time = current_preview_time(view, dt, t)

	if view._loadout_organizer_pending_preset_id ~= preset_id or view._loadout_organizer_pending_preview_key ~= key then
		view._loadout_organizer_pending_preset_id = preset_id
		view._loadout_organizer_pending_preview_key = key
		view._loadout_organizer_pending_since = current_time

		return false
	end

	return current_time - (view._loadout_organizer_pending_since or current_time) >= delay
end

local function update_hover_preview(view, dt, t)
	if not view or view._intro_active or view._active_customize_preset_index then
		hide_preview(view, true)

		return
	end

	if not Settings.loadout_preview_enabled() then
		hide_preview(view, true)

		return
	end

	local mode = Settings.preview_mode()

	if mode == PREVIEW_MODE.disabled and not Settings.show_weapon_preview() and not Settings.show_curio_preview() then
		hide_preview(view, true)

		return
	end

	local key = Settings.preview_key(mode)

	local preset_id = hovered_preset_id(view)

	if not preset_id then
		hide_preview(view, true)

		return
	end

	if view._loadout_organizer_preview_visible and view._loadout_organizer_hovered_preset_id == preset_id and view._loadout_organizer_preview_key == key then
		return
	end

	if view._loadout_organizer_preview_visible then
		hide_preview(view, true)
	end

	if not preview_delay_elapsed(view, preset_id, key, Settings.preview_delay(), dt, t) then
		return
	end

	clear_preview_delay(view)

	local _, profile_preset = Settings.safe_call("get hovered profile preset", ProfileUtils and ProfileUtils.get_profile_preset, preset_id)

	if not profile_preset then
		hide_preview(view, true)

		return
	end

	local _, layout = Settings.safe_call("build self profile preset preview", build_preview_layout, view, profile_preset, mode)

	if type(layout) ~= "table" or #layout == 0 then
		hide_preview(view, true)

		return
	end

	view._loadout_organizer_preview_visible = true
	view._loadout_organizer_hovered_preset_id = preset_id
	view._loadout_organizer_preview_mode = mode
	view._loadout_organizer_preview_key = key

	if not present_preview_layout(view, layout) then
		hide_preview(view, true)

		return
	end

	Settings.safe_method("show profile preset tooltip", view, "_set_tooltip_visibility", true, false)
end

function mod.move_active_preset(view, direction)
	local index = view and view._active_customize_preset_index
	local _, presets = Settings.safe_call("get profile presets for moving", ProfileUtils and ProfileUtils.get_profile_presets)
	local new_index = index and index + direction

	if not presets or not index or not new_index or not presets[index] or new_index < 1 or new_index > #presets then
		return
	end

	presets[index], presets[new_index] = presets[new_index], presets[index]

	Settings.safe_method("save moved profile preset order", Managers and Managers.save, "queue_save")

	view._active_customize_preset_index = nil
	Settings.safe_method("rebuild profile preset buttons after move", view, "_setup_preset_buttons")
	Settings.safe_method("reopen moved profile preset customize menu", view, "on_profile_preset_index_customize", new_index)
	set_reorder_button_states(view)
end

local function grid_is_profile_preset_tooltip_grid(grid)
	local parent = grid and grid._parent

	return parent and parent._profile_preset_tooltip_grid == grid
end

local function should_inject_better_loadouts_reorder_controls(grid, layout, content_blueprints)
	return better_loadouts_loaded()
		and grid_is_profile_preset_tooltip_grid(grid)
		and content_blueprints
		and content_blueprints.loadout_organizer_move_row ~= nil
		and layout_is_profile_preset_customize(layout)
		and not layout_contains_preview(layout)
		and not layout_contains_reorder_controls(layout)
end

mod:hook("ViewElementGrid", "present_grid_layout", function (func, self, layout, content_blueprints, ...)
	local adjusted_layout = layout
	local is_preview_layout = layout_contains_preview(layout)
	local is_tooltip_grid = grid_is_profile_preset_tooltip_grid(self)

	if should_inject_better_loadouts_reorder_controls(self, layout, content_blueprints) then
		adjusted_layout = insert_reorder_controls_before_delete(layout)
	end

	if is_tooltip_grid then
		apply_preview_grid_rendering(self._parent, false)
	end

	local result = func(self, adjusted_layout, content_blueprints, ...)

	if is_tooltip_grid then
		apply_preview_grid_rendering(self._parent, is_preview_layout)

		if is_preview_layout then
			refresh_active_preview_geometry(self._parent)
		end
	end

	return result
end)

mod:hook("ViewElementProfilePresets", "_present_tooltip_grid_layout", function (func, self, layout, ...)
	local adjusted_layout = inject_reorder_controls(layout)
	local has_preview_layout = layout_contains_preview(adjusted_layout)

	if better_loadouts_loaded() then
		if has_preview_layout then
			present_preview_layout(self, adjusted_layout)

			return
		end

		self._loadout_organizer_preview_layout_active = nil
		self._loadout_organizer_preview_layout = nil

		apply_preview_grid_rendering(self, false)
		restore_better_loadouts_tooltip_dimensions(self)

		return func(self, adjusted_layout, ...)
	end

	self._loadout_organizer_preview_layout_active = has_preview_layout
	self._loadout_organizer_preview_layout = has_preview_layout and preview_layout_from_grid_layout(adjusted_layout) or nil
	apply_preview_grid_rendering(self, false)
	apply_tooltip_dimensions(self, adjusted_layout)

	return func(self, adjusted_layout, ...)
end)

mod:hook("ViewElementProfilePresets", "cb_on_profile_preset_icon_grid_layout_changed", function (func, self, layout, ...)
	func(self, layout, ...)

	if not self._loadout_organizer_preview_layout_active and not layout_contains_preview(layout) then
		return
	end

	local grid = self._profile_preset_tooltip_grid
	local _, menu_settings = Settings.safe_method("layout changed tooltip menu settings", grid, "menu_settings")

	if not menu_settings then
		return
	end

	local preview_layout = self._loadout_organizer_preview_layout or PREVIEW_LAYOUTS.default
	local grid_height = preview_tooltip_grid_height(preview_layout)
	local tooltip_height = preview_tooltip_height(preview_layout)

	menu_settings.grid_size[2] = grid_height
	menu_settings.mask_size[2] = grid_height

	Settings.safe_method("layout changed tooltip grid size", self, "_set_scenegraph_size", "profile_preset_tooltip_grid", nil, grid_height)
	Settings.safe_method("layout changed tooltip size", self, "_set_scenegraph_size", "profile_preset_tooltip", nil, tooltip_height)
	Settings.safe_method("layout changed tooltip grid position", self, "_update_profile_preset_tooltip_grid_position")
	refresh_active_preview_geometry(self)
end)

mod:hook("ViewElementProfilePresets", "cb_on_profile_preset_icon_grid_left_pressed", function (func, self, widget, element, ...)
	local direction = element and element.loadout_organizer_move_direction

	if direction then
		mod.move_active_preset(self, direction)

		return
	end

	return func(self, widget, element, ...)
end)

mod:hook("ViewElementProfilePresets", "on_profile_preset_index_customize", function (func, self, index, ...)
	if index and self._loadout_organizer_preview_visible then
		hide_preview(self, true)
	end

	return func(self, index, ...)
end)

mod:hook_safe("ViewElementProfilePresets", "update", function (self, dt, t)
	set_reorder_button_states(self)
	apply_preview_grid_rendering(self, self._loadout_organizer_preview_visible == true)

	update_hover_preview(self, dt, t)

	if self._loadout_organizer_preview_visible then
		refresh_active_preview_geometry(self)
	end
end)

mod:hook_safe("LobbyView", "_draw_widgets", function (self, dt, t, input_service, ui_renderer)
	TeamPreview.draw_lobby(self, ui_renderer)
end)

mod:hook_safe("LobbyView", "on_enter", function (self)
	self._loadout_previews_exiting = nil
	lobby_team_previews_keybind_hidden = false
end)

mod:hook("GroupFinderView", "on_exit", function (func, self, ...)
	self._loadout_previews_exiting = true
	ApplicantPreview.destroy_widget(self, true)

	return func(self, ...)
end)

mod:hook_safe("GroupFinderView", "on_enter", function (self)
	self._loadout_previews_exiting = nil
end)

mod:hook("GroupFinderView", "destroy", function (func, self, ...)
	self._loadout_previews_exiting = true
	ApplicantPreview.destroy_widget(self, true)

	return func(self, ...)
end)

mod:hook("BaseView", "destroy", function (func, self, ...)
	local class_name = self and self.__class_name

	if class_name == "LobbyView" then
		self._loadout_previews_exiting = true
		TeamPreview.clear_view_widgets(self, "detach lobby team preview widgets from base destroy", self._ui_renderer, true)
	elseif class_name == "MissionIntroView" then
		self._loadout_previews_exiting = true
		TeamPreview.clear_view_widgets(self, "detach mission intro team preview widgets from base destroy", self._ui_renderer, true)
		TeamPreview._mission_intro_tree_gear_scale = nil
	elseif class_name == "GroupFinderView" then
		self._loadout_previews_exiting = true
		ApplicantPreview.destroy_widget(self, true)
	end

	return func(self, ...)
end)

mod:hook_safe("LobbyView", "_reset_spawn_slot", function (self, slot)
	TeamPreview.destroy_slot_widget(self, slot, nil, nil, self and (self._loadout_previews_exiting or self._destroyed))
end)

mod:hook("LobbyView", "_destroy_spawn_slots", function (func, self, ...)
	TeamPreview.clear_view_widgets(self, "detach lobby team preview widgets before spawn slots", nil, true)

	return func(self, ...)
end)

mod:hook("LobbyView", "_all_ready_countdown", function (func, self, dt, ...)
	local countdown = self and self._countdown

	if type(countdown) == "number" and type(dt) == "number" and countdown - dt < 0 then
		self._loadout_previews_exiting = true
		TeamPreview.clear_view_widgets(self, "detach lobby team preview widgets before ready complete", self._ui_renderer, true)
	end

	return func(self, dt, ...)
end)

mod:hook("LobbyView", "on_exit", function (func, self, ...)
	self._loadout_previews_exiting = true
	TeamPreview.clear_view_widgets(self, "detach lobby team preview widgets on exit", self._ui_renderer, true)

	return func(self, ...)
end)

mod:hook("MissionIntroView", "on_exit", function (func, self, ...)
	self._loadout_previews_exiting = true
	TeamPreview.clear_view_widgets(self, "detach mission intro team preview widgets on exit", self._ui_renderer, true)
	TeamPreview._mission_intro_tree_gear_scale = nil

	return func(self, ...)
end)

mod:hook_safe("MissionIntroView", "on_enter", function (self)
	self._loadout_previews_exiting = nil
	mission_intro_team_previews_keybind_hidden = false
end)

mod:hook("MissionIntroView", "draw", function (func, self, dt, t, input_service, layer, ...)
	local result = func(self, dt, t, input_service, layer, ...)

	TeamPreview.draw_mission_intro_pass(self, dt, t, input_service, layer)

	return result
end)

mod:hook("GroupFinderView", "draw", function (func, self, dt, t, input_service, layer, ...)
	local result = func(self, dt, t, input_service, layer, ...)

	ApplicantPreview.draw_pass(self, dt, t, input_service, layer)

	return result
end)

mod:hook_safe("MissionIntroView", "_reset_spawn_slot", function (self, slot)
	TeamPreview.destroy_slot_widget(self, slot, nil, nil, self and (self._loadout_previews_exiting or self._destroyed))
end)
