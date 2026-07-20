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
Managers.package:load("content/pickups/pickup_assets", "ewc_syn_edits")

local GibbingSettings = mod:original_require("scripts/settings/gibbing/gibbing_settings")
local LineEffects = mod:original_require("scripts/settings/effects/line_effects")
local PlayerCharacterSoundEventAliases = require("scripts/settings/sound/player_character_sound_event_aliases")

local gibbing_types = GibbingSettings.gibbing_types
local gibbing_power = GibbingSettings.gibbing_power

mod.custom_damage_types = {
    ["multilaser"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.lasbeam_killshot,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_lasgun_p3_m3_fire_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_lasgun_p3_m3_fire_auto",
        play_ranged_shooting_aiming = "wwise/events/weapon/play_lasgun_p3_m3_fire_auto",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_lasgun_p3_m3_fire_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_lasgun_p3_m3_fire_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_lasgun_p3_m3_fire_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_lasgun_p3_m3_fire_single",
	sfx_special_activate = "wwise/events/weapon/play_chainaxe_swing",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/lasgun/lasgun_charged_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/lasgun/lasgun_charged_muzzle_crit",
    },
    ["arc"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.arc_beam,
	shell_casing_effect = "",
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
        play_ranged_shooting_aiming = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_single",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/arc_rifle/impact_arc_rifle_p1",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/arc_rifle/impact_arc_rifle_p1",
    },
    ["arc_low_voltage"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.arc_beam,
	shell_casing_effect = "",
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
        play_ranged_shooting_aiming = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_arc_rifle_p1_m1_fire_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_arc_rifle_p1_m1_fire_single",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01",
        muzzle_flash_crit = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01",
    },
    ["combiplasma"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect_aiming = LineEffects.plasma_beam,
        -- Sounds
        play_ranged_shooting_aiming = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot_aiming = "wwise/events/weapon/play_weapon_plasmagun",
        ranged_single_shot_aiming = "wwise/events/weapon/play_weapon_plasmagun",
        -- Muzzle flash
        muzzle_flash_aiming = "content/fx/particles/weapons/rifles/plasma_gun/plasma_muzzle_ks",
        muzzle_flash_crit_aiming = "content/fx/particles/weapons/rifles/plasma_gun/plasma_muzzle_bfg",
    },
    ["combineedle"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect_aiming = LineEffects.needle_trail,
        -- Sounds
        play_ranged_shooting_aiming = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot_aiming = "wwise/events/weapon/play_weapon_needle_pistol",
        ranged_single_shot_aiming = "wwise/events/weapon/play_weapon_needle_pistol",
        -- Muzzle flash
        muzzle_flash_aiming = "content/fx/particles/weapons/pistols/needlepistol/needlepistol_muzzle_hip",
        muzzle_flash_crit_aiming = "content/fx/particles/weapons/pistols/needlepistol/needlepistol_muzzle_hip",
    },
    ["combigrenade"] = {
        -- Gibbing settings
        -- Line effect
        -- Sounds
        play_ranged_shooting_aiming = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting_aiming = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot_aiming = "wwise/events/weapon/play_ogryn_gauntlet_fire",
        ranged_single_shot_aiming = "wwise/events/weapon/play_ogryn_gauntlet_fire",
        -- Muzzle flash
        muzzle_flash_aiming = "content/fx/particles/weapons/rifles/ogryn_gauntlet/ogryn_gauntlet_muzzle_flash",
        muzzle_flash_crit_aiming = "content/fx/particles/weapons/rifles/ogryn_gauntlet/ogryn_gauntlet_muzzle_flash",
    },
    ["syn_silencer_shotgun"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_weapon_needle_pistol",
	ranged_single_shot = "wwise/events/weapon/play_weapon_needle_pistol",
        muzzle_flash = "content/fx/particles/weapons/pistols/needlepistol/needlepistol_muzzle_hip",
        muzzle_flash_crit = "content/fx/particles/weapons/pistols/needlepistol/needlepistol_muzzle_hip",
    },
    ["syn_silencer_auto"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_heavy_swing_hit",
	ranged_single_shot = "wwise/events/weapon/play_heavy_swing_hit",
        muzzle_flash = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
    },
    ["syn_silencer_las"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_power_sword_off",
	ranged_single_shot = "wwise/events/weapon/play_power_sword_off",
        muzzle_flash = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
    },
    ["syn_silencer_las2"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_power_sword_off",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_power_sword_off",
	ranged_single_shot = "wwise/events/weapon/play_power_sword_off",
        muzzle_flash = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/bolter/bolter_muzzle_secondary",
    },
    ["auto_bullet_infantry_m2"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p1_m2_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p1_m2_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p1_m2_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p1_m2_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p1_m2_single",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p1_m2_single",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_crit",
    },
    ["auto_bullet_infantry_m3"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p1_m3_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p1_m3_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p1_m3_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p1_m3_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p1_m3_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p1_m3_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_crit",
    },
    ["auto_bullet_braced_m2"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p2_m2_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p2_m2_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p2_m2_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p2_m2_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p2_m2_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p2_m2_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_02",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_crit",
    },
    ["auto_bullet_braced_m3"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p2_m3_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p2_m3_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p2_m3_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p2_m3_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p2_m3_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p2_m3_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_02",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_crit",
    },
    ["auto_bullet_headhunter_m2"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p3_m2_single",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p3_m2_single",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_03",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_03_crit",
    },
    ["auto_bullet_headhunter_m3"] = {
        game_damage_type = "auto_bullet",
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p3_m3_single",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p3_m3_single",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_03",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/autogun/autogun_muzzle_03_crit",
    },
    ["auto_bullet_infantry_m2_stubber"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p1_m2_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p1_m2_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p1_m2_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p1_m2_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p1_m2_single",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p1_m2_single",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
    },
    ["auto_bullet_infantry_m3_stubber"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p1_m3_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p1_m3_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p1_m3_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p1_m3_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p1_m3_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p1_m3_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
    },
    ["auto_bullet_braced_m2_stubber"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p2_m2_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p2_m2_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p2_m2_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p2_m2_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p2_m2_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p2_m2_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
    },
    ["auto_bullet_braced_m3_stubber"] = {
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_autogun_p2_m3_auto",
        stop_ranged_shooting = "wwise/events/weapon/stop_autogun_p2_m3_auto",
	play_ranged_braced_shooting = "wwise/events/weapon/play_autogun_p2_m3_auto",
	stop_ranged_braced_shooting = "wwise/events/weapon/stop_autogun_p2_m3_auto",
        ranged_pre_loop_shot = "wwise/events/weapon/play_autogun_p2_m3_first",
        ranged_single_shot = "wwise/events/weapon/play_autogun_p2_m3_first",
	ranged_out_of_ammo = "wwise/events/weapon/play_last_bullet_autogun",
    },
    ["syn_taupulserifle"] = {
        game_damage_type = "biomancer_soul",
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.galvanic_beam,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        ranged_pre_loop_shot = "wwise/events/weapon/play_weapon_bolter_m2",
        ranged_single_shot = "wwise/events/weapon/play_weapon_bolter_m2",
        -- Muzzle flash
        --muzzle_flash = "content/fx/particles/enemies/daemonhost/daemonhost_beam_hit",
        muzzle_flash = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01",
        muzzle_flash_crit = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01",
    },
    ["lascannon"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.lasbeam_bfg,
        --line_effect = LineEffects.renegade_sniper_lasbeam,
        -- Sounds
        ranged_single_shot = "wwise/events/weapon/play_lasgun_p2_m1_charged",
	ranged_shot_tail = "wwise/events/weapon/play_player_wpn_refl_rifle_heavy",
	--play_ranged_charging = "wwise/events/weapon/%s_lasgun_p2_charge",
	--play_ranged_fast_charging = "wwise/events/weapon/%s_lasgun_p2_charge",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/lasgun/lasgun_bfg_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/lasgun/lasgun_bfg_muzzle_crit",
    },
    ["gk8gauss"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.pellet_trail,
        --line_effect = LineEffects.renegade_sniper_lasbeam,
        -- Sounds
        ranged_single_shot = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
	ranged_shot_tail = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
	--play_ranged_charging = "wwise/events/weapon/%s_lasgun_p2_charge",
	--play_ranged_fast_charging = "wwise/events/weapon/%s_lasgun_p2_charge",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/arc_rifle/impact_arc_rifle_p1",
    },
    ["gk8gauss_auto"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        --line_effect = LineEffects.pellet_trail,
        line_effect = LineEffects.galvanic_beam,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        ranged_pre_loop_shot = "wwise/events/weapon/play_weapon_bolter_m2",
        ranged_single_shot = "wwise/events/weapon/play_weapon_bolter_m2",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01", 
        muzzle_flash_crit = "content/fx/particles/weapons/force_staff/force_staff_projectile_cast_01", 
    },
    ["gk8gauss_helbore"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.pellet_trail,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        ranged_single_shot = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
	ranged_shot_tail = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
    },
    ["gk8gauss_shotgun"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.plasma,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.pellet_trail,
        -- Sounds
        play_ranged_shooting = "wwise/events/weapon/play_weapon_silence",
        stop_ranged_shooting = "wwise/events/weapon/stop_weapon_silence",
        ranged_pre_loop_shot = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        ranged_single_shot = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        ranged_single_shot_special_extra = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
	ranged_shot_tail = "wwise/events/weapon/play_psyker_lightning_bolt_charged",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
	weapon_special_muzzle_flash_effect = "content/fx/particles/weapons/rifles/galvanic/galvanic_rifle_muzzle",
    },
    ["syn_laspistol"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.laser,
        gibbing_power = gibbing_power.infinite,
        -- Line effect
        line_effect = LineEffects.lasbeam_pistol_ads,
        -- Sounds
	ranged_single_shot = "wwise/events/weapon/play_laspistol_p1_m3",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/rifles/lasgun/lasgun_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/rifles/lasgun/lasgun_muzzle_crit",
    },
    ["syn_stubpistol"] = {
        -- Gibbing settings
        gibbing_type = gibbing_types.ballistic,
        gibbing_power = gibbing_power.always,
        -- Line effect
        line_effect = LineEffects.autogun_bullet,
        -- Sounds
	ranged_single_shot = "wwise/events/weapon/play_dual_stubpistols_p1_m1_single",
        -- Muzzle flash
        muzzle_flash = "content/fx/particles/weapons/pistols/stubrevolver/stubrevolver_muzzle",
        muzzle_flash_crit = "content/fx/particles/weapons/pistols/stubrevolver/stubrevolver_muzzle_crit",
    },
}
-- Yes I stole the following snippit from you Backup158, because it works and I can't code.
for damage_type_name, type_data in pairs(mod.custom_damage_types) do
    ewc.damage_types[damage_type_name] = type_data
