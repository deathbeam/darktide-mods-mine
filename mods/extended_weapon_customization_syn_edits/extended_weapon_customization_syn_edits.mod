return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`extended_weapon_customization_syn_edits` encountered an error loading the Darktide Mod Framework.")

		new_mod("extended_weapon_customization_syn_edits", {
			mod_script       = "extended_weapon_customization_syn_edits/ewc_syn_edits",
			mod_data         = "extended_weapon_customization_syn_edits/ewc_syn_edits_data",
			mod_localization = "extended_weapon_customization_syn_edits/ewc_syn_edits_localization",
		})
	end,
	require = {
    	"extended_weapon_customization",
	"extended_weapon_customization_base_additions",
	},
  	load_after = {
    	"extended_weapon_customization",
	"extended_weapon_customization_base_additions",
  	},
	version = "2.0",
	packages = {},
}
