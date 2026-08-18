-- passives.lua
--
-- Bot passive system. Introduced v0.22.21.
--
-- Two concepts:
--
--   * A PASSIVE is a named buff a bot carries for its whole mission
--     lifespan. Under the hood it is a Fatshark buff template applied
--     via BuffExtension:add_internally_controlled_buff. We register our
--     own templates via mod:hook_require on the standard buff_templates
--     require path, so they are indistinguishable from Fatshark's own
--     as far as the buff extension is concerned.
--
--   * TIER PASSIVES are baseline buffs a bot gets purely by being at a
--     certain tier. Tier 1 is the vanilla bot slot, no buffs. Higher
--     tiers get progressively more, matching the design intent that
--     bots you unlock via penances or Ordos are meaningfully stronger.
--
-- A preset picks its tier (baseline passives resolved from tier) plus a
-- list of preset-specific passives (unique flavour). Sister Argenta:
-- tier 3 (Champion baseline) + pilgrim_faith_shield (corruption immunity),
-- her signature Sororitas thematic.
--
-- Adding new passives:
--
--   1. Add an entry to M.CATALOGUE with a unique id, display_name,
--      description, buff_template (usually same as id), and a `custom`
--      block for our own buff (stat_buffs, keywords, duration, etc.).
--      If you want to point at a Fatshark template that already exists,
--      set buff_template = "their_name" and omit `custom`.
--
--   2. Optionally register it in M.TIER_PASSIVES[tier] so any bot at
--      that tier picks it up.
--
--   3. For preset-specific passives, add the id to that preset's
--      `passives` list in preset.lua.
--
-- Adding new tiers:
--
--   Extend M.TIER_PASSIVES with a new key. Presets set their `tier`
--   field to that key.

local M = {}

local _mod
local _shared
local _debug_log

