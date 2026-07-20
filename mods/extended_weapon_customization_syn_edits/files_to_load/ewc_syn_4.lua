local mod = get_mod("extended_weapon_customization_syn_edits")
local ewc = get_mod("extended_weapon_customization")

-- ##### ┌─┐┌─┐┬─┐┌─┐┌─┐┬─┐┌┬┐┌─┐┌┐┌┌─┐┌─┐ ############################################################################
-- ##### ├─┘├┤ ├┬┘├┤ │ │├┬┘│││├─┤││││  ├┤  ############################################################################
-- ##### ┴  └─┘┴└─└  └─┘┴└─┴ ┴┴ ┴┘└┘└─┘└─┘ ############################################################################
-- #region Performance
    local CLASS = CLASS
    local pairs = pairs
    local table = table
    local managers = Managers
    local vector3_box = Vector3Box
    local table_clone = table.clone
    local table_merge_recursive = table.merge_recursive
--#endregion

-- ##### ┌┬┐┌─┐┌┬┐┌─┐ #################################################################################################
-- #####  ││├─┤ │ ├─┤ #################################################################################################
-- ##### ─┴┘┴ ┴ ┴ ┴ ┴ #################################################################################################
local _item = "content/items/weapons/player"
local _item_ranged = _item.."/ranged"
local _item_melee = _item.."/melee"
local _empty_item = "content/items/weapons/player/trinkets/unused_trinket"

