require("scripts/ui/views/base_view")

local definition_path = "ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_view_definitions"

local PsykhaniumSpawnerView = class("PsykhaniumSpawnerView", "BaseView")

local PER_PAGE   = 20
local QUEUE_ROWS = 12

local SLOT_W      = 224
local TEXT_INSET  = 44
local TEXT_W_ICON = SLOT_W - TEXT_INSET - 6
local TEXT_W_FULL = SLOT_W - 8

local MODES = { "spawn", "waves", "player", "indulg", "misc" }

local MODE_LABEL_KEY = {
    spawn  = "mode_spawn",
    waves  = "mode_waves",
    player = "mode_player",
    indulg = "mode_indulge",
    misc   = "mode_misc",
}

local GROUPS = {
    spawn = {
        "tab_1", "tab_2", "tab_3", "tab_4", "tab_5", "tab_6",
        "mode", "count_dec", "count_val", "count_inc", "spread_dec", "spread_val", "spread_inc",
        "t_aim", "spawn", "clear", "queue_keep", "spawn_close",
    },
    player = {
        "g_all", "g_toughness", "g_health", "g_ammo", "g_magazine", "g_ability", "g_blitz",
        "g_stamina", "g_dodge", "g_invuln", "g_refill", "g_peril_gain", "g_peril_death",
    },
    waves = {
        "preset_1", "preset_2", "preset_3", "preset_4", "preset_5", "preset_6",
        "trial_1", "trial_2", "trial_3", "trial_4",
        "wave_start", "wave_stop", "wave_next", "wave_auto", "wave_label",
    },
    misc = { "m_muffler", "m_killall", "m_ai", "m_nodef", "m_respawn", "m_whisper", "m_noprops", "m_continuous", "m_swap", "m_immortal", "m_invis", "m_reset", "m_nostagger" },
    indulg = {},
}

local GOD_BTN = {
    g_all = "all", g_toughness = "toughness", g_health = "health", g_ammo = "ammo", g_magazine = "magazine",
    g_ability = "ability", g_blitz = "blitz", g_stamina = "stamina", g_dodge = "dodge", g_invuln = "invuln",
    g_peril_gain = "no_peril_gain", g_peril_death = "no_peril_death",
}

local GOD_LABEL_KEY = {
    g_all = "god_label_all", g_toughness = "god_label_toughness", g_health = "god_label_health",
    g_ammo = "god_label_ammo", g_magazine = "god_label_magazine", g_ability = "god_label_ability",
    g_blitz = "god_label_blitz", g_stamina = "god_label_stamina", g_dodge = "god_label_dodge",
    g_invuln = "god_label_invuln", g_peril_gain = "god_label_no_peril_gain", g_peril_death = "god_label_no_peril_death",
}

local TOOLTIPS_KEY = {
    mode_1 = "tip_mode_1", mode_2 = "tip_mode_2", mode_3 = "tip_mode_3", mode_4 = "tip_mode_4", mode_5 = "tip_mode_5",
    tab_6 = "tip_tab_allies",
    mode       = "tip_mode",       spawn      = "tip_spawn",      clear      = "tip_clear",
    queue_keep = "tip_queue_keep", spawn_close = "tip_spawn_close",
    count_dec  = "tip_count_dec",  count_inc  = "tip_count_inc",
    spread_dec = "tip_spread_dec", spread_inc = "tip_spread_inc",
    t_aim      = "tip_t_aim",
    g_all       = "tip_g_all",       g_toughness = "tip_g_toughness", g_health    = "tip_g_health",
    g_ammo      = "tip_g_ammo",      g_magazine  = "tip_g_magazine",  g_ability   = "tip_g_ability",
    g_blitz     = "tip_g_blitz",     g_stamina   = "tip_g_stamina",   g_dodge     = "tip_g_dodge",
    g_invuln    = "tip_g_invuln",    g_peril_gain  = "tip_g_peril_gain", g_peril_death = "tip_g_peril_death",
    g_refill    = "tip_g_refill",
    m_muffler  = "tip_m_muffler",  m_killall  = "tip_m_killall",  m_ai       = "tip_m_ai",
    m_nodef    = "tip_m_nodef",    m_respawn  = "tip_m_respawn",  m_whisper  = "tip_m_whisper",
    m_noprops  = "tip_m_noprops",  m_continuous = "tip_m_continuous",
    m_swap = "tip_m_swap",         m_immortal = "tip_m_immortal", m_invis = "tip_m_invis",
    m_reset = "tip_m_reset",       m_nostagger = "tip_m_nostagger",
    wave_start = "tip_wave_start", wave_stop  = "tip_wave_stop",  wave_next = "tip_wave_next",
    wave_auto  = "tip_wave_auto",
}

local BTN_KEYBIND = {
    g_all = "ps_key_god_mode", g_toughness = "ps_key_god_toughness", g_health = "ps_key_god_health",
    g_ammo = "ps_key_god_ammo", g_magazine = "ps_key_god_magazine", g_ability = "ps_key_god_ability",
    g_blitz = "ps_key_god_blitz", g_stamina = "ps_key_god_stamina", g_dodge = "ps_key_god_dodge",
    g_peril_gain = "ps_key_no_peril_gain", g_peril_death = "ps_key_no_peril_death",
    g_invuln = "ps_key_invuln", g_refill = "ps_key_refill",
    m_killall = "ps_key_kill_all", m_respawn = "ps_key_respawn", m_reset = "ps_key_reset",
    m_nostagger = "ps_key_no_stagger",
}

PsykhaniumSpawnerView.init = function (self, settings, context)
    local definitions = require(definition_path)
    PsykhaniumSpawnerView.super.init(self, definitions, settings, context)

    self._spawner = (context and context.spawner_mod) or get_mod("ImprovedMeatGrinder")

    local last = self._spawner and (self._spawner._last_mode or self._spawner:get("ps_last_mode"))
    self._mode = last or "spawn"

    local order = self._spawner and self._spawner.breeds_data and self._spawner.breeds_data.category_order or {}
    local last_cat = self._spawner and (self._spawner._last_category or self._spawner:get("ps_last_category"))
    local valid_cat = (last_cat == "allies")
    if not valid_cat then
        for _, c in ipairs(order) do if c == last_cat then valid_cat = true break end end
    end
    self._category = valid_cat and last_cat or "regular"
    self._page = 1
    self._indulg_family = (self._spawner and (self._spawner._indulg_family or self._spawner:get("ps_indulg_family"))) or 1
    self._slot_breed = {}
    self._slot_indulg = {}
    self._slot_bot = {}
    self._last_trial = nil
    self._stats_breed = false
    self._pass_input = false
    self._pass_draw = true
