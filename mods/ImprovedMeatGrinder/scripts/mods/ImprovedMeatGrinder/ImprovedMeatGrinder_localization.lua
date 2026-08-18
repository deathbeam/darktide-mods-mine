local mod = get_mod("ImprovedMeatGrinder")

return {

	mod_name = {
		en = "Improved Meat Grinder",
		["zh-cn"] = "改良灵能训练场",
		ru = "Улучшенная Мясорубка",
	},
	mod_description = {
		en = "A click-to-spawn menu for the Meat Grinder (Psykhanium) training range. Open a grid of enemies grouped by category, click to spawn, set quantity, spread and QoL toggles. Includes quick-slot hotkeys, per-stat infinite toggles, wave trials, an enemy info panel, and a hold-to-place key for dropping a horde where you aim.",
		["zh-cn"] = "灵能训练场专用敌人一键生成菜单。敌人按分类网格展示，点击即可生成，可自定义生成数量、分散范围与各类便捷功能。支持快捷栏热键、单项属性无限开关、波次测试、敌人信息面板，还有长按放置功能，能将预设敌群生成在准星瞄准位置。",
		ru = "Improved Meat Grinder - Меню для быстрого создания врагов в тренировочном полигоне Мясорубка (Псайканиум). Открывает таблицу врагов, сгруппированных по категориям, клик для спавна, настройка количества, разброса и дополнительных функций. Включает быстрые слоты, бесконечные параметры по отдельности, волновые испытания, панель информации о врагах и клавишу для размещения орды в прицеле.",
	},

	psy_menu_title = {
		en = "Improved Meat Grinder",
		["zh-cn"] = "改良灵能训练场",
		ru = "Улучшенная Мясорубка",
	},

	ui_title = {
		en = "IMPROVED MEAT GRINDER",
		["zh-cn"] = "改良灵能训练场",
		ru = "УЛУЧШЕННАЯ МЯСОРУБКА",
	},
	ui_close = {
		en = "Close",
		["zh-cn"] = "关闭",
		ru = "Закрыть",
	},
	ui_clear = {
		en = "Clear",
		["zh-cn"] = "清空",
		ru = "Очистить",
	},
	ui_spawn = {
		en = "Spawn",
		["zh-cn"] = "生成",
		ru = "Создать",
	},
	ui_spawn_fmt = {
		en = "Spawn (%%d)",
		["zh-cn"] = "生成 (%%d)",
		ru = "Создать (%%d)",
	},
	ui_page_prev = {
		en = "< Prev",
		["zh-cn"] = "< 上一页",
		ru = "< Назад",
	},
	ui_page_next = {
		en = "Next >",
		["zh-cn"] = "下一页 >",
		ru = "Вперёд >",
	},
	ui_page_fmt = {
		en = "Page %%d / %%d",
		["zh-cn"] = "第 %%d / %%d 页",
		ru = "Стр. %%d / %%d",
	},
	ui_restart = {
		en = "Restart",
		["zh-cn"] = "重新开始",
		ru = "Перезапуск",
	},
	ui_stop = {
		en = "Stop",
		["zh-cn"] = "停止",
		ru = "Стоп",
	},
	ui_next_wave = {
		en = "Next Wave",
		["zh-cn"] = "下一波",
		ru = "След. волна",
	},
	ui_kill_all = {
		en = "Kill All",
		["zh-cn"] = "清除全部",
		ru = "Убить всех",
	},
	ui_respawn = {
		en = "Respawn",
		["zh-cn"] = "复活",
		ru = "Воскресить",
	},
	ui_reset = {
		en = "Reset",
		["zh-cn"] = "重置",
		ru = "Сброс",
	},
	ui_refill_now = {
		en = "Refill Now",
		["zh-cn"] = "立即补满",
		ru = "Восполнить сейчас",
	},
	ui_horde_title_fmt = {
		en = "Horde (%%d)",
		["zh-cn"] = "敌群 (%%d)",
		ru = "Орда (%%d)",
	},
	ui_queue_hint = {
		en = "Click a row for its info.  - / + count,  X removes it.",
		["zh-cn"] = "点击行查看详情， - / + 调整数量， X 移除。",
		ru = "Кликните по строке для информации. - / + меняет количество, X удаляет.",
	},
	ui_enemy_info = {
		en = "Enemy Info",
		["zh-cn"] = "敌人信息",
		ru = "Инфо о враге",
	},
	ui_stats_hint = {
		en = "Hover an enemy to see its\narmour and health.",
		["zh-cn"] = "悬停敌人查看\n装甲与生命值。",
		ru = "Наведите курсор на врага,\nчтобы увидеть броню и здоровье.",
	},
	ui_health_fmt = {
		en = "Health: %%s",
		["zh-cn"] = "生命值: %%s",
		ru = "Здоровье: %%s",
	},
	ui_na = {
		en = "n/a",
		["zh-cn"] = "无数据",
		ru = "н/д",
	},
	ui_no_indulgences = {
		en = "No indulgences found",
		["zh-cn"] = "未找到恩赐",
		ru = "Индульгенции не найдены",
	},
	ui_indulgences_unavail = {
		en = "Indulgences unavailable",
		["zh-cn"] = "恩赐不可用",
		ru = "Индульгенции недоступны",
	},
	ui_more_types_fmt = {
		en = "+ %%d more types",
		["zh-cn"] = "+ 还有 %%d 种",
		ru = "+ ещё %%d типов",
	},

	mode_spawn = {
		en = "Spawn",
		["zh-cn"] = "生成",
		ru = "Создание",
	},
	mode_waves = {
		en = "Waves",
		["zh-cn"] = "波次",
		ru = "Волны",
	},
	mode_player = {
		en = "Player",
		["zh-cn"] = "玩家",
		ru = "Игрок",
	},
	mode_indulge = {
		en = "Indulge",
		["zh-cn"] = "恩赐",
		ru = "Индульгенции",
	},
	mode_misc = {
		en = "Extras",
		["zh-cn"] = "附加",
		ru = "Дополнительно",
	},

	btn_mode_click = {
		en = "Mode: Click",
		["zh-cn"] = "模式: 点击即生成",
		ru = "Режим: Клик",
	},
	btn_mode_select = {
		en = "Mode: Select",
		["zh-cn"] = "模式: 预选编组",
		ru = "Режим: Выбор",
	},
	btn_aim_on = {
		en = "Aim: On",
		["zh-cn"] = "瞄准: 开",
		ru = "Прицел: Вкл",
	},
	btn_aim_off = {
		en = "Aim: Off",
		["zh-cn"] = "瞄准: 关",
		ru = "Прицел: Выкл",
	},
	btn_horde_keep = {
		en = "Horde: Keep",
		["zh-cn"] = "敌群: 保留",
		ru = "Орда: Сохранять",
	},
	btn_horde_once = {
		en = "Horde: Once",
		["zh-cn"] = "敌群: 单次",
		ru = "Орда: 1 раз",
	},
	btn_on_close_fmt = {
		en = "On Close: %%s",
		["zh-cn"] = "关闭时: %%s",
		ru = "Закрытие: %%s",
	},
	btn_count_fmt = {
		en = "Count: %%d",
		["zh-cn"] = "数量: %%d",
		ru = "Кол-во: %%d",
	},
	btn_spread_fmt = {
		en = "Spread: %%d",
		["zh-cn"] = "分散: %%d",
		ru = "Разброс: %%d",
	},

	god_label_all = {
		en = "All",
		["zh-cn"] = "全部",
		ru = "Всё",
	},
	god_label_toughness = {
		en = "Toughness",
		["zh-cn"] = "韧性",
		ru = "Стойкость",
	},
	god_label_health = {
		en = "Health",
		["zh-cn"] = "生命值",
		ru = "Здоровье",
	},
	god_label_ammo = {
		en = "Ammo",
		["zh-cn"] = "备弹",
		ru = "Боезапас",
	},
	god_label_magazine = {
		en = "Magazine",
		["zh-cn"] = "弹匣",
		ru = "Магазин",
	},
	god_label_ability = {
		en = "Ability",
		["zh-cn"] = "技能",
		ru = "Способность",
	},
	god_label_blitz = {
		en = "Blitz",
		["zh-cn"] = "手雷",
		ru = "Гранаты",
	},
	god_label_stamina = {
		en = "Stamina",
		["zh-cn"] = "体力",
		ru = "Выносливость",
	},
	god_label_dodge = {
		en = "Dodge",
		["zh-cn"] = "闪避",
		ru = "Уклонение",
	},
	god_label_invuln = {
		en = "Invuln",
		["zh-cn"] = "无敌",
		ru = "Неуязвимость",
	},
	god_label_no_peril_gain = {
		en = "No Peril Gain",
		["zh-cn"] = "无灵能积累",
		ru = "Без накопления опасности",
	},
	god_label_no_peril_death = {
		en = "No Peril Death",
		["zh-cn"] = "无灵能自爆",
		ru = "Без смерти от опасности",
	},

	misc_ai_fmt = {
		en = "AI: %%s",
		["zh-cn"] = "敌人AI: %%s",
		ru = "Интеллект: %%s",
	},
	misc_no_def_fmt = {
		en = "No Def: %%s",
		["zh-cn"] = "关闭原生: %%s",
		ru = "Без стандартных: %%s",
	},
	misc_muffler_on = {
		en = "Muffler: On",
		["zh-cn"] = "音效压制: 开",
		ru = "Заглушить: Вкл",
	},
	misc_muffler_off = {
		en = "Muffler: Off",
		["zh-cn"] = "音效压制: 关",
		ru = "Заглушить: Выкл",
	},
	misc_whispers_on = {
		en = "Whispers: On",
		["zh-cn"] = "灵能低语: 开",
		ru = "Шёпот: Вкл",
	},
	misc_whispers_off = {
		en = "Whispers: Off",
		["zh-cn"] = "灵能低语: 关",
		ru = "Шёпот: Выкл",
	},
	misc_props_hidden = {
		en = "Props: Hidden",
		["zh-cn"] = "道具: 已隐藏",
		ru = "Предметы: Скрыты",
	},
	misc_props_shown = {
		en = "Props: Shown",
		["zh-cn"] = "道具: 显示",
		ru = "Предметы: Показаны",
	},
	misc_continuous_fmt = {
		en = "Continuous: %%s",
		["zh-cn"] = "持续补充: %%s",
		ru = "Непрерывно: %%s",
	},
	misc_lineup_missing = {
		en = "Lineup: Missing",
		["zh-cn"] = "敌群: 遗漏怪物",
		ru = "Состав: Пропущенные",
	},
	misc_lineup_default = {
		en = "Lineup: Default",
		["zh-cn"] = "敌群: 默认",
		ru = "Состав: Стандартный",
	},
	misc_infinite_hp_fmt = {
		en = "Infinite HP: %%s",
		["zh-cn"] = "无限血量: %%s",
		ru = "Бессмертные: %%s",
	},
	misc_invisible_fmt = {
		en = "Invisible: %%s",
		["zh-cn"] = "隐身: %%s",
		ru = "Невидимость: %%s",
	},
	misc_auto_on = {
		en = "Auto: On",
		["zh-cn"] = "自动: 开",
		ru = "Авто: Вкл",
	},
	misc_auto_off = {
		en = "Auto: Off",
		["zh-cn"] = "自动: 关",
		ru = "Авто: Выкл",
	},

	state_on = {
		en = "On",
		["zh-cn"] = "开",
		ru = "Вкл",
	},
	state_off = {
		en = "Off",
		["zh-cn"] = "关",
		ru = "Выкл",
	},

	armor_unarmored = {
		en = "Unarmoured",
		["zh-cn"] = "无装甲",
		ru = "Небронированный",
	},
	armor_infested = {
		en = "Infested",
		["zh-cn"] = "感染",
		ru = "Заражённый",
	},
	armor_flak = {
		en = "Flak",
		["zh-cn"] = "防弹甲",
		ru = "Осколочная",
	},
	armor_carapace = {
		en = "Carapace",
		["zh-cn"] = "硬壳甲",
		ru = "Панцирная",
	},
	armor_maniac = {
		en = "Maniac",
		["zh-cn"] = "狂人",
		ru = "Безумный",
	},
	armor_unyielding = {
		en = "Unyielding",
		["zh-cn"] = "不屈",
		ru = "Непреклонный",
	},
	armor_void_shield = {
		en = "Void Shield",
		["zh-cn"] = "虚空盾",
		ru = "Пустотный щит",
	},

	zone_head = {
		en = "Head",
		["zh-cn"] = "头部",
		ru = "Голова",
	},
	zone_body = {
		en = "Body",
		["zh-cn"] = "躯干",
		ru = "Туловище",
	},
	zone_arms = {
		en = "Arms",
		["zh-cn"] = "手臂",
		ru = "Руки",
	},
	zone_legs = {
		en = "Legs",
		["zh-cn"] = "腿部",
		ru = "Ноги",
	},
	zone_tail = {
		en = "Tail",
		["zh-cn"] = "尾部",
		ru = "Хвост",
	},
	zone_tongue = {
		en = "Tongue",
		["zh-cn"] = "舌头",
		ru = "Язык",
	},
	zone_tentacle = {
		en = "Tentacle",
		["zh-cn"] = "触手",
		ru = "Щупальце",
	},
	zone_weakspot = {
		en = "Weak spot",
		["zh-cn"] = "弱点",
		ru = "Уязвимое место",
	},
	zone_shield = {
		en = "Shield",
		["zh-cn"] = "护盾",
		ru = "Щит",
	},
	zone_shoulder = {
		en = "Shoulder",
		["zh-cn"] = "肩甲",
		ru = "Плечо",
	},
	zone_void_shield = {
		en = "Void shield",
		["zh-cn"] = "虚空盾",
		ru = "Пустотный щит",
	},
	zone_backpack = {
		en = "Backpack",
		["zh-cn"] = "背包",
		ru = "Рюкзак",
	},
	zone_corruptor = {
		en = "Corruptor",
		["zh-cn"] = "腐化护甲",
		ru = "Осквернитель",
	},

	notify_host_only = {
		en = "Spawning only works as host.",
		["zh-cn"] = "只有主机才能生成敌人。",
		ru = "Создание работает только у хоста.",
	},
	notify_psykhanium_only = {
		en = "Only in the Psykhanium training range.",
		["zh-cn"] = "仅在灵能训练场可用。",
		ru = "Только в тренировочном полигоне Псайканиума.",
	},
	notify_no_spawn_position = {
		en = "Could not find a spawn position.",
		["zh-cn"] = "无法找到生成位置。",
		ru = "Не удалось найти позицию для создания.",
	},
	notify_spawned_fmt = {
		en = "Spawned %%d (inert)",
		["zh-cn"] = "已生成 %%d 个敌人（静止）",
		ru = "Создано %%d (неподвижны)",
	},
	notify_spawned_active_fmt = {
		en = "Spawned %%d",
		["zh-cn"] = "已生成 %%d 个敌人",
		ru = "Создано %%d",
	},
	notify_unknown_breed = {
		en = "Unknown breed: %%s",
		["zh-cn"] = "未知敌人类型: %%s",
		ru = "Неизвестный тип: %%s",
	},
	notify_immortal_hp_range_only = {
		en = "Infinite enemy HP works in the Meat Grinder only.",
		["zh-cn"] = "敌人无限血量仅在灵能训练场可用。",
		ru = "Бесконечное здоровье врагов работает только в Мясорубке.",
	},
	notify_immortal_hp_on = {
		en = "Infinite enemy HP: ON",
		["zh-cn"] = "敌人无限血量: 开",
		ru = "Бесконечное здоровье врагов: ВКЛ",
	},
	notify_immortal_hp_off = {
		en = "Infinite enemy HP: OFF",
		["zh-cn"] = "敌人无限血量: 关",
		ru = "Бесконечное здоровье врагов: ВЫКЛ",
	},
	notify_killed_all = {
		en = "Cleared all spawns.",
		["zh-cn"] = "已清除所有生成敌人。",
		ru = "Все созданные враги удалены.",
	},
	notify_refilled = {
		en = "Refilled toughness, health, ammo and ability.",
		["zh-cn"] = "已补满韧性、生命、弹药和技能。",
		ru = "Восполнены стойкость, здоровье, боезапас и способность.",
	},
	notify_refill_range_only = {
		en = "Only works in the Meat Grinder.",
		["zh-cn"] = "仅在灵能训练场可用。",
		ru = "Работает только в Мясорубке.",
	},
	notify_nothing_spawned = {
		en = "Nothing spawned yet.",
		["zh-cn"] = "尚未生成任何敌人。",
		ru = "Пока ничего не создано.",
	},
	notify_no_player_unit = {
		en = "No player unit to revive.",
		["zh-cn"] = "没有可复活的玩家单位。",
		ru = "Нет игрока для воскрешения.",
	},
	notify_respawned = {
		en = "Respawn / revive attempted.",
		["zh-cn"] = "已尝试复活。",
		ru = "Попытка воскрешения.",
	},
	notify_quick_slot_empty = {
		en = "Quick slot is empty. Set it in mod options (F4).",
		["zh-cn"] = "快捷栏为空，请在模组设置 (F4) 中配置。",
		ru = "Быстрый слот пуст. Настройте в опциях мода (F4).",
	},
	notify_open_psykhanium = {
		en = "Open the Psykhanium first.",
		["zh-cn"] = "请先进入灵能训练场。",
		ru = "Сначала откройте Псайканиум.",
	},
	notify_menu_failed = {
		en = "Menu failed to open. Use the quick-slot hotkeys instead.",
		["zh-cn"] = "菜单打开失败，可使用快捷栏热键代替。",
		ru = "Не удалось открыть меню. Используйте горячие клавиши быстрых слотов.",
	},
	notify_menu_view_failed = {
		en = "Improved Meat Grinder: menu view registration failed (%%s). Hotkeys still work.",
		["zh-cn"] = "改良灵能训练场: 菜单视图注册失败 (%%s)，热键仍可使用。",
		ru = "Улучшенная Мясорубка: не удалось зарегистрировать представление меню (%%s). Горячие клавиши работают.",
	},
	notify_trial_complete_fmt = {
		en = "Trial complete: %%s",
		["zh-cn"] = "试炼完成: %%s",
		ru = "Испытание завершено: %%s",
	},
	notify_wave_fmt = {
		en = "Wave %%d",
		["zh-cn"] = "第 %%d 波",
		ru = "Волна %%d",
	},
	notify_trials_range_only = {
		en = "Trials run in the Meat Grinder only.",
		["zh-cn"] = "波次试炼仅在灵能训练场可用。",
		ru = "Испытания доступны только в Мясорубке.",
	},
	notify_auto_waves_on = {
		en = "Auto-advance waves: ON",
		["zh-cn"] = "自动推进波次: 开",
		ru = "Автопродвижение волн: ВКЛ",
	},
	notify_auto_waves_off = {
		en = "Auto-advance waves: OFF",
		["zh-cn"] = "自动推进波次: 关",
		ru = "Автопродвижение волн: ВЫКЛ",
	},
	notify_muffler_off_desc = {
		en = "Sound muffler: OFF (full audio)",
		["zh-cn"] = "音效压制: 关（完整音频）",
		ru = "Глушитель звука: ВЫКЛ (полный звук)",
	},
	notify_muffler_on_desc = {
		en = "Sound muffler: ON",
		["zh-cn"] = "音效压制: 开",
		ru = "Глушитель звука: ВКЛ",
	},
	notify_whispers_off_desc = {
		en = "Whispers: OFF",
		["zh-cn"] = "灵能低语: 关",
		ru = "Шёпот: ВЫКЛ",
	},
	notify_whispers_on_desc = {
		en = "Whispers: ON",
		["zh-cn"] = "灵能低语: 开",
		ru = "Шёпот: ВКЛ",
	},
	notify_continuous_on = {
		en = "Continuous horde: ON",
		["zh-cn"] = "持续补充敌群: 开",
		ru = "Непрерывная орда: ВКЛ",
	},
	notify_continuous_off = {
		en = "Continuous horde: OFF",
		["zh-cn"] = "持续补充敌群: 关",
		ru = "Непрерывная орда: ВЫКЛ",
	},
	notify_lineup_missing = {
		en = "Lineup: Missing enemies",
		["zh-cn"] = "敌群切换: 遗漏怪物",
		ru = "Состав: Пропущенные враги",
	},
	notify_lineup_default = {
		en = "Lineup: Default",
		["zh-cn"] = "敌群切换: 默认",
		ru = "Состав: Стандартный",
	},
	notify_lineup_range_only = {
		en = "Lineup swap only works in the Meat Grinder.",
		["zh-cn"] = "敌群替换仅在灵能训练场可用。",
		ru = "Смена состава работает только в Мясорубке.",
	},
	notify_enemy_ai_on = {
		en = "Enemy AI: ON",
		["zh-cn"] = "敌人AI: 开",
		ru = "ИИ врагов: ВКЛ",
	},
	notify_enemy_ai_off = {
		en = "Enemy AI: OFF",
		["zh-cn"] = "敌人AI: 关",
		ru = "ИИ врагов: ВЫКЛ",
	},
	notify_ai_range_only = {
		en = "Enemy AI toggle only works in the Meat Grinder.",
		["zh-cn"] = "敌人AI切换仅在灵能训练场可用。",
		ru = "Переключение ИИ врагов работает только в Мясорубке.",
	},
	notify_invis_range_only = {
		en = "Invisibility works in the Meat Grinder only.",
		["zh-cn"] = "隐身仅在灵能训练场可用。",
		ru = "Невидимость работает только в Мясорубке.",
	},
	notify_invisible_on = {
		en = "Invisible: ON",
		["zh-cn"] = "隐身: 开",
		ru = "Невидимость: ВКЛ",
	},
	notify_invisible_off = {
		en = "Invisible: OFF",
		["zh-cn"] = "隐身: 关",
		ru = "Невидимость: ВЫКЛ",
	},
	notify_prepare_mode = {
		en = "Prepare mode: you are hidden and enemies are inert. Toggle Invisible off (Extras) when ready to fight.",
		["zh-cn"] = "准备模式：你已隐身，敌人静止。准备战斗时在附加面板关闭隐身。",
		ru = "Режим подготовки: вы скрыты, враги неподвижны. Выключите невидимость (в Дополнительно), когда будете готовы к бою.",
	},
	notify_reset_done = {
		en = "Reset. You are hidden and enemies are inert. Toggle Invisible off to fight.",
		["zh-cn"] = "已重置。你已隐身，敌人静止。关闭隐身即可开始战斗。",
		ru = "Сброс выполнен. Вы скрыты, враги неподвижны. Выключите невидимость, чтобы начать бой.",
	},
	notify_reset_range_only = {
		en = "Reset only works in the Meat Grinder.",
		["zh-cn"] = "重置仅在灵能训练场可用。",
		ru = "Сброс работает только в Мясорубке.",
	},
	notify_hold_range_only = {
		en = "Hold-to-place only works in the Meat Grinder.",
		["zh-cn"] = "长按放置仅在灵能训练场可用。",
		ru = "Размещение по удержанию работает только в Мясорубке.",
	},
	notify_hold_nothing_queued = {
		en = "Nothing queued. Build a horde in the menu (Select mode) first.",
		["zh-cn"] = "队列为空，请先在菜单中预选敌人（预选模式）。",
		ru = "Ничего не добавлено в очередь. Сначала соберите орду в меню (режим Выбор).",
	},
	notify_indulgences_range_only = {
		en = "Indulgences apply in the Meat Grinder only.",
		["zh-cn"] = "恩赐仅在灵能训练场可用。",
		ru = "Индульгенции действуют только в Мясорубке.",
	},
	notify_indulgence_on_fmt = {
		en = "Indulgence on: %%s",
		["zh-cn"] = "恩赐已开启: %%s",
		ru = "Индульгенция включена: %%s",
	},
	notify_indulgence_off_fmt = {
		en = "Indulgence off: %%s",
		["zh-cn"] = "恩赐已关闭: %%s",
		ru = "Индульгенция выключена: %%s",
	},
	notify_indulgences_cleared_fmt = {
		en = "Cleared %%d indulgence(s).",
		["zh-cn"] = "已清除 %%d 个恩赐。",
		ru = "Очищено индульгенций: %%d",
	},

	notify_god_all_on = {
		en = "Infinite all: ON",
		["zh-cn"] = "全能无敌: 开",
		ru = "Всё бесконечно: ВКЛ",
	},
	notify_god_all_off = {
		en = "Infinite all: OFF",
		["zh-cn"] = "全能无敌: 关",
		ru = "Всё бесконечно: ВЫКЛ",
	},
	notify_god_toughness_on = {
		en = "Infinite toughness: ON",
		["zh-cn"] = "无限韧性: 开",
		ru = "Бесконечная стойкость: ВКЛ",
	},
	notify_god_toughness_off = {
		en = "Infinite toughness: OFF",
		["zh-cn"] = "无限韧性: 关",
		ru = "Бесконечная стойкость: ВЫКЛ",
	},
	notify_god_health_on = {
		en = "Infinite health: ON",
		["zh-cn"] = "无限生命: 开",
		ru = "Бесконечное здоровье: ВКЛ",
	},
	notify_god_health_off = {
		en = "Infinite health: OFF",
		["zh-cn"] = "无限生命: 关",
		ru = "Бесконечное здоровье: ВЫКЛ",
	},
	notify_god_ammo_on = {
		en = "Infinite ammo: ON",
		["zh-cn"] = "无限弹药: 开",
		ru = "Бесконечный боезапас: ВКЛ",
	},
	notify_god_ammo_off = {
		en = "Infinite ammo: OFF",
		["zh-cn"] = "无限弹药: 关",
		ru = "Бесконечный боезапас: ВЫКЛ",
	},
	notify_god_magazine_on = {
		en = "Infinite magazine: ON",
		["zh-cn"] = "无限弹匣: 开",
		ru = "Бесконечный магазин: ВКЛ",
	},
	notify_god_magazine_off = {
		en = "Infinite magazine: OFF",
		["zh-cn"] = "无限弹匣: 关",
		ru = "Бесконечный магазин: ВЫКЛ",
	},
	notify_god_ability_on = {
		en = "Infinite ability: ON",
		["zh-cn"] = "无限技能: 开",
		ru = "Бесконечная способность: ВКЛ",
	},
	notify_god_ability_off = {
		en = "Infinite ability: OFF",
		["zh-cn"] = "无限技能: 关",
		ru = "Бесконечная способность: ВЫКЛ",
	},
	notify_god_blitz_on = {
		en = "Infinite blitz: ON",
		["zh-cn"] = "无限手雷: 开",
		ru = "Бесконечные гранаты: ВКЛ",
	},
	notify_god_blitz_off = {
		en = "Infinite blitz: OFF",
		["zh-cn"] = "无限手雷: 关",
		ru = "Бесконечные гранаты: ВЫКЛ",
	},
	notify_god_stamina_on = {
		en = "Infinite stamina: ON",
		["zh-cn"] = "无限体力: 开",
		ru = "Бесконечная выносливость: ВКЛ",
	},
	notify_god_stamina_off = {
		en = "Infinite stamina: OFF",
		["zh-cn"] = "无限体力: 关",
		ru = "Бесконечная выносливость: ВЫКЛ",
	},
	notify_god_dodge_on = {
		en = "Infinite dodges: ON",
		["zh-cn"] = "无限闪避: 开",
		ru = "Бесконечные уклонения: ВКЛ",
	},
	notify_god_dodge_off = {
		en = "Infinite dodges: OFF",
		["zh-cn"] = "无限闪避: 关",
		ru = "Бесконечные уклонения: ВЫКЛ",
	},
	notify_god_invuln_on = {
		en = "Invulnerable: ON",
		["zh-cn"] = "无敌: 开",
		ru = "Неуязв.: ВКЛ",
	},
	notify_god_invuln_off = {
		en = "Invulnerable: OFF",
		["zh-cn"] = "无敌: 关",
		ru = "Неуязв.: ВЫКЛ",
	},
	notify_god_no_peril_gain_on = {
		en = "No peril gain: ON",
		["zh-cn"] = "无灵能积累: 开",
		ru = "Нет опасности: ВКЛ",
	},
	notify_god_no_peril_gain_off = {
		en = "No peril gain: OFF",
		["zh-cn"] = "无灵能积累: 关",
		ru = "Нет опасности: ВЫКЛ",
	},
	notify_god_no_peril_death_on = {
		en = "No peril death: ON",
		["zh-cn"] = "无灵能自爆: 开",
		ru = "Опасность не убивает: ВКЛ",
	},
	notify_god_no_peril_death_off = {
		en = "No peril death: OFF",
		["zh-cn"] = "无灵能自爆: 关",
		ru = "Опасность не убивает: ВЫКЛ",
	},

	wave_idle = {
		en = "Idle",
		["zh-cn"] = "空闲",
		ru = "Ожидание",
	},
	wave_status_fmt = {
		en = "%%s - Wave %%d",
		["zh-cn"] = "%%s - 第 %%d 波",
		ru = "%%s - Волна %%d",
	},

	preset_gunner_line = {
		en = "Gunner Line",
		["zh-cn"] = "枪手阵线",
		ru = "Линия стрелков",
	},
	preset_melee_rush = {
		en = "Melee Rush",
		["zh-cn"] = "近战冲锋",
		ru = "Рукопашный натиск",
	},
	preset_elite_squad = {
		en = "Elite Squad",
		["zh-cn"] = "精英小队",
		ru = "Элитный отряд",
	},
	preset_specialists = {
		en = "Specialist Nightmare",
		["zh-cn"] = "专家噩梦",
		ru = "Кошмар спецов",
	},
	preset_monsters = {
		en = "Monster Mash",
		["zh-cn"] = "巨兽混战",
		ru = "Смесь монстров",
	},
	preset_mixed_horde = {
		en = "Mixed Horde",
		["zh-cn"] = "混合敌群",
		ru = "Смешанная орда",
	},

	trial_disabler = {
		en = "Disabler Drill",
		["zh-cn"] = "控制者训练",
		ru = "Обездвиживатели",
	},
	trial_ranged = {
		en = "Ranged Drill",
		["zh-cn"] = "远程训练",
		ru = "Стрельбы",
	},
	trial_boss_rush = {
		en = "Boss Rush",
		["zh-cn"] = "首领连战",
		ru = "Босс-раш",
	},
	trial_endless = {
		en = "Endless Horde",
		["zh-cn"] = "无尽敌潮",
		ru = "Бесконечная орда",
	},

	cat_regular = {
		en = "Infantry",
		["zh-cn"] = "步兵",
		ru = "Пехота",
	},
	cat_elite = {
		en = "Elites",
		["zh-cn"] = "精英",
		ru = "Элита",
	},
	cat_specialist = {
		en = "Specialists",
		["zh-cn"] = "专家",
		ru = "Спецы",
	},
	cat_boss = {
		en = "Monstrosities",
		["zh-cn"] = "巨兽",
		ru = "Чудовища",
	},
	cat_misc = {
		en = "Misc",
		["zh-cn"] = "杂项",
		ru = "Разное",
	},
	cat_allies = {
		en = "Allies",
		["zh-cn"] = "友军",
		ru = "Союзники",
	},
	ps_show_bot_hud = {
		en = "Show ally health bars (party HUD)",
		["zh-cn"] = "显示友军血条（队伍HUD）",
		ru = "Показывать полосы здоровья союзников (интерфейс отряда)",
	},
	ps_show_bot_hud_description = {
		en = "Show spawned allies on the team HUD with full mission-style health and toughness bars. Takes effect on your next Meat Grinder entry. Meat Grinder only; experimental.",
		["zh-cn"] = "在队伍HUD上以完整任务样式显示友军的血量与韧性条。将在你下次进入灵能训练场时生效。仅灵能训练场，实验性功能。",
		ru = "Показывать созданных союзников в интерфейс отряда с полосками здоровья и стойкости, как в миссиях. Вступает в силу при следующем входе в Мясорубку. Только Мясорубка, экспериментально.",
	},
	ps_no_stagger = {
		en = "Enemies don't stagger",
		["zh-cn"] = "敌人不受硬直",
		ru = "Враги не получают ошеломление",
	},
	ps_no_stagger_description = {
		en = "On: enemies you hit don't stagger, flinch or get knocked back, so stagger-prone enemies stay put while you test damage and weak spots. Damage still applies normally. Meat Grinder only.",
		["zh-cn"] = "开启：被你击中的敌人不会硬直、踉跄或被击退，方便你在原地测试易硬直敌人的伤害与弱点。伤害仍正常结算。仅灵能训练场。",
		ru = "Вкл: атакованные враги не получают ошеломление, не шатаются или отталкиваются, что позволяет тестировать урон и уязвимые места на врагах, склонных к ошеломлению. Урон наносится нормально. Только Мясорубка.",
	},
	ps_key_no_stagger = {
		en = "Toggle enemies don't stagger",
		["zh-cn"] = "开关敌人不受硬直",
		ru = "Переключить отсутствие ошеломления у врагов",
	},
	ps_key_no_stagger_description = {
		en = "Toggle whether enemies stagger/knock back when hit. Meat Grinder only.",
		["zh-cn"] = "切换敌人被击中时是否会硬直/被击退。仅灵能训练场。",
		ru = "Переключает, получают ли враги ошеломление/отталкивание при попадании. Только Мясорубка.",
	},
	misc_no_stagger_fmt = {
		en = "No stagger: %%s",
		["zh-cn"] = "无硬直: %%s",
		ru = "Без ошеломления: %%s",
	},
	tip_m_nostagger = {
		en = "Enemies don't stagger or get knocked back when hit (damage still applies). Good for testing stagger-prone enemies.",
		["zh-cn"] = "敌人被击中时不会硬直或被击退（伤害仍生效）。适合测试易硬直的敌人。",
		ru = "Враги не получают ошеломление или отталкивание при попадании (урон применяется). Полезно для тестирования врагов, склонных к ошеломлению.",
	},
	notify_no_stagger_on = {
		en = "Enemies don't stagger: ON",
		["zh-cn"] = "敌人不受硬直：开",
		ru = "Враги без ошеломления: ВКЛ",
	},
	notify_no_stagger_off = {
		en = "Enemies don't stagger: OFF",
		["zh-cn"] = "敌人不受硬直：关",
		ru = "Враги без ошеломления: ВЫКЛ",
	},
	notify_no_stagger_range_only = {
		en = "No-stagger only works in the Meat Grinder.",
		["zh-cn"] = "无硬直仅在灵能训练场可用。",
		ru = "Отсутствие ошеломления работает только в Мясорубке.",
	},
	bot_mode_active = {
		en = "Active",
		["zh-cn"] = "主动",
		ru = "Активный",
	},
	bot_mode_passive = {
		en = "Passive",
		["zh-cn"] = "被动",
		ru = "Пассивный",
	},
	bot_mode_frozen = {
		en = "Frozen",
		["zh-cn"] = "静止",
		ru = "Заморожен",
	},
	ally_mode_fmt = {
		en = "Behaviour: %%s",
		["zh-cn"] = "行为: %%s",
		ru = "Поведение: %%s",
	},
	ps_bot_mode = {
		en = "Ally behaviour",
		["zh-cn"] = "友军行为",
		ru = "Поведение союзников",
	},
	ps_bot_mode_description = {
		en = "Active: allies fight normally. Passive: allies follow you but never attack, so they cannot steal kills. Frozen: allies stand still and do nothing. Useful for testing coherency and enemy damage. Meat Grinder only.",
		["zh-cn"] = "主动：友军正常战斗。被动：友军跟随你但从不攻击，不会抢人头。静止：友军原地不动。适合测试凝聚力与敌人伤害。仅灵能训练场。",
		ru = "Активный: союзники сражаются нормально. Пассивный: союзники следуют за вами, но не атакуют, чтобы не отбирать убийства. Заморожен: союзники стоят неподвижно. Полезно для тестирования сплочённости и урона врагов. Только Мясорубка.",
	},
	ps_key_bot_mode = {
		en = "Cycle ally behaviour",
		["zh-cn"] = "切换友军行为",
		ru = "Циклично менять поведение союзников",
	},
	ps_key_bot_mode_description = {
		en = "Cycle allies between Active, Passive (follow but never attack) and Frozen (stand still). Meat Grinder only.",
		["zh-cn"] = "在主动、被动（跟随但不攻击）与静止（原地不动）之间循环切换友军行为。仅灵能训练场。",
		ru = "Переключает союзников между режимами Активный, Пассивный (следуют, но не атакуют) и Заморожен (стоят). Только Мясорубка.",
	},
	notify_bot_mode_fmt = {
		en = "Allies: %%s",
		["zh-cn"] = "友军：%%s",
		ru = "Союзники: %%s",
	},
	notify_bot_mode_range_only = {
		en = "Ally behaviour only works in the Meat Grinder.",
		["zh-cn"] = "友军行为仅在灵能训练场可用。",
		ru = "Поведение союзников работает только в Мясорубке.",
	},
	ally_slot_fmt = {
		en = "Ally %%d",
		["zh-cn"] = "友军 %%d",
		ru = "Союзник %%d",
	},
	ally_random = {
		en = "Random ally",
		["zh-cn"] = "随机友军",
		ru = "Случайный союзник",
	},
	ally_remove_one = {
		en = "Remove one",
		["zh-cn"] = "移除一名",
		ru = "Удалить одного",
	},
	ally_remove_all = {
		en = "Remove all",
		["zh-cn"] = "全部移除",
		ru = "Удалить всех",
	},
	ally_count_fmt = {
		en = "Allies: %%d / %%d",
		["zh-cn"] = "友军：%%d / %%d",
		ru = "Союзники: %%d / %%d",
	},
	tip_tab_allies = {
		en = "Spawn friendly mission bots to fight alongside you (max 3).",
		["zh-cn"] = "生成任务中的友方机器人与你并肩作战（最多3名）。",
		ru = "Создаёт дружественных ботов из миссий для боя вместе с вами (максимум 3).",
	},
	notify_bot_spawned = {
		en = "Ally spawned (%%d/%%d)",
		["zh-cn"] = "已生成友军（%%d/%%d）",
		ru = "Союзник создан (%%d/%%d)",
	},
	notify_bot_removed_one = {
		en = "Ally removed (%%d/%%d)",
		["zh-cn"] = "已移除友军（%%d/%%d）",
		ru = "Союзник удалён (%%d/%%d)",
	},
	notify_bots_removed = {
		en = "All allies removed.",
		["zh-cn"] = "已移除所有友军。",
		ru = "Все союзники удалены.",
	},
	notify_bots_full = {
		en = "Ally limit reached (%%d).",
		["zh-cn"] = "已达友军上限（%%d）。",
		ru = "Достигнут лимит союзников (%%d).",
	},
	notify_bots_range_only = {
		en = "Allies can only be spawned in the Meat Grinder.",
		["zh-cn"] = "友军仅能在灵能训练场生成。",
		ru = "Союзников можно создавать только в Мясорубке.",
	},
	notify_bots_host_only = {
		en = "Only the host can spawn allies.",
		["zh-cn"] = "仅房主可生成友军。",
		ru = "Только хост может создавать союзников.",
	},
	notify_bots_unavailable = {
		en = "Allies are unavailable right now.",
		["zh-cn"] = "当前无法生成友军。",
		ru = "Союзники сейчас недоступны.",
	},
	ps_key_spawn_bot = {
		en = "Spawn an ally bot",
		["zh-cn"] = "生成一名友军机器人",
		ru = "Создать бота-союзника",
	},
	ps_key_spawn_bot_description = {
		en = "Spawn a friendly mission bot in the Meat Grinder (up to 3). Meat Grinder only.",
		["zh-cn"] = "在灵能训练场生成一名友方机器人（最多3名）。仅灵能训练场可用。",
		ru = "Создаёт дружественного бота из миссий в Мясорубке (до 3). Только Мясорубка.",
	},
	ps_key_clear_bots = {
		en = "Remove all ally bots",
		["zh-cn"] = "移除所有友军机器人",
		ru = "Удалить всех ботов-союзников",
	},
	ps_key_clear_bots_description = {
		en = "Despawn every friendly bot you have spawned. Meat Grinder only.",
		["zh-cn"] = "移除所有已生成的友方机器人。仅灵能训练场可用。",
		ru = "Удаляет всех созданных вами дружественных ботов. Только Мясорубка.",
	},

	tip_mode_1 = {
		en = "Spawn: pick enemies to spawn.",
		["zh-cn"] = "生成: 选择要生成的敌人。",
		ru = "Создание: выберите врагов для создания.",
	},
	tip_mode_2 = {
		en = "Waves: preset groups and escalating wave trials.",
		["zh-cn"] = "波次: 预制敌群与递进式波次试炼。",
		ru = "Волны: предустановленные группы и волновые испытания с нарастанием сложности.",
	},
	tip_mode_3 = {
		en = "Player: infinite toughness, health, ammo, magazine, ability, blitz, stamina, dodges, invulnerability.",
		["zh-cn"] = "玩家: 无限韧性、生命、弹药、弹匣、技能、手雷、体力、闪避、无敌。",
		ru = "Игрок: бесконечные стойкость, здоровье, боезапас, магазин, способность, гранаты, выносливость, уклонения, неуязвимость.",
	},
	tip_mode_4 = {
		en = "Indulge: click an indulgence to toggle it on/off (active ones are highlighted). Prev/Next switch archetype.",
		["zh-cn"] = "恩赐: 点击恩赐来开关（已激活的会高亮）。上/下页切换职业。",
		ru = "Индульгенции: кликните по индульгенции, чтобы включить/выключить (активные выделены). Пред./След. переключают архетип.",
	},
	tip_mode_5 = {
		en = "Extras: infinite enemy HP, player invisibility, sound muffler, respawn and other Meat Grinder utilities.",
		["zh-cn"] = "附加: 敌人无限血量、玩家隐身、音效压制、复活等训练场工具。",
		ru = "Дополнительно: бесконечное здоровье врагов, невидимость игрока, заглушение звуков, воскрешение и другие утилиты Мясорубки.",
	},
	tip_mode = {
		en = "Click: clicking an enemy spawns it now. Select: clicking adds enemies to your horde.",
		["zh-cn"] = "点击模式: 点击直接生成敌人。预选模式: 点击将敌人加入编组队列。",
		ru = "Клик: клик по врагу создаёт его сразу. Выбор: клик добавляет врагов в вашу орду.",
	},
	tip_spawn = {
		en = "Spawn the horde you built in Select mode.",
		["zh-cn"] = "将预选模式中编组的敌群统一生成。",
		ru = "Создать орду, собранную в режиме Выбор.",
	},
	tip_clear = {
		en = "Empty the current horde.",
		["zh-cn"] = "清空当前敌群编组。",
		ru = "Очистить текущую орду.",
	},
	tip_queue_keep = {
		en = "On: keep the horde after it spawns so you can spawn it again. Off: clear it once spawned.",
		["zh-cn"] = "开: 生成后保留队列可重复生成。关: 生成后清空队列。",
		ru = "Вкл: сохранять орду после создания, чтобы можно было создать снова. Выкл: очищать после создания.",
	},
	tip_spawn_close = {
		en = "On: spawn the horde when the menu closes. Off: keep it for the hold-to-place key.",
		["zh-cn"] = "开: 关闭菜单时生成敌群。关: 保留队列供长按放置使用。",
		ru = "Вкл: создавать орду при закрытии меню. Выкл: сохранять для клавиши размещения по удержанию.",
	},
	tip_count_dec = {
		en = "Fewer enemies spawned per click.",
		["zh-cn"] = "每次点击生成更少敌人。",
		ru = "Меньше врагов за клик.",
	},
	tip_count_inc = {
		en = "More enemies spawned per click.",
		["zh-cn"] = "每次点击生成更多敌人。",
		ru = "Больше врагов за клик.",
	},
	tip_spread_dec = {
		en = "Smaller scatter radius so a group spawns closer together.",
		["zh-cn"] = "缩小分散半径，敌人更集中。",
		ru = "Меньший радиус разброса, враги создаются ближе друг к другу.",
	},
	tip_spread_inc = {
		en = "Larger scatter radius so a group spreads out more.",
		["zh-cn"] = "增大分散半径，敌人更分散。",
		ru = "Больший радиус разброса, враги распределяются шире.",
	},
	tip_t_aim = {
		en = "On: spawn where you were aiming when you opened the menu. Off: spawn in front of you.",
		["zh-cn"] = "开: 生成在打开菜单时准星瞄准的位置。关: 生成在身前。",
		ru = "Вкл: создавать в точке прицела на момент открытия меню. Выкл: создавать перед вами.",
	},
	tip_g_all = {
		en = "Toggle every stat below on or off at once.",
		["zh-cn"] = "一键切换以下所有属性开关。",
		ru = "Включить/выключить все параметры ниже одним нажатием.",
	},
	tip_g_toughness = {
		en = "Keep your toughness full.",
		["zh-cn"] = "持续维持韧性满值。",
		ru = "Поддерживает стойкость полной.",
	},
	tip_g_health = {
		en = "Keep your health full.",
		["zh-cn"] = "持续维持生命值满。",
		ru = "Поддерживает здоровье полным.",
	},
	tip_g_ammo = {
		en = "Keep your ammo reserves full (uses the game's own refill).",
		["zh-cn"] = "持续填满备弹（调用游戏原生补给逻辑）。",
		ru = "Поддерживает боезапас полным (использует стандартное восполнение игры).",
	},
	tip_g_magazine = {
		en = "Keep your loaded magazine full so you never reload.",
		["zh-cn"] = "弹匣子弹永久满额，无需换弹。",
		ru = "Магазин всегда полный, перезарядка не требуется.",
	},
	tip_g_ability = {
		en = "Keep your combat ability charged and off cooldown.",
		["zh-cn"] = "职业技能持续就绪，无冷却。",
		ru = "Способность всегда заряжена и без перезарядки.",
	},
	tip_g_blitz = {
		en = "Keep your blitz charges topped up.",
		["zh-cn"] = "手雷充能永远满层。",
		ru = "Поддерживает максимальное количество гранат.",
	},
	tip_g_stamina = {
		en = "Keep your stamina full.",
		["zh-cn"] = "体力持续满值。",
		ru = "Поддерживает выносливость полной.",
	},
	tip_g_dodge = {
		en = "Reset the dodge counter.",
		["zh-cn"] = "重置闪避衰减计数。",
		ru = "Сбрасывает счётчик уклонений.",
	},
	tip_g_invuln = {
		en = "Take no damage.",
		["zh-cn"] = "免疫所有伤害。",
		ru = "Не получать урон.",
	},
	tip_g_peril_gain = {
		en = "Psyker: peril (warp charge) never builds, so you can cast freely.",
		["zh-cn"] = "灵能者专属: 危险值永不积累，可无限制施法。",
		ru = "Псайкер: опасность (заряд варпа) не накапливается, можно кастовать без ограничений.",
	},
	tip_g_peril_death = {
		en = "Psyker: never explode from perils of the warp even at max peril.",
		["zh-cn"] = "灵能者专属: 即使危险值满也不会触发自爆。",
		ru = "Псайкер: никогда не взрывается от опасностей варпа, даже на максимуме.",
	},
	tip_g_refill = {
		en = "One-shot: top up toughness, health, ammo and ability right now.",
		["zh-cn"] = "一次性: 立即补满韧性、生命、弹药和技能。",
		ru = "Одноразово: восполнить стойкость, здоровье, боезапас и способность сейчас.",
	},
	tip_m_muffler = {
		en = "Disable the Meat Grinder's sound muffler for fuller combat audio.",
		["zh-cn"] = "关闭训练场音效压制，恢复完整战斗音频。",
		ru = "Отключить приглушение звука в Мясорубке для полного боевого аудио.",
	},
	tip_m_killall = {
		en = "Remove every spawned enemy.",
		["zh-cn"] = "清除所有已生成的敌人。",
		ru = "Удалить всех созданных врагов.",
	},
	tip_m_ai = {
		en = "On: enemies you spawn wake up and hunt you. Off: inert dummies. Applies to enemies spawned after you toggle it. Use Invisible to stop them hitting you.",
		["zh-cn"] = "开: 生成的敌人会主动攻击你。关: 敌人静止不动。仅对切换后生成的敌人生效。可配合隐身使用。",
		ru = "Вкл: созданные враги просыпаются и охотятся на вас. Выкл: неподвижные манекены. Действует на врагов, созданных после переключения. Используйте невидимость, чтобы они не атаковали.",
	},
	tip_m_nodef = {
		en = "On: stop the Meat Grinder spawning its own enemies so only yours exist.",
		["zh-cn"] = "开: 停止训练场原生敌人的刷新，仅保留你手动生成的敌人。",
		ru = "Вкл: остановить появление стандартных врагов Мясорубки, останутся только ваши.",
	},
	tip_m_respawn = {
		en = "Full-heal and get back up after going down or dying.",
		["zh-cn"] = "倒地或死亡后直接复活并回满状态。",
		ru = "Полное исцеление и подъём после падения или смерти.",
	},
	tip_m_whisper = {
		en = "Silence the Meat Grinder's psychic whispers.",
		["zh-cn"] = "静音训练场的灵能低语。",
		ru = "Отключить психический шёпот в Мясорубке.",
	},
	tip_m_noprops = {
		en = "Remove the loadout chest and the pickup items on the tables for a clean arena. The empty tables themselves stay (they are part of the level).",
		["zh-cn"] = "移除装备箱与桌上拾取物，保持场地整洁。空桌子属于地图本身，无法移除。",
		ru = "Убрать сундук с экипировкой и предметы на столах для чистого поля. Пустые столы остаются (они часть уровня).",
	},
	tip_m_continuous = {
		en = "Keep the arena topped up to the size of the last group you spawned, respawning that mix as enemies die. Turn off to stop.",
		["zh-cn"] = "自动补充至上次生成数量，敌人死亡后按比例补充。关闭即停止。",
		ru = "Поддерживать количество врагов на уровне последней созданной группы, восполняя состав по мере гибели. Выключите, чтобы остановить.",
	},
	tip_m_swap = {
		en = "Swap the range lineup: replace all the default enemies with the ones missing by default (bosses, captains, vanguards and more), or press again to restore the defaults. Meat Grinder only; takes effect while inside it.",
		["zh-cn"] = "替换训练场敌群: 将默认敌人替换为遗漏的怪物（首领、队长、先锋等），再次按下恢复默认。仅训练场可用。",
		ru = "Сменить состав полигона: заменить стандартных врагов на тех, кто обычно отсутствует (боссы, капитаны, авангарды и др.), повторное нажатие восстанавливает стандартных. Только Мясорубка, действует внутри.",
	},
	tip_m_immortal = {
		en = "Every enemy in the arena (yours and the range defaults) still takes damage but never dies, so you can test sustained weapon damage. Turn off to let them die again. Meat Grinder only.",
		["zh-cn"] = "场内所有敌人承受伤害但不会死亡，适合持续输出测试。关闭后敌人正常死亡。仅训练场可用。",
		ru = "Все враги на арене (ваши и стандартные) получают урон, но не умирают, что позволяет тестировать длительный урон. Выключите, чтобы они снова умирали. Только Мясорубка.",
	},
	tip_m_invis = {
		en = "On: enemies cannot target or hit you, so you can watch them freely. Off: they can attack you again. Meat Grinder only.",
		["zh-cn"] = "开: 敌人无法锁定或攻击你，可自由观察。关: 敌人恢复攻击。仅训练场可用。",
		ru = "Вкл: враги не могут нацелиться или ударить вас, можно свободно наблюдать. Выкл: они снова могут атаковать. Только Мясорубка.",
	},
	tip_m_reset = {
		en = "Clear all spawns, stop any trial, and calm the arena back to the default state (enemies inert, AI off). Meat Grinder only.",
		["zh-cn"] = "清除所有生成的敌人、停止试炼，并将场地恢复到默认平静状态（敌人静止、AI关闭）。仅训练场可用。",
		ru = "Очистить всех созданных, остановить испытание и вернуть арену в спокойное состояние (враги неподвижны, ИИ выкл). Только Мясорубка.",
	},
	tip_wave_start = {
		en = "Restart the last trial you started.",
		["zh-cn"] = "重新开始上次的试炼。",
		ru = "Перезапустить последнее начатое испытание.",
	},
	tip_wave_stop = {
		en = "Stop the active trial.",
		["zh-cn"] = "停止当前试炼。",
		ru = "Остановить текущее испытание.",
	},
	tip_wave_next = {
		en = "Spawn the next wave now.",
		["zh-cn"] = "立即生成下一波。",
		ru = "Создать следующую волну сейчас.",
	},
	tip_wave_auto = {
		en = "Auto: waves advance automatically (on timer or when cleared). Off: use Next Wave.",
		["zh-cn"] = "自动: 波次定时或清场后自动推进。关: 需手动点击下一波。",
		ru = "Авто: волны продвигаются автоматически (по таймеру или после зачистки). Выкл: используйте Следующую волну.",
	},

	tip_wave_timer_adv = {
		en = "advances on a timer",
		["zh-cn"] = "定时推进",
		ru = "продвижение по таймеру",
	},
	tip_wave_clear_adv = {
		en = "advances when cleared",
		["zh-cn"] = "清场后推进",
		ru = "продвижение после зачистки",
	},
	tip_wave_endless = {
		en = ", endless",
		["zh-cn"] = "，无尽模式",
		ru = ", бесконечная",
	},
	tip_wave_trial_fmt = {
		en = "%%d-wave trial, %%s%%s. First wave: %%s",
		["zh-cn"] = "%%d波试炼，%%s%%s。首波：%%s",
		ru = "%%d-волновое испытание, %%s%%s. Первая волна: %%s",
	},

	ps_none = {
		en = "(none)",
		["zh-cn"] = "（无）",
		ru = "(нет)",
	},

	ps_open_menu = {
		en = "Open spawn menu",
		["zh-cn"] = "打开生成菜单",
		ru = "Открыть меню создания",
	},
	ps_open_menu_description = {
		en = "Opens the click-to-spawn menu. Press again to close. Psykhanium only.",
		["zh-cn"] = "打开敌人一键生成菜单，再次按下关闭。仅在灵能训练场生效。",
		ru = "Открывает меню создания по клику. Повторное нажатие закрывает. Только Псайканиум.",
	},
	ps_spawn_count = {
		en = "Spawn count",
		["zh-cn"] = "单次生成数量",
		ru = "Количество создаваемых",
	},
	ps_spawn_count_description = {
		en = "How many enemies each spawn action creates.",
		["zh-cn"] = "每次生成操作会刷新出的敌人数目。",
		ru = "Сколько врагов создаётся за одно действие.",
	},
	ps_spread = {
		en = "Spawn spread",
		["zh-cn"] = "生成分散范围",
		ru = "Разброс при создании",
	},
	ps_spread_description = {
		en = "Radius the group is scattered over so they don't stack on one point.",
		["zh-cn"] = "敌人生成后的分散半径，避免全部堆叠在同一点。",
		ru = "Радиус разброса группы, чтобы враги не появлялись в одной точке.",
	},
	ps_menu_spawn_at_aim = {
		en = "Menu spawns where you aimed",
		["zh-cn"] = "菜单生成点为瞄准位置",
		ru = "Создание по прицелу меню",
	},
	ps_menu_spawn_at_aim_description = {
		en = "On: the menu spawns at the spot you were looking at when you opened it. Off: spawns in front of you.",
		["zh-cn"] = "开启：打开菜单时，敌人生成在你的准星落点；关闭：敌人生成在你身前。",
		ru = "Вкл: меню создаёт врагов в точке, куда вы смотрели при открытии. Выкл: создаёт перед вами.",
	},
	ps_no_default_enemies = {
		en = "No default Meat Grinder enemies",
		["zh-cn"] = "关闭训练场原生敌人",
		ru = "Отключить стандартных врагов Мясорубки",
	},
	ps_no_default_enemies_description = {
		en = "On: stops the Meat Grinder spawning and respawning its own enemies, and clears any currently present, so only the ones you spawn exist.",
		["zh-cn"] = "开启后，训练场停止自动刷新原生敌人并清空场上现有原生敌人，场内只会保留你手动生成的怪物。",
		ru = "Вкл: останавливает появление и возрождение стандартных врагов, удаляет уже существующих, остаются только созданные вами.",
	},
	ps_no_props = {
		en = "Hide Meat Grinder props",
		["zh-cn"] = "隐藏训练场杂物道具",
		ru = "Скрыть предметы в Мясорубке",
	},
	ps_no_props_description = {
		en = "On: removes the loadout chest and the pickup items on the tables for a clean arena. The empty tables themselves are part of the level and remain.",
		["zh-cn"] = "开启后移除装备箱与桌上拾取道具，场地更整洁；空桌子属于地图原生模型，无法移除。",
		ru = "Вкл: убирает сундук с экипировкой и предметы на столах для чистоты. Пустые столы остаются (они часть уровня).",
	},
	ps_swap_lineup = {
		en = "Swap lineup for missing enemies",
		["zh-cn"] = "替换默认敌群为遗漏怪物",
		ru = "Сменить состав на пропущенных врагов",
	},
	ps_swap_lineup_description = {
		en = "On: replaces the range default lineup with the enemies it leaves out (bosses, captains, vanguards and more). Off: the normal default lineup. Toggle from the Misc tab too.",
		["zh-cn"] = "开启：将训练场默认刷新敌群替换为原本不会刷新的怪物（首领、队长、先锋等）；关闭：恢复原生默认敌群。也可在杂项面板切换。",
		ru = "Вкл: заменяет стандартный состав полигона на врагов, которых он обычно пропускает (боссы, капитаны, авангарды и др.). Выкл: обычный состав. Также переключается в Дополнительно.",
	},
	ps_key_swap_lineup = {
		en = "Swap lineup (default <-> missing)",
		["zh-cn"] = "切换敌群类型（默认/遗漏怪物）",
		ru = "Сменить состав (стандартный <-> пропущенные)",
	},
	ps_key_swap_lineup_description = {
		en = "Toggle the range lineup between the default enemies and the missing ones. Meat Grinder only.",
		["zh-cn"] = "切换训练场刷新敌群，在原生默认怪物与遗漏特殊怪物之间切换，仅灵能训练场可用。",
		ru = "Переключает состав полигона между стандартными врагами и пропущенными. Только Мясорубка.",
	},
	ps_prepare_on_entry = {
		en = "Calm arena on entry",
		["zh-cn"] = "进入时保持平静",
		ru = "Спокойная арена при входе",
	},
	ps_prepare_on_entry_description = {
		en = "On: entering the Meat Grinder starts calm - spawns cleared, trials stopped, AI off - so you can set up your build and mod settings before any fight. Off: keep your previous state on entry.",
		["zh-cn"] = "开启：进入灵能训练场时保持平静——清空生成的敌人、停止试炼、关闭AI，方便你先调整配装和模组设置再开战。关闭：进入时保留上次的状态。",
		ru = "Вкл: при входе в Мясорубку всё спокойно — удалены создания, остановлены испытания, ИИ выкл, чтобы вы могли настроить билд и моды перед боем. Выкл: сохраняется предыдущее состояние.",
	},
	ps_invisible_default = {
		en = "Invisible on entry",
		["zh-cn"] = "进入时隐身",
		ru = "Невидимость при входе",
	},
	ps_invisible_default_description = {
		en = "On: you start invisible when you enter the Meat Grinder, so enemies cannot target or hit you until you turn Invisible off. Off: you start visible.",
		["zh-cn"] = "开启：进入灵能训练场时你处于隐身状态，敌人无法锁定或攻击你，直到你关闭隐身。关闭：进入时可见。",
		ru = "Вкл: вы невидимы при входе в Мясорубку, враги не могут нацелиться или ударить, пока вы не выключите невидимость. Выкл: вы видимы.",
	},
	ps_key_reset = {
		en = "Reset arena to default",
		["zh-cn"] = "重置场地为默认",
		ru = "Сбросить арену по умолчанию",
	},
	ps_key_reset_description = {
		en = "Clear all spawns, stop any trial, and calm the arena back to the default state. Meat Grinder only.",
		["zh-cn"] = "清除所有生成的敌人、停止试炼并使场地恢复平静默认状态。仅灵能训练场可用。",
		ru = "Удалить всех созданных, остановить испытание и вернуть арену в спокойное состояние. Только Мясорубка.",
	},
	ps_key_enemy_ai = {
		en = "Toggle enemy AI",
		["zh-cn"] = "开关敌人AI",
		ru = "Переключить ИИ врагов",
	},
	ps_key_enemy_ai_description = {
		en = "Toggle whether enemies you spawn hunt you or stand inert as dummies. Applies to enemies spawned after you toggle it. Meat Grinder only.",
		["zh-cn"] = "切换生成的敌人是否会主动追击玩家，关闭后敌人仅作为静止靶标。切换后仅对后续生成的敌人生效，仅限灵能训练场。",
		ru = "Переключает, будут ли созданные враги охотиться на вас или стоять неподвижно как манекены. Действует на созданных после переключения. Только Мясорубка.",
	},
	ps_key_invisible = {
		en = "Toggle player invisibility",
		["zh-cn"] = "开关玩家隐身",
		ru = "Переключить невидимость игрока",
	},
	ps_key_invisible_description = {
		en = "On: enemies cannot target or hit you. Off: they can attack you again. Meat Grinder only.",
		["zh-cn"] = "开启后敌人无法锁定、攻击你；关闭恢复正常仇恨判定，仅灵能训练场生效。",
		ru = "Вкл: враги не могут нацелиться или ударить. Выкл: снова могут атаковать. Только Мясорубка.",
	},
	ps_immortal_enemies = {
		en = "Infinite enemy HP (DPS dummies)",
		["zh-cn"] = "敌人无限血量（输出测试靶）",
		ru = "Бесконечное здоровье врагов (манекены для битья)",
	},
	ps_immortal_enemies_description = {
		en = "On: every enemy in the arena (yours and the range defaults) still takes damage but cannot die, so you can test sustained weapon damage. Off: enemies die normally. Toggle from the Extras tab too. Meat Grinder only.",
		["zh-cn"] = "开启后场内所有敌人（原生+手动生成）承受伤害但不会死亡，适合持续输出测试；关闭敌人正常死亡。也可在附加面板切换，仅训练场可用。",
		ru = "Вкл: все враги на арене (ваши и стандартные) получают урон, но не умирают, для тестирования длительного урона. Выкл: умирают обычно. Переключается также в Дополнительно. Только Мясорубка.",
	},
	ps_key_immortal_enemies = {
		en = "Infinite enemy HP (DPS dummies)",
		["zh-cn"] = "敌人无限血量（输出测试靶）",
		ru = "Бесконечное здоровье врагов (манекены для битья)",
	},
	ps_key_immortal_enemies_description = {
		en = "Toggle whether spawned enemies can die, for weapon damage testing. Meat Grinder only.",
		["zh-cn"] = "切换生成敌人是否拥有无限血量，用于武器伤害测试，仅灵能训练场生效。",
		ru = "Переключает, могут ли созданные враги умирать, для тестирования урона. Только Мясорубка.",
	},
	ps_select_mode = {
		en = "Select mode (build a horde then spawn)",
		["zh-cn"] = "预选模式（编组后统一生成）",
		ru = "Режим выбора (собрать орду, затем создать)",
	},
	ps_select_mode_description = {
		en = "On: clicking enemies in the menu adds them to your horde; they spawn when you press Spawn or close the menu. Off: clicking spawns immediately.",
		["zh-cn"] = "开启：点击敌人加入预生成队列，点击生成或关闭菜单时统一刷新；关闭：点击敌人直接当场生成。",
		ru = "Вкл: клик по врагу добавляет его в орду; создание происходит при нажатии Создать или закрытии меню. Выкл: клик создаёт сразу.",
	},
	ps_spawn_on_close = {
		en = "Spawn horde when menu closes",
		["zh-cn"] = "关闭菜单时生成预编组敌群",
		ru = "Создавать орду при закрытии меню",
	},
	ps_spawn_on_close_description = {
		en = "On: closing the menu spawns whatever you built in Select mode. Off: closing keeps the horde so you can place it later with the hold-to-place key.",
		["zh-cn"] = "开启：关闭菜单直接生成预选敌群；关闭：关闭菜单保留队列，可使用长按放置键后续生成。",
		ru = "Вкл: при закрытии меню создаётся собранная в режиме Выбор орда. Выкл: орда сохраняется для последующего размещения по удержанию клавиши.",
	},
	ps_keep_queue = {
		en = "Keep horde after spawning",
		["zh-cn"] = "生成后保留敌群队列",
		ru = "Сохранять орду после создания",
	},
	ps_keep_queue_description = {
		en = "On: your horde is kept after it spawns so you can spawn the same group again. Off: the horde is cleared once it spawns.",
		["zh-cn"] = "开启：敌群生成后保留队列，可重复生成同一批怪物；关闭：生成完成后清空预选队列。",
		ru = "Вкл: орда сохраняется после создания, можно создать ту же группу снова. Выкл: орда очищается после создания.",
	},
	ps_key_god_mode = {
		en = "Toggle infinite everything",
		["zh-cn"] = "全能无敌模式开关",
		ru = "Включить всё бесконечное",
	},
	ps_key_god_mode_description = {
		en = "Toggle: keeps toughness, health, ammo, ability and grenades topped up and makes you unkillable. Best-effort in the training range.",
		["zh-cn"] = "一键切换全能无敌，自动维持韧性、血量、弹药、技能、手雷满层，角色不会死亡，训练场环境下尽力生效。",
		ru = "Переключает: поддерживает стойкость, здоровье, боезапас, способность и гранаты, делает вас неуязвимым. Работает в пределах тренировочного полигона.",
	},
	ps_key_god_toughness = {
		en = "Toggle infinite toughness",
		["zh-cn"] = "无限韧性开关",
		ru = "Переключить бесконечную стойкость",
	},
	ps_key_god_toughness_description = {
		en = "Toggle keeping your toughness full.",
		["zh-cn"] = "持续将你的韧性值维持满值。",
		ru = "Включает поддержание стойкости полной.",
	},
	ps_key_god_health = {
		en = "Toggle infinite health",
		["zh-cn"] = "无限生命值开关",
		ru = "Переключить бесконечное здоровье",
	},
	ps_key_god_health_description = {
		en = "Toggle keeping your health full.",
		["zh-cn"] = "持续将你的生命值维持满值。",
		ru = "Включает поддержание здоровья полным.",
	},
	ps_key_god_ammo = {
		en = "Toggle infinite ammo",
		["zh-cn"] = "无限备弹开关",
		ru = "Переключить бесконечный боезапас",
	},
	ps_key_god_ammo_description = {
		en = "Toggle keeping your ammo reserves full (uses the game's own ammo refill).",
		["zh-cn"] = "持续填满背包备弹，调用游戏原生补给逻辑。",
		ru = "Включает поддержание боезапаса (использует стандартное восполнение игры).",
	},
	ps_key_god_magazine = {
		en = "Toggle infinite magazine",
		["zh-cn"] = "弹匣无需换弹开关",
		ru = "Переключить бесконечный магазин",
	},
	ps_key_god_magazine_description = {
		en = "Toggle keeping your loaded magazine full so you never need to reload.",
		["zh-cn"] = "当前弹匣子弹永久满额，无需换弹。",
		ru = "Включает поддержание магазина полным, перезарядка не требуется.",
	},
	ps_key_god_ability = {
		en = "Toggle infinite ability",
		["zh-cn"] = "无限职业技能开关",
		ru = "Переключить бесконечную способность",
	},
	ps_key_god_ability_description = {
		en = "Toggle keeping your combat ability ready.",
		["zh-cn"] = "职业主动技能持续就绪，无冷却。",
		ru = "Включает поддержание способности готовой к использованию.",
	},
	ps_key_god_blitz = {
		en = "Toggle infinite blitz",
		["zh-cn"] = "无限闪击手雷开关",
		ru = "Переключить бесконечные гранаты",
	},
	ps_key_god_blitz_description = {
		en = "Toggle keeping your blitz (grenade) charges topped up.",
		["zh-cn"] = "闪击手雷充能层数永久拉满。",
		ru = "Включает поддержание максимального количества гранат.",
	},
	ps_key_god_stamina = {
		en = "Toggle infinite stamina",
		["zh-cn"] = "无限体力开关",
		ru = "Переключить бесконечную выносливость",
	},
	ps_key_god_stamina_description = {
		en = "Toggle keeping your stamina full.",
		["zh-cn"] = "冲刺、闪避体力持续满值。",
		ru = "Включает поддержание выносливости полной.",
	},
	ps_key_god_dodge = {
		en = "Toggle infinite dodges",
		["zh-cn"] = "无衰减连续闪避开关",
		ru = "Переключить бесконечные уклонения",
	},
	ps_key_god_dodge_description = {
		en = "Toggle resetting the consecutive-dodge counter so dodges never lose effectiveness.",
		["zh-cn"] = "重置连续闪避衰减计数，连续闪避不会降低闪避效果。",
		ru = "Включает сброс счётчика уклонений, чтобы уклонения никогда не теряли эффективность.",
	},
	ps_key_no_peril_gain = {
		en = "Toggle no peril gain",
		["zh-cn"] = "灵能不积攒危险值开关",
		ru = "Переключить отсутствие накопления опасности",
	},
	ps_key_no_peril_gain_description = {
		en = "Psyker: toggle keeping peril (warp charge) pinned at zero so you can cast freely.",
		["zh-cn"] = "灵能者专属：危险值永久锁定0，可无限制释放灵能技能。",
		ru = "Псайкер: опасность (заряд варпа) всегда на нуле, можно колдовать без ограничений.",
	},
	ps_key_no_peril_death = {
		en = "Toggle no peril death",
		["zh-cn"] = "灵能过载不会自爆开关",
		ru = "Переключить отсутствие смерти от опасности",
	},
	ps_key_no_peril_death_description = {
		en = "Psyker: toggle never exploding from perils of the warp, even at maximum peril.",
		["zh-cn"] = "灵能者专属：即便危险值拉满，也不会触发灵能自爆。",
		ru = "Псайкер: никогда не взрывается от опасностей варпа, даже на максимуме.",
	},
	ps_key_respawn = {
		en = "Respawn / revive",
		["zh-cn"] = "复活并回满全部状态",
		ru = "Воскреснуть / возродиться",
	},
	ps_key_respawn_description = {
		en = "Full-heal and get you back up after going down or dying in the Meat Grinder.",
		["zh-cn"] = "训练场倒地/死亡后，直接复活并回满全部状态。",
		ru = "Полное исцеление и подъём после падения или смерти в Мясорубке.",
	},
	ps_key_aim_spawn = {
		en = "Hold to place horde",
		["zh-cn"] = "长按放置预选敌群",
		ru = "Удерживать для размещения орды",
	},
	ps_key_aim_spawn_description = {
		en = "Hold this key, aim, and release to drop the horde you built in the menu at the spot under your crosshair. Set 'Select mode' on and 'Spawn horde when menu closes' off to build a horde first.",
		["zh-cn"] = "按住按键瞄准目标点松开，即可将菜单预选的敌群生成在准星位置。需先开启预选模式、关闭「关闭菜单生成敌群」。",
		ru = "Удерживайте клавишу, прицельтесь и отпустите, чтобы разместить собранную в меню орду в точке прицела. Включите 'Режим выбора' и отключите 'Создавать при закрытии меню', чтобы сначала собрать орду.",
	},
	ps_key_kill_all = {
		en = "Kill all spawns",
		["zh-cn"] = "清除所有生成敌人",
		ru = "Убить всех созданных",
	},
	ps_key_kill_all_description = {
		en = "Removes every spawned enemy.",
		["zh-cn"] = "清空场上所有手动生成的怪物。",
		ru = "Удаляет всех созданных врагов.",
	},
	ps_key_refill = {
		en = "Refill toughness/health",
		["zh-cn"] = "回满韧性与血量",
		ru = "Восполнить стойкость/здоровье",
	},
	ps_key_refill_description = {
		en = "Tops your operative back up.",
		["zh-cn"] = "瞬间将角色韧性、生命值恢复至满值。",
		ru = "Восстанавливает стойкость и здоровье оперативника до максимума.",
	},
	ps_key_invuln = {
		en = "Toggle invulnerable",
		["zh-cn"] = "角色无敌开关",
		ru = "Переключить неуязвимость",
	},
	ps_key_invuln_description = {
		en = "Makes your operative immune to damage. Toggle.",
		["zh-cn"] = "切换角色是否免疫所有伤害。",
		ru = "Делает оперативника неуязвимым к урону. Переключается.",
	},
	ps_key_repeat = {
		en = "Repeat last spawn",
		["zh-cn"] = "重复上一次生成",
		ru = "Повторить последнее создание",
	},
	ps_key_repeat_description = {
		en = "Spawns the last enemy you spawned again, at your crosshair.",
		["zh-cn"] = "将上一次生成的敌人直接刷新在当前准星位置。",
		ru = "Создаёт последнего созданного врага снова в точке прицела.",
	},
	ps_quick_slots = {
		en = "Quick slots",
		["zh-cn"] = "快捷生成栏",
		ru = "Быстрые слоты",
	},
	ps_slot_1 = {
		en = "Quick slot 1 enemy",
		["zh-cn"] = "快捷栏1怪物",
		ru = "Враг для быстрого слота 1",
	},
	ps_slot_1_description = {
		en = "Enemy spawned by the slot 1 hotkey.",
		["zh-cn"] = "按下快捷栏1热键时生成的怪物。",
		ru = "Враг, создаваемый по горячей клавише слота 1.",
	},
	ps_key_slot_1 = {
		en = "Spawn slot 1",
		["zh-cn"] = "生成快捷栏1怪物",
		ru = "Создать из слота 1",
	},
	ps_slot_2 = {
		en = "Quick slot 2 enemy",
		["zh-cn"] = "快捷栏2怪物",
		ru = "Враг для быстрого слота 2",
	},
	ps_slot_2_description = {
		en = "Enemy spawned by the slot 2 hotkey.",
		["zh-cn"] = "按下快捷栏2热键时生成的怪物。",
		ru = "Враг, создаваемый по горячей клавише слота 2.",
	},
	ps_key_slot_2 = {
		en = "Spawn slot 2",
		["zh-cn"] = "生成快捷栏2怪物",
		ru = "Создать из слота 2",
	},
	ps_slot_3 = {
		en = "Quick slot 3 enemy",
		["zh-cn"] = "快捷栏3怪物",
		ru = "Враг для быстрого слота 3",
	},
	ps_slot_3_description = {
		en = "Enemy spawned by the slot 3 hotkey.",
		["zh-cn"] = "按下快捷栏3热键时生成的怪物。",
		ru = "Враг, создаваемый по горячей клавише слота 3.",
	},
	ps_key_slot_3 = {
		en = "Spawn slot 3",
		["zh-cn"] = "生成快捷栏3怪物",
		ru = "Создать из слота 3",
	},
	ps_slot_4 = {
		en = "Quick slot 4 enemy",
		["zh-cn"] = "快捷栏4怪物",
		ru = "Враг для быстрого слота 4",
	},
	ps_slot_4_description = {
		en = "Enemy spawned by the slot 4 hotkey.",
		["zh-cn"] = "按下快捷栏4热键时生成的怪物。",
		ru = "Враг, создаваемый по горячей клавише слота 4.",
	},
	ps_key_slot_4 = {
		en = "Spawn slot 4",
		["zh-cn"] = "生成快捷栏4怪物",
		ru = "Создать из слота 4",
	},
}
