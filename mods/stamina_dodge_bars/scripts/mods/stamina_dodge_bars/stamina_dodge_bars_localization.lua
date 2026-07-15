local mod = get_mod("stamina_dodge_bars")

local function cf(color_name)
	local color = Color[color_name](255, true)
	return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
end

local localizations = {
	mod_name = {
		en = "Stamina & Dodge Bars",
	},
	mod_description = {
		en = "Segmented stamina and dodge bars with per-bar orientation, custom colors, a dodge counter, and negative-dodge tracking.",
	},

	dodge_bar_name = {
		en = "Dodges",
	},
	stamina_bar_name = {
		en = "Stamina",
	},

	-- ##############################
	-- #          GENERAL           #
	-- ##############################
	hide_vanilla = {
		en = "Hide vanilla Stamina/Dodge HUD",
	},
	hide_vanilla_description = {
		en = "Hide the game's built-in stamina bar (and the dodge counter attached to it) so only these bars show. Turn off to keep the vanilla HUD.",
	},
	value_text_color = {
		en = "Value text color",
	},
	value_text_color_description = {
		en = "Color of the value text on both bars (stamina percentage and dodge count).",
	},
	gauge_color = {
		en = "Gauge color",
	},
	gauge_color_description = {
		en = "Color of the bar name labels and bracket on both bars.",
	},

	-- ##############################
	-- #          STAMINA           #
	-- ##############################
	stamina_show = {
		en = cf("ui_blue_light") .. "Stamina Bar{#reset()}",
	},
	stamina_show_description = {
		en = "Show a segmented stamina bar that recolors as stamina drops.",
	},
	stamina_orientation = {
		en = "Orientation",
	},
	stamina_orientation_description = {
		en = "Which way the bar (and its bracket) faces.",
	},
	stamina_show_percentage = {
		en = "Show percentage text",
	},
	stamina_show_percentage_description = {
		en = "Show current stamina as a percentage next to the bar.",
	},
	stamina_show_name = {
		en = "Show stamina text",
	},
	stamina_show_name_description = {
		en = "Show the STAMINA label next to the bar.",
	},
	stamina_always_show = {
		en = "Always show",
	},
	stamina_always_show_description = {
		en = "Keep the bar visible at all times instead of fading it out when stamina is full.",
	},
	stamina_color_high = {
		en = "Color above 75",
	},
	stamina_color_high_description = {
		en = "Bar color when stamina is above 75 percent.",
	},
	stamina_color_mid_high = {
		en = "Color 50 to 75",
	},
	stamina_color_mid_high_description = {
		en = "Bar color when stamina is between 50 and 75 percent.",
	},
	stamina_color_mid_low = {
		en = "Color 25 to 50",
	},
	stamina_color_mid_low_description = {
		en = "Bar color when stamina is between 25 and 50 percent.",
	},
	stamina_color_low = {
		en = "Color below 25",
	},
	stamina_color_low_description = {
		en = "Bar color when stamina is at or below 25 percent.",
	},
	stamina_color_empty = {
		en = "Spent color",
	},
	stamina_color_empty_description = {
		en = "Color of the spent (empty) portion of the bar.",
	},

	-- ##############################
	-- #           DODGE            #
	-- ##############################
	dodge_show = {
		en = cf("ui_hud_green_light") .. "Dodge Bar{#reset()}",
	},
	dodge_show_description = {
		en = "Show a segmented bar tracking your remaining effective dodges.",
	},
	dodge_orientation = {
		en = "Orientation",
	},
	dodge_orientation_description = {
		en = "Which way the bar (and its bracket) faces.",
	},
	dodge_show_counter = {
		en = "Show dodge counter",
	},
	dodge_show_counter_description = {
		en = "Show the remaining-dodge number next to the bar.",
	},
	dodge_show_name = {
		en = "Show dodge text",
	},
	dodge_show_name_description = {
		en = "Show the DODGES label next to the bar.",
	},
	dodge_show_negative = {
		en = "Show negative dodges",
	},
	dodge_show_negative_description = {
		en = "Keep counting past zero (into negatives) when you dodge more than your effective dodges, instead of stopping at 0. Over-dodged segments use the negative colour.",
	},
	dodge_always_show = {
		en = "Always show",
	},
	dodge_always_show_description = {
		en = "Keep the bar visible instead of fading it in and out around dodges.",
	},
	dodge_color_full = {
		en = "Available color",
	},
	dodge_color_full_description = {
		en = "Color of segments for dodges you still have.",
	},
	dodge_color_empty = {
		en = "Spent color",
	},
	dodge_color_empty_description = {
		en = "Color of spent (used) dodge segments.",
	},
	dodge_color_negative = {
		en = "Negative color",
	},
	dodge_color_negative_description = {
		en = "Color of segments when you have dodged past your effective dodges.",
	},

	-- ##############################
	-- #        ORIENTATION         #
	-- ##############################
	orientation_option_horizontal = {
		en = "Horizontal (Bottom)",
	},
	orientation_option_horizontal_flipped = {
		en = "Horizontal (Top)",
	},
	orientation_option_vertical = {
		en = "Vertical (Left)",
	},
	orientation_option_vertical_flipped = {
		en = "Vertical (Right)",
	},
}

-- Color dropdown labels (tinted swatch + readable name), generated for every engine colour.
local function display_name(text)
	local display_text = ""
	local words = string.split(text, "_")
	for _, word in ipairs(words) do
		word = (word:gsub("^%l", string.upper))
		display_text = display_text .. " " .. word
	end
	return display_text
end

for _, color_name in ipairs(Color.list) do
	localizations[color_name] = { en = cf(color_name) .. display_name(color_name) .. "{#reset()}" }
end

return localizations
