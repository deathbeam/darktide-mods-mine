local function c(color_name, text)
	if Color and color_name and Color[color_name] then
		local col = Color[color_name](255, true)
		return string.format("{#color(%d,%d,%d)}%s{#reset()}", col[2], col[3], col[4], text)
	end
	return text
end

return {
	mod_name = {
		en = "Controlled Chaos",
	},
	mod_description = {
		en = "Adds a 'Havoc' difficulty to the Meat Grinder that replicates Havoc enemy health, enemy damage and player debuffs at a chosen Havoc level, plus optional Havoc enemy buffs applied to every enemy spawned in the Meat Grinder (including those from Creature Spawner).",
	},
	havoc_level = {
		en = "Havoc Level",
	},
	havoc_level_description = {
		en = "This setting is applied live to the Meat Grinder. Only respawned enemies are affected by changes to this value.",
	},
	enemy_buffs = {
		en = "Enemy Havoc Buffs",
	},
	enemy_buffs_description = {
		en = "Optional Havoc enemy buffs applied to EVERY eligible enemy spawned in the Meat Grinder (including enemies spawned by Creature Spawner), independent of the difficulty. Check any combination. Cranial Corruption / Rotten Armour are mutually exclusive (only one visual override at a time), and only one Contaminated Stimm can be active at a time; everything else stacks, matching live Havoc. Leave all unchecked to disable.",
	},

	buff_cranial_corruption = {
		en = c("light_salmon", "Cranial Corruption"),
	},
	buff_cranial_corruption_description = {
		en = "Visible parasite on its head\nInfested armour override (head)\n+25% movement speed\n+50% hit mass\nSuppression immune\nExplodes on lethal ranged damage (head)",
	},
	buff_pus_hardened_skin = {
		en = c("citadel_ogryn_camo", "Pus-Hardened Skin"),
	},
	buff_pus_hardened_skin_description = {
		en = "89% ranged damage reduction (Havoc 1)\n50% ranged damage reduction (Havoc 40)\nScales inversely with Havoc Level",
	},
	buff_blight_spreads = {
		en = c("olive", "The Blight Spreads"),
	},
	buff_blight_spreads_description = {
		en = "On death, drops a pool of corruption and spreads the buff to nearby enemies.",
	},
	buff_encroaching_garden = {
		en = c("blue_violet", "The Encroaching Garden"),
	},
	buff_encroaching_garden_description = {
		en = "Heals nearby allies without this buff\nHigher stagger resistance",
	},
	buff_final_toll = {
		en = c("ui_red_light", "The Final Toll"),
	},
	buff_final_toll_description = {
		en = "Gains the following buffs under 50% HP:\nStagger immune\n+50% hit mass\n+25% movement speed",
	},
	buff_rampaging_enemies = {
		en = c("item_rarity_5", "Rampaging Enemies"),
	},
	buff_rampaging_enemies_description = {
		en = "When a nearby enemy dies, gains stacks.\nFor each stack:\n+5% damage resistance (Elite)\n+10% damage resistance (non-Elite)\nMax 5 stacks",
	},
	buff_rotten_armour = {
		en = c("citadel_nurgling_green", "Rotten Armour"),
	},
	buff_rotten_armour_description = {
		en = "Infested armour override\n75% damage resistance (above 90% HP)\n+25% damage taken (below 25% HP)\n-15% movement speed\nReleases toxic gas on death",
	},
	buff_nurgles_blessing = {
		en = c("yellow_green", "Nurgle's Blessing"),
	},
	buff_nurgles_blessing_description = {
		en = "-35% damage taken\n+100% stagger resistance\n+20% ranged attack speed\n+25% movement speed\nCan fire more shots per volley",
	},
	buff_stimm_blue = {
		en = c("dodger_blue", "Contaminated Stimm: Blue"),
	},
	buff_stimm_blue_description = {
		en = "Carapace armour override\n+100% hit mass\n-55% damage taken (Carapace)\n-60% damage taken (non-Carapace)",
	},
	buff_stimm_green = {
		en = c("lime", "Contaminated Stimm: Green"),
	},
	buff_stimm_green_description = {
		en = "+70% HP (Havoc 1)\n+100% HP (Havoc 40)\nScales with Havoc Level\n\n-50% damage taken (DoT)",
	},
	buff_stimm_red = {
		en = c("ui_red_light", "Contaminated Stimm: Red"),
	},
	buff_stimm_red_description = {
		en = "+40% melee attack speed\n-90% stagger duration\n+200% stagger resistance",
	},
	buff_stimm_yellow = {
		en = c("citadel_dorn_yellow", "Contaminated Stimm: Yellow"),
	},
	buff_stimm_yellow_description = {
		en = "-35% damage taken\n+400% weakspot damage bonus\n+30% ranged attack speed\n+30% melee attack speed\nCan fire more shots per volley",
	},
}
