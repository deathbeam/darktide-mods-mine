local mod = get_mod("stamina_dodge_bars")

-- Shared sizing for both the stamina and dodge bars. Mirrors the values used by the
-- Keystone & Blitz Bars element so the look stays consistent.
local hud_element_sdb = {
	max_glow_alpha = 130,
	center_offset = 210,
	spacing = 2, -- tighter segment dividers for a cleaner, more vanilla-like bar
	half_distance = 1,
	bar_size = {
		200,
		9
	},
	area_size = {
		220,
		40
	}
}

return settings("HudElementSdb", hud_element_sdb)
