local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local PANEL_W, PANEL_H   = 1620, 700
local CONTENT_W, CONTENT_DX = 960, 0
local QUEUE_W,  QUEUE_DX    = 300, 650
local STATS_W,  STATS_DX    = 300, -650

local COLS      = 4
local ROWS      = 5
local SLOTS     = COLS * ROWS
local BTN_W     = 224
local BTN_H     = 48
local ICON_SIZE = 34
local ICON_PAD  = 6
local GRID_TOP  = -176
local ROW_STEP  = 52
local COL_X     = { -354, -118, 118, 354 }

local scenegraph_definition = {
	screen  = { scale = "fit", size = { 1920, 1080 }, position = { 0, 0, 0 } },
	root    = { parent = "screen", horizontal_alignment = "center", vertical_alignment = "center", size = { PANEL_W, PANEL_H }, position = { 0, 0, 1 } },
	content = { parent = "root", horizontal_alignment = "center", vertical_alignment = "center", size = { CONTENT_W, PANEL_H }, position = { CONTENT_DX, 0, 1 } },
	queue   = { parent = "root", horizontal_alignment = "center", vertical_alignment = "center", size = { QUEUE_W, PANEL_H - 40 }, position = { QUEUE_DX, 0, 1 } },
	stats   = { parent = "root", horizontal_alignment = "center", vertical_alignment = "center", size = { STATS_W, PANEL_H - 40 }, position = { STATS_DX, 0, 1 } },
}

local function node(id, x, y, w, h, z, parent)
	scenegraph_definition[id] = {
		parent = parent or "content",
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = { w or BTN_W, h or BTN_H },
		position = { x, y, z or 2 },
	}
end

local widget_definitions = {}

widget_definitions.background = UIWidget.create_definition({
	{ pass_type = "rect", style = { color = { 236, 10, 12, 16 } } },
	{ pass_type = "texture", value = "content/ui/materials/frames/frame_tile_2px", style = { color = { 255, 120, 90, 60 }, scale_to_material = true } },
}, "root", nil, { PANEL_W, PANEL_H })

widget_definitions.queue_bg = UIWidget.create_definition({
	{ pass_type = "rect", style = { color = { 170, 18, 20, 26 } } },
	{ pass_type = "texture", value = "content/ui/materials/frames/frame_tile_2px", style = { color = { 255, 120, 90, 50 }, scale_to_material = true } },
}, "queue", nil, { QUEUE_W, PANEL_H - 40 })

widget_definitions.stats_bg = UIWidget.create_definition({
	{ pass_type = "rect", style = { color = { 170, 18, 20, 26 } } },
	{ pass_type = "texture", value = "content/ui/materials/frames/frame_tile_2px", style = { color = { 255, 120, 90, 50 }, scale_to_material = true } },
}, "stats", nil, { STATS_W, PANEL_H - 40 })

local function text_widget(id, x, y, w, h, font_size, align, parent)
	node(id, x, y, w, h, 3, parent)
	return UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = "",
			style = {
				font_type = "proxima_nova_bold",
				font_size = font_size or 22,
				text_horizontal_alignment = align or "center",
				text_vertical_alignment = "center",
				text_color = { 255, 235, 235, 235 },
				offset = { 0, 0, 4 },
			},
		},
	}, id, { text = "" }, { w, h })
end

local function button_widget(id, x, y, w, h, parent)
	node(id, x, y, w or BTN_W, h or BTN_H, 2, parent)
	return UIWidget.create_definition(ButtonPassTemplates.terminal_button, id, { original_text = "" }, { w or BTN_W, h or BTN_H })
end

