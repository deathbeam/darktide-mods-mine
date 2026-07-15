-- Stamina & Dodge Bars - stamina bar element.
-- Reads live stamina via scripts/utilities/attack/stamina (current + max), draws KBB-style
-- segments (one per stamina point) with a smooth fractional fill, and recolours the bar by
-- current-stamina threshold (approach borrowed from "Color My Stamina"). Orientation/bracket
-- rendering matches the dodge element.

local mod = get_mod("stamina_dodge_bars")

local Definitions = mod:io_dofile("stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_definitions")
local HudElementSdbSettings = mod:io_dofile("stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Stamina = mod:original_require("scripts/utilities/attack/stamina")

local HudElementSdbStamina = class("HudElementSdbStamina", "HudElementBase")

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

-- Whole-bar colour chosen by current stamina percentage (Color My Stamina style).
local function threshold_color(percent)
	if percent > 75 then
		return resolve_color("stamina_color_high", "ui_green_light", 255)
	elseif percent > 50 then
		return resolve_color("stamina_color_mid_high", "ui_hud_yellow_super_light", 255)
	elseif percent > 25 then
		return resolve_color("stamina_color_mid_low", "ui_hud_yellow_medium", 255)
	end
	return resolve_color("stamina_color_low", "ui_interaction_critical", 255)
end

HudElementSdbStamina.init = function (self, parent, draw_layer, start_scale)
	self._bar_kind = "stamina"
	self._definitions = Definitions.build("stamina")

	HudElementSdbStamina.super.init(self, parent, draw_layer, start_scale, self._definitions)

	self._segments = {}
	self._segment_width = 0
	self._segment_amount = nil
	self._current_stamina = 0
	self._max_stamina = 0
	self._bar_widget = self:_create_widget("bar", self._definitions.bar_definition)

	local gauge_widget = self._widgets_by_name.gauge
	if gauge_widget then
		gauge_widget.content.name_text = Utf8.upper(mod:localize("stamina_bar_name"))
	end

	self:_update_text_offsets()
end

HudElementSdbStamina.destroy = function (self, ui_renderer)
	if ui_renderer and self._bar_widget then
		UIWidget.destroy(ui_renderer, self._bar_widget)
		self._bar_widget = nil
	end
	HudElementSdbStamina.super.destroy(self, ui_renderer)
end

HudElementSdbStamina._add_segment = function (self)
	self._segments[#self._segments + 1] = {}
end

HudElementSdbStamina._remove_segment = function (self)
	self._segments[#self._segments] = nil
end

HudElementSdbStamina._read_stamina = function (self)
	local player = Managers.player and Managers.player:local_player(1)
	local unit = player and player.player_unit
	if not unit then return nil, nil end

	local unit_data = ScriptUnit.has_extension(unit, "unit_data_system")
	if not unit_data then return nil, nil end

	-- The BASE stamina template (which carries base_stamina) comes from the archetype, NOT the
	-- weapon's stamina_template(). current_and_max_value folds in weapon/buff modifiers itself.
	local archetype = unit_data:archetype()
	local stam_template = archetype and archetype.stamina
	if not stam_template then return nil, nil end

	local stamina_component = unit_data:read_component("stamina")
	if not stamina_component then return nil, nil end

	-- pcall-guarded: this runs every frame, so a future engine change must never hard-crash the load.
	local ok, current, max = pcall(Stamina.current_and_max_value, unit, stamina_component, stam_template)
	if not ok then return nil, nil end
	return current, max
end

HudElementSdbStamina.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementSdbStamina.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local gauge = self._widgets_by_name.gauge
	if gauge and mod._value_text_color then
		gauge.style.value_text.text_color = mod._value_text_color
		gauge.style.name_text.text_color = mod._gauge_color
		gauge.style.warning.color = mod._gauge_color
	end

	local current, max = self:_read_stamina()
	if current and max then
		self._current_stamina = current
		self._max_stamina = max
		self:_update_segment_amount(math.max(1, math.round(max)))
		self._has_stamina = true
	else
		self._has_stamina = false
	end

	self:_update_visibility(dt)
end

HudElementSdbStamina._update_segment_amount = function (self, amount)
	if amount ~= self._segment_amount then
		local amount_difference = (self._segment_amount or 0) - amount
		self._segment_amount = amount

		self:_resize()

		local add = amount_difference < 0
		for _ = 1, math.abs(amount_difference) do
			if add then
				self:_add_segment()
			else
				self:_remove_segment()
			end
		end
	end
end

HudElementSdbStamina._update_visibility = function (self, dt)
	if not mod._stamina_show or not self._has_stamina or mod._is_in_hub() then
		self._alpha_multiplier = 0
		return
	end

	if mod._stamina_always_show then
		self._alpha_multiplier = 1
		return
	end

	-- Not always-on: fade out while stamina is full, fade in once any has been spent.
	-- Use the REAL (fractional) max stamina, not the rounded segment count. Some melee weapons have
	-- a max like 2.82; round(max)=3 would mean current never reaches the segment count, so the bar
	-- would sit at ~94% forever, never read "full", and never fade out.
	local max = self._max_stamina or 0
	local full = self._current_stamina and max > 0 and (self._current_stamina / max) >= 0.999
	local speed = 4
	local a = self._alpha_multiplier or 0
	if full then
		a = math.max(a - dt * speed, 0)
	else
		a = math.min(a + dt * speed, 1)
	end
	self._alpha_multiplier = a
end

HudElementSdbStamina._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if self._alpha_multiplier == 0 then return end

	local previous_alpha_multiplier = render_settings.alpha_multiplier
	render_settings.alpha_multiplier = self._alpha_multiplier

	HudElementSdbStamina.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
	self:_draw_segments(dt, t, ui_renderer)

	render_settings.alpha_multiplier = previous_alpha_multiplier
end

HudElementSdbStamina._draw_segments = function (self, dt, t, ui_renderer)
	local num_segments = self._segment_amount
	if not num_segments or num_segments < 1 then return end

	local widget = self._bar_widget
	local widget_offset = widget.offset
	local segment_width = self._segment_width
	local spacing = HudElementSdbSettings.spacing

	local current = self._current_stamina or 0
	-- Percentage is against the real (fractional) max, so full stamina reads 100% (not ~94% on
	-- weapons whose max isn't a whole number) and the threshold colours map correctly.
	local max_stamina = self._max_stamina or 0
	local percent = max_stamina > 0 and (current / max_stamina) * 100 or 0

	local gauge_widget = self._widgets_by_name.gauge
	if gauge_widget then
		gauge_widget.content.value_text = mod._stamina_show_percentage and string.format("%d%%", math.round(percent)) or ""
		gauge_widget.content.name_text = mod._stamina_show_name and Utf8.upper(mod:localize("stamina_bar_name")) or ""
	end

	local color_full  = threshold_color(percent)
	local color_empty = resolve_color("stamina_color_empty", "ui_disabled_text_color", 100)

	local offset
	if self._horizontal then
		offset = (segment_width + spacing) * (num_segments - 1) * 0.5
	else
		offset = y_offset(num_segments)
	end

	for i = num_segments, 1, -1 do
		local segment = self._segments[i]
		if not segment then return end

		-- Each segment is 1 stamina point; fill it by how much of that point remains.
		local value = math.clamp(current - (i - 1), 0, 1)

		local widget_color = widget.style.full.color
		for e = 1, 4 do
			widget_color[e] = math.lerp(color_empty[e], color_full[e], value)
		end

		if self._horizontal then
			widget_offset[1] = offset
			widget_offset[2] = self._flipped and 2 or 1
			offset = offset - segment_width - spacing
		else
			local scenegraph_size = self:scenegraph_size("bar")
			widget_offset[1] = 0
			widget_offset[2] = scenegraph_size.y - offset
			offset = offset - segment_width - spacing
		end

		UIWidget.draw(widget, ui_renderer)
	end
end

HudElementSdbStamina._resize = function (self)
	local amount = self._segment_amount or 0
	local bar_size = HudElementSdbSettings.bar_size
	local spacing = HudElementSdbSettings.spacing
	local total_spacing = spacing * math.max(amount - 1, 0)
	local total_bar_length = bar_size[1] - total_spacing

	self._segment_width = math.round(amount > 0 and total_bar_length / amount or total_bar_length)
	local segment_height = 9

	local orientation = mod:get("stamina_orientation") or mod.orientation_options["orientation_option_horizontal"]
	local horizontal = orientation == mod.orientation_options["orientation_option_horizontal"] or
		orientation == mod.orientation_options["orientation_option_horizontal_flipped"]
	self._horizontal = horizontal
	self._flipped = orientation == mod.orientation_options["orientation_option_horizontal_flipped"] or
		orientation == mod.orientation_options["orientation_option_vertical_flipped"]

	local width  = horizontal and self._segment_width or segment_height
	local height = horizontal and segment_height or self._segment_width
	self:_set_scenegraph_size("bar", width, height)

	self:_update_text_offsets()
end

HudElementSdbStamina._update_text_offsets = function (self)
	local widget = self._widgets_by_name.gauge
	if not widget then return end

	local orientation = mod:get("stamina_orientation") or mod.orientation_options["orientation_option_horizontal"]

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

return HudElementSdbStamina