end

local function V(self, key)
    local m = self._spawner
    return m and m:localize(key) or key
end
local function Vf(self, key, ...)
    local m = self._spawner
    local fmt = m and m:localize(key) or key
    return string.format(fmt, ...)
end

local function onoff(self, v)
    return V(self, v and "state_on" or "state_off")
end

PsykhaniumSpawnerView.on_enter = function (self)
    PsykhaniumSpawnerView.super.on_enter(self)
    self._allow_close_hotkey = true

    local mod = self._spawner
    if mod then mod._view = self end
    if mod and (not mod.lists or not mod.lists[self._category]) then
        pcall(mod.build_breed_lists)
    end

    self:_set_static_labels()
    self:_wire_callbacks()
    self:_refresh()
    self._stats_breed = nil
    self:_set_stats(nil)
end

function PsykhaniumSpawnerView:_wb()
    return self._widgets_by_name
end

local function set_btn(w, name, text)
    local b = w[name]
    if b then b.content.original_text = text end
end

local function set_txt(w, name, text)
    local b = w[name]
    if b then b.content.text = text end
end

PsykhaniumSpawnerView._set_static_labels = function (self)
    local w = self:_wb()
    local mod = self._spawner

    set_txt(w, "title", V(self, "ui_title"))

    for i = 1, 5 do
        set_btn(w, "mode_" .. i, V(self, MODE_LABEL_KEY[MODES[i]]))
    end
    set_btn(w, "act_close", V(self, "ui_close"))

    local order = mod and mod.breeds_data and mod.breeds_data.category_order or {}
    local labels = mod and mod.breeds_data and mod.breeds_data.category_label or {}
    for i = 1, 5 do
        local tab = w["tab_" .. i]
        if tab then
            local cat = order[i]
            if cat then
                tab.content.original_text = labels[cat] or cat
                tab.content.category = cat
            else
                tab.content.original_text = ""
            end
        end
    end
    local t6 = w["tab_6"]
    if t6 then
        t6.content.original_text = V(self, "cat_allies")
        t6.content.category = "allies"
    end
    set_btn(w, "count_dec", "-")
    set_btn(w, "count_inc", "+")
    set_btn(w, "spread_dec", "-")
    set_btn(w, "spread_inc", "+")
    set_btn(w, "page_prev", V(self, "ui_page_prev"))
    set_btn(w, "page_next", V(self, "ui_page_next"))
    set_btn(w, "clear", V(self, "ui_clear"))

    set_btn(w, "g_refill", V(self, "ui_refill_now"))

    local waves = mod and mod.waves or { presets = {}, trials = {} }
    for i = 1, 6 do
        local p = waves.presets[i]
        set_btn(w, "preset_" .. i, p and p.name or "")
        if w["preset_" .. i] then w["preset_" .. i].content.hotspot.disabled = (p == nil) end
    end
    for i = 1, 4 do
        local t = waves.trials[i]
        set_btn(w, "trial_" .. i, t and t.name or "")
        if w["trial_" .. i] then w["trial_" .. i].content.hotspot.disabled = (t == nil) end
    end
    set_btn(w, "wave_start", V(self, "ui_restart"))
    set_btn(w, "wave_stop",  V(self, "ui_stop"))
    set_btn(w, "wave_next",  V(self, "ui_next_wave"))

    set_btn(w, "m_killall", V(self, "ui_kill_all"))
    set_btn(w, "m_respawn", V(self, "ui_respawn"))
    set_btn(w, "m_reset", V(self, "ui_reset"))

    set_txt(w, "queue_title", Vf(self, "ui_horde_title_fmt", 0))
    set_txt(w, "queue_hint", V(self, "ui_queue_hint"))

    set_txt(w, "stats_title", V(self, "ui_enemy_info"))

    local ac = (mod and mod.armor_color) or {}
    local arm_names = (mod and mod.armor_name) or {}
    local legend = {
        { "unarmored",   arm_names.unarmored   or "Unarmoured" },
        { "infested",    arm_names.infested    or "Infested" },
        { "flak",        arm_names.flak        or "Flak" },
        { "carapace",    arm_names.carapace    or "Carapace" },
        { "maniac",      arm_names.maniac      or "Maniac" },
        { "unyielding",  arm_names.unyielding  or "Unyielding" },
        { "void_shield", arm_names.void_shield or "Void Shield" },
    }
    for i = 1, 8 do
        local lw = w["legend_" .. i]
        if lw then
            local e = legend[i]
            if e then
                lw.content.text = e[2]
                local col = ac[e[1]] or { 200, 200, 200 }
                local st = lw.style and lw.style.text
                if st and st.text_color then
                    st.text_color[1] = 255; st.text_color[2] = col[1]; st.text_color[3] = col[2]; st.text_color[4] = col[3]
                end
            else
                lw.content.text = ""
            end
        end
    end
end

