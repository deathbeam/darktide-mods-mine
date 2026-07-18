local mod = get_mod("ImprovedMeatGrinder")
local breeds_data = mod:io_dofile("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_breeds")

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

local breed_options = { { text = "None", value = "none" } }
breed_options.localize = false
pcall(function()
	local Breeds = require("scripts/settings/breed/breeds")
	local tmp = {}
	for breed_name, breed in pairs(Breeds) do
		if not breeds_data.blacklist[breed_name] and breeds_data.categories[breed_name] and breed and breed.display_name then
			local ok, s = pcall(Localize, breed.display_name)
			if ok and s and s ~= "" and not string.find(s, "<") then
				tmp[#tmp + 1] = { label = s, value = breed_name }
			end
		end
	end
	table.sort(tmp, function(a, b) return a.label < b.label end)
	for i = 1, #tmp do
		breed_options[#breed_options + 1] = { text = tmp[i].label, value = tmp[i].value }
	end
end)

local function slot_dropdown(id)
	return {
		setting_id    = id,
		type          = "dropdown",
		default_value = "none",
		options       = breed_options,
	}
end

mod_data.options = {
	widgets = {

		{
			setting_id      = "ps_open_menu",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = { "home" },
			function_name   = "open_menu",
		},

		{
			setting_id    = "ps_spawn_count",
			type          = "numeric",
			default_value = 1,
			range         = { 1, 20 },
		},

		{
			setting_id    = "ps_spread",
			type          = "numeric",
			default_value = 2,
			range         = { 0, 8 },
		},
		{
			setting_id    = "ps_menu_spawn_at_aim",
			type          = "checkbox",
			default_value = true,
		},
		{
			setting_id    = "ps_prepare_on_entry",
			type          = "checkbox",
			default_value = true,
		},
		{
			setting_id    = "ps_invisible_default",
			type          = "checkbox",
			default_value = false,
		},
		{
			setting_id    = "ps_no_default_enemies",
			type          = "checkbox",
			default_value = false,
		},
		{

			setting_id    = "ps_no_props",
			type          = "checkbox",
			default_value = false,
		},
		{
			setting_id    = "ps_swap_lineup",
			type          = "checkbox",
			default_value = false,
		},
		{
			setting_id    = "ps_immortal_enemies",
			type          = "checkbox",
			default_value = false,
		},
		{
			setting_id    = "ps_show_bot_hud",
			type          = "checkbox",
			default_value = true,
		},
		{
			setting_id    = "ps_no_stagger",
			type          = "checkbox",
			default_value = false,
		},
		{
			setting_id    = "ps_select_mode",
			type          = "checkbox",
			default_value = false,
		},
		{

			setting_id    = "ps_spawn_on_close",
			type          = "checkbox",
			default_value = true,
		},
		{

			setting_id    = "ps_keep_queue",
			type          = "checkbox",
			default_value = false,
		},

		{
			setting_id      = "ps_key_kill_all",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "kill_all",
		},
		{
			setting_id      = "ps_key_reset",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "reset_to_default",
		},
		{
			setting_id      = "ps_key_spawn_bot",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "spawn_bot_key",
		},
		{
			setting_id      = "ps_key_clear_bots",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "clear_bots_key",
		},
		{
			setting_id      = "ps_key_no_stagger",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_no_stagger",
		},
		{
			setting_id      = "ps_key_enemy_ai",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_enemy_ai",
		},
		{
			setting_id      = "ps_key_invisible",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_invisible",
		},
		{
			setting_id      = "ps_key_refill",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "refill",
		},
		{
			setting_id      = "ps_key_invuln",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_invuln",
		},
		{
			setting_id      = "ps_key_repeat",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "repeat_last",
		},
		{
			setting_id      = "ps_key_god_mode",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_mode",
		},

		{
			setting_id      = "ps_key_god_toughness",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_toughness",
		},
		{
			setting_id      = "ps_key_god_health",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_health",
		},
		{
			setting_id      = "ps_key_god_ammo",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_ammo",
		},
		{
			setting_id      = "ps_key_god_magazine",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_magazine",
		},
		{
			setting_id      = "ps_key_god_ability",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_ability",
		},
		{
			setting_id      = "ps_key_god_blitz",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_blitz",
		},
		{
			setting_id      = "ps_key_god_stamina",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_stamina",
		},
		{
			setting_id      = "ps_key_god_dodge",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_dodge",
		},
		{
			setting_id      = "ps_key_no_peril_gain",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_no_peril_gain",
		},
		{
			setting_id      = "ps_key_no_peril_death",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_god_no_peril_death",
		},
		{
			setting_id      = "ps_key_respawn",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "respawn",
		},
		{
			setting_id      = "ps_key_swap_lineup",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_swap_lineup",
		},
		{
			setting_id      = "ps_key_immortal_enemies",
			type            = "keybind",
			keybind_trigger = "pressed",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "toggle_immortal_enemies",
		},
		{

			setting_id      = "ps_key_aim_spawn",
			type            = "keybind",
			keybind_trigger = "held",
			keybind_type    = "function_call",
			default_value   = {},
			function_name   = "aim_spawn_hold",
		},

		{
			setting_id  = "ps_quick_slots",
			type        = "group",
			sub_widgets = {
				slot_dropdown("ps_slot_1"),
				{
					setting_id      = "ps_key_slot_1",
					type            = "keybind",
					keybind_trigger = "pressed",
					keybind_type    = "function_call",
					default_value   = {},
					function_name   = "spawn_slot_1",
				},
				slot_dropdown("ps_slot_2"),
				{
					setting_id      = "ps_key_slot_2",
					type            = "keybind",
					keybind_trigger = "pressed",
					keybind_type    = "function_call",
					default_value   = {},
					function_name   = "spawn_slot_2",
				},
				slot_dropdown("ps_slot_3"),
				{
					setting_id      = "ps_key_slot_3",
					type            = "keybind",
					keybind_trigger = "pressed",
					keybind_type    = "function_call",
					default_value   = {},
					function_name   = "spawn_slot_3",
				},
				slot_dropdown("ps_slot_4"),
				{
					setting_id      = "ps_key_slot_4",
					type            = "keybind",
					keybind_trigger = "pressed",
					keybind_type    = "function_call",
					default_value   = {},
					function_name   = "spawn_slot_4",
				},
			},
		},
	},
}

return mod_data