-- ===========================================================================
-- Catalogue
-- ===========================================================================
--
-- The stat_buffs values use the same numeric conventions Fatshark's own
-- templates use:
--
--   damage_taken_multiplier      MULTIPLICATIVE. 0.9 = take 90% damage,
--                                i.e. 10% DR. 0 = full immunity.
--   corruption_taken_multiplier  MULTIPLICATIVE. 0 = corruption immunity.
--   melee_damage / ranged_damage ADDITIVE. 0.1 = +10% damage output.
--   combat_ability_cooldown_modifier  ADDITIVE. -0.15 = 15% faster CD.
--   ability_cooldown_modifier    ADDITIVE. -0.15 = 15% faster CD.
--
-- Verified against /tmp/dtsrc/scripts/settings/buff/buff_settings.lua
-- lines 704-724 and 649-692 (kind labels next to each stat name in
-- Fatshark's own source).

M.CATALOGUE = {
    {
        -- v0.28.8: Darktide's base wound count is three for Ogryn and two
        -- for every other playable archetype. The native difficulty bot
        -- buffs are neutralized during template registration below, then
        -- this private baseline adds the missing wound only to non-Ogryn
        -- Pilgrimage bots. Talents, curios and signature passives remain
        -- additive on top of the resulting three-wound baseline.
        id            = "pilgrim_non_ogryn_baseline_wound",
        display_name  = "Pilgrimage Bot Wound Baseline",
        description   = "Normalizes the bot's unmodified wound count to three.",
        buff_template = "pilgrim_non_ogryn_baseline_wound",
        custom = {
            stat_buffs = {
                extra_max_amount_of_wounds = 1,
            },
        },
    },
    {
        -- v0.22.95 (Abelard batch, safe subset): plain stat, confirmed
        -- spec "Practiced Steel, +30% melee damage".
        id            = "pilgrim_practiced_steel",
        display_name  = "Practiced Steel",
        description   = "+30% melee damage. Decades at the Lord Captain's side.",
        buff_template = "pilgrim_practiced_steel",
        custom = {
            stat_buffs = {
                melee_damage = 0.3,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_keystone_fanatic_rage",
        },
    },
    {
        -- v0.22.95 (Cassia, safe subset): the "bit of damage" third of
        -- her kit. Gaze of the Third Eye + Tisiphone's Discipline are
        -- proc passives and ship with the aura-engine batch.
        id            = "pilgrim_navigators_focus",
        display_name  = "Navigator's Focus",
        description   = "+20% warp damage. The third eye sees the seams of things.",
        buff_template = "pilgrim_navigators_focus",
        custom = {
            stat_buffs = {
                warp_damage = 0.2,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_passive_souldrinker",
        },
    },
    {
        -- v0.22.96 (Cassia kit, Kaizen-approved): 20% on-hit shock
        -- jolt: Attack.execute of the Smite channel tick profile at
        -- modest power = stagger CC + a little damage.
        id            = "pilgrim_gaze_third_eye",
        display_name  = "Gaze of the Third Eye",
        description   = "Her attacks have a 20% chance to lash the target with warp lightning, staggering it.",
        buff_template = "pilgrim_gaze_third_eye",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_passive_warp_battery",
            template = function(BS)
                return {
                    class_name = "server_only_proc_buff",
                    max_stacks = 1, max_stacks_cap = 1, predicted = false,
                    proc_events = { [BS.proc_events.on_hit] = 0.2 },
                    proc_func = function(params, template_data, template_context, t)
                        pcall(function()
                            local victim = params.attacked_unit
                            if not victim or not HEALTH_ALIVE[victim] then return end
                            local DPT = require("scripts/settings/damage/damage_profile_templates")
                            local DS = require("scripts/settings/damage/damage_settings")
                            local Attack = require("scripts/utilities/attack/attack")
                            Attack.execute(victim, DPT.psyker_protectorate_channel_chain_lightning_activated,
                                "power_level", 200, "damage_type", DS.damage_types.electrocution,
                                "attacking_unit", template_context.unit, "attack_type", "ranged")
                        end)
                    end,
                }
            end,
        },
    },
    {
        -- v0.22.96 (Cassia kit; Kaizen renamed from Paternova to the
        -- late tyrant of House Orsellio): her kills steel the warband.
        id            = "pilgrim_tisiphones_discipline",
        display_name  = "Tisiphone's Discipline",
        description   = "Her kills replenish 10% toughness for the pilgrim.",
        buff_template = "pilgrim_tisiphones_discipline",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_channel_grants_toughness_damage_reduction",
            template = function(BS)
                return {
                    class_name = "server_only_proc_buff",
                    max_stacks = 1, max_stacks_cap = 1, predicted = false,
                    cooldown_duration = 1,
                    proc_events = { [BS.proc_events.on_kill] = 1 },
                    proc_func = function(params, template_data, template_context, t)
                        pcall(function()
                            local player = Managers.player and Managers.player:local_player_safe(1)
                            local unit = player and player.player_unit
                            if not unit then return end
                            local Toughness = require("scripts/utilities/toughness/toughness")
                            Toughness.replenish_percentage(unit, 0.1, false, "buff")
                        end)
                    end,
                }
            end,
        },
    },
    {
        -- v0.22.96 (Jae, confirmed spec): +~7% move speed per stack on
        -- kill, 3 stacks, 5s. Stacks via a short-lived child buff.
        id            = "pilgrim_silver_tongue",
        display_name  = "Silver Tongue",
        description   = "Kills grant her a burst of speed, stacking briefly.",
        buff_template = "pilgrim_silver_tongue",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_movement_speed",
            template = function(BS)
                return {
                    class_name = "server_only_proc_buff",
                    max_stacks = 1, max_stacks_cap = 1, predicted = false,
                    proc_events = { [BS.proc_events.on_kill] = 1 },
                    proc_func = function(params, template_data, template_context, t)
                        pcall(function()
                            local unit = template_context.unit
                            local ext = ScriptUnit.extension(unit, "buff_system")
                            local FixedFrame = rawget(_G, "FixedFrame")
                            local ft = FixedFrame and FixedFrame.get_latest_fixed_time() or t
                            ext:add_externally_controlled_buff("pilgrim_silver_tongue_stack", ft)
                        end)
                    end,
                }
            end,
        },
    },
    {
        -- v0.22.96 (Jae, confirmed spec): dodge-vs-ranged window after
        -- taking ranged health damage, 15s internal cooldown.
        id            = "pilgrim_serpents_reflex",
        display_name  = "Serpent's Reflex",
        description   = "After ranged fire draws her blood, she weaves: counts as dodging ranged for 5 seconds.",
        buff_template = "pilgrim_serpents_reflex",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_dodge",
            template = function(BS)
                return {
                    class_name = "server_only_proc_buff",
                    max_stacks = 1, max_stacks_cap = 1, predicted = false,
                    cooldown_duration = 15,
                    proc_events = { [BS.proc_events.on_damage_taken] = 1 },
                    check_proc_func = function(params, template_data, template_context, t)
                        return params.attack_type == "ranged" and (params.damage or 0) > 0
                    end,
                    proc_func = function(params, template_data, template_context, t)
                        pcall(function()
                            local unit = template_context.unit
                            local ext = ScriptUnit.extension(unit, "buff_system")
                            local FixedFrame = rawget(_G, "FixedFrame")
                            local ft = FixedFrame and FixedFrame.get_latest_fixed_time() or t
                            ext:add_externally_controlled_buff("pilgrim_serpents_reflex_dodge", ft)
                        end)
                    end,
                }
            end,
        },
    },
    {
        id            = "pilgrim_elite_toughness",
        display_name  = "Elite Toughness",
        description   = "+10% damage resistance while operating.",
        buff_template = "pilgrim_elite_toughness",
        custom = {
            stat_buffs = {
                damage_taken_multiplier = 0.9,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_channel_grants_toughness_damage_reduction",
        },
    },
    {
        id            = "pilgrim_champion_might",
        display_name  = "Champion Might",
        description   = "+10% damage, +10% damage resistance, -15% combat ability cooldown.",
        buff_template = "pilgrim_champion_might",
        custom = {
            stat_buffs = {
                melee_damage                     = 0.1,
                ranged_damage                    = 0.1,
                damage_taken_multiplier          = 0.9,
                combat_ability_cooldown_modifier = -0.15,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_keystone_fanatic_rage",
        },
    },
    {
        id            = "pilgrim_faith_shield",
        display_name  = "Faith's Shield",
        description   = "Immune to corruption damage. Sororitas thematic; Sister Argenta's signature.",
        buff_template = "pilgrim_faith_shield",
        custom = {
            stat_buffs = {
                corruption_taken_multiplier = 0,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_aura_cleansing_prayer",
        },
    },
    {
        id            = "pilgrim_expanded_coherency",
        display_name  = "Bot Coherency Field",
        description   = "+300% coherency radius. Universal quality-of-life passive so bots don't visibly stray out of the coherency bubble; they can't strategise about positioning the way a human can.",
        buff_template = "pilgrim_expanded_coherency",
        custom = {
            stat_buffs = {
                -- coherency_radius_modifier is an "additive_multiplier"
                -- per buff_settings.lua line 687, so 3.0 = +300%.
                coherency_radius_modifier = 3.0,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_aura_always_in_coherency",
        },
    },
    {
        -- Pure passthrough to a Fatshark buff template. No `custom`
        -- block means install_templates does not synthesize a new one;
        -- add_internally_controlled_buff resolves the name in
        -- Fatshark's own registry (Mortis Trials / Hordes mode).
        --
        -- hordes_buff_coherency_corruption_healing installs a coherency
        -- aura that heals corruption from every ally within Sister
        -- Argenta's coherency radius on a 0.5s interval. Stacks with
        -- her Beacon of Purity talent (zealot_preacher_coherency_corruption_healing),
        -- so a coherent player gets both cleansing pulses.
        --
        -- Uses the Fatshark-provided icon: no hud_icon override needed.
        id            = "pilgrim_beacon_boon",
        display_name  = "Beacon of Purity Boon",
        description   = "Applies the Mortis Trials Beacon of Purity coherency-corruption-healing aura. Stacks with the Beacon of Purity talent for two healing sources.",
        buff_template = "hordes_buff_coherency_corruption_healing",
    },

    -- v0.22.35: three new preset-specific passives, one per new bot.
    -- All three are pure passthroughs to shipped Fatshark hordes-mode
    -- buff templates; no custom stat_buffs synthesis, so
    -- install_templates leaves them alone and add_internally_controlled_buff
    -- resolves them from Fatshark's own registry.

    {
        -- Magos Haneumann's tech-priest signature: his Voltaic Emitter
        -- (Cryptic discharge ability) always fires as if at max
        -- capacitance / stacks. Direct copy of Fatshark's Mortis
        -- Trials boon; Fatshark exposes it as
        -- hordes_buff_cryptic_discharge_ability_always_full_charges_bonus
        -- (hordes_legendary_cryptic_buff_templates.lua line 33).
        id            = "pilgrim_voltaic_master",
        display_name  = "Voltaic Master",
        description   = "Voltaic Emitter always fires at maximum capacitance. Signature of Magos Haneumann.",
        buff_template = "hordes_buff_cryptic_discharge_ability_always_full_charges_bonus",
    },
    {
        -- Two extra wounds via Fatshark's shipped
        -- hordes_buff_two_extra_wounds
        -- (hordes_unkillable_family_buff_templates.lua line 261).
        -- Kibellah stacks this WITH her native Martyrdom keystone in
        -- v0.22.37; extra wound count is exactly what makes Martyr
        -- scale further.
        id            = "pilgrim_indefatigable",
        display_name  = "Indefatigable",
        description   = "+2 wounds. Extra hit points for Martyrdom to scale with.",
        buff_template = "hordes_buff_two_extra_wounds",
    },
    {
        -- v0.22.36: Kibellah's combat multiplier stack, layered on
        -- top of Indefatigable and her native Martyrdom. Kaizen's
        -- spec: +50% attack speed, +50% crit chance, +35% crit
        -- damage. Names match Fatshark's stat_buffs registry exactly
        -- (buff_settings.lua lines 659, 706, 708). attack_speed and
        -- critical_strike_damage are additive_multiplier stats, so
        -- 0.5 = +50%, 0.35 = +35%. critical_strike_chance is a plain
        -- "value" stat, so 0.5 = add 0.5 (i.e. +50 percentage points)
        -- to base chance.
        id            = "pilgrim_kibellah_edge",
        display_name  = "Spinner's Edge",
        description   = "+50% melee attack speed, +50% melee crit chance, +35% melee crit damage. Layered on top of the Martyrdom keystone she runs natively. Melee-only per Kaizen's spec.",
        buff_template = "pilgrim_kibellah_edge",
        -- v0.22.42: was the generic attack_speed / critical_strike_*
        -- names, which apply to BOTH melee AND ranged. Kaizen wants
        -- these melee-only so her ranged play doesn't get an
        -- accidental boost. Fatshark exposes the melee-specific
        -- variants directly:
        --   melee_attack_speed         additive_multiplier
        --   melee_critical_strike_chance    value (percentage points)
        --   melee_critical_strike_damage    additive_multiplier
        -- (buff_settings.lua lines 798-800). Same numeric values.
        custom = {
            stat_buffs = {
                melee_attack_speed           = 0.5,
                melee_critical_strike_chance = 0.5,
                melee_critical_strike_damage = 0.35,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_hits_grant_stacking_damage",
        },
    },
    {
        -- Solomorne's Castigator Stance grants total damage immunity
        -- for its duration. Direct copy of Fatshark's Mortis Trials
        -- boon: hordes_buff_adamant_stance_immunity
        -- (hordes_legendary_adamant_buff_templates.lua line 33). The
        -- buff itself is passive; it only applies invulnerability
        -- during the ability window via a keywords_func check on
        -- adamant_hunt_stance. So Solomorne carries it always but the
        -- effect only fires when he's actually in stance.
        id            = "pilgrim_castigator_immortal",
        display_name  = "Castigator's Aegis",
        description   = "Total damage immunity while Castigator Stance is active. Solomorne's signature.",
        buff_template = "hordes_buff_adamant_stance_immunity",
    },

    -- v0.22.41: Heinrix's three signature passives.

    {
        -- Direct passthrough to Fatshark's Mortis Trials Psyker boon
        -- (hordes_legendary_psyker_buff_templates.lua line 32). Grants
        -- the `psyker_chain_lightning_full_charge` keyword, so Smite
        -- always fires at full charge as if Scrier's Gaze were up.
        -- Solves the bot's inability to time Scrier's Gaze before
        -- Smite: the boon makes the timing moot.
        id            = "pilgrim_heinrix_full_charge",
        display_name  = "Full Biolightning",
        description   = "Every Smite fires at maximum charge, as if Scrier's Gaze were always active.",
        buff_template = "hordes_buff_psyker_smite_always_max_damage",
    },
    {
        -- v0.22.43: layered on top of Full Biolightning per Kaizen's
        -- correction (keep the passthrough AND add raw damage).
        -- Fatshark exposes smite_damage as an additive_multiplier
        -- stat (buff_settings.lua line 894), so 2.0 = +200%. Stacks
        -- with the full-charge keyword: every Smite lands at max
        -- charge with triple damage on top.
        id            = "pilgrim_heinrix_biolightning",
        display_name  = "Overcharged Biolightning",
        description   = "+200% Smite damage. Stacks with Full Biolightning.",
        buff_template = "pilgrim_heinrix_biolightning",
        custom = {
            stat_buffs = {
                smite_damage = 2.0,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_psyker_smite_always_max_damage",
        },
    },

    {
        -- Enhanced Fast Metabolism (Mortis Trials boon
        -- hordes_buff_health_regen is 1% per 5s). Kaizen wants 3% per
        -- 5s, so this is a custom interval_buff mirroring Fatshark's
        -- own shape (hordes_unkillable_family_buff_templates.lua line
        -- 299) with a tripled percentage. Server-only guard is
        -- explicit; interval_func would otherwise fire redundantly on
        -- clients when they don't own the health extension write.
        id            = "pilgrim_heinrix_regen",
        display_name  = "Enhanced Metabolism",
        description   = "Regenerates 3% max HP every 5 seconds. Does not heal corruption.",
        buff_template = "pilgrim_heinrix_regen",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_health_regen",
            template = function(BS)
                return {
                    class_name    = "interval_buff",
                    max_stacks    = 1,
                    max_stacks_cap = 1,
                    predicted     = false,
                    buff_category = BS.buff_categories.hordes_buff or BS.buff_categories.generic,
                    interval      = 5,
                    interval_func = function(template_data, template_context, template, time_since_start, t)
                        if not template_context.is_server then return end
                        local unit = template_context.unit
                        local ok_ext, ext = pcall(ScriptUnit.extension, unit, "health_system")
                        if not ok_ext or not ext then return end
                        local ok_max, max_health = pcall(ext.max_health, ext)
                        if not ok_max or not max_health then return end
                        local ok_heal_settings, DamageSettings = pcall(require, "scripts/settings/damage/damage_settings")
                        local heal_type = ok_heal_settings
                            and DamageSettings
                            and DamageSettings.heal_types
                            and DamageSettings.heal_types.buff
                        pcall(ext.add_heal, ext, max_health * 0.03, heal_type)
                    end,
                }
            end,
        },
    },

    {
        -- Zealot-flavour on-hit heal. Kaizen asked for the zealot
        -- talent that regenerates health after being hit; talents
        -- can't be injected without wrecking her other keystone, so
        -- this is a server-only proc buff that fires on damage_taken
        -- against Heinrix and adds a small heal. 2s internal cooldown
        -- keeps a burst of hits from mega-healing him.
        --
        -- Values: 3% max HP per proc, min 2s between procs. Matches
        -- the "small consistent" feel of the zealot talent without
        -- the recuperate-from-corruption specificity, which is a
        -- health-extension mechanic that isn't buff-expressible on
        -- its own.
        id            = "pilgrim_heinrix_reactive_heal",
        display_name  = "Reactive Regeneration",
        description   = "Heals 3% max HP whenever hit (2 second cooldown between heals). Zealot-inspired.",
        buff_template = "pilgrim_heinrix_reactive_heal",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_health_regen",
            template = function(BS)
                return {
                    class_name        = "server_only_proc_buff",
                    max_stacks        = 1,
                    max_stacks_cap    = 1,
                    predicted         = false,
                    cooldown_duration = 2,
                    buff_category     = BS.buff_categories.hordes_buff or BS.buff_categories.generic,
                    proc_events       = {
                        [BS.proc_events.on_damage_taken] = 1,
                    },
                    -- Only heal when Heinrix himself is the victim
                    -- AND the hit dealt real HP damage (not just
                    -- toughness). Bots take a lot of toughness chip
                    -- damage; letting that trigger the heal would
                    -- effectively make him unkillable.
                    check_proc_func = function(params, template_data, template_context, t)
                        if params.attacked_unit ~= template_context.unit then
                            return false
                        end
                        return (params.damage_amount or 0) > 0
                    end,
                    proc_func = function(params, template_data, template_context, t)
                        local unit = template_context.unit
                        local ok_ext, ext = pcall(ScriptUnit.extension, unit, "health_system")
                        if not ok_ext or not ext then return end
                        local ok_max, max_health = pcall(ext.max_health, ext)
                        if not ok_max or not max_health then return end
                        local ok_heal_settings, DamageSettings = pcall(require, "scripts/settings/damage/damage_settings")
                        local heal_type = ok_heal_settings
                            and DamageSettings
                            and DamageSettings.heal_types
                            and DamageSettings.heal_types.buff
                        pcall(ext.add_heal, ext, max_health * 0.03, heal_type)
                    end,
                }
            end,
        },
    },

    -- v0.22.44: Kaizen's ask was "make Heinrix hold Smite longer, or
    -- auto-cast Scrier's Gaze so he doesn't overload." Making a bot
    -- auto-time a stance ability before Smite is a behavior-tree
    -- surgery job (Fatshark's engine BT + Better Bots' ability queue,
    -- both non-trivial to override safely). The mod-side answer that
    -- gives the same OUTCOME without touching bot AI: neutralise the
    -- peril generated by Smite itself. If Smite costs no peril,
    -- overload never happens, so channel length is not gated by it
    -- anymore and Scrier's Gaze wouldn't have helped there anyway.
    --
    -- Mechanism: warp_charge_amount_smite is a multiplicative_multiplier
    -- stat (buff_settings.lua line 946). Fatshark's own "Efficient
    -- Smites" talent uses 0.5 (halved peril generation) via
    -- talent_settings_2.combat_ability_3.warp_charge_amount_smite;
    -- Havoc-tier boons go down to 0.2. We drop to 0.05 (95% reduction)
    -- rather than exactly 0, because a hardcoded zero on a
    -- multiplicative stat occasionally trips edge cases in gameplay
    -- code that assumes non-zero costs. 5% is close enough to the
    -- intended outcome (effectively infinite channel) without daring
    -- a division/edge path.
    --
    -- Combined stack on Heinrix: Full Biolightning (every smite fires
    -- max-charge) + Overcharged Biolightning (+200% smite damage) +
    -- Undying Warp (near-zero peril from smite) = channel as long as
    -- the bot AI decides to hold the input, every tick at max damage.
    {
        id            = "pilgrim_heinrix_undying_warp",
        display_name  = "Undying Warp",
        description   = "Smite generates 95% less Peril. Heinrix can channel it indefinitely without overloading.",
        buff_template = "pilgrim_heinrix_undying_warp",
        custom = {
            stat_buffs = {
                -- warp_charge_amount_smite is a multiplicative_multiplier:
                -- 0.05 = final peril per smite is 5% of base.
                warp_charge_amount_smite = 0.05,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_psyker_smite_always_max_damage",
        },
    },

    -- =====================================================================
    -- v0.22.80: Idira Tlass signature kit (Kaizen-approved with changes,
    -- 2026-08-10). The volatile unsanctioned psyker: heavy warp damage,
    -- violent deaths in her wake, dampened but not tamed Peril, and a
    -- 10% chance that pain answers pain with a Perils detonation.
    -- =====================================================================

    {
        id            = "pilgrim_idira_warp_torrent",
        display_name  = "Warp Torrent",
        description   = "+30% warp damage. The storm does not ask permission.",
        buff_template = "pilgrim_idira_warp_torrent",
        custom = {
            stat_buffs = {
                -- additive_multiplier per buff_settings.lua line 951.
                warp_damage = 0.3,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_keystone_empowered_psyche",
        },
    },
    {
        -- Pure passthrough to Fatshark's Mortis Trials boon: enemies
        -- Idira kills with ranged attacks detonate (frag-grenade-class
        -- explosion at the corpse). hordes_legendary_generic_buff_
        -- templates.lua line 229; balanced and localised by Fatshark.
        id            = "pilgrim_idira_unstable_wake",
        display_name  = "Unstable Wake",
        description   = "Enemies slain by Idira's ranged attacks detonate. Things die violently around her.",
        buff_template  = "hordes_buff_explode_enemies_on_ranged_kill",
    },
    {
        id            = "pilgrim_idira_dampened_conduit",
        display_name  = "Overwhelmed, Not Consumed",
        description   = "All Peril generation reduced by 60%. Dampened, never tamed. (Kaizen tuned down from the proposed 90%.)",
        buff_template = "pilgrim_idira_dampened_conduit",
        custom = {
            stat_buffs = {
                -- multiplicative_multiplier (buff_settings.lua line
                -- 945): 0.4 = final Peril per action is 40% of base,
                -- a 60% reduction. Covers ALL her warp actions, unlike
                -- Heinrix's Smite-only variant.
                warp_charge_amount = 0.4,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_keystone_warp_syphon",
        },
    },
    {
        id            = "pilgrim_idira_thrice_bound",
        display_name  = "Thrice-Bound Soul",
        description   = "+3 wounds. Compensation for a body the warp keeps borrowing.",
        buff_template = "pilgrim_idira_thrice_bound",
        custom = {
            stat_buffs = {
                -- "value" type (buff_settings.lua line 760): flat +3
                -- health segments, same stat the hordes two-extra-
                -- wounds boon drives.
                extra_max_amount_of_wounds = 3,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_two_extra_wounds",
        },
    },
    {
        -- v0.28.9: authentic Perils state, replacing the former direct
        -- explosion approximation. A successful health-damage roll writes
        -- Darktide's warp-charge component to "exploding". The normal
        -- disruptive-state transition then owns the scream, gear sound,
        -- forced animation, native blast, weapon interruption and Peril reset.
        --
        -- The overload action hook below supplies its non-lethal branch only
        -- when this passive is present and the captured build does not already
        -- carry Crystalline Will. The passive then consumes one wound after a
        -- completed overload, which makes Thrice-Bound Soul's +3 wounds the
        -- intended safety reserve. A native Crystalline Will build keeps its
        -- own aftermath and is not charged twice.
        id            = "pilgrim_idira_perilous_vessel",
        display_name  = "Perilous Vessel",
        description   = "Health damage has a 10% chance to trigger Perils. Idira survives, but loses one wound.",
        buff_template = "pilgrim_idira_perilous_vessel",
        custom = {
            hud_icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_blocking_soulblaze",
            template = function(BS)
                local on_damage_taken = BS.proc_events.on_damage_taken
                local on_action_finish = BS.proc_events.on_action_finish
                return {
                    class_name     = "proc_buff",
                    max_stacks     = 1,
                    max_stacks_cap = 1,
                    predicted      = false,
                    buff_category  = BS.buff_categories.hordes_buff or BS.buff_categories.generic,
                    proc_events       = {
                        [on_damage_taken] = 0.1,
                        [on_action_finish] = 1,
                    },
                    start_func = function(template_data, template_context)
                        local unit = template_context.unit
                        local unit_data = ScriptUnit.extension(unit, "unit_data_system")
                        template_data.warp_charge = unit_data:write_component("warp_charge")
                        template_data.character_state = unit_data:read_component("character_state")
                        template_data.health = ScriptUnit.extension(unit, "health_system")
                        local talent = ScriptUnit.has_extension(unit, "talent_system")
                        template_data.native_crystalline_will = talent ~= nil
                            and talent:has_special_rule("psyker_no_knock_down_overload") == true
                        template_data.next_overload_t = 0
                    end,
                    specific_check_proc_funcs = {
                        [on_damage_taken] = function(params, template_data, template_context, t)
                            if not template_context.is_server
                                or params.attacked_unit ~= template_context.unit
                                or (params.damage_amount or 0) <= 0
                                or t < (template_data.next_overload_t or 0) then
                                return false
                            end
                            local warp_charge = template_data.warp_charge
                            local character_state = template_data.character_state
                            return warp_charge ~= nil
                                and warp_charge.state ~= "exploding"
                                and (not character_state
                                    or character_state.state_name ~= "exploding")
                        end,
                        [on_action_finish] = function(params, template_data, template_context)
                            return template_context.is_server
                                and not template_data.native_crystalline_will
                                and params.action_name == "action_warp_charge_explode"
                                and params.reason == "action_complete"
                        end,
                    },
                    specific_proc_func = {
                        [on_damage_taken] = function(params, template_data, template_context, t)
                            local warp_charge = template_data.warp_charge
                            if not warp_charge then
                                _debug_log("passives", 0,
                                    "Perilous Vessel proc had no warp-charge component", 0, "warn")
                                if _shared and type(_shared.notify) == "function" then
                                    _shared.notify("Idira's Perilous Vessel could not start.", "alert")
                                end
                                return
                            end
                            template_data.next_overload_t = t + 3
                            warp_charge.current_percentage = 1
                            warp_charge.starting_percentage = 1
                            warp_charge.state = "exploding"
                            _debug_log("passives", 0,
                                "Perilous Vessel armed native Psyker overload", 0, "info")
                        end,
                        [on_action_finish] = function(params, template_data, template_context)
                            local health = template_data.health
                            if not health or type(health.num_wounds) ~= "function" then
                                _debug_log("passives", 0,
                                    "Perilous Vessel survived overload but health extension was unavailable",
                                    0, "warn")
                                return
                            end
                            local current_wounds = health:num_wounds()
                            if current_wounds > 1
                                and type(health.remove_wounds) == "function" then
                                health:remove_wounds(1)
                                _debug_log("passives", 0,
                                    "Perilous Vessel consumed one wound after overload", 0, "info")
                                return
                            end
                            -- Match Crystalline Will's last-wound branch. This is
                            -- normally reachable only after Idira has exhausted the
                            -- three extra wounds granted by Thrice-Bound Soul.
                            local ok_attack, Attack = pcall(require,
                                "scripts/utilities/attack/attack")
                            local ok_profiles, DamageProfileTemplates = pcall(require,
                                "scripts/settings/damage/damage_profile_templates")
                            local ok_types, DamageSettings = pcall(require,
                                "scripts/settings/damage/damage_settings")
                            if ok_attack and ok_profiles and ok_types
                                and Attack and DamageProfileTemplates and DamageSettings then
                                Attack.execute(template_context.unit,
                                    DamageProfileTemplates.warp_charge_exploding_tick,
                                    "instakill", true,
                                    "damage_type", DamageSettings.damage_types.warp_overload)
                            end
                        end,
                    },
                }
            end,
        },
    },

    -- =====================================================================
    -- v0.22.80: Theodora von Valancius signature kit (partial; her
    -- coherency aura, Lord Captain's Standard, is specced in the
    -- roadmap and ships with Abelard's aura batch). Dynastic Largesse
    -- (+50% Ordos earned while she is in the warband) is implemented
    -- wallet-side (wallet.lua SLOTTED_PRESET_MULTIPLIERS), not as a
    -- buff, so it has no entry here.
    -- =====================================================================

    {
        id            = "pilgrim_theodora_duellist_poise",
        display_name  = "Duellist's Poise",
        description   = "+20% melee damage, +10% attack speed. The Lord Captain's falchion craft.",
        buff_template = "pilgrim_theodora_duellist_poise",
        custom = {
            stat_buffs = {
                melee_damage = 0.2,
                attack_speed = 0.1,
            },
            hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_hits_grant_stacking_damage",
        },
    },
}

local _by_id = {}
for i = 1, #M.CATALOGUE do _by_id[M.CATALOGUE[i].id] = M.CATALOGUE[i] end

-- ===========================================================================
-- Tier passives
-- ===========================================================================
--
-- Tier is a small integer keyed off a preset's `tier` field. A preset
-- with tier N picks up every id in TIER_PASSIVES[N] AND its own
-- `passives` list. Both apply through the same buff extension so
-- Fatshark's max_stacks / uniqueness handling stops double-application.

M.TIER_PASSIVES = {
    [1] = {},                                          -- Novice, no bonuses
    [2] = { "pilgrim_elite_toughness" },               -- Elite
    [3] = { "pilgrim_champion_might" },                -- Champion
}

-- v0.22.24: universal passives are applied to every Pilgrimage bot
-- regardless of tier or preset. Right now this is Kaizen's coherency
-- widen, which is a quality-of-life patch across the board: bots
-- can't reason about positioning the way you can, so widening their
-- coherency bubble means they don't drift out and drop the aura for
-- their teammates. Apply order: universal → tier baseline → preset
-- specifics (see resolve_for_preset below).
-- v0.28.8: the native difficulty buffs' wound fields are removed in
-- install_templates. resolve_for_preset adds one wound to non-Ogryn classes,
-- producing a three-wound baseline at every difficulty. The +2 on Kibellah
-- and +3 on Idira remain intentional signature passives on top of that.
M.UNIVERSAL_PASSIVES = {
    "pilgrim_expanded_coherency",
}

-- ===========================================================================
-- Public read API
-- ===========================================================================

function M.get(id) return _by_id[id] end
function M.all() return M.CATALOGUE end

function M.tier_passives(tier)
    tier = tonumber(tier) or 1
    return M.TIER_PASSIVES[tier] or {}
end

-- Merge tier passives + preset passives into a flat de-duplicated list.
-- Used by the pump: one list per preset, applied slot by slot to the bot.
function M.resolve_for_preset(preset)
    if type(preset) ~= "table" then return {} end
    local ordered = {}
    local seen = {}
    local function push(id)
        if not id or seen[id] then return end
        seen[id] = true
        ordered[#ordered + 1] = id
    end
    -- v0.22.24: universal → tier baseline → preset-specific.
    -- The seen-set gate makes duplicates across those three layers a
    -- no-op, so a preset can safely list a passive it already gets
    -- from tier or universal (no double-apply on Fatshark's side
    -- either, because our custom templates all set max_stacks = 1).
    for i = 1, #M.UNIVERSAL_PASSIVES do push(M.UNIVERSAL_PASSIVES[i]) end
    if preset.archetype_name and preset.archetype_name ~= "ogryn" then
        push("pilgrim_non_ogryn_baseline_wound")
    end
    local tier_ids = M.TIER_PASSIVES[preset.tier or 1] or {}
    for i = 1, #tier_ids do push(tier_ids[i]) end
    local preset_ids = preset.passives or {}
    for i = 1, #preset_ids do push(preset_ids[i]) end
    return ordered
end

-- ===========================================================================
-- Custom buff template registration
-- ===========================================================================
--
-- Fatshark's buff template registry is built by
-- scripts/settings/buff/buff_templates.lua which returns a merged
-- `templates` table via `settings("BuffTemplates", templates)`. DMF's
-- hook_require lets us amend that table the first time it's required.
-- Runs once per mod load; entries stay live for the whole session.

-- v0.22.81 (Boons v2 foothold): other modules can register their own
-- template catalogues to ride this file's buff_templates hook_require.
-- One hook on the require path is safer than several modules each
-- installing their own; DMF's hook_require behavior with multiple
-- registrants on one path is not something we want to depend on.
-- Boons.lua registers its custom-boon catalogue here at init. Entries
-- use the exact same schema as M.CATALOGUE (id / buff_template /
-- custom.stat_buffs or custom.template factory).
M.EXTERNAL_TEMPLATE_SOURCES = {}

function M.register_template_source(catalogue)
    if type(catalogue) ~= "table" then return false end
    M.EXTERNAL_TEMPLATE_SOURCES[#M.EXTERNAL_TEMPLATE_SOURCES + 1] = catalogue
    return true
end

function M.install_templates()
    if not _mod or type(_mod.hook_require) ~= "function" then return end

    _mod:hook_require("scripts/settings/buff/buff_templates",
        function(templates)
            local ok_settings, BuffSettings = pcall(require, "scripts/settings/buff/buff_settings")
            if not ok_settings or type(BuffSettings) ~= "table" then
                _debug_log("passives", 0,
                    "BuffSettings unavailable; custom templates not registered", 0, "warn")
                return
            end
            local stat_buffs      = BuffSettings.stat_buffs
            local buff_categories = BuffSettings.buff_categories
            local keywords        = BuffSettings.keywords
            if not stat_buffs or not buff_categories then
                _debug_log("passives", 0,
                    "BuffSettings has no stat_buffs/buff_categories; templates not registered",
                    0, "warn")
                return
            end

            -- Darktide normally adds one or two wounds to every bot as the
            -- difficulty rises. That turns the intended three-wound baseline
            -- into four for most classes and five for Ogryn. Remove only that
            -- wound field and leave the native health, Toughness, block and
            -- revive bonuses untouched. Non-Ogryn Pilgrimage bots receive one
            -- explicit baseline wound through resolve_for_preset above.
            local wound_token = stat_buffs.extra_max_amount_of_wounds
            local normalized_native_buffs = 0
            if wound_token ~= nil then
                for _, template_name in ipairs({ "bot_medium_buff", "bot_high_buff" }) do
                    local native_template = templates[template_name]
                    if native_template and type(native_template.stat_buffs) == "table"
                        and native_template.stat_buffs[wound_token] ~= nil then
                        native_template.stat_buffs[wound_token] = nil
                        normalized_native_buffs = normalized_native_buffs + 1
                    end
                end
            end
            _debug_log("passives", 0,
                "normalized native wound bonus in " .. normalized_native_buffs
                    .. " bot difficulty template(s)", 0, "info")

            local registered = 0
            -- v0.22.81: walk our catalogue plus every registered
            -- external source (custom boons from boons.lua ride this
            -- same hook; see register_template_source above).
            local sources = { M.CATALOGUE }
            for si = 1, #M.EXTERNAL_TEMPLATE_SOURCES do
                sources[#sources + 1] = M.EXTERNAL_TEMPLATE_SOURCES[si]
            end
            for src = 1, #sources do
            for i = 1, #sources[src] do
                local p = sources[src][i]
                -- v0.22.38: hard-guard against a catalogue entry that
                -- forgot buff_template. Without this the `templates[nil]`
                -- write throws "table index is nil" and crashes the
                -- game at gameplay init (character select). A skipped
                -- passive is a graceful degradation; a crash is not.
                if p.custom and (type(p.buff_template) ~= "string" or p.buff_template == "") then
                    _debug_log("passives", 0,
                        "passive '" .. tostring(p.id) ..
                        "' has custom stat_buffs but no buff_template field; skipping registration",
                        0, "warn")
                elseif p.custom and not templates[p.buff_template] then
                    -- v0.22.41: two synthesis paths.
                    --
                    -- 1. `custom.template` (table or factory function
                    --    (BuffSettings) -> table): raw template written
                    --    directly against Fatshark's shape. Use when the
                    --    passive needs interval_buff, server_only_proc_buff,
                    --    proc_events, start_func, etc, none of which the
                    --    stat_buffs/keywords shortcut can express.
                    -- 2. `custom.stat_buffs` + `custom.keywords`: the
                    --    original shortcut that synthesises a plain
                    --    duration=huge buff. Covers the vast majority of
                    --    passives (Elite Toughness, Champion Might,
                    --    Spinner's Edge...).
                    local synthesized
                    if p.custom.template then
                        local factory = p.custom.template
                        if type(factory) == "function" then
                            local ok, out = pcall(factory, BuffSettings)
                            if ok and type(out) == "table" then
                                synthesized = out
                            else
                                _debug_log("passives", 0,
                                    "custom template factory for '" .. p.id ..
                                    "' failed: " .. tostring(out), 0, "warn")
                            end
                        elseif type(factory) == "table" then
                            synthesized = factory
                        end
                        if synthesized then
                            -- Fill in name if the factory didn't; keeps
                            -- template-vs-registry consistency.
                            synthesized.name = synthesized.name or p.buff_template
                            if p.custom.hud_icon and not synthesized.hud_icon then
                                synthesized.hud_icon = p.custom.hud_icon
                            end
                        end
                    end

                    if not synthesized then
                        local resolved_stat_buffs = {}
                        for stat_name, value in pairs(p.custom.stat_buffs or {}) do
                            local token = stat_buffs[stat_name]
                            if token ~= nil then
                                resolved_stat_buffs[token] = value
                            else
                                _debug_log("passives", 0,
                                    "unknown stat_buff '" .. tostring(stat_name) ..
                                    "' in passive " .. p.id, 0, "warn")
                            end
                        end

                        local resolved_keywords = {}
                        for _, keyword_name in ipairs(p.custom.keywords or {}) do
                            local token = keywords and keywords[keyword_name]
                            if token ~= nil then
                                resolved_keywords[#resolved_keywords + 1] = token
                            end
                        end

                        synthesized = {
                            class_name    = "buff",
                            name          = p.buff_template,
                            duration      = p.custom.duration or math.huge,
                            predicted     = false,
                            max_stacks    = 1,
                            stat_buffs    = resolved_stat_buffs,
                            keywords      = resolved_keywords,
                            buff_category = buff_categories.generic,
                            hud_icon      = p.custom.hud_icon,
                        }
                    end

                    templates[p.buff_template] = synthesized
                    registered = registered + 1
                end
            end
            end

            -- ===============================================================
            -- v0.25.2 PERFORMANCE FIX (root-caused from Kaizen's 2026-08-12
            -- console log): every custom template registered above must ALSO
            -- be registered in NetworkLookup.buff_templates. Vanilla builds
            -- that lookup at boot from its own template list and gives it a
            -- metatable whose __index on a MISSING key calls
            -- table.dump(lookup_table) and errors (network_lookup.lua:578).
            -- Our pilgrim_ names were never in it, so any engine or mod path
            -- that indexes the lookup by an applied buff's name dumped the
            -- ENTIRE ~5300-entry table to the console log, inside a pcall
            -- that swallowed the error but not the dump. The field readout:
            -- 22 dumps in the first 35 seconds of a leg (the reconciler's
            -- cadence), 817k log lines, 90 MB of log, 100-450 ms frame
            -- stalls, "6 fps upon loading into a mission". Registering the
            -- names kills the storm at the source. rawget is MANDATORY for
            -- the existence probe: a plain read of a missing key IS the dump.
            -- Solo-host mod, so extending the lookup cannot desync anyone;
            -- both ends of the "network" are the same machine.
            local ok_nl, NetworkLookup = pcall(require, "scripts/network_lookup/network_lookup")
            if ok_nl and type(NetworkLookup) == "table"
                and type(NetworkLookup.buff_templates) == "table" then
                local bt = NetworkLookup.buff_templates
                local added = 0
                for src = 1, #sources do
                for i = 1, #sources[src] do
                    local name = sources[src][i].buff_template
                    if type(name) == "string" and name ~= ""
                        and rawget(bt, name) == nil then
                        local index = #bt + 1
                        bt[index] = name
                        bt[name] = index
                        added = added + 1
                    end
                end
                end
                if added > 0 then
                    _debug_log("passives", 0, "registered " .. added
                        .. " custom template name(s) in NetworkLookup.buff_templates"
                        .. " (dump-storm fix)", 0, "info")
                end
            else
                _debug_log("passives", 0,
                    "NetworkLookup unavailable; buff lookup dumps may continue", 0, "warn")
            end

            _debug_log("passives", 0,
                "registered " .. registered .. " custom buff template(s)", 0, "info")
        end)
end

-- Perilous Vessel needs one narrow bridge into the real overload action.
-- Darktide decides whether that action kills the Psyker through the private
-- `_psyker_alternative_overload` flag. We leave the native talent decision
-- intact, then turn the flag on only for a unit carrying Idira's passive.
-- Everything else, including the action timing, VFX, SFX and explosion, stays
-- in Fatshark's code. The passive template above owns the one-wound aftermath.
local _idira_overload_hook_installed = false

local function _install_idira_overload_hook(action_class)
    if _idira_overload_hook_installed or not action_class
        or not _mod or type(_mod.hook) ~= "function" then
        return false
    end
    _mod:hook(action_class, "start", function(func, self, action_settings, ...)
        func(self, action_settings, ...)
        local unit = self._player_unit
        local buff_extension = unit and ScriptUnit.has_extension(unit, "buff_system")
        if action_settings and action_settings.overload_type == "warp_charge"
            and buff_extension
            and type(buff_extension.has_buff_using_buff_template) == "function"
            and buff_extension:has_buff_using_buff_template(
                "pilgrim_idira_perilous_vessel") then
            self._psyker_alternative_overload = true
        end
    end)
    _idira_overload_hook_installed = true
    _debug_log("passives", 0,
        "installed authentic Perilous Vessel overload survival hook", 0, "info")
    return true
end

function M.install_idira_overload_hook()
    local classes = rawget(_G, "CLASS")
    if classes and _install_idira_overload_hook(classes.ActionOverloadExplosion) then
        return true
    end
    if _mod and type(_mod.hook_require) == "function" then
        _mod:hook_require(
            "scripts/extension_systems/weapon/actions/action_overload_explosion",
            function(action_class)
                _install_idira_overload_hook(action_class)
            end)
        return true
    end
    _debug_log("passives", 0,
        "could not schedule Perilous Vessel overload survival hook", 0, "warn")
    return false
end

-- Field diagnostic for the probabilistic Idira passive. It uses exactly the
-- same component state as a successful 10% health-damage roll, but only when
-- the live Idira bot actually carries Perilous Vessel. This lets one command
-- prove the native scream, animation and overload action without changing the
-- passive's combat odds.
function M.force_idira_overload()
    local Managers = rawget(_G, "Managers")
    local player_manager = Managers and Managers.player
    if not player_manager or type(player_manager.bot_players) ~= "function" then
        return false, "bot player manager unavailable"
    end
    local ok_players, players = pcall(player_manager.bot_players, player_manager)
    if not ok_players or type(players) ~= "table" then
        return false, "bot list unavailable"
    end
    local unit = nil
    for _, player in pairs(players) do
        local profile = nil
        if player and type(player.profile) == "function" then
            local ok_profile, value = pcall(player.profile, player)
            if ok_profile then profile = value end
        end
        profile = profile or (player and player._profile)
        if profile and profile.character_id == "pilgrim_idira_tlass" then
            unit = player.player_unit
            break
        end
    end
    if not unit then return false, "Idira is not alive in the party" end

    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
    if not buff_extension
        or type(buff_extension.has_buff_using_buff_template) ~= "function"
        or not buff_extension:has_buff_using_buff_template(
            "pilgrim_idira_perilous_vessel") then
        return false, "Perilous Vessel is not applied to Idira"
    end

    local ok_data, unit_data = pcall(ScriptUnit.extension, unit, "unit_data_system")
    if not ok_data or not unit_data then return false, "unit data unavailable" end
    local ok_warp, warp_charge = pcall(unit_data.write_component,
        unit_data, "warp_charge")
    if not ok_warp or not warp_charge then return false, "warp-charge component unavailable" end
    if warp_charge.state == "exploding" then return false, "Idira is already overloading" end

    warp_charge.current_percentage = 1
    warp_charge.starting_percentage = 1
    warp_charge.state = "exploding"
    _debug_log("passives", 0,
        "forced Perilous Vessel native overload diagnostic", 0, "info")
    return true
end

-- ===========================================================================
-- Apply
-- ===========================================================================
--
-- Applies a passive to a bot's unit by calling
-- BuffExtension:add_internally_controlled_buff. Idempotent for
-- max_stacks=1 buffs (Fatshark's own _handle_unique_buffs check
-- prevents duplicates); we also track applied set per unit in the
-- pump for cheaper early-outs.
--
-- Returns (ok, err). ok=true means the buff was added OR was already
-- present. err is populated on real failures (no extension, unknown
-- template, unit not alive).

function M.apply_to_unit(unit, passive_id)
    local passive = _by_id[passive_id]
    if not passive then return false, "unknown passive: " .. tostring(passive_id) end

    local ScriptUnit = rawget(_G, "ScriptUnit")
    if not ScriptUnit or type(ScriptUnit.extension) ~= "function" then
        return false, "no ScriptUnit.extension"
    end

    local ok_alive, alive = pcall(function()
        local Unit = rawget(_G, "Unit")
        return Unit and Unit.alive and Unit.alive(unit)
    end)
    if not ok_alive or not alive then return false, "unit not alive" end

    local ok_ext, buff_ext = pcall(ScriptUnit.extension, unit, "buff_system")
    if not ok_ext or not buff_ext then return false, "no buff extension yet" end
    if type(buff_ext.add_internally_controlled_buff) ~= "function" then
        return false, "buff extension missing add_internally_controlled_buff"
    end

    local FixedFrame = rawget(_G, "FixedFrame")
    local t = (FixedFrame and FixedFrame.get_latest_fixed_time
        and FixedFrame.get_latest_fixed_time()) or 0

    local ok, err = pcall(buff_ext.add_internally_controlled_buff, buff_ext, passive.buff_template, t)
    if not ok then return false, "add threw: " .. tostring(err) end
    return true
end

-- ===========================================================================
-- Pump: apply preset-resolved passives to Pilgrimage bots
-- ===========================================================================
--
-- Called from the Tick scheduler at 0.5s intervals. Iterates every bot
-- player, resolves its preset's passives via resolve_for_preset, and
-- applies each one that isn't already applied. Tracked per (unit,
-- passive_id) so once a bot has its full set, subsequent ticks are
-- effectively no-op iterations of an empty pending set.
--
-- Reset by preset.reset_spawn_counter on StateLoading enter so each
-- fresh mission starts with an empty applied set.

local _applied = {}                        -- [unit] = { [passive_id] = true }
local _retry_count = {}                    -- [unit][passive_id] = int
local PASSIVE_MAX_RETRIES = 20

function M.reset_pump_state()
    _applied = {}
    _retry_count = {}
end

function M.pump(preset_module)
    if type(preset_module) ~= "table" or type(preset_module.default_preset) ~= "function" then
        return
    end
    local Managers = rawget(_G, "Managers")
    if not Managers or not Managers.player
        or type(Managers.player.bot_players) ~= "function" then
        return
    end

    local ok_players, bot_players = pcall(Managers.player.bot_players, Managers.player)
    if not ok_players or type(bot_players) ~= "table" then return end

    for _, player in pairs(bot_players) do
        local unit = player.player_unit
        if unit then
            local profile
            if type(player.profile) == "function" then
                local ok_p, res_p = pcall(player.profile, player)
                if ok_p then profile = res_p end
            end
            profile = profile or player._profile

            local preset_id = type(profile) == "table" and profile._pilgrimage_preset
            local preset = preset_id and preset_module.get and preset_module.get(preset_id)

            if preset then
                local passive_ids = M.resolve_for_preset(preset)
                if #passive_ids > 0 then
                    _applied[unit] = _applied[unit] or {}
                    _retry_count[unit] = _retry_count[unit] or {}
                    for i = 1, #passive_ids do
                        local pid = passive_ids[i]
                        if not _applied[unit][pid] then
                            local retries = _retry_count[unit][pid] or 0
                            if retries >= PASSIVE_MAX_RETRIES then
                                -- Give up; stop pumping this passive.
                                _applied[unit][pid] = true
                                _debug_log("passives", 0,
                                    "passive " .. pid .. " apply hit retry cap on a bot",
                                    0, "warn")
                            else
                                _retry_count[unit][pid] = retries + 1
                                local ok = M.apply_to_unit(unit, pid)
                                if ok then
                                    _applied[unit][pid] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ===========================================================================

function M.status()
    local applied_count = 0
    for _, per_unit in pairs(_applied) do
        for _ in pairs(per_unit) do applied_count = applied_count + 1 end
    end
    return {
        catalogue_size    = #M.CATALOGUE,
        tiers             = M.TIER_PASSIVES,
        universal         = M.UNIVERSAL_PASSIVES,
        applied_count     = applied_count,
    }
end

-- ===========================================================================
-- v0.22.96: AURA ENGINE (the deferred batch, built from the roadmap
-- spec with all three APIs verified: PlayerUnitBuffExtension.
-- remove_externally_controlled_buff(local_index, component_index) at
-- line 338, Toughness.replenish_percentage, toughness percent reads).
-- Tick-driven (Pilgrimage.lua, 1s): each def names a source preset, a
-- target (player or the bot itself), an optional radius (coherency
-- approximated by distance), and a condition. Buffs are added via
-- add_externally_controlled_buff and removed with the captured
-- (index, component_index) pair the moment the condition fails.
-- ===========================================================================

local AURA_TEMPLATES = {
    { buff_template = "pilgrim_aura_standard",  custom = { stat_buffs = { damage = 0.1 } } },
    { buff_template = "pilgrim_aura_aegis",     custom = { stat_buffs = { damage_taken_multiplier = 0.8 } } },
    { buff_template = "pilgrim_aura_precept",   custom = { stat_buffs = { ranged_damage = 0.15 } } },
    { buff_template = "pilgrim_steady_blade",   custom = { stat_buffs = { toughness_regen_rate_modifier = 1.5 } } },
    { buff_template = "pilgrim_sleight_of_hand", custom = { stat_buffs = { critical_strike_chance = 0.3 } } },
    { buff_template = "pilgrim_silver_tongue_stack",
      custom = { stat_buffs = { movement_speed = 0.07 }, duration = 5 } },
    { buff_template = "pilgrim_serpents_reflex_dodge",
      custom = { keywords = { "count_as_dodge_vs_ranged" }, duration = 5 } },
}
for i = 1, #AURA_TEMPLATES do
    M.EXTERNAL_TEMPLATE_SOURCES[#M.EXTERNAL_TEMPLATE_SOURCES + 1] = { AURA_TEMPLATES[i] }
end

local AURA_RADIUS_SQ = 15 * 15

local function _toughness_percent(unit)
    local ok, ext = pcall(ScriptUnit.extension, unit, "toughness_system")
    if not ok or not ext then return nil end
    local ok2, pct = pcall(ext.current_toughness_percent, ext)
    return ok2 and pct or nil
end

local function _wielded_slot(unit)
    local ok, ud = pcall(ScriptUnit.extension, unit, "unit_data_system")
    if not ok or not ud then return nil end
    local ok2, inv = pcall(ud.read_component, ud, "inventory")
    return ok2 and inv and inv.wielded_slot or nil
end

local function _health_percent(unit)
    local ok, ext = pcall(ScriptUnit.extension, unit, "health_system")
    if not ok or not ext then return nil end
    local ok2, cur = pcall(ext.current_health_percent, ext)
    return ok2 and cur or nil
end

M.AURAS = {
    { id = "standard", preset = "theodora_von_valancius", target = "player",
      template = "pilgrim_aura_standard", radius = true,
      condition = function(bot, player_unit) return true end },
    { id = "aegis", preset = "seneschal_abelard", target = "player",
      template = "pilgrim_aura_aegis", radius = true,
      condition = function(bot, player_unit)
          local hp = _health_percent(player_unit)
          return hp ~= nil and hp < 0.5
      end },
    { id = "precept", preset = "seneschal_abelard", target = "player",
      template = "pilgrim_aura_precept", radius = true,
      -- v1 approximation of "when Abelard fires": his gun is out.
      condition = function(bot, player_unit)
          return _wielded_slot(bot) == "slot_secondary"
      end },
    { id = "steady_blade", preset = "seneschal_abelard", target = "self",
      template = "pilgrim_steady_blade",
      condition = function(bot) return (_toughness_percent(bot) or 0) > 0.7 end },
    { id = "sleight_of_hand", preset = "princess_jae", target = "self",
      template = "pilgrim_sleight_of_hand",
      condition = function(bot) return (_toughness_percent(bot) or 0) >= 1 end },
}

local _aura_state = {}

local function _bot_unit_for_preset(preset_id)
    local players = Managers.player and Managers.player:players()
    if not players then return nil end
    local want = "pilgrim_" .. preset_id
    for _, player in pairs(players) do
        local ok_h, is_human = pcall(player.is_human_controlled, player)
        if ok_h and not is_human and player.player_unit then
            local ok_p, profile = pcall(player.profile, player)
            if ok_p and profile and profile.character_id == want then
                return player.player_unit
            end
        end
    end
    return nil
end

local function _remove_aura(key)
    local st = _aura_state[key]
    _aura_state[key] = nil
    if not st then return end
    pcall(function()
        local ext = ScriptUnit.extension(st.unit, "buff_system")
        ext:remove_externally_controlled_buff(st.index, st.component_index)
    end)
end

function M.update_auras()
    local player = Managers.player and Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    for i = 1, #M.AURAS do
        local def = M.AURAS[i]
        local bot = _bot_unit_for_preset(def.preset)
        local target = def.target == "self" and bot or player_unit
        local want = false
        if bot and target and rawget(_G, "HEALTH_ALIVE") and HEALTH_ALIVE[bot] then
            local ok_c, cond = pcall(def.condition, bot, player_unit)
            want = ok_c and cond or false
            if want and def.radius and player_unit and def.target == "player" then
                local ok_d, in_range = pcall(function()
                    local a = POSITION_LOOKUP[bot]
                    local b = POSITION_LOOKUP[player_unit]
                    return a and b and Vector3.distance_squared(a, b) <= AURA_RADIUS_SQ
                end)
                want = ok_d and in_range or false
            end
        end
        local st = _aura_state[def.id]
        if want and (not st or st.unit ~= target) then
            if st then _remove_aura(def.id) end
            pcall(function()
                local ext = ScriptUnit.extension(target, "buff_system")
                local FixedFrame = rawget(_G, "FixedFrame")
                local ft = FixedFrame and FixedFrame.get_latest_fixed_time() or 0
                local _, index, component_index = ext:add_externally_controlled_buff(def.template, ft)
                if index then
                    _aura_state[def.id] = { unit = target, index = index, component_index = component_index }
                end
            end)
        elseif not want and st then
            _remove_aura(def.id)
        end
    end
end

function M.reset_auras()
    for key in pairs(_aura_state) do _remove_aura(key) end
end

function M.init(deps)
    _mod       = deps.mod
    _shared    = deps.shared
    _debug_log = deps.debug_log or function() end
    M.install_templates()
    M.install_idira_overload_hook()
end

return M