PsykhaniumSpawnerView._wire_callbacks = function (self)
    local w = self:_wb()

    for i = 1, 5 do
        local b = w["mode_" .. i]
        if b then b.content.hotspot.pressed_callback = callback(self, "cb_mode", MODES[i]) end
    end
    if w.act_close then w.act_close.content.hotspot.pressed_callback = callback(self, "cb_action", "close") end

    for i = 1, 6 do
        local tab = w["tab_" .. i]
        if tab then tab.content.hotspot.pressed_callback = callback(self, "cb_tab", i) end
    end
    for i = 1, PER_PAGE do
        local slot = w["slot_" .. i]
        if slot then slot.content.hotspot.pressed_callback = callback(self, "cb_slot", i) end
    end
    if w.count_dec then w.count_dec.content.hotspot.pressed_callback = callback(self, "cb_count_adj", -1) end
    if w.count_inc then w.count_inc.content.hotspot.pressed_callback = callback(self, "cb_count_adj", 1) end
    if w.spread_dec then w.spread_dec.content.hotspot.pressed_callback = callback(self, "cb_spread", -1) end
    if w.spread_inc then w.spread_inc.content.hotspot.pressed_callback = callback(self, "cb_spread", 1) end
    if w.page_prev then w.page_prev.content.hotspot.pressed_callback = callback(self, "cb_page", -1) end
    if w.page_next then w.page_next.content.hotspot.pressed_callback = callback(self, "cb_page", 1) end
    if w.mode  then w.mode.content.hotspot.pressed_callback  = callback(self, "cb_toggle", "ps_select_mode") end
    if w.spawn then w.spawn.content.hotspot.pressed_callback = callback(self, "cb_spawn_queue") end
    if w.clear then w.clear.content.hotspot.pressed_callback = callback(self, "cb_clear") end
    if w.queue_keep then w.queue_keep.content.hotspot.pressed_callback = callback(self, "cb_toggle", "ps_keep_queue") end
    if w.spawn_close then w.spawn_close.content.hotspot.pressed_callback = callback(self, "cb_toggle", "ps_spawn_on_close") end
    if w.t_aim then w.t_aim.content.hotspot.pressed_callback = callback(self, "cb_toggle", "ps_menu_spawn_at_aim") end

    for name, key in pairs(GOD_BTN) do
        if w[name] then w[name].content.hotspot.pressed_callback = callback(self, "cb_god", key) end
    end
    if w.g_refill then w.g_refill.content.hotspot.pressed_callback = callback(self, "cb_action", "refill") end

    for i = 1, 6 do
        local b = w["preset_" .. i]
        if b then b.content.hotspot.pressed_callback = callback(self, "cb_preset", i) end
    end
    for i = 1, 4 do
        local b = w["trial_" .. i]
        if b then b.content.hotspot.pressed_callback = callback(self, "cb_trial", i) end
    end
    if w.wave_start then w.wave_start.content.hotspot.pressed_callback = callback(self, "cb_wave", "restart") end
    if w.wave_stop  then w.wave_stop.content.hotspot.pressed_callback  = callback(self, "cb_wave", "stop") end
    if w.wave_next  then w.wave_next.content.hotspot.pressed_callback  = callback(self, "cb_wave", "next") end
    if w.wave_auto  then w.wave_auto.content.hotspot.pressed_callback  = callback(self, "cb_wave", "auto") end

    if w.m_muffler then w.m_muffler.content.hotspot.pressed_callback = callback(self, "cb_misc", "muffler") end
    if w.m_killall then w.m_killall.content.hotspot.pressed_callback = callback(self, "cb_misc", "killall") end
    if w.m_ai      then w.m_ai.content.hotspot.pressed_callback      = callback(self, "cb_toggle", "ps_enemy_ai") end
    if w.m_nodef   then w.m_nodef.content.hotspot.pressed_callback   = callback(self, "cb_toggle", "ps_no_default_enemies") end
    if w.m_respawn then w.m_respawn.content.hotspot.pressed_callback = callback(self, "cb_misc", "respawn") end
    if w.m_whisper then w.m_whisper.content.hotspot.pressed_callback = callback(self, "cb_misc", "whispers") end
    if w.m_noprops then w.m_noprops.content.hotspot.pressed_callback = callback(self, "cb_toggle", "ps_no_props") end
    if w.m_continuous then w.m_continuous.content.hotspot.pressed_callback = callback(self, "cb_misc", "continuous") end
    if w.m_swap then w.m_swap.content.hotspot.pressed_callback = callback(self, "cb_toggle", "ps_swap_lineup") end
    if w.m_immortal then w.m_immortal.content.hotspot.pressed_callback = callback(self, "cb_misc", "immortal") end
    if w.m_invis then w.m_invis.content.hotspot.pressed_callback = callback(self, "cb_misc", "invisible") end
    if w.m_reset then w.m_reset.content.hotspot.pressed_callback = callback(self, "cb_misc", "reset") end
    if w.m_nostagger then w.m_nostagger.content.hotspot.pressed_callback = callback(self, "cb_misc", "nostagger") end

    for i = 1, QUEUE_ROWS do
        local row = w["queue_row_" .. i]
        if row then row.content.hotspot.pressed_callback = callback(self, "cb_queue_row", i) end
        local minus = w["queue_minus_" .. i]
        if minus then minus.content.hotspot.pressed_callback = callback(self, "cb_queue_adj", i, -1) end
        local plus = w["queue_plus_" .. i]
        if plus then plus.content.hotspot.pressed_callback = callback(self, "cb_queue_adj", i, 1) end
        local xb = w["queue_x_" .. i]
        if xb then xb.content.hotspot.pressed_callback = callback(self, "cb_queue_del", i) end
    end
end

PsykhaniumSpawnerView._current_list = function (self)
    local mod = self._spawner
    local lists = mod and mod.lists or {}
    return lists[self._category] or {}
end

PsykhaniumSpawnerView._refresh = function (self)
    local w = self:_wb()
    local mod = self._spawner
    local mode = self._mode

    for m, names in pairs(GROUPS) do
        local vis = (m == mode)
        for _, name in ipairs(names) do
            if w[name] then w[name].visible = vis end
        end
    end

    local grid_mode = (mode == "spawn" or mode == "indulg")
    for _, nm in ipairs({ "page_prev", "page_label", "page_next" }) do
        if w[nm] then w[nm].visible = grid_mode end
    end
    if not grid_mode then
        for i = 1, PER_PAGE do
            if w["slot_" .. i] then w["slot_" .. i].visible = false end
        end
    end

    for i = 1, 5 do
        if w["mode_" .. i] then w["mode_" .. i].content.hotspot.is_selected = (MODES[i] == mode) end
    end

    if mode == "spawn" then self:_refresh_spawn()
    elseif mode == "player" then self:_refresh_player()
    elseif mode == "waves" then self:_refresh_waves()
    elseif mode == "misc" then self:_refresh_misc()
    elseif mode == "indulg" then self:_refresh_indulg() end

    if mode == "spawn" and self._category == "allies" then
        for _, nm in ipairs({ "page_prev", "page_next", "mode", "count_dec", "count_val", "count_inc",
            "spread_dec", "spread_val", "spread_inc", "t_aim", "spawn", "clear", "queue_keep", "spawn_close" }) do
            if w[nm] then w[nm].visible = false end
        end
    end

    self:_refresh_queue()

    if w.info then w.info.content.text = "" end
