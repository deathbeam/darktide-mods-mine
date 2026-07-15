local mod = get_mod("stamina_dodge_bars")

local HudElementSdbSettings = mod:io_dofile("stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_settings")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")

local bar_size = HudElementSdbSettings.bar_size
local area_size = HudElementSdbSettings.area_size
local center_offset = HudElementSdbSettings.center_offset

-- Builds a fresh set of definitions for one bar instance ("stamina" or "dodge"),
-- positioned with that bar's own default offset so both are visible side by side
-- out of the box. Reposition freely with a HUD-editing mod (each bar is its own element).
local function build(bar_kind)
	local offset_x = 0
	local offset_y = bar_kind == "dodge" and 26 or 0

	local scenegraph_definition = {
		screen = UIWorkspaceSettings.screen,
		area = {
			vertical_alignment = "center",
			parent = "screen",
			horizontal_alignment = "center",
			size = area_size,
			position = {
				0 + offset_x,
				center_offset + offset_y,
				0
			}
		},
		gauge = {
			vertical_alignment = "top",
			parent = "area",
			horizontal_alignment = "center",
			size = {
				212,
				10
			},
			position = {
				0,
				6,
				1
			}
		},
		bar = {
			vertical_alignment = "top",
			parent = "area",
			horizontal_alignment = "center",
			size = bar_size,
			position = {
				0,
				0,
				1
			}
		}
	}

	local value_text_style = table.clone(UIFontSettings.body_small)
	value_text_style.offset = { 0, 10, 3 }
	value_text_style.size = { 500, 30 }
	value_text_style.vertical_alignment = "top"
	value_text_style.horizontal_alignment = "right"
	value_text_style.text_vertical_alignment = "top"
	value_text_style.text_horizontal_alignment = "right"
	value_text_style.text_color = UIHudSettings.color_tint_main_1

	local name_text_style = table.clone(value_text_style)
	name_text_style.offset = { 0, 10, 3 }
	name_text_style.horizontal_alignment = "left"
	name_text_style.text_horizontal_alignment = "left"
	name_text_style.text_color = UIHudSettings.color_tint_main_2
	name_text_style.drop_shadow = false

	local widget_definitions = {
		gauge = UIWidget.create_definition({
			{
				value_id = "value_text",
				style_id = "value_text",
				pass_type = "text",
				value = "",
				style = value_text_style
			},
			{
				value_id = "name_text",
				style_id = "name_text",
				pass_type = "text",
				value = "", -- set per-instance in init
				style = name_text_style
			},
			{
				value = "content/ui/materials/hud/stamina_gauge",
				style_id = "warning",
				pass_type = "rotated_texture",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					offset = { 0, 0, 1 },
					size = { 212, 10 },
					pivot = { 212 / 2, 0 },
					angle = 0,
					color = UIHudSettings.color_tint_main_2
				}
			}
		}, "gauge")
	}

	local bar = UIWidget.create_definition({
		{
			value = "content/ui/materials/hud/stamina_full",
			style_id = "full",
			pass_type = "rect",
			style = {
				offset = { 0, 0, 3 },
				color = UIHudSettings.color_tint_main_1
			}
		}
	}, "bar")

	return {
		bar_definition = bar,
		widget_definitions = widget_definitions,
		scenegraph_definition = scenegraph_definition
	}
end

return {
	build = build
}