local function slot_button_widget(id, x, y, w, h)
	w = w or BTN_W
	h = h or BTN_H
	node(id, x, y, w, h, 2)

	local passes = {}
	for i = 1, #ButtonPassTemplates.terminal_button do
		passes[#passes + 1] = ButtonPassTemplates.terminal_button[i]
	end
	passes[#passes + 1] = {
		texture = nil,
		size = { ICON_SIZE, ICON_SIZE },
		style_id = "icon",
		pass_type = "rotated_texture",
		horizontal_alignment = "left",
		vertical_alignment = "center",
		style = {
			angle = 0,
			pivot = { ICON_SIZE * 0.5, ICON_SIZE * 0.5 },
			horizontal_alignment = "left",
			vertical_alignment = "center",
			size = { ICON_SIZE, ICON_SIZE },
			offset = { ICON_PAD, 0, 5 },
			color = { 255, 255, 255, 255 },
			material_values = { texture_map = nil },
		},
		visibility_function = function(content, style)
			return style.material_values ~= nil and style.material_values.texture_map ~= nil
		end,
	}

	local def = UIWidget.create_definition(passes, id, { original_text = "" }, { w, h })
	if def.style and def.style.text then
		local t = {}
		for k, v in pairs(def.style.text) do t[k] = v end
		local oz = (def.style.text.offset and def.style.text.offset[3]) or 6
		t.offset = { 0, 0, oz }
		t.font_size = 16
		t.word_wrap = true
		t.size = { w - 8, h }
		def.style.text = t
	end
	return def
end

local function queue_row_widget(id, y)
	node(id, -43, y, QUEUE_W - 106, 28, 2, "queue")
	local passes = {}
	for i = 1, #ButtonPassTemplates.terminal_button do passes[#passes + 1] = ButtonPassTemplates.terminal_button[i] end
	passes[#passes + 1] = {
		texture = nil,
		size = { 22, 22 },
		style_id = "icon",
		pass_type = "rotated_texture",
		horizontal_alignment = "left",
		vertical_alignment = "center",
		style = {
			angle = 0,
			pivot = { 11, 11 },
			horizontal_alignment = "left",
			vertical_alignment = "center",
			size = { 22, 22 },
			offset = { 6, 0, 5 },
			color = { 255, 255, 255, 255 },
			material_values = { texture_map = nil },
		},
		visibility_function = function(content, style)
			return style.material_values ~= nil and style.material_values.texture_map ~= nil
		end,
	}
	local def = UIWidget.create_definition(passes, id, { original_text = "" }, { QUEUE_W - 106, 28 })
	if def.style and def.style.text then
		local t = {}
		for k, v in pairs(def.style.text) do t[k] = v end
		t.text_horizontal_alignment = "left"
		t.offset = { 34, 0, (def.style.text.offset and def.style.text.offset[3]) or 6 }
		t.font_size = 15
		def.style.text = t
	end
	return def
end

local function queue_small_btn(id, x, y, label, font_size)
	node(id, x, y, 26, 28, 3, "queue")
	local def = UIWidget.create_definition(ButtonPassTemplates.terminal_button, id, { original_text = label }, { 26, 28 })

	if font_size and def.style and def.style.text then def.style.text.font_size = font_size end
	return def
end

local function zone_widget(id, x, y, w, h)
	node(id, x, y, w, h, 3, "stats")
	return UIWidget.create_definition({
		{ pass_type = "rect", style_id = "border", style = { size = { w + 4, h + 4 }, offset = { 0, 0, 2 }, color = { 200, 20, 20, 20 } } },
		{ pass_type = "rect", style_id = "fill",   style = { size = { w, h },         offset = { 0, 0, 3 }, color = { 255, 120, 120, 120 } } },
	}, id, nil, { w, h })
end

widget_definitions.title = text_widget("title_sg", 0, -318, CONTENT_W - 60, 38, 26, "center")

local mode_x = { -368, -184, 0, 184, 368 }
for i = 1, 5 do
	widget_definitions["mode_" .. i] = button_widget("mode_sg_" .. i, mode_x[i], -276, 180, 40)
end

widget_definitions.act_close = button_widget("act_close_sg", 0, 260, 180, 44)
widget_definitions.info = text_widget("info_sg", 0, 306, CONTENT_W - 60, 26, 18, "center")

local tab_x = { -390, -234, -78, 78, 234, 390 }
for i = 1, 6 do
	widget_definitions["tab_" .. i] = button_widget("tab_sg_" .. i, tab_x[i], -230, 150, 40)
end
for i = 1, SLOTS do
	local col = (i - 1) % COLS
	local row = math.floor((i - 1) / COLS)
	widget_definitions["slot_" .. i] = slot_button_widget("slot_sg_" .. i, COL_X[col + 1], GRID_TOP + row * ROW_STEP, BTN_W, BTN_H)
end
widget_definitions.page_prev  = button_widget("page_prev_sg", -210, 92, 150, 38)
widget_definitions.page_label = text_widget("page_sg", 0, 92, 240, 28, 20, "center")
widget_definitions.page_next  = button_widget("page_next_sg", 210, 92, 150, 38)

widget_definitions.mode       = button_widget("mode_row_sg",  -232, 136, 200, 42)
widget_definitions.count_dec  = button_widget("count_dec_sg",  -99, 136, 46, 42)
widget_definitions.count_val  = text_widget("count_val_sg",    -16, 136, 100, 42, 20, "center")
widget_definitions.count_inc  = button_widget("count_inc_sg",   67, 136, 46, 42)
widget_definitions.spread_dec = button_widget("spread_dec_sg", 123, 136, 46, 42)
widget_definitions.spread_val = text_widget("spread_val_sg",   216, 136, 120, 42, 20, "center")
widget_definitions.spread_inc = button_widget("spread_inc_sg", 309, 136, 46, 42)

widget_definitions.t_aim       = button_widget("t_aim_sg",       -310, 182, 150, 42)
widget_definitions.spawn       = button_widget("spawn_sg",       -155, 182, 140, 42)
widget_definitions.clear       = button_widget("clear_sg",        -20, 182, 110, 42)
widget_definitions.queue_keep  = button_widget("queue_keep_sg",   120, 182, 150, 42)
widget_definitions.spawn_close = button_widget("spawn_close_sg",   295, 182, 180, 42)

local g_col = { -250, 0, 250 }
widget_definitions.g_all        = button_widget("g_all_sg",        g_col[1], -145, 230, 48)
widget_definitions.g_toughness  = button_widget("g_toughness_sg",  g_col[2], -145, 230, 48)
widget_definitions.g_health     = button_widget("g_health_sg",     g_col[3], -145, 230, 48)
widget_definitions.g_ammo       = button_widget("g_ammo_sg",       g_col[1],  -91, 230, 48)
widget_definitions.g_magazine   = button_widget("g_magazine_sg",   g_col[2],  -91, 230, 48)
widget_definitions.g_ability    = button_widget("g_ability_sg",    g_col[3],  -91, 230, 48)
widget_definitions.g_blitz      = button_widget("g_blitz_sg",      g_col[1],  -37, 230, 48)
widget_definitions.g_stamina    = button_widget("g_stamina_sg",    g_col[2],  -37, 230, 48)
widget_definitions.g_dodge      = button_widget("g_dodge_sg",      g_col[3],  -37, 230, 48)
widget_definitions.g_invuln     = button_widget("g_invuln_sg",     g_col[1],   17, 230, 48)
widget_definitions.g_peril_gain = button_widget("g_peril_gain_sg", g_col[2],   17, 230, 48)
widget_definitions.g_peril_death= button_widget("g_peril_death_sg",g_col[3],   17, 230, 48)

widget_definitions.g_refill     = button_widget("g_refill_sg",     g_col[1],   71, 230, 48)

local p_col = { -250, 0, 250 }
for i = 1, 6 do
	local c = (i - 1) % 3
	local r = math.floor((i - 1) / 3)
	widget_definitions["preset_" .. i] = button_widget("preset_sg_" .. i, p_col[c + 1], -150 + r * 58, 230, 50)
end
local tr_x = { -345, -115, 115, 345 }
for i = 1, 4 do
	widget_definitions["trial_" .. i] = button_widget("trial_sg_" .. i, tr_x[i], -20, 220, 48)
end
widget_definitions.wave_start = button_widget("wave_start_sg", -258, 46, 160, 46)
widget_definitions.wave_stop  = button_widget("wave_stop_sg",  -101, 46, 130, 46)
widget_definitions.wave_next  = button_widget("wave_next_sg",    56, 46, 160, 46)
widget_definitions.wave_auto  = button_widget("wave_auto_sg",   243, 46, 190, 46)
widget_definitions.wave_label = text_widget("wave_label_sg", 0, 104, 700, 30, 20, "center")

local misc_buttons = {
	"m_muffler", "m_killall", "m_ai", "m_nodef", "m_respawn", "m_whisper",
	"m_noprops", "m_continuous", "m_swap", "m_immortal", "m_invis", "m_reset",
	"m_nostagger",
}
local misc_col = { -160, 160 }
for i = 1, #misc_buttons do
	local c = (i - 1) % 2
	local r = math.floor((i - 1) / 2)
	widget_definitions[misc_buttons[i]] = button_widget(misc_buttons[i] .. "_sg", misc_col[c + 1], -176 + r * 58, 300, 50)
end

widget_definitions.queue_title = text_widget("queue_title_sg", 0, -298, QUEUE_W - 20, 30, 20, "center", "queue")
local QUEUE_ROWS = 12
for i = 1, QUEUE_ROWS do
	local y = -262 + (i - 1) * 34
	widget_definitions["queue_row_" .. i]   = queue_row_widget("queue_row_sg_" .. i, y)
	widget_definitions["queue_minus_" .. i] = queue_small_btn("queue_minus_sg_" .. i, 78, y, "-")
	widget_definitions["queue_plus_" .. i]  = queue_small_btn("queue_plus_sg_" .. i, 105, y, "+")
	widget_definitions["queue_x_" .. i]     = queue_small_btn("queue_x_sg_" .. i, 132, y, "X", 15)
end
widget_definitions.queue_hint = text_widget("queue_hint_sg", 0, 150, QUEUE_W - 20, 22, 13, "center", "queue")
widget_definitions.queue_more = text_widget("queue_more_sg", 0, 176, QUEUE_W - 20, 22, 15, "center", "queue")

widget_definitions.stats_title = text_widget("stats_title_sg", 0, -298, STATS_W - 20, 28, 20, "center", "stats")
widget_definitions.stats_name  = text_widget("stats_name_sg",  0, -262, STATS_W - 20, 26, 18, "center", "stats")

widget_definitions.z_head    = zone_widget("z_head_sg",     0, -208, 40, 36)
widget_definitions.z_chest   = zone_widget("z_chest_sg",    0, -160, 74, 50)
widget_definitions.z_belly   = zone_widget("z_belly_sg",    0, -120, 60, 28)
widget_definitions.z_larm_up = zone_widget("z_larm_up_sg", -52, -158, 22, 44)
widget_definitions.z_larm_lo = zone_widget("z_larm_lo_sg", -52, -108, 20, 48)
widget_definitions.z_rarm_up = zone_widget("z_rarm_up_sg",  52, -158, 22, 44)
widget_definitions.z_rarm_lo = zone_widget("z_rarm_lo_sg",  52, -108, 20, 48)
widget_definitions.z_lleg_up = zone_widget("z_lleg_up_sg", -19,  -82, 30, 46)
widget_definitions.z_lleg_lo = zone_widget("z_lleg_lo_sg", -19,  -28, 28, 54)
widget_definitions.z_rleg_up = zone_widget("z_rleg_up_sg",  19,  -82, 30, 46)
widget_definitions.z_rleg_lo = zone_widget("z_rleg_lo_sg",  19,  -28, 28, 54)

for i = 1, 4 do
	widget_definitions["ex_sw_" .. i] = zone_widget("ex_sw_sg_" .. i, 74, -150 + (i - 1) * 36, 16, 16)
	widget_definitions["ex_tx_" .. i] = text_widget("ex_tx_sg_" .. i, 116, -150 + (i - 1) * 36, 60, 20, 12, "left", "stats")
end

for i = 1, 8 do
	widget_definitions["nz_" .. i] = text_widget("nz_sg_" .. i, 0, -196 + (i - 1) * 26, STATS_W - 30, 24, 16, "center", "stats")
end

widget_definitions.stats_health = text_widget("stats_health_sg", 0, 30, STATS_W - 20, 26, 18, "center", "stats")

local legend_col = { -70, 70 }
for i = 1, 8 do
	local c = (i - 1) % 2
	local r = math.floor((i - 1) / 2)
	widget_definitions["legend_" .. i] = text_widget("legend_sg_" .. i, legend_col[c + 1], 72 + r * 30, 130, 24, 15, "center", "stats")
end
widget_definitions.stats_hint = text_widget("stats_hint_sg", 0, -110, STATS_W - 30, 120, 15, "center", "stats")

return {
	widget_definitions = widget_definitions,
	scenegraph_definition = scenegraph_definition,
	QUEUE_ROWS = QUEUE_ROWS,
}