end

PsykhaniumSpawnerView._refresh_spawn = function (self)
    local w = self:_wb()
    local mod = self._spawner

    if self._category == "allies" then
        self:_refresh_allies()
        for i = 1, 6 do
            local tab = w["tab_" .. i]
            if tab then tab.content.hotspot.is_selected = (i == 6) and true or false end
        end
        return
    end

    local list = self:_current_list()

    local total = #list
    local pages = math.max(1, math.ceil(total / PER_PAGE))
    if self._page > pages then self._page = pages end
    if self._page < 1 then self._page = 1 end
    local start_i = (self._page - 1) * PER_PAGE

    self._slot_breed = {}
    for i = 1, PER_PAGE do
        local slot = w["slot_" .. i]
        if slot then
            local breed = list[start_i + i]
            local icon = slot.style and slot.style.icon
            local text = slot.style and slot.style.text
            if breed then
                slot.content.original_text = mod and mod.breed_label(breed) or breed
                slot.content.hotspot.disabled = false
                slot.visible = true
                self._slot_breed[i] = breed

                local show_icon = mod and mod.has_icon and mod.has_icon(breed)
                    and mod.icons_available and mod.icons_available()
                local tex = (show_icon and mod.get_icon) and mod.get_icon(breed) or nil
                if icon and icon.material_values then icon.material_values.texture_map = tex end
                if text then
                    text.text_horizontal_alignment = show_icon and "left" or "center"
                    if text.offset then text.offset[1] = show_icon and TEXT_INSET or 0 end
                    if text.size then text.size[1] = show_icon and TEXT_W_ICON or TEXT_W_FULL end
                end
            else
                slot.content.original_text = ""
                slot.content.text = ""
                slot.content.hotspot.disabled = true
                slot.visible = false
                self._slot_breed[i] = nil
                if icon and icon.material_values then icon.material_values.texture_map = nil end
            end
        end
    end

    local order = mod and mod.breeds_data and mod.breeds_data.category_order or {}
    for i = 1, 6 do
        local tab = w["tab_" .. i]
        if tab then tab.content.hotspot.is_selected = (order[i] == self._category) end
    end

    local count = (mod and mod:get("ps_spawn_count")) or 1
    set_txt(w, "count_val", Vf(self, "btn_count_fmt", count))

    local select_mode = mod and mod:get("ps_select_mode")
    local aim  = mod and mod:get("ps_menu_spawn_at_aim")
    local keepq = mod and mod:get("ps_keep_queue")
    local onclose = mod and mod:get("ps_spawn_on_close")

    set_btn(w, "mode", V(self, select_mode and "btn_mode_select" or "btn_mode_click"))
    set_btn(w, "t_aim", V(self, aim and "btn_aim_on" or "btn_aim_off"))
    set_btn(w, "queue_keep", V(self, keepq and "btn_horde_keep" or "btn_horde_once"))
    set_btn(w, "spawn_close", Vf(self, "btn_on_close_fmt", onoff(self, onclose)))

    if w.mode then w.mode.content.hotspot.is_selected = select_mode and true or false end
    if w.t_aim then w.t_aim.content.hotspot.is_selected = aim and true or false end
    if w.queue_keep then w.queue_keep.content.hotspot.is_selected = keepq and true or false end
    if w.spawn_close then w.spawn_close.content.hotspot.is_selected = onclose and true or false end

    local spread = (mod and mod:get("ps_spread")) or 2
    set_txt(w, "spread_val", Vf(self, "btn_spread_fmt", spread))

    local qn = mod and mod.queue_count and mod.queue_count() or 0
    set_btn(w, "spawn", Vf(self, "ui_spawn_fmt", qn))
    if w.spawn then w.spawn.content.hotspot.disabled = (qn == 0) end
    if w.clear then w.clear.content.hotspot.disabled = (qn == 0) end

    set_txt(w, "page_label", Vf(self, "ui_page_fmt", self._page, pages))
end

