require("scripts/foundation/utilities/color")

local mod = get_mod("ModPerformanceMonitor")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local ConstantElementModPerf = class("ConstantElementModPerf", "ConstantElementBase")

local MAX_LINES = 46
local MAX_CELLS = 6
local GRAPH_BARS = 120
local GRAPH_H = 70
local BAR_W = 3
local TAB_COUNT = 5
local TAB_W = 88
local TAB_H = 26
local PANEL_SIZE = { 1400, 1400 }

local C_BAR_HI  = { 255, 244, 96, 96 }
local C_BAR_MID = { 255, 245, 190, 92 }
local C_BAR_LO  = { 255, 138, 210, 150 }
local C_ACCENT  = { 255, 120, 205, 255 }
local C_DIM     = { 255, 150, 156, 172 }

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	container = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = PANEL_SIZE,
		position = { 0, 0, 1 },
	},
}
for i = 1, TAB_COUNT do
	scenegraph_definition["tab_" .. i] = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = { TAB_W, TAB_H },
		position = { 40 + (i - 1) * TAB_W, -100, 20 },
	}
end

local function text_pass(align, size)
	return {
		value_id = "text",
		value = "",
		style_id = "text",
		pass_type = "text",
		style = {
			text_color = { 255, 226, 228, 234 },
			font_size = 18,
			drop_shadow = true,
			font_type = "arial",
			word_wrap = false,
			size = size or { 600, 40 },
			text_horizontal_alignment = align or "left",
			text_vertical_alignment = "top",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = { 0, 0, 10 },
		},
	}
end

local widget_definitions = {
	bg = UIWidget.create_definition({
		{ pass_type = "rect", style_id = "panel", style = { color = { 205, 12, 14, 20 }, size = { 0, 0 }, offset = { 0, 0, 0 } } },
	}, "container"),
	tab_underline = UIWidget.create_definition({
		{ pass_type = "rect", style_id = "rect", style = { color = { 255, 120, 205, 255 }, size = { 0, 0 }, offset = { 0, 0, 19 } } },
	}, "container"),
	graph_title = UIWidget.create_definition({ text_pass() }, "container"),
	graph_refline = UIWidget.create_definition({
		{ pass_type = "rect", style_id = "rect", style = { color = { 110, 245, 190, 92 }, size = { 0, 0 }, offset = { 0, 0, 8 } } },
	}, "container"),
}

for i = 1, MAX_LINES do
	for k = 1, MAX_CELLS do
		widget_definitions["cell_" .. i .. "_" .. k] = UIWidget.create_definition({ text_pass() }, "container")
	end
end

for i = 1, GRAPH_BARS do
	widget_definitions["bar_" .. i] = UIWidget.create_definition({
		{ pass_type = "rect", style_id = "bar", style = { color = { 255, 120, 200, 255 }, size = { 0, 0 }, offset = { 0, 0, 9 } } },
	}, "container")
end

for i = 1, TAB_COUNT do
	widget_definitions["tab_" .. i] = UIWidget.create_definition({
		text_pass("center", { TAB_W, TAB_H }),
	}, "tab_" .. i)
end

ConstantElementModPerf.init = function(self, parent, draw_layer, start_scale)
	ConstantElementModPerf.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
end

ConstantElementModPerf.should_draw = function(self)
	local m = get_mod("ModPerformanceMonitor")
	return m ~= nil and m._overlay_on == true
end
ConstantElementModPerf.should_update = function(self)
	local m = get_mod("ModPerformanceMonitor")
	return m ~= nil and m._overlay_on == true
end

local function hide_graph(self)
	self._widgets_by_name.graph_title.content.text = ""
	local rl = self._widgets_by_name.graph_refline.style.rect
	rl.size[1], rl.size[2] = 0, 0
	for i = 1, GRAPH_BARS do
		local st = self._widgets_by_name["bar_" .. i].style.bar
		st.size[1], st.size[2] = 0, 0
	end
end