mod.extended_weapon_customization_plugin_4 = {
----------------------------------------------------------------------------------------
--			KIT BASH SECTION
----------------------------------------------------------------------------------------

    kitbashs = {

        [_item_melee.."/syn_no_connector"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	feature_flags = {"ROTATION_ursula"},
            	attach_node = "ap_connector_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_01/connector_01"] = true},
            	attachments = {
                syn_connector_1 = {
                    item = _item_melee.."/connectors/syn_human_power_maul_connector_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		},
            	display_name = "n/a",
            	name = _item_melee.."/syn_no_connector",
            	is_full_item = true,
        },
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--										MELEE
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        [_item_melee.."/heads/syn_ogryn_powersword_01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_01/blade_01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_01",
            	name = _item_melee.."/heads/syn_ogryn_powersword_01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_02"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_02/blade_02"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_02",
            	name = _item_melee.."/heads/syn_ogryn_powersword_02",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_03"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_03/blade_03"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_03",
            	name = _item_melee.."/heads/syn_ogryn_powersword_03",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_05"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_05/blade_05"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_05",
            	name = _item_melee.."/heads/syn_ogryn_powersword_05",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_06"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_06/blade_06"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_06",
            	name = _item_melee.."/heads/syn_ogryn_powersword_06",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_07"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_07/blade_07"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_07",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_07",
            	name = _item_melee.."/heads/syn_ogryn_powersword_07",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_08"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_08/blade_08"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_08",
                    fix = {offset = {position = vector3_box(0.0, 0.0, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_08",
            	name = _item_melee.."/heads/syn_ogryn_powersword_08",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_08_ml01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_08_ml01/blade_08_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_08_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_08_ml01",
            	name = _item_melee.."/heads/syn_ogryn_powersword_08_ml01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_deluxe01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_deluxe01/blade_deluxe01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_deluxe01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_deluxe01",
            	name = _item_melee.."/heads/syn_ogryn_powersword_deluxe01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_powersword_ml01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/blade_ml01/blade_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/syn_blades/power_sword_blade_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 3, 2.25)}}},
		},
            	display_name = "loc_syn_transonic_powersword_ml01",
            	name = _item_melee.."/heads/syn_ogryn_powersword_ml01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_custodes_01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_4c/trinket_4c"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/connector_01/connector_01"] = true,
		["content/weapons/player/ranged/bolt_pistol/attachments/barrel_01/barrel_01"] = true,
		["content/weapons/player/ranged/bolt_pistol/attachments/magazine_02/magazine_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true,
		["content/weapons/player/melee/thunder_hammer/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/ranged/bolt_pistol/attachments/receiver_04/receiver_04"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_ranged.."/recievers/syn_boltgun_pistol_receiver_04",
                    fix = {offset = {position = vector3_box(-0.096, 0.0, 0.32), rotation = vector3_box(0, 90, 90), scale = vector3_box(2.5, 2.5, 2.5)}},
		    children = {
                	syn_head_1a = {
                    	item = _item_ranged.."/magazines/boltgun_pistol_magazine_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_head_1b = {
                    	item = _item_ranged.."/barrels/boltgun_pistol_barrel_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
                syn_head_2 = {
                    item = _item_melee.."/blades/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(-0.114, 0.0, 0.66), rotation = vector3_box(0, 0, 90), scale = vector3_box(3, 2.25, 1.65)}}},
                syn_head_3 = {
                    item = _item_melee.."/connectors/syn_thunder_hammer_connector_01",
                    fix = {offset = {position = vector3_box(0.002, 0, 0.052), rotation = vector3_box(0, 0, -90), scale = vector3_box(2, 2, 1.3)}}},
                syn_head_4 = {
                    item = _item_melee.."/pommels/syn_thunder_hammer_pommel_05",
                    fix = {offset = {position = vector3_box(-0.196, 0, 0.522), rotation = vector3_box(0, -90, -90), scale = vector3_box(2.534, 2.534, 6.788)}}},
                syn_head_5 = {
                    item = "content/items/weapons/player/trinkets/trinket_4c",
                    fix = {offset = {position = vector3_box(-0.174, 0.114, 0.252), rotation = vector3_box(0, 0, 0), scale = vector3_box(2, 2, 2)}}},
		},
            	display_name = "loc_syn_ogryn_custodes_01",
            	name = _item_melee.."/heads/syn_ogryn_custodes_01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_halberd_01"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	feature_flags = {"ROTATION_ursula"},
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_07/pommel_07"] = true,
		["content/weapons/player/melee/thunder_hammer/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/ranged/arc_rifle/attachments/stock_01/stock_01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_01",
                    fix = {offset = {position = vector3_box(-0.386, 0.0, 0.54), rotation = vector3_box(0, 0, 90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_2 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_01",
                    fix = {offset = {position = vector3_box(0.386, 0.0, 0.54), rotation = vector3_box(0, 0, -90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_3 = {
                    item = _item_melee.."/pommels/syn_power_sword_pommel_07",
                    fix = {offset = {position = vector3_box(0.217, 0, 0.241), rotation = vector3_box(0, 90, 90), scale = vector3_box(2.5, 12, 11)}}},
                syn_head_4 = {
                    item = _item_melee.."/pommels/syn_thunder_hammer_pommel_05",
                    fix = {offset = {position = vector3_box(0.1, 0, 0.396), rotation = vector3_box(0, -90, -90), scale = vector3_box(3.5, 3.5, 7)}}},
		},
            	display_name = "loc_syn_ogryn_halberd_01",
            	name = _item_melee.."/heads/syn_ogryn_halberd_01",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_halberd_02"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	feature_flags = {"ROTATION_ursula"},
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_deluxe01/pommel_deluxe01"] = true,
		["content/weapons/player/melee/2h_force_sword/attachments/pommel_03/pommel_03"] = true,
		["content/weapons/player/melee/thunder_hammer/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/ranged/arc_rifle/attachments/stock_deluxe01/stock_deluxe01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_deluxe01",
                    fix = {offset = {position = vector3_box(-0.386, 0.0, 0.54), rotation = vector3_box(0, 0, 90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_2 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_deluxe01",
                    fix = {offset = {position = vector3_box(0.386, 0.0, 0.54), rotation = vector3_box(0, 0, -90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_3 = {
                    item = _item_melee.."/pommels/syn_power_sword_pommel_deluxe01",
                    fix = {offset = {position = vector3_box(-0.021, 0, 0.241), rotation = vector3_box(0, 90, 90), scale = vector3_box(2.5, 12, 11)}}},
                syn_head_4 = {
                    item = _item_melee.."/pommels/syn_thunder_hammer_pommel_05",
                    fix = {offset = {position = vector3_box(0.1, 0, 0.396), rotation = vector3_box(0, -90, -90), scale = vector3_box(3.5, 3.5, 7)}}},
                syn_head_5 = {
                    item = _item_melee.."/pommels/syn_2h_force_sword_pommel_03",
                    fix = {offset = {position = vector3_box(-0.444, 0.006, 0.398), rotation = vector3_box(-90, 0, 90), scale = vector3_box(3, 3, 3.512)}}},
                syn_head_6 = {
                    item = _item_melee.."/pommels/syn_2h_force_sword_pommel_03",
                    fix = {offset = {position = vector3_box(0.444, -0.006, 0.398), rotation = vector3_box(90, 0, -90), scale = vector3_box(3, 3, 3.512)}}},
		},
            	display_name = "loc_syn_ogryn_halberd_02",
            	name = _item_melee.."/heads/syn_ogryn_halberd_02",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_ogryn_halberd_03"] = {
            	is_fallback_item = false,
            	show_in_1p = true,
            	only_show_in_1p = false,
            	base_unit = "content/characters/empty_item/empty_item",
           	item_list_faction = "Player",
            	tags = {},
            	workflow_checklist = {},
            	workflow_state = "RELEASABLE",
            	feature_flags = {"ROTATION_ursula"},
            	attach_node = "ap_head_01",
            	resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_07_ml01/pommel_07_ml01"] = true,	
		["content/weapons/player/melee/thunder_hammer/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/ranged/arc_rifle/attachments/stock_ml01/stock_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_ml01",
                    fix = {offset = {position = vector3_box(-0.386, 0.0, 0.54), rotation = vector3_box(0, 0, 90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_2 = {
                    item = _item_ranged.."/stocks/syn_arc_rifle_stock_ml01",
                    fix = {offset = {position = vector3_box(0.386, 0.0, 0.54), rotation = vector3_box(0, 0, -90), scale = vector3_box(6, 2, 4.55)}}},
                syn_head_3 = {
                    item = _item_melee.."/pommels/syn_power_sword_pommel_07_ml01",
                    fix = {offset = {position = vector3_box(0.217, 0, 0.241), rotation = vector3_box(0, 90, 90), scale = vector3_box(2.5, 12, 11)}}},
                syn_head_4 = {
                    item = _item_melee.."/pommels/syn_thunder_hammer_pommel_05",
                    fix = {offset = {position = vector3_box(0.1, 0, 0.396), rotation = vector3_box(0, -90, -90), scale = vector3_box(3.5, 3.5, 7)}}},
		},
            	display_name = "loc_syn_ogryn_halberd_03",
            	name = _item_melee.."/heads/syn_ogryn_halberd_03",
            	is_full_item = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_01/grip_01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_01/pommel_01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_01/blade_01"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_01",
            	name = _item_melee.."/syn_transonic_powersword_right_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_02/blade_02"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_02",
            	name = _item_melee.."/syn_transonic_powersword_right_02",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_03/grip_03"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_03/pommel_03"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_03/blade_03"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_03",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_03",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_03",
            	name = _item_melee.."/syn_transonic_powersword_right_03",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_05/grip_05"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_05/blade_05"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_05",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_05",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_05",
            	name = _item_melee.."/syn_transonic_powersword_right_05",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_06/grip_06"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_06/pommel_06"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_06/blade_06"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_06",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_06",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_06",
            	name = _item_melee.."/syn_transonic_powersword_right_06",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_ml01/grip_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_ml01/blade_ml01"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_ml01",
            	name = _item_melee.."/syn_transonic_powersword_right_ml01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_07"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_07/blade_07"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_07",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_07",
            	name = _item_melee.."/syn_transonic_powersword_right_07",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_08"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_07/grip_07"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_07/pommel_07"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_08/blade_08"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_07",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_08",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_07",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_08",
            	name = _item_melee.."/syn_transonic_powersword_right_08",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_08_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_07_ml01/grip_07_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_07_ml01/pommel_07_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_08_ml01/blade_08_ml01"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_07_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_08_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_07_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_08_ml01",
            	name = _item_melee.."/syn_transonic_powersword_right_08_ml01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_right_deluxe01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_rightweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_deluxe01/grip_deluxe01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_deluxe01/pommel_deluxe01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_deluxe01/blade_deluxe01"] = true},
            	attachments = {
                syn_transonic_blade_right_1 = {
                    item = _item_melee.."/grips/power_sword_grip_deluxe01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_right_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_deluxe01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_deluxe01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_right_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_deluxe01",
            	name = _item_melee.."/syn_transonic_powersword_right_deluxe01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_01/pommel_01"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_01/grip_01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_01/blade_01"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_01",
            	name = _item_melee.."/syn_transonic_powersword_left_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_02/blade_02"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_02",
            	name = _item_melee.."/syn_transonic_powersword_left_02",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_03/grip_03"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_03/pommel_03"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_03/blade_03"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_03",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_03",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_03",
            	name = _item_melee.."/syn_transonic_powersword_left_03",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_05/grip_05"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_05/blade_05"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_05",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_05",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_05",
            	name = _item_melee.."/syn_transonic_powersword_left_05",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_06/grip_06"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_06/pommel_06"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_06/blade_06"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_06",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_06",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_06",
            	name = _item_melee.."/syn_transonic_powersword_left_06",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_ml01/grip_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_ml01/blade_ml01"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_ml01",
            	name = _item_melee.."/syn_transonic_powersword_left_ml01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_07"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_07/blade_07"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_07",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_02",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1, 1.5)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_07",
            	name = _item_melee.."/syn_transonic_powersword_left_07",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_08"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_07/grip_07"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_07/pommel_07"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_08/blade_08"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_07",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_08",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_07",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_08",
            	name = _item_melee.."/syn_transonic_powersword_left_08",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_08_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_07_ml01/grip_07_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_07_ml01/pommel_07_ml01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_08_ml01/blade_08_ml01"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_07_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_08_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_07_ml01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_08_ml01",
            	name = _item_melee.."/syn_transonic_powersword_left_08_ml01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_transonic_powersword_left_deluxe01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "j_leftweaponattach",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true,
			["content/weapons/player/melee/transonic_razor/wpn_transonic_razor_chained_rig"] = true,
			["content/weapons/player/melee/power_sword/attachments/grip_deluxe01/grip_deluxe01"] = true,
			["content/weapons/player/melee/power_sword/attachments/pommel_deluxe01/pommel_deluxe01"] = true,
			["content/weapons/player/melee/power_sword/attachments/blade_deluxe01/blade_deluxe01"] = true},
            	attachments = {
                syn_transonic_blade_left_1 = {
                    item = _item_melee.."/grips/power_sword_grip_deluxe01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_transonic_blade_left_2 = {
                	    item = _item_melee.."/blades/power_sword_blade_deluxe01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_3 = {
                	    item = _item_melee.."/pommels/power_sword_pommel_deluxe01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_transonic_blade_left_4 = {
                	    item = _item_melee.."/blades/transonic_knife_blade_01",
                	    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 1.7, 1.75)}, hide = {mesh = {2}}}},
		    }},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_transonic_powersword_deluxe01",
            	name = _item_melee.."/syn_transonic_powersword_left_deluxe01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_powerclaw_grip_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/weapons/player/melee/chordclaw/wpn_chordclaw_chained_rig",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_grip_01",
            	resource_dependencies = {
			["content/weapons/player/melee/chordclaw/wpn_chordclaw_chained_rig"] = true},
            	attachments = {},
            	workflow_checklist = {},
            	name = _item_melee.."/syn_powerclaw_grip_01",
            	workflow_state = "RELEASABLE",
            	disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/grips/syn_powerclaw_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_grip_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/chordclaw/wpn_chordclaw_chained_rig"] = true},
            	attachments = {
                syn_power_claw_grip_1 = {
                    item = _item_melee.."/syn_powerclaw_grip_01",
                    fix = {offset = {position = vector3_box(0, -0.075, .0), rotation = vector3_box(10, 90, 0), scale = vector3_box(1.5, 1.5, 1.5)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_powerclaw_01",
            	name = _item_melee.."/grips/syn_powerclaw_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/grips/syn_powerclaw_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_grip_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/chordclaw/wpn_chordclaw_chained_rig"] = true},
            	attachments = {
                syn_power_claw_grip_1 = {
                    item = _item_melee.."/syn_powerclaw_grip_01",
                    fix = {offset = {position = vector3_box(0, -0.075, .0), rotation = vector3_box(10, 90, 0), scale = vector3_box(1.5, 1.5, 1.5)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_powerclaw_02",
            	name = _item_melee.."/grips/syn_powerclaw_02",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_01/head_01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_01",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_02/head_02"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_02",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_02",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_03/head_03"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_03",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_03",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_04"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_04/head_04"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_04",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_04",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_05/head_05"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_05",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_05",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_ml01/head_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(1, 1, 1)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_ogryn_head_06",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_ogryn_head_06",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_01/head_01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_01",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_02/head_02"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_02",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_02",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_03/head_03"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_03",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_03",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_04"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_04/head_04"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_04",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_04",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_05/head_05"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_05",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_05",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_06/head_06"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_06",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_06",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_06",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_pickaxe_shovel_head_07"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel/attachments/head_ml01/head_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/syn_shovel_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.34, 3.34, 3.34)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_shovel_head_07",
            	name = _item_melee.."/heads/syn_pickaxe_shovel_head_07",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_01/head_01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_01",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_01",
            	workflow_state = "RELEASABLE",
		disable_vfx_spawner_exclusion = true,
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_02/head_02"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_02",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_02",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_03/head_03"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_03",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_03",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_04"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_04/head_04"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_04",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_04",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_05/head_05"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_05",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_05",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_melee.."/heads/syn_crusher_shovel_ogryn_head_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "ap_head_01",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/shovel_ogryn/attachments/head_ml01/head_ml01"] = true},
            	attachments = {
                syn_head_1 = {
                    item = _item_melee.."/heads/shovel_ogryn_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},			
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_crusher_ml01",
            	name = _item_melee.."/heads/syn_crusher_shovel_ogryn_head_ml01",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_01",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_01",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_02/grip_02"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_02",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_02",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_03/grip_03"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_03",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_03",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_04"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_04/grip_04"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_04",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_04",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_05/grip_05"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_05",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_05",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_06/grip_06"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_06",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_06",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_combat_sword_grip_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/combat_sword/attachments/grip_ml01/grip_ml01"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/combat_sword_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_combatsword_ml01",
            	name = _item_ranged.."/shaft/syn_arbite_combat_sword_grip_ml01",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_01/grip_01"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},		
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_01",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_01",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_02"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_02/grip_02"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_02",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_02",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_03"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_03/grip_03"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_03",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_03",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_04"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_04/grip_04"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_04",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_04",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_05"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_05/grip_05"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_05",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_05",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_06"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_06/grip_06"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_06",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_06",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_ranged.."/shaft/syn_arbite_falchion_grip_ml01"] = {
		is_fallback_item = false,
            	show_in_1p = true,
            	base_unit = "content/characters/empty_item/empty_item",
            	item_list_faction = "Player",
            	tags = {},
            	only_show_in_1p = false,
            	attach_node = "rp_human_power_maul_short_chained_rig",
            	resource_dependencies = {
	                ["content/characters/empty_item/empty_item"] = true,
			["content/weapons/player/melee/falchion/attachments/grip_ml01/grip_ml01"] = true},
            	attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/grips/falchion_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, 1, 1)}}},	
		},
            	workflow_checklist = {},
            	display_name = "loc_syn_falchion_ml01",
            	name = _item_ranged.."/shaft/syn_arbite_falchion_grip_ml01",
            	workflow_state = "RELEASABLE",
            	is_full_item = true,
        },
        [_item_melee.."/syn_hilt_extender_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_hiltextender_01 = {
                    item = _item_melee.."/pommels/syn_power_sword_pommel_02",
                    fix = {offset = {position = vector3_box(0, 0.0, -.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
},
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/syn_hilt_extender_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blades/syn_bonesaw_poison_0"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/blades/syn_bonesaw_poison_0",
            workflow_state = "RELEASABLE",
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blades/syn_bonesaw_poison_1"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/saw/attachments/blade_01/blade_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/saw/attachments/blade_01/blade_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/blades/syn_bonesaw_poison_1",
            workflow_state = "RELEASABLE",
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blades/falchion_blade_06_syn"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_blade_1 = {
                    item = _item_melee.."/blades/syn_falchion_blade_06",           
                    fix = {offset = {position = vector3_box(0, 0.0, -.028), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_06",
            name = _item_melee.."/blades/falchion_blade_06_syn",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_01",
            name = _item_melee.."/body/syn_saw_body_combatsword_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_02/grip_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_02/grip_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_02",
            name = _item_melee.."/body/syn_saw_body_combatsword_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_03/grip_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_03/grip_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_03",
            name = _item_melee.."/body/syn_saw_body_combatsword_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_04/grip_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_04/grip_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_04",
            name = _item_melee.."/body/syn_saw_body_combatsword_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_05/grip_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_05/grip_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_05",
            name = _item_melee.."/body/syn_saw_body_combatsword_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_06/grip_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_06/grip_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_06",
            name = _item_melee.."/body/syn_saw_body_combatsword_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_combatsword_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_sword/attachments/grip_ml01/grip_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_sword/attachments/grip_ml01/grip_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_ml01",
            name = _item_melee.."/body/syn_saw_body_combatsword_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_01/grip_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_01",
            name = _item_melee.."/body/syn_saw_body_falchion_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_02/grip_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_02/grip_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_02",
            name = _item_melee.."/body/syn_saw_body_falchion_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_03/grip_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_03/grip_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_03",
            name = _item_melee.."/body/syn_saw_body_falchion_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_04/grip_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_04/grip_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_04",
            name = _item_melee.."/body/syn_saw_body_falchion_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_05/grip_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_05/grip_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_05",
            name = _item_melee.."/body/syn_saw_body_falchion_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_06/grip_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_06/grip_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_06",
            name = _item_melee.."/body/syn_saw_body_falchion_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_falchion_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/falchion/attachments/grip_ml01/grip_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/falchion/attachments/grip_ml01/grip_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_ml01",
            name = _item_melee.."/body/syn_saw_body_falchion_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_01/grip_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_01",
            name = _item_melee.."/body/syn_saw_body_sabre_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_02/grip_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_02/grip_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_02",
            name = _item_melee.."/body/syn_saw_body_sabre_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_03/grip_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_03/grip_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_03",
            name = _item_melee.."/body/syn_saw_body_sabre_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_04/grip_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_04/grip_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_04",
            name = _item_melee.."/body/syn_saw_body_sabre_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_05/grip_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_05/grip_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_05",
            name = _item_melee.."/body/syn_saw_body_sabre_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_06/grip_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_06/grip_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_06",
            name = _item_melee.."/body/syn_saw_body_sabre_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_07/grip_07",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_07/grip_07"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_07",
            name = _item_melee.."/body/syn_saw_body_sabre_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_08/grip_08",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_08/grip_08"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_08",
            name = _item_melee.."/body/syn_saw_body_sabre_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_saw_body_sabre_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/sabre/attachments/grip_ml01/grip_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_saw_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/sabre/attachments/grip_ml01/grip_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_ml01",
            name = _item_melee.."/body/syn_saw_body_sabre_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_chain_connector"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/power_sword/attachments/grip_02/grip_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "10",
      		resource_dependencies = {["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_chain_connector",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_chain_ender"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/attachments/trinket_hooks/trinket_hook_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "10",
      		resource_dependencies = {["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_chain_ender",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_chain_starter"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/attachments/trinket_hooks/trinket_hook_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_chain_starter",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_01/connector_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_01/connector_01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_02"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_02/connector_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_02/connector_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_02",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_03"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_03/connector_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_03/connector_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_03",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_04"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_04/connector_04",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_04/connector_04"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_04",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_05"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_05/connector_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_05/connector_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_05",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_connector_ml01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/human_power_maul/attachments/connector_ml01/connector_ml01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/human_power_maul/attachments/connector_ml01/connector_ml01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_connector_ml01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_01/connector_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_01/connector_01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_02"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_02/connector_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_02/connector_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_02",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_03"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_03/connector_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_03/connector_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_03",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_04"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_04/connector_04",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_04/connector_04"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_04",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_05"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_05/connector_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_05/connector_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_05",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_06"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_06/connector_06",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_06/connector_06"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_06",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_flail_crusher_connector_ml01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/connector_ml01/connector_ml01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = "ap_head_01",
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/connector_ml01/connector_ml01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_flail_crusher_connector_ml01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/head/syn_ogryn_flail_maul_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_01/connector_01"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_01",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_01",
            name = _item_melee.."/head/syn_ogryn_flail_maul_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_maul_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_02/connector_02"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_02/head_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_02",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_02",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_02",
            name = _item_melee.."/head/syn_ogryn_flail_maul_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_maul_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_03/connector_03"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_03/head_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_03",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_03",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_03",
            name = _item_melee.."/head/syn_ogryn_flail_maul_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_maul_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_04/connector_04"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_04/head_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_04",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_04",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_04",
            name = _item_melee.."/head/syn_ogryn_flail_maul_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_maul_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_05/connector_05"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_05/head_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_05",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_05",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_05",
            name = _item_melee.."/head/syn_ogryn_flail_maul_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_maul_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/connector_ml01/connector_ml01"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_ml01/head_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_connector_ml01",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_ml01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_ml01",
            name = _item_melee.."/head/syn_ogryn_flail_maul_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_01/connector_01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_01/head_01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_01",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_01",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_02/connector_02"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_02/head_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_02",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_02",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_02",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_03/connector_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_03/head_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_03",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_03",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_03",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_04/connector_04"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_04/head_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_04",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_04",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_04",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_05/connector_05"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_05/head_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_05",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_05",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_05",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_06/connector_06"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_06/head_06"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_06",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_07",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_06",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_ogryn_flail_crusher_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/connector_ml01/connector_ml01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_ml01/head_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_flail_00 = {
                    item = _item_melee.."/syn_flail_crusher_connector_ml01",
                    fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_ml01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_07",
            name = _item_melee.."/head/syn_ogryn_flail_crusher_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_01",
            name = _item_melee.."/head/syn_flail_maul_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_02/head_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_02",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_02",
            name = _item_melee.."/head/syn_flail_maul_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_03/head_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_03",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_03",
            name = _item_melee.."/head/syn_flail_maul_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_04/head_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_04",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_04",
            name = _item_melee.."/head/syn_flail_maul_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_05/head_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_05",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_05",
            name = _item_melee.."/head/syn_flail_maul_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_maul_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_ml01/head_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/human_power_maul_head_ml01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_maul_ml01",
            name = _item_melee.."/head/syn_flail_maul_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_01/head_01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_01",
            name = _item_melee.."/head/syn_flail_crusher_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_02/head_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_02",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_02",
            name = _item_melee.."/head/syn_flail_crusher_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_03/head_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_03",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_03",
            name = _item_melee.."/head/syn_flail_crusher_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_04/head_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_04",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_04",
            name = _item_melee.."/head/syn_flail_crusher_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_05/head_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_05",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_05",
            name = _item_melee.."/head/syn_flail_crusher_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_07/head_07"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_07",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_06",
            name = _item_melee.."/head/syn_flail_crusher_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/head/syn_flail_crusher_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_ml01/head_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                	syn_flail_01 = {
                    	item = _item_melee.."/syn_chain_starter",
                    	fix = {offset = {position = vector3_box(0, 0., .0), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.5, 1.5, 1.5)}},
		        children = {
                		syn_flail_02 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_flail_03 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_flail_04 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_flail_05 = {
                    					item = _item_melee.."/syn_chain_connector", 
                    					fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        				children = {
                						syn_flail_06 = {
                    						item = "content/items/weapons/player/trinkets/trinket_1a",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
								children = {
                							syn_flail_07 = {
                    							item = _item_melee.."/syn_chain_connector", 
                    							fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        						children = {
                								syn_flail_08 = {
                    								item = "content/items/weapons/player/trinkets/trinket_1a",
                    								fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
										children = {
                									syn_flail_09 = {
                    									item = _item_melee.."/syn_chain_connector", 
                    									fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        								children = {
                										syn_flail_10 = {
                    										item = "content/items/weapons/player/trinkets/trinket_1a",
                    										fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
												children = {
                											syn_flail_11 = {
                    											item = _item_melee.."/syn_chain_connector", 
                    											fix = {offset = {position = vector3_box(0.0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        										children = {
                												syn_flail_12 = {
                    												item = "content/items/weapons/player/trinkets/trinket_1a",
                    												fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {node = {11}}},
														children = {
                													syn_flail_13 = {
                    													item = _item_melee.."/syn_chain_ender", 
                    													fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        												children = {
                														syn_flail_14 = {
                    														item = _item_melee.."/heads/2h_power_maul_head_ml01",
                    														fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.667, .667, .667)}}},
															}},
														}},
													}},
												}},
											}},
										}},
									}},
								}},
							}},
						}},
					}},
				}},
			}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_flail_crusher_ml01",
            name = _item_melee.."/head/syn_flail_crusher_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_left_shiv_riceflail_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_05/grip_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_left_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_left_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_left_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_left_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_left_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_left_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_left_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_05",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_01",
            name = _item_melee.."/grips/syn_left_shiv_riceflail_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_left_shiv_riceflail_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_02/grip_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_left_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_left_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_left_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_left_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_left_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_left_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_left_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_02",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_02",
            name = _item_melee.."/grips/syn_left_shiv_riceflail_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_left_shiv_riceflail_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_03/grip_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_left_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_left_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .135), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_left_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_left_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_left_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_left_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_left_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_03",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.135), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_03",
            name = _item_melee.."/grips/syn_left_shiv_riceflail_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_left_shiv_riceflail_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_04/grip_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_left_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_left_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .115), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_left_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_left_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_left_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_left_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_left_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_04",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.115), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_04",
            name = _item_melee.."/grips/syn_left_shiv_riceflail_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_left_shiv_riceflail_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_ml01/grip_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_left_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_left_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_left_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_left_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_left_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_left_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_left_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_ml01",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_ml01",
            name = _item_melee.."/grips/syn_left_shiv_riceflail_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_right_shiv_riceflail_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_05/grip_05"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_right_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_right_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_right_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_right_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_right_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_right_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_right_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_05",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_01",
            name = _item_melee.."/grips/syn_right_shiv_riceflail_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_right_shiv_riceflail_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_02/grip_02"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_right_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_right_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_right_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_right_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_right_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_right_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_right_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_02",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_02",
            name = _item_melee.."/grips/syn_right_shiv_riceflail_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_right_shiv_riceflail_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_03/grip_03"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_right_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_right_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .135), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_right_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_right_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_right_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_right_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_right_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_03",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.135), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_03",
            name = _item_melee.."/grips/syn_right_shiv_riceflail_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_right_shiv_riceflail_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_04/grip_04"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_right_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_right_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .115), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_right_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_right_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_right_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_right_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_right_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_04",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.115), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_04",
            name = _item_melee.."/grips/syn_right_shiv_riceflail_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_right_shiv_riceflail_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shovel/attachments/grip_ml01/grip_ml01"] = true,
		["content/weapons/player/attachments/trinket_hooks/trinket_hook_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/attachments/trinkets/trinket_1a/trinket_1a"] = true},
            attachments = {
                syn_right_riceflail_01 = {
                    item = _item_melee.."/grips/shovel_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_right_riceflail_02 = {
                    	item = _item.."/trinkets/trinket_hook_02",
                    	fix = {offset = {position = vector3_box(0, 0., .123), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_right_riceflail_03 = {
                    		item = "content/items/weapons/player/trinkets/trinket_1a",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
				children = {
                			syn_right_riceflail_04 = {
                    			item = _item_melee.."/syn_chain_connector", 
                    			fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, -45), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		        		children = {
                				syn_right_riceflail_05 = {
                    				item = "content/items/weapons/player/trinkets/trinket_1a",
                    				fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.)}, hide = {node = {11}}},
						children = {
                					syn_right_riceflail_06 = {
                    					item = _item_melee.."/syn_chain_ender", 
                    					fix = {offset = {position = vector3_box(0.024, 0.0, .0), rotation = vector3_box(0, 90, 90), scale = vector3_box(1, 1, 1)}},
		        				children = {
                						syn_right_riceflail_07 = {
                    						item = _item_melee.."/grips/shovel_grip_ml01",
                    						fix = {offset = {position = vector3_box(0, 0.0, 0.124), rotation = vector3_box(180, 0, 0), scale = vector3_box(1, 1, 1)}}},
							}},
						}},
					}},
				}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_riceflail_ml01",
            name = _item_melee.."/grips/syn_right_shiv_riceflail_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_01/grip_01"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_01/blade_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_01/handle_01"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_01",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_01_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_02_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_02/grip_02"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_02/handle_02"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_02",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_02_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_02_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_03_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_03/handle_03"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_03",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_03_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_03_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_04_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_04/grip_04"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_04/blade_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_04/handle_04"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_04",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_04_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_04_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_05_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_05/grip_05"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_05/blade_05"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_05/handle_05"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_05",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_05_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_05_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_06_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_06/grip_06"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_06/blade_06"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_06/handle_06"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_06",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_06",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_06_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_06_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_07_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_07/grip_07"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_07/blade_07"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_07/handle_07"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_07",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_07",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_07_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_07_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_08_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_08/grip_08"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_08/blade_08"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_08/handle_08"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_08",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_08",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_08",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_08_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_08_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_09_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_09/grip_09"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_10/blade_10"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_09/handle_09"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_09",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_09",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_10",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_09_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_09_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_ml01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_ml01/grip_ml01"] = true,
		["content/weapons/player/melee/combat_blade/attachments/blade_ml01/blade_ml01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_03/handle_03"] = true},
            attachments = {
                syn_shiv_ogryn_blade_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_shiv_ogryn_blade_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		        children = {
                		syn_shiv_ogryn_blade_03 = {
                    		item = _item_melee.."/blades/combat_blade_blade_ml01",
                    		fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.4)}}},
			}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_ml01_shiv",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_ml01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_00"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_00",
            name = _item_melee.."/syn_spike/syn_spike_00",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_01",
            name = _item_melee.."/syn_spike/syn_spike_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_02",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_02",
            name = _item_melee.."/syn_spike/syn_spike_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_03",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_03",
            name = _item_melee.."/syn_spike/syn_spike_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_04",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_04",
            name = _item_melee.."/syn_spike/syn_spike_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_05",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_05",
            name = _item_melee.."/syn_spike/syn_spike_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_06",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_06",
            name = _item_melee.."/syn_spike/syn_spike_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_07",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_07",
            name = _item_melee.."/syn_spike/syn_spike_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_spike/syn_spike_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "1",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/melee/sabre/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_spike_01 = {
                    item = _item_melee.."/blades/sabre_blade_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0.0), rotation = vector3_box(90, 0, 0), scale = vector3_box(5.5, 1.5, .35)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_spike_ml01",
            name = _item_melee.."/syn_spike/syn_spike_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/connector/syn_crowbar_connector_00"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item", 
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {},
            workflow_checklist = {},
            display_name = "loc_syn_crowbar_connector_00",
            name = _item_melee.."/connector/syn_crowbar_connector_00",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_01/shaft_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_human_power_maul_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_01/shaft_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_01_crowbar",
            name = _item_melee.."/body/syn_maul_body_01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_02_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_02/shaft_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_02/shaft_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_02_crowbar",
            name = _item_melee.."/body/syn_maul_body_02_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_03_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_03/shaft_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_03/shaft_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_03_crowbar",
            name = _item_melee.."/body/syn_maul_body_03_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_04_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_04/shaft_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_04/shaft_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_04_crowbar",
            name = _item_melee.."/body/syn_maul_body_04_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_05_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_05/shaft_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_05/shaft_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_05_crowbar",
            name = _item_melee.."/body/syn_maul_body_05_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_06_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_06/shaft_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_06/shaft_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_06_crowbar",
            name = _item_melee.."/body/syn_maul_body_06_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/body/syn_maul_body_ml01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/human_power_maul/attachments/shaft_ml01/shaft_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/human_power_maul/attachments/shaft_ml01/shaft_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_maul_body_ml01_crowbar",
            name = _item_melee.."/body/syn_maul_body_ml01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_02/grip_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_01/pommel_01"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_02/grip_02"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_01_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_02_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_01/grip_01"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_02_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_02_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_03_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_03/grip_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_03/grip_03"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_03_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_03_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_04_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_04/grip_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_04/pommel_04"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_04/grip_04"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_04_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_04_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_05_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_05/grip_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_05/grip_05"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_05_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_05_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_body_ml01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/grip_06/grip_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/axe/attachments/pommel_ml01/pommel_ml01"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_06/grip_06"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/axe_pommel_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_ml01_crowbar",
            name = _item_melee.."/grips/syn_combataxe_body_ml01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_body_01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/hatchet/attachments/pommel_01/pommel_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_01/grip_01"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/hatchet_pommel_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_01_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        }, 
        [_item_melee.."/grips/syn_hatchet_body_02_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_02/grip_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/hatchet/attachments/pommel_02/pommel_02"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_02/grip_02"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/hatchet_pommel_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_02_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_02_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        }, 
        [_item_melee.."/grips/syn_hatchet_body_03_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_03/grip_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/hatchet/attachments/pommel_ml01/pommel_ml01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/hatchet_pommel_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_03_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_03_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_body_04_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_04/grip_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/hatchet/attachments/pommel_04/pommel_04"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_04/grip_04"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/hatchet_pommel_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_04_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_04_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },  
        [_item_melee.."/grips/syn_hatchet_body_05_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_05/grip_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/grip_05/grip_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_05_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_05_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        }, 
        [_item_melee.."/grips/syn_hatchet_body_06_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/grip_06/grip_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_crowbar_chained_rig",
            resource_dependencies = {
		["content/weapons/player/melee/hatchet/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_06/grip_06"] = true},
            attachments = {
                	syn_crowbar_body_01 = {
                    	item = _item_melee.."/pommels/hatchet_pommel_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_06_crowbar",
            name = _item_melee.."/grips/syn_hatchet_body_06_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        }, 
        [_item_melee.."/grips/syn_combataxe_head_01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_01/head_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_01_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_head_02_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_02/head_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_02_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_02_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_head_03_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_03/head_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_03_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_03_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_head_04_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_04/head_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_04_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_04_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_head_05_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_05/head_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_05_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_05_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combataxe_head_ml01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/axe/attachments/head_ml01/head_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_combataxe_ml01_crowbar",
            name = _item_melee.."/grips/syn_combataxe_head_ml01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_01/head_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_01_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_02_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_02/head_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_02_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_02_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_03_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_03/head_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_03_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_03_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_04_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_04/head_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_04_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_04_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_05_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_05/head_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_05_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_05_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_06_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_06/head_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_06_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_06_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_hatchet_head_ml01_crowbar"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_hatchet_06_crowbar",
            name = _item_melee.."/grips/syn_hatchet_head_ml01_crowbar",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_crowbar_bladeguard_00"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/heads/syn_crowbar_bladeguard_00",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_crowbar_bladeguard_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/heads/syn_crowbar_bladeguard_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_crowbar_bladeguard_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/heads/syn_crowbar_bladeguard_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_bladeguard_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/power_sword/attachments/pommel_02/pommel_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/heads/syn_bladeguard_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_bladeguard_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/weapons/player/melee/power_sword/attachments/pommel_ml01/pommel_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/heads/syn_bladeguard_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_01",
            name = _item_melee.."/heads/syn_sabre_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_02",
            name = _item_melee.."/heads/syn_sabre_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_03",
            name = _item_melee.."/heads/syn_sabre_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_04",
            name = _item_melee.."/heads/syn_sabre_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_05",
            name = _item_melee.."/heads/syn_sabre_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_06",
            name = _item_melee.."/heads/syn_sabre_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_07",
            name = _item_melee.."/heads/syn_sabre_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_sabre_head_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/sabre_blade_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_sabre_ml01",
            name = _item_melee.."/heads/syn_sabre_head_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_01",
            name = _item_melee.."/heads/syn_combatsword_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_02",
            name = _item_melee.."/heads/syn_combatsword_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_03",
            name = _item_melee.."/heads/syn_combatsword_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_04",
            name = _item_melee.."/heads/syn_combatsword_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_05",
            name = _item_melee.."/heads/syn_combatsword_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_06",
            name = _item_melee.."/heads/syn_combatsword_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_07",
            name = _item_melee.."/heads/syn_combatsword_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_combatsword_head_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/combat_sword_blade_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_ml01",
            name = _item_melee.."/heads/syn_combatsword_head_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_01",
            name = _item_melee.."/heads/syn_falchion_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_02",
            name = _item_melee.."/heads/syn_falchion_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_03",
            name = _item_melee.."/heads/syn_falchion_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_04",
            name = _item_melee.."/heads/syn_falchion_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_05",
            name = _item_melee.."/heads/syn_falchion_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_06",
                    fix = {offset = {position = vector3_box(0, 0.0, -0.008), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_06",
            name = _item_melee.."/heads/syn_falchion_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/heads/syn_falchion_head_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_head_1 = {
                    item = _item_melee.."/blades/falchion_blade_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_head_2 = {
                    item = _item_melee.."/heads/syn_human_power_maul_short_head_03", 
                    fix = {offset = {position = vector3_box(0, 0.0, 0.356), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1.884)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_falchion_ml01",
            name = _item_melee.."/heads/syn_falchion_head_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blades/syn_shiv_blade_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver01/blade_05_ver01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver01/blade_05_ver01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/blades/syn_shiv_blade_05",
            workflow_state = "RELEASABLE",
        },
        [_item_melee.."/blades/syn_shiv_blade_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver02/blade_05_ver02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver02/blade_05_ver02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/blades/syn_shiv_blade_06",
            workflow_state = "RELEASABLE",
        },
        [_item_melee.."/grips/syn_shiv_grip_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver01/grip_05_ver01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver01/grip_05_ver01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_grip_blade_05",
            workflow_state = "RELEASABLE",
        },
        [_item_melee.."/grips/syn_shiv_grip_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver02/grip_05_ver02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver02/grip_05_ver02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_grip_blade_06",
            workflow_state = "RELEASABLE",
        },
        [_item_melee.."/grips/syn_shiv_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver01/blade_05_ver01"] = true,
                ["content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver01/grip_05_ver01"] = true},
            attachments = {
                syn_shiv_01 = {
                    item = _item_melee.."/grips/syn_shiv_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_02 = {
                    	item = _item_melee.."/blades/syn_shiv_blade_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_05",
            name = _item_melee.."/grips/syn_shiv_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_shiv_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/shiv/attachments/blade_05/blade_05_ver02/blade_05_ver02"] = true,
                ["content/weapons/player/melee/shiv/attachments/grip_05/grip_05_ver02/grip_05_ver02"] = true},
            attachments = {
                syn_shiv_01 = {
                    item = _item_melee.."/grips/syn_shiv_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_02 = {
                    	item = _item_melee.."/blades/syn_shiv_blade_06",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shiv_06",
            name = _item_melee.."/grips/syn_shiv_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_01_shiv",
            name = _item_melee.."/grips/syn_combatsword_01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_02_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_02_shiv",
            name = _item_melee.."/grips/syn_combatsword_02_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_03_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_03_shiv",
            name = _item_melee.."/grips/syn_combatsword_03_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_04_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_04_shiv",
            name = _item_melee.."/grips/syn_combatsword_04_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_05_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_05_shiv",
            name = _item_melee.."/grips/syn_combatsword_05_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_06_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_06/grip_06"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_06",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_06_shiv",
            name = _item_melee.."/grips/syn_combatsword_06_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_07_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_07",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_07_shiv",
            name = _item_melee.."/grips/syn_combatsword_07_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatsword_ml01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_ml01/grip_ml01"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_shiv_combat_sword_01 = {
                    item = _item_melee.."/grips/combat_sword_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_sword_02 = {
                    	item = _item_melee.."/blades/combat_sword_blade_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatsword_ml01_shiv",
            name = _item_melee.."/grips/syn_combatsword_ml01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_shiv_combat_knife_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_01_shiv",
            name = _item_melee.."/grips/syn_combatknife_01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_02_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_02_shiv",
            name = _item_melee.."/grips/syn_combatknife_02_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_03_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_03_shiv",
            name = _item_melee.."/grips/syn_combatknife_03_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_04_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_04_shiv",
            name = _item_melee.."/grips/syn_combatknife_04_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_05_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_05_shiv",
            name = _item_melee.."/grips/syn_combatknife_05_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_06_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_06/grip_06"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_06",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_06_shiv",
            name = _item_melee.."/grips/syn_combatknife_06_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_07_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_07/grip_07"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_07",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_07_shiv",
            name = _item_melee.."/grips/syn_combatknife_07_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_08_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_08/blade_08"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_08",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_08_shiv",
            name = _item_melee.."/grips/syn_combatknife_08_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_09_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_09/blade_09"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_09",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_09_shiv",
            name = _item_melee.."/grips/syn_combatknife_09_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_combatknife_ml01_shiv"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_dual_shivs_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/grip_ml01/grip_ml01"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_shiv_combat_knife_grip_01 = {
                    item = _item_melee.."/grips/combat_knife_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
		    children = {
                	syn_shiv_combat_knife_grip_02 = {
                    	item = _item_melee.."/blades/combat_knife_blade_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_combatknife_ml01_shiv",
            name = _item_melee.."/grips/syn_combatknife_ml01_shiv",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_01_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_01_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_01_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_02_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_02_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_02_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_03_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_03_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_03_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_04_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_04_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_04_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_05_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_05_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_05_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_06_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_06_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_06_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_07_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_07_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_07_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_08_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_08/blade_08"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_08",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_08_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_08_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_09_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_10/blade_10"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_10",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_09_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_09_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_ogryn_combatblade_blade_ml01_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_blade_01 = {
                    item = _item_melee.."/blades/combat_blade_blade_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_blade_ml01_knife",
            name = _item_melee.."/blade/syn_ogryn_combatblade_blade_ml01_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_01_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_01/handle_01"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_01",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_01_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_01_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_02_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_02/handle_02"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_02",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_02",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_02_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_02_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_03_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_03/handle_03"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_03",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_03_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_03_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_04_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_04/handle_04"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_04",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_04",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_04_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_04_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_05_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_05/handle_05"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_05",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_05",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_05_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_05_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_06_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_06/grip_06"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_06/handle_06"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_06",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_06",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_06_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_06_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_07_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_07/grip_07"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_07/handle_07"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_07",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_07",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_07_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_07_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_08_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_08/grip_08"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_08/handle_08"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_08",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_08",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_08_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_08_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_09_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_09/grip_09"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_09/handle_09"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_09",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_09",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_09_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_09_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_ogryn_combatblade_grip_ml01_knife"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_knife_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/combat_knife/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_ml01/grip_ml01"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/handle_03/handle_03"] = true},
            attachments = {
                syn_grip_01 = {
                    item = _item_ranged.."/handles/combat_blade_handle_03",
                    fix = {offset = {position = vector3_box(0, 0.0, 0), rotation = vector3_box(0, 0, 0), scale = vector3_box(.3, .3, .344)}},
		    children = {
                	syn_grip_02 = {
                    	item = _item_melee.."/grips/combat_blade_grip_ml01",
                    	fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_ogryn_combatblade_grip_ml01_knife",
            name = _item_melee.."/grips/syn_ogryn_combatblade_grip_ml01_knife",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_2h_chain_sword_grip_01_chainaxe"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_chain_sword/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/axe/attachments/grip_05/grip_05"] = true},
            attachments = {
                syn_gripcover_01 = {
                    item = _item_melee.."/grips/axe_grip_05",
                    fix = {offset = {position = vector3_box(0, 0.0, -.02), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, 1.3, .714)}}},
                syn_gripcover_02 = {
                    item = _item_melee.."/grips/syn_2h_chain_sword_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_2h_chain_sword_grip_01_chainaxe",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_2h_chain_sword_grip_02_chainaxe"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_chain_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_02/grip_02"] = true},
            attachments = {
                syn_gripcover_01 = {
                    item = _item_melee.."/grips/hatchet_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, -.024), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, 1.3, .964)}}},
                syn_gripcover_02 = {
                    item = _item_melee.."/grips/syn_2h_chain_sword_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_2h_chain_sword_grip_02_chainaxe",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_2h_chain_sword_grip_03_chainaxe"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_chain_sword/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_01/grip_01"] = true},
            attachments = {
                syn_gripcover_01 = {
                    item = _item_melee.."/grips/hatchet_grip_01",
                    fix = {offset = {position = vector3_box(0, 0.0, -.036), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.31, 1.1, 1.058)}}},
                syn_gripcover_02 = {
                    item = _item_melee.."/grips/syn_2h_chain_sword_grip_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_2h_chain_sword_grip_03_chainaxe",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_2h_chain_sword_grip_04_chainaxe"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_chain_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_02/grip_02"] = true},
            attachments = {
                syn_gripcover_01 = {
                    item = _item_melee.."/grips/hatchet_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, -.022), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.14, 1.14, .946)}}},
                syn_gripcover_02 = {
                    item = _item_melee.."/grips/syn_2h_chain_sword_grip_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_2h_chain_sword_grip_04_chainaxe",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/grips/syn_2h_chain_sword_grip_ml01_chainaxe"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_chain_sword/attachments/grip_ml01/grip_ml01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_02/grip_02"] = true},
            attachments = {
                syn_gripcover_01 = {
                    item = _item_melee.."/grips/hatchet_grip_02",
                    fix = {offset = {position = vector3_box(0, 0.0, -.024), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, 1.3, .964)}}},
                syn_gripcover_02 = {
                    item = _item_melee.."/grips/syn_2h_chain_sword_grip_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/grips/syn_2h_chain_sword_grip_ml01_chainaxe",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_01/shaft_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_01/shaft_01"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_01/pommel_01"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_01",
            name = _item_melee.."/syn_2h_chainsword_shaft_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_02/shaft_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_02/shaft_02"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_02",
            name = _item_melee.."/syn_2h_chainsword_shaft_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_03/shaft_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_03/shaft_03"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_03/pommel_03"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_03",
            name = _item_melee.."/syn_2h_chainsword_shaft_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_04/shaft_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_04/shaft_04"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_04/pommel_04"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_04",
            name = _item_melee.."/syn_2h_chainsword_shaft_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_05/shaft_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_05/shaft_05"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_05/pommel_05"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_05",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_05",
            name = _item_melee.."/syn_2h_chainsword_shaft_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_2h_chainsword_shaft_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/thunder_hammer/attachments/shaft_ml01/shaft_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_2h_chain_sword_chained_rig",
            resource_dependencies = {
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_ml01/shaft_ml01"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/pommel_ml01/pommel_ml01"] = true},
            attachments = {
                syn_grip_1 = {
                    item = _item_melee.."/pommels/thunder_hammer_pommel_ml01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_chainsword_shaft_ml01",
            name = _item_melee.."/syn_2h_chainsword_shaft_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_hilt_skull"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_skull",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_triangle"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/force_staff/attachments/head_04/head_04",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_triangle",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_sideblade"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/sabre/attachments/blade_02/blade_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 6,
      		resource_dependencies = {["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_sideblade",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_sidehorn"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/sabre/attachments/blade_03/blade_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 6,
      		resource_dependencies = {["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_sidehorn",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_sideblade_2"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/sabre/attachments/blade_02/blade_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 9,
      		resource_dependencies = {["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_sideblade",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_sidehorn_2"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/sabre/attachments/blade_03/blade_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 9,
      		resource_dependencies = {["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_sidehorn",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt_sidepoint"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/axe/attachments/pommel_02/pommel_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_sidepoint",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_hilt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_02/hilt_02"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_frostmourne = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
                    children = {
                	syn_frostmourne_1 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .0, 0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.15, 1.08, 2.13)}}},
                	syn_frostmourne_2 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, -.124, 0.086), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_3 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .124, 0.086), rotation = vector3_box(0, 0, 180), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_4 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_triangle",
                    	fix = {offset = {position = vector3_box(0, .0, 0.05), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.15, 0.55, 1.464)}}},
                	syn_frostmourne_5 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade",
                    	fix = {offset = {position = vector3_box(0, -.016, 0.16), rotation = vector3_box(110, 0, 180), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_6 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade",
                    	fix = {offset = {position = vector3_box(0, .016, 0.16), rotation = vector3_box(-110, 0, 0), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_7 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn",
                    	fix = {offset = {position = vector3_box(0, -.135, -0.0053), rotation = vector3_box(-170, 0, 0), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_8 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn",
                    	fix = {offset = {position = vector3_box(0, .135, -0.0053), rotation = vector3_box(170, 0, 180), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_9 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidepoint",
                    	fix = {offset = {position = vector3_box(0, .124, 0.07), rotation = vector3_box(180, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_10 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidepoint",
                    	fix = {offset = {position = vector3_box(0, -.124, 0.07), rotation = vector3_box(180, 0, 0), scale = vector3_box(.6, .6, .6)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_hilt",
            name = _item_melee.."/syn_frostmourne_hilt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_hilt_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/hilt_04/hilt_04"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_frostmourne = {
                    item = _item_melee.."/hilts/2h_force_sword_hilt_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
                    children = {
                	syn_frostmourne_1 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .0, 0.198), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.33, 1.2, 2.13)}}},
                	syn_frostmourne_2 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .088, 0.064), rotation = vector3_box(0, 0, 180), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_3 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, -.088, 0.064), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_4 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_triangle",
                    	fix = {offset = {position = vector3_box(0, .0, 0.05), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.15, 0.55, 1.464)}}},
                	syn_frostmourne_5 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade_2",
                    	fix = {offset = {position = vector3_box(0, -.016, -0.06), rotation = vector3_box(110, 0, 180), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_6 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade_2",
                    	fix = {offset = {position = vector3_box(0, .016, -0.06), rotation = vector3_box(-110, 0, 0), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_7 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn_2",
                    	fix = {offset = {position = vector3_box(0, -.102, -0.204), rotation = vector3_box(-170, 0, 0), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_8 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn_2",
                    	fix = {offset = {position = vector3_box(0, .102, -0.204), rotation = vector3_box(170, 0, 180), scale = vector3_box(1.4, 0.49, .066)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_hilt_alt",
            name = _item_melee.."/syn_frostmourne_hilt_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_connector"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_02/hilt_02"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_frostmourne = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_02",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
                    children = {
                	syn_frostmourne_1 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .0, 0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.15, 1.08, 2.13)}}},
                	syn_frostmourne_2 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, -.124, 0.086), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_3 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .124, 0.086), rotation = vector3_box(0, 0, 180), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_4 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_triangle",
                    	fix = {offset = {position = vector3_box(0, .0, 0.05), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.15, 0.55, 1.464)}}},
                	syn_frostmourne_5 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade",
                    	fix = {offset = {position = vector3_box(0, -.016, 0.16), rotation = vector3_box(110, 0, 180), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_6 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade",
                    	fix = {offset = {position = vector3_box(0, .016, 0.16), rotation = vector3_box(-110, 0, 0), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_7 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn",
                    	fix = {offset = {position = vector3_box(0, -.135, -0.0053), rotation = vector3_box(-170, 0, 0), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_8 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn",
                    	fix = {offset = {position = vector3_box(0, .135, -0.0053), rotation = vector3_box(170, 0, 180), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_9 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidepoint",
                    	fix = {offset = {position = vector3_box(0, .124, 0.07), rotation = vector3_box(180, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_10 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidepoint",
                    	fix = {offset = {position = vector3_box(0, -.124, 0.07), rotation = vector3_box(180, 0, 0), scale = vector3_box(.6, .6, .6)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_hilt",
            name = _item_melee.."/syn_frostmourne_connector",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_connector_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/hilt_04/hilt_04"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_frostmourne = {
                    item = _item_melee.."/hilts/2h_force_sword_hilt_04",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
                    children = {
                	syn_frostmourne_1 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .0, 0.198), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.33, 1.2, 2.13)}}},
                	syn_frostmourne_2 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, .088, 0.064), rotation = vector3_box(0, 0, 180), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_3 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_skull",
                    	fix = {offset = {position = vector3_box(0, -.088, 0.064), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .6)}}},
                	syn_frostmourne_4 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_triangle",
                    	fix = {offset = {position = vector3_box(0, .0, 0.05), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.15, 0.55, 1.464)}}},
                	syn_frostmourne_5 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade_2",
                    	fix = {offset = {position = vector3_box(0, -.016, -0.06), rotation = vector3_box(110, 0, 180), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_6 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sideblade_2",
                    	fix = {offset = {position = vector3_box(0, .016, -0.06), rotation = vector3_box(-110, 0, 0), scale = vector3_box(1, 1.45, .14)}}},
                	syn_frostmourne_7 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn_2",
                    	fix = {offset = {position = vector3_box(0, -.102, -0.204), rotation = vector3_box(-170, 0, 0), scale = vector3_box(1.4, 0.49, .066)}}},
                	syn_frostmourne_8 = {
                    	item = _item_melee.."/syn_frostmourne_hilt_sidehorn_2",
                    	fix = {offset = {position = vector3_box(0, .102, -0.204), rotation = vector3_box(170, 0, 180), scale = vector3_box(1.4, 0.49, .066)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_hilt_alt",
            name = _item_melee.."/syn_frostmourne_connector_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_leftblade"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/combat_sword/attachments/blade_06/blade_06",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/combat_sword/attachments/blade_06/blade_06"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_leftblade",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_rightblade"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/combat_blade/attachments/blade_03/blade_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/combat_blade/attachments/blade_03/blade_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_hilt_rightblade",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_topblade"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_topblade",
      		item_list_faction = "Player",
            	disable_vfx_spawner_exclusion = true,
    	},
        [_item_melee.."/syn_frostmourne_centerblade"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/combat_knife/attachments/blade_06/blade_06",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/combat_knife/attachments/blade_06/blade_06"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_frostmourne_centerblade",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_frostmourne_blade"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/hilt_04/hilt_04"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_04/head_04"] = true,
                ["content/weapons/player/melee/sabre/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_02/pommel_02"] = true},
            attachments = {
                syn_blade_4 = {
                	item = _item_melee.."/syn_frostmourne_topblade",
                	fix = {offset = {position = vector3_box(0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.2, 1.44, 0.95)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_blade = {
                    item = _item_melee.."/syn_frostmourne_leftblade",
                    fix = {offset = {position = vector3_box(0.0, .0145, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .606, .734)}}},
                syn_blade_1 = {
               		item = _item_melee.."/syn_frostmourne_rightblade",
               		fix = {offset = {position = vector3_box(0.0, -.0135, 0.036), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.304, .318, 0.594)}}},
                syn_blade_2 = {
                	item = _item_melee.."/syn_frostmourne_topblade",
                	fix = {offset = {position = vector3_box(0.0, .0, 0.24), rotation = vector3_box(0, 0, 0), scale = vector3_box(.682, .858, 0.668)}}},
                syn_blade_3 = {
                	item = _item_melee.."/syn_frostmourne_centerblade",
                	fix = {offset = {position = vector3_box(0.0, .0, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.666, 1.3, 2.422)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_blade",
            name = _item_melee.."/syn_frostmourne_blade",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_holymoonlight_bladeshroudac12"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/force_staff/attachments/head_06/head_06",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/force_staff/attachments/head_06/head_06"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac12",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_bladeshroudac10"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_force_sword/attachments/pommel_01/pommel_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_force_sword/attachments/pommel_01/pommel_01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac10",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_bladeshroudac9"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/force_sword/attachments/pommel_05/pommel_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/force_sword/attachments/pommel_05/pommel_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac9",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_bladeshroudac7"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/power_sword/attachments/grip_05/grip_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/power_sword/attachments/grip_05/grip_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac7",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_cloth"] = {
      		show_in_1p = true,
      		base_unit = "content/characters/player/human/attachments_gear/upperbody/zealot_inquisition_upperbody_a/zealot_inquisition_upperbody_a_cloak",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/characters/player/human/attachments_gear/upperbody/zealot_inquisition_upperbody_a/zealot_inquisition_upperbody_a_cloak"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac7",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_hilt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/force_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_01/pommel_01"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_bca"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_nm"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_orm"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_06/head_06"] = true},
            attachments = {
                syn_holymoonlight = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_holymoonlight_13 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac12",
                    	fix = {offset = {position = vector3_box(0.0075, .0, 0.02), rotation = vector3_box(0, 0, 0), scale = vector3_box(.74, .5, 0.3)}}},
                	syn_holymoonlight_12 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac12",
                    	fix = {offset = {position = vector3_box(-0.0075, .0, 0.02), rotation = vector3_box(0, 0, 0), scale = vector3_box(.74, .5, 0.3)}}},
                	syn_holymoonlight_11 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac10",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_iron_wear_01",
                    	},
      			material_overrides = {
				"oxidized_metal_iron_wear_01",
      			},
                    	fix = {offset = {position = vector3_box(0, .1083, 0.0909), rotation = vector3_box(113, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_holymoonlight_10 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac10",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_iron_wear_01",
                    	},
      			material_overrides = {
				"oxidized_metal_iron_wear_01",
      			},
                    	fix = {offset = {position = vector3_box(0, -.1083, 0.0909), rotation = vector3_box(-113, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_holymoonlight_9 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac9",
                    	fix = {offset = {position = vector3_box(0, .0, -0.044), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.0, 1.0, 1)}}},
                	syn_holymoonlight_8 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac7",
                    	fix = {offset = {position = vector3_box(0.0, -.0884, 0.0825), rotation = vector3_box(67, 0, 180), scale = vector3_box(.93, .93, .86)}}},
                	syn_holymoonlight_7 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac7",
                    	fix = {offset = {position = vector3_box(0.0, .0884, 0.0825), rotation = vector3_box(-67, 0, 0), scale = vector3_box(.93, .93, .86)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_holymoonlight_hilt",
            name = _item_melee.."/syn_holymoonlight_hilt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_holymoonlight_connector"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/force_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_01/pommel_01"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_bca"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_nm"] = true,
                ["content/characters/tiling_materials/iron_01/metal_iron_01_orm"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_06/head_06"] = true},
            attachments = {
                syn_holymoonlight = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_holymoonlight_13 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac12",
                    	fix = {offset = {position = vector3_box(0.0075, .0, 0.02), rotation = vector3_box(0, 0, 0), scale = vector3_box(.74, .5, 0.3)}}},
                	syn_holymoonlight_12 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac12",
                    	fix = {offset = {position = vector3_box(-0.0075, .0, 0.02), rotation = vector3_box(0, 0, 0), scale = vector3_box(.74, .5, 0.3)}}},
                	syn_holymoonlight_11 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac10",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_iron_wear_01",
                    	},
      			material_overrides = {
				"oxidized_metal_iron_wear_01",
      			},
                    	fix = {offset = {position = vector3_box(0, .1083, 0.0909), rotation = vector3_box(113, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_holymoonlight_10 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac10",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_iron_wear_01",
                    	},
      			material_overrides = {
				"oxidized_metal_iron_wear_01",
      			},
                    	fix = {offset = {position = vector3_box(0, -.1083, 0.0909), rotation = vector3_box(-113, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_holymoonlight_9 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac9",
                    	fix = {offset = {position = vector3_box(0, .0, -0.044), rotation = vector3_box(180, 0, 0), scale = vector3_box(1.0, 1.0, 1)}}},
                	syn_holymoonlight_8 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac7",
                    	fix = {offset = {position = vector3_box(0.0, -.0884, 0.0825), rotation = vector3_box(67, 0, 180), scale = vector3_box(.93, .93, .86)}}},
                	syn_holymoonlight_7 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroudac7",
                    	fix = {offset = {position = vector3_box(0.0, .0884, 0.0825), rotation = vector3_box(-67, 0, 0), scale = vector3_box(.93, .93, .86)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_holymoonlight_hilt",
            name = _item_melee.."/syn_holymoonlight_connector",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_holymoonlight_blade_main"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_blade_main",
      		item_list_faction = "Player",
            	disable_vfx_spawner_exclusion = true,
    	},
        [_item_melee.."/syn_holymoonlight_bladeshroud"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/ranged/lasgun_rifle_krieg/attachments/barrel_05/barrel_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/ranged/lasgun_rifle_krieg/attachments/barrel_05/barrel_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroud",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_holymoonlight_bladeshroudac"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_force_sword/attachments/blade_03/blade_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_force_sword/attachments/blade_03/blade_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_holymoonlight_bladeshroudac",
      		item_list_faction = "Player",
            	disable_vfx_spawner_exclusion = true,
    	},
        [_item_melee.."/syn_holymoonlight_blade"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/ranged/lasgun_rifle_krieg/attachments/barrel_05/barrel_05"] = true,
                ["content/weapons/player/ranged/lasgun_rifle/attachments/sight_01/sight_01"] = true,
                ["content/characters/tiling_materials/fabric_wool_01/wool_01_bc"] = true,
                ["content/characters/tiling_materials/fabric_wool_01/wool_01_nm"] = true,
                ["content/characters/tiling_materials/fabric_wool_01/wool_01_orm"] = true,
                ["content/textures/colors/1_colour_white_01"] = true,
                ["content/characters/player/human/attachments_gear/upperbody/zealot_inquisition_upperbody_a/zealot_inquisition_upperbody_a_cloak"] = true},
            attachments = {
                syn_holymoonlightblade = {
                    item = _item_melee.."/syn_holymoonlight_blade_main",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 180), scale = vector3_box(1, .8, 1)}},
                    children = {
                	syn_holymoonlightblade_1 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroud",
                    	fix = {offset = {position = vector3_box(0.0, .024, 0.064), rotation = vector3_box(91, 180, 0), scale = vector3_box(0.378, .95, 0.7)}, hide = {mesh = {5,6,7,8,9,10}}}},
                	syn_holymoonlightblade_2 = {
                    	item = _item_melee.."/syn_holymoonlight_bladeshroud",
                    	fix = {offset = {position = vector3_box(0.0, -.024, 0.064), rotation = vector3_box(89, 0, 0), scale = vector3_box(0.378, .8, 0.7)}, hide = {mesh = {5,6,7,8,9,10}}}},
                	syn_holymoonlightblade_3 = {
                    	item = _item_melee.."/syn_holymoonlight_cloth",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/fabric_wool_01_wear_02",
                        	[2] = "content/items/material_overrides/gear_colors/color_1_colour_white_01",
                    	},
      			material_overrides = {
				"color_1_colour_white_01",
				"fabric_wool_01_wear_02",
      			},
                    	fix = {offset = {position = vector3_box(-0.0265, -.0807, -0.2144), rotation = vector3_box(-12, 6, -88.5), scale = vector3_box(.1, .1, .2)}}},
                	syn_holymoonlightblade_4 = {
                    	item = _item_melee.."/syn_holymoonlight_cloth",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/fabric_wool_01_wear_02",
                        	[2] = "content/items/material_overrides/gear_colors/color_1_colour_white_01",
                    	},
      			material_overrides = {
				"color_1_colour_white_01",
				"fabric_wool_01_wear_02",
      			},
                    	fix = {offset = {position = vector3_box(-0.0344, .0466, -0.1464), rotation = vector3_box(6.77, 8.2, 100.55), scale = vector3_box(.1, .1, .15)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_holymoonlight_blade",
            name = _item_melee.."/syn_holymoonlight_blade",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_no_extra_energy"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02"] = true},
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/syn_no_extra_energy",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = false,
        },
        [_item_melee.."/syn_holymoonlight_extra_energy"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_extra_energy_1 = {
                    item = _item_melee.."/syn_holymoonlight_bladeshroudac",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {4,5,6,7,8,9,10}}},
                },
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/syn_holymoonlight_extra_energy",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_negotiator_bladeshroudac13_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/thunder_hammer/attachments/head_03/head_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/thunder_hammer/attachments/head_03/head_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac13_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_bladeshroudac13_02"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/force_staff/attachments/head_02/head_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/force_staff/attachments/head_02/head_02"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac13_02",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_bladeshroudac12_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac12_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_bladeshroudac12_02"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/2h_pickaxe_ogryn/attachments/head_07/head_07",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/2h_pickaxe_ogryn/attachments/head_07/head_07"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac12_02",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_bladeshroudac11_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/force_staff/attachments/head_03/head_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/force_staff/attachments/head_03/head_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac11_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_bladeshroudac10_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/falchion/attachments/blade_03/blade_03",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/falchion/attachments/blade_03/blade_03"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_negotiator_bladeshroudac10_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_negotiator_hilt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_negotiator = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_negotiator_13 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.082), rotation = vector3_box(0, 0, 0), scale = vector3_box(.4, .8, 0.7)}}},
                	syn_negotiator_12 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.09), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.06, 1.06, 3)}}},
                	syn_negotiator_11 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac11_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.146), rotation = vector3_box(0, 0, 0), scale = vector3_box(.76, .392, .85)}}},
                	syn_negotiator_10 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, .12, 0.06), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, .3)}}},
                	syn_negotiator_9 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, -.12, 0.06), rotation = vector3_box(0, 0, 180), scale = vector3_box(.7, .7, .3)}}},
                	syn_negotiator_8 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, .12, 0.06), rotation = vector3_box(0, 180, 0), scale = vector3_box(.7, .7, .15)}}},
                	syn_negotiator_7 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, -.12, 0.06), rotation = vector3_box(0, 180, 180), scale = vector3_box(.7, .7, .15)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_negotiator_hilt",
            name = _item_melee.."/syn_negotiator_hilt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_negotiator_hilt_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_02/head_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/2h_pickaxe_ogryn/attachments/head_07/head_07"] = true},
            attachments = {
                syn_negotiator = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_negotiator_13 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac13_02",
                    	fix = {offset = {position = vector3_box(0.00, .0, .084), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.1, 1.134, .556)}}},
                	syn_negotiator_12 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_02",
                    	fix = {offset = {position = vector3_box(0.00, .046, 0.146), rotation = vector3_box(-90, 0, 90), scale = vector3_box(.3, .1, .14)}}},
                	syn_negotiator_11 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_02",
                    	fix = {offset = {position = vector3_box(0.00, -.046, 0.146), rotation = vector3_box(90, 0, 90), scale = vector3_box(.3, .1, .14)}}},
                	syn_negotiator_10 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.09), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.06, 1.06, 3)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_negotiator_hilt_alt",
            name = _item_melee.."/syn_negotiator_hilt_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_negotiator_connector"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            force_link_children = "false",
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_03/head_03"] = true,
                ["content/weapons/player/melee/falchion/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_negotiator = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_negotiator_13 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.082), rotation = vector3_box(0, 0, 0), scale = vector3_box(.4, .8, 0.7)}}},
                	syn_negotiator_12 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.09), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.06, 1.06, 3)}}},
                	syn_negotiator_11 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac11_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.146), rotation = vector3_box(0, 0, 0), scale = vector3_box(.76, .392, .85)}}},
                	syn_negotiator_10 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, .12, 0.06), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, .3)}}},
                	syn_negotiator_9 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, -.12, 0.06), rotation = vector3_box(0, 0, 180), scale = vector3_box(.7, .7, .3)}}},
                	syn_negotiator_8 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, .12, 0.06), rotation = vector3_box(0, 180, 0), scale = vector3_box(.7, .7, .15)}}},
                	syn_negotiator_7 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac10_01",
                    	fix = {offset = {position = vector3_box(0.0, -.12, 0.06), rotation = vector3_box(0, 180, 180), scale = vector3_box(.7, .7, .15)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_negotiator_hilt",
            name = _item_melee.."/syn_negotiator_connector",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_negotiator_connector_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            force_link_children = "false",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/melee/force_staff/attachments/head_02/head_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/2h_pickaxe_ogryn/attachments/head_07/head_07"] = true},
            attachments = {
                syn_negotiator = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_negotiator_13 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac13_02",
                    	fix = {offset = {position = vector3_box(0.00, .0, .084), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.1, 1.134, .556)}}},
                	syn_negotiator_12 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_02",
                    	fix = {offset = {position = vector3_box(0.00, .046, 0.146), rotation = vector3_box(-90, 0, 90), scale = vector3_box(.3, .1, .14)}}},
                	syn_negotiator_11 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_02",
                    	fix = {offset = {position = vector3_box(0.00, -.046, 0.146), rotation = vector3_box(90, 0, 90), scale = vector3_box(.3, .1, .14)}}},
                	syn_negotiator_10 = {
                    	item = _item_melee.."/syn_negotiator_bladeshroudac12_01",
                    	fix = {offset = {position = vector3_box(0.00, .0, 0.09), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.06, 1.06, 3)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_negotiator_hilt_alt",
            name = _item_melee.."/syn_negotiator_connector_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_eaglehead_bladeshroudac13_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/attachments/emblems/emblem_15/emblem_15",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/attachments/emblems/emblem_15/emblem_15"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_eaglehead_bladeshroudac09_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/attachments/emblems/emblem_13/emblem_13",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/attachments/emblems/emblem_13/emblem_13"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_eaglehead_bladeshroudac07_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/shovel/attachments/pommel_01/pommel_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/shovel/attachments/pommel_01/pommel_01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/syn_eaglehead_hilt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_hilt_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/attachments/emblems/emblem_15/emblem_15"] = true,
                ["content/weapons/player/attachments/emblems/emblem_13/emblem_13"] = true,
                ["content/weapons/player/melee/shovel/attachments/pommel_01/pommel_01"] = true},
            attachments = {
                syn_eaglehead = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, -.042), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_eaglehead_13 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.065, 0.06), rotation = vector3_box(15, 180, 0), scale = vector3_box(2.75, 7, 5)}}},
                	syn_eaglehead_12 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.065, 0.06), rotation = vector3_box(15, 180, 0), scale = vector3_box(-2.75, 7, 5)}}},
                	syn_eaglehead_11 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, -0.065, 0.06), rotation = vector3_box(-15, 180, 180), scale = vector3_box(-2.75, 7, 5)}}},
                	syn_eaglehead_10 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, -0.065, 0.06), rotation = vector3_box(-15, 180, 180), scale = vector3_box(2.75, 7, 5)}}},
                	syn_eaglehead_09 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.19), rotation = vector3_box(0, 0, 180), scale = vector3_box(5, 5, 5)}}},
                	syn_eaglehead_08 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(5, 5, 5)}}},
                	syn_eaglehead_07 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac07_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.086), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_eaglehead_hilt",
            name = _item_melee.."/syn_eaglehead_hilt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_eaglehead_connector"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_connector_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/hilt_01/hilt_01"] = true,
                ["content/weapons/player/attachments/emblems/emblem_15/emblem_15"] = true,
                ["content/weapons/player/attachments/emblems/emblem_13/emblem_13"] = true,
                ["content/weapons/player/melee/shovel/attachments/pommel_01/pommel_01"] = true},
            attachments = {
                syn_eaglehead = {
                    item = _item_melee.."/hilts/2h_power_sword_hilt_01",
                    fix = {offset = {position = vector3_box(0, 0.0, -.042), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
                    children = {
                	syn_eaglehead_13 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.065, 0.06), rotation = vector3_box(15, 180, 0), scale = vector3_box(2.75, 7, 5)}}},
                	syn_eaglehead_12 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.065, 0.06), rotation = vector3_box(15, 180, 0), scale = vector3_box(-2.75, 7, 5)}}},
                	syn_eaglehead_11 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, -0.065, 0.06), rotation = vector3_box(-15, 180, 180), scale = vector3_box(-2.75, 7, 5)}}},
                	syn_eaglehead_10 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac13_01",
                    	fix = {offset = {position = vector3_box(0.0, -0.065, 0.06), rotation = vector3_box(-15, 180, 180), scale = vector3_box(2.75, 7, 5)}}},
                	syn_eaglehead_09 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.19), rotation = vector3_box(0, 0, 180), scale = vector3_box(5, 5, 5)}}},
                	syn_eaglehead_08 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac09_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(5, 5, 5)}}},
                	syn_eaglehead_07 = {
                    	item = _item_melee.."/syn_eaglehead_bladeshroudac07_01",
                    	fix = {offset = {position = vector3_box(0.0, .0, 0.086), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_eaglehead_hilt",
            name = _item_melee.."/syn_eaglehead_connector",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.0, -0.0175, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},    
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_01",
            name = _item_melee.."/syn_zweiblade_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0155, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_02",
                    fix = {offset = {position = vector3_box(0.0, -0.0155, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_02",
            name = _item_melee.."/syn_zweiblade_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_03",
                    fix = {offset = {position = vector3_box(0.0, -0.0175, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_03",
            name = _item_melee.."/syn_zweiblade_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0155, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_04",
                    fix = {offset = {position = vector3_box(0.0, -0.0155, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_04",
            name = _item_melee.."/syn_zweiblade_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_05/blade_05"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_05",
                    fix = {offset = {position = vector3_box(0.0, 0.017, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_05",
                    fix = {offset = {position = vector3_box(0.0, -0.017, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_05",
            name = _item_melee.."/syn_zweiblade_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_06/blade_06"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_06",
                    fix = {offset = {position = vector3_box(0.0, 0.017, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_06",
                    fix = {offset = {position = vector3_box(0.0, -0.017, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_06",
            name = _item_melee.."/syn_zweiblade_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_07",
                    fix = {offset = {position = vector3_box(0.0, 0.0155, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_07",
                    fix = {offset = {position = vector3_box(0.0, -0.0155, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_07",
            name = _item_melee.."/syn_zweiblade_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_zweiblade_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_zwei = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.0, .0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.3, .65, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}}},
                syn_zwei_01 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0155, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(0.6, .5, 1.5)}}},
                syn_zwei_02 = {
                    item = _item_melee.."/blades/syn_combat_sword_blade_ml01",
                    fix = {offset = {position = vector3_box(0.0, -0.0155, 0.0), rotation = vector3_box(0, 0, 180), scale = vector3_box(0.6, .5, 1.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_zweiblade_08",
            name = _item_melee.."/syn_zweiblade_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_shaft"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_human_power_maul_short_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul_short/attachments/shaft_03/shaft_03"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/hatchet/attachments/pommel_04/pommel_04"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_01/grip_01"] = true},
            attachments = {
                syn_frostmourne_shaft = {
                    item = _item_ranged.."/shafts/human_power_maul_short_shaft_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, -0.098), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}},
                    children = {
                	syn_frostmourne_shaft_1 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.142), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_2 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.101), rotation = vector3_box(0, 0, 0), scale = vector3_box(.8, .8, 1.5)}}},
                	syn_frostmourne_shaft_3 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.012), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_4 = {
                    	item = _item_melee.."/grips/syn_hatchet_grip_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_frostmourne_shaft_5 = {
                    	item = _item_melee.."/pommels/syn_hatchet_pommel_04",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -0.138), rotation = vector3_box(0, 180, 0), scale = vector3_box(1.35, 1.35, 1.35)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_shaft",
            name = _item_melee.."/syn_frostmourne_shaft",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_grip"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_sword_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/hatchet/attachments/pommel_04/pommel_04"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_01/grip_01"] = true},
            attachments = {
                syn_frostmourne_shaft = {
                    item = _item_melee.."/grips/combat_sword_grip_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, -0.098), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}},
                    children = {
                	syn_frostmourne_shaft_1 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.142), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_2 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.101), rotation = vector3_box(0, 0, 0), scale = vector3_box(.8, .8, 1.5)}}},
                	syn_frostmourne_shaft_3 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.012), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_4 = {
                    	item = _item_melee.."/grips/syn_hatchet_grip_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_frostmourne_shaft_5 = {
                    	item = _item_melee.."/pommels/syn_hatchet_pommel_04",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -0.138), rotation = vector3_box(0, 180, 0), scale = vector3_box(1.35, 1.35, 1.35)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_shaft",
            name = _item_melee.."/syn_frostmourne_grip",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_frostmourne_grip_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_sword_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/grip_01/grip_01"] = true,
                ["content/weapons/player/melee/axe/attachments/pommel_05/pommel_05"] = true,
                ["content/weapons/player/melee/hatchet/attachments/pommel_04/pommel_04"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_01/grip_01"] = true},
            attachments = {
                syn_frostmourne_shaft = {
                    item = _item_melee.."/grips/combat_sword_grip_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, -0.098), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}},
                    children = {
                	syn_frostmourne_shaft_1 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.142), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_2 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.101), rotation = vector3_box(0, 0, 0), scale = vector3_box(.8, .8, 1.5)}}},
                	syn_frostmourne_shaft_3 = {
                    	item = _item_melee.."/pommels/syn_axe_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.012), rotation = vector3_box(0, 0, 0), scale = vector3_box(.7, .7, 1)}}},
                	syn_frostmourne_shaft_4 = {
                    	item = _item_melee.."/grips/syn_hatchet_grip_01",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                	syn_frostmourne_shaft_5 = {
                    	item = _item_melee.."/pommels/syn_hatchet_pommel_04",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -0.138), rotation = vector3_box(0, 180, 0), scale = vector3_box(1.35, 1.35, 1.35)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_frostmourne_shaft",
            name = _item_melee.."/syn_frostmourne_grip_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_holymoonlight_grip"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "rp_combat_sword_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/grip_05/grip_05"] = true,
                ["content/weapons/player/melee/force_sword/attachments/pommel_05/pommel_05"] = true},
            attachments = {
                syn_holymoonlight_grip_1 = {
                    item = _item_melee.."/grips/2h_force_sword_grip_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}},
                    children = {
                	syn_holymoonlight_grip_2 = {
                    	item = _item_melee.."/pommels/force_sword_pommel_05",
                    	fix = {offset = {position = vector3_box(0.0, 0.0, 0.), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
		    },
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_holymoonlight_grip",
            name = _item_melee.."/syn_holymoonlight_grip",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/syn_power_sword_connector_01"] = {
      		show_in_1p = true,
      		base_unit = "content/weapons/player/melee/power_sword/attachments/hilt_01/hilt_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {["content/weapons/player/melee/power_sword/attachments/hilt_01/hilt_01"] = true},
            	attachments = {},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/syn_power_sword_connector_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/pickaxe/syn_battle_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_01",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_02",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_03",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_04",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.49, 3.49, 3.49)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.51, 3.51, 3.51)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_05",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_06",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_07",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_08",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_09",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_10",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_11",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_06",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_12",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_battle_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.495, 3.495, 3.495)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -90), scale = vector3_box(3.505, 3.505, 3.505)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_13",
            name = _item_melee.."/pickaxe/syn_battle_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_01",
            name = _item_melee.."/pickaxe/syn_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_02",
            name = _item_melee.."/pickaxe/syn_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_03",
            name = _item_melee.."/pickaxe/syn_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_04",
            name = _item_melee.."/pickaxe/syn_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_05",
            name = _item_melee.."/pickaxe/syn_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_06",
            name = _item_melee.."/pickaxe/syn_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_07",
            name = _item_melee.."/pickaxe/syn_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_08",
            name = _item_melee.."/pickaxe/syn_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_09",
            name = _item_melee.."/pickaxe/syn_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_10",
            name = _item_melee.."/pickaxe/syn_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_11",
            name = _item_melee.."/pickaxe/syn_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_12",
            name = _item_melee.."/pickaxe/syn_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pickaxe/syn_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 90), scale = vector3_box(3.5, 3.5, 3.5)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_13",
            name = _item_melee.."/pickaxe/syn_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_01",
            name = _item_melee.."/ogryn/syn_battle_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_02",
            name = _item_melee.."/ogryn/syn_battle_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_03",
            name = _item_melee.."/ogryn/syn_battle_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_04",
            name = _item_melee.."/ogryn/syn_battle_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.99, 2.99, 2.99)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.01, 3.01, 3.01)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_05",
            name = _item_melee.."/ogryn/syn_battle_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_06",
            name = _item_melee.."/ogryn/syn_battle_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_07",
            name = _item_melee.."/ogryn/syn_battle_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_08",
            name = _item_melee.."/ogryn/syn_battle_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_09",
            name = _item_melee.."/ogryn/syn_battle_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_10",
            name = _item_melee.."/ogryn/syn_battle_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_11",
            name = _item_melee.."/ogryn/syn_battle_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_06",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_12",
            name = _item_melee.."/ogryn/syn_battle_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_battle_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2.995, 2.995, 2.995)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(3.005, 3.005, 3.005)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_13",
            name = _item_melee.."/ogryn/syn_battle_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_01",
            name = _item_melee.."/ogryn/syn_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_02",
            name = _item_melee.."/ogryn/syn_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_03",
            name = _item_melee.."/ogryn/syn_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_04",
            name = _item_melee.."/ogryn/syn_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_05",
            name = _item_melee.."/ogryn/syn_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_06",
            name = _item_melee.."/ogryn/syn_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_07",
            name = _item_melee.."/ogryn/syn_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_08",
            name = _item_melee.."/ogryn/syn_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_09",
            name = _item_melee.."/ogryn/syn_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_10",
            name = _item_melee.."/ogryn/syn_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_11",
            name = _item_melee.."/ogryn/syn_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_12",
            name = _item_melee.."/ogryn/syn_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_axe_head_13",
            name = _item_melee.."/ogryn/syn_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/head_04/head_04"] = true,
		--["content/weapons/player/melee/thunder_hammer/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.158), rotation = vector3_box(0, 0, 0), scale = vector3_box(.41, 2.54, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_01",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.), rotation = vector3_box(0, 0, 0), scale = vector3_box(.61, 2.9, 1.27)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_02",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.114), rotation = vector3_box(0, 0, 0), scale = vector3_box(.62, 3.09, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_03",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.148), rotation = vector3_box(0, 0, 0), scale = vector3_box(.574, 2.722, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_04",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.02, 1.02, 1.02)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.182), rotation = vector3_box(0, 0, 0), scale = vector3_box(.55, 2.50, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_05",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.114), rotation = vector3_box(0, 0, 0), scale = vector3_box(.62, 3.09, 1)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_06",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, .158), rotation = vector3_box(0, 0, 0), scale = vector3_box(.47, 2.95, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_07",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_02",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.182), rotation = vector3_box(0, 0, 0), scale = vector3_box(.554, 3, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_08",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_03",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.152), rotation = vector3_box(0, 0, 0), scale = vector3_box(.506, 3.074, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_09",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_04",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.112), rotation = vector3_box(0, 0, 0), scale = vector3_box(.58, 2.636, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_10",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_05",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.098), rotation = vector3_box(0, 0, 0), scale = vector3_box(.4, 2.688, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_11",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_06",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, .158), rotation = vector3_box(0, 0, 0), scale = vector3_box(.47, 2.95, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_12",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/thunderhammer/syn_battle_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_head_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.01, 1.01)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0, 0, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.00, 1.00)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.182), rotation = vector3_box(0, 0, 0), scale = vector3_box(.554, 3, 1.00)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_13",
            name = _item_melee.."/thunderhammer/syn_battle_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_01",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.036), rotation = vector3_box(0, 0, 0), scale = vector3_box(.41, 2.844, 1.258)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_01",
            name = _item_melee.."/power/syn_battle_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_02",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.), rotation = vector3_box(0, 0, 0), scale = vector3_box(.61, 2.9, 2.634)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_02",
            name = _item_melee.."/power/syn_battle_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_03",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.27), rotation = vector3_box(0, 0, 0), scale = vector3_box(.62, 3.308, 2.046)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_03",
            name = _item_melee.."/power/syn_battle_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_04",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.406), rotation = vector3_box(0, 0, 0), scale = vector3_box(.574, 3.158, 1.666)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_04",
            name = _item_melee.."/power/syn_battle_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_05",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.408), rotation = vector3_box(0, 0, 0), scale = vector3_box(.55, 2.836, 2.174)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_05",
            name = _item_melee.."/power/syn_battle_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_axe_head_ml01",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.27), rotation = vector3_box(0, 0, 0), scale = vector3_box(.62, 3.308, 2.046)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_06",
            name = _item_melee.."/power/syn_battle_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_01",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, .398), rotation = vector3_box(0, 0, 0), scale = vector3_box(.47, 3.376, 1.604)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_07",
            name = _item_melee.."/power/syn_battle_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_02",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.474), rotation = vector3_box(0, 0, 0), scale = vector3_box(.554, 3.312, 1.608)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_08",
            name = _item_melee.."/power/syn_battle_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_03",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.37), rotation = vector3_box(0, 0, 0), scale = vector3_box(.506, 3.534, 1.78)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_09",
            name = _item_melee.."/power/syn_battle_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_04",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.372), rotation = vector3_box(0, 0, 0), scale = vector3_box(.58, 2.938, 1.306)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_10",
            name = _item_melee.."/power/syn_battle_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_05",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.308), rotation = vector3_box(0, 0, 0), scale = vector3_box(.4, 2.916, 1.486)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_11",
            name = _item_melee.."/power/syn_battle_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_06",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, .398), rotation = vector3_box(0, 0, 0), scale = vector3_box(.47, 3.376, 1.604)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_12",
            name = _item_melee.."/power/syn_battle_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_battle_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/human_power_maul/attachments/head_01/head_01"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, .0175, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.01, 1.36, 2.21)}}},
                syn_battleaxe_1 = {
                    item = _item_melee.."/heads/syn_hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0, -.0175, 0), rotation = vector3_box(0, 0, -180), scale = vector3_box(1.00, 1.35, 2.20)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/heads/syn_human_power_maul_head_01",
                    fix = {offset = {position = vector3_box(0, 0, 0.474), rotation = vector3_box(0, 0, 0), scale = vector3_box(.554, 3.312, 1.608)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_battle_axe_head_13",
            name = _item_melee.."/power/syn_battle_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_01",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, -0.032, 0.268), rotation = vector3_box(-90, 0, 0), scale = vector3_box(.774, 1.212, 0.2)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}}, 
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_01",
            name = _item_melee.."/power/syn_axe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_02",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.123, 0.235), rotation = vector3_box(-177, 0, 0), scale = vector3_box(47, .698, .222)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_02",
            name = _item_melee.."/power/syn_axe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_03",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.179, 0.215), rotation = vector3_box(77, 0, 0), scale = vector3_box(.82, 1.194, .252)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_03",
            name = _item_melee.."/power/syn_axe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_04",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.172, 0.265), rotation = vector3_box(85, 0, 0), scale = vector3_box(.768, 1.086, .25)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_04",
            name = _item_melee.."/power/syn_axe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_05",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.161, 0.291), rotation = vector3_box(83, 0, 0), scale = vector3_box(.566, 1.312, .228)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_05",
            name = _item_melee.."/power/syn_axe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/axe/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/axe_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.179, 0.215), rotation = vector3_box(77, 0, 0), scale = vector3_box(.82, 1.194, .252)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_06",
            name = _item_melee.."/power/syn_axe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_01/head_01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_01",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.188, 0.271), rotation = vector3_box(82, 0, 0), scale = vector3_box(.426, .682, .154)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_07",
            name = _item_melee.."/power/syn_axe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_08"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_02/head_02"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_02",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.19, 0.3), rotation = vector3_box(80, 0, 0), scale = vector3_box(.43, .882, .168)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_08",
            name = _item_melee.."/power/syn_axe_head_08",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_09"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_03/head_03"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_03",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.203, 0.271), rotation = vector3_box(81, 0, 0), scale = vector3_box(.232, .902, .178)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_09",
            name = _item_melee.."/power/syn_axe_head_09",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_10"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_04/head_04"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_04",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.161, 0.226), rotation = vector3_box(82, 0, 0), scale = vector3_box(.247, .792, .158)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_10",
            name = _item_melee.."/power/syn_axe_head_10",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_11"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_05/head_05"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_05",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.155, 0.214), rotation = vector3_box(81, 0, 0), scale = vector3_box(.246, .876, .156)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_11",
            name = _item_melee.."/power/syn_axe_head_11",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_12"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_06/head_06"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_06",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.188, 0.271), rotation = vector3_box(82, 0, 0), scale = vector3_box(.426, .682, .154)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_12",
            name = _item_melee.."/power/syn_axe_head_12",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/power/syn_axe_head_13"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_sword/attachments/blade_03/blade_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/head_ml01/head_ml01"] = true},
            attachments = {
                syn_battleaxe = {
                    item = _item_melee.."/heads/hatchet_head_ml01",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                syn_battleaxe_powerfield = {
                    item = _item_melee.."/blades/syn_2h_power_sword_blade_03",
                    fix = {offset = {position = vector3_box(0, 0.19, 0.3), rotation = vector3_box(80, 0, 0), scale = vector3_box(.43, .882, .168)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_poweraxe_head_13",
            name = _item_melee.."/power/syn_axe_head_13",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/chains/syn_chain_axe_chain_00"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/chains/syn_chain_axe_chain_00",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_00"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "n/a",
            name = _item_melee.."/blade/syn_double_chainaxe_head_00",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_01",
            name = _item_melee.."/blade/syn_double_chainaxe_head_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_01_secondary"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
		["content/characters/empty_item/empty_item"] = true, 
                ["content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_chainaxe_second_head = {
                    item = _item_melee.."/blades/syn_chainaxe_head_01",
                    fix = {offset = {position = vector3_box(0.0, .0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_01",
            name = _item_melee.."/blade/syn_double_chainaxe_head_01_secondary",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_02",
            name = _item_melee.."/blade/syn_double_chainaxe_head_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_03",
            name = _item_melee.."/blade/syn_double_chainaxe_head_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_04",
            name = _item_melee.."/blade/syn_double_chainaxe_head_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_05",
            name = _item_melee.."/blade/syn_double_chainaxe_head_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_06",
            name = _item_melee.."/blade/syn_double_chainaxe_head_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_07",
            name = _item_melee.."/blade/syn_double_chainaxe_head_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_blade_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_ml01",
            name = _item_melee.."/blade/syn_double_chainaxe_head_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_01_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_01",
            name = _item_melee.."/blade/syn_double_chainaxe_head_01_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_02_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_02",
            name = _item_melee.."/blade/syn_double_chainaxe_head_02_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_03_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_03",
            name = _item_melee.."/blade/syn_double_chainaxe_head_03_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_04_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_04",
            name = _item_melee.."/blade/syn_double_chainaxe_head_04_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_05_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_05",
            name = _item_melee.."/blade/syn_double_chainaxe_head_05_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_06_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_06",
            name = _item_melee.."/blade/syn_double_chainaxe_head_06_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_07_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_07",
            name = _item_melee.."/blade/syn_double_chainaxe_head_07_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_double_chainaxe_head_ml01_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_double_chainaxe_head_ml01",
            name = _item_melee.."/blade/syn_double_chainaxe_head_ml01_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_01_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_01/blade_01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_01",
            name = _item_melee.."/blade/syn_chainaxe_head_01_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_02_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_02/blade_02"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_02",
            name = _item_melee.."/blade/syn_chainaxe_head_02_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_03_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_03/blade_03"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_03",
            name = _item_melee.."/blade/syn_chainaxe_head_03_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_04_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_04/blade_04"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_04",
            name = _item_melee.."/blade/syn_chainaxe_head_04_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_05_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_05/blade_05"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_05",
            name = _item_melee.."/blade/syn_chainaxe_head_05_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_06_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_06/blade_06"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_06",
            name = _item_melee.."/blade/syn_chainaxe_head_06_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_07_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_07/blade_07"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_07",
            name = _item_melee.."/blade/syn_chainaxe_head_07_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/blade/syn_chainaxe_head_ml01_2h"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_body_01",
            resource_dependencies = {
                ["content/weapons/player/melee/chain_axe/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
            },
            workflow_checklist = {},
            display_name = "loc_syn_chainaxe_head_ml01",
            name = _item_melee.."/blade/syn_chainaxe_head_ml01_2h",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
------------------------------------------------------------------------------------------------------------------------------
--
--				 SHIELDS 
--
------------------------------------------------------------------------------------------------------------------------------
        [_item_melee.."/shields/syn_shield_bigtome"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/characters/player/human/attachments_gear/backpack/backpack_book_a/backpack_book_a"] = true},
            attachments = {
                syn_shield_1 = {
		    --material_overrides = {"color_1_colour_gray_01"},
                    item = _item_ranged.."/syn_bigtome",
                    fix = {offset = {position = vector3_box(-0.31, 0.05, -1.36), rotation = vector3_box(0, 0, 98), scale = vector3_box(1, 1, 1)}},
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_bigtome",
            name = _item_melee.."/shields/syn_shield_bigtome",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_tome"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/pickups/pocketables/side_mission/tome/tome_item_01"] = true},
            attachments = {
                syn_spellbook = {
                    item = _item_ranged.."/syn_tome",
                    fix = {offset = {position = vector3_box(0.0, 0.08, 0.07), rotation = vector3_box(90, 90, 0), scale = vector3_box(1, 1, -1)}},
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_tome",
            name = _item_melee.."/shields/syn_shield_tome",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_grim"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/pickups/pocketables/side_mission/grimoire/grimoire_01"] = true},
            attachments = {
                syn_spellbook = {
                    item = _item_ranged.."/syn_grimoire",
                    fix = {offset = {position = vector3_box(0.0, 0.08, 0.07), rotation = vector3_box(90, 90, 0), scale = vector3_box(1, 1, -1)}},
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_grim",
            name = _item_melee.."/shields/syn_shield_grim",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_halo"] = {
      		show_in_1p = true,
            	only_show_in_1p = false,
      		base_unit = "content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
		material_overrides = {"oxidized_metal_gold_wear_01"},
      		resource_dependencies = {
		["content/characters/tiling_materials/gold_01/metal_gold_01_orm"] = true,
		["content/characters/tiling_materials/gold_01/metal_gold_01_bca"] = true,
		["content/characters/tiling_materials/gold_01/metal_gold_01_nm"] = true,
		["content/textures/colors/oxidation_color_black_01"] = true,
		["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/shields/syn_halo",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/shields/syn_holyrelic"] = {
      		show_in_1p = true,
            	only_show_in_1p = false,
      		base_unit = "content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {
		["content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02"] = true},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/shields/syn_holyrelic",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/shields/syn_power_falchion_blade_01"] = {
      		show_in_1p = true,
            	only_show_in_1p = false,
      		base_unit = "content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {
		["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/shields/syn_power_falchion_blade_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/shields/syn_power_falchion_blade_02"] = {
      		show_in_1p = true,
            	only_show_in_1p = false,
      		base_unit = "content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {
		["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/shields/syn_power_falchion_blade_02",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/shields/syn_combat_sword_blade_01"] = {
      		show_in_1p = true,
            	only_show_in_1p = false,
      		base_unit = "content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01",
      		workflow_checklist = {},
      		is_fallback_item = false,
      		tags = {},
      		attach_node = 1,
      		resource_dependencies = {
		["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true},
      		workflow_state = "RELEASABLE",
      		display_name = "n/a",
      		name = _item_melee.."/shields/syn_combat_sword_blade_01",
      		item_list_faction = "Player",
    	},
        [_item_melee.."/shields/syn_ogryn_shield_crusader_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_01"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04b"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
	            item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_08",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.22), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.34), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_ogryn_shield_crusader_01a"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_02"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04c"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_09",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.22), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.34), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01a",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_01a",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_ogryn_shield_crusader_01b"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04e"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_melee.."/shields/syn_holyrelic",
                    fix = {offset = {position = vector3_box(0.124, 0.1, -0.398), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 2.64, 2.618)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04e",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01b",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_01b",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_ogryn_shield_crusader_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_01"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_08",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.186), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.082), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.31), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_ogryn_shield_crusader_02a"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_02"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_09",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.186), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.082), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.31), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02a",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_02a",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_ogryn_shield_crusader_02b"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/attachments/sights/sight_reflex_02/sight_reflex_02"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
		syn_ogryn_shield_scaling = {
	            item = _item_ranged.."/syn_reflex/syn_reflex_02",
                    fix = {offset = {position = vector3_box(0.04, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(2., 2., 2.)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		children = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_melee.."/shields/syn_holyrelic",
                    fix = {offset = {position = vector3_box(0.124, 0.1, -0.358), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 2.64, 2.618)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.042, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .5, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.028, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.04), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, 1.12, 1.0)}},
                },
		}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02b",
            name = _item_melee.."/shields/syn_ogryn_shield_crusader_02b",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_01"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04b"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_08",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.22), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.34), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01",
            name = _item_melee.."/shields/syn_shield_crusader_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_01a"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_02"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04c"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_09",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.216), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.22), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.106), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04c",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.34), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01a",
            name = _item_melee.."/shields/syn_shield_crusader_01a",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_01b"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02"] = true,
                ["content/weapons/player/melee/2h_force_sword/attachments/pommel_02/pommel_02"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/pommel_03/pommel_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_04/emblem_04e"] = true,
                ["content/weapons/player/attachments/emblems/emblem_09/emblem_9c"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, -0.03, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 3.23, 1.75)}},
    		    children = {
                	syn_shield_1a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_01",
                    fix = {offset = {position = vector3_box(0.09, 0.23, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -3.23, 1.75)}},
    		    children = {
                	syn_shield_2a = {
                    	item = _item_melee.."/pommels/syn_2h_force_sword_pommel_02",
                    	fix = {offset = {position = vector3_box(0.0, 0.004, 0.028), rotation = vector3_box(90, 0, 0), scale = vector3_box(.406, 1.232, .674)}}},
                }},
                syn_shield_3 = {
                    item = _item_melee.."/shields/syn_holyrelic",
                    fix = {offset = {position = vector3_box(0.124, 0.1, -0.398), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 2.64, 2.618)}},
                },
                syn_shield_5 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04e",
                    fix = {offset = {position = vector3_box(0.108, 0.1, -0.652), rotation = vector3_box(0, 0, 0), scale = vector3_box(16, 5.5, 4.5)}},
                },
                syn_shield_6 = {
                    item = _item_ranged.."/emblems/syn_emblemright_09c",
                    fix = {offset = {position = vector3_box(0.1083, 0.2215, -0.404), rotation = vector3_box(18.5, -9, 8), scale = vector3_box(3, 2, 2)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.13, 0.1, 0.196), rotation = vector3_box(-180, 0, 90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_8 = {
                    item = _item_melee.."/pommels/syn_2h_power_maul_pommel_03",
                    fix = {offset = {position = vector3_box(0.072, 0.1, 0.196), rotation = vector3_box(-180, 0, -90), scale = vector3_box(.4, .4, .4)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_01b",
            name = _item_melee.."/shields/syn_shield_crusader_01b",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_01"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_08",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.186), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.082), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.31), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02",
            name = _item_melee.."/shields/syn_shield_crusader_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_02a"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/attachments/devices/device_e/device_e_02"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/characters/player/human/attachments_gear/headgear/missionary_diadem_a/missionary_diadem_a"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/attachments/emblems/emblem_03/emblem_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_ranged.."/emblems/syn_emblem_device_left_09",
                    fix = {offset = {position = vector3_box(0.112, 0.1, -0.186), rotation = vector3_box(0, 0, 90), scale = vector3_box(7, 3, 5.5)}},
                },
                syn_shield_4 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_03",
                    fix = {offset = {position = vector3_box(0.12, 0.1, -0.19), rotation = vector3_box(0, 0, 0), scale = vector3_box(18, 13, 13)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
                syn_shield_13 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.082), rotation = vector3_box(0, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_14 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
                syn_shield_15 = {
                    item = _item_ranged.."/emblems/syn_emblemleft_04b",
                    fix = {offset = {position = vector3_box(0.15, 0.1, -0.31), rotation = vector3_box(180, 0, 90), scale = vector3_box(1.4, 1.4, 1.4)}, hide = {mesh = {1,2,3,4,5,6,7,8,9,10}}},
		    children = {
                	syn_shield_16 = {
                    	item = _item_melee.."/shields/syn_halo",
                    	material_override_items = {
                        	[1] = "content/items/material_overrides/gear_materials/oxidized_metal_gold_wear_01",
                    	},
			material_overrides = {"oxidized_metal_gold_wear_01"},
                    	fix = {offset = {position = vector3_box(0.0, 0.0, -1.8), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 1, 1)}}},
                }},
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02a",
            name = _item_melee.."/shields/syn_shield_crusader_02a",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/shields/syn_shield_crusader_02b"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "j_leftweaponattach",
            resource_dependencies = {
                ["content/weapons/player/ranged/preacher_relic/wpn_preacher_relic_02"] = true,
                ["content/weapons/player/melee/combat_sword/attachments/blade_01/blade_01"] = true,
                ["content/weapons/player/melee/power_sword/attachments/grip_04/grip_04"] = true,
                ["content/weapons/player/melee/combat_blade/attachments/grip_03/grip_03"] = true,
                ["content/weapons/player/melee/hatchet/attachments/grip_03/grip_03"] = true,
		["content/weapons/player/melee/power_sword/attachments/grip_02/grip_02"] = true,
                ["content/weapons/player/shields/assault_shield/wpn_assault_shield_chained_rig"] = true,
                ["content/weapons/player/melee/power_falchion/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_shield_1 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, -0.08, 0.23), rotation = vector3_box(180, 0, 5), scale = vector3_box(2.5, 2.75, 1.75)}},
                },
                syn_shield_2 = {
                    item = _item_melee.."/shields/syn_power_falchion_blade_02",
                    fix = {offset = {position = vector3_box(0.09, 0.28, 0.23), rotation = vector3_box(180, 0, -5), scale = vector3_box(2.5, -2.75, 1.75)}},
                },
                syn_shield_3 = {
                    item = _item_melee.."/shields/syn_holyrelic",
                    fix = {offset = {position = vector3_box(0.124, 0.1, -0.358), rotation = vector3_box(0, 0, 0), scale = vector3_box(1, 2.64, 2.618)}},
                },
                syn_shield_6 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.17, 0.22), rotation = vector3_box(180, 0, 180), scale = vector3_box(0.9, 1.84, 1.66)}},
                },
                syn_shield_7 = {
                    item = _item_melee.."/shields/syn_combat_sword_blade_01",
                    fix = {offset = {position = vector3_box(0.103, 0.03, 0.22), rotation = vector3_box(180, 0, 0), scale = vector3_box(-0.9, 1.84, 1.66)}},
                },
                syn_shield_8 = {
                    item = _item_ranged.."/magwell/syn_m41a_filler",
                    fix = {offset = {position = vector3_box(0.096, 0.1, -0.076), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.892, 5.708, 7.684)}},
                },
                syn_shield_9 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, 0.078), rotation = vector3_box(0, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_10 = {
                    item = _item_melee.."/grips/syn_combat_blade_grip_03",
                    fix = {offset = {position = vector3_box(0.056, -0.004, -0.074), rotation = vector3_box(180, 0, 90), scale = vector3_box(.5, .33, .5)}},
                },
                syn_shield_11 = {
                    item = _item_melee.."/grips/syn_hatchet_grip_03",
                    fix = {offset = {position = vector3_box(-0.002, -0.004, -0.01), rotation = vector3_box(0, 0, 0), scale = vector3_box(.6, .6, .824)}},
                },
                syn_shield_12 = {
                    item = _item_melee.."/grips/syn_power_sword_grip_04",
                    fix = {offset = {position = vector3_box(0.062, 0.204, 0.062), rotation = vector3_box(0, 0, 90), scale = vector3_box(-.45, .85, .8)}},
                },
            },
            workflow_checklist = {},
            display_name = "loc_syn_shield_crusader_02b",
            name = _item_melee.."/shields/syn_shield_crusader_02b",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--										SHAFTS
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        [_item_melee.."/ogryn/syn_custodes_shaft_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/stock_01/stock_01"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/muzzel_01/muzzel_01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_02/shaft_02"] = true},
            attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
                syn_shaft_2 = {
                    item = _item_ranged.."/stocks/syn_galvanic_rifle_stock_01",
                    fix = {offset = {position = vector3_box(-0.058, 0.0, 0.404), rotation = vector3_box(0, 90, 90), scale = vector3_box(3.094, 2.228, 1.226)}}},
                syn_shaft_3 = {
                    item = _item_ranged.."/muzzles/syn_galvanic_rifle_muzzle_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.452), rotation = vector3_box(-90, 90, 0), scale = vector3_box(3.018, 4.54, 1.704)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_custodes_shaft_01",
            name = _item_melee.."/ogryn/syn_custodes_shaft_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_custodes_shaft_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/muzzel_deluxe01/muzzel_deluxe01"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/stock_deluxe01/stock_deluxe01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_02/shaft_02"] = true},
            attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
                syn_shaft_2 = {
                    item = _item_ranged.."/stocks/syn_galvanic_rifle_stock_deluxe01",
                    fix = {offset = {position = vector3_box(-0.058, 0.0, 0.018), rotation = vector3_box(0, 90, 90), scale = vector3_box(3.094, 1.673, 1.226)}}},
                syn_shaft_3 = {
                    item = _item_ranged.."/muzzles/syn_galvanic_rifle_muzzle_deluxe01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 1.16), rotation = vector3_box(-90, 90, 0), scale = vector3_box(3.018, 3.6, 1.704)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_custodes_shaft_02",
            name = _item_melee.."/ogryn/syn_custodes_shaft_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_custodes_shaft_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/stock_ml01/stock_ml01"] = true,
		["content/weapons/player/ranged/galvanic_rifle/attachments/muzzel_ml01/muzzel_ml01"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_02/shaft_02"] = true},
            attachments = {
                syn_shaft_1 = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
                syn_shaft_2 = {
                    item = _item_ranged.."/stocks/syn_galvanic_rifle_stock_ml01",
                    fix = {offset = {position = vector3_box(-0.058, 0.0, 0.404), rotation = vector3_box(0, 90, 90), scale = vector3_box(3.094, 2.228, 1.226)}}},
                syn_shaft_3 = {
                    item = _item_ranged.."/muzzles/syn_galvanic_rifle_muzzle_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.452), rotation = vector3_box(-90, 90, 0), scale = vector3_box(3.018, 4.54, 1.704)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_custodes_shaft_03",
            name = _item_melee.."/ogryn/syn_custodes_shaft_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_01/shaft_01"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_01",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_02/shaft_02"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_02",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_03/shaft_03"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_03",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_04/shaft_04"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_04",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_05/shaft_05"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_05",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_06/shaft_06"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_06",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_07"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_07/grip_07"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_07",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_07",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_07",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_2h_powermaul_shaft_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/2h_power_maul/attachments/grip_ml01/shaft_ml01"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_2h_power_maul_shaft_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_2h_powermaul_shaft_ml01",
            name = _item_melee.."/ogryn/syn_2h_powermaul_shaft_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_01/shaft_01"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_01",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_02/shaft_02"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_02",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_03/shaft_03"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_03",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_04/shaft_04"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_04",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_05/shaft_05"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_05",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_05",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_06"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_06/shaft_06"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_06",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_06",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_06",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/ogryn/syn_thunderhammer_shaft_ml01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "wpn_2h_ogryn_pickaxe_chained_rig",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/thunder_hammer/attachments/shaft_ml01/shaft_ml01"] = true},
            attachments = {
                syn_shaft = {
                    item = _item_melee.."/shafts/syn_thunder_hammer_shaft_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(3, 3, 3)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_thunderhammer_shaft_ml01",
            name = _item_melee.."/ogryn/syn_thunderhammer_shaft_ml01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--										POMMEL
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        [_item_melee.."/pommel/syn_pickaxe_knife_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_combat_knife_blade_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_knife_01",
            name = _item_melee.."/pommel/syn_pickaxe_knife_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_knife_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_02/blade_02"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_combat_knife_blade_02",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_knife_02",
            name = _item_melee.."/pommel/syn_pickaxe_knife_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_knife_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_03/blade_03"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_combat_knife_blade_03",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_knife_03",
            name = _item_melee.."/pommel/syn_pickaxe_knife_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_knife_04"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_04/blade_04"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_combat_knife_blade_04",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_knife_04",
            name = _item_melee.."/pommel/syn_pickaxe_knife_04",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_knife_05"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/combat_knife/attachments/blade_07/blade_07"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_combat_knife_blade_07",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_knife_05",
            name = _item_melee.."/pommel/syn_pickaxe_knife_05",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_transonic_01"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_transonic_knife_blade_01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_transonic_01",
            name = _item_melee.."/pommel/syn_pickaxe_transonic_01",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_transonic_01_alt"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/transonic_razor/attachments/blade_01/blade_01_cinematic"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_transonic_knife_blade_01_cinematic",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_transonic_01_alt",
            name = _item_melee.."/pommel/syn_pickaxe_transonic_01_alt",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_transonic_02"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/transonic_razor/attachments/blade_deluxe01/blade_deluxe01"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_transonic_knife_blade_deluxe01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_transonic_02",
            name = _item_melee.."/pommel/syn_pickaxe_transonic_02",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },
        [_item_melee.."/pommel/syn_pickaxe_transonic_03"] = {
            is_fallback_item = false,
            show_in_1p = true,
            base_unit = "content/characters/empty_item/empty_item",
            item_list_faction = "Player",
            tags = {},
            only_show_in_1p = false,
            feature_flags = {"FEATURE_item_retained"},
            attach_node = "ap_pommel_01",
            resource_dependencies = {
                ["content/characters/empty_item/empty_item"] = true,
                ["content/weapons/player/melee/transonic_razor/attachments/blade_ml01/blade_ml01"] = true},
            attachments = {
                syn_pommel = {
                    item = _item_melee.."/blades/syn_transonic_knife_blade_ml01",
                    fix = {offset = {position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 180, -90), scale = vector3_box(4.5, 3.3, 2)}}},
            },
            workflow_checklist = {},
            display_name = "loc_syn_pickaxe_transonic_03",
            name = _item_melee.."/pommel/syn_pickaxe_transonic_03",
            workflow_state = "RELEASABLE",
            is_full_item = true,
            disable_vfx_spawner_exclusion = true,
        },

--------------------
--End of kitbashes--
--------------------
    },
}
