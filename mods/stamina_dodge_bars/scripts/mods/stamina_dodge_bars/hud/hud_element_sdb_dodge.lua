-- Stamina & Dodge Bars - dodge bar element.
-- Dodge-counting logic (effective dodges, decrement, negative tracking, cooldown reset, Agile
-- trait) is ported from "Show Remaining Dodges" by mrouzon and contributors; it lives in the main
-- script and updates mod._effective_dodges / mod._effective_dodges_left, which this element reads.
-- The orientation / bracket rendering is ported from "Keystone & Blitz Bars".

local mod = get_mod("stamina_dodge_bars")

local Definitions = mod:io_dofile("stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_definitions")
local HudElementSdbSettings = mod:io_dofile("stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local HudElementSdbDodge = class("HudElementSdbDodge", "HudElementBase")

-- Y positions for the bottom-most segment when drawn vertically, keyed by segment count.
-- (Ported from Keystone & Blitz Bars; dodge counts are usually 2-6, up to ~8 with curios.)
local Y_OFFSETS = {
	[1] = 294, [2] = 192, [3] = 158, [4] = 140.5, [5] = 131,
	[6] = 123.5, [7] = 120, [8] = 117, [9] = 114.5, [10] = 108
}
local function y_offset(n)
	return Y_OFFSETS[n] or 108
end

local function resolve_color(setting_id, fallback_name, alpha)
	local name = mod:get(setting_id) or fallback_name
	local color_fn = Color[name] or Color[fallback_name]
	if color_fn then
		return color_fn(alpha or 255, true)
	end
	return { alpha or 255, 255, 255, 255 }
end

HudElementSdbDodge.init = function (self, parent, draw_layer, start_scale)
	self._bar_kind = "dodge"
	self._definitions = Definitions.build("dodge")

	HudElementSdbDodge.super.init(self, parent, draw_layer, start_scale, self._definitions)

	self._dodges = {}
	self._dodge_width = 0
	self._dodge_amount = nil
	self._bar_widget = self:_create_widget("bar", self._definitions.bar_definition)

	local gauge_widget = self._widgets_by_name.gauge
	if gauge_widget then
		gauge_widget.content.name_text = Utf8.upper(mod:localize("dodge_bar_name"))
	end

	self:_update_text_offsets()
end

HudElementSdbDodge.destroy = function (self, ui_renderer)
	if ui_renderer and self._bar_widget then
		UIWidget.destroy(ui_renderer, self._bar_widget)
		self._bar_widget = nil
	end
	HudElementSdbDodge.super.destroy(self, ui_renderer)
end

HudElementSdbDodge._add_dodge = function (self)
	self._dodges[#self._dodges + 1] = {}
end

HudElementSdbDodge._remove_dodge = function (self)
	self._dodges[#self._dodges] = nil
end

HudElementSdbDodge.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementSdbDodge.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	-- Establish the dodge count from mission start so the bar shows immediately with "always show",
	-- not only after the first dodge. (The dodge/slide/weapon-swap hooks keep it current afterwards.)
	if mod.ensure_effective_dodges then
		mod.ensure_effective_dodges()
	end

	local gauge = self._widgets_by_name.gauge
	if gauge and mod._value_text_color then
		gauge.style.value_text.text_color = mod._value_text_color
		gauge.style.name_text.text_color = mod._gauge_color
		gauge.style.warning.color = mod._gauge_color
	end

	self:_update_dodge_amount()
	self:_update_visibility(dt)

	-- Consecutive-dodge cooldown bookkeeping (ported from Show Remaining Dodges).
	mod._unified_t = t
	if mod._consecutive_dodges_cooldown < t and mod._waiting_for_dodge_effectiveness_reset and not mod._dodging then
		mod._waiting_for_dodge_effectiveness_reset = false
		mod._effective_dodges_left = mod._effective_dodges
		mod._draw_widget = false
	end
end

HudElementSdbDodge._update_dodge_amount = function (self)
	local dodge_amount = mod._effective_dodges or 0

	if dodge_amount ~= self._dodge_amount then
		local amount_difference = (self._dodge_amount or 0) - dodge_amount
		self._dodge_amount = dodge_amount

		self:_resize()

		local add_dodges = amount_difference < 0
		for _ = 1, math.abs(amount_difference) do
			if add_dodges then
				self:_add_dodge()
			else
				self:_remove_dodge()
			end
		end
	end
end

HudElementSdbDodge._update_visibility = function (self, dt)
	if not mod._dodge_show or mod._is_in_hub() then
		self._alpha_multiplier = 0
		return
	end

	local has_dodges = mod._effective_dodges and mod._effective_dodges > 0

	if mod._dodge_always_show then
		self._alpha_multiplier = has_dodges and 1 or 0
		return
	end

	local draw = mod._draw_widget and has_dodges
	local alpha_speed = mod._dodge_fade_speed or 4
	local alpha_multiplier = self._alpha_multiplier or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._alpha_multiplier = alpha_multiplier
end

HudElementSdbDodge._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if self._alpha_multiplier == 0 then return end

	local previous_alpha_multiplier = render_settings.alpha_multiplier
	render_settings.alpha_multiplier = self._alpha_multiplier

	HudElementSdbDodge.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
	self:_draw_dodges(dt, t, ui_renderer)

	render_settings.alpha_multiplier = previous_alpha_multiplier
end

HudElementSdbDodge._draw_dodges = function (self, dt, t, ui_renderer)
	local num_dodges = self._dodge_amount
	if not num_dodges or num_dodges < 1 then return end

	local widget = self._bar_widget
	local widget_offset = widget.offset
	local dodge_width = self._dodge_width
	local spacing = HudElementSdbSettings.spacing

	-- How many segments are "filled", and the value-text number.
	local effective_left = mod._effective_dodges_left or 0
	local dodges_left = effective_left
	if not mod._dodge_show_negative and dodges_left < 0 then
		dodges_left = 0
	end

	local gauge_widget = self._widgets_by_name.gauge
	if gauge_widget then
		gauge_widget.content.value_text = mod._dodge_show_counter and string.format("%d", dodges_left) or ""
		gauge_widget.content.name_text = mod._dodge_show_name and Utf8.upper(mod:localize("dodge_bar_name")) or ""
	end

	local view_dodges_left = dodges_left < 0 and (dodges_left * -1) or dodges_left

	local color_full     = resolve_color("dodge_color_full", "ui_green_light", 255)
	local color_negative = resolve_color("dodge_color_negative", "ui_interaction_critical", 255)
	local color_empty    = resolve_color("dodge_color_empty", "ui_green_medium", 100)

	local offset
	if self._horizontal then
		offset = (dodge_width + spacing) * (num_dodges - 1) * 0.5
	else
		offset = y_offset(num_dodges)
	end

	for i = num_dodges, 1, -1 do
		local dodge = self._dodges[i]
		if not dodge then return end

		local is_full = i <= view_dodges_left

		local active_color
		if not is_full then
			active_color = color_empty
		elseif effective_left >= 0 then
			active_color = color_full
		else
			active_color = color_negative
		end

		local widget_color = widget.style.full.color
		widget_color[1] = active_color[1]
		widget_color[2] = active_color[2]
		widget_color[3] = active_color[3]
		widget_color[4] = active_color[4]

		if self._horizontal then
			widget_offset[1] = offset
			widget_offset[2] = self._flipped and 2 or 1
			offset = offset - dodge_width - spacing
		else
			local scenegraph_size = self:scenegraph_size("bar")
			widget_offset[1] = 0
			widget_offset[2] = scenegraph_size.y - offset
			offset = offset - dodge_width - spacing
		end

		UIWidget.draw(widget, ui_renderer)
	end
end

HudElementSdbDodge._resize = function (self)
	local amount = self._dodge_amount or 0
	local bar_size = HudElementSdbSettings.bar_size
	local spacing = HudElementSdbSettings.spacing
	local total_spacing = spacing * math.max(amount - 1, 0)
	local total_bar_length = bar_size[1] - total_spacing

	self._dodge_width = math.round(amount > 0 and total_bar_length / amount or total_bar_length)
	local segment_height = 9

	local orientation = mod:get("dodge_orientation") or mod.orientation_options["orientation_option_horizontal"]
	local horizontal = orientation == mod.orientation_options["orientation_option_horizontal"] or
		orientation == mod.orientation_options["orientation_option_horizontal_flipped"]
	self._horizontal = horizontal
	self._flipped = orientation == mod.orientation_options["orientation_option_horizontal_flipped"] or
		orientation == mod.orientation_options["orientation_option_vertical_flipped"]

	local width  = horizontal and self._dodge_width or segment_height
	local height = horizontal and segment_height or self._dodge_width
	self:_set_scenegraph_size("bar", width, height)

	self:_update_text_offsets()
end

HudElementSdbDodge._update_text_offsets = function (self)
	local widget = self._widgets_by_name.gauge
	if not widget then return end

	local orientation = mod:get("dodge_orientation") or mod.orientation_options["orientation_option_horizontal"]

	local styles = {
		orientation_option_horizontal = {
			value_h = "right", value_offset = { 0, 10, 3 },
			name_h = "left", name_offset = { 0, 10, 3 }, angle = 0
		},
		orientation_option_horizontal_flipped = {
			value_h = "right", value_offset = { 0, -30, 3 },
			name_h = "left", name_offset = { 0, -30, 3 }, angle = math.pi
		},
		orientation_option_vertical = {
			value_h = "right", value_offset = { -118, -86, 3 },
			name_h = "right", name_offset = { -118, -104, 3 }, angle = (math.pi * 3) / 2
		},
		orientation_option_vertical_flipped = {
			value_h = "left", value_offset = { 118, -86, 3 },
			name_h = "left", name_offset = { 118, -104, 3 }, angle = math.pi / 2
		}
	}
	local s = styles[orientation] or styles.orientation_option_horizontal

	local value_text_style = widget.style.value_text
	value_text_style.horizontal_alignment = s.value_h
	value_text_style.text_horizontal_alignment = s.value_h
	value_text_style.offset = s.value_offset

	local name_text_style = widget.style.name_text
	name_text_style.horizontal_alignment = s.name_h
	name_text_style.text_horizontal_alignment = s.name_h
	name_text_style.offset = s.name_offset

	widget.style.warning.angle = s.angle
end

return HudElementSdbDodge
