-- Chinese localization provided by jcyl2023
local function cf(text, color_name)
    local color = Color[color_name](255, true)
    return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4]) .. text .. "{#color(203,203,203)}"
end
-- B站独一无二的小真寻翻译，很多词汇并不和游戏中一致
-- grenade defaults 手榴弹默认值
local box = 2
local rock = 4
local nuke = 1
local frag = 3
local krak = 2
local smoke = 3
local flame = 3
local shock = 3
local mine = 2
local arbites = 4
local dogsplosion = 3
local flask = 3
local launcher = 2
-- grenade increases 手榴弹增加
local enhanced = 2
local grenadier = 1
 
return {
    -- Mod Details Mod详细信息
    mod_name = {
        en = "AutoBlitz",
        ["zh-cn"] = "自动投掷",
    },
    mod_description = {
        en = "GRENADE OUT",    
        ["zh-cn"] = "B站 独一无二的小真寻",
    },
    -- Debug
    debug = {
        en = "Debug",
    },
    -- Groups 角色
    adamant = {
        en = cf(Localize("loc_class_adamant_name"),"medium_violet_red"), -- 
    },
    ogryn = {
        en = cf(Localize("loc_class_ogryn_name"),"ui_ogryn"),
    },
    veteran = {
        en =cf(Localize("loc_class_veteran_name"),"ui_veteran"),
    },
    zealot = {
        en = cf(Localize("loc_class_zealot_name"),"ui_zealot"),
    },
    -- Global Settings 全局设置
    allow_override = {
        en = "Allow Player Override",
        ["zh-cn"] = "允许玩家覆盖",
    },
    auto_throw_keybind = {
        en = "Auto-Throw Keybind",
    },
    auto_throw_keybind_tooltip = {
        en = "Swaps to and throws grenades. When set, AutoBlitz will not automatically throw grenades unless the keybind is pressed."
    },
    allow_override_tooltip = {
        en = "If enabled, auto-throw can be cancelled by swapping weapons or aiming.",
        ["zh-cn"] = "交换武器或瞄准取消投掷",
    },
    -- Grenade Settings 手榴弹设置
    overhand = {
        en = "Overhand",
        ["zh-cn"] = "高抛",
    },
    underhand = {
        en = "Underhand",
        ["zh-cn"] = "低抛",
    },
    -- Box 盒子雷
    box_enabled = {
        en = cf("Big Box of Hurt","ui_ogryn_text"),
        ["zh-cn"] = cf("盒子雷（欧格林）","ui_ogryn_text"),
    },
    box_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    box_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    box_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Boxes: \nStandard: %d\nEnhanced Blitz: %d", box, box + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能这么做 \n\n最大盒子雷: \n标准: %d\n强化闪击: %d", box, box + enhanced),
    },

    -- Rock 扔石头
    rock_enabled = {
        en = cf("Big Friendly Rock","ui_ogryn_text"),
        ["zh-cn"] = cf("投石头（欧格林）","ui_ogryn_text"),
    },
    rock_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    rock_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    rock_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Rocks: \nStandard: %d\nEnhanced Blitz: %d", rock, rock + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能这么做\n\n最大手雷: \n标准: %d\n强化闪击: %d", rock, rock + enhanced),
 },
    -- Nuke 核弹
    nuke_enabled = {
        en = cf("Frag Bomb","ui_ogryn_text"),
        ["zh-cn"] = cf("核弹雷（欧格林）","ui_ogryn_text"),
    },
    nuke_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    nuke_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    nuke_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Frag Bombs: \nStandard: %d\nEnhanced Blitz: %d", nuke, nuke + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能这么做.\n\n最大手雷: \n标准: %d\n强化闪击: %d", nuke, nuke + enhanced),
    },
 
    -- 老兵
    -- Frag 流血雷
    frag_enabled = {
        en = cf("Shredder Frag Grenade","ui_veteran_text"),
        ["zh-cn"] = cf("流血雷（老兵）","ui_veteran_text"),
    },
    frag_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    frag_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    frag_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Shredder Frag Grenades: \nStandard/%s: %d/%s\nEnhanced Blitz: %d/%s\n",
        cf("Grenadier", "ui_veteran_text"), frag, cf(frag + grenadier, "ui_veteran_text"), frag + enhanced, cf(frag + grenadier + enhanced, "ui_veteran_text")),
 
        ["zh-cn"] = string.format("必须有这么多手榴弹才能自动投掷\n\n最大手雷数量: \n标准/%s: %d/%s\n强化闪击: %d/%s\n",
        cf("掷弹兵", "ui_veteran_text"), frag, cf(frag + grenadier, "ui_veteran_text"), frag + enhanced, cf(frag + grenadier + enhanced, "ui_veteran_text")),
       
    },
    -- Krak 穿甲雷
    krak_enabled = {
        en = cf("Krak Grenade","ui_veteran_text"),
        ["zh-cn"] = cf("穿甲雷（老兵）","ui_veteran_text"),
    },
    krak_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    krak_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    krak_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Krak Grenades: \nStandard/%s: %d/%s\nEnhanced Blitz: %d/%s\n",
        cf("Grenadier", "ui_veteran_text"), frag, cf(krak + grenadier, "ui_veteran_text"), krak + enhanced, cf(krak + grenadier + enhanced, "ui_veteran_text")),
 
        ["zh-cn"] = string.format("必须有这么多手榴弹才能自动投掷\n\n最大手雷数量: \n标准/%s: %d/%s\n强化闪击: %d/%s\n",
        cf("掷弹兵", "ui_veteran_text"), frag, cf(frag + grenadier, "ui_veteran_text"), frag + enhanced, cf(frag + grenadier + enhanced, "ui_veteran_text")),
    },
    -- Smoke 烟雾弹
    smoke_enabled = {
        en = cf("Smoke Grenade","ui_veteran_text"),
        ["zh-cn"] = cf("烟雾弹（老兵）","ui_veteran_text"),
    },
    smoke_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    smoke_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    smoke_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Smoke Grenades: \nStandard/%s: %d/%s\nEnhanced Blitz: %d/%s\n",
        cf("Grenadier", "ui_veteran_text"), frag, cf(smoke + grenadier, "ui_veteran_text"), smoke + enhanced, cf(smoke + grenadier + enhanced, "ui_veteran_text")),
        ["zh-cn"] = string.format("必须有这么多手榴弹才能自动投掷\n\n最大手雷数量: \n标准/%s: %d/%s\n强化闪击: %d/%s\n",
        cf("掷弹兵", "ui_veteran_text"), frag, cf(frag + grenadier, "ui_veteran_text"), frag + enhanced, cf(frag + grenadier + enhanced, "ui_veteran_text")),
    },
    -- Flame 火雷
    flame_enabled = {
        en = cf("Immolation Grenade","ui_zealot_text"),
        ["zh-cn"] = cf("火雷（狂信）","ui_zealot_text"),
    },
    flame_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    flame_minimum = {
        en = "Minimum Grenades",
         ["zh-cn"] = "最小手榴弹数量阈值",
    },
    flame_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Immolation Grenades: \nStandard: %d\nEnhanced Blitz: %d", flame, flame + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能自动投掷\n\n最大手榴弹: \n标准: %d\n强化闪击: %d", flame, flame + enhanced),
    },
    -- Shock 眩晕手雷
    shock_enabled = {
        en = cf("Stunstorm Grenade","ui_zealot_text"),
        ["zh-cn"] = cf("眩晕手雷（狂信）","ui_zealot_text"),
    },
    shock_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    shock_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    shock_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum Stunstorm Grenades: \nStandard: %d\nEnhanced Blitz: %d", shock, shock + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能自动投掷\n\n最大手榴弹: \n标准: %d\n强化闪击: %d", shock, shock + enhanced),
    },
    -- Mine
    mine_enabled = {
        en = cf(Localize("loc_talent_ability_shock_mine"), "pale_violet_red") -- should be localized for all languages without further modification
    },
    mine_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    mine_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    mine_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum %s: \nStandard: %d\nEnhanced Blitz: %d", Localize("loc_talent_ability_shock_mine"), mine, mine + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能自动投掷\n\n最大手榴弹: \n标准: %d\n强化闪击: %d", mine, mine + enhanced),
    },
    -- Arbites Grenade
    arbites_enabled = {
        en = cf(Localize("loc_talent_ability_adamant_grenade"), "pale_violet_red") -- should be localized for all languages without further modification
    },
    arbites_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    arbites_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    arbites_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum %s: \nStandard: %d\nEnhanced Blitz: %d", Localize("loc_talent_ability_adamant_grenade"), arbites, arbites + enhanced),
        ["zh-cn"] = string.format("至少有这么多手雷才能自动投掷\n\n最大手榴弹: \n标准: %d\n强化闪击: %d", arbites, arbites + enhanced),
    },
    -- Dogsplosion
    dogsplosion_enabled = {
        en = cf(Localize("loc_talent_ability_detonate"), "pale_violet_red") -- should be localized for all languages without further modification
    },
    dogsplosion_enabled_tooltip = {
        en = string.format("Automatically triggers %s when the conditions below are met. \n\nAt least one of the following settings must be enabled to use this feature: \nRequire Minimum Enemy Count \nRequire Pounce",cf(Localize("loc_talent_ability_detonate"), "pale_violet_red"))
    },
    dogsplosion_use_threshold = {
        en = "Require Minimum Enemy Count"
    },
    dogsplosion_use_threshold_tooltip = {
        en = string.format("When enabled, detonation will only take place if ANY of the enemy counts below are met. \nOnly enemies within the detonation radius are counted.")
    },
    dogsplosion_enemy_threshold = {
        en = "Total Enemies"
    },
    dogsplosion_elite_threshold = {
        en = "Total Elites"
    },
    dogsplosion_special_threshold = {
        en = "Total Specialists"
    },
    dogsplosion_boss_threshold = {
        en = "Total Bosses"
    },
    dogsplosion_allow_daemonhost = {
        en = "Allow Detonation Near Sleeping Daemonhosts"
    },
    dogsplosion_pounce_only = {
        en = "Require Pounce"
    },
    dogsplosion_require_tag = {
        en = "Require Tag"
    },
    dogsplosion_require_tag_tooltip = {
        en = string.format("This setting only applies when Require Pounce is enabled. \nIf enabled, a command tag must also be present when the pounce occurs.")
    },
    dogsplosion_cooldown = {
        en = "Cooldown"
    },
    dogsplosion_minimum = {
        en = "Minimum Charges"
    },
    dogsplosion_minimum_tooltip = {
        en = string.format("Must have at least this many charges to auto-trigger.\n\nMaximum %s: \nStandard: %d\nEnhanced Blitz: %d", Localize("loc_talent_ability_detonate"), dogsplosion, dogsplosion + enhanced),
    },
    -- Hive Scum
    broker = {
        en = cf(Localize("loc_class_broker_name"), "ui_toughness_default"), -- should be localized for all languages without further modification
    },
    flask_enabled = {
        en = cf(Localize("loc_talent_broker_blitz_tox_grenade"), "ui_toughness_medium"),  -- should be localized for all languages without further modification
    },
    flask_minimum = {
        en = "Minimum Grenades",
        ["zh-cn"] = "最小手榴弹数量阈值",
    },
    flask_throw_type = {
        en = "Throw Type",
        ["zh-cn"] = "投掷类型",
    },
    flask_tooltip = {
        en = string.format("Must have at least this many grenades to auto-throw.\n\nMaximum %s: \nStandard: %d\nEnhanced Blitz: %d", Localize("loc_talent_broker_blitz_tox_grenade"), flask, flask + enhanced),
    },
    launcher_enabled = {
        en = cf(Localize("loc_talent_broker_blitz_missile_launcher"), "ui_toughness_medium"),  -- should be localized for all languages without further modification
    },
    launcher_minimum = {
        en = "Minimum Missiles",
    },
    launcher_tooltip = {
        en = string.format("Must have at least this many missiles to auto-launch.\n\nMaximum %s: \nStandard: %d\nEnhanced Blitz: %d", Localize("loc_talent_broker_blitz_missile_launcher"), launcher, launcher + enhanced),
    }
}
