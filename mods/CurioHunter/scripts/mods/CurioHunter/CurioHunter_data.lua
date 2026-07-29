local mod = get_mod("CurioHunter")

local CURIO_TYPES = {
	"health",
	"toughness",
	"stamina",
	"wound",
}

local function action_options()
	return {
		{ text = "opt_buy", value = "buy" },
		{ text = "opt_notify", value = "notify" },
		{ text = "opt_ignore", value = "ignore" },
	}
end

local widgets = {
	{
		setting_id = "min_power",
		type = "numeric",
		default_value = 70,
		range = { 1, 80 },
		decimals_number = 0,
	},
	{
		setting_id = "silent",
		type = "checkbox",
		default_value = false,
	},
	{
		setting_id = "poll_seconds",
		type = "numeric",
		default_value = 3600,
		range = { 60, 3600 },
		decimals_number = 0,
	},
	{
		setting_id = "check_now_key",
		type = "keybind",
		default_value = {},
		keybind_trigger = "pressed",
		keybind_type = "function_call",
		function_name = "check_now",
	},
	{
		setting_id = "debug",
		type = "checkbox",
		default_value = false,
	},
}

for i = 1, #CURIO_TYPES do
	widgets[#widgets + 1] = {
		setting_id = "action_" .. CURIO_TYPES[i],
		type = "dropdown",
		default_value = "notify",
		options = action_options(),
	}
end

widgets[#widgets + 1] = {
	setting_id = "classes_group",
	type = "group",
	sub_widgets = {
		{
			setting_id = "include_adamant",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_broker",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_ogryn",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_psyker",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_veteran",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_zealot",
			type = "checkbox",
			default_value = true,
		},
		{
			setting_id = "include_cryptic",
			type = "checkbox",
			default_value = true,
		},
	},
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	},
}