PsykhaniumSpawnerView._refresh_allies = function (self)
    local w = self:_wb()
    local mod = self._spawner
    local profiles = (mod and mod.bot_profiles) or {}

    self._slot_breed = {}
    self._slot_bot = {}

    local opts = {}
    for i = 1, #profiles do
        opts[#opts + 1] = { kind = "spawn", profile = profiles[i], label = Vf(self, "ally_slot_fmt", i) }
    end
    opts[#opts + 1] = { kind = "random",     label = V(self, "ally_random") }
    opts[#opts + 1] = { kind = "remove_one", label = V(self, "ally_remove_one") }
    opts[#opts + 1] = { kind = "remove_all", label = V(self, "ally_remove_all") }

    local bmode = (mod and mod.bot_mode and mod.bot_mode()) or "active"
    opts[#opts + 1] = {
        kind = "mode",
        label = Vf(self, "ally_mode_fmt", V(self, "bot_mode_" .. bmode)),
        active = (bmode ~= "active"),
    }

    for i = 1, PER_PAGE do
        local slot = w["slot_" .. i]
        if slot then
            local o = opts[i]
            local icon = slot.style and slot.style.icon
            if icon and icon.material_values then icon.material_values.texture_map = nil end
            local text = slot.style and slot.style.text
            if o then
                slot.visible = true
                slot.content.hotspot.disabled = false
                slot.content.hotspot.is_selected = o.active and true or false
                slot.content.original_text = o.label
                if text then
                    text.text_horizontal_alignment = "center"
                    if text.offset then text.offset[1] = 0 end
                    if text.size then text.size[1] = TEXT_W_FULL end
                end
                self._slot_bot[i] = o
            else
                slot.visible = false
                slot.content.original_text = ""
                slot.content.text = ""
                slot.content.hotspot.disabled = true
                self._slot_bot[i] = nil
            end
        end
    end

    local n = (mod and mod.bot_count and mod.bot_count()) or 0
    local maxb = (mod and mod.MAX_BOTS) or 3
    set_txt(w, "page_label", Vf(self, "ally_count_fmt", n, maxb))
end

PsykhaniumSpawnerView._refresh_player = function (self)
    local w = self:_wb()
    local mod = self._spawner
    if not mod or not mod._god then return end

    for name, key in pairs(GOD_BTN) do
        local label = V(self, GOD_LABEL_KEY[name])
        local on = (key == "all") and (mod.god_all_on and mod.god_all_on()) or mod._god[key]
        set_btn(w, name, label .. ": " .. onoff(self, on))
        if w[name] then w[name].content.hotspot.is_selected = on and true or false end
    end
end

PsykhaniumSpawnerView._refresh_waves = function (self)
    local w = self:_wb()
    local mod = self._spawner
    local active = mod and mod.wave_active and mod.wave_active()
    local auto = mod and mod.wave_auto_get and mod.wave_auto_get()
    set_txt(w, "wave_label", mod and mod.wave_status and mod.wave_status() or V(self, "wave_idle"))
    set_btn(w, "wave_auto", V(self, auto and "misc_auto_on" or "misc_auto_off"))
    if w.wave_auto then w.wave_auto.content.hotspot.is_selected = auto and true or false end
    if w.wave_stop then w.wave_stop.content.hotspot.disabled = not active end
    if w.wave_next then w.wave_next.content.hotspot.disabled = not active end
    if w.wave_start then w.wave_start.content.hotspot.disabled = (self._last_trial == nil) end
end

PsykhaniumSpawnerView._refresh_misc = function (self)
    local w = self:_wb()
    local mod = self._spawner
    local ai   = mod and mod:get("ps_enemy_ai")
    local ndef = mod and mod:get("ps_no_default_enemies")
    local muff = mod and mod.muffler_off and mod.muffler_off()
    local nowh = mod and mod.whispers_off and mod.whispers_off()
    local noprops = mod and mod:get("ps_no_props")
    local cont = mod and mod.continuous_on and mod.continuous_on()

    set_btn(w, "m_ai",      Vf(self, "misc_ai_fmt", onoff(self, ai)))
    set_btn(w, "m_nodef",   Vf(self, "misc_no_def_fmt", onoff(self, ndef)))
    set_btn(w, "m_muffler", V(self, muff and "misc_muffler_off" or "misc_muffler_on"))
    set_btn(w, "m_whisper", V(self, nowh and "misc_whispers_off" or "misc_whispers_on"))
    set_btn(w, "m_noprops", V(self, noprops and "misc_props_hidden" or "misc_props_shown"))
    set_btn(w, "m_continuous", Vf(self, "misc_continuous_fmt", onoff(self, cont)))
    set_btn(w, "m_swap", V(self, (mod and mod:get("ps_swap_lineup")) and "misc_lineup_missing" or "misc_lineup_default"))

    local immo = mod and mod.immortal_enemies_on and mod.immortal_enemies_on()
    set_btn(w, "m_immortal", Vf(self, "misc_infinite_hp_fmt", onoff(self, immo)))
    local invis = mod and mod.invisible_on and mod.invisible_on()
    set_btn(w, "m_invis", Vf(self, "misc_invisible_fmt", onoff(self, invis)))
    local nostag = mod and mod:get("ps_no_stagger")
    set_btn(w, "m_nostagger", Vf(self, "misc_no_stagger_fmt", onoff(self, nostag)))

    if w.m_ai then w.m_ai.content.hotspot.is_selected = ai and true or false end
    if w.m_nodef then w.m_nodef.content.hotspot.is_selected = ndef and true or false end
    if w.m_muffler then w.m_muffler.content.hotspot.is_selected = muff and true or false end
    if w.m_whisper then w.m_whisper.content.hotspot.is_selected = nowh and true or false end
    if w.m_noprops then w.m_noprops.content.hotspot.is_selected = noprops and true or false end
    if w.m_continuous then w.m_continuous.content.hotspot.is_selected = cont and true or false end
    if w.m_swap then w.m_swap.content.hotspot.is_selected = (mod and mod:get("ps_swap_lineup")) and true or false end
    if w.m_immortal then w.m_immortal.content.hotspot.is_selected = immo and true or false end
    if w.m_invis then w.m_invis.content.hotspot.is_selected = invis and true or false end
    if w.m_nostagger then w.m_nostagger.content.hotspot.is_selected = nostag and true or false end
end

PsykhaniumSpawnerView._refresh_indulg = function (self)
    local w = self:_wb()
    local mod = self._spawner
    if mod and mod.build_indulgences and not mod._indulg then pcall(mod.build_indulgences) end
    local fams = (mod and mod._indulg) or {}
    self._slot_indulg = {}
    local function clear_slots()
        for i = 1, PER_PAGE do
            local slot = w["slot_" .. i]
            if slot then
                slot.content.original_text = ""
                slot.content.text = ""
                slot.content.hotspot.disabled = true
                slot.visible = false
                local icon = slot.style and slot.style.icon
                if icon and icon.material_values then icon.material_values.texture_map = nil end
            end
        end
    end
    if #fams == 0 then
        clear_slots()
        set_txt(w, "page_label", V(self, (mod and mod.indulgences_available and mod.indulgences_available())
            and "ui_no_indulgences" or "ui_indulgences_unavail"))
        return
    end
    local fi = self._indulg_family or 1
    if fi < 1 then fi = #fams end
    if fi > #fams then fi = 1 end
    self._indulg_family = fi
    local fam = fams[fi]
    local buffs = fam.buffs or {}
    for i = 1, PER_PAGE do
        local slot = w["slot_" .. i]
        if slot then
            local buff = buffs[i]
            local icon = slot.style and slot.style.icon
            if icon and icon.material_values then icon.material_values.texture_map = nil end
            if buff then
                slot.content.original_text = mod.indulgence_title(buff)
                slot.content.hotspot.disabled = false
                slot.content.hotspot.is_selected = (mod.has_indulgence and mod.has_indulgence(buff)) or false
                slot.visible = true
                self._slot_indulg[i] = buff
            else
                slot.content.original_text = ""
                slot.content.text = ""
                slot.content.hotspot.disabled = true
                slot.visible = false
                self._slot_indulg[i] = nil
            end
        end
    end
    set_txt(w, "page_label", fam.label .. "  (" .. fi .. "/" .. #fams .. ")")
end

PsykhaniumSpawnerView._refresh_queue = function (self)
    local w = self:_wb()
    local mod = self._spawner
    local q = (mod and mod._queue) or {}
    set_txt(w, "queue_title", Vf(self, "ui_horde_title_fmt", #q))

    local counts, order = {}, {}
    for i = 1, #q do
        local b = q[i]
        if not counts[b] then counts[b] = 0; order[#order + 1] = b end
        counts[b] = counts[b] + 1
    end

    self._queue_breed = {}
    local shown = math.min(#order, QUEUE_ROWS)
    if #order > QUEUE_ROWS then shown = QUEUE_ROWS - 1 end
    for i = 1, QUEUE_ROWS do
        local row   = w["queue_row_" .. i]
        local minus = w["queue_minus_" .. i]
        local plus  = w["queue_plus_" .. i]
        local xb    = w["queue_x_" .. i]
        local breed = (i <= shown) and order[i] or nil
        self._queue_breed[i] = breed
        if breed then
            if row then
                row.visible = true
                row.content.original_text = (mod and mod.breed_label(breed) or breed) .. "  x" .. counts[breed]
                row.content.hotspot.disabled = false
                row.content.hotspot.is_selected = (breed == self._stats_breed)
                local ic = row.style and row.style.icon
                if ic and ic.material_values then
                    ic.material_values.texture_map = (mod and mod.get_icon) and mod.get_icon(breed) or nil
                end
            end
            if minus then minus.visible = true; minus.content.hotspot.disabled = false end
            if plus  then plus.visible = true;  plus.content.hotspot.disabled = false end
            if xb    then xb.visible = true;    xb.content.hotspot.disabled = false end
        else
            if row then row.visible = false end
            if minus then minus.visible = false end
            if plus then plus.visible = false end
            if xb then xb.visible = false end
        end
    end
    if w.queue_hint then w.queue_hint.visible = (#order > 0) end
    if w.queue_more then
        if #order > QUEUE_ROWS then
            w.queue_more.visible = true
            w.queue_more.content.text = Vf(self, "ui_more_types_fmt", #order - shown)
        else
            w.queue_more.visible = false
        end
    end
end

PsykhaniumSpawnerView.cb_mode = function (self, mode)
    self._mode = mode
    if self._spawner then
        self._spawner._last_mode = mode
        self._spawner:set("ps_last_mode", mode, false)
        if mode == "indulg" and self._spawner.build_indulgences
            and (not self._spawner._indulg or #self._spawner._indulg == 0) then
            pcall(self._spawner.build_indulgences)
        end
    end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_count_adj = function (self, dir)
    local mod = self._spawner
    if mod then
        local v = (mod:get("ps_spawn_count") or 1) + dir
        if v < 1 then v = 1 end
        if v > 20 then v = 20 end
        mod:set("ps_spawn_count", v)
    end
    self:_refresh()
end

PsykhaniumSpawnerView._after_queue_change = function (self)
    self:_refresh_queue()
    if self._mode == "spawn" then
        local w = self:_wb()
        local mod = self._spawner
        local qn = mod and mod.queue_count and mod.queue_count() or 0
        set_btn(w, "spawn", Vf(self, "ui_spawn_fmt", qn))
        if w.spawn then w.spawn.content.hotspot.disabled = (qn == 0) end
        if w.clear then w.clear.content.hotspot.disabled = (qn == 0) end
    end
end

PsykhaniumSpawnerView.cb_queue_row = function (self, i)
    local breed = self._queue_breed and self._queue_breed[i]
    if not breed then return end
    if self._stats_breed == breed then
        self._stats_breed = nil
        self:_set_stats(nil)
    else
        self._stats_breed = breed
        self:_set_stats(breed)
    end
    self:_refresh_queue()
end

PsykhaniumSpawnerView.cb_queue_adj = function (self, i, dir)
    local breed = self._queue_breed and self._queue_breed[i]
    local mod = self._spawner
    if not breed or not mod then return end
    if dir > 0 then
        if mod.queue_add_one then mod.queue_add_one(breed) end
    elseif mod.queue_remove_one then
        mod.queue_remove_one(breed)
    end
    self:_after_queue_change()
end

PsykhaniumSpawnerView.cb_queue_del = function (self, i)
    local breed = self._queue_breed and self._queue_breed[i]
    if breed and self._spawner and self._spawner.queue_remove_type then
        self._spawner.queue_remove_type(breed)
        self:_after_queue_change()
    end
end

PsykhaniumSpawnerView.cb_tab = function (self, i)
    local order = self._spawner and self._spawner.breeds_data.category_order or {}
    local cat = (i == 6) and "allies" or order[i]
    if cat then
        self._category = cat
        self._page = 1
        if self._spawner then
            self._spawner._last_category = cat
            self._spawner:set("ps_last_category", cat, false)
        end
        self:_refresh()
    end
end

PsykhaniumSpawnerView.cb_slot = function (self, i)
    if self._mode == "indulg" then
        local buff = self._slot_indulg and self._slot_indulg[i]
        if buff and self._spawner and self._spawner.toggle_indulgence then
            self._spawner.toggle_indulgence(buff)
            self:_refresh()
        end
        return
    end
    if self._mode == "spawn" and self._category == "allies" then
        local o = self._slot_bot and self._slot_bot[i]
        local mod = self._spawner
        if o and mod then
            if o.kind == "spawn" and mod.spawn_bot then mod.spawn_bot(o.profile)
            elseif o.kind == "random" and mod.spawn_bot_random then mod.spawn_bot_random()
            elseif o.kind == "remove_one" and mod.despawn_one_bot then mod.despawn_one_bot()
            elseif o.kind == "remove_all" and mod.despawn_all_bots then mod.despawn_all_bots()
            elseif o.kind == "mode" and mod.cycle_bot_mode then mod:cycle_bot_mode() end
            self:_refresh()
        end
        return
    end
    local breed = self._slot_breed[i]
    if breed and self._spawner then
        self._spawner.menu_spawn(breed)
        self:_after_queue_change()
    end
end

PsykhaniumSpawnerView.cb_spread = function (self, dir)
    local mod = self._spawner
    if mod then
        local v = (mod:get("ps_spread") or 2) + dir
        if v < 0 then v = 0 end
        if v > 8 then v = 8 end
        mod:set("ps_spread", v)
    end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_page = function (self, dir)
    if self._mode == "indulg" then
        self._indulg_family = (self._indulg_family or 1) + dir
        self:_refresh()
        if self._spawner then
            self._spawner._indulg_family = self._indulg_family
            self._spawner:set("ps_indulg_family", self._indulg_family, false)
        end
        return
    end
    self._page = self._page + dir
    self:_refresh()
end

PsykhaniumSpawnerView.cb_toggle = function (self, setting_id)
    local mod = self._spawner
    if mod then mod:set(setting_id, not mod:get(setting_id), true) end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_spawn_queue = function (self)
    if self._spawner then self._spawner.queue_spawn() end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_clear = function (self)
    if self._spawner then self._spawner.queue_clear() end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_god = function (self, key)
    if self._spawner and self._spawner.god_toggle then self._spawner.god_toggle(key) end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_preset = function (self, i)
    local mod = self._spawner
    local waves = mod and mod.waves
    local p = waves and waves.presets[i]
    if p and mod.spawn_preset then mod.spawn_preset(p.id) end
end

PsykhaniumSpawnerView.cb_trial = function (self, i)
    local mod = self._spawner
    local waves = mod and mod.waves
    local t = waves and waves.trials[i]
    if t and mod.start_trial then
        self._last_trial = t.id
        mod.start_trial(t.id)
        self:_refresh()
    end
end

PsykhaniumSpawnerView.cb_wave = function (self, action)
    local mod = self._spawner
    if not mod then return end
    if action == "stop" and mod.wave_stop then mod.wave_stop()
    elseif action == "next" and mod.wave_next then mod.wave_next()
    elseif action == "auto" and mod.wave_auto_toggle then mod.wave_auto_toggle()
    elseif action == "restart" and self._last_trial and mod.start_trial then mod.start_trial(self._last_trial) end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_misc = function (self, action)
    local mod = self._spawner
    if not mod then return end
    if action == "muffler" and mod.toggle_sound_muffler then mod:toggle_sound_muffler()
    elseif action == "killall" then mod:kill_all()
    elseif action == "respawn" and mod.respawn then mod:respawn()
    elseif action == "whispers" and mod.toggle_whispers then mod:toggle_whispers()
    elseif action == "continuous" and mod.toggle_continuous then mod:toggle_continuous()
    elseif action == "immortal" and mod.toggle_immortal_enemies then mod:toggle_immortal_enemies()
    elseif action == "invisible" and mod.toggle_invisible then mod:toggle_invisible()
    elseif action == "reset" and mod.reset_to_default then mod:reset_to_default()
    elseif action == "nostagger" and mod.toggle_no_stagger then mod:toggle_no_stagger() end
    self:_refresh()
end

PsykhaniumSpawnerView.cb_action = function (self, action)
    local mod = self._spawner
    if not mod then return end
    if action == "refill" then
        mod:refill()
    elseif action == "close" then
        Managers.ui:close_view(self.view_name)
    end
end

PsykhaniumSpawnerView._group_desc = function (self, group)
    local mod = self._spawner
    local parts = {}
    for breed, n in pairs(group or {}) do
        parts[#parts + 1] = (mod and mod.breed_label(breed) or breed) .. " x" .. n
    end
    return table.concat(parts, ", ")
end

PsykhaniumSpawnerView._wave_tooltip = function (self, name)
    local mod = self._spawner
    local waves = mod and mod.waves
    if not waves then return nil end
    local pi = string.match(name, "^preset_(%d+)$")
    if pi then
        local p = waves.presets[tonumber(pi)]
        return p and (V(self, "ui_spawn") .. ": " .. self:_group_desc(p.group)) or nil
    end
    local ti = string.match(name, "^trial_(%d+)$")
    if ti then
        local t = waves.trials[tonumber(ti)]
        if not t then return nil end
        local adv = V(self, (t.advance == "timer") and "tip_wave_timer_adv" or "tip_wave_clear_adv")
        local endless = t.endless and V(self, "tip_wave_endless") or ""
        return Vf(self, "tip_wave_trial_fmt", #t.waves, adv, endless, self:_group_desc(t.waves[1]))
    end
    return nil
end

local function keybind_str(mod, setting_id)
    if not setting_id or not mod then return nil end
    local dmf = get_mod("DMF")
    local val = mod:get(setting_id)
    if type(val) ~= "table" or not val.main then return nil end
    if dmf and dmf.keywatch_result_to_local_keys then
        local ok, keys = pcall(dmf.keywatch_result_to_local_keys, val)
        if ok and keys and #keys > 0 then return table.concat(keys, " + ") end
    end
    return nil
end

PsykhaniumSpawnerView._update_tooltip = function (self)
    local w = self:_wb()
    if not w.info then return end
    local hovered, hname
    if self._mode == "indulg" and self._slot_indulg then
        for i = 1, PER_PAGE do
            local b = w["slot_" .. i]
            if b and b.visible and b.content.hotspot.is_hover then
                local buff = self._slot_indulg[i]
                local desc = (buff and self._spawner and self._spawner.indulgence_desc)
                    and self._spawner.indulgence_desc(buff) or nil
                w.info.content.text = (desc and desc ~= "") and desc or ""
                return
            end
        end
    end
    for i = 1, 6 do
        local b = w["preset_" .. i]
        if b and b.visible and b.content.hotspot.is_hover then hovered = self:_wave_tooltip("preset_" .. i); break end
    end
    if not hovered then
        for i = 1, 4 do
            local b = w["trial_" .. i]
            if b and b.visible and b.content.hotspot.is_hover then hovered = self:_wave_tooltip("trial_" .. i); break end
        end
    end
    if not hovered then
        for name, tip_key in pairs(TOOLTIPS_KEY) do
            local b = w[name]
            if b and b.visible and b.content and b.content.hotspot and b.content.hotspot.is_hover then
                hovered = V(self, tip_key)
                hname = name
                break
            end
        end
    end
    if hovered and hname then
        local ks = keybind_str(self._spawner, BTN_KEYBIND[hname])
        if ks then hovered = hovered .. "   [" .. ks .. "]" end
    end
    w.info.content.text = hovered or ""
end

local ZONE_MAP = {
    z_head    = "head",            z_chest   = "torso",           z_belly = "center_mass",
    z_larm_up = "upper_left_arm",  z_larm_lo = "lower_left_arm",
    z_rarm_up = "upper_right_arm", z_rarm_lo = "lower_right_arm",
    z_lleg_up = "upper_left_leg",  z_lleg_lo = "lower_left_leg",
    z_rleg_up = "upper_right_leg", z_rleg_lo = "lower_right_leg",
}

PsykhaniumSpawnerView._set_stats = function (self, breed)
    local w = self:_wb()
    local mod = self._spawner
    local arm_names = (mod and mod.armor_name) or {}

    local function show_zones(vis)
        for zid in pairs(ZONE_MAP) do
            if w[zid] then w[zid].visible = vis end
        end
    end

    local function show_nz(vis)
        for i = 1, 8 do
            local nw = w["nz_" .. i]
            if nw then nw.visible = vis end
        end
    end

    local function show_extras(vis)
        for i = 1, 4 do
            if w["ex_sw_" .. i] then w["ex_sw_" .. i].visible = vis end
            if w["ex_tx_" .. i] then w["ex_tx_" .. i].visible = vis end
        end
    end

    local s = (breed and mod and mod.enemy_stats) and mod.enemy_stats(breed) or nil
    if not s then
        set_txt(w, "stats_name", "")
        set_txt(w, "stats_health", "")
        if w.stats_hint then w.stats_hint.visible = true end
        set_txt(w, "stats_hint", V(self, "ui_stats_hint"))
        show_zones(false)
        show_nz(false)
        show_extras(false)
        return
    end

    if w.stats_hint then w.stats_hint.visible = false end
    set_txt(w, "stats_name", s.name)
    local hp = (type(s.health) == "number") and tostring(s.health) or V(self, "ui_na")
    set_txt(w, "stats_health", Vf(self, "ui_health_fmt", hp))

    local ac = (mod.armor_color) or {}

    if s.humanoid then
        show_nz(false)
        for zid, zkey in pairs(ZONE_MAP) do
            local ww = w[zid]
            if ww then
                ww.visible = true
                local col = ac[s.zones[zkey] or s.base] or { 120, 120, 120 }
                local fill = ww.style and ww.style.fill
                if fill and fill.color then
                    fill.color[1] = 255; fill.color[2] = col[1]; fill.color[3] = col[2]; fill.color[4] = col[3]
                end
            end
        end
        local extras = s.extras or {}
        for i = 1, 4 do
            local sw, tx = w["ex_sw_" .. i], w["ex_tx_" .. i]
            local e = extras[i]
            if e then
                local col = ac[e.cat] or { 200, 200, 200 }
                if sw then
                    sw.visible = true
                    local fill = sw.style and sw.style.fill
                    if fill and fill.color then
                        fill.color[1] = 255; fill.color[2] = col[1]; fill.color[3] = col[2]; fill.color[4] = col[3]
                    end
                end
                if tx then
                    tx.visible = true
                    tx.content.text = e.label
                    local st = tx.style and tx.style.text
                    if st and st.text_color then
                        st.text_color[1] = 255; st.text_color[2] = col[1]; st.text_color[3] = col[2]; st.text_color[4] = col[3]
                    end
                end
            else
                if sw then sw.visible = false end
                if tx then tx.visible = false; tx.content.text = "" end
            end
        end
    else
        show_zones(false)
        show_extras(false)
        local rows = s.summary or {}
        for i = 1, 8 do
            local nw = w["nz_" .. i]
            if nw then
                local row = rows[i]
                if row then
                    nw.visible = true
                    local parts = {}
                    for _, c in ipairs(row.cats) do parts[#parts + 1] = (arm_names[c] or c) end
                    nw.content.text = row.label .. ": " .. table.concat(parts, " / ")
                    local col = ac[row.cats[1]] or { 220, 220, 220 }
                    local st = nw.style and nw.style.text
                    if st and st.text_color then
                        st.text_color[1] = 255; st.text_color[2] = col[1]; st.text_color[3] = col[2]; st.text_color[4] = col[3]
                    end
                else
                    nw.visible = false
                    nw.content.text = ""
                end
            end
        end
    end
end

PsykhaniumSpawnerView._update_stats = function (self)
    local w = self:_wb()
    if not w.stats_name then return end
    local hover_breed
    if self._mode == "spawn" then
        for i = 1, PER_PAGE do
            local slot = w["slot_" .. i]
            if slot and slot.visible and slot.content.hotspot.is_hover then
                hover_breed = self._slot_breed[i]
                break
            end
        end
    end
    if hover_breed and hover_breed ~= self._stats_breed then
        self._stats_breed = hover_breed
        self:_set_stats(hover_breed)
    end
end

PsykhaniumSpawnerView.update = function (self, dt, t, input_service)
    pcall(function() self:_update_tooltip() end)
    pcall(function() self:_update_stats() end)
    return PsykhaniumSpawnerView.super.update(self, dt, t, input_service)
end

PsykhaniumSpawnerView.on_exit = function (self)
    if self._spawner and self._spawner._view == self then self._spawner._view = nil end
    if self._spawner and self._spawner.queue_spawn and self._spawner:get("ps_spawn_on_close") then
        pcall(self._spawner.queue_spawn)
    end
    PsykhaniumSpawnerView.super.on_exit(self)
end

return PsykhaniumSpawnerView