end

-- table.dump(ewc.damage_types, "ALL DAMAGE TYPES FROM MAIN MOD TABLE AFTER INSERTING", 20)

-- ###################################################################
-- HELPER FUNCTIONS
-- ###################################################################
mod:io_dofile("extended_weapon_customization_syn_edits/helper_functions")
local load_mod_file = mod.load_mod_file
local merge_recursive_safe = mod.merge_recursive_safe
local table_insert_all_from_table = mod.table_insert_all_from_table

-- ###################################################################
-- LOADING THE ATTACHMENT THINGS
-- ###################################################################
mod.extended_weapon_customization_plugin = {
	attachment_slots = {},
	attachments = {},
	fixes = {},
	kitbashs = {},
}
local amount_of_files = 6 -- edit this as you need to make more files
for i = 1, amount_of_files do
	local number_converted_to_string = tostring(i)
	load_mod_file("/files_to_load/ewc_syn_"..number_converted_to_string)
	-- Merges results from each file. Fixes are listed without a key (like "value1, value2," instead of "key1 = value1, key2 = value2,"), so manual insertion is needed (merging will overwrite existing fixes)
	merge_recursive_safe(mod.extended_weapon_customization_plugin.attachment_slots, mod["extended_weapon_customization_plugin_"..number_converted_to_string].attachment_slots)
	merge_recursive_safe(mod.extended_weapon_customization_plugin.attachments, mod["extended_weapon_customization_plugin_"..number_converted_to_string].attachments)
	if mod["extended_weapon_customization_plugin_"..number_converted_to_string].fixes then
        for weapon, table_of_fixes in pairs(mod["extended_weapon_customization_plugin_"..number_converted_to_string].fixes) do
            -- If the main table to return doesn't have an entry for the weapon yet, create it
            if not mod.extended_weapon_customization_plugin.fixes[weapon] then
                mod.extended_weapon_customization_plugin.fixes[weapon] = {}
            end
            table_insert_all_from_table(mod.extended_weapon_customization_plugin.fixes[weapon], table_of_fixes)
        end
    end
	merge_recursive_safe(mod.extended_weapon_customization_plugin.kitbashs, mod["extended_weapon_customization_plugin_"..number_converted_to_string].kitbashs)