local function draw_graph(self, gx, gy, font, inner_w, line_h)
	local m = get_mod("ModPerformanceMonitor")
	if not m then hide_graph(self); return 0 end
	local okg, g = pcall(m.get_graph)
	g = okg and g or nil
	if not (g and g.n >= 2) then
		hide_graph(self)
		return 0
	end

	local gt = self._widgets_by_name.graph_title
	gt.content.text = g.title
	gt.style.text.font_size = math.max(11, font - 4)
	gt.style.text.offset[1], gt.style.text.offset[2] = gx, gy
	gt.style.text.size[1] = inner_w

	local title_h = line_h
	local nb = math.min(g.n, math.floor(inner_w / BAR_W))
	local start = g.n - nb + 1
	local baseline = gy + title_h + GRAPH_H
	local ceil = (g.ceiling and g.ceiling > 0) and g.ceiling or (g.max > 0 and g.max or 0.0001)

	for i = 1, GRAPH_BARS do
		local st = self._widgets_by_name["bar_" .. i].style.bar
		local si = start + (i - 1)
		if i <= nb and si >= 1 and si <= g.n then
			local val = g.vals[si]
			local frac = val / ceil
			if frac > 1 then frac = 1 end
			local h = frac * GRAPH_H
			if h < 1 then h = 1 end
			st.size[1], st.size[2] = BAR_W - 1, h
			st.offset[1] = gx + (i - 1) * BAR_W
			st.offset[2] = baseline - h
			local hi = g.hi or 1e9
			local mid = g.mid or 1e9
			st.color = (val >= hi) and C_BAR_HI or ((val >= mid) and C_BAR_MID or C_BAR_LO)
		else
			st.size[1], st.size[2] = 0, 0
		end
	end

	local rl = self._widgets_by_name.graph_refline.style.rect
	if g.mid and g.mid < ceil then
		local ry = baseline - (g.mid / ceil) * GRAPH_H
		rl.size[1], rl.size[2] = nb * BAR_W, 1
		rl.offset[1], rl.offset[2] = gx, ry
		rl.color[1] = 110
	else
		rl.size[1], rl.size[2] = 0, 0
	end

	return title_h + GRAPH_H + 10
end

local function clear_cells(self, wi)
	for k = 1, MAX_CELLS do
		self._widgets_by_name["cell_" .. wi .. "_" .. k].content.text = ""
	end
end

local function render_panel(self)
	local mod = get_mod("ModPerformanceMonitor")
	if not mod then return end
	local ok, view = pcall(mod.get_view)
	local lines = (ok and view and view.lines) or {}

	local font = mod.get_overlay_font_size()
	local title_font = font + 6
	local line_h = font * 1.34
	local pad = 14
	local ox, oy = mod.get_overlay_offset()
	local panel_w = math.min(PANEL_SIZE[1], mod.get_overlay_width())
	local inner_w = panel_w - pad * 2

	pcall(function()
		local tabs, active = mod.get_tabs()
		local tab_font = math.max(12, font - 3)
		local active_idx = 1
		for i = 1, TAB_COUNT do
			local w = self._widgets_by_name["tab_" .. i]
			local tb = tabs and tabs[i]
			if tb then
				self:set_scenegraph_position("tab_" .. i, ox + (i - 1) * TAB_W, oy, 20, "left", "top")
				w.content.text = tb.label
				local st = w.style.text
				st.font_size = tab_font
				st.text_color = (tb.id == active) and C_ACCENT or C_DIM
				if tb.id == active then active_idx = i end
			else
				w.content.text = ""
			end
		end
		local ul = self._widgets_by_name.tab_underline.style.rect
		ul.size[1], ul.size[2] = TAB_W - 22, 2
		ul.offset[1], ul.offset[2] = ox + (active_idx - 1) * TAB_W + 11, oy + TAB_H - 3
		ul.color[1] = 255
	end)

	local y = oy + TAB_H + 8
	local wi = 0
	local graph_drawn = false
	for li = 1, #lines do
		local l = lines[li]
		if l.graph then
			graph_drawn = true
			y = y + draw_graph(self, ox, y, font, inner_w, line_h)
		else
			wi = wi + 1
			if wi <= MAX_LINES then
				local cells = l.cells or {}
				local tw = 0
				for _, c in ipairs(cells) do tw = tw + (c.w or 1) end
				if tw <= 0 then tw = 1 end
				local x = 0
				for k = 1, MAX_CELLS do
					local cw = self._widgets_by_name["cell_" .. wi .. "_" .. k]
					local c = cells[k]
					if c then
						local slot_w = inner_w * (c.w or 1) / tw
						local st = cw.style.text
						cw.content.text = c.t
						st.text_color = l.color
						st.font_size = l.big and title_font or font
						st.text_horizontal_alignment = c.a or "left"
						st.offset[1], st.offset[2] = ox + x, y
						st.size[1] = slot_w
						x = x + slot_w
					else
						cw.content.text = ""
					end
				end
				y = y + line_h
			end
		end
	end
	for j = wi + 1, MAX_LINES do
		clear_cells(self, j)
	end
	if not graph_drawn then hide_graph(self) end

	local panel_h = (y - oy) + pad * 2
	local panel = self._widgets_by_name.bg.style.panel
	if #lines > 0 then
		panel.color[1] = 205
		panel.size[1], panel.size[2] = panel_w, panel_h
		panel.offset[1], panel.offset[2] = ox - pad, oy - pad
	else
		panel.color[1], panel.size[1], panel.size[2] = 0, 0, 0
	end
end

ConstantElementModPerf.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	ConstantElementModPerf.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	pcall(render_panel, self)
end

return ConstantElementModPerf
