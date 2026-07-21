local mod = get_mod("LoadoutPreviews")
local localization = {
	mod_name = {
		en = "Loadout Previews",
		["zh-cn"] = "装备配置预览",
	},
	mod_name_pizazz = {
		en = "{#color(0,255,85)}Loadout Previews{#reset()}",
		["zh-cn"] = "{#color(0,255,85)}装备配置预览{#reset()}",
	},
	mod_description = {
		en = "Adds saved loadout reordering and loadout previews on loadout icon hover.",
		["zh-cn"] = "添加已保存配置的重新排序和鼠标悬停配置图标时的配置预览。",
	},
	loadout_preview_enabled = {
		en = "Enable Self Previews",
		["zh-cn"] = "配置预览",
	},
	loadout_preview_enabled_tooltip = {
		en = "Show loadout previews when hovering your saved loadouts in the character panel.",
		["zh-cn"] = "配置预览总开关。关闭此选项将隐藏天赋、武器和饰品。",
	},
	talent_preview_mode = {
		en = "Preview Mode",
		["zh-cn"] = "预览模式",
	},
	talent_preview_mode_tooltip = {
		en = "Choose the hover preview style.\nDisabled: hide talents.\nTree: show the saved talent tree.\nTree + Stats: show the tree with calculated stats.\nCompact: show only Blitz, Aura, Ability, and Keystone.\nCompact + Stats: show compact talents with calculated stats.\nStats: show calculated loadout stats.",
		["zh-cn"] = "选择悬停预览样式。\n禁用：隐藏天赋。\n树形：显示已保存的天赋树。\n树形+属性：显示天赋树并计算属性。\n紧凑：仅显示战斗技能、光环、能力和基石。\n紧凑+属性：显示紧凑天赋并计算属性。\n属性：显示计算的配置属性。",
	},
	talent_preview_mode_disabled = {
		en = "Disabled",
		["zh-cn"] = "禁用",
	},
	talent_preview_mode_disabled_tooltip = {
		en = "Disable the talent tree preview entirely.",
		["zh-cn"] = "完全禁用天赋树预览。",
	},
	talent_preview_mode_tree = {
		en = "Tree",
		["zh-cn"] = "树形",
	},
	talent_preview_mode_tree_tooltip = {
		en = "Shows a small preview of the hovered loadout's talents.",
		["zh-cn"] = "显示悬停配置的天赋小预览。",
	},
	talent_preview_mode_tree_stats = {
		en = "Tree + Stats",
		["zh-cn"] = "树形+属性",
	},
	talent_preview_mode_tree_stats_tooltip = {
		en = "Shows calculated stats to the left of the talent tree and gear details.",
		["zh-cn"] = "在天赋树和装备详情左侧显示计算的属性。",
	},
	talent_preview_mode_compact = {
		en = "Compact",
		["zh-cn"] = "紧凑",
	},
	talent_preview_mode_compact_tooltip = {
		en = "Shows only the selected Blitz, Aura, Ability, and Keystone talent icons from left to right.",
		["zh-cn"] = "仅从左到右显示已选的战斗技能、光环、能力和基石天赋图标。",
	},
	talent_preview_mode_compact_stats = {
		en = "Compact + Stats",
		["zh-cn"] = "紧凑+属性",
	},
	talent_preview_mode_compact_stats_tooltip = {
		en = "Shows calculated stats to the left of compact talents and gear details.",
		["zh-cn"] = "在紧凑天赋和装备详情左侧显示计算的属性。",
	},
	talent_preview_mode_stats = {
		en = "Stats",
		["zh-cn"] = "属性",
	},
	talent_preview_mode_stats_tooltip = {
		en = "Shows calculated loadout stats. Wounds assume the highest difficulty.",
		["zh-cn"] = "显示计算的配置属性。伤口值假定为最高难度。",
	},
	preview_delay = {
		en = "Preview Delay",
		["zh-cn"] = "预览延迟",
	},
	preview_delay_tooltip = {
		en = "Seconds to wait before showing a hover preview.",
		["zh-cn"] = "显示悬停预览前等待的秒数。",
	},
	show_stats_preview = {
		en = "Show Stats",
	},
	show_stats_preview_tooltip = {
		en = "Show calculated stats when the selected preview mode includes stats. Wounds assume the highest difficulty.",
	},
	show_lobby_team_previews = {
		en = "Enable Team Previews",
		["zh-cn"] = "大厅队友预览",
	},
	show_lobby_team_previews_tooltip = {
		en = "Show teammate loadout previews in the mission lobby and Valkyrie loading screen.",
		["zh-cn"] = "在任务大厅中悬停人类玩家时显示紧凑配置预览。",
	},
	lobby_team_preview_mode = {
		en = "Lobby Preview Mode",
		["zh-cn"] = "大厅预览模式",
	},
	lobby_team_preview_mode_tooltip = {
		en = "Choose how teammate loadout previews are shown in the mission lobby.",
		["zh-cn"] = "选择任务大厅中队友配置预览的显示方式。",
	},
	lobby_team_preview_mode_off = {
		en = "Off",
		["zh-cn"] = "关闭",
	},
	lobby_team_preview_mode_off_tooltip = {
		en = "Do not show teammate loadout previews in the mission lobby.",
		["zh-cn"] = "不在任务大厅显示队友配置预览。",
	},
	lobby_team_preview_mode_hold = {
		en = "Hold",
		["zh-cn"] = "按住",
	},
	lobby_team_preview_mode_hold_tooltip = {
		en = "Show teammate loadout previews while the lobby preview keybind is held.",
		["zh-cn"] = "按住大厅预览按键时显示队友配置预览。",
	},
	lobby_team_preview_mode_toggle = {
		en = "Toggle",
		["zh-cn"] = "切换",
	},
	lobby_team_preview_mode_toggle_tooltip = {
		en = "Press the lobby preview keybind to show or hide teammate loadout previews.",
		["zh-cn"] = "按下大厅预览按键以显示或隐藏队友配置预览。",
	},
	lobby_team_preview_keybind = {
		en = "Lobby Preview Keybind",
		["zh-cn"] = "大厅预览按键",
	},
	lobby_team_preview_keybind_tooltip = {
		en = "Press to show or hide team loadout previews while in the mission lobby.",
		["zh-cn"] = "用于按住和切换大厅预览模式的按键。",
	},
	show_own_lobby_team_preview = {
		en = "Show Your Lobby Preview",
		["zh-cn"] = "显示自己的大厅预览",
	},
	show_own_lobby_team_preview_tooltip = {
		en = "Include your own loadout preview with teammate previews in the mission lobby.",
		["zh-cn"] = "在任务大厅的队友预览中同时显示自己的配置预览。",
	},
	show_lobby_tree_on_hover = {
		en = "Lobby Tree Toggle",
		["zh-cn"] = "大厅悬停显示天赋树",
	},
	show_lobby_tree_on_hover_tooltip = {
		en = "In the mission lobby, click a team preview to switch that preview between compact loadout details and the full talent tree.",
		["zh-cn"] = "在任务大厅中，悬停队伍预览时仅显示完整天赋树。",
	},
	valkyrie_team_preview_mode = {
		en = "Valkyrie Preview Mode",
		["zh-cn"] = "女武神预览模式",
	},
	valkyrie_team_preview_mode_tooltip = {
		en = "Choose how team previews are shown on the Valkyrie loading screen.",
		["zh-cn"] = "选择女武神载入界面中的队伍预览显示方式。",
	},
	valkyrie_team_preview_mode_compact = {
		en = "Compact",
		["zh-cn"] = "紧凑",
	},
	valkyrie_team_preview_mode_compact_tooltip = {
		en = "Show compact talents with the enabled team weapons and curios.",
		["zh-cn"] = "显示紧凑天赋以及已启用的队伍武器和饰品。",
	},
	valkyrie_team_preview_mode_tree = {
		en = "Tree",
		["zh-cn"] = "树形",
	},
	valkyrie_team_preview_mode_tree_tooltip = {
		en = "Show only the full talent tree for each player.",
		["zh-cn"] = "仅显示每位玩家的完整天赋树。",
	},
	valkyrie_team_preview_mode_tree_gear = {
		en = "Tree + Loadout",
		["zh-cn"] = "Tree + Loadout",
	},
	valkyrie_team_preview_mode_tree_gear_tooltip = {
		en = "Show the full talent tree beside enabled team weapons and curios.",
		["zh-cn"] = "Show the full talent tree beside enabled team weapons and curios.",
	},
	show_mission_intro_team_previews = {
		en = "Valkyrie Teammate Previews",
		["zh-cn"] = "女武神队友预览",
	},
	show_mission_intro_team_previews_tooltip = {
		en = "Show compact loadout previews for human players during the Valkyrie mission intro. Bots are skipped.",
		["zh-cn"] = "在女武神任务简报画面显示人类玩家的紧凑配置预览。机器人会被跳过。",
	},
	show_group_finder_applicant_previews = {
		en = "Enable Party Finder Previews",
		["zh-cn"] = "申请者预览",
	},
	show_group_finder_applicant_previews_tooltip = {
		en = "Show loadout previews when hovering players applying to your party finder listing.",
		["zh-cn"] = "悬停申请加入你的队伍寻找列表的玩家时，显示紧凑配置预览。",
	},
	show_team_stimm_lab_preview = {
		en = "Show Stimm Lab",
		["zh-cn"] = "队友兴奋剂实验室",
	},
	show_team_stimm_lab_preview_tooltip = {
		en = "Include Hive Scum stimm lab selections in team previews.",
		["zh-cn"] = "在队友预览中显示 Hive Scum 兴奋剂实验室选择。",
	},
	team_preview_unknown_player = {
		en = "Unknown Player",
		["zh-cn"] = "未知玩家",
	},
	preview_settings = {
		en = "Self Previews",
		["zh-cn"] = "预览",
	},
	preview_settings_tooltip = {
		en = "Options for your character panel loadout previews.",
		["zh-cn"] = "常规配置预览选项。",
	},
	show_stimm_lab_preview = {
		en = "Show Stimm Lab",
		["zh-cn"] = "显示兴奋剂实验室",
	},
	show_stimm_lab_preview_tooltip = {
		en = "Include Hive Scum stimm lab selections under the talent preview.",
		["zh-cn"] = "在天赋预览下方包含 Hive Scum 兴奋剂实验室选择。",
	},
	weapon_settings = {
		en = "Weapons",
		["zh-cn"] = "武器",
	},
	weapon_settings_tooltip = {
		en = "Weapon options for loadout previews.",
		["zh-cn"] = "配置预览的武器选项。",
	},
	show_weapon_preview = {
		en = "Show Weapons",
		["zh-cn"] = "显示武器",
	},
	show_weapon_preview_tooltip = {
		en = "Include the hovered loadout's saved melee and ranged weapons.",
		["zh-cn"] = "包含悬停配置的已保存近战和远程武器。",
	},
	show_weapon_icons_preview = {
		en = "Weapon Icons",
		["zh-cn"] = "武器图标",
	},
	show_weapon_icons_preview_tooltip = {
		en = "Show weapon icons. Turn this off to use text-only weapon rows.",
		["zh-cn"] = "显示武器图标。关闭则使用纯文本武器行。",
	},
	curio_settings = {
		en = "Curios",
		["zh-cn"] = "饰品",
	},
	curio_settings_tooltip = {
		en = "Curio options for loadout previews.",
		["zh-cn"] = "配置预览的饰品选项。",
	},
	team_settings = {
		en = "Team",
		["zh-cn"] = "队伍",
	},
	team_settings_tooltip = {
		en = "Options for team loadout previews in the lobby and Valkyrie loading screen.",
		["zh-cn"] = "任务大厅和女武神载入画面中的队友配置预览选项。",
	},
	team_weapon_settings = {
		en = "Weapons",
	},
	team_weapon_settings_tooltip = {
		en = "Weapon options for team previews.",
	},
	team_curio_settings = {
		en = "Curios",
	},
	team_curio_settings_tooltip = {
		en = "Curio options for team previews.",
	},
	show_team_weapon_preview = {
		en = "Show Weapons",
		["zh-cn"] = "队友武器",
	},
	show_team_weapon_preview_tooltip = {
		en = "Show equipped melee and ranged weapons in team previews.",
		["zh-cn"] = "显示队友装备的近战和远程武器。",
	},
	show_team_weapon_icons_preview = {
		en = "Weapon Icons",
		["zh-cn"] = "队友武器图标",
	},
	show_team_weapon_icons_preview_tooltip = {
		en = "Show weapon icons in team previews.",
		["zh-cn"] = "在队友预览中显示武器图标。",
	},
	team_weapon_preview_text_mode = {
		en = "Weapon Names",
		["zh-cn"] = "队友武器名称",
	},
	team_weapon_preview_text_mode_tooltip = {
		en = "Show weapon names in team previews, even when weapon details are hidden.",
		["zh-cn"] = "在队友预览中显示武器名称，即使武器详情已隐藏。",
	},
	show_team_weapon_blessings_preview = {
		en = "Weapon Blessings",
		["zh-cn"] = "队友武器祝福",
	},
	show_team_weapon_blessings_preview_tooltip = {
		en = "Show weapon blessing names in team previews.",
		["zh-cn"] = "显示队友武器的祝福名称。",
	},
	show_team_weapon_blessing_descriptions_preview = {
		en = "Blessing Descriptions",
		["zh-cn"] = "队友祝福描述",
	},
	show_team_weapon_blessing_descriptions_preview_tooltip = {
		en = "Append short blessing descriptions in team previews.",
		["zh-cn"] = "在队友预览中附加简短祝福描述。",
	},
	show_team_weapon_perks_preview = {
		en = "Weapon Perks",
		["zh-cn"] = "队友武器专长",
	},
	show_team_weapon_perks_preview_tooltip = {
		en = "Show weapon perk lines in team previews.",
		["zh-cn"] = "显示队友武器的专长条目。",
	},
	show_team_curio_preview = {
		en = "Show Curios",
		["zh-cn"] = "队友饰品",
	},
	show_team_curio_preview_tooltip = {
		en = "Show curio main stats in team previews.",
		["zh-cn"] = "显示队友饰品的主要属性。",
	},
	show_team_curio_perks_preview = {
		en = "Curio Perks",
		["zh-cn"] = "队友饰品专长",
	},
	show_team_curio_perks_preview_tooltip = {
		en = "Show curio perk lines in team previews.",
		["zh-cn"] = "显示队友饰品的专长条目。",
	},
	party_finder_settings = {
		en = "Party Finder",
	},
	party_finder_settings_tooltip = {
		en = "Options for applicant previews in Party Finder.",
	},
	party_finder_preview_mode = {
		en = "Preview Mode",
	},
	party_finder_preview_mode_tooltip = {
		en = "Choose the preview style for Party Finder applicant hover previews.",
	},
	party_finder_preview_delay = {
		en = "Preview Delay",
	},
	party_finder_preview_delay_tooltip = {
		en = "Seconds to wait before showing a Party Finder applicant preview.",
	},
	show_party_finder_stats_preview = {
		en = "Show Stats",
	},
	show_party_finder_stats_preview_tooltip = {
		en = "Show calculated stats when the selected Party Finder preview mode includes stats. Wounds assume the highest difficulty.",
	},
	show_party_finder_stimm_lab_preview = {
		en = "Show Stimm Lab",
	},
	show_party_finder_stimm_lab_preview_tooltip = {
		en = "Include Hive Scum stimm lab selections in Party Finder applicant previews.",
	},
	party_finder_weapon_settings = {
		en = "Weapons",
	},
	party_finder_weapon_settings_tooltip = {
		en = "Weapon options for Party Finder applicant previews.",
	},
	show_party_finder_weapon_preview = {
		en = "Show Weapons",
	},
	show_party_finder_weapon_preview_tooltip = {
		en = "Show equipped melee and ranged weapons in Party Finder applicant previews.",
	},
	show_party_finder_weapon_icons_preview = {
		en = "Weapon Icons",
	},
	show_party_finder_weapon_icons_preview_tooltip = {
		en = "Show weapon icons in Party Finder applicant previews.",
	},
	party_finder_weapon_preview_text_mode = {
		en = "Weapon Names",
	},
	party_finder_weapon_preview_text_mode_tooltip = {
		en = "Show weapon names in Party Finder applicant previews, even when weapon details are hidden.",
	},
	show_party_finder_weapon_blessings_preview = {
		en = "Weapon Blessings",
	},
	show_party_finder_weapon_blessings_preview_tooltip = {
		en = "Show weapon blessing names in Party Finder applicant previews.",
	},
	show_party_finder_weapon_blessing_descriptions_preview = {
		en = "Blessing Descriptions",
	},
	show_party_finder_weapon_blessing_descriptions_preview_tooltip = {
		en = "Append short blessing descriptions in Party Finder applicant previews.",
	},
	show_party_finder_weapon_perks_preview = {
		en = "Weapon Perks",
	},
	show_party_finder_weapon_perks_preview_tooltip = {
		en = "Show weapon perk lines in Party Finder applicant previews.",
	},
	party_finder_curio_settings = {
		en = "Curios",
	},
	party_finder_curio_settings_tooltip = {
		en = "Curio options for Party Finder applicant previews.",
	},
	show_party_finder_curio_preview = {
		en = "Show Curios",
	},
	show_party_finder_curio_preview_tooltip = {
		en = "Show curio main stats in Party Finder applicant previews.",
	},
	show_party_finder_curio_perks_preview = {
		en = "Curio Perks",
	},
	show_party_finder_curio_perks_preview_tooltip = {
		en = "Show curio perk lines in Party Finder applicant previews.",
	},
	other_settings = {
		en = "Other",
		["zh-cn"] = "其他",
	},
	other_settings_tooltip = {
		en = "Miscellaneous mod menu options.",
		["zh-cn"] = "职业特定预览选项。",
	},
	name_pizazz = {
		en = "Name Pizazz",
		["zh-cn"] = "名称特效",
	},
	name_pizazz_tooltip = {
		en = "Color the mod name in the mod menu. Changing this may require a reload to update the displayed name.",
		["zh-cn"] = "在模组菜单中为模组名称着色。更改此选项可能需要重新加载以更新显示的名称。",
	},
	use_cn_localization = {
		en = "Chinese Localization",
		["zh-cn"] = "中文本地化",
	},
	use_cn_localization_tooltip = {
		en = "Force this mod's text to use the Chinese translation. Changing this requires a reload to update the mod menu.",
		["zh-cn"] = "强制此模组文本使用中文翻译。更改此选项需要重新加载以更新模组菜单。",
	},
	show_curio_preview = {
		en = "Show Curios",
		["zh-cn"] = "显示饰品",
	},
	show_curio_preview_tooltip = {
		en = "Include the hovered loadout's saved curio main stats.",
		["zh-cn"] = "包含悬停配置的已保存饰品主要属性。",
	},
	weapon_preview_text_mode = {
		en = "Weapon Names",
		["zh-cn"] = "武器名称",
	},
	weapon_preview_text_mode_tooltip = {
		en = "Show weapon names next to weapon icons.",
		["zh-cn"] = "在武器图标旁显示武器名称。",
	},
	show_weapon_blessings_preview = {
		en = "Weapon Blessings",
		["zh-cn"] = "武器祝福",
	},
	show_weapon_blessings_preview_tooltip = {
		en = "Show each weapon's blessing names below the weapon name.",
		["zh-cn"] = "在武器名称下方显示每件武器的祝福名称。",
	},
	show_weapon_blessing_descriptions_preview = {
		en = "Blessing Descriptions",
		["zh-cn"] = "祝福描述",
	},
	show_weapon_blessing_descriptions_preview_tooltip = {
		en = "Append each weapon blessing's short description after its name.",
		["zh-cn"] = "在每个武器祝福名称后附加其简短描述。",
	},
	show_weapon_perks_preview = {
		en = "Weapon Perks",
		["zh-cn"] = "武器专长",
	},
	show_weapon_perks_preview_tooltip = {
		en = "Show each weapon's perk lines below its blessings.",
		["zh-cn"] = "在祝福下方显示每件武器的专长条目。",
	},
	show_curio_perks_preview = {
		en = "Curio Perks",
		["zh-cn"] = "饰品专长",
	},
	show_curio_perks_preview_tooltip = {
		en = "Show each curio's perk lines below its main stat.",
		["zh-cn"] = "在主要属性下方显示每个饰品的专长条目。",
	},
	move_left = {
		en = "Move Left",
		["zh-cn"] = "左移",
	},
	move_right = {
		en = "Move Right",
		["zh-cn"] = "右移",
	},
	move_up = {
		en = "Move Up",
		["zh-cn"] = "上移",
	},
	move_down = {
		en = "Move Down",
		["zh-cn"] = "下移",
	},
	preview_title = {
		en = "Talent Preview",
		["zh-cn"] = "天赋预览",
	},
	preview_no_talents = {
		en = "No saved talents",
		["zh-cn"] = "无已保存天赋",
	},
	preview_weapons_title = {
		en = "Weapons",
		["zh-cn"] = "武器",
	},
	preview_curios_title = {
		en = "Curios",
		["zh-cn"] = "饰品",
	},
	preview_stats_title = {
		en = "Stats",
		["zh-cn"] = "属性",
	},
	preview_stats_wounds = {
		en = "Wounds",
		["zh-cn"] = "伤口",
	},
	preview_stats_health = {
		en = "Health",
		["zh-cn"] = "生命值",
	},
	preview_stats_toughness = {
		en = "Toughness",
		["zh-cn"] = "韧性",
	},
	preview_stats_stamina = {
		en = "Stamina",
		["zh-cn"] = "耐力",
	},
	preview_stats_stamina_regen = {
		en = "Stamina Regen",
		["zh-cn"] = "耐力回复",
	},
	preview_stats_crit_chance = {
		en = "Crit Chance",
		["zh-cn"] = "暴击率",
	},
	preview_stats_crit_damage = {
		en = "Crit Damage",
		["zh-cn"] = "暴击伤害",
	},
	preview_stats_dodges = {
		en = "Dodges",
		["zh-cn"] = "闪避次数",
	},
	preview_stats_dodge_distance = {
		en = "Dodge Distance",
		["zh-cn"] = "闪避距离",
	},
	preview_stats_sprint_speed = {
		en = "Sprint Speed",
		["zh-cn"] = "冲刺速度",
	},
	preview_stats_sprint_time = {
		en = "Sprint Time",
		["zh-cn"] = "冲刺时间",
	},
	preview_stats_toughness_regen_delay = {
		en = "Tough Regen Delay",
		["zh-cn"] = "韧性回复延迟",
	},
	preview_stats_toughness_regen_still = {
		en = "Tough Regen Still",
		["zh-cn"] = "静止韧性回复",
	},
	preview_stats_toughness_regen_moving = {
		en = "Tough Regen Moving",
		["zh-cn"] = "移动韧性回复",
	},
	preview_stats_toughness_melee_kill = {
		en = "Tough on Melee Kill",
		["zh-cn"] = "近战击杀韧性回复",
	},
	preview_missing_weapon = {
		en = "Missing weapon",
		["zh-cn"] = "缺少武器",
	},
	preview_missing_curio = {
		en = "Missing curio",
		["zh-cn"] = "缺少饰品",
	},
	preview_points = {
		en = "%d point(s)",
		["zh-cn"] = "%d 点",
	},
	preview_more = {
		en = "+%d more",
		["zh-cn"] = "+%d 更多",
	},
	preview_ability = {
		en = "Ability: %s",
		["zh-cn"] = "能力：%s",
	},
	preview_aura_label = {
		en = "Aura:",
		["zh-cn"] = "光环：",
	},
	preview_aura = {
		en = "Aura: %s",
		["zh-cn"] = "光环：%s",
	},
	preview_blitz_label = {
		en = "Blitz:",
		["zh-cn"] = "战斗技能：",
	},
	preview_blitz = {
		en = "Blitz: %s",
		["zh-cn"] = "战斗技能：%s",
	},
	preview_keystone_label = {
		en = "Keystone:",
		["zh-cn"] = "基石：",
	},
	preview_keystone = {
		en = "Keystone: %s",
		["zh-cn"] = "基石：%s",
	},
}

if mod:get("use_cn_localization") == true then
	for _, entry in pairs(localization) do
		if type(entry) == "table" and entry["zh-cn"] then
			entry.en = entry["zh-cn"]
		end
	end
end

return localization