end

-- ###################################################################
-- COPYING TO VARIANTS
-- ###################################################################
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.autogun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.autogun_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.bolter_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.bolter_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.boltpistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.boltpistol_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.chainaxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.chainaxe_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.chainsword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.chainsword_2h_p1_m1)
--mod.extended_weapon_customization_plugin.attachment_slots.combatknife_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatknife_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m4 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.forcesword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.forcesword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.forcesword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.forcesword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.attachment_slots.laspistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.laspistol_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.needlepistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.needlepistol_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_combatblade_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_combatblade_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p2_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_heavystubber_p2_m1)
--mod.extended_weapon_customization_plugin.attachment_slots.ogryn_pickaxe_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_pickaxe_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_rippergun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.ogryn_rippergun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.plasmagun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.plasmagun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powermaul_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powermaul_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powermaul_shield_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powermaul_shield_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powersword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powersword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powersword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powersword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.powersword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.powersword_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p4_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p4_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.attachment_slots.stubrevolver_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.attachment_slots.stubrevolver_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachment_slots.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p2_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p2_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p3_m1)
mod.extended_weapon_customization_plugin.attachments.autogun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.autogun_p3_m1)
mod.extended_weapon_customization_plugin.attachments.bolter_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.bolter_p1_m1)
mod.extended_weapon_customization_plugin.attachments.boltpistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.boltpistol_p1_m1)
mod.extended_weapon_customization_plugin.attachments.chainaxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.chainaxe_p1_m1)
mod.extended_weapon_customization_plugin.attachments.chainsword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.chainsword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combatknife_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatknife_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combataxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combataxe_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combataxe_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.attachments.combataxe_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.attachments.combatknife_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatknife_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.attachments.combatsword_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m4 = table_clone(mod.extended_weapon_customization_plugin.attachments.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.attachments.forcesword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.forcesword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.forcesword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.forcesword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.attachments.lasgun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.attachments.laspistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.attachments.laspistol_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.attachments.needlepistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.needlepistol_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_combatblade_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_combatblade_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p2_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_heavystubber_p2_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_pickaxe_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_pickaxe_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_pickaxe_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_pickaxe_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_rippergun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.ogryn_rippergun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.plasmagun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.plasmagun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powermaul_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.powermaul_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powermaul_shield_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.powermaul_shield_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powersword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powersword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powersword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.powersword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.powersword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.powersword_p1_m1)
mod.extended_weapon_customization_plugin.attachments.shotgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.shotgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.attachments.shotgun_p4_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.attachments.shotgun_p4_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.attachments.stubrevolver_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.attachments.stubrevolver_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.attachments.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.attachments.thunderhammer_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.attachments.thunderhammer_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p2_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p2_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p3_m1)
mod.extended_weapon_customization_plugin.fixes.autogun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.autogun_p3_m1)
mod.extended_weapon_customization_plugin.fixes.bolter_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.bolter_p1_m1)
mod.extended_weapon_customization_plugin.fixes.boltpistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.boltpistol_p1_m1)
mod.extended_weapon_customization_plugin.fixes.chainaxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.chainaxe_p1_m1)
mod.extended_weapon_customization_plugin.fixes.chainsword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.chainsword_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combatknife_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatknife_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combataxe_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combataxe_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.combataxe_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combataxe_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.fixes.combataxe_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.combataxe_p2_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p2_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.fixes.combatsword_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.combatsword_p3_m1)
mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m4 = table_clone(mod.extended_weapon_customization_plugin.fixes.dual_shivs_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcestaff_p2_m1 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcestaff_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcestaff_p3_m1 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcestaff_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcestaff_p4_m1 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcestaff_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcesword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcesword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcesword_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcesword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.forcesword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.forcesword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p2_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p3_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.fixes.lasgun_p3_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.lasgun_p3_m1)
mod.extended_weapon_customization_plugin.fixes.laspistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.fixes.laspistol_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.laspistol_p1_m1)
mod.extended_weapon_customization_plugin.fixes.needlepistol_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.needlepistol_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_combatblade_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_combatblade_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_combatblade_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p2_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p2_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p2_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_heavystubber_p2_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_pickaxe_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_pickaxe_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_pickaxe_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_pickaxe_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_rippergun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.ogryn_rippergun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.ogryn_rippergun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.plasmagun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.plasmagun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powermaul_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.powermaul_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powermaul_shield_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.powermaul_shield_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powersword_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powersword_2h_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.powersword_2h_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powersword_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.powersword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.powersword_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.powersword_p1_m1)
mod.extended_weapon_customization_plugin.fixes.shotgun_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.shotgun_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.shotgun_p1_m1)
mod.extended_weapon_customization_plugin.fixes.shotgun_p4_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.fixes.shotgun_p4_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.shotgun_p4_m1)
mod.extended_weapon_customization_plugin.fixes.stubrevolver_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.fixes.stubrevolver_p1_m3 = table_clone(mod.extended_weapon_customization_plugin.fixes.stubrevolver_p1_m1)
mod.extended_weapon_customization_plugin.fixes.thunderhammer_2h_p1_m2 = table_clone(mod.extended_weapon_customization_plugin.fixes.thunderhammer_2h_p1_m1)
