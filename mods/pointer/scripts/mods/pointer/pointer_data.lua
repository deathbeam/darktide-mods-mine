local mod = get_mod("pointer")

local widgets = {
	{
		setting_id    = "point_when_tagging",
		type          = "checkbox",
		default_value = true,
	},
	{
        setting_id      = "point_keybind",
		type            = "keybind",
		default_value   = {},
		keybind_global  = true,
		keybind_trigger = "pressed",
		keybind_type    = "function_call",
		function_name   = "trigger_point_animation",
    },
	{
		tooltip 	  = "If you are currently attacking or charging anything (like a Psyker staff) the animation will not play",
        setting_id    = "disable_attacking_during_action",
		type          = "checkbox",
		default_value = true,
    },
	{
		setting_id      = "tagging_delay",
		type            = "numeric",
		default_value   = 0.85,
		range 		    = {0.00, 2.00},
		decimals_number = 2,
		tooltip		    = "tagging_delay_tooltip"
	}
}

return {
	name = "Immersive Tagging",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	}
}
