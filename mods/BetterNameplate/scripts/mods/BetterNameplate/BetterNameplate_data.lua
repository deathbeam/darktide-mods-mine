local mod = get_mod("BetterNameplate")

local function create_font_options()
	local FontDefinitions = require("scripts/managers/ui/ui_fonts_definitions")
	local fonts = FontDefinitions.fonts or {}
	local options = {}

	for font_name, _ in pairs(fonts) do
		options[#options + 1] = { text = font_name, value = font_name }
	end

	table.sort(options, function(a, b)
		return a.value < b.value
	end)

	return options
end

local function create_color_options()
	local options = {}
	for i, color_name in ipairs(Color.list) do
		options[i] = { text = color_name, value = color_name }
	end

	table.sort(options, function(a, b)
		return a.value < b.value
	end)

	return options
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id  = "display_settings",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "only_icon_in_nameplate",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "no_icon_in_nameplate",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "class_name_in_nameplate",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "only_class_name_in_nameplate",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "only_icon_and_class_name_in_nameplate",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "reduce_screen_margin",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "enhanced_distance_scale",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "hide_off_screen_icon",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "show_in_close_range",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_in_smoke",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id      = "opacity_normal",
						type            = "numeric",
						default_value   = 1,
						range           = { 0, 1 },
						decimals_number = 2,
					},
					{
						setting_id    = "fade_when_aim",
						type          = "checkbox",
						default_value = true,
						sub_widgets   = {
							{
								setting_id      = "opacity_aim",
								type            = "numeric",
								default_value   = 0.5,
								range           = { 0, 1 },
								decimals_number = 2,
							},
						},
					},
				},
			},
			{
				setting_id  = "font_settings",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "override_font_size",
						type          = "checkbox",
						default_value = false,
						sub_widgets   = {
							{
								setting_id    = "font_size",
								type          = "numeric",
								default_value = 20,
								range         = { 0, 40 },
							},
						}
					},
					{
						setting_id    = "override_font_type",
						type          = "checkbox",
						default_value = false,
						sub_widgets   = {
							{
								setting_id    = "font_type",
								type          = "dropdown",
								default_value = "proxima_nova_bold",
								options       = create_font_options()
							},
						}
					},
					{
						setting_id    = "override_font_color",
						type          = "checkbox",
						default_value = false,
						sub_widgets   = {
							{
								setting_id    = "font_color",
								type          = "dropdown",
								default_value = "ui_hud_green_super_light",
								options       = create_color_options()
							},
						},
					},
				},
			},
		}
	}
}
