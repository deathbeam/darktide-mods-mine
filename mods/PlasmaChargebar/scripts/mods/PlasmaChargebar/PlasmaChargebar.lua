local mod = get_mod("PlasmaChargebar")

mod.version = "1.1.0"

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local BAR_WIDTH = 24
local BAR_HEIGHT = 56
local MASK_HEIGHT = BAR_HEIGHT - 4
local BAR_DISTANCE = 32
local TEXTURE_FRAME = "content/ui/materials/hud/crosshairs/charge_up"
local TEXTURE_MASK = "content/ui/materials/hud/crosshairs/charge_up_mask"
local CHARGE_ACTION = "action_charge"

local LEFT = "plasma_charge_left"
local RIGHT = "plasma_charge_right"
local MASK_LEFT = "plasma_charge_mask_left"
local MASK_RIGHT = "plasma_charge_mask_right"
local STYLE_IDS = {
	LEFT,
	RIGHT,
	MASK_LEFT,
	MASK_RIGHT,
}

local SKIP_CROSSHAIRS = {
	charge_up = true,
	charge_up_ads = true,
}

local function tint()
	local color = UIHudSettings.color_tint_main_1

	return {
		color[1],
		color[2],
		color[3],
		color[4],
	}
end

local function charge_passes()
	return {
		{
			pass_type = "texture_uv",
			style_id = LEFT,
			value = TEXTURE_FRAME,
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				visible = false,
				uvs = {
					{ 1, 0 },
					{ 0, 1 },
				},
				offset = { -BAR_DISTANCE, 0, 1 },
				size = { BAR_WIDTH, BAR_HEIGHT },
				color = tint(),
			},
		},
		{
			pass_type = "texture",
			style_id = RIGHT,
			value = TEXTURE_FRAME,
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				visible = false,
				offset = { BAR_DISTANCE, 0, 1 },
				size = { BAR_WIDTH, BAR_HEIGHT },
				color = tint(),
			},
		},
		{
			pass_type = "texture_uv",
			style_id = MASK_LEFT,
			value = TEXTURE_MASK,
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				visible = false,
				uvs = {
					{ 1, 0 },
					{ 0, 1 },
				},
				offset = { -BAR_DISTANCE, 0, 2 },
				size = { BAR_WIDTH, MASK_HEIGHT },
				color = tint(),
			},
		},
		{
			pass_type = "texture_uv",
			style_id = MASK_RIGHT,
			value = TEXTURE_MASK,
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				visible = false,
				uvs = {
					{ 0, 1 },
					{ 1, 0 },
				},
				offset = { BAR_DISTANCE, 0, 2 },
				size = { BAR_WIDTH, MASK_HEIGHT },
				color = tint(),
			},
		},
	}
end

local function inject_passes(element)
	local definitions = element._crosshair_widget_definitions

	if not definitions then
		return
	end

	for name, definition in pairs(definitions) do
		local style = definition and definition.style

		if not SKIP_CROSSHAIRS[name] and definition and not (style and style[LEFT]) then
			local passes = charge_passes()

			for i = 1, #passes do
				UIWidget.add_definition_pass(definition, passes[i])
			end
		end
	end

	element._plasma_charge_injected = true
	mod._element = element
end

local function rebuild_current_widget(element)
	local crosshair_type = element._crosshair_type

	if element._widget and crosshair_type then
		element:_unregister_widget_name(crosshair_type)

		element._widget = nil
	end

	element._crosshair_type = nil
end

local PLASMA_TEMPLATES = {}

local function is_plasma_template(name)
	local known = PLASMA_TEMPLATES[name]

	if known == nil then
		known = string.sub(name, 1, 9) == "plasmagun"
		PLASMA_TEMPLATES[name] = known
	end

	return known
end

local function plasma_charge(element)
	local parent = element._parent
	local player_extensions = parent and parent:player_extensions()

	if not player_extensions then
		return nil
	end

	local unit_data = player_extensions.unit_data

	if not unit_data then
		return nil
	end

	local weapon_action = unit_data:read_component("weapon_action")

	if not weapon_action or weapon_action.current_action_name ~= CHARGE_ACTION then
		return nil
	end

	local weapon_template = WeaponTemplate.current_weapon_template(weapon_action)
	local template_name = weapon_template and weapon_template.name

	if not template_name or not is_plasma_template(template_name) then
		return nil
	end

	local charge_component = unit_data:read_component("action_module_charge")

	if not charge_component then
		return nil
	end

	local charge_level = charge_component.charge_level or 0
	local max_charge = charge_component.max_charge or 0

	if max_charge <= 0 then
		max_charge = 1
	end

	local fraction = charge_level / max_charge

	if fraction < 0 then
		fraction = 0
	elseif fraction > 1 then
		fraction = 1
	end

	return fraction
end

local function hide_bars(element)
	local widget = element and element._widget
	local style = widget and widget.style

	if not style then
		return
	end

	for i = 1, #STYLE_IDS do
		local pass_style = style[STYLE_IDS[i]]

		if pass_style then
			pass_style.visible = false
		end
	end
end

local function update_bars(element)
	local widget = element._widget

	if not widget then
		return
	end

	local style = widget.style
	local left = style[LEFT]

	if not left then
		return
	end

	local right = style[RIGHT]
	local mask_left = style[MASK_LEFT]
	local mask_right = style[MASK_RIGHT]
	local fraction = plasma_charge(element)

	if not fraction then
		left.visible = false
		right.visible = false
		mask_left.visible = false
		mask_right.visible = false

		return
	end

	local distance = mod:get("bar_distance") or BAR_DISTANCE
	local filled_height = MASK_HEIGHT * fraction
	local filled_offset = MASK_HEIGHT * (1 - fraction) * 0.5

	left.visible = true
	left.offset[1] = -distance

	right.visible = true
	right.offset[1] = distance

	mask_left.visible = true
	mask_left.size[2] = filled_height
	mask_left.offset[1] = -distance
	mask_left.offset[2] = filled_offset
	mask_left.uvs[1][2] = 1 - fraction

	mask_right.visible = true
	mask_right.size[2] = filled_height
	mask_right.offset[1] = distance
	mask_right.offset[2] = filled_offset
	mask_right.uvs[1][2] = fraction
end

local hooks_installed = false

local function install_hooks()
	if hooks_installed then
		return
	end

	pcall(require, "scripts/ui/hud/elements/crosshair/hud_element_crosshair")

	local element_class = CLASS.HudElementCrosshair

	if not element_class then
		return
	end

	mod:hook_safe(element_class, "init", function(self)
		inject_passes(self)
	end)

	mod:hook_safe(element_class, "destroy", function(self)
		if mod._element == self then
			mod._element = nil
		end
	end)

	mod:hook_safe(element_class, "update", function(self)
		if not self._plasma_charge_injected then
			inject_passes(self)
			rebuild_current_widget(self)

			return
		end

		update_bars(self)
	end)

	hooks_installed = true
end

install_hooks()

mod.on_game_state_changed = function(status, state_name)
	install_hooks()
end

mod.on_disabled = function(initial_call)
	hide_bars(mod._element)
end

mod.on_enabled = function(initial_call)
	install_hooks()
end
