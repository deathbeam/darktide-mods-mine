local mod = get_mod("stamina_dodge_bars")

mod.orientation_options = table.enum(
	"orientation_option_horizontal",
	"orientation_option_horizontal_flipped",
	"orientation_option_vertical",
	"orientation_option_vertical_flipped"
)

local function list_options(enum)
	local options = {}
	for k, v in pairs(enum) do
		table.insert(options, { text = k, value = v })
	end
	return options
end

-- All engine colours (includes the Citadel range, etc.) - same full list Custom UI Colors uses.
local colors = {}
for _, color_name in ipairs(Color.list) do
	table.insert(colors, { text = color_name, value = color_name })
end
table.sort(colors, function(a, b) return a.text < b.text end)
local function get_colors()
	return table.clone(colors)
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "hide_vanilla",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "value_text_color",
				type = "dropdown",
				default_value = "ui_blue_light",
				options = get_colors()
			},
			{
				setting_id = "gauge_color",
				type = "dropdown",
				default_value = "terminal_text_body",
				options = get_colors()
			},
			{
				setting_id = "stamina_show",
				type = "checkbox",
				default_value = true,
				sub_widgets = {
					{
						setting_id = "stamina_orientation",
						type = "dropdown",
						default_value = mod.orientation_options["orientation_option_horizontal_flipped"],
						options = list_options(mod.orientation_options)
					},
					{
						setting_id = "stamina_show_percentage",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "stamina_show_name",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "stamina_always_show",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "stamina_color_high",
						type = "dropdown",
						default_value = "ui_blue_light",
						options = get_colors()
					},
					{
						setting_id = "stamina_color_mid_high",
						type = "dropdown",
						default_value = "ui_blue_light",
						options = get_colors()
					},
					{
						setting_id = "stamina_color_mid_low",
						type = "dropdown",
						default_value = "ui_blue_light",
						options = get_colors()
					},
					{
						setting_id = "stamina_color_low",
						type = "dropdown",
						default_value = "ui_blue_light",
						options = get_colors()
					},
					{
						setting_id = "stamina_color_empty",
						type = "dropdown",
						default_value = "ui_hud_red_light",
						options = get_colors()
					}
				}
			},
			{
				setting_id = "dodge_show",
				type = "checkbox",
				default_value = true,
				sub_widgets = {
					{
						setting_id = "dodge_orientation",
						type = "dropdown",
						default_value = mod.orientation_options["orientation_option_horizontal"],
						options = list_options(mod.orientation_options)
					},
					{
						setting_id = "dodge_show_counter",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "dodge_show_name",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "dodge_show_negative",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "dodge_always_show",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "dodge_color_full",
						type = "dropdown",
						default_value = "ui_blue_light",
						options = get_colors()
					},
					{
						setting_id = "dodge_color_empty",
						type = "dropdown",
						default_value = "item_rarity_dark_3",
						options = get_colors()
					},
					{
						setting_id = "dodge_color_negative",
						type = "dropdown",
						default_value = "ui_interaction_critical",
						options = get_colors()
					}
				}
			}
		}
	}
}
