local mod = get_mod("controlled_chaos")

local function checkbox(setting_id)
	return {
		setting_id = setting_id,
		type = "checkbox",
		default_value = false,
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "havoc_level",
				type = "numeric",
				range = {1, 40},
				default_value = 40,
				decimals_number = 0,
			},
			{
				setting_id = "enemy_buffs",
				type = "group",
				sub_widgets = {
					checkbox("buff_cranial_corruption"),
					checkbox("buff_rotten_armour"),
					checkbox("buff_pus_hardened_skin"),
					checkbox("buff_blight_spreads"),
					checkbox("buff_encroaching_garden"),
					checkbox("buff_final_toll"),
					checkbox("buff_rampaging_enemies"),
					checkbox("buff_nurgles_blessing"),
					checkbox("buff_stimm_blue"),
					checkbox("buff_stimm_green"),
					checkbox("buff_stimm_red"),
					checkbox("buff_stimm_yellow"),
				},
			},
		},
	},
}
