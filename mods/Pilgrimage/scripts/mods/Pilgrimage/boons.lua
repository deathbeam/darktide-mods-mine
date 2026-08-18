-- boons.lua
--
-- Run-scoped buffs, drafted between legs and applied on every mission start.
--
-- ===========================================================================
-- WE DO NOT INVENT BUFFS. WE REUSE THE ONES THE GAME ALREADY SHIPS.
-- ===========================================================================
--
-- Mortis Trials introduced 138 "Mission Buffs": burning on melee hit, two extra wounds,
-- infinite ammo during stance, and so on. They are exactly the shape a Chaos Wastes boon
-- wants, they are already balanced, already localised, and already have icons.
--
-- Crucially they are also merged into the GLOBAL BuffTemplates table, not kept somewhere
-- only the Hordes manager can see. buff_templates.lua:32-48 pulls every hordes file in
-- through _create_entry, so BuffTemplates["hordes_buff_two_extra_wounds"] resolves and
-- add_externally_controlled_buff can find it by name. That single fact is what makes this
-- module twenty lines of application code instead of a custom buff system.
--
-- ===========================================================================
-- THE THREE TRAPS
-- ===========================================================================
--
-- 1. THE RETURN VALUES ARE NOT WHAT YOU EXPECT.
--
--        player_unit_buff_extension.lua:226
--        return client_tried_adding_rpc_buff, index, component_index
--
--    The FIRST value is an error flag, not the handle. An earlier draft of this mod had
--    this wrong and assigned the flag to the index, which would have leaked every buff it
--    ever applied. Success is `index ~= nil`, and that is also how the game's own
--    mission_buffs_handler.lua:121 tests it. Note it does not test the flag: a "muted"
--    buff returns a real index with nothing applied, so index is the only honest signal.
--
-- 2. APPLYING TWICE DOUBLE-STACKS, EVEN ON max_stacks = 1.
--
--    add_externally_controlled_buff skips _can_add_internally_controlled_buff, which is
--    the thing that enforces the stack cap. It lands in _add_buff, which calls
--    Buff.add_stack, and set_stack_count does NOT clamp (buff.lua:479). It merely skips
--    the on_add_stack callback. So a second grant of a single-stack boon silently doubles
--    its stat_buffs.
--
--    The game avoids this at SELECTION time, not application time: it checks
--    does_player_have_buff_saved and destructively removes each pick from the pool. We do
--    the same, and additionally keep _applied as a per-unit guard so a double tick or a
--    double hook can never grant the same name twice to the same body.
--
-- 3. THE DESCRIPTION IS NOT A PLAIN LOCALISATION KEY.
--
--    Localizing it directly gives you literal "{time}" and "{dammage}" in the text. The
--    numbers live in a separate buff_stats table and are substituted by
--    MissionBuffsParser.get_formated_buff_description, which also colours them. We use the
--    game's parser rather than reimplementing the formatting.
--
-- ===========================================================================
-- SERVER ONLY, WHICH IS FINE HERE
-- ===========================================================================
--
-- Every hordes template is `predicted = false`, and a non-predicted external buff bails
-- out on a client (`elseif not is_server then client_tried_adding_rpc_buff = true`).
-- In a Pilgrimage leg we ARE the server, so this works. It also means the mod cannot
-- accidentally do anything in a public game, which is the behaviour we want anyway.

local M = {}

local _mod
local _shared
local _run_state
local _event_log
local _hooks
local _debug_log
-- Declared with the other injected deps, at the TOP, and the position is load-bearing.
-- v0.14.1 declared these two below M.info, and a Lua function only captures locals
-- that exist ABOVE its definition; M.info silently read a nil global instead, the icon
-- override never ran, and the draft cards kept the placeholder while every probe in
-- the debug report said the stand-ins were ready. Position is behaviour.
local _icons
local _missions -- injected, only for its seeded generator
-- v0.22.81: loadout deps (wallet purchases, shop slot expansions)
local _wallet
local _shop

local SENTINEL = "__pilgrimage_boons_installed"

local ALLOWED_BUFFS_PATH = "scripts/managers/mission_buffs/mission_buffs_allowed_buffs"
local PARSER_PATH = "scripts/ui/constant_elements/elements/mission_buffs/utilities/mission_buffs_parser"
local BUFFS_DATA_PATH = "scripts/settings/buff/hordes_buffs/hordes_buffs_data"

M.GAME_MODE_MANAGER_PATH = "scripts/managers/game_mode/game_mode_manager"

-- ---------------------------------------------------------------------------
-- Source tables
--
-- Fetched lazily and cached. All three are pure data, so caching is safe, and none of
-- them exist before the game has loaded its settings.
-- ---------------------------------------------------------------------------

local _allowed = nil
local _pool = nil
-- v0.24.0: pool partitions, rebuilt alongside _pool by build_pool.
-- _family_of maps a family buff name to its family key; _legendary_set
-- marks names that came from the legendary catalogue rather than a
-- family. The draft filter and the legendary leak both key on these.
local _family_of = nil
-- A boon can belong to more than one useful draft theme. Fatshark's own
-- catalogue repeats several templates across Fire, Electric and Elementalist,
-- but the older single `_family_of` value discarded that information. These
-- tags are the gameplay-facing compatibility layer used by Archetypes.
local _draft_tags_of = nil
local _legendary_set = nil
-- v0.26.5: Legendary is now a role, not merely "anything Fatshark put
-- under legendary_buffs". The loadout accepts only buffs tied to one
-- combat ability, blitz, or talent. Strong generic buffs remain rare
-- in-mission drops, while explicitly reclassified ordinary buffs join
-- a family draft pool.
local _loadout_legendary_set = nil
local _rare_legendary_set = nil
local _reclassified_family_of = nil
local _loadout_legendary_archetype = nil
-- Pilgrimage-side family/legendary entries carry their own presentation
-- metadata; Fatshark's HordesBuffsData only knows about shipped buffs.
local _pilgrim_family_by_template = {}
local _pilgrim_legendary_by_template = {}
-- v0.24.0: forward declaration; filled next to M.ARCHETYPES below.
-- M.draft runs before that section in file order, so without this the
-- reference inside draft would silently resolve to a global nil.
local _archetype_by_id = {}
local _parser = nil

-- Explicit design demotions from Fatshark's root Generic Legendary
-- list. These effects are useful but belong to an Archetype's ordinary
-- majoris/minoris progression, not to a build-defining pre-run slot.
-- Unknown future Generic entries default to rare-draft, which is the
-- conservative choice until their strength and theme are reviewed.
local GENERIC_FAMILY_OVERRIDES = {
	hordes_buff_uninterruptible_more_damage_taken = "unstoppable",
	hordes_buff_combat_ability_cooldown_on_kills = "unstoppable",
	hordes_buff_auto_clip_fill_while_melee = "cowboy",
	hordes_buff_weakspot_ranged_hit_always_stagger = "critical",
	hordes_buff_explode_enemies_on_ranged_kill = "cowboy",
	hordes_buff_aoe_shock_closest_enemy_on_interval = "electric",
	hordes_buff_staggering_pulse = "unstoppable",
	hordes_buff_random_damage_immunity = "unkillable",
	hordes_buff_bleeding_and_burning_on_melee_hit = "elementalist",
	hordes_buff_explosion_on_toughness_broken = "unkillable",
	hordes_buff_reflect_melee_damage = "unkillable",
}

-- Extra theme memberships which cannot be inferred from Fatshark's broad
-- family tables alone. `debuff` means the boon creates, rewards or develops an
-- enemy debuff. Fire/Electric additions mark mixed boons which remain useful
-- when only that one element is available. A boon which requires two elements
-- at once deliberately receives neither single-element compatibility tag.
local EXTRA_DRAFT_TAGS = {
	-- Executioner can use these Critical and Unstoppable cards entirely with
	-- its melee weapon. Pure ranged cards and cross-slot setup/payoff cards are
	-- deliberately absent because the Archetype locks slot_secondary.
	hordes_buff_explode_enemies_on_critical_kill = { "executioner" },
	hordes_buff_weakspot_damage_increase = { "executioner" },
	hordes_buff_melee_damage_on_melee_critical_hit = { "executioner" },
	hordes_buff_critical_chance_on_dodge = { "executioner" },
	hordes_buff_critical_melee_hit_infinite_cleave = { "executioner" },
	hordes_buff_increase_super_armor_impact_on_crit = { "executioner" },
	hordes_buff_stacking_crit_damage_on_critical_hit = { "executioner" },
	hordes_buff_melee_critical_damage_increase = { "executioner" },
	hordes_buff_damage_reduction_on_critical_hit = { "executioner" },
	hordes_buff_critical_damage_from_consecutive_critical_hits = { "executioner" },
	hordes_buff_crit_chance_per_missing_stamina_bar = { "executioner" },
	hordes_buff_sprinting_staggers = { "executioner" },
	hordes_buff_dodge_staggers = { "executioner" },
	hordes_buff_replenish_stamina_from_ranged_or_melee_hit = { "executioner" },
	hordes_buff_movement_bonuses_on_toughness_broken = { "executioner" },
	hordes_buff_suppression_immunity = { "executioner" },
	hordes_buff_toughness_on_melee_kills = { "executioner" },
	hordes_buff_windup_is_uninterruptible = { "executioner" },
	hordes_buff_no_movement_speed_reduction_on_aim_and_windup = { "executioner" },
	hordes_buff_increase_impact_on_push_attacks = { "executioner" },
	hordes_buff_dodge_incapacitating_attacks = { "executioner" },
	hordes_buff_damage_per_full_stamina_bar = { "executioner" },
	hordes_buff_uninterruptible_more_damage_taken = { "executioner" },
	hordes_buff_combat_ability_cooldown_on_kills = { "executioner" },
	hordes_buff_staggering_pulse = { "executioner" },

	-- Fire and soulfire development.
	hordes_buff_burning_on_melee_hit = { "debuff" },
	hordes_buff_burning_on_ranged_hit = { "debuff" },
	hordes_buff_burning_on_melee_hit_taken = { "debuff" },
	hordes_buff_damage_vs_burning = { "debuff" },
	hordes_buff_fire_pulse = { "debuff" },
	hordes_buff_toughness_on_fire_damage_dealt = { "debuff" },
	hordes_buff_burning_damage_per_burning_enemy = { "debuff" },
	hordes_buff_coherency_damage_vs_burning = { "debuff" },
	hordes_buff_coherency_burning_duration = { "debuff" },

	-- Shock development. Improved Dodge is intentionally absent: being stored
	-- in Electric/Elementalist does not make a generic movement boon a debuff.
	hordes_buff_shock_on_ranged_hit = { "debuff" },
	hordes_buff_shock_on_melee_hit = { "debuff" },
	hordes_buff_damage_vs_electrocuted = { "debuff" },
	hordes_buff_shock_pulse_on_toughness_broken = { "debuff" },
	hordes_buff_instakill_melee_hit_on_electrocuted_enemy = { "debuff" },
	hordes_buff_shock_on_hit_after_dodge = { "debuff" },
	hordes_buff_shock_closest_enemy_on_interval = { "debuff" },
	hordes_buff_damage_taken_close_to_electrocuted_enemy = { "debuff" },
	hordes_buff_coherency_damage_taken_close_to_electrocuted_enemy = { "debuff" },
	hordes_buff_aoe_shock_closest_enemy_on_interval = { "debuff" },

	-- Genuine mixed cards. The first works from either element independently;
	-- the second creates fire and bleed itself, so Pyromancer can use it without
	-- first finding a separate bleed source.
	hordes_buff_extra_toughness_near_burning_shocked_enemies = {
		"fire", "electric", "debuff",
	},
	hordes_buff_bleeding_and_burning_on_melee_hit = { "fire", "debuff" },
	hordes_buff_shock_on_blocking_melee_attack = { "electric", "debuff" },
}

-- Declared HERE, above every function that touches it, and not next to the applying code
-- where it is mostly used. Lua resolves a local by its lexical position, so a local
-- declared below build_pool is a nil GLOBAL as far as build_pool is concerned, and
-- `_stats.pool_from = x` would throw. This mod has already been bitten by exactly that
-- once, in event_log.lua.
local _stats = {
	applied = 0,
	failed = 0,
	spawns = 0,
	pool_from = "not built",
	last_error = nil,
}

local function _allowed_buffs()
	if _allowed then return _allowed end
	local ok, value = pcall(require, ALLOWED_BUFFS_PATH)
	if ok and type(value) == "table" then _allowed = value end
	return _allowed
end

-- The PRESENTATION table: title, description, icon, gradient, buff_stats. Not the
-- BuffTemplate; the BuffTemplate's own `icon` is a useless default that
-- buff_templates.lua:120 assigns to everything.
--
-- I ASSUMED THIS WAS A GLOBAL AND IT IS NOT. hordes_buffs_data.lua ends with
-- `return settings("HordesBuffsData", hordes_buffs_data)`, and settings() simply returns
-- its argument (scripts/foundation/utilities/settings.lua:7). Nothing publishes a global.
-- So rawget(_G, "HordesBuffsData") was nil, info() fell through to its "just show the raw
-- name" fallback, and every card showed hordes_buff_something with no description.
--
-- Requiring it is also what makes it EXIST: nothing in a normal mission pulls this file
-- in, since its only consumers are the Hordes UI elements.
local _data = nil

local function _buffs_data()
	if _data ~= nil then return _data or nil end

	local ok, value = pcall(require, BUFFS_DATA_PATH)
	if ok and type(value) == "table" then
		_data = value
	else
		_data = rawget(_G, "HordesBuffsData") or false
	end

	return _data or nil
end

local function _mission_buffs_parser()
	if _parser ~= nil then return _parser end
	local ok, value = pcall(require, PARSER_PATH)
	_parser = (ok and value) or false
	return _parser
end

M.allowed_buffs = _allowed_buffs
M.buffs_data = _buffs_data

-- ---------------------------------------------------------------------------
-- Building the pool
--
-- The catalogue is not a list. mission_buffs_allowed_buffs.lua is three nested trees:
--
--   legendary_buffs.generic              flat array, 14 names, everyone gets these
--   legendary_buffs.<archetype>          a map keyed by LOADOUT SLOT, not a list:
--                                          .generic
--                                          .grenade_ability.<grenade_name> = { names }
--                                          .combat_ability.<ability_name>  = { names }
--                                          .talent_specific.<talent>       (cryptic only)
--   buff_families.<family>.buffs         and .priority_buffs, flat arrays
--
-- and there are SEVEN archetypes, not four: veteran, zealot, psyker, ogryn, adamant,
-- broker, cryptic. Any per-class logic has to be driven off this table rather than a
-- hardcoded assumption, which is why the walk below is generic and recursive rather than
-- a list of known keys.
--
-- For a first pass we take everything. Filtering to the player's own archetype and
-- equipped abilities is a refinement, and doing it wrong would silently shrink the pool,
-- so it is better added once there is something to compare against.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- WHO IS ALLOWED WHAT
--
-- The first version took the entire catalogue, on the reasoning that filtering it wrongly
-- would silently shrink the pool. That was the wrong trade: it offered Kaizen a cryptic
-- buff for an ability his character does not have, which is worse than a smaller pool
-- because it is a boon that would do nothing if taken.
--
-- This now mirrors mission_buffs_selector.lua:145-195 exactly, because the game has
-- already answered the question and any answer of mine would be a guess at its intent:
--
--     legendary_buffs.generic                                everyone
--     legendary_buffs[archetype].generic                     your class
--     legendary_buffs[archetype].grenade_ability[<name>]     your equipped grenade
--     legendary_buffs[archetype].combat_ability[<group>]     your equipped combat ability
--     legendary_buffs[archetype].talent_specific[<talent>]   only if you have that talent
--     buff_families[*].buffs and .priority_buffs             everyone, these are generic
--
-- Note the asymmetry the game itself has and which is easy to get wrong: the grenade is
-- keyed by `equipped_abilities.grenade_ability.NAME` while the combat ability is keyed by
-- `equipped_abilities.combat_ability.ABILITY_GROUP`. Not the same field.
--
-- WITHOUT A PLAYER UNIT we fall back to generic plus families only. That is the honest
-- answer: it is better to offer a smaller correct pool than to offer buffs for a class
-- that is not yours. /pil_boons reports which of the two happened.
-- ---------------------------------------------------------------------------

local function _append(out, seen, list)
	if type(list) ~= "table" then return end
	for i = 1, #list do
		local name = list[i]
		if type(name) == "string" and name:sub(1, 12) == "hordes_buff_" and not seen[name] then
			seen[name] = true
			out[#out + 1] = name
		end
	end
end

local function _add_draft_tag(buff_name, tag)
	if type(buff_name) ~= "string" or type(tag) ~= "string" or tag == "" then return end
	_draft_tags_of[buff_name] = _draft_tags_of[buff_name] or {}
	_draft_tags_of[buff_name][tag] = true
end

local function _add_extra_draft_tags(buff_name, tags)
	if type(tags) ~= "table" then return end
	for i = 1, #tags do _add_draft_tag(buff_name, tags[i]) end
end

local function _has_wanted_draft_tag(buff_name, wanted)
	local tags = _draft_tags_of and _draft_tags_of[buff_name]
	if type(tags) ~= "table" then return false end
	for tag in pairs(tags) do
		if wanted[tag] then return true end
	end
	return false
end

-- `pairs()` order is intentionally undefined. Use Fatshark's published family
-- order first, then append any future families alphabetically. This makes the
-- single presentation family stable while `_draft_tags_of` retains every
-- membership for gameplay filtering.
local function _ordered_family_keys(allowed, families)
	local out, seen = {}, {}
	for i = 1, #(allowed.available_family_builds or {}) do
		local key = allowed.available_family_builds[i]
		if families[key] and not seen[key] then
			seen[key] = true
			out[#out + 1] = key
		end
	end
	local extras = {}
	for key in pairs(families) do
		if not seen[key] then extras[#extras + 1] = key end
	end
	table.sort(extras)
	for i = 1, #extras do out[#out + 1] = extras[i] end
	return out
end

local function _walk_buff_names(value, fn)
	if type(value) == "string" then
		if value:sub(1, 12) == "hordes_buff_" then fn(value) end
	elseif type(value) == "table" then
		for _, child in pairs(value) do _walk_buff_names(child, fn) end
	end
end

-- This shipped boon is an ordinary Cowboy effect, despite living in
-- Fatshark's Legendary catalogue. Its internal id and localization key
-- can change between game builds, so the check uses both raw metadata
-- and the localized English presentation available on the current
-- install. The raw-key checks keep it working for non-English clients
-- when Fatshark's semantic key names are present.
local function _family_override(name)
	local explicit = GENERIC_FAMILY_OVERRIDES[name]
	if explicit then return explicit end
	local data = _buffs_data()
	local entry = data and data[name]
	local raw = string.lower(table.concat({
		tostring(name or ""),
		tostring(entry and entry.title or ""),
		tostring(entry and entry.description or ""),
	}, " "))
	if string.find(raw, "coulda", 1, true) and string.find(raw, "empty", 1, true) then
		return "cowboy"
	end
	if string.find(raw, "auto_reload", 1, true)
		and (string.find(raw, "melee", 1, true) or string.find(raw, "holster", 1, true)) then
		return "cowboy"
	end
	local ok, info = pcall(M.info, name)
	if ok and info then
		local title = string.lower(tostring(info.title or ""))
		local desc = string.lower(tostring(info.description or ""))
		local matched = string.find(title, "coulda swore", 1, true) ~= nil
			or (string.find(desc, "ranged weapon", 1, true) ~= nil
				and string.find(desc, "magazine", 1, true) ~= nil
				and string.find(desc, "7%", 1, true) ~= nil)
		return matched and "cowboy" or nil
	end
	return nil
end

-- Rebuilds a patch-resilient catalogue from Fatshark's nested data:
--
-- * root/class generic entries are rare mission Legendaries;
-- * combat-ability and talent-specific entries are loadout Legendaries;
-- * blitz entries are loadout Legendaries unless the same buff is
--   reused across several classes, which makes it a generic grenade
--   modifier and therefore a rare mission Legendary;
-- * named low-impact exceptions can become normal family boons.
--
-- Counting reuse is more durable than hardcoding DLC-era buff ids. It
-- automatically catches effects such as duplicate grenade chance,
-- blanket brittleness, and grenade regeneration across new classes.
local function _rebuild_legendary_roles(legendary)
	_loadout_legendary_set = {}
	_rare_legendary_set = {}
	_reclassified_family_of = {}
	_loadout_legendary_archetype = {}
	if type(legendary) ~= "table" then return end

	local grenade_uses = {}
	for class_key, class_buffs in pairs(legendary) do
		if class_key ~= "generic" and type(class_buffs) == "table"
			and type(class_buffs.grenade_ability) == "table" then
			local in_this_class = {}
			for _, buffs in pairs(class_buffs.grenade_ability) do
				_walk_buff_names(buffs, function(name) in_this_class[name] = true end)
			end
			for name in pairs(in_this_class) do
				grenade_uses[name] = (grenade_uses[name] or 0) + 1
			end
		end
	end

	local function mark_rare(name)
		local family = _family_override(name)
		if family then
			_reclassified_family_of[name] = family
			_rare_legendary_set[name] = nil
			_loadout_legendary_set[name] = nil
		else
			_rare_legendary_set[name] = true
		end
	end

	_walk_buff_names(legendary.generic, mark_rare)
	for class_key, class_buffs in pairs(legendary) do
		if class_key ~= "generic" and type(class_buffs) == "table" then
			_walk_buff_names(class_buffs.generic, mark_rare)
			_walk_buff_names(class_buffs.combat_ability, function(name)
				if not _reclassified_family_of[name] and not _rare_legendary_set[name] then
					_loadout_legendary_set[name] = true
					_loadout_legendary_archetype[name] = class_key
				end
			end)
			_walk_buff_names(class_buffs.talent_specific, function(name)
				if not _reclassified_family_of[name] and not _rare_legendary_set[name] then
					_loadout_legendary_set[name] = true
					_loadout_legendary_archetype[name] = class_key
				end
			end)
			_walk_buff_names(class_buffs.grenade_ability, function(name)
				if _reclassified_family_of[name] then return end
				-- Reuse across several classes means the effect is a generic
				-- grenade jackpot. Reuse by variants inside one class still
				-- targets that class's named blitz and remains loadout-worthy.
				if (grenade_uses[name] or 0) > 1 then
					_rare_legendary_set[name] = true
					_loadout_legendary_set[name] = nil
					_loadout_legendary_archetype[name] = nil
				elseif not _rare_legendary_set[name] then
					_loadout_legendary_set[name] = true
					_loadout_legendary_archetype[name] = class_key
				end
			end)
		end
	end

	for i = 1, #(M.LEGENDARIES or {}) do
		local boon = M.LEGENDARIES[i]
		local name = boon and boon.buff_template
		if name then
			_loadout_legendary_set[name] = true
			_loadout_legendary_archetype[name] = boon.archetype
		end
	end
end

local function _ensure_legendary_roles()
	if _loadout_legendary_set then return end
	local allowed = _allowed_buffs()
	_rebuild_legendary_roles(allowed and allowed.legendary_buffs)
end

local function _requirement_matches(actual, wanted)
	if wanted == nil then return true end
	if type(wanted) == "string" then return actual == wanted end
	if type(wanted) == "table" then
		for i = 1, #wanted do
			if actual == wanted[i] then return true end
		end
	end
	return false
end

-- Returns archetype_name, grenade_name, combat_ability_group, talents, or nils.
local function _player_loadout()
	local player = _shared.local_player()
	local player_unit = _shared.local_player_unit()
	if not player or not player_unit then return nil end

	local archetype
	if type(player.archetype_name) == "function" then
		local ok, name = pcall(player.archetype_name, player)
		if ok then archetype = name end
	end
	if not archetype then return nil end

	local ability_extension = _shared.extension(player_unit, "ability_system")
	if not ability_extension then return archetype end

	local ok_abilities, equipped = pcall(ability_extension.equipped_abilities, ability_extension)
	if not ok_abilities or type(equipped) ~= "table" then return archetype end

	local grenade, combat

	local ok_has, has_grenade = pcall(ability_extension.has_ability_type, ability_extension, "grenade_ability")
	if ok_has and has_grenade and equipped.grenade_ability then
		grenade = equipped.grenade_ability.name
	end

	local ok_has_combat, has_combat = pcall(ability_extension.has_ability_type, ability_extension, "combat_ability")
	if ok_has_combat and has_combat and equipped.combat_ability then
		-- ability_group, NOT name. The catalogue keys combat abilities differently to
		-- grenades and mixing them up yields an empty table lookup and a silently
		-- smaller pool.
		combat = equipped.combat_ability.ability_group
	end

	local talents
	if type(player.profile) == "function" then
		local ok_profile, profile = pcall(player.profile, player)
		if ok_profile and type(profile) == "table" then talents = profile.talents end
	end

	return archetype, grenade, combat, talents
end

function M.build_pool()
	local allowed = _allowed_buffs()
	if not allowed then
		_stats.pool_from = "no catalogue"
		_family_of, _draft_tags_of, _legendary_set = {}, {}, {}
		return {}
	end

	local out, seen = {}, {}
	-- v0.24.0: partitions rebuilt with the pool. Everything appended
	-- BEFORE the legendary section belongs to a family; everything
	-- after is a legendary.
	_family_of, _draft_tags_of, _legendary_set = {}, {}, {}
	_rebuild_legendary_roles(allowed.legendary_buffs)

	-- Families are build archetypes of their own (fire, unkillable and so on) and are not
	-- class restricted, so everyone can be offered all of them.
	local families = allowed.buff_families
	if type(families) == "table" then
		local family_keys = _ordered_family_keys(allowed, families)
		for fi = 1, #family_keys do
			local family_key = family_keys[fi]
			local family = families[family_key]
			if type(family) == "table" then
				local function add_family_list(list)
					for i = 1, #(list or {}) do
						local name = list[i]
						if type(name) == "string" and name:sub(1, 12) == "hordes_buff_" then
							_add_draft_tag(name, family_key)
							_add_extra_draft_tags(name, EXTRA_DRAFT_TAGS[name])
							if not seen[name] then
								seen[name] = true
								out[#out + 1] = name
								_family_of[name] = family_key
							end
						end
					end
				end
				add_family_list(family.priority_buffs)
				add_family_list(family.buffs)
			end
		end
	end

	-- v0.26.0: our family expansions are real drafted boons, not
	-- permanent Doctrines. They use Pilgrimage templates but join the
	-- same family partition and archetype filter as Fatshark's entries.
	for i = 1, #(M.FAMILY_BOONS or {}) do
		local boon = M.FAMILY_BOONS[i]
		local name = boon and boon.buff_template
		if type(name) == "string" and name ~= "" and not seen[name] then
			seen[name] = true
			out[#out + 1] = name
			_family_of[name] = boon.family
		end
		if type(name) == "string" and name ~= "" then
			_add_draft_tag(name, boon.family)
			_add_extra_draft_tags(name, boon.draft_tags)
			_add_extra_draft_tags(name, EXTRA_DRAFT_TAGS[name])
		end
	end

	-- v0.26.5: shipped entries explicitly demoted from Legendary status
	-- become genuine family boons before the Legendary boundary is set.
	-- This means Archetype filtering and family icon styling treat them
	-- exactly like the rest of that family.
	for name, family in pairs(_reclassified_family_of or {}) do
		if not seen[name] then
			seen[name] = true
			out[#out + 1] = name
			_family_of[name] = family
		end
		_add_draft_tag(name, family)
		_add_extra_draft_tags(name, EXTRA_DRAFT_TAGS[name])
	end

	local legendary = allowed.legendary_buffs
	if type(legendary) == "table" then
		-- v0.24.0: everything from here down is a legendary; record the
		-- boundary so the loop after this block can mark them.
		local legendary_start = #out + 1
		_append(out, seen, legendary.generic)

		local archetype, grenade, combat, talents = _player_loadout()

		if archetype and legendary[archetype] then
			local class_buffs = legendary[archetype]
			_stats.pool_from = "archetype " .. tostring(archetype)

			_append(out, seen, class_buffs.generic)

			if grenade and type(class_buffs.grenade_ability) == "table" then
				_append(out, seen, class_buffs.grenade_ability[grenade])
			end

			if combat and type(class_buffs.combat_ability) == "table" then
				_append(out, seen, class_buffs.combat_ability[combat])
			end

			if type(class_buffs.talent_specific) == "table" and type(talents) == "table" then
				for talent_name, talent_buffs in pairs(class_buffs.talent_specific) do
					if talents[talent_name] then _append(out, seen, talent_buffs) end
				end
			end
		else
			-- No player yet, or an archetype the catalogue does not list. Generic and
			-- families only, which is correct but smaller.
			_stats.pool_from = archetype and ("unknown archetype " .. tostring(archetype))
				or "generic only, no player"
		end

		for i = legendary_start, #out do
			_legendary_set[out[i]] = true
		end
	end

	-- Pilgrimage legendaries are filtered with the same relevance rule:
	-- class first, then the equipped blitz when the entry claims one.
	-- No player/loadout means no class-specific custom legendary.
	local player_archetype, player_grenade, player_combat = _player_loadout()
	for i = 1, #(M.LEGENDARIES or {}) do
		local boon = M.LEGENDARIES[i]
		local relevant = player_archetype ~= nil
			and (not boon.archetype or boon.archetype == player_archetype)
		if relevant and boon.requires_blitz then
			relevant = _requirement_matches(player_grenade, boon.requires_blitz)
			if not relevant and type(boon.requires_blitz) == "string"
				and M.blitz_template_name and _shared then
				local unit = _shared.local_player_unit and _shared.local_player_unit()
				relevant = M.blitz_template_name(unit) == boon.requires_blitz
			end
		end
		if relevant and boon.requires_combat_ability then
			relevant = _requirement_matches(player_combat, boon.requires_combat_ability)
		end
		local name = boon and boon.buff_template
		if relevant and type(name) == "string" and name ~= "" and not seen[name] then
			seen[name] = true
			out[#out + 1] = name
			_legendary_set[name] = true
		end
	end

	-- Sorted so the pool order is identical on every machine and every launch. A seeded
	-- draft is only reproducible if the thing it indexes into is stable, and pairs()
	-- iteration order in Lua is not.
	table.sort(out)
	return out
end

-- v0.24.0: partition accessors. Both are only meaningful after pool()
-- has been called for the current leg; pool() rebuilds them.
function M.family_of(buff_name)
	return _family_of and _family_of[buff_name] or nil
end

-- Public debug/audit accessor. The returned list is sorted so console probes
-- and test snapshots remain stable across machines.
function M.draft_tags_of(buff_name)
	local out = {}
	for tag in pairs((_draft_tags_of and _draft_tags_of[buff_name]) or {}) do
		out[#out + 1] = tag
	end
	table.sort(out)
	return out
end

function M.is_draft_compatible(buff_name, archetype_id)
	-- Ensure the native and Pilgrimage tag indices exist before answering a UI,
	-- console or test query made outside the normal draft path.
	M.pool()
	local archetype = _archetype_by_id[archetype_id]
	if not archetype then return false end
	local wanted = {}
	local draft_tags = archetype.draft_tags or archetype.families or {}
	for i = 1, #draft_tags do wanted[draft_tags[i]] = true end
	return _has_wanted_draft_tag(buff_name, wanted)
end

function M.is_legendary(buff_name)
	return _legendary_set ~= nil and _legendary_set[buff_name] == true
end

function M.is_loadout_legendary(buff_name)
	_ensure_legendary_roles()
	return _loadout_legendary_set[buff_name] == true
end

function M.is_rare_legendary(buff_name)
	_ensure_legendary_roles()
	return _rare_legendary_set[buff_name] == true
end

-- The operative class whose combat ability or blitz owns this
-- loadout Legendary. The UI uses this as presentation metadata only;
-- applicability is still enforced independently by the live pool.
function M.legendary_archetype(buff_name)
	_ensure_legendary_roles()
	return _loadout_legendary_archetype[buff_name]
end

-- Cached per leg, not forever. The pool depends on the player's equipped abilities, and
-- those are not known until the player unit exists, so a pool built during the loading
-- screen would be the generic-only fallback and would then be wrong for the rest of the
-- run. reset_leg drops it.
function M.pool()
	if _pool then return _pool end
	_pool = M.build_pool()
	return _pool
end

function M.pool_size()
	return #M.pool()
end

-- Drops the cache so a /reload picks up any change. Also used by tests.
function M.reset_pool()
	_pool = nil
	_allowed = nil
end

-- ---------------------------------------------------------------------------
-- Presentation
-- ---------------------------------------------------------------------------

-- Fatshark's Hordes data still exposes several development names. Keep the
-- correction at Pilgrimage's presentation boundary so the underlying template
-- ids remain untouched and save/network compatibility is not disturbed.
local function _player_facing_ability_names(text)
	if type(text) ~= "string" then return text end
	return text
		:gsub("Focus Stance", "Desperado")
		:gsub("Punk Rage", "Rampage")
		:gsub("Volley Fire", "Executioner's Stance")
		:gsub("Precision Stance", "Advanced Combat Doctrines")
end

-- Returns a table the view can render: name, title, description, icon.
-- Never returns nil and never returns an empty title, because a boon you cannot read is
-- worse than one you cannot have.
function M.info(buff_name)
	local info = {
		name = buff_name,
		title = tostring(buff_name),
		description = "",
		icon = nil,
		custom_icon = nil,
		-- The colour ramp the icon is tinted through. The game supplies one per buff and
		-- falls back to the talent ability ramp when it is missing
		-- (hud_element_tactical_overlay.lua:28, 380). Without it the icon draws flat
		-- grey, so it is worth carrying even though it is only cosmetic.
		gradient = nil,
		is_family = false,
	}

	local pilgrim = _pilgrim_family_by_template[buff_name]
		or _pilgrim_legendary_by_template[buff_name]
	if pilgrim then
		info.title = pilgrim.name or info.title
		info.description = _player_facing_ability_names(pilgrim.description or "")
		info.icon = pilgrim.icon or (pilgrim.custom and pilgrim.custom.hud_icon) or nil
		info.gradient = pilgrim.gradient
		local family_boon = _pilgrim_family_by_template[buff_name]
		info.is_family = family_boon ~= nil
		-- v0.28.5: custom family boons use the small set of Hordes-card
		-- textures already proven to render in ordinary missions. Wave B
		-- originally named several plausible Mortis assets directly; the
		-- engine accepted the strings but drew its question-mark placeholder
		-- because those resources were not resident. Long Burn's family art
		-- is the known-good style and now wins for every family entry.
		if family_boon and _icons and _icons.family_styled_icon then
			info.icon = _icons.family_styled_icon(family_boon.family) or info.icon
			if _icons.custom_icon_for then
				info.custom_icon = _icons.custom_icon_for(buff_name,
					family_boon.family)
			end
		elseif _icons and info.icon then
			local resident = _icons.texture_resident and _icons.texture_resident(info.icon)
			if resident == false and _icons.icon_override then
				info.icon = _icons.icon_override(buff_name) or info.icon
			end
		end
		return info
	end

	local data = _buffs_data()
	local entry = data and data[buff_name]
	if not entry then return info end

	-- Both are stored as "" rather than nil for a couple of shipped entries, and an
	-- empty string binds as "clear the texture" rather than "use the default", so it has
	-- to become nil here.
	if entry.icon and entry.icon ~= "" then info.icon = entry.icon end
	if entry.gradient and entry.gradient ~= "" then info.gradient = entry.gradient end

	-- The shipped art is unreachable on this install (it lives in the Mortis Trials
	-- level bundle, which no package name reaches), so when the engine cannot resolve
	-- the real texture, swap in a category stand-in. icon_override prefers a RESIDENT
	-- GAME TEXTURE PATH (status and stimm icons from the base HUD, probe-verified,
	-- these provably draw) and only falls back to the SimpleAssets texture object,
	-- which in practice the buff materials refused to render. Strictly a fallback
	-- either way: if a future patch makes the real art resident, it wins.
	if _icons then
		local family = _family_of and _family_of[buff_name]
		if family and _icons.family_styled_icon then
			-- Shipped family icons are tied to the Mortis bundle and often draw
			-- as an empty white hex here. Replace them with the proven Wave A
			-- Hordes artwork for that family, not with an old generic HUD icon.
			info.icon = _icons.family_styled_icon(family) or info.icon
			if _icons.custom_icon_for then
				info.custom_icon = _icons.custom_icon_for(buff_name, family)
			end
		else
			local resident = _icons.texture_resident and _icons.texture_resident(info.icon)
			if resident == false and _icons.icon_override then
				local override = _icons.icon_override(buff_name)
				if override then info.icon = override end
			end
		end
	end

	info.is_family = (_family_of and _family_of[buff_name] ~= nil)
		or entry.is_family_buff == true

	-- Two shipped entries carry title = "" deliberately and are meant to fall back to the
	-- raw name. The game's own UI does the same check
	-- (constant_element_mission_buffs.lua:144).
	local Localize = rawget(_G, "Localize")
	if entry.title and entry.title ~= "" and type(Localize) == "function" then
		local ok, text = pcall(Localize, entry.title)
		if ok and type(text) == "string" and text ~= "" and text:sub(1, 1) ~= "<" then
			info.title = text
		end
	end

	-- The description carries format parameters that live in entry.buff_stats. Localizing
	-- it directly leaves "{time}" and friends in the text, so it goes through the game's
	-- own parser.
	local parser = _mission_buffs_parser()
	if parser and parser.get_formated_buff_description then
		local Color = rawget(_G, "Color")
		local colour = Color and Color.ui_terminal and Color.ui_terminal(255, true) or nil
		local ok, text = pcall(parser.get_formated_buff_description, entry, colour)
			if ok and type(text) == "string" then
				info.description = _player_facing_ability_names(text)
			end
	end

	return info
end

-- ---------------------------------------------------------------------------
-- Drafting
--
-- Seeded off the run seed and the leg number, so the same run always offers the same
-- choices. That keeps a shared seed genuinely reproducible, which is the whole point of
-- showing the seed on screen, and it means a crash mid-draft cannot be used to reroll
-- into a better offer.
-- ---------------------------------------------------------------------------

-- Returns a list of `count` distinct boon names the player does not already own.
-- v0.24.0: chance (in percent) that a draft smuggles one legendary in.
-- v0.28.7 makes the value run-scoped: 15% initially, then +15 percentage
-- points for each mission draft that did not contain a Legendary. The
-- run-state module persists and caps the pity curve; this local value remains
-- the compatibility default for tests and external callers using three args.
local LEGENDARY_LEAK_PCT = 15

function M.draft(count, seed, owned, legendary_leak_pct)
	count = math.max(1, math.min(count or 3, 6))
	owned = owned or {}
	legendary_leak_pct = math.max(0, math.min(100,
		math.floor(legendary_leak_pct or LEGENDARY_LEAK_PCT)))

	local pool = M.pool()
	if #pool == 0 then return {} end

	-- v0.24.0 (Boons v2): the draft is family-first. Legendaries are
	-- pulled OUT of the base candidates and only re-enter through the
	-- seeded leak below, so the Archetype hard filter has a clean
	-- family list to work on and legendaries keep their own moment.
	local family_candidates = {}
	local legendary_candidates = {}
	local active_legendary = M.active_legendary()
	for i = 1, #pool do
		local name = pool[i]
		if not owned[name] then
			if M.is_legendary(name) then
				-- The run stamp is not part of `owned`, so explicitly remove
				-- the preselected Legendary from the rare offer pool.
				if name ~= active_legendary then
					legendary_candidates[#legendary_candidates + 1] = name
				end
			else
				family_candidates[#family_candidates + 1] = name
			end
		end
	end

	-- ARCHETYPE HARD FILTER. v0.28.12 filters by explicit compatibility
	-- tags rather than one broad family label. This permits mixed cards that
	-- function from the Archetype's own element, while rejecting a pure shock
	-- card for Pyromancer and a two-element requirement such as Thermal Shock.
	-- The old off-theme backfill is intentionally gone: a shorter late-run draft
	-- is preferable to presenting a boon the selected Archetype cannot support.
	local archetype_id = M.active_archetype_id()
	local archetype = archetype_id and _archetype_by_id[archetype_id] or nil
	local candidates = family_candidates
	if archetype then
		local wanted = {}
		local draft_tags = archetype.draft_tags or archetype.families or {}
		for i = 1, #draft_tags do wanted[draft_tags[i]] = true end
		local on_theme = {}
		for i = 1, #family_candidates do
			local name = family_candidates[i]
			if _has_wanted_draft_tag(name, wanted) then
				on_theme[#on_theme + 1] = name
			end
		end
		candidates = on_theme
		if #on_theme < count then
			_debug_log("boons", 0, "archetype draft near exhaustion: "
				.. tostring(#on_theme) .. " compatible candidates left for "
				.. tostring(archetype_id), 0, "info")
		end
	end

	if #candidates == 0 and #legendary_candidates == 0 then return {} end

	local state = _missions.mix_seed(seed or 0)
	local out = {}

	for _ = 1, math.min(count, #candidates) do
		local value
		state, value = _missions.next_random(state, 1, #candidates)
		out[#out + 1] = candidates[value]
		table.remove(candidates, value)
	end

	-- LEGENDARY LEAK: one seeded roll per draft; on a hit the LAST
	-- option is replaced with a seeded-random legendary. Replacing
	-- rather than appending keeps the draft size the player paid for
	-- (Zero Waste and the count cap stay honest).
	-- v0.28.2: a run may gain additional distinct Legendaries. Pool
	-- construction already restricts these to the current class,
	-- equipped combat ability, equipped blitz and relevant talents;
	-- the split above removes the active pick and `owned` removes every
	-- Legendary previously drafted.
	if #legendary_candidates > 0 and #out > 0 then
		local roll
		state, roll = _missions.next_random(state, 1, 100)
		if roll <= legendary_leak_pct then
			local pick
			state, pick = _missions.next_random(state, 1, #legendary_candidates)
			out[#out] = legendary_candidates[pick]
		end
	end

	-- Degenerate escape hatch: nothing but legendaries left (deep run,
	-- tiny families). Offer legendaries straight rather than an empty
	-- draft.
	if #out == 0 and #legendary_candidates > 0 then
		for _ = 1, math.min(count, #legendary_candidates) do
			local value
			state, value = _missions.next_random(state, 1, #legendary_candidates)
			out[#out + 1] = legendary_candidates[value]
			table.remove(legendary_candidates, value)
		end
	end

	return out
end

-- The seed for the draft offered at the start of a given leg. Derived rather than stored,
-- so it survives a level change without needing a settings key of its own.
function M.draft_seed(run_seed, leg)
	return _missions.mix_seed((run_seed or 0) + (leg or 0) * 7919)
end

-- ---------------------------------------------------------------------------
-- Applying
-- ---------------------------------------------------------------------------

-- name -> index returned by the buff extension. Per player unit, and therefore cleared on
-- every spawn: the indexes belong to the body that has just been destroyed.
local _applied = {}

local function _fixed_time()
	local FixedFrame = rawget(_G, "FixedFrame")
	if FixedFrame and FixedFrame.get_latest_fixed_time then
		local ok, t = pcall(FixedFrame.get_latest_fixed_time)
		if ok and t then return t end
	end
	return _shared.fixed_time()
end

-- Grants one boon to a unit. Returns true when the buff actually landed.
function M.grant(player_unit, buff_name)
	if not player_unit or not buff_name then return false, "no unit" end

	-- The dedupe that stops the double-stack described at the top of this file.
	if _applied[buff_name] then return false, "already applied" end

	local buff_extension = _shared.extension(player_unit, "buff_system")
	if not buff_extension then return false, "no buff extension" end
	if type(buff_extension.add_externally_controlled_buff) ~= "function" then
		return false, "extension cannot add external buffs"
	end

	local ok, _flag, index = pcall(buff_extension.add_externally_controlled_buff,
		buff_extension, buff_name, _fixed_time())

	if not ok then
		_stats.failed = _stats.failed + 1
		_stats.last_error = tostring(_flag)
		return false, tostring(_flag)
	end

	-- index, not the first value. The first value is an error flag, and a muted buff
	-- returns a real index anyway, so index is the only signal worth testing. This is the
	-- same test mission_buffs_handler.lua:121 makes.
	if index == nil then
		_stats.failed = _stats.failed + 1
		_stats.last_error = "buff refused, likely not server"
		return false, "buff refused"
	end

	_applied[buff_name] = index
	_stats.applied = _stats.applied + 1
	return true
end

-- Applies every boon the run owns. Called on player spawn, including respawns.
function M.apply_all(player_unit)
	-- Clear IN PLACE. Other code may hold a reference to this exact table, and
	-- reassigning would orphan it.
	for name in pairs(_applied) do _applied[name] = nil end

	if not player_unit then return 0 end
	if not _run_state.is_active() then return 0 end

	local state = _run_state.get()
	local granted = 0

	-- Sorted, so the order boons are applied is deterministic. It should not matter, but
	-- when two buffs interact it is much easier to debug a fixed order than a random one.
	local names = {}
	for name in pairs(state.boons) do names[#names + 1] = name end
	table.sort(names)

	for i = 1, #names do
		local ok = M.grant(player_unit, names[i])
		if ok then granted = granted + 1 end
	end

	-- v0.22.81: slotted loadout boons ride the same spawn moment,
	-- after the drafted boons. M.apply_loadout is defined further down
	-- the file; calling through M resolves it at runtime.
	if type(M.apply_loadout) == "function" then
		granted = granted + (M.apply_loadout(player_unit) or 0)
	end

	if granted > 0 then
		_event_log.emit({
			t = _shared.fixed_time(),
			event = "boons_applied",
			id = _event_log.next_id(),
			count = granted,
			of = #names,
		})
	end

	return granted
end

function M.applied()
	return _applied
end

-- ---------------------------------------------------------------------------
-- Hook
--
-- on_player_unit_spawn is the moment the game itself uses to restore mission buffs
-- (game_mode_survival.lua:879, game_mode_coop_complete_objective.lua:286). It runs after
-- extension init, so buff_system exists, and it fires on respawn as well as first spawn,
-- which is exactly what we need: the previous unit's buff indexes died with it.
--
-- hook_safe, so a fault of ours can never stop a player spawning.
-- ---------------------------------------------------------------------------

function M.install(GameModeManager)
	if not GameModeManager then return end
	if _hooks.claim(GameModeManager, SENTINEL) then return end

	_mod:hook_safe(GameModeManager, "on_player_unit_spawn",
		function(self, player, player_unit, is_respawn)
			M.on_player_unit_spawn(player, player_unit, is_respawn)
		end)
end

function M.on_player_unit_spawn(player, player_unit, is_respawn)
	_stats.spawns = _stats.spawns + 1

	if not _run_state.is_active() then return end

	-- Bots spawn through the same path. Boons are the player's, and granting them to a bot
	-- would be a silent balance change nobody asked for.
	if player and type(player.is_human_controlled) == "function" then
		local ok, human = pcall(player.is_human_controlled, player)
		if not ok or not human then return end
	end

	-- Only ours. In a solo leg there is one human, but this costs nothing and stops the
	-- hook doing anything at all in a session we do not own.
	if not _shared.is_solo_host() then return end

	local granted = M.apply_all(player_unit)

	_debug_log("boons:spawn", _shared.fixed_time(),
		"applied " .. tostring(granted) .. " boons on "
			.. (is_respawn and "respawn" or "spawn"), 0, "info")
end

-- ---------------------------------------------------------------------------
-- Offering the draft at the start of a leg
--
-- WHY HERE AND NOT AT THE TERMINAL
--
-- The terminal was the first home for this, and it works, but Kaizen's read after playing
-- it is better and it is worth writing down why. A boon chosen in the Mourningstar is a
-- menu decision made minutes before it matters, sandwiched between the route list and a
-- loading screen. A boon chosen standing in the drop zone with the mission about to start
-- is the same decision made where it applies, and it is much closer to walking up to a
-- shrine in Chaos Wastes, which is the thing we are actually trying to build.
--
-- It also means one draft per leg naturally, without the run state having to reason about
-- whether you happen to have visited the terminal.
--
-- The terminal still offers it as a fallback, for the case where a leg is somehow started
-- and finished without the offer being taken.
--
-- TIMING: a few seconds after the player unit exists, not immediately. The first moments
-- of a level are still settling, the mission intro may be playing, and a view that opens
-- during that is a view that opens behind something. The drop zone is also the safest
-- place in the level, so the seconds spent reading three cards cost nothing.
-- ---------------------------------------------------------------------------

local DRAFT_OPEN_DELAY_S = 4

local _leg_start_t = nil
local _draft_offered_this_leg = false

function M.reset_leg()
	_leg_start_t = nil
	_draft_offered_this_leg = false

	-- Drop the cached pool. It is built from the player's equipped abilities, and on the
	-- previous leg it may have been built before the player unit existed, in which case it
	-- is the generic-only fallback and wrong for everything after.
	_pool = nil
end

function M.draft_tick(t)
	-- Missions only. In the hub the terminal owns this.
	if _shared.is_in_hub() then return end
	if not _shared.game_mode_name() then return end

	-- The Psykhanium is neither. It has a player unit and it is not a hub, which is
	-- exactly the shape this gate used to test for, so walking in there with a draft
	-- owed produced the offer mid-training-dummy. The debt survives being ignored here;
	-- the terminal or the next real leg collects it.
	if _shared.is_in_psykhanium() then return end

	if _draft_offered_this_leg then return end
	if not _run_state.is_active() then return end
	if not _run_state.draft_pending() then return end

	local player_unit = _shared.local_player_unit()
	if not player_unit then
		-- Not spawned yet. Do not start the clock until there is someone to spawn it for,
		-- or the delay burns down during the loading screen and the view opens instantly.
		_leg_start_t = nil
		return
	end

	if not _leg_start_t then
		_leg_start_t = t
		return
	end

	if t - _leg_start_t < DRAFT_OPEN_DELAY_S then return end

	local ui = Managers.ui
	if not ui or not ui.open_view then return end

	-- Never stack on top of something else, including the escape menu.
	if ui.using_input then
		local ok, claimed = pcall(ui.using_input, ui, true, false, true)
		if ok and claimed then return end
	end

	-- Offered once per leg. If it is closed without a pick the draft stays owed, so the
	-- terminal will offer it back in the Mourningstar rather than nagging mid-fight.
	_draft_offered_this_leg = true

	local ok, err = pcall(ui.open_view, ui, "pilgrimage_route_view")
	if not ok then
		_stats.last_error = tostring(err)
		return
	end

	_event_log.emit({
		t = t,
		event = "boon_draft_offered",
		id = _event_log.next_id(),
		leg = _run_state.get().index,
	})
end

-- ---------------------------------------------------------------------------
-- Taking one
--
-- Grants IMMEDIATELY when there is a live player unit, rather than waiting for the next
-- spawn. Choosing a boon at the start of a leg and then not having it for that leg would
-- make the choice feel like paperwork.
-- ---------------------------------------------------------------------------

function M.choose(name)
	if not name then return false end

	-- v0.25.0: a drafted legendary starts its unlock clock. Promotion
	-- happens only when the NEXT leg completes (chain calls
	-- promote_pending_legendaries), on Penitent or higher. is_legendary
	-- needs the pool partitions; build them if this VM has not yet.
	if _legendary_set == nil then pcall(M.pool) end
	if M.is_legendary(name) and M.record_pending_legendary then
		pcall(M.record_pending_legendary, name)
	end

	_run_state.add_boon(name, 1)
	_run_state.clear_draft()

	local player_unit = _shared.local_player_unit()
	if player_unit and _run_state.is_active() then
		M.grant(player_unit, name)
	end

	_event_log.emit({
		t = _shared.fixed_time(),
		event = "boon_chosen",
		id = _event_log.next_id(),
		boon = name,
		leg = _run_state.get().index,
	})

	return true
end

-- ---------------------------------------------------------------------------

function M.status()
	local owned = {}
	if _run_state then
		for name, stacks in pairs(_run_state.get().boons) do
			owned[#owned + 1] = name .. " x" .. tostring(stacks)
		end
		table.sort(owned)
	end

	local applied_count = 0
	for _ in pairs(_applied) do applied_count = applied_count + 1 end

	return {
		pool_size    = M.pool_size(),
		pool_from    = _stats.pool_from,
		draft_pending = _run_state and _run_state.draft_pending() or false,
		offered_this_leg = _draft_offered_this_leg,
		data_table   = _buffs_data() ~= nil,
		parser       = _mission_buffs_parser() ~= false,
		owned        = owned,
		applied_now  = applied_count,
		applied_total = _stats.applied,
		failed       = _stats.failed,
		spawns       = _stats.spawns,
		last_error   = _stats.last_error,
	}
end

-- ===========================================================================
-- v0.22.81 (Session F foothold / Boons v2): the Boon Loadout.
-- ===========================================================================
--
-- Custom Pilgrimage boons, purchasable as PERMANENT unlocks with Ordos
-- and slotted into a loadout that is active from run start, every run,
-- while slotted. They can NEVER appear in the between-legs draft (the
-- draft rolls from Fatshark's hordes pool; these ids aren't in it), per
-- the Section 3f pool partition.
--
-- Storage (DMF settings):
--   _boon_library_owned    csv of purchased custom boon ids
--   _boon_loadout_slotted  csv of currently slotted ids
-- Slot count: 1 base + boon_slot_2/boon_slot_3 Emporium purchases
-- (slot 4 reserved for a future penance per the locked Section 9
-- decision: at least one expansion Ordos-purchasable, rest penances).
--
-- Templates register through Passives.register_template_source so one
-- hook_require owns the buff_templates path. Prices flagged for the
-- Ordos economy audit.

local KEY_BOON_OWNED   = "_boon_library_owned"
local KEY_BOON_SLOTTED = "_boon_loadout_slotted"

-- Ability-state Legendary helpers. These controller buffs stay on the
-- operative for the mission, but expose their stats/keywords only while the
-- matching native ability keyword is present. This is the same lifecycle
-- shape Fatshark uses for its own Hordes stance boons, so death, respawn and
-- an ordinary ability end cannot leave a second Pilgrimage timer running.
local function _ability_state_template(active_keyword, stat_values, keyword_names)
	return function(BS)
		local stats, keywords = {}, {}
		for stat_name, value in pairs(stat_values or {}) do
			local token = BS.stat_buffs[stat_name]
			if token then stats[token] = value end
		end
		for i = 1, #(keyword_names or {}) do
			local token = BS.keywords[keyword_names[i]]
			if token then keywords[#keywords + 1] = token end
		end
		local active_token = BS.keywords[active_keyword]
		return {
			class_name = "buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			conditional_stat_buffs = stats,
			conditional_keywords = keywords,
			start_func = function(template_data)
				template_data.ability_active = false
			end,
			conditional_stat_buffs_func = function(template_data)
				return template_data.ability_active
			end,
			conditional_keywords_func = function(template_data)
				return template_data.ability_active
			end,
			update_func = function(template_data, template_context)
				local ext = template_context.buff_extension
				template_data.ability_active = active_token ~= nil
					and ext ~= nil and ext:has_keyword(active_token) or false
			end,
		}
	end
end

-- Returns the live native ability buff instance. BuffExtension deliberately
-- exposes presence checks but no public instance getter; duration extension
-- therefore uses the extension's own active-buff array, then calls Buff's
-- public add_duration method. Keeping this seam in one helper makes source
-- drift easy to audit after a game update.
local function _active_buff_instance(buff_extension, template_names)
	local buffs = buff_extension and buff_extension._buffs
	if type(buffs) ~= "table" then return nil end
	for i = 1, #buffs do
		local buff = buffs[i]
		local ok, template = pcall(buff.template, buff)
		local name = ok and template and template.name
		for j = 1, #template_names do
			if name == template_names[j] then return buff end
		end
	end
	return nil
end

local function _duration_refund_template(active_templates, critical_only, per_kill, cap)
	return function(BS)
		return {
			class_name = "server_only_proc_buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			proc_events = { [BS.proc_events.on_kill] = 1 },
			check_proc_func = function(params, template_data, template_context)
				if critical_only and not params.is_critical_strike then return false end
				return _active_buff_instance(template_context.buff_extension, active_templates) ~= nil
			end,
			proc_func = function(params, template_data, template_context)
				if not template_context.is_server then return end
				local buff = _active_buff_instance(template_context.buff_extension, active_templates)
				if not buff then return end
				local amount = per_kill
				if cap then
					local ok, already = pcall(buff.extra_duration, buff)
					already = ok and already or 0
					amount = math.min(amount, math.max(0, cap - (already or 0)))
				end
				if amount > 0 then pcall(buff.add_duration, buff, amount) end
			end,
		}
	end
end

-- Declared before the custom template factories so their callbacks capture the
-- local helpers rather than looking for globals. The implementations live in
-- the runtime section, after the full catalogue has been built.
local _deal_secondary_damage
-- Every damage profile name can be serialized by Darktide's attack report and
-- death systems. Borrow a shipped reflection profile name so secondary damage
-- always has a valid network lookup on hosts and clients. A custom local name
-- caused crash 60fc7451-f711-44ff-9049-227c17dc04e4 when an arc was reported.
local SECONDARY_DAMAGE_PROFILE_NAME = "hordes_buff_damage_reflection_hit"
local _nearest_enemy_in_radius
local _for_each_enemy_in_radius

local function _cold_wake_template(BS)
	local stance_keyword = BS.keywords.veteran_combat_ability_stance
	local dodge_keyword = BS.keywords.count_as_dodge_vs_ranged
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		conditional_keywords = dodge_keyword and { dodge_keyword } or {},
		proc_events = { [BS.proc_events.on_ranged_dodge] = 1 },
		start_func = function(template_data)
			template_data.ability_active = false
		end,
		conditional_keywords_func = function(template_data)
			return template_data.ability_active
		end,
		update_func = function(template_data, template_context)
			local extension = template_context.buff_extension
			template_data.ability_active = stance_keyword ~= nil
				and extension ~= nil and extension:has_keyword(stance_keyword) or false
		end,
		check_proc_func = function(params, template_data)
			return template_data.ability_active
		end,
		proc_func = function(params, template_data, template_context)
			if not template_context.is_server then return end
			local buff = _active_buff_instance(template_context.buff_extension, {
				"veteran_combat_ability_stance_master",
				"veteran_combat_ability_stance_master_increased_duration",
			})
			if not buff then return end
			local ok, already = pcall(buff.extra_duration, buff)
			already = ok and already or 0
			local amount = math.min(0.5, math.max(0, 10 - (already or 0)))
			if amount > 0 then pcall(buff.add_duration, buff, amount) end
		end,
	}
end

local function _house_edge_template(BS)
	local stance_keyword = BS.keywords.broker_combat_ability_focus
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return params.is_critical_strike == true
				and (params.actual_damage_dealt or 0) > 0
				and stance_keyword ~= nil
				and template_context.buff_extension:has_keyword(stance_keyword)
		end,
		proc_func = function(params, template_data, template_context)
			if not template_context.is_server then return end
			local target = _nearest_enemy_in_radius(template_context.unit,
				params.attacked_unit, 8, params.attacked_unit)
			if target then
				_deal_secondary_damage(target, template_context.unit,
					(params.actual_damage_dealt or 0) * 0.50, "buff")
			end
		end,
	}
end

local function _gutter_rage_template(BS)
	local stance_keyword = BS.keywords.broker_combat_ability_punk_rage
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		start_func = function(template_data)
			template_data.hit_count = 0
			template_data.was_active = false
		end,
		update_func = function(template_data, template_context)
			local active = stance_keyword ~= nil
				and template_context.buff_extension:has_keyword(stance_keyword) or false
			if not active and template_data.was_active then template_data.hit_count = 0 end
			template_data.was_active = active
		end,
		check_proc_func = function(params, template_data, template_context)
			return params.attack_type == "melee"
				and (params.actual_damage_dealt or 0) > 0
				and stance_keyword ~= nil
				and template_context.buff_extension:has_keyword(stance_keyword)
		end,
		proc_func = function(params, template_data, template_context)
			if not template_context.is_server then return end
			template_data.hit_count = (template_data.hit_count or 0) + 1
			if template_data.hit_count % 10 ~= 0 then return end
			local damage = (params.actual_damage_dealt or 0) * 0.50
			_for_each_enemy_in_radius(template_context.unit, params.attacked_unit, 5,
				nil, function(target)
					_deal_secondary_damage(target, template_context.unit, damage, "buff")
				end)
		end,
	}
end

-- Wave B health/toughness helpers. These stay inside the buff system so the
-- server remains authoritative and the effects disappear with the owning
-- player unit. Toughness is loaded lazily because boons.lua also runs in UI
-- contexts where gameplay utilities may not be ready yet.
local _toughness_utility

local function _replenish_toughness(unit, percentage, reason)
	if _toughness_utility == nil then
		local ok, utility = pcall(require, "scripts/utilities/toughness/toughness")
		_toughness_utility = ok and type(utility) == "table" and utility or false
	end
	if not _toughness_utility
		or type(_toughness_utility.replenish_percentage) ~= "function" then
		return false
	end
	return pcall(_toughness_utility.replenish_percentage,
		unit, percentage, false, reason)
end

local function _remove_child_buff(buff_extension, template_name)
	if not buff_extension
		or type(buff_extension.has_buff_using_buff_template) ~= "function"
		or type(buff_extension.remove_internally_controlled_buff_stack) ~= "function"
		or not buff_extension:has_buff_using_buff_template(template_name) then
		return
	end
	pcall(buff_extension.remove_internally_controlled_buff_stack,
		buff_extension, template_name)
end

local function _health_threshold_template(child_template_name)
	return function()
		return {
			class_name = "buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			start_func = function(template_data)
				template_data.child_active = false
				template_data.next_check_t = 0
			end,
			update_func = function(template_data, template_context, dt, t)
				if not template_context.is_server
					or t < (template_data.next_check_t or 0) then return end
				template_data.next_check_t = t + 0.20

				local health = ScriptUnit.has_extension(
					template_context.unit, "health_system")
				local below = health ~= nil
					and type(health.current_health_percent) == "function"
					and health:current_health_percent() < (1 / 3)
				if below == template_data.child_active then return end

				local buff_extension = template_context.buff_extension
				if below then
					if buff_extension
						and type(buff_extension.add_internally_controlled_buff) == "function" then
						buff_extension:add_internally_controlled_buff(child_template_name, t)
						template_data.child_active = true
					end
				else
					_remove_child_buff(buff_extension, child_template_name)
					template_data.child_active = false
				end
			end,
			stop_func = function(template_data, template_context)
				if template_data.child_active then
					_remove_child_buff(template_context.buff_extension, child_template_name)
					template_data.child_active = false
				end
			end,
		}
	end
end

local function _brace_for_it_template(BS)
	return {
		class_name = "proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		cooldown_duration = 3,
		proc_events = { [BS.proc_events.on_block] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
		end,
		proc_func = function(params, template_data, template_context)
			_replenish_toughness(template_context.unit, 0.10,
				"pilgrimage_brace_for_it")
		end,
	}
end

local function _refusal_response_template(BS)
	return {
		class_name = "proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		cooldown_duration = 12,
		proc_events = { [BS.proc_events.on_damage_taken] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and params.attacked_unit == template_context.unit
				and (params.damage_amount or 0) > 0
		end,
		proc_func = function(params, template_data, template_context, t)
			_replenish_toughness(template_context.unit, 0.30,
				"pilgrimage_refusal_response")
			local buff_extension = template_context.buff_extension
			if buff_extension
				and type(buff_extension.add_internally_controlled_buff) == "function" then
				buff_extension:add_internally_controlled_buff(
					"pilgrim_refusal_response_guard", t)
			end
		end,
	}
end

-- Wave B timed-trigger helpers. A visible family boon listens for the combat
-- event, then adds a hidden child buff containing only the temporary stats.
-- This mirrors Fatshark's own kill-buff pattern and lets the buff system own
-- duration refreshes and stack caps instead of maintaining parallel timers.
local _electrocution_keyword_names = {
	"electrocuted",
	"electrocuted_chain_lightning",
	"electrocuted_arc",
	"electrocuted_arc_grenade",
	"electrocuted_arc_ability",
	"electrocuted_shock_mine",
}

local function _resolve_ailment_tokens(BS, ailment_names)
	local tokens = {}
	local damage_types = {}
	local seen = {}
	local function add_keyword(name)
		local token = BS.keywords and BS.keywords[name]
		if token ~= nil and not seen[token] then
			seen[token] = true
			tokens[#tokens + 1] = token
		end
	end
	for i = 1, #ailment_names do
		local name = ailment_names[i]
		if name == "electrocuted" then
			for j = 1, #_electrocution_keyword_names do
				add_keyword(_electrocution_keyword_names[j])
			end
			damage_types.electrocution = true
		else
			add_keyword(name)
			if name == "warpfire_burning" then
				damage_types.warpfire = true
			elseif name == "burning" then
				damage_types.burning = true
			elseif name == "bleeding" then
				damage_types.bleeding = true
			end
		end
	end
	return tokens, damage_types
end

local function _extension_has_any_keyword(extension, tokens)
	if not extension then return false end
	for i = 1, #tokens do
		local token = tokens[i]
		if type(extension.has_keyword) == "function" then
			local ok, has = pcall(extension.has_keyword, extension, token)
			if ok and has then return true end
		end
		if type(extension.had_keyword) == "function" then
			local ok, had = pcall(extension.had_keyword, extension, token)
			if ok and had then return true end
		end
	end
	return false
end

-- Nearby-state boons care about what is on the enemy now. Unlike the death
-- fallback above, they must not use had_keyword, because that briefly remembers
-- an ailment after it has ended and would leave the bonus active too long.
local function _extension_has_current_keyword(extension, tokens)
	if not extension or type(extension.has_keyword) ~= "function" then return false end
	for i = 1, #tokens do
		local ok, has = pcall(extension.has_keyword, extension, tokens[i])
		if ok and has then return true end
	end
	return false
end

local function _count_nearby_ailing_enemies(player_unit, radius, tokens)
	local count = 0
	_for_each_enemy_in_radius(player_unit, player_unit, radius, nil, function(enemy)
		local extension = ScriptUnit and type(ScriptUnit.has_extension) == "function"
			and ScriptUnit.has_extension(enemy, "buff_system") or nil
		if _extension_has_current_keyword(extension, tokens) then
			count = count + 1
		end
	end)
	return count
end

-- Reconcile a hidden child to an exact stack count through tracked external
-- handles. External removal uses Darktide's normal RPC path, so a remote owner
-- cannot keep stale attack-speed or defence stacks after the server count falls.
local function _set_child_stacks(template_data, buff_extension, template_name,
		wanted, t)
	wanted = math.min(255, math.max(0, math.floor(wanted or 0)))
	local handles = template_data.child_handles or {}
	template_data.child_handles = handles
	if not buff_extension then return #handles end

	while #handles < wanted
		and type(buff_extension.add_externally_controlled_buff) == "function" do
		local call_ok, _, index, component_index = pcall(
			buff_extension.add_externally_controlled_buff, buff_extension,
			template_name, t)
		if not call_ok or index == nil then break end
		handles[#handles + 1] = { index = index, component = component_index }
	end

	while #handles > wanted
		and type(buff_extension.remove_externally_controlled_buff) == "function" do
		local handle = handles[#handles]
		local call_ok = pcall(buff_extension.remove_externally_controlled_buff,
			buff_extension, handle.index, handle.component)
		if not call_ok then break end
		handles[#handles] = nil
	end

	return #handles
end

local function _nearby_ailment_template(child_template_name, ailment_names,
		minimum_count, stacks_from_count)
	return function(BS)
		local tokens = _resolve_ailment_tokens(BS, ailment_names)
		return {
			class_name = "buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			start_func = function(template_data)
				template_data.next_check_t = 0
				template_data.child_handles = {}
				template_data.child_stacks = 0
			end,
			update_func = function(template_data, template_context, dt, t)
				if not template_context.is_server
					or t < (template_data.next_check_t or 0) then return end
				template_data.next_check_t = t + 0.50

				local count = _count_nearby_ailing_enemies(
					template_context.unit, 8, tokens)
				local wanted = stacks_from_count and count
					or (count >= minimum_count and 1 or 0)
				template_data.child_stacks = _set_child_stacks(template_data,
					template_context.buff_extension, child_template_name, wanted, t)
			end,
			stop_func = function(template_data, template_context)
				if not template_context.is_server then return end
				template_data.child_stacks = _set_child_stacks(template_data,
					template_context.buff_extension, child_template_name, 0, 0)
			end,
		}
	end
end

-- Movement boons use the authoritative character-state component instead of
-- input guesses. That cleanly separates ordinary walking from dodge, slide and
-- sprint actions. The small velocity check prevents Moving Target from staying
-- active when the walking state is idle. External child handles keep the stat
-- synchronized and make every transition an add/remove rather than a per-frame
-- buff refresh.
local function _velocity_length_squared(velocity)
	if velocity == nil then return 0 end
	if Vector3 and type(Vector3.length_squared) == "function" then
		local ok, value = pcall(Vector3.length_squared, velocity)
		if ok and type(value) == "number" then return value end
	end
	if type(velocity) == "table" then
		local x = velocity.x or velocity[1] or 0
		local y = velocity.y or velocity[2] or 0
		local z = velocity.z or velocity[3] or 0
		return x * x + y * y + z * z
	end
	return 0
end

local function _movement_state_template(child_template_name, predicate)
	return function()
		return {
			class_name = "buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			start_func = function(template_data, template_context)
				template_data.next_check_t = 0
				template_data.child_handles = {}
				template_data.child_stacks = 0
				local unit_data = ScriptUnit.has_extension(
					template_context.unit, "unit_data_system")
				if unit_data then
					template_data.character_state = unit_data:read_component("character_state")
					template_data.locomotion = unit_data:read_component("locomotion")
				end
			end,
			update_func = function(template_data, template_context, dt, t)
				if not template_context.is_server
					or t < (template_data.next_check_t or 0) then return end
				template_data.next_check_t = t + 0.05
				local state = template_data.character_state
				local locomotion = template_data.locomotion
				local active = state ~= nil
					and predicate(state.state_name, locomotion,
						_velocity_length_squared)
				local wanted = active and 1 or 0
				if wanted == template_data.child_stacks then return end
				template_data.child_stacks = _set_child_stacks(template_data,
					template_context.buff_extension, child_template_name, wanted, t)
			end,
			stop_func = function(template_data, template_context)
				if not template_context.is_server then return end
				template_data.child_stacks = _set_child_stacks(template_data,
					template_context.buff_extension, child_template_name, 0, 0)
			end,
		}
	end
end

local function _is_moving_normally(state_name, locomotion, length_squared)
	return state_name == "walking" and locomotion ~= nil
		and length_squared(locomotion.velocity_current) > 0.01
end

local function _is_dodging_or_sliding(state_name)
	return state_name == "dodging" or state_name == "sliding"
end

local function _death_has_ailment(params, tokens, damage_types)
	local death_keywords = params.keywords_on_death_or_nil
	if death_keywords then
		for i = 1, #tokens do
			if death_keywords[tokens[i]] then return true end
		end
	end

	local dying_unit = params.dying_unit or params.attacked_unit
	local extension = ScriptUnit and dying_unit
		and type(ScriptUnit.has_extension) == "function"
		and ScriptUnit.has_extension(dying_unit, "buff_system") or nil
	if _extension_has_any_keyword(extension, tokens) then return true end

	return damage_types[params.damage_type] == true
end

local function _timed_trigger_template(child_template_name, proc_event_name,
		predicate)
	return function(BS)
		local proc_event = assert(BS.proc_events[proc_event_name],
			"missing proc event: " .. proc_event_name)
		return {
			class_name = "server_only_proc_buff",
			max_stacks = 1,
			max_stacks_cap = 1,
			predicted = false,
			proc_events = { [proc_event] = 1 },
			check_proc_func = function(params, template_data, template_context)
				return template_context.is_server
					and predicate(params, template_context, BS)
			end,
			proc_func = function(params, template_data, template_context, t)
				local extension = template_context.buff_extension
				if extension and type(extension.add_internally_controlled_buff) == "function" then
					extension:add_internally_controlled_buff(child_template_name, t)
				end
			end,
		}
	end
end

local function _ailment_kill_timed_template(child_template_name, ailment_names)
	return function(BS)
		local tokens, damage_types = _resolve_ailment_tokens(BS, ailment_names)
		return _timed_trigger_template(child_template_name, "on_minion_death",
			function(params, template_context)
				return params.attacking_unit == template_context.unit
					and _death_has_ailment(params, tokens, damage_types)
			end)(BS)
	end
end

local function _pyre_tithe_template(BS)
	local tokens, damage_types = _resolve_ailment_tokens(BS,
		{ "burning", "warpfire_burning" })
	local proc_event = assert(BS.proc_events.on_minion_death,
		"missing proc event: on_minion_death")
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [proc_event] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and params.attacking_unit == template_context.unit
				and _death_has_ailment(params, tokens, damage_types)
		end,
		proc_func = function(params, template_data, template_context)
			_replenish_toughness(template_context.unit, 0.02,
				"pilgrimage_pyre_tithe")
		end,
	}
end

-- v0.28.8: LOUDER! follows the Taunt's real pulse event. The initial shout
-- and both repeats all emit on_ogryn_shout, so one proc covers all three
-- waves without maintaining a second timer that could drift from the ability.
-- Each pulse borrows Voice of Command's native 50-point bonus-Toughness buff,
-- then restores the affected unit to its new maximum. Using the shipped buff
-- preserves the yellow Toughness presentation and its normal ten-second life.
local LOUDER_GOLDEN_TOUGHNESS_BUFF =
	"veteran_combat_ability_increase_toughness_to_coherency"

local function _apply_louder_toughness(unit, owner_unit, t)
	if not unit or not HEALTH_ALIVE[unit] then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension
		or type(buff_extension.add_internally_controlled_buff) ~= "function" then return end

	local ok = pcall(buff_extension.add_internally_controlled_buff,
		buff_extension, LOUDER_GOLDEN_TOUGHNESS_BUFF, t,
		"owner_unit", owner_unit)
	if ok then
		_replenish_toughness(unit, 1, "pilgrimage_louder")
	end
end

local function _pulse_louder_toughness(player_unit, t)
	local affected = {}
	local function apply(unit)
		if not unit or affected[unit] then return end
		affected[unit] = true
		_apply_louder_toughness(unit, player_unit, t)
	end

	apply(player_unit)
	local coherency_extension = ScriptUnit.has_extension(player_unit, "coherency_system")
	if not coherency_extension
		or type(coherency_extension.in_coherence_units) ~= "function" then return end
	local ok, units = pcall(coherency_extension.in_coherence_units,
		coherency_extension)
	if not ok or type(units) ~= "table" then return end
	for unit in pairs(units) do apply(unit) end
end

local function _louder_template(BS)
	local proc_event = assert(BS.proc_events.on_ogryn_shout,
		"missing proc event: on_ogryn_shout")
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [proc_event] = 1 },
		proc_func = function(params, template_data, template_context, t)
			_pulse_louder_toughness(template_context.unit, t)
		end,
	}
end

local function _timed_stat_template(duration, max_stacks, stat_values)
	return function(BS)
		local resolved = {}
		for stat_name, value in pairs(stat_values) do
			local token = assert(BS.stat_buffs[stat_name],
				"missing stat buff: " .. stat_name)
			resolved[token] = value
		end
		return {
			class_name = "buff",
			duration = duration,
			max_stacks = max_stacks,
			max_stacks_cap = max_stacks,
			predicted = false,
			refresh_duration_on_stack = true,
			stat_buffs = resolved,
		}
	end
end

local function _stacking_stat_template(max_stacks, stat_values)
	return function(BS)
		local resolved = {}
		for stat_name, value in pairs(stat_values) do
			local token = assert(BS.stat_buffs[stat_name],
				"missing stat buff: " .. stat_name)
			resolved[token] = value
		end
		return {
			class_name = "buff",
			max_stacks = max_stacks,
			max_stacks_cap = max_stacks,
			predicted = false,
			stat_buffs = resolved,
		}
	end
end

-- Wave B hit/application helpers. Ailments are placed on the victim through
-- the same target-side buff API used by Fatshark's Hordes boons. Keeping this
-- in one helper preserves source ownership, stack counts and server authority
-- for Cinder Touch, Ion Wake, Livewire and Prism of Ruin.
local function _apply_ailment_stacks(target_unit, buff_name, stacks, t,
		owner_unit)
	if not target_unit or (HEALTH_ALIVE and not HEALTH_ALIVE[target_unit])
		or not ScriptUnit or type(ScriptUnit.has_extension) ~= "function" then
		return false
	end
	local extension = ScriptUnit.has_extension(target_unit, "buff_system")
	if not extension then return false end
	stacks = math.max(1, math.floor(stacks or 1))
	if type(extension.add_internally_controlled_buff_with_stacks) == "function" then
		local ok = pcall(extension.add_internally_controlled_buff_with_stacks,
			extension, buff_name, stacks, t, "owner_unit", owner_unit)
		return ok
	end
	if type(extension.add_internally_controlled_buff) ~= "function" then
		return false
	end
	for i = 1, stacks do
		local ok = pcall(extension.add_internally_controlled_buff,
			extension, buff_name, t, "owner_unit", owner_unit)
		if not ok then return false end
	end
	return true
end

local function _cinder_touch_template(BS)
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		start_func = function(template_data)
			template_data.target_ready_at = setmetatable({}, { __mode = "k" })
		end,
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and params.attack_type == "melee"
				and params.hit_weakspot == true
				and (params.actual_damage_dealt or 0) > 0
		end,
		proc_func = function(params, template_data, template_context, t)
			local target = params.attacked_unit
			local ready_at = template_data.target_ready_at
			if not target or t < (ready_at[target] or 0) then return end
			if _apply_ailment_stacks(target, "flamer_assault", 1, t,
					template_context.unit) then
				ready_at[target] = t + 1
			end
		end,
	}
end

local function _ion_wake_template(BS)
	return {
		class_name = "server_only_proc_buff",
		cooldown_duration = 3,
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_successful_dodge] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and params.attack_type == "melee"
				and params.attacking_unit ~= nil
		end,
		proc_func = function(params, template_data, template_context, t)
			_apply_ailment_stacks(params.attacking_unit, "hordes_ailment_shock",
				1, t, template_context.unit)
		end,
	}
end

local function _livewire_template(BS)
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and params.attack_type == "melee"
				and params.is_critical_strike == true
				and (params.actual_damage_dealt or 0) > 0
		end,
		proc_func = function(params, template_data, template_context, t)
			_apply_ailment_stacks(params.attacked_unit, "hordes_ailment_shock",
				1, t, template_context.unit)
		end,
	}
end

-- Closed Circuit repeats a quarter of a direct hit's final damage against one
-- other shocked enemy. `buff` attacks are damage-over-time ticks and secondary
-- effects, so excluding that attack type keeps the boon on deliberate hits.
-- The borrowed secondary profile also has skip_on_hit_proc, giving the arc a
-- second recursion barrier inside Darktide's native proc dispatcher.
local function _closed_circuit_template(BS)
	local shock_tokens = _resolve_ailment_tokens(BS, { "electrocuted" })
	local direct_attack_types = {
		arc = true,
		melee = true,
		ranged = true,
		explosion = true,
		shout = true,
		push = true,
		companion_dog = true,
	}
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		check_proc_func = function(params, template_data, template_context)
			if not template_context.is_server
				or not direct_attack_types[params.attack_type]
				or (params.actual_damage_dealt or 0) <= 0
				or params.attacked_unit == nil then return false end
			local target_extension = ScriptUnit.has_extension(
				params.attacked_unit, "buff_system")
			return _extension_has_current_keyword(target_extension, shock_tokens)
		end,
		proc_func = function(params, template_data, template_context)
			local other = _nearest_enemy_in_radius(template_context.unit,
				params.attacked_unit, 8, params.attacked_unit, function(target)
					local extension = ScriptUnit.has_extension(target, "buff_system")
					return _extension_has_current_keyword(extension, shock_tokens)
				end)
			if other then
				_deal_secondary_damage(other, template_context.unit,
					(params.actual_damage_dealt or 0) * 0.25, "electrocution")
			end
		end,
	}
end

local function _prism_of_ruin_template(BS)
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		start_func = function(template_data)
			template_data.armed = false
			template_data.ready_at = nil
		end,
		update_func = function(template_data, template_context, dt, t)
			if template_data.ready_at == nil then
				template_data.ready_at = t + 15
				return
			end
			if template_context.is_server and not template_data.armed
				and t >= template_data.ready_at then
				template_data.armed = true
			end
		end,
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server and template_data.armed
				and (params.actual_damage_dealt or 0) > 0
		end,
		proc_func = function(params, template_data, template_context, t)
			local target = params.attacked_unit
			_apply_ailment_stacks(target, "flamer_assault", 3, t,
				template_context.unit)
			_apply_ailment_stacks(target, "bleed", 3, t,
				template_context.unit)
			_apply_ailment_stacks(target, "hordes_ailment_shock", 2, t,
				template_context.unit)
			template_data.armed = false
			template_data.ready_at = t + 15
		end,
	}
end

local function _remove_all_internal_stacks(extension, template_name)
	if not extension
		or type(extension.has_buff_using_buff_template) ~= "function"
		or type(extension.remove_internally_controlled_buff_stack) ~= "function" then
		return
	end
	-- The only current caller caps at five. The guard prevents a malformed
	-- extension double or another mod from turning cleanup into an endless loop.
	local guard = 0
	while extension:has_buff_using_buff_template(template_name) and guard < 16 do
		extension:remove_internally_controlled_buff_stack(template_name)
		guard = guard + 1
	end
end

local function _measured_violence_template(BS)
	return {
		class_name = "server_only_proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = { [BS.proc_events.on_hit] = 1 },
		check_proc_func = function(params, template_data, template_context)
			return template_context.is_server
				and (params.actual_damage_dealt or 0) > 0
		end,
		proc_func = function(params, template_data, template_context, t)
			local extension = template_context.buff_extension
			if params.hit_weakspot == true then
				if extension
					and type(extension.add_internally_controlled_buff) == "function" then
					extension:add_internally_controlled_buff(
						"pilgrim_measured_violence_effect", t)
				end
			else
				_remove_all_internal_stacks(extension,
					"pilgrim_measured_violence_effect")
			end
		end,
	}
end

local function _wrecking_rhythm_template(BS)
	local sweep_start = assert(BS.proc_events.on_sweep_start,
		"missing proc event: on_sweep_start")
	local sweep_finish = assert(BS.proc_events.on_sweep_finish,
		"missing proc event: on_sweep_finish")
	local proc_events = { [sweep_start] = 1, [sweep_finish] = 1 }
	local specific = {}
	specific[sweep_start] = function(params, template_data)
		if params.is_heavy then
			template_data.heavy_count = (template_data.heavy_count or 0) + 1
			template_data.empowered = template_data.heavy_count % 3 == 0
		else
			template_data.heavy_count = 0
			template_data.empowered = false
		end
	end
	specific[sweep_finish] = function(params, template_data)
		template_data.empowered = false
	end
	local wield_melee = BS.proc_events.on_wield_melee
	if wield_melee then
		proc_events[wield_melee] = 1
		specific[wield_melee] = function(params, template_data)
			template_data.heavy_count = 0
			template_data.empowered = false
		end
	end
	return {
		class_name = "proc_buff",
		max_stacks = 1,
		max_stacks_cap = 1,
		predicted = false,
		proc_events = proc_events,
		conditional_stat_buffs = {
			[BS.stat_buffs.max_hit_mass_attack_modifier] = 0.40,
			[BS.stat_buffs.melee_impact_modifier] = 0.40,
		},
		conditional_stat_buffs_func = function(template_data)
			return template_data.empowered == true
		end,
		check_active_func = function(template_data)
			return template_data.empowered == true
		end,
		specific_proc_func = specific,
	}
end

-- ===========================================================================
-- v0.26.0 (Boons v2 Wave A): PILGRIMAGE FAMILY BOONS.
-- ===========================================================================
--
-- These are drafted during a run. They are deliberately separate from
-- M.CUSTOM, whose entries are permanent Ordos-purchased Doctrines. The
-- descriptions are menu copy, not design notes: one quick sentence each.

M.FAMILY_BOONS = {
	{
		id = "pilgrim_family_kindling",
		buff_template = "pilgrim_family_kindling",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Kindling",
		description = "Burn and soulfire deal 10% more damage.",
		short = "+10% fire damage",
		custom = {
			stat_buffs = { burning_damage = 0.10 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_long_burn",
		buff_template = "pilgrim_family_long_burn",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Long Burn",
		description = "Burn and soulfire last 30% longer.",
		short = "+30% fire duration",
		custom = {
			stat_buffs = { burning_duration = 0.30 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_hot_blood",
		buff_template = "pilgrim_family_hot_blood",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Hot Blood",
		description = "Burning enemy kills grant +5% move speed for 3s. Stacks 3 times.",
		short = "fire kill: move speed",
		custom = {
			template = _ailment_kill_timed_template("pilgrim_hot_blood_effect",
				{ "burning", "warpfire_burning" }),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_damage_per_burning_enemy",
		},
	},
	{
		id = "pilgrim_family_cinder_touch",
		buff_template = "pilgrim_family_cinder_touch",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Cinder Touch",
		description = "Melee weakspot hits apply 1 burn stack per target each second.",
		short = "weakspot hit: burn",
		custom = {
			template = _cinder_touch_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_pyre_tithe",
		buff_template = "pilgrim_family_pyre_tithe",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Pyre Tithe",
		description = "Burning enemy kills replenish 2% toughness.",
		short = "fire kill: +2% toughness",
		custom = {
			template = _pyre_tithe_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_toughness_on_fire_damage_dealt",
		},
	},
	{
		id = "pilgrim_family_flashover",
		buff_template = "pilgrim_family_flashover",
		family = "fire",
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Flashover",
		description = "20 combined fire stacks erupt for 10% max health and spread both fires.",
		short = "20 fire stacks: eruption",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_damage_per_burning_enemy",
		},
	},
	{
		id = "pilgrim_family_grounded",
		buff_template = "pilgrim_family_grounded",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Grounded",
		description = "Gain 20% rending against electrocuted enemies.",
		short = "+20% shock rending",
		custom = {
			stat_buffs = { rending_vs_electrocuted_multiplier = 0.20 },
				hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		id = "pilgrim_family_ion_wake",
		buff_template = "pilgrim_family_ion_wake",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Ion Wake",
		description = "Dodging a melee attack shocks the attacker. 3s cooldown.",
		short = "melee dodge: shock",
		custom = {
			template = _ion_wake_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		id = "pilgrim_family_copper_nerves",
		buff_template = "pilgrim_family_copper_nerves",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "minoris",
		name = "Copper Nerves",
		description = "Within 8m of an electrocuted enemy, gain +10% toughness replenishment.",
		short = "near shock: toughness recovery",
		custom = {
			template = _nearby_ailment_template("pilgrim_copper_nerves_effect",
				{ "electrocuted" }, 1, false),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_extra_toughness_near_burning_shocked_enemies",
		},
	},
	{
		id = "pilgrim_family_faraday_soul",
		buff_template = "pilgrim_family_faraday_soul",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Faraday Soul",
		description = "Within 8m of 3 electrocuted enemies, take 20% less damage.",
		short = "3 nearby shocks: -20% damage",
		custom = {
			template = _nearby_ailment_template("pilgrim_faraday_soul_effect",
				{ "electrocuted" }, 3, false),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_damage_taken_close_to_electrocuted_enemy",
		},
	},
	{
		id = "pilgrim_family_livewire",
		buff_template = "pilgrim_family_livewire",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Livewire",
		description = "Critical melee hits shock the target.",
		short = "melee crit: shock",
		custom = {
			template = _livewire_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		id = "pilgrim_family_closed_circuit",
		buff_template = "pilgrim_family_closed_circuit",
		family = "electric",
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Closed Circuit",
		description = "Direct hits arc 25% damage to another shocked enemy within 8m.",
		short = "shocked hits arc 25%",
		custom = {
			template = _closed_circuit_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		id = "pilgrim_family_elemental_affinity",
		buff_template = "pilgrim_family_elemental_affinity",
		family = "elementalist",
		draft_tags = { "fire", "electric", "debuff" },
		tier = "minoris",
		name = "Elemental Affinity",
		description = "Deal 10% more damage to burning, soulfired, or electrocuted targets.",
		short = "+10% vs elemental ailments",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_reactive_chemistry",
		buff_template = "pilgrim_family_reactive_chemistry",
		family = "elementalist",
		draft_tags = { "fire", "electric", "debuff" },
		tier = "minoris",
		name = "Reactive Chemistry",
		description = "Ailment kills grant +10% reload and melee attack speed for 3s.",
		short = "ailment kill: combat speed",
		custom = {
			template = _ailment_kill_timed_template(
				"pilgrim_reactive_chemistry_effect",
				{ "burning", "warpfire_burning", "bleeding", "electrocuted" }),
				hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_improved_weapon_reload_on_melee_kill",
		},
	},
	{
		id = "pilgrim_family_entropy_feast",
		buff_template = "pilgrim_family_entropy_feast",
		family = "elementalist",
		draft_tags = { "fire", "electric", "debuff" },
		tier = "majoris",
		name = "Entropy Feast",
		description = "Gain +10% attack speed per enemy within 8m suffering damage over time.",
		short = "nearby ailments: attack speed",
		custom = {
			template = _nearby_ailment_template("pilgrim_entropy_feast_effect",
				{ "burning", "warpfire_burning", "bleeding", "electrocuted" },
				1, true),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_damage_per_burning_enemy",
		},
	},
	{
		id = "pilgrim_family_prism_of_ruin",
		buff_template = "pilgrim_family_prism_of_ruin",
		family = "elementalist",
		draft_tags = { "fire", "electric", "debuff" },
		tier = "majoris",
		name = "Prism of Ruin",
		description = "Every 15s, your next damaging hit applies 3 burn, 3 bleed, and 2 shock.",
		short = "timed hit: three ailments",
		custom = {
			template = _prism_of_ruin_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_thermal_shock",
		buff_template = "pilgrim_family_thermal_shock",
		family = "elementalist",
		-- Requires both fire and shock to be present, so it belongs to the
		-- debuff specialist but neither single-element Archetype.
		draft_tags = { "debuff" },
		tier = "majoris",
		name = "Thermal Shock",
		description = "Mix fire and shock: heavy stagger and 20% brittleness for 6s. 12s cooldown.",
		short = "mix elements: stagger, brittle",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id = "pilgrim_family_thick_hide",
		buff_template = "pilgrim_family_thick_hide",
		family = "unkillable",
		tier = "minoris",
		name = "Thick Hide",
		description = "Take 10% less toughness damage.",
		short = "-10% toughness damage",
		custom = {
			stat_buffs = { toughness_damage_taken_modifier = -0.10 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id = "pilgrim_family_second_wind",
		buff_template = "pilgrim_family_second_wind",
		family = "unkillable",
		tier = "minoris",
		name = "Second Wind",
		description = "Toughness regeneration starts 30% sooner.",
		short = "-30% regen delay",
		custom = {
			stat_buffs = { toughness_regen_delay_modifier = -0.30 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id = "pilgrim_family_hard_to_finish",
		buff_template = "pilgrim_family_hard_to_finish",
		family = "unkillable",
		tier = "minoris",
		name = "Hard to Finish",
		description = "Below 33% health, receive 20% more healing.",
		short = "+20% low-health healing",
		custom = {
			template = _health_threshold_template("pilgrim_hard_to_finish_effect"),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_health_regen",
		},
	},
	{
		id = "pilgrim_family_last_reserve",
		buff_template = "pilgrim_family_last_reserve",
		family = "unkillable",
		tier = "minoris",
		name = "Last Reserve",
		description = "Below 33% health, replenish 20% more toughness.",
		short = "+20% low-health toughness",
		custom = {
			template = _health_threshold_template("pilgrim_last_reserve_effect"),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_toughness_coherency_regen_increase",
		},
	},
	{
		id = "pilgrim_family_brace_for_it",
		buff_template = "pilgrim_family_brace_for_it",
		family = "unkillable",
		tier = "minoris",
		name = "Brace for It",
		description = "Blocking restores 10% toughness. 3s cooldown.",
		short = "block: +10% toughness",
		custom = {
			template = _brace_for_it_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_shock_on_blocking_melee_attack",
		},
	},
	{
		id = "pilgrim_family_grave_refusal",
		buff_template = "pilgrim_family_grave_refusal",
		family = "unkillable",
		tier = "majoris",
		name = "Grave Refusal",
		description = "Gain 50% more health while downed.",
		short = "+50% downed health",
		custom = {
			stat_buffs = { knocked_down_health_modifier = 0.50 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id = "pilgrim_family_stone_covenant",
		buff_template = "pilgrim_family_stone_covenant",
		family = "unkillable",
		tier = "majoris",
		name = "Stone Covenant",
		description = "+40% max health, but 30% less healing received.",
		short = "+40% health, -30% healing",
		custom = {
			stat_buffs = {
				max_health_multiplier = 1.40,
				-- Fatshark's published stat key is misspelled "recieved".
				healing_recieved_modifier = -0.30,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id = "pilgrim_family_refusal_response",
		buff_template = "pilgrim_family_refusal_response",
		family = "unkillable",
		tier = "majoris",
		name = "Refusal Response",
		description = "Health damage restores 30% toughness and halves toughness damage for 3s. CD 12s.",
		short = "health hit: toughness guard",
		custom = {
			template = _refusal_response_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id = "pilgrim_family_quick_hands",
		buff_template = "pilgrim_family_quick_hands",
		family = "cowboy",
		tier = "minoris",
		name = "Quick Hands",
		description = "Reload 15% faster.",
		short = "+15% reload speed",
		custom = {
			stat_buffs = { reload_speed = 0.15 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_damage_taken_by_flamers_and_grenadier_reduced",
		},
	},
	{
		id = "pilgrim_family_deep_pockets",
		buff_template = "pilgrim_family_deep_pockets",
		family = "cowboy",
		tier = "minoris",
		name = "Deep Pockets",
		description = "Carry 20% more ammunition.",
		short = "+20% ammo reserve",
		custom = {
			stat_buffs = { ammo_reserve_capacity = 0.20 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_damage_taken_by_flamers_and_grenadier_reduced",
		},
	},
	{
		id = "pilgrim_family_clean_holster",
		buff_template = "pilgrim_family_clean_holster",
		family = "cowboy",
		tier = "minoris",
		name = "Clean Holster",
		description = "Ranged weakspot kills grant +20% weapon-swap speed for 4s.",
		short = "headshot kill: faster swap",
		custom = {
			template = _timed_trigger_template("pilgrim_clean_holster_effect",
				"on_kill", function(params, template_context)
					return params.attacking_unit == template_context.unit
						and params.attack_type == "ranged"
						and params.hit_weakspot == true
				end),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_reduce_swap_time",
		},
	},
	{
		id = "pilgrim_family_moving_target",
		buff_template = "pilgrim_family_moving_target",
		family = "cowboy",
		tier = "minoris",
		name = "Moving Target",
		description = "Deal 10% more ranged damage while moving normally.",
		short = "+10% ranged while moving",
		custom = {
			template = _movement_state_template(
				"pilgrim_moving_target_effect", _is_moving_normally),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_no_movement_speed_reduction_on_aim_and_windup",
		},
	},
	{
		id = "pilgrim_family_deadeye_drift",
		buff_template = "pilgrim_family_deadeye_drift",
		family = "cowboy",
		tier = "majoris",
		name = "Deadeye Drift",
		description = "Deal 25% more ranged damage while dodging or sliding.",
		short = "+25% ranged while dodging",
		custom = {
			template = _movement_state_template(
				"pilgrim_deadeye_drift_effect", _is_dodging_or_sliding),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_no_movement_speed_reduction_on_aim_and_windup",
		},
	},
	{
		id = "pilgrim_family_fan_the_hammer",
		buff_template = "pilgrim_family_fan_the_hammer",
		family = "cowboy",
		tier = "majoris",
		name = "Fan the Hammer",
		description = "Ranged kills grant +20% ranged attack speed for 3s.",
		short = "ranged kill: faster fire",
		custom = {
			template = _timed_trigger_template("pilgrim_fan_the_hammer_effect",
				"on_kill", function(params, template_context)
					return params.attacking_unit == template_context.unit
						and params.attack_type == "ranged"
				end),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_no_movement_speed_reduction_on_aim_and_windup",
		},
	},
	{
		id = "pilgrim_family_honed_edge",
		buff_template = "pilgrim_family_honed_edge",
		family = "critical",
		draft_tags = { "executioner" },
		tier = "minoris",
		name = "Honed Edge",
		description = "Melee critical hits deal 20% more damage.",
		short = "+20% melee crit damage",
		custom = {
			stat_buffs = { melee_critical_strike_damage = 0.20 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id = "pilgrim_family_true_sight",
		buff_template = "pilgrim_family_true_sight",
		family = "critical",
		tier = "minoris",
		name = "True Sight",
		description = "+5% ranged critical chance.",
		short = "+5% ranged crit",
		custom = {
			stat_buffs = { ranged_critical_strike_chance = 0.05 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id = "pilgrim_family_measured_violence",
		buff_template = "pilgrim_family_measured_violence",
		family = "critical",
		draft_tags = { "executioner" },
		tier = "minoris",
		name = "Measured Violence",
		description = "Weakspot hits grant +4% weakspot power for 3s. Stacks 5 times; other hits reset.",
		short = "chain weakspots: more power",
		custom = {
			template = _measured_violence_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id = "pilgrim_family_afterimage",
		buff_template = "pilgrim_family_afterimage",
		family = "critical",
		draft_tags = { "executioner" },
		tier = "minoris",
		name = "Afterimage",
		description = "Critical kills grant +10% dodge distance for 4s.",
		short = "crit kill: longer dodge",
		custom = {
			template = _timed_trigger_template("pilgrim_afterimage_effect",
				"on_kill", function(params, template_context)
					return params.attacking_unit == template_context.unit
						and params.is_critical_strike == true
				end),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_improved_dodge_speed_and_distance",
		},
	},
	{
		id = "pilgrim_family_executioners_rhythm",
		buff_template = "pilgrim_family_executioners_rhythm",
		family = "critical",
		draft_tags = { "executioner" },
		tier = "majoris",
		name = "Executioner's Rhythm",
		description = "Damaging critical hits grant +10% attack speed for 4s. Stacks twice.",
		short = "crits: stacking attack speed",
		custom = {
			template = _timed_trigger_template("pilgrim_executioners_rhythm_effect",
				"on_hit", function(params, template_context)
					return params.attacking_unit == template_context.unit
						and params.is_critical_strike == true
						and (params.actual_damage_dealt or 0) > 0
				end),
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_stacking_crit_damage_on_critical_hit",
		},
	},
	{
		id = "pilgrim_family_iron_cadence",
		buff_template = "pilgrim_family_iron_cadence",
		family = "unstoppable",
		draft_tags = { "executioner" },
		tier = "minoris",
		name = "Iron Cadence",
		description = "Heavy melee attacks gain 15% power.",
		short = "+15% heavy power",
		custom = {
			stat_buffs = { melee_heavy_power_level_modifier = 0.15 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id = "pilgrim_family_wrecking_rhythm",
		buff_template = "pilgrim_family_wrecking_rhythm",
		family = "unstoppable",
		draft_tags = { "executioner" },
		tier = "majoris",
		name = "Wrecking Rhythm",
		description = "Every third consecutive heavy attack gains +40% cleave and stagger.",
		short = "third heavy: cleave and stagger",
		custom = {
			template = _wrecking_rhythm_template,
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
}

for i = 1, #M.FAMILY_BOONS do
	local boon = M.FAMILY_BOONS[i]
	_pilgrim_family_by_template[boon.buff_template] = boon
end

function M.family_all()
	return M.FAMILY_BOONS
end

M.CUSTOM = {
	{
		-- Kaizen's own design (2026-08-10), third implementation and
		-- this one is HIS mechanism: "since Smite is technically a
		-- weapon you hold under the hood, make the [damage buff]
		-- active only when smite is the equipped weapon."
		--
		-- History: v0.22.81 used smite_damage_multiplier, which never
		-- fired because Smite's CHANNEL is warp-typed (only the
		-- finisher is smite-typed). v0.22.82's Attack.execute relabel
		-- hook also failed in the field (the attack utility loads
		-- before mods and is never re-required, so the fanout can't
		-- reach it). v0.22.83: conditional stat buff on the WIELD
		-- state, pure buff-system machinery, the same machinery whose
		-- malus provably works. Base -0.9 always; +9.9 more while the
		-- wielded slot is slot_grenade_ability AND its weapon template
		-- is psyker_smite (so Assail/Brain Burst don't qualify), which
		-- sums the additive bucket to exactly 10x while channeling
		-- Smite. While Smite is wielded you cannot attack with
		-- anything else, so "Smite does 10x" and "wielding Smite means
		-- 10x" are the same statement, modulo DoTs from earlier hits
		-- ticking during the channel, which also enjoy the bonus
		-- (noted, acceptable).
		-- FOURTH implementation (Kaizen 2026-08-10): "We just bump the
		-- damage 10x, straight up, but block inputs that switch to
		-- other weapons, so only Smite (or just the blitz) is allowed
		-- to be wielded." History of the three failures lives in the
		-- roadmap; short version: smite_damage_multiplier (channel is
		-- warp-typed), Attack.execute relabel (utility unreachable by
		-- fanout), conditional_stat_buffs (never evaluated in the
		-- field). This shape needs NOTHING exotic: a flat additive
		-- damage stat, proven working by the malus in every prior
		-- attempt, and the balance lives in the Smite lockdown
		-- (InputService hook in Pilgrimage.lua, TEP's proven seam):
		-- weapon wield inputs blocked, and an auto-snap that re-raises
		-- Smite whenever the game auto-returns you to a weapon after a
		-- cast (gated below 85% Peril so it can never force an
		-- overload death; while venting above that you hold your
		-- weapon, at 10x, the one documented soft spot).
		id           = "pilgrim_boon_unlimited_power",
		name         = "Unlimited Power",
		description  = "Smite deals 50x damage. All other damage is reduced to 10%.",
		short        = "Smite x50, rest 10%",
		-- v0.26.0: promoted out of the Ordos Doctrine library and into
		-- the Psyker Smite legendary pool. The old cost remains only as
		-- save-history metadata; buy_custom rejects promoted entries.
		cost         = 2500,
		legendary    = true,
		archetype    = "psyker",  -- apply-time gate; the lockdown also keys on this
		-- v0.22.85 (Kaizen): "100x damage modifier across the board,
		-- active only if smite is in the talent tree." The blitz gate
		-- below is checked at apply time AND by the lockdown, so a
		-- psyker running Assail or Brain Burst gets neither the buff
		-- nor the input lock.
		--
		-- v0.22.86 NAMING TRAP (Kaizen caught it): the blitz players
		-- call Smite is internally `psyker_chain_lightning`; the
		-- template named `psyker_smite` is BRAIN BURST (charge-and-
		-- pop, kill_charge on the head hitzone). v0.22.85 shipped the
		-- wrong name for one evening and would have gated UP onto
		-- Brain Burst instead of Smite.
		requires_blitz = "psyker_chain_lightning",
		buff_template = "pilgrim_boon_unlimited_power",
		custom = {
			stat_buffs = {
				-- additive: 1 + 99.0 = x100 on everything, and the
				-- lockdown makes "everything" mean Smite.
				--
				-- v0.22.87, Kaizen's ORIGINAL design, now buildable
				-- because the field test proved the buff machinery
				-- works ("it works now and it ridiculously strong"):
				-- Smite x50, everything else x0.1, weapons stay
				-- equippable for utility (poxburster shoves,
				-- corruptor clearing), the lockdown retired to a
				-- dormant generic system in Pilgrimage.lua.
				--
				-- Bucket math (damage_calculation.lua): `damage`,
				-- `smite_damage` and `chain_lightning_damage` all
				-- accumulate into ONE additive bucket, each
				-- contributing (aggregated - 1). Non-Smite damage:
				-- 1 + (-0.9) = x0.1. Smite components additionally
				-- carry +49.9 from one of the two targeted stats:
				-- 1 - 0.9 + 49.9 = exactly x50.
				--   * chain_lightning_damage (line 510, gated by the
				--     profile's chain_lightning flag) covers the
				--     electrocuted DoT ticks natively, and covers the
				--     channel ticks through the profile-flag patch in
				--     Pilgrimage.lua (the channel profile ships
				--     WITHOUT the flag; we set it while UP is live).
				--   * smite_damage (line 501, damage_type smite only)
				--     is the safety net for any smite-typed hit.
				-- Known leaks, accepted for now: Empowered Psionics
				-- adds its own +2 to the same bucket (x52.1, fine);
				-- force-weapon shock blessings whose DoTs reuse
				-- flagged chain-lightning profiles would enjoy the
				-- x50 (thematically coherent; revisit in the economy
				-- pass).
				damage = -0.9,
				chain_lightning_damage = 49.9,
				smite_damage = 49.9,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_psyker_smite_always_max_damage",
		},
	},
	{
		id = "pilgrim_legendary_cold_wake",
		name = "Cold Wake",
		description = "Executioner's Stance dodges ranged fire. Ranged dodges add 0.5s, up to 10s.",
		short = "ranged dodges extend stance",
		legendary = true,
		archetype = "veteran",
		requires_combat_ability = "volley_fire_stance",
		buff_template = "pilgrim_legendary_cold_wake",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/veteran/veteran_ability_volley_fire",
			template = _cold_wake_template,
		},
	},
	{
		id = "pilgrim_legendary_shadow_emperor",
		name = "Shadow of the Emperor",
		description = "The attack that ends Shroudfield strikes again after 1s.",
		short = "Shroudfield attack repeats",
		legendary = true,
		archetype = "zealot",
		requires_combat_ability = "zealot_invisibility",
		buff_template = "pilgrim_legendary_shadow_emperor",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_ability_stealth",
		},
	},
	{
		-- Current source has no timed "Warrant stance": Terminus Warrant
		-- is a permanent keystone. The timed Arbites combat stance is
		-- Castigator's Stance (adamant_stance), which is the intended fit.
		id = "pilgrim_legendary_lex_never_rests",
		name = "The Lex Never Rests",
		description = "Castigator's Stance kills extend it by 1s, up to 25s per use.",
		short = "stance kills add 1s, max 25s",
		legendary = true,
		archetype = "adamant",
		requires_combat_ability = "adamant_stance",
		buff_template = "pilgrim_legendary_lex_never_rests",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/adamant/adamant_stance",
			template = _duration_refund_template({ "adamant_hunt_stance" }, false, 1, 25),
		},
	},
	{
		id = "pilgrim_legendary_house_edge",
		name = "House Edge",
		description = "Critical hits during Desperado ricochet to a nearby enemy for 50% damage.",
		short = "Desperado crits ricochet",
		legendary = true,
		archetype = "broker",
		requires_combat_ability = "broker_focus_stance",
		buff_template = "pilgrim_legendary_house_edge",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/broker/broker_broker_gunslinger_focus",
			template = _house_edge_template,
		},
	},
	{
		id = "pilgrim_legendary_gutter_rage",
		name = "Gutter Rage",
		description = "Every 10th Rampage melee hit deals 50% of its damage in a 5m shockwave.",
		short = "10th hit: 50% shockwave",
		legendary = true,
		archetype = "broker",
		requires_combat_ability = "broker_punk_rage_stance",
		buff_template = "pilgrim_legendary_gutter_rage",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/broker/broker_broker_punk_rage",
			template = _gutter_rage_template,
		},
	},
	{
		id = "pilgrim_legendary_doctrina_override",
		name = "Doctrina Override",
		description = "Marked targets arc 25% of damage taken to a nearby enemy.",
		short = "marks arc 25% damage",
		legendary = true,
		archetype = "cryptic",
		requires_blitz = {
			"cryptic_servo_skull_order",
			"cryptic_servo_skull_order_base",
		},
		buff_template = "pilgrim_legendary_doctrina_override",
		custom = {
			hud_icon = "content/ui/textures/icons/throwables/hud/cryptic_servo_skull_order_shooting",
			template = function(BS)
				return {
					class_name = "server_only_proc_buff",
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					proc_events = { [BS.proc_events.on_hit] = 1 },
					start_func = function(template_data, template_context)
						local unit = template_context.unit
						template_data.spawner = ScriptUnit.has_extension(unit, "companion_spawner_system")
						local ok, settings = pcall(require, "scripts/settings/ability/special_rules_settings")
						template_data.servo_rule = ok and settings.special_rules
							and settings.special_rules.cryptic_servo_skull_hack
							or "cryptic_servo_skull_hack"
					end,
					check_proc_func = function(params, template_data, template_context)
						if not template_context.buff_extension:has_buff_using_buff_template(
							"cryptic_servo_skull_order") then return false end
						local servo = template_data.spawner and template_data.spawner:spawned_unit_lookup(
							template_data.servo_rule)
						return servo ~= nil and params.attack_instigator_unit == servo
							and params.attacked_unit ~= nil and HEALTH_ALIVE[params.attacked_unit]
					end,
					proc_func = function(params, template_data, template_context, t)
						if not template_context.is_server then return end
						local target_ext = ScriptUnit.has_extension(params.attacked_unit, "buff_system")
						if target_ext then
							target_ext:add_internally_controlled_buff(
								"pilgrim_doctrina_override_mark", t,
								"owner_unit", template_context.unit)
						end
					end,
				}
			end,
		},
	},
	{
		-- Save-compatible replacement for Target Marked. Keeping the old
		-- id and template means an already unlocked or slotted copy becomes
		-- Omnissian Certainty instead of turning into a dead save entry.
		id = "pilgrim_legendary_target_marked",
		name = "Omnissian Certainty",
		description = "ACD drains 7% Capacitance per second, unaffected by firing or refunds.",
		short = "ACD: fixed 7% drain",
		legendary = true,
		archetype = "cryptic",
		requires_combat_ability = "cryptic_precision_stance",
		buff_template = "pilgrim_legendary_target_marked",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_cryptic_precision_stance_duration_extension_on_kill",
		},
	},
	{
		id = "pilgrim_legendary_word_carries",
		name = "The Word Carries",
		description = "+50% shout radius. Allies are freed and take 50% less Toughness damage for 5s.",
		short = "larger shout, rescue and guard",
		legendary = true,
		archetype = "veteran",
		requires_combat_ability = "voice_of_command",
		buff_template = "pilgrim_legendary_word_carries",
		custom = {
			stat_buffs = { shout_radius_modifier = 0.50 },
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_veteran_apply_infinite_bleed_on_shout",
		},
	},
	{
		id = "pilgrim_legendary_overwhelming_mind",
		name = "Overwhelming Mind",
		description = "Scrier's Gaze: 3x warp damage, 10% other damage, then two upgraded Shrieks.",
		short = "Gaze: warp x3, two Shrieks",
		legendary = true,
		archetype = "psyker",
		requires_combat_ability = "psyker_overcharge_stance",
		buff_template = "pilgrim_legendary_overwhelming_mind",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_psyker_overcharge_reduced_damage_taken",
			template = _ability_state_template("psyker_overcharge", {
				-- The game's damage bucket is additive. While Gaze is active,
				-- ordinary damage becomes 1 - 0.9 = x0.1, while attacks the
				-- engine classifies as warp also receive +2.9, for x3 total.
				damage = -0.90,
				warp_damage = 2.90,
			}),
		},
	},
	{
		id = "pilgrim_legendary_unwarded_minds",
		name = "Unwarded Minds",
		description = "Brain Rupture executes non-bosses, but cannot target Captains or Monstrosities.",
		short = "Brain Rupture executes non-bosses",
		legendary = true,
		archetype = "psyker",
		requires_blitz = {
			"psyker_smite",
			"psyker_biomancer_smite",
		},
		buff_template = "pilgrim_legendary_unwarded_minds",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_psyker_brain_burst_hits_nearby_enemies",
		},
	},
	{
		id = "pilgrim_legendary_louder",
		name = "LOUDER!",
		description = "Each Taunt wave fully restores allies' Toughness and grants 50 bonus Toughness.",
		short = "Taunt waves fortify allies",
		legendary = true,
		archetype = "ogryn",
		requires_combat_ability = "ogryn_taunt_shout",
		buff_template = "pilgrim_legendary_louder",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_ogryn_apply_fire_on_shout",
			template = _louder_template,
		},
	},
	{
		id = "pilgrim_legendary_special_delivery",
		name = "Special Delivery",
		description = "Big Box releases 6 seeking bomblets, each dealing 70% impact damage.",
		short = "6 seeking impact bomblets",
		legendary = true,
		archetype = "ogryn",
		requires_blitz = "ogryn_grenade_box_cluster",
		buff_template = "pilgrim_legendary_special_delivery",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_ogryn_box_of_surprises",
		},
	},
	{
		-- v0.22.92 (Kaizen: "People buying friendly fire doesn't make
		-- sense, I would rather have it be a trade off"; picked the
		-- cursed-boon shape from the design session). Replaces the
		-- v0.22.91 Emporium SKU. The FF machinery lives in
		-- Pilgrimage.lua and keys on custom_boon_active of this id:
		-- friendly fire opens for player targets, and the directional
		-- filter lets ONLY the human's attacks through, so the price
		-- is your own discipline: stray shots, sweeps and grenades
		-- wound your warband, and their fire never wounds anyone.
		id           = "pilgrim_boon_sanctioned_discord",
		name         = "Sanctioned Discord",
		description  = "+100% damage. Your attacks can hurt allies; theirs cannot hurt you.",
		short        = "+100% dmg, FF on you",
		cost         = 2000,
		buff_template = "pilgrim_boon_sanctioned_discord",
		custom = {
			stat_buffs = {
				-- additive bucket: 1 + 1.0 = x2 on everything.
				damage = 1.0,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id           = "pilgrim_boon_krieg_doctrine",
		name         = "Krieg Doctrine",
		description  = "+40% ranged damage. Coherency no longer regenerates toughness.",
		short        = "+40% ranged, no regen",
		cost         = 1200,
		buff_template = "pilgrim_boon_krieg_doctrine",
		custom = {
			stat_buffs = {
				ranged_damage = 0.4,
				-- additive_multiplier (buff_settings.lua line 923):
				-- 1 + (-1) = 0, coherency toughness regen fully off.
				toughness_coherency_regen_rate_multiplier = -1,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_damage_taken_by_flamers_and_grenadier_reduced",
		},
	},
	{
		-- Kaizen's tuning note (2026-08-10): "the healing from blood
		-- debt must be small per kill, or trigger once every x kills
		-- ... Otherwise a player would be genuinely immortal." Chosen
		-- shape: 1% max HP per melee kill with a 3 second internal
		-- cooldown (the proc system's native cooldown_duration), so
		-- sustained ceiling is ~20% HP per minute. The halved-other-
		-- healing side lives in a Pilgrimage hook on the player health
		-- extension's add_heal (Pilgrimage.lua), marker-guarded so our
		-- own proc heal is exempt from its own tax.
		id           = "pilgrim_boon_blood_debt",
		name         = "Blood Debt",
		description  = "Melee kills heal 1% health (3s cooldown). Half healing; no ranged weapons.",
		-- v0.22.97: short text now mentions the ranged lock (2026-08-11
		-- field report; the long description already had it).
		short        = "melee kills heal, ranged locked, cursed",
		cost         = 1500,
		buff_template = "pilgrim_boon_blood_debt",
		custom = {
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_health_regen",
			template = function(BS)
				return {
					class_name        = "server_only_proc_buff",
					max_stacks        = 1,
					max_stacks_cap    = 1,
					predicted         = false,
					cooldown_duration = 3,
					buff_category     = BS.buff_categories.hordes_buff or BS.buff_categories.generic,
					proc_events       = {
						[BS.proc_events.on_kill] = 1,
					},
					check_proc_func = function(params, template_data, template_context, t)
						return params.attack_type == "melee"
					end,
					proc_func = function(params, template_data, template_context, t)
						local unit = template_context.unit
						pcall(function()
							local ext = ScriptUnit.extension(unit, "health_system")
							local max_health = ext:max_health()
							local Pilgrimage = rawget(_G, "get_mod") and get_mod("Pilgrimage")
							local Boons = Pilgrimage and Pilgrimage._modules and Pilgrimage._modules.Boons
							-- Marker so the heal-halving hook exempts us.
							if Boons then Boons._blood_debt_self_heal = true end
							local ok_hs, DamageSettings = pcall(require, "scripts/settings/damage/damage_settings")
							local heal_type = ok_hs and DamageSettings
								and DamageSettings.heal_types and DamageSettings.heal_types.buff
							pcall(ext.add_heal, ext, max_health * 0.01, heal_type)
							if Boons then Boons._blood_debt_self_heal = false end
						end)
					end,
				}
			end,
		},
	},
	{
		-- Kaizen's capacitance question answered: cryptic charges
		-- refill through the SAME shared cooldown computation
		-- (player_unit_ability_extension.lua line 779-784:
		-- base_cooldown * combat_ability_cooldown_modifier, class-
		-- agnostic), so this speeds Skitarii capacitance exactly like
		-- everyone else's ability cooldown.
		id           = "pilgrim_boon_redline_cogitator",
		name         = "Redline Cogitator",
		description  = "-50% combat ability cooldown. Take 25% more damage.",
		short        = "-50% CD, +25% dmg taken",
		cost         = 1200,
		buff_template = "pilgrim_boon_redline_cogitator",
		custom = {
			stat_buffs = {
				combat_ability_cooldown_modifier = -0.5,
				damage_taken_multiplier = 1.25,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		-- Both effects live Pilgrimage-side: wallet.earn_pickup doubles
		-- while this is active (wallet.lua), Emporium prices go x1.5
		-- (shop.effective_cost). No buff template at all; the id is
		-- state, not a buff. `no_buff = true` tells apply_all to skip
		-- the grant path.
		id           = "pilgrim_boon_house_wins",
		name         = "The House Always Wins",
		description  = "Double Ordos pickups, but Emporium prices rise 50%.",
		short        = "x2 Ordos, pricier shop",
		cost         = 1000,
		no_buff      = true,
	},
	{
		-- Stat buckets multiply between categories: global 0.8 x
		-- vs-monsters 2.5 = 2.0 net (+100%) against monstrosities and
		-- captains, 0.8 (-20%) against everything else. Values chosen
		-- so the NET matches the design text; field-verify the bucket
		-- math on a real monster.
		id           = "pilgrim_boon_bigger_they_are",
		name         = "The Bigger They Are",
		description  = "+100% damage to monsters and captains; -20% against everything else.",
		short        = "+100% vs monsters",
		cost         = 1200,
		buff_template = "pilgrim_boon_bigger_they_are",
		custom = {
			stat_buffs = {
				damage = -0.2,
				damage_vs_monsters = 1.5,
				damage_vs_captains = 1.5,
				ranged_damage_vs_monsters = 1.5,
				ranged_damage_vs_captains = 1.5,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
}

local _custom_by_id = {}
for i = 1, #M.CUSTOM do _custom_by_id[M.CUSTOM[i].id] = M.CUSTOM[i] end

function M.custom_get(id) return _custom_by_id[id] end
function M.custom_all()
	local out = {}
	for i = 1, #M.CUSTOM do
		if not M.CUSTOM[i].legendary then out[#out + 1] = M.CUSTOM[i] end
	end
	return out
end

-- Custom legendary catalogue. It is derived from the one source table so a
-- new entry cannot be registered as a template but accidentally omitted from
-- the picker. Keeping UP's id/template stable preserves old saves.
M.LEGENDARIES = {}
for i = 1, #M.CUSTOM do
	if M.CUSTOM[i].legendary then
		M.LEGENDARIES[#M.LEGENDARIES + 1] = M.CUSTOM[i]
	end
end
for i = 1, #M.LEGENDARIES do
	local boon = M.LEGENDARIES[i]
	_pilgrim_legendary_by_template[boon.buff_template] = boon
end

-- Hidden child effects for family boons. The visible boon owns the trigger or
-- threshold check; these templates hold the temporary stat change.
-- Keeping them separate prevents support effects from entering any draft pool.
M.FAMILY_SUPPORT_TEMPLATES = {
	{
		id = "pilgrim_flashover_spent_support",
		buff_template = "pilgrim_flashover_spent",
		custom = {
			template = function()
				return {
					class_name = "buff",
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
				}
			end,
		},
	},
	{
		id = "pilgrim_thermal_shock_cooldown_support",
		buff_template = "pilgrim_thermal_shock_cooldown",
		custom = {
			template = function()
				return {
					class_name = "buff",
					duration = 12,
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
				}
			end,
		},
	},
	{
		id = "pilgrim_thermal_shock_brittleness_support",
		buff_template = "pilgrim_thermal_shock_brittleness",
		custom = {
			template = function(BS)
				return {
					class_name = "buff",
					duration = 6,
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					refresh_duration_on_stack = true,
					stat_buffs = {
						[BS.stat_buffs.rending_multiplier] = 0.20,
					},
				}
			end,
		},
	},
	{
		id = "pilgrim_hot_blood_effect_support",
		buff_template = "pilgrim_hot_blood_effect",
		custom = {
			template = _timed_stat_template(3, 3, { movement_speed = 0.05 }),
		},
	},
	{
		id = "pilgrim_reactive_chemistry_effect_support",
		buff_template = "pilgrim_reactive_chemistry_effect",
		custom = {
			template = _timed_stat_template(3, 1, {
				reload_speed = 0.10,
				melee_attack_speed = 0.10,
			}),
		},
	},
	{
		id = "pilgrim_copper_nerves_effect_support",
		buff_template = "pilgrim_copper_nerves_effect",
		custom = {
			template = _stacking_stat_template(1,
				{ toughness_replenish_modifier = 0.10 }),
		},
	},
	{
		id = "pilgrim_faraday_soul_effect_support",
		buff_template = "pilgrim_faraday_soul_effect",
		custom = {
			template = _stacking_stat_template(1,
				{ damage_taken_modifier = -0.20 }),
		},
	},
	{
		id = "pilgrim_entropy_feast_effect_support",
		buff_template = "pilgrim_entropy_feast_effect",
		custom = {
			-- No gameplay cap is intended. 255 is only a defensive engine
			-- ceiling, far above the number of enemies broadphase can return
			-- inside an 8 metre sphere during ordinary play.
			template = _stacking_stat_template(255, { attack_speed = 0.10 }),
		},
	},
	{
		id = "pilgrim_clean_holster_effect_support",
		buff_template = "pilgrim_clean_holster_effect",
		custom = {
			template = _timed_stat_template(4, 1, { wield_speed = 0.20 }),
		},
	},
	{
		id = "pilgrim_moving_target_effect_support",
		buff_template = "pilgrim_moving_target_effect",
		custom = {
			template = _stacking_stat_template(1, { ranged_damage = 0.10 }),
		},
	},
	{
		id = "pilgrim_deadeye_drift_effect_support",
		buff_template = "pilgrim_deadeye_drift_effect",
		custom = {
			template = _stacking_stat_template(1, { ranged_damage = 0.25 }),
		},
	},
	{
		id = "pilgrim_fan_the_hammer_effect_support",
		buff_template = "pilgrim_fan_the_hammer_effect",
		custom = {
			template = _timed_stat_template(3, 1, { ranged_attack_speed = 0.20 }),
		},
	},
	{
		id = "pilgrim_afterimage_effect_support",
		buff_template = "pilgrim_afterimage_effect",
		custom = {
			template = _timed_stat_template(4, 1,
				{ dodge_distance_modifier = 0.10 }),
		},
	},
	{
		id = "pilgrim_executioners_rhythm_effect_support",
		buff_template = "pilgrim_executioners_rhythm_effect",
		custom = {
			template = _timed_stat_template(4, 2, { attack_speed = 0.10 }),
		},
	},
	{
		id = "pilgrim_measured_violence_effect_support",
		buff_template = "pilgrim_measured_violence_effect",
		custom = {
			template = _timed_stat_template(3, 5,
				{ weakspot_power_level_modifier = 0.04 }),
		},
	},
	{
		id = "pilgrim_hard_to_finish_effect_support",
		buff_template = "pilgrim_hard_to_finish_effect",
		custom = {
			template = function(BS)
				return {
					class_name = "buff",
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					stat_buffs = {
						[BS.stat_buffs.healing_recieved_modifier] = 0.20,
					},
				}
			end,
		},
	},
	{
		id = "pilgrim_last_reserve_effect_support",
		buff_template = "pilgrim_last_reserve_effect",
		custom = {
			template = function(BS)
				return {
					class_name = "buff",
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					stat_buffs = {
						[BS.stat_buffs.toughness_replenish_modifier] = 0.20,
					},
				}
			end,
		},
	},
	{
		id = "pilgrim_refusal_response_guard_support",
		buff_template = "pilgrim_refusal_response_guard",
		custom = {
			template = function(BS)
				return {
					class_name = "buff",
					duration = 3,
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					refresh_duration_on_stack = true,
					stat_buffs = {
						[BS.stat_buffs.toughness_damage_taken_multiplier] = 0.50,
					},
				}
			end,
		},
	},
}

	-- Hidden support template used on enemies marked by Doctrina Override. It is
-- registered for networking, but never enters a shop, draft or loadout list.
M.LEGENDARY_SUPPORT_TEMPLATES = {
	{
		id = "pilgrim_doctrina_override_mark_support",
		buff_template = "pilgrim_doctrina_override_mark",
		custom = {
			template = function(BS)
				return {
					class_name = "server_only_proc_buff",
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					refresh_duration_on_stack = true,
					duration = 5,
					proc_events = { [BS.proc_events.on_minion_damage_taken] = 1 },
					check_proc_func = function(params, template_data, template_context)
						return template_context.is_server
							and params.damage_profile_name ~= SECONDARY_DAMAGE_PROFILE_NAME
							and (params.damage_amount or 0) > 0
					end,
					proc_func = function(params, template_data, template_context)
						local owner = params.attacking_unit_owner_unit
							or params.attacking_unit or template_context.owner_unit
						local side_source = owner or template_context.owner_unit
						local target = _nearest_enemy_in_radius(side_source,
							template_context.unit, 8, template_context.unit)
						if target and owner then
							_deal_secondary_damage(target, owner,
								(params.damage_amount or 0) * 0.25, "electrocution")
						end
					end,
				}
			end,
		},
	},
	{
		id = "pilgrim_word_carries_guard_support",
		buff_template = "pilgrim_word_carries_guard",
		custom = {
			template = function(BS)
				return {
					class_name = "buff",
					duration = 5,
					max_stacks = 1,
					max_stacks_cap = 1,
					predicted = false,
					refresh_duration_on_stack = true,
					stat_buffs = {
						[BS.stat_buffs.toughness_damage_taken_multiplier] = 0.50,
					},
				}
			end,
		},
	},
}

-- ===========================================================================
-- v0.27.0: custom Legendary runtime integrations.
-- ===========================================================================

local function _unit_has_buff(unit, template_name)
	if not unit or not ALIVE[unit] then return false end
	local extension = ScriptUnit.has_extension(unit, "buff_system")
	if not extension then return false end
	local ok, has = pcall(extension.has_buff_using_buff_template,
		extension, template_name)
	return ok and has == true
end

local function _unit_is_boss(unit)
	local unit_data = unit and ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data and unit_data:breed()
	local tags = breed and breed.tags or {}
	return tags.monster == true or tags.captain == true
		or tags.cultist_captain == true
end

-- Secondary Legendary damage is applied after the triggering hit has already
-- passed through armour and difficulty scaling. Dealing that exact number here
-- prevents a ricochet or arc from being reduced by armour a second time. The
-- local clone keeps the required behavior, but retains a shipped network-safe
-- name. Doctrina excludes that reflection name to prevent recursive arcs.
local _secondary_damage_profile
local _damage_utility
local _breed_utility
local _attack_settings
local _damage_settings

local function _legendary_runtime_dependencies()
	if _damage_utility then return true end
	local ok_damage, Damage = pcall(require, "scripts/utilities/attack/damage")
	local ok_breed, Breed = pcall(require, "scripts/utilities/breed")
	local ok_attack, AttackSettings = pcall(require,
		"scripts/settings/damage/attack_settings")
	local ok_types, DamageSettings = pcall(require,
		"scripts/settings/damage/damage_settings")
	local ok_profiles, DamageProfiles = pcall(require,
		"scripts/settings/damage/damage_profile_templates")
	if not (ok_damage and ok_breed and ok_attack and ok_types and ok_profiles) then
		return false
	end
	local base_profile = DamageProfiles[SECONDARY_DAMAGE_PROFILE_NAME]
	if type(base_profile) ~= "table" then return false end
	_secondary_damage_profile = {}
	for key, value in pairs(base_profile) do
		_secondary_damage_profile[key] = value
	end
	_secondary_damage_profile.name = SECONDARY_DAMAGE_PROFILE_NAME
	_secondary_damage_profile.skip_on_hit_proc = true
	_secondary_damage_profile.ignore_toughness = true
	_secondary_damage_profile.unblockable = true
	_damage_utility = Damage
	_breed_utility = Breed
	_attack_settings = AttackSettings
	_damage_settings = DamageSettings
	return true
end

_for_each_enemy_in_radius = function(side_source, origin_unit, radius, excluded_unit, callback)
	if not side_source or not origin_unit or type(callback) ~= "function" then return end
	local extension_manager = Managers.state.extension
	local side_system = extension_manager and extension_manager:system("side_system")
	local side = side_system and side_system.side_by_unit[side_source]
	local broadphase_system = extension_manager and extension_manager:system("broadphase_system")
	local broadphase = broadphase_system and broadphase_system.broadphase
	local origin = POSITION_LOOKUP[origin_unit]
	if not side or not broadphase or not origin then return end

	local results = {}
	local enemy_side_names = side:relation_side_names("enemy")
	local count = broadphase.query(broadphase, origin, radius, results, enemy_side_names)
	for i = 1, count do
		local target = results[i]
		if target ~= excluded_unit and HEALTH_ALIVE[target] then callback(target) end
	end
end

_nearest_enemy_in_radius = function(side_source, origin_unit, radius, excluded_unit,
		predicate)
	local origin = origin_unit and POSITION_LOOKUP[origin_unit]
	if not origin then return nil end
	local nearest, nearest_distance
	_for_each_enemy_in_radius(side_source, origin_unit, radius, excluded_unit,
		function(target)
			if predicate and not predicate(target) then return end
			local position = POSITION_LOOKUP[target]
			if not position then return end
			local distance = Vector3.distance_squared(origin, position)
			if not nearest_distance or distance < nearest_distance then
				nearest = target
				nearest_distance = distance
			end
		end)
	return nearest
end

_deal_secondary_damage = function(target, source, amount, damage_kind)
	amount = tonumber(amount) or 0
	if amount <= 0 or not target or not source
		or not HEALTH_ALIVE[target] or not ALIVE[source]
		or not _legendary_runtime_dependencies() then return false end

	local breed = _breed_utility.unit_breed_or_nil(target)
	if not breed then return false end
	local target_position = POSITION_LOOKUP[target]
	local source_position = POSITION_LOOKUP[source]
	local direction = Vector3.up()
	if target_position and source_position
		and Vector3.distance_squared(target_position, source_position) > 0.001 then
		direction = Vector3.normalize(target_position - source_position)
	end
	local damage_type = _damage_settings.damage_types[damage_kind or "buff"]
		or _damage_settings.damage_types.buff
	local result = _attack_settings.attack_results.damaged
	local ok = pcall(_damage_utility.deal_damage,
		target, breed, source, source, result, _attack_settings.attack_types.buff,
		_secondary_damage_profile, amount, amount, 0, nil, direction, "torso", nil,
		false, damage_type, target_position, nil, false, 0)
	return ok
end

-- Flashover and Thermal Shock care about the moment an ailment is actually
-- accepted by the target, not merely about the hit that attempted to apply it.
-- Several weapons and talents add their ailment after on_hit has already run,
-- so observing MinionBuffExtension is the one ordering-safe seam. The hook's
-- first operation is a three-name lookup; every unrelated buff addition exits
-- immediately without inspecting stacks, units or player state.
local OBSERVED_AILMENTS = {
	flamer_assault = "fire",
	warp_fire = "fire",
	hordes_ailment_shock = "shock",
}
local FLASHOVER_RADIUS = 5
local _flashover_spreading = false
local _stagger_utility

local function _named_vararg(wanted, ...)
	local count = select("#", ...)
	for i = 1, count - 1, 2 do
		if select(i, ...) == wanted then return select(i + 1, ...) end
	end
	return nil
end

local function _current_stacks(extension, template_name)
	if not extension or type(extension.current_stacks) ~= "function" then return 0 end
	local ok, stacks = pcall(extension.current_stacks, extension, template_name)
	return ok and tonumber(stacks) or 0
end

local function _extension_has_template(extension, template_name)
	if not extension
		or type(extension.has_buff_using_buff_template) ~= "function" then return false end
	local ok, has = pcall(extension.has_buff_using_buff_template,
		extension, template_name)
	return ok and has == true
end

local function _add_target_buff(extension, template_name, t, owner)
	if not extension
		or type(extension.add_internally_controlled_buff) ~= "function" then return false end
	return pcall(extension.add_internally_controlled_buff, extension,
		template_name, t, "owner_unit", owner)
end

local function _target_max_health(target)
	local extension = ScriptUnit.has_extension(target, "health_system")
	if not extension or type(extension.max_health) ~= "function" then return 0 end
	local ok, value = pcall(extension.max_health, extension)
	return ok and tonumber(value) or 0
end

local function _trigger_flashover(target, target_extension, owner, t)
	if _flashover_spreading
		or not _unit_has_buff(owner, "pilgrim_family_flashover")
		or _extension_has_template(target_extension, "pilgrim_flashover_spent") then
		return
	end
	local combined = _current_stacks(target_extension, "flamer_assault")
		+ _current_stacks(target_extension, "warp_fire")
	if combined < 20 then return end

	-- Mark before dealing damage. Even a lethal eruption can therefore never
	-- re-enter through another mod's damage callback during the same frame.
	if not _add_target_buff(target_extension, "pilgrim_flashover_spent", t, owner) then
		return
	end
	local damage = _target_max_health(target) * 0.10
	if damage <= 0 then return end
	local nearby = {}
	_for_each_enemy_in_radius(owner, target, FLASHOVER_RADIUS, target,
		function(enemy) nearby[#nearby + 1] = enemy end)

	_deal_secondary_damage(target, owner, damage, "buff")
	_flashover_spreading = true
	local spread_ok, spread_error = pcall(function()
		for i = 1, #nearby do
			local enemy = nearby[i]
			_deal_secondary_damage(enemy, owner, damage, "buff")
			if HEALTH_ALIVE[enemy] then
				_apply_ailment_stacks(enemy, "flamer_assault", 5, t, owner)
				_apply_ailment_stacks(enemy, "warp_fire", 5, t, owner)
			end
		end
	end)
	_flashover_spreading = false
	if not spread_ok then error(spread_error) end
end

local function _trigger_thermal_shock(target, target_extension, owner, t)
	if not _unit_has_buff(owner, "pilgrim_family_thermal_shock")
		or _extension_has_template(target_extension,
			"pilgrim_thermal_shock_cooldown") then return end
	if not _add_target_buff(target_extension,
		"pilgrim_thermal_shock_cooldown", t, owner) then return end
	_add_target_buff(target_extension,
		"pilgrim_thermal_shock_brittleness", t, owner)

	if not _stagger_utility then
		local ok, Stagger = pcall(require, "scripts/utilities/attack/stagger")
		_stagger_utility = ok and Stagger or false
	end
	if not _stagger_utility or type(_stagger_utility.force_stagger) ~= "function" then
		return
	end
	local target_position = POSITION_LOOKUP[target]
	local owner_position = POSITION_LOOKUP[owner]
	local direction = Vector3.up()
	if target_position and owner_position
		and Vector3.distance_squared(target_position, owner_position) > 0.001 then
		direction = Vector3.normalize(target_position - owner_position)
	end
	pcall(_stagger_utility.force_stagger, target, "heavy", direction,
		2, 1, 1, owner)
end

local function _after_ailment_added(kind, target, extension, owner,
		had_fire, had_shock, t)
	if not owner or not ALIVE[owner] or not HEALTH_ALIVE[target] then return end
	if kind == "fire" then _trigger_flashover(target, extension, owner, t) end
	local cross_applied = kind == "fire" and had_shock
		or kind == "shock" and had_fire
	if cross_applied then
		_trigger_thermal_shock(target, extension, owner, t)
	end
end

function M.install_family_ailment_observer(MinionBuffExtension)
	if not _mod or MinionBuffExtension._pilgrimage_family_ailments then return end
	MinionBuffExtension._pilgrimage_family_ailments = true
	_mod:hook(MinionBuffExtension, "add_internally_controlled_buff",
		function(func, self, template_name, t, ...)
			local kind = OBSERVED_AILMENTS[template_name]
			if not kind or not self._is_server then
				return func(self, template_name, t, ...)
			end

			local before = _current_stacks(self, template_name)
			local had_fire = _current_stacks(self, "flamer_assault") > 0
				or _current_stacks(self, "warp_fire") > 0
			local had_shock = _current_stacks(self, "hordes_ailment_shock") > 0
			local owner = _named_vararg("owner_unit", ...)
			local result = func(self, template_name, t, ...)
			if _current_stacks(self, template_name) > before then
				local ok, err = pcall(_after_ailment_added, kind, self._unit,
					self, owner, had_fire, had_shock, t)
				if not ok and _debug_log then
					_debug_log("boons", 0,
						"family ailment observer failed: " .. tostring(err), 0, "warn")
				end
			end
			return result
		end)
end

local _shadow_replays = {}

local function _shadow_attack_should_repeat(attacking_unit, damage_type)
	if not attacking_unit or not _unit_has_buff(attacking_unit,
		"pilgrim_legendary_shadow_emperor") then return false end
	local extension = ScriptUnit.has_extension(attacking_unit, "buff_system")
	if not extension or not extension:has_unique_buff_id("zealot_invisibility") then
		return false
	end
	local ok, BS = pcall(require, "scripts/settings/buff/buff_settings")
	local can_keep_stealth = ok and BS.keywords
		and BS.keywords.can_attack_during_invisibility
		and extension:has_keyword(BS.keywords.can_attack_during_invisibility)
	if can_keep_stealth then return false end
	return damage_type ~= "bleeding" and damage_type ~= "burning"
		and damage_type ~= "grenade_frag" and damage_type ~= "plasma"
		and damage_type ~= "electrocution"
end

function M.update(t)
	if #_shadow_replays == 0 then return end
	for i = #_shadow_replays, 1, -1 do
		local replay = _shadow_replays[i]
		if not ALIVE[replay.target] or not ALIVE[replay.source] then
			table.remove(_shadow_replays, i)
		elseif t >= replay.at then
			table.remove(_shadow_replays, i)
			if HEALTH_ALIVE[replay.target] then
				_deal_secondary_damage(replay.target, replay.source,
					replay.damage, "buff")
			end
		end
	end
end

local function _omnissian_active(unit)
	if not _unit_has_buff(unit, "pilgrim_legendary_target_marked") then return false end
	local extension = ScriptUnit.has_extension(unit, "buff_system")
	local ok, BS = pcall(require, "scripts/settings/buff/buff_settings")
	local keyword = ok and BS.keywords and BS.keywords.cryptic_precision_stance
	return keyword ~= nil and extension:has_keyword(keyword)
end

-- ACD normally spends 1% per shot, drains 10% per second, pauses that drain
-- while reloading, and can receive several refunds. The template wrapper
-- suppresses the shot path, while the ability-extension wrapper allows only
-- the marked 7%-per-second drain through for the lifetime of the stance.
function M.install_omnissian_ability_extension(PlayerUnitAbilityExtension)
	if not _mod or PlayerUnitAbilityExtension._pilgrimage_omnissian then return end
	PlayerUnitAbilityExtension._pilgrimage_omnissian = true

	_mod:hook(PlayerUnitAbilityExtension, "increase_ability_cooldown_percentage",
		function(func, self, ability_type, amount, ...)
			if ability_type == "combat_ability" and _omnissian_active(self._unit) then
				if M._omnissian_native_drain then
					return func(self, ability_type, amount * 0.70, ...)
				elseif M._omnissian_manual_drain then
					return func(self, ability_type, amount, ...)
				end

				-- Return the same shape as the native method without changing
				-- Capacitance. Callers therefore see the real current value.
				local capacitance = self:remaining_ability_capacitance(ability_type)
				local charges = math.floor(capacitance + 0.001)
				local partial = capacitance - charges
				return charges, partial > 0 and 1 - partial or (charges > 0 and 0 or 1)
			end
			return func(self, ability_type, amount, ...)
		end)

	_mod:hook(PlayerUnitAbilityExtension, "reduce_ability_cooldown_percentage",
		function(func, self, ability_type, amount, ...)
			if ability_type == "combat_ability" and _omnissian_active(self._unit) then
				return
			end
			return func(self, ability_type, amount, ...)
		end)
end

function M.install_omnissian_templates(templates)
	if type(templates) ~= "table" then return end
	local ok_cf, ConditionalFunctions = pcall(require,
		"scripts/settings/buff/helper_functions/conditional_functions")
	if not ok_cf then return end
	local ok_bs, BS = pcall(require, "scripts/settings/buff/buff_settings")
	local on_shoot = ok_bs and BS.proc_events and BS.proc_events.on_shoot

	for _, name in ipairs({
		"cryptic_precision_stance_one_charge",
		"cryptic_precision_stance_two_charges",
		"cryptic_precision_stance_three_charges",
	}) do
		local template = templates[name]
		if template and not template._pilgrimage_omnissian then
			template._pilgrimage_omnissian = true
			local old_shoot = on_shoot and template.specific_proc_func
				and template.specific_proc_func[on_shoot]
			if old_shoot then
				template.specific_proc_func[on_shoot] = function(params, data, context, t)
					if _unit_has_buff(context.unit, "pilgrim_legendary_target_marked") then
						return
					end
					return old_shoot(params, data, context, t)
				end
			end

			local old_update = template.update_func
			template.update_func = function(data, context, dt, t)
				if not _unit_has_buff(context.unit, "pilgrim_legendary_target_marked") then
					return old_update(data, context, dt, t)
				end

				local reloading = ConditionalFunctions.is_reloading(data, context)
				if reloading and data.ability_extension then
					local amount = 0.07 * dt
					data.cooldown_percent_used = (data.cooldown_percent_used or 0) + amount
					M._omnissian_manual_drain = true
					local ok, charges, partial = pcall(
						data.ability_extension.increase_ability_cooldown_percentage,
						data.ability_extension, "combat_ability", amount)
					M._omnissian_manual_drain = false
					if ok and charges == 0 and partial >= 1 then data.stop_ability = true end
				end

				M._omnissian_native_drain = not reloading
				local ok, result = pcall(old_update, data, context, dt, t)
				M._omnissian_native_drain = false
				if not ok then error(result) end
				return result
			end
		end
	end
end

local function _for_each_player_in_radius(player_unit, radius, callback)
	local side_system = Managers.state.extension and Managers.state.extension:system("side_system")
	local side = side_system and side_system.side_by_unit[player_unit]
	local origin = POSITION_LOOKUP[player_unit]
	if not side or not origin then return end
	local radius_sq = radius * radius
	local seen = {}

	local function visit(unit)
		if not unit or seen[unit] or not ALIVE[unit] then return end
		seen[unit] = true
		local position = POSITION_LOOKUP[unit]
		if position and Vector3.distance_squared(origin, position) <= radius_sq then
			callback(unit)
		end
	end

	visit(player_unit)
	for i = 1, #(side.player_units or {}) do visit(side.player_units[i]) end
end

local ASSISTABLE_STATES = {
	hogtied = true,
	knocked_down = true,
	ledge_hanging = true,
	netted = true,
}

local DISABLING_STATES = {
	consumed = true,
	grabbed = true,
	mutant_charged = true,
	pounced = true,
	vortex_grabbed = true,
	warp_grabbed = true,
}

local function _word_carries(player_unit, radius, t)
	_for_each_player_in_radius(player_unit, radius, function(unit)
		local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
		if buff_extension then
			buff_extension:add_internally_controlled_buff(
				"pilgrim_word_carries_guard", t, "owner_unit", player_unit)
		end

		local unit_data = ScriptUnit.has_extension(unit, "unit_data_system")
		local character_state = unit_data and unit_data:read_component("character_state")
		local state_name = character_state and character_state.state_name
		if ASSISTABLE_STATES[state_name] then
			local assisted = unit_data:write_component("assisted_state_input")
			assisted.force_assist = true
		elseif DISABLING_STATES[state_name] then
			local disabled = unit_data:write_component("disabled_state_input")
			disabled.disabling_unit = nil
		end
	end)
end

function M.install_shout_ability(ShoutAbility)
	if not _mod or ShoutAbility._pilgrimage_legendary_shouts then return end
	ShoutAbility._pilgrimage_legendary_shouts = true
	_mod:hook(ShoutAbility, "execute", function(func, radius, template_name,
		player_unit, t, locomotion_component, shout_direction, ...)
		local result = func(radius, template_name, player_unit, t,
			locomotion_component, shout_direction, ...)
		local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
		local stats = buff_extension and buff_extension:stat_buffs() or {}
		local effective_radius = radius * (stats.shout_radius_modifier or 1)

		if template_name == "veteran_shout"
			and _unit_has_buff(player_unit, "pilgrim_legendary_word_carries") then
			_word_carries(player_unit, effective_radius, t)
		end
		return result
	end)
end

local function _psyker_shriek(player_unit, kind, t)
	local ok_attack, Attack = pcall(require, "scripts/utilities/attack/attack")
	local ok_profiles, DamageProfiles = pcall(require,
		"scripts/settings/damage/damage_profile_templates")
	local ok_attack_settings, AttackSettings = pcall(require,
		"scripts/settings/damage/attack_settings")
	local ok_damage_settings, DamageSettings = pcall(require,
		"scripts/settings/damage/damage_settings")
	local ok_warp, WarpCharge = pcall(require, "scripts/utilities/warp_charge")
	if not (ok_attack and ok_profiles and ok_attack_settings and ok_damage_settings and ok_warp) then
		return
	end

	local unit_data = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local warp_charge = unit_data and unit_data:write_component("warp_charge")
	local first_person = unit_data and unit_data:read_component("first_person")
	local origin = POSITION_LOOKUP[player_unit]
	if not warp_charge or not origin then return end
	local rotation = first_person and first_person.rotation or Unit.local_rotation(player_unit, 1)
	local forward = Vector3.normalize(Vector3.flat(Quaternion.forward(rotation)))

	local side_system = Managers.state.extension and Managers.state.extension:system("side_system")
	local side = side_system and side_system.side_by_unit[player_unit]
	local broadphase_system = Managers.state.extension and Managers.state.extension:system("broadphase_system")
	local broadphase = broadphase_system and broadphase_system.broadphase
	local num_hits = 0
	if side and broadphase then
		local results = {}
		local enemies = side:relation_side_names("enemy")
		local count = broadphase.query(broadphase, origin, 30, results, enemies)
		for i = 1, count do
			local target = results[i]
			local target_position = POSITION_LOOKUP[target]
			if HEALTH_ALIVE[target] and target_position then
				local offset = Vector3.flat(target_position - origin)
				local distance_sq = Vector3.length_squared(offset)
				local direction = distance_sq > 0 and Vector3.normalize(offset) or forward
				if distance_sq <= 81 or Vector3.dot(forward, direction) > 0.9 then
					num_hits = num_hits + 1
					Attack.execute(target, DamageProfiles.psyker_biomancer_shout,
						"attack_direction", direction,
						"power_level", 1000,
						"hit_zone_name", "torso",
						"damage_type", DamageSettings.damage_types.psyker_biomancer_discharge,
						"attack_type", AttackSettings.attack_types.shout,
						"attacking_unit", player_unit)

					if kind == "soulblaze" then
						local target_buffs = ScriptUnit.has_extension(target, "buff_system")
						if target_buffs then
							target_buffs:add_internally_controlled_buff_with_stacks(
								"warp_fire", 6, t, "owner_unit", player_unit)
						end
					end
				end
			end
		end
	end

	if kind == "soulblaze" then
		WarpCharge.decrease_immediate(0.10, warp_charge, player_unit)
	else
		WarpCharge.decrease_immediate(0.50, warp_charge, player_unit)
		local player_buffs = ScriptUnit.has_extension(player_unit, "buff_system")
		if player_buffs and num_hits > 0 then
			player_buffs:add_internally_controlled_buff_with_stacks(
				"psyker_shout_warp_generation_reduction", math.min(num_hits, 25), t,
				"parent_buff_template", "pilgrim_legendary_overwhelming_mind")
		end
	end

	local fx_extension = ScriptUnit.has_extension(player_unit, "fx_system")
	if fx_extension then
		-- The synthetic Overwhelming Mind casts do not pass through the
		-- predicted player action that normally plays the Shriek sound. Fire
		-- the same gear alias used by action_psyker_shout.lua and include the
		-- owning client because this helper itself only runs on the server.
		pcall(fx_extension.trigger_gear_wwise_event_with_source, fx_extension,
			"ability_shout", { ability_template = "psyker_shout" },
			"head", true, true)
		pcall(fx_extension.spawn_particles, fx_extension,
			"content/fx/particles/abilities/psyker_warp_charge_shout",
			origin + Vector3.up(), rotation)
	end
end

function M.install_overwhelming_mind_templates(templates)
	if type(templates) ~= "table" or templates._pilgrimage_overwhelming_mind then return end
	templates._pilgrimage_overwhelming_mind = true

	local stance = templates.psyker_overcharge_stance
	if stance and stance.stop_func then
		local old_stop = stance.stop_func
		stance.stop_func = function(data, context)
			local at_max = data.warp_charge_component
				and data.warp_charge_component.current_percentage >= 1
			local result = old_stop(data, context)
			if context.is_server and at_max
				and _unit_has_buff(context.unit, "pilgrim_legendary_overwhelming_mind") then
				local ok_fixed, FixedFrame = pcall(require, "scripts/utilities/fixed_frame")
				_psyker_shriek(context.unit, "soulblaze",
					ok_fixed and FixedFrame.get_latest_fixed_time() or 0)
			end
			return result
		end
	end

	local warp_unbound = templates.psyker_overcharge_stance_infinite_casting
	if warp_unbound then
		local old_stop = warp_unbound.stop_func
		warp_unbound.stop_func = function(data, context)
			local result = old_stop and old_stop(data, context)
			if context.is_server
				and _unit_has_buff(context.unit, "pilgrim_legendary_overwhelming_mind") then
				local ok_fixed, FixedFrame = pcall(require, "scripts/utilities/fixed_frame")
				_psyker_shriek(context.unit, "vent",
					ok_fixed and FixedFrame.get_latest_fixed_time() or 0)
			end
			return result
		end
	end
end

function M.install_brain_rupture_targeting(TargetingModule)
	if not _mod or TargetingModule._pilgrimage_unwarded_minds then return end
	TargetingModule._pilgrimage_unwarded_minds = true
	_mod:hook(TargetingModule, "fixed_update", function(func, self, ...)
		local result = func(self, ...)
		if _unit_has_buff(self._player_unit, "pilgrim_legendary_unwarded_minds") then
			local target = self._component and self._component.target_unit_1
			if target and _unit_is_boss(target) then
				self._component.target_unit_1 = nil
				self._component.target_unit_2 = nil
				self._component.target_unit_3 = nil
			end
		end
		return result
	end)
end

local function _attack_arg(name, ...)
	local count = select("#", ...)
	for i = 1, count, 2 do
		if select(i, ...) == name then return select(i + 1, ...) end
	end
	return nil
end

function M.install_legendary_attack(Attack)
	if not _mod or Attack._pilgrimage_legendary_attack then return end
	Attack._pilgrimage_legendary_attack = true
	_mod:hook(Attack, "execute", function(func, attacked_unit, damage_profile, ...)
		local damage_type = _attack_arg("damage_type", ...)
		local attacking_unit = _attack_arg("attacking_unit", ...)
		if damage_type == "smite"
			and _unit_has_buff(attacking_unit, "pilgrim_legendary_unwarded_minds") then
			if _unit_is_boss(attacked_unit) then
				return 0, "blocked", "negated", "no_stagger", false
			end
			local count = select("#", ...)
			local args = { ... }
			args[count + 1] = "instakill"
			args[count + 2] = true
				return func(attacked_unit, damage_profile, unpack(args, 1, count + 2))
			end

		local repeat_shadow = _shared and _shared.is_server
			and _shared.is_server()
			and _shadow_attack_should_repeat(attacking_unit, damage_type)
		local damage, attack_result, efficiency, stagger_result, weakspot =
			func(attacked_unit, damage_profile, ...)
		if repeat_shadow and type(damage) == "number" and damage > 0 then
			local now = _shared.fixed_time and _shared.fixed_time() or 0
			_shadow_replays[#_shadow_replays + 1] = {
				at = now + 1,
				target = attacked_unit,
				source = attacking_unit,
				damage = damage,
			}
		end
		return damage, attack_result, efficiency, stagger_result, weakspot
	end)
end

-- Elemental Affinity and Afflictor both need the actual target at damage time.
-- Elemental Affinity preserves its OR rule, while Afflictor counts distinct
-- current debuff categories rather than stacks. Applying the modifier after
-- Darktide's calculation gives the exact advertised 80/95/110/125/140% curve.
function M.install_family_damage_calculation(DamageCalculation)
	if not _mod or DamageCalculation._pilgrimage_family_damage then return end
	DamageCalculation._pilgrimage_family_damage = true
	local ok_settings, BuffSettings = pcall(require,
		"scripts/settings/buff/buff_settings")
	local keywords = ok_settings and BuffSettings and BuffSettings.keywords or {}
	local compact_tokens = {}
	local keyword_names = {
		"burning", "warpfire_burning", "electrocuted",
		"electrocuted_chain_lightning", "electrocuted_arc",
		"electrocuted_arc_grenade", "electrocuted_arc_ability",
		"electrocuted_shock_mine",
	}
	for i = 1, #keyword_names do
		local token = keywords[keyword_names[i]]
		if token ~= nil then compact_tokens[#compact_tokens + 1] = token end
	end
	local afflictor_keyword_names = {
		{ "burning" },
		{ "warpfire_burning" },
		_electrocution_keyword_names,
		{ "bleeding" },
		{ "toxin" },
		{ "taunted" },
	}
	local afflictor_keyword_groups = {}
	for gi = 1, #afflictor_keyword_names do
		local group = {}
		for ni = 1, #afflictor_keyword_names[gi] do
			local token = keywords[afflictor_keyword_names[gi][ni]]
			if token ~= nil then group[#group + 1] = token end
		end
		if #group > 0 then afflictor_keyword_groups[#afflictor_keyword_groups + 1] = group end
	end

	local function attacker_has(extension, buff_name)
		if not extension
			or type(extension.has_buff_using_buff_template) ~= "function" then return false end
		local ok, has = pcall(extension.has_buff_using_buff_template,
			extension, buff_name)
		return ok and has == true
	end

	local function afflictor_count(target_extension, target_stat_buffs)
		local count = 0
		for i = 1, #afflictor_keyword_groups do
			if _extension_has_current_keyword(target_extension,
				afflictor_keyword_groups[i]) then
				count = count + 1
				if count >= 4 then return 4 end
			end
		end
		target_stat_buffs = target_stat_buffs or {}
		-- Brittleness is a target-side rending stat rather than a keyword.
		if (tonumber(target_stat_buffs.rending_multiplier) or 1) > 1 then
			count = count + 1
			if count >= 4 then return 4 end
		end
		-- Direct vulnerability effects share the damage-taken buckets. Treat
		-- them as one Exposed category even if several effects supply it.
		if (tonumber(target_stat_buffs.damage_taken_modifier) or 1) > 1
			or (tonumber(target_stat_buffs.damage_taken_multiplier) or 1) > 1 then
			count = count + 1
		end
		return math.min(count, 4)
	end

	_mod:hook(DamageCalculation, "calculate", function(func, ...)
		local damage, efficiency, base_damage, base_buff_damage, rending_damage,
			finesse_damage, backstab_damage, flanking_damage, armor_modifier,
			hit_zone_multiplier = func(...)
		local attacker_extension = select(20, ...)
		local target_extension = select(21, ...)
		if attacker_has(attacker_extension, "pilgrim_family_elemental_affinity")
			and type(damage) == "number" and damage > 0
			and _extension_has_current_keyword(target_extension, compact_tokens) then
			damage = damage * 1.10
		end
		if attacker_has(attacker_extension, "pilgrim_arch_afflictor")
			and type(damage) == "number" and damage > 0 then
			local target_stat_buffs = select(19, ...)
			local categories = afflictor_count(target_extension, target_stat_buffs)
			damage = damage * (0.80 + 0.15 * categories)
		end
		return damage, efficiency, base_damage, base_buff_damage, rending_damage,
			finesse_damage, backstab_damage, flanking_damage, armor_modifier,
			hit_zone_multiplier
	end)
end

-- Compatibility name for older entry files during a hot reload. A full restart
-- uses install_legendary_attack directly.
M.install_brain_rupture_attack = M.install_legendary_attack

local SPECIAL_DELIVERY_PROJECTILE = "pilgrim_special_delivery_bomblet"
local _special_delivery_projectile

local function _append_network_lookup(lookup, name)
	-- NetworkLookup's metatable deliberately errors on a missing string key,
	-- so existence checks must bypass it with rawget.
	if type(lookup) ~= "table" or rawget(lookup, name) ~= nil then return end
	local id = #lookup + 1
	lookup[id] = name
	lookup[name] = id
end

-- Builds one networked projectile that borrows the game's own true-flight
-- steering, grenade model and Big Box impact profile. Only the profile's
-- attack power is scaled, so every armour modifier and breed override from
-- the original impact remains intact at exactly 70% raw damage.
function M.prepare_special_delivery()
	if _special_delivery_projectile then return true end
	local ok_dp, DamageProfiles = pcall(require,
		"scripts/settings/damage/damage_profile_templates")
	local ok_tf, TrueFlight = pcall(require,
		"scripts/settings/projectile/true_flight_templates")
	local ok_loco, Locomotion = pcall(require,
		"scripts/settings/projectile_locomotion/projectile_locomotion_templates")
	local ok_projectiles, Projectiles = pcall(require,
		"scripts/settings/projectile/projectile_templates")
	local ok_lookup, NetworkLookupTable = pcall(require,
		"scripts/network_lookup/network_lookup")
	if not (ok_dp and ok_tf and ok_loco and ok_projectiles and ok_lookup) then
		return false
	end

	local damage_name = "pilgrim_special_delivery_impact"
	local damage_profile = DamageProfiles[damage_name]
	if not damage_profile then
		damage_profile = table.clone(DamageProfiles.ogryn_grenade_box_cluster_impact)
		damage_profile.name = damage_name
		damage_profile.power_distribution = table.clone(damage_profile.power_distribution)
		damage_profile.power_distribution.attack =
			damage_profile.power_distribution.attack * 0.70
		DamageProfiles[damage_name] = damage_profile
	end
	_append_network_lookup(NetworkLookupTable.damage_profile_templates, damage_name)

	local true_flight_name = "pilgrim_special_delivery"
	local true_flight = TrueFlight[true_flight_name]
	if not true_flight then
		true_flight = table.clone(TrueFlight.throwing_knives_aimed)
		true_flight.broadphase_radius = 20
		true_flight.allowed_bounces = 0
		true_flight.true_flight_shard_impact_behaviour = false
		true_flight.on_impact_function = nil
		TrueFlight[true_flight_name] = true_flight
	end

	local locomotion_name = "pilgrim_special_delivery"
	local locomotion = Locomotion[locomotion_name]
	if not locomotion then
		locomotion = table.clone(Locomotion.psyker_throwing_knife_projectile_aimed)
		locomotion.name = locomotion_name
		locomotion.integrator_parameters = table.clone(locomotion.integrator_parameters)
		locomotion.integrator_parameters.true_flight_template = true_flight
		locomotion.integrator_parameters.collision_filter =
			"filter_player_character_shooting_projectile"
		Locomotion[locomotion_name] = locomotion
	end

	local source = Projectiles.ogryn_grenade_box_cluster_grenade
	if not source then return false end
	local projectile = Projectiles[SPECIAL_DELIVERY_PROJECTILE]
	if not projectile then
		projectile = table.clone(source)
		projectile.name = SPECIAL_DELIVERY_PROJECTILE
		projectile.locomotion_template = locomotion
		projectile.damage = table.clone(projectile.damage)
		projectile.damage.impact = {
			delete_on_impact = true,
			delete_on_hit_mass = true,
			damage_profile = damage_profile,
			damage_type = "ogryn_grenade_box",
		}
		Projectiles[SPECIAL_DELIVERY_PROJECTILE] = projectile
	end
	_append_network_lookup(NetworkLookupTable.projectile_template_names,
		SPECIAL_DELIVERY_PROJECTILE)
	_special_delivery_projectile = projectile
	return true
end

local function _spawn_special_delivery_cluster(extension, direction)
	local source_name = extension._projectile_template
		and extension._projectile_template.name
	if source_name ~= "ogryn_grenade_box_cluster" then return false end
	if not M.prepare_special_delivery() then return false end
	local ok_master, MasterItems = pcall(require, "scripts/backend/master_items")
	local ok_loco_settings, LocomotionSettings = pcall(require,
		"scripts/settings/projectile_locomotion/projectile_locomotion_settings")
	if not (ok_master and ok_loco_settings) then return false end

	local owner_unit = extension._owner_unit
	if not _unit_has_buff(owner_unit, "pilgrim_legendary_special_delivery") then
		return false
	end

	local _, position = extension._locomotion_extension:previous_and_current_positions()
	local item = MasterItems.get_cached()[_special_delivery_projectile.item_name]
	if not position or not item then return false end
	local check_vector = Vector3.dot(direction, Vector3.right()) < 1
		and Vector3.right() or Vector3.forward()
	local start_axis = Vector3.cross(direction, check_vector)
	local random_start_rotation = math.pi * 2 * math.random()
	local angle_distribution = math.pi * 2 / 6
	local starting_state = LocomotionSettings.states.true_flight

	for i = 1, 6 do
		local angle = angle_distribution * i + random_start_rotation
		local rotation = Quaternion.axis_angle(direction, angle)
		local flat_direction = Quaternion.rotate(rotation, start_axis)
		local launch_direction = Vector3.normalize(Vector3.lerp(flat_direction, direction, 0.35))
		Managers.state.unit_spawner:spawn_network_unit(nil, "item_projectile",
			position, rotation, nil, item, _special_delivery_projectile,
			starting_state, launch_direction, 24, Vector3.zero(), owner_unit,
			false, extension._origin_item_slot, nil, nil, nil,
			extension._weapon_item_or_nil, 5, extension._owner_side_or_nil)
	end

	if extension._fx_extension then extension._fx_extension:on_cluster() end
	return true
end

function M.install_special_delivery_projectiles(ProjectileDamageExtension)
	if not _mod or ProjectileDamageExtension._pilgrimage_special_delivery then return end
	ProjectileDamageExtension._pilgrimage_special_delivery = true
	_mod:hook(ProjectileDamageExtension, "_spawn_cluster",
		function(func, self, cluster_settings, direction)
			if _spawn_special_delivery_cluster(self, direction) then return end
			return func(self, cluster_settings, direction)
		end)
end

-- ===========================================================================
-- v0.24.0 (Boons v2 phase 1): ARCHETYPES.
-- ===========================================================================
--
-- Design session with Kaizen, 2026-08-11 night. An Archetype is a run
-- identity: one big on-style effect, one off-style cost, and a HARD
-- draft filter. v0.28.12 maps explicit functional compatibility tags
-- over the game's family groupings, and never backfills an incompatible
-- boon when the on-theme pool runs low. There is still a small
-- seeded chance for a legendary to leak into any draft (phase 2 gates
-- the leak on the Legendary slot being empty).
--
-- Slot model (Kaizen): a DEDICATED Archetype slot in the Boon Loadout,
-- unlocked by the archetype_slot Emporium purchase, chosen between
-- runs, LOCKED AT RUN START like Blitz mode and the War Plan (the
-- run's identity cannot switch underfoot; the draft filter and the
-- stat package must agree for the whole road).
--
-- Effects use the exact custom-boon template machinery the Doctrines
-- field-proved. Every stat verified against buff_settings.lua:
--   toughness_bonus (additive), toughness_damage_taken_modifier
--   (additive), melee/ranged_damage (additive bucket),
--   melee_damage_taken_modifier (additive), critical_strike_chance
--   (value, +0.10 = +10pp), damage_vs_burning (additive),
--   toughness_replenish_modifier (additive, ALL replenish sources),
--   combat_ability_cooldown_modifier (additive, Redline-proven),
--   grenade_ability_cooldown_modifier (additive; ability extension
--   line 786 scales BLITZ CHARGE REGENERATION with it, and a blitz
--   with no natural regen has no cooldown running, so it is
--   inherently "if applicable", exactly Kaizen's ask; Psyker's own
--   talent tree uses -0.3 on this stat).
-- All numbers flagged for the economy/tuning pass.

M.ARCHETYPES = {
	{
		id          = "pilgrim_arch_goliath",
		name        = "Goliath",
		description = "+25% melee power, +50% impact, +35% cleave. -10% speed, -30% ranged damage.",
		short       = "heavy blows, poor shot",
		families    = { "unstoppable" },
		buff_template = "pilgrim_arch_goliath",
		custom = {
			stat_buffs = {
				melee_power_level_modifier = 0.25,
				melee_impact_modifier = 0.50,
				max_melee_hit_mass_attack_modifier = 0.35,
				melee_attack_speed = -0.10,
				ranged_damage = -0.30,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_toughness_increase",
		},
	},
	{
		id          = "pilgrim_arch_gunslinger",
		name        = "Gunslinger",
		description = "+20% ranged damage; +10% crit. -25% melee damage; +20% melee damage taken.",
		short       = "deadeye, soft up close",
		families    = { "cowboy", "critical" },
		buff_template = "pilgrim_arch_gunslinger",
		custom = {
			stat_buffs = {
				ranged_damage = 0.2,
				critical_strike_chance = 0.10,
				melee_damage = -0.25,
				melee_damage_taken_modifier = 0.2,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_big_weakspot_damage_increase",
		},
	},
	{
		id          = "pilgrim_arch_pyromancer",
		name        = "Pyromancer",
		description = "+40% damage vs burning enemies; -25% toughness replenishment.",
		short       = "burn them all",
		-- v0.28.11: Fire now has a healthy standalone pool. Keeping the
		-- entire Fatshark Elementalist family here could offer pure shock
		-- cards such as shock-on-melee-hit, contradicting Pyromancer's
		-- identity. Independently usable cross-element cards are admitted by
		-- explicit tags; two-element requirements belong to Afflictor.
		families    = { "fire" },
		buff_template = "pilgrim_arch_pyromancer",
		custom = {
			stat_buffs = {
				damage_vs_burning = 0.4,
				toughness_replenish_modifier = -0.25,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_on_melee_hit",
		},
	},
	{
		id          = "pilgrim_arch_stormcaller",
		-- v0.24.1 (Kaizen): renamed from Stormcaller; the name should
		-- carry BOTH the electricity and the cooldown identity. Dynamo:
		-- a machine that never stops generating. Internal id kept so
		-- any stored selection survives the rename.
		name        = "Dynamo",
		description = "-25% ability and blitz cooldowns; -15% damage.",
		short       = "ability spam, lower damage",
		-- Matching Pyromancer's purity pass: Dynamo owns Electric, while
		-- compatible mixed cards are shared explicitly with Afflictor.
		families    = { "electric" },
		buff_template = "pilgrim_arch_stormcaller",
		custom = {
			stat_buffs = {
				combat_ability_cooldown_modifier = -0.25,
				grenade_ability_cooldown_modifier = -0.25,
				damage = -0.15,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/big_buffs/hordes_buff_extra_ability_charge",
		},
	},
	{
		id          = "pilgrim_arch_afflictor",
		name        = "Afflictor",
		description = "-20% damage to clean targets; +15% per different debuff (max 4).",
		short       = "layer debuffs for damage",
		-- Afflictor is assembled from explicit compatibility tags across
		-- several families. `families` remains presentation metadata; the
		-- draft filter uses `draft_tags` when it exists.
		families    = { "elementalist" },
		draft_tags  = { "debuff" },
		buff_template = "pilgrim_arch_afflictor",
		custom = {
			-- The target-dependent damage curve is applied by the narrow
			-- DamageCalculation hook. This empty template is the synchronized
			-- marker which tells that hook the Archetype is active.
			stat_buffs = {},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_burning_damage_per_burning_enemy",
		},
	},
	{
		id          = "pilgrim_arch_bulwark",
		name        = "Bulwark",
		description = "+3 stamina, -40% block cost, +50% push impact, +20% toughness. -15% attack speed",
		short       = "block, push, endure",
		families    = { "unkillable" },
		unlock_penance = "pilgrim_arch_bulwark_proof",
		buff_template = "pilgrim_arch_bulwark",
		custom = {
			stat_buffs = {
				stamina_modifier = 3,
				block_cost_multiplier = 0.6,
				push_impact_modifier = 0.50,
				toughness_bonus = 0.20,
				attack_speed = -0.15,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/states_grace_time_hud",
		},
	},
	{
		id          = "pilgrim_arch_executioner",
		name        = "Executioner",
		description = "+18% melee crit chance and +40% crit damage. No ranged weapon; -10 toughness.",
		short       = "melee crits, no ranged",
		-- Critical + Unstoppable remain the identity shown to the player.
		-- Drafting uses a narrower compatibility tag so a melee-only run
		-- never receives ranged-critical or cross-slot cards it cannot use.
		families    = { "critical", "unstoppable" },
		draft_tags  = { "executioner" },
		buff_template = "pilgrim_arch_executioner",
		custom = {
			stat_buffs = {
				melee_critical_strike_chance = 0.18,
				melee_critical_strike_damage = 0.40,
				toughness_bonus_flat = -10,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/horde_buffs/small_buffs/hordes_buff_stacking_crit_damage_on_critical_hit",
		},
	},
	{
		id          = "pilgrim_arch_skirmisher",
		name        = "Skirmisher",
		description = "+10% move speed; longer dodge window; +1 dodge; reload while sprinting. -35% toughness recovery; -10% health.",
		short       = "mobile gunfighter, fragile recovery",
		families    = { "cowboy", "unstoppable" },
		unlock_penance = "pilgrim_arch_skirmisher_proof",
		buff_template = "pilgrim_arch_skirmisher",
		custom = {
			stat_buffs = {
				movement_speed = 0.10,
				dodge_linger_time_modifier = 0.30,
				extra_consecutive_dodges = 1,
				reload_decrease_movement_reduction = 0,
				toughness_replenish_modifier = -0.35,
				max_health_multiplier = 0.90,
			},
			hud_icon = "content/ui/textures/icons/buffs/hud/states_sprint_buff_hud",
		},
	},
}

-- _archetype_by_id is forward-declared next to the pool caches (M.draft
-- closes over it); filled here where the catalogue exists.
for i = 1, #M.ARCHETYPES do _archetype_by_id[M.ARCHETYPES[i].id] = M.ARCHETYPES[i] end

function M.archetype_get(id) return _archetype_by_id[id] end
function M.archetype_all() return M.ARCHETYPES end

-- Storage. Selection is the between-runs choice; the run stamp is what
-- the active run locked in (set by bootstrap's begin, survives game
-- restarts mid-run because it lives in settings like the run itself).
local KEY_ARCHETYPE_SELECTED = "_archetype_selected"
local KEY_ARCHETYPE_RUN      = "_archetype_run"
local KEY_TEST_UNLOCKS       = "_test_unlocks"

function M.test_unlocks_enabled()
	return _mod ~= nil and _mod:get(KEY_TEST_UNLOCKS) == true
end

-- A read-time override, deliberately separate from real ownership and earned
-- unlock storage. Switching it off restores the exact progression state that
-- existed before testing.
function M.set_test_unlocks(enabled)
	if not _mod then return false, "mod unavailable" end
	if _run_state and _run_state.is_active and _run_state.is_active() then
		return false, "finish or abandon the pilgrimage first"
	end
	_mod:set(KEY_TEST_UNLOCKS, enabled == true, false)
	M.reset_pool()
	return true
end

function M.archetype_is_unlocked(id)
	local archetype = _archetype_by_id[id]
	if not archetype then return false end
	return archetype.unlock_penance == nil or M.test_unlocks_enabled()
end

function M.selected_archetype_id()
	local v = _mod and _mod:get(KEY_ARCHETYPE_SELECTED)
	if type(v) ~= "string" or v == "" then return nil end
	return M.archetype_is_unlocked(v) and v or nil
end

function M.set_selected_archetype(id)
	if not _mod then return false end
	-- v0.24.1: same mid-run lock as Doctrine slotting. The run's own
	-- archetype was never switchable (the stamp is what applies), but
	-- editing the next run's pick mid-run reads as a loophole next to
	-- the loadout lock, so the whole tab freezes together.
	if _run_state and _run_state.is_active and _run_state.is_active() then
		return false, "loadout locked during a pilgrimage"
	end
	if id ~= nil and not _archetype_by_id[id] then return false, "unknown archetype" end
	if id ~= nil and not M.archetype_is_unlocked(id) then
		return false, "archetype not unlocked"
	end
	_mod:set(KEY_ARCHETYPE_SELECTED, id or "", false)
	return true
end

-- The Emporium unlock that opens the Archetype slot at all.
function M.archetype_slot_unlocked()
	if M.test_unlocks_enabled() then return true end
	return _shop ~= nil and _shop.is_unlocked ~= nil
		and _shop.is_unlocked("archetype_slot") == true
end

-- Called by bootstrap's begin() for NEW runs only: locks the current
-- selection in for the whole run. An empty stamp means "no archetype",
-- deliberately distinct from "stale stamp from an older run" because
-- reads are gated on run activity.
function M.stamp_archetype_for_run()
	if not _mod then return end
	local id = M.archetype_slot_unlocked() and M.selected_archetype_id() or nil
	_mod:set(KEY_ARCHETYPE_RUN, id or "", false)
end

-- The archetype governing the CURRENT run, or nil. Gated on run
-- activity so a leftover stamp from a finished run never filters a
-- preview draft or applies a stat package in the hub.
function M.active_archetype_id()
	if not (_run_state and _run_state.is_active and _run_state.is_active()) then
		return nil
	end
	local v = _mod and _mod:get(KEY_ARCHETYPE_RUN)
	if type(v) ~= "string" or v == "" then return nil end
	return _archetype_by_id[v] and v or nil
end

-- Marker read by the Blood Debt heal-halving hook in Pilgrimage.lua.
M._blood_debt_self_heal = false

local function _load_csv(key)
	local raw = _mod and _mod:get(key)
	local out = {}
	if type(raw) ~= "string" or raw == "" then return out end
	for id in string.gmatch(raw, "([^,]+)") do
		if _custom_by_id[id] then out[#out + 1] = id end
	end
	return out
end

local function _store_csv(key, list)
	if not _mod then return end
	_mod:set(key, table.concat(list, ","), false)
end

local function _contains(list, id)
	for i = 1, #list do if list[i] == id then return i end end
	return nil
end

function M.owned_ids() return _load_csv(KEY_BOON_OWNED) end
function M.is_owned(id)
	local boon = _custom_by_id[id]
	if M.test_unlocks_enabled() and boon and not boon.legendary then return true end
	return _contains(M.owned_ids(), id) ~= nil
end

-- ---------------------------------------------------------------------------
-- v0.22.82: slot-map model (Kaizen's field feedback: "it should mimick
-- the slot system that party has"). Bindings are per-slot ("1:id,2:id"
-- encoding, same shape as the party preset slots), replacing the
-- v0.22.81 order-less csv list. One boon per slot, one slot per boon.
-- ---------------------------------------------------------------------------

local KEY_BOON_SLOTMAP = "_boon_loadout_slotmap"
local BOON_MAX_SLOTS = 4

local function _load_slot_map()
	local out = {}
	local raw = _mod and _mod:get(KEY_BOON_SLOTMAP)
	if type(raw) == "string" and raw ~= "" then
		for entry in string.gmatch(raw, "([^,]+)") do
			local slot_str, id = string.match(entry, "^(%d+):(.+)$")
			if slot_str and id and _custom_by_id[id] and not _custom_by_id[id].legendary then
				out[tonumber(slot_str)] = id
			end
		end
		return out
	end
	-- One-time migration from the v0.22.81 order-less list: assign the
	-- old slotted boons to slots in order, persist the map, clear the
	-- old key so this branch never runs again.
	local old = _load_csv(KEY_BOON_SLOTTED)
	if #old > 0 and _mod then
		local slot = 1
		for i = 1, #old do
			local boon = _custom_by_id[old[i]]
			if boon and not boon.legendary and slot <= BOON_MAX_SLOTS then
				out[slot] = old[i]
				slot = slot + 1
			end
		end
		local parts = {}
		for slot, id in pairs(out) do parts[#parts + 1] = tostring(slot) .. ":" .. id end
		table.sort(parts)
		_mod:set(KEY_BOON_SLOTMAP, table.concat(parts, ","), false)
		_mod:set(KEY_BOON_SLOTTED, "", false)
	end
	return out
end

local function _store_slot_map(map)
	if not _mod then return end
	local parts = {}
	for slot, id in pairs(map) do
		parts[#parts + 1] = tostring(slot) .. ":" .. id
	end
	table.sort(parts)
	_mod:set(KEY_BOON_SLOTMAP, table.concat(parts, ","), false)
end

function M.slot_map() return _load_slot_map() end
function M.binding_for_boon_slot(slot) return _load_slot_map()[tonumber(slot)] end

-- Which slot (if any) a boon currently occupies.
function M.slot_of(id)
	for slot, bound in pairs(_load_slot_map()) do
		if bound == id then return slot end
	end
	return nil
end

-- Bind a boon to a specific loadout slot, or clear it (id = nil).
-- Validation: the slot must be unlocked, the boon owned, and not
-- already bound to a DIFFERENT slot (re-binding to its own slot is a
-- no-op success, matching the party picker's semantics).
function M.bind_boon_slot(slot, id)
	-- v0.24.1 (Kaizen exploit report): the LOADOUT IS LOCKED while a
	-- pilgrimage is under way. Field-found exploit: de-slot The House
	-- Always Wins between legs, buy at normal prices, re-slot before
	-- the next mission and keep the doubled pickups. Slotting is a
	-- pre-run decision, exactly like the Archetype and the War Plan.
	if _run_state and _run_state.is_active and _run_state.is_active() then
		return false, "loadout locked during a pilgrimage"
	end
	slot = tonumber(slot)
	if not slot or slot < 1 or slot > BOON_MAX_SLOTS then return false, "invalid slot" end
	local map = _load_slot_map()
	if id == nil then
		map[slot] = nil
		_store_slot_map(map)
		return true, "cleared"
	end
	if not _custom_by_id[id] or _custom_by_id[id].legendary then
		return false, "not a Doctrine"
	end
	if slot > M.loadout_slots() then return false, "slot locked" end
	if not M.is_owned(id) then return false, "not owned" end
	local at = M.slot_of(id)
	if at and at ~= slot then
		return false, string.format("already in slot %d", at)
	end
	map[slot] = id
	_store_slot_map(map)
	return true, "slotted"
end

-- Flat list of slotted boon ids (active-slot range only), for the
-- apply path and state checks.
function M.slotted_ids()
	local out = {}
	local limit = M.loadout_slots()
	local map = _load_slot_map()
	for slot = 1, limit do
		if map[slot] then out[#out + 1] = map[slot] end
	end
	return out
end

function M.is_slotted(id) return _contains(M.slotted_ids(), id) ~= nil end

-- 1 base + Emporium expansions (boon_slot_2/3). Slot 4 reserved for a
-- future penance. Cap 4 per the locked decision.
function M.loadout_slots()
	if M.test_unlocks_enabled() then return BOON_MAX_SLOTS end
	local slots = 1
	if _shop and _shop.is_unlocked then
		if _shop.is_unlocked("boon_slot_2") then slots = slots + 1 end
		if _shop.is_unlocked("boon_slot_3") then slots = slots + 1 end
	end
	if slots > 4 then slots = 4 end
	return slots
end

-- Purchase a custom boon into the permanent library.
function M.buy_custom(id)
	local boon = _custom_by_id[id]
	if not boon then return false, "unknown boon" end
	if boon.legendary then return false, "earned as a Legendary" end
	if M.is_owned(id) then return false, "already owned" end
	if not _wallet or not _wallet.spend then return false, "wallet unavailable" end
	if not _wallet.spend(boon.cost or 0, "boon:" .. id) then
		return false, "not enough Ordos"
	end
	local owned = M.owned_ids()
	owned[#owned + 1] = id
	_store_csv(KEY_BOON_OWNED, owned)
	if _event_log and _event_log.emit then
		_event_log.emit({
			t = _shared.fixed_time(), event = "boon_purchased",
			id = _event_log.next_id(), boon = id, cost = boon.cost or 0,
		})
	end
	return true
end

-- v0.22.82: toggle_slot (v0.22.81's order-less API) removed; the
-- slot-map model above (bind_boon_slot / binding_for_boon_slot) is the
-- only mutation surface, matching the party preset slots.

-- True when a no-buff state boon (House Always Wins) is in force:
-- owned, slotted, and a run is active. wallet.lua and shop.lua read
-- this for their respective effects.
function M.custom_boon_active(id)
	-- Promoted entries keep this compatibility surface so older feature
	-- hooks (notably Unlimited Power's channel flag) follow the legendary
	-- run stamp without pretending the boon is still a Doctrine.
	if _pilgrim_legendary_by_template[id] then
		return M.active_legendary and M.active_legendary() == id or false
	end
	if not M.is_slotted(id) or not M.is_owned(id) then return false end
	return _run_state and _run_state.is_active() or false
end

-- v0.22.85: the equipped blitz, read off the unit's visual loadout.
-- weapon_template_from_slot returns the weapon template whose .name is
-- the template key ("psyker_smite" / "psyker_biomancer_smite" etc,
-- weapon_templates.lua line 19: template_data.name = template_name).
-- nil when the extension or slot isn't readable yet; callers treat nil
-- as "not the required blitz" and rely on the reconciler tick to retry
-- once the loadout has finished resolving.
function M.blitz_template_name(player_unit)
	if not player_unit then return nil end
	local ok, ext = pcall(ScriptUnit.extension, player_unit, "visual_loadout_system")
	if not ok or not ext or type(ext.weapon_template_from_slot) ~= "function" then
		return nil
	end
	local ok2, template = pcall(ext.weapon_template_from_slot, ext, "slot_grenade_ability")
	if not ok2 or type(template) ~= "table" then return nil end
	return template.name
end

-- Called from apply_all (via the M table, so definition order doesn't
-- matter): grant every slotted, owned, buff-backed custom boon at
-- spawn, after the drafted run boons. Class-gated boons (Unlimited
-- Power) skip silently when the player's archetype doesn't match, so a
-- Veteran with it slotted isn't handed a pure -90% curse. v0.22.85:
-- boons with requires_blitz additionally need that weapon template in
-- the blitz slot (Kaizen: "active only if smite is in the talent
-- tree"); grant() dedupes, so re-running this from the reconciler is
-- free for boons already applied.
-- ===========================================================================
-- v0.25.0 (Boons v2 phase 2): THE LEGENDARY SLOT.
-- ===========================================================================
--
-- Kaizen's design, locked 2026-08-11/12: a dedicated Legendary slot in
-- the Boon Loadout, filled PRE-RUN from legendaries the player has
-- UNLOCKED. Unlocking is earned on the road: drafting a legendary
-- through the leak, then FINISHING THAT LEG successfully, on a plan of
-- Penitent or higher (Novitiate runs never unlock; too cheap). The
-- leak itself only fires while no legendary is active, so the slot and
-- the leak never double up.
--
-- Storage:
--   _legendary_unlocked  csv of permanently unlocked buff names
--   _legendary_pending   csv of names drafted this run, awaiting the
--                        leg-completion promotion (cleared at run start)
--   _legendary_slot      the between-runs selection
--   _legendary_run       the stamp locked in at run start
local KEY_LEGENDARY_UNLOCKED = "_legendary_unlocked"
local KEY_LEGENDARY_PENDING  = "_legendary_pending"
local KEY_LEGENDARY_SLOT     = "_legendary_slot"
local KEY_LEGENDARY_RUN      = "_legendary_run"

-- The shared _load_csv validates against _custom_by_id (Doctrine ids),
-- which would silently drop every legendary name on load (found by the
-- harness: pending stored fine, promotion read back an empty list).
-- Legendaries are GAME buff names, so validation here is the hordes
-- prefix, the same rule build_pool's _append applies.
local function _legendary_csv_load(key)
	local raw = _mod and _mod:get(key)
	local out = {}
	if type(raw) ~= "string" or raw == "" then return out end
	for id in string.gmatch(raw, "([^,]+)") do
		if id:sub(1, 12) == "hordes_buff_" or _pilgrim_legendary_by_template[id] then
			out[#out + 1] = id
		end
	end
	return out
end

function M.all_legendary_names()
	local out, seen = {}, {}
	local function walk(value)
		if type(value) == "string" then
			if value:sub(1, 12) == "hordes_buff_" and not seen[value] then
				seen[value] = true
				out[#out + 1] = value
			end
		elseif type(value) == "table" then
			for _, child in pairs(value) do walk(child) end
		end
	end
	local allowed = _allowed_buffs()
	if allowed then walk(allowed.legendary_buffs) end
	for i = 1, #(M.LEGENDARIES or {}) do
		local name = M.LEGENDARIES[i].buff_template
		if name and not seen[name] then
			seen[name] = true
			out[#out + 1] = name
		end
	end
	table.sort(out)
	return out
end

-- Only combat-ability, blitz-specific, talent-specific, and Pilgrimage
-- custom Legendaries belong in the pre-run slot picker. Generic jackpot
-- buffs deliberately stay out even though they remain rare draft drops.
function M.loadout_legendary_names()
	_ensure_legendary_roles()
	local out = {}
	for name in pairs(_loadout_legendary_set) do out[#out + 1] = name end
	table.sort(out)
	return out
end

function M.legendary_unlocked_ids()
	local persisted = _legendary_csv_load(KEY_LEGENDARY_UNLOCKED)
	local out, seen = {}, {}
	for i = 1, #persisted do
		local name = persisted[i]
		if M.is_loadout_legendary(name) and not seen[name] then
			seen[name] = true
			out[#out + 1] = name
		end
	end
	if not M.test_unlocks_enabled() then return out end
	local all = M.loadout_legendary_names()
	for i = 1, #all do
		if not seen[all[i]] then out[#out + 1] = all[i] end
	end
	return out
end

function M.is_legendary_unlocked(name)
	local ids = M.legendary_unlocked_ids()
	for i = 1, #ids do if ids[i] == name then return true end end
	return false
end

function M.legendary_slot()
	local v = _mod and _mod:get(KEY_LEGENDARY_SLOT)
	if type(v) ~= "string" or v == "" then return nil end
	return M.is_loadout_legendary(v) and M.is_legendary_unlocked(v) and v or nil
end

function M.set_legendary_slot(name)
	if not _mod then return false end
	-- Same mid-run lock as the rest of the loadout.
	if _run_state and _run_state.is_active and _run_state.is_active() then
		return false, "loadout locked during a pilgrimage"
	end
	if name ~= nil and not M.is_legendary_unlocked(name) then
		return false, "not unlocked"
	end
	if name ~= nil and not M.is_loadout_legendary(name) then
		return false, "not eligible for the Legendary loadout"
	end
	_mod:set(KEY_LEGENDARY_SLOT, name or "", false)
	return true
end

-- The legendary locked into the CURRENT run, or nil. Same gating shape
-- as active_archetype_id.
function M.active_legendary()
	if not (_run_state and _run_state.is_active and _run_state.is_active()) then
		return nil
	end
	local v = _mod and _mod:get(KEY_LEGENDARY_RUN)
	if type(v) ~= "string" or v == "" then return nil end
	-- A save made by an older build may have stamped a now-retired
	-- generic Legendary. Keep the string for rollback compatibility,
	-- but never apply it through the loadout under the new rules.
	return M.is_loadout_legendary(v) and v or nil
end

-- Run-start bookkeeping, called by bootstrap's begin for NEW runs:
-- stamp the archetype AND the legendary, and clear any pending unlocks
-- left by an abandoned or failed earlier run (pending may only promote
-- inside the run that earned it).
function M.on_run_begin()
	M.stamp_archetype_for_run()
	if _mod then
		local slot = M.legendary_slot()
		_mod:set(KEY_LEGENDARY_RUN, slot or "", false)
		_mod:set(KEY_LEGENDARY_PENDING, "", false)
	end
end

-- Called by chain when a leg completes SUCCESSFULLY. Promotes every
-- pending legendary to the permanent collection, gated on the run's
-- plan being Penitent or higher (Kaizen: Novitiate is too cheap a road
-- to earn a legendary on). On Novitiate the pending list survives
-- untouched; it simply never promotes and dies at the next run start.
-- Records a drafted legendary as pending-unlock. Defined HERE, after
-- the csv helpers, and called from M.choose through the module table
-- (choose sits earlier in the file, where the helpers are not yet in
-- scope; a direct reference there would compile as a nil global).
function M.record_pending_legendary(name)
	if not _mod or type(name) ~= "string" then return false end
	-- Rare generic Legendaries are rewards for this run, not permanent
	-- loadout unlocks. Only slot-eligible effects start an unlock clock.
	if not M.is_loadout_legendary(name) then return false end
	local pending = _legendary_csv_load(KEY_LEGENDARY_PENDING)
	for i = 1, #pending do if pending[i] == name then return true end end
	pending[#pending + 1] = name
	_store_csv(KEY_LEGENDARY_PENDING, pending)
	return true
end

function M.promote_pending_legendaries()
	if not _mod then return 0 end
	local pending = _legendary_csv_load(KEY_LEGENDARY_PENDING)
	if #pending == 0 then return 0 end
	local plan_id
	if _run_state and _run_state.get then
		local ok, state = pcall(_run_state.get)
		plan_id = ok and state and state.plan_id or nil
	end
	if plan_id == nil or plan_id == "novitiate" then return 0 end
	local unlocked = _legendary_csv_load(KEY_LEGENDARY_UNLOCKED)
	local have = {}
	for i = 1, #unlocked do have[unlocked[i]] = true end
	local promoted = 0
	for i = 1, #pending do
		local name = pending[i]
		if M.is_loadout_legendary(name) and not have[name] then
			unlocked[#unlocked + 1] = name
			have[name] = true
			promoted = promoted + 1
			local pretty = name
			local ok_i, info = pcall(M.info, name)
			if ok_i and info and info.title and info.title ~= "" then pretty = info.title end
			if _shared and _shared.notify then
				pcall(_shared.notify, "Legendary unlocked for your loadout: " .. tostring(pretty))
			end
		end
	end
	if promoted > 0 then _store_csv(KEY_LEGENDARY_UNLOCKED, unlocked) end
	_store_csv(KEY_LEGENDARY_PENDING, {})
	return promoted
end

-- One-way-in-new-code, rollback-safe save migration for Unlimited Power's
-- Doctrine -> Legendary promotion. We leave the legacy ownership/slot text
-- untouched so an older build can still read it, but the new UI filters it.
-- A previous owner receives the Legendary unlock; if UP was actually slotted
-- and the Legendary slot is empty, the selection follows it automatically.
local function _raw_csv_has(key, wanted)
	local raw = _mod and _mod:get(key)
	if type(raw) ~= "string" or raw == "" then return false end
	for id in string.gmatch(raw, "([^,]+)") do
		if id == wanted then return true end
	end
	return false
end

local function _legacy_up_was_slotted(id)
	if _raw_csv_has(KEY_BOON_SLOTTED, id) then return true end
	local raw = _mod and _mod:get(KEY_BOON_SLOTMAP)
	if type(raw) ~= "string" or raw == "" then return false end
	for entry in string.gmatch(raw, "([^,]+)") do
		local _, bound = string.match(entry, "^(%d+):(.+)$")
		if bound == id then return true end
	end
	return false
end

local function _migrate_unlimited_power()
	local id = "pilgrim_boon_unlimited_power"
	if not _raw_csv_has(KEY_BOON_OWNED, id) then return false end

	local unlocked = _legendary_csv_load(KEY_LEGENDARY_UNLOCKED)
	local have = false
	for i = 1, #unlocked do
		if unlocked[i] == id then have = true break end
	end
	if not have then
		unlocked[#unlocked + 1] = id
		_store_csv(KEY_LEGENDARY_UNLOCKED, unlocked)
	end

	if _legacy_up_was_slotted(id) then
		local selected = _mod:get(KEY_LEGENDARY_SLOT)
		if type(selected) ~= "string" or selected == "" then
			_mod:set(KEY_LEGENDARY_SLOT, id, false)
		end
	end
	return not have
end

function M.apply_loadout(player_unit)
	local granted = 0
	local archetype = nil
	if _run_state and _run_state.get then
		archetype = _run_state.get().stat_archetype
	end

	-- v0.24.0: the run's Archetype stat package applies first, exactly
	-- like a slotted Doctrine. active_archetype_id is already gated on
	-- run activity and the slot unlock happened at stamp time, so this
	-- needs no further checks; grant()'s dedupe makes repeats free.
	local arch_id = M.active_archetype_id()
	if arch_id then
		local arch = _archetype_by_id[arch_id]
		if arch and arch.buff_template then
			local ok = M.grant(player_unit, arch.buff_template)
			if ok then granted = granted + 1 end
		end
	end

	-- v0.25.0: the run's slotted Legendary applies like a Doctrine,
	-- with a RELEVANCE guard (Kaizen: only offer/apply what the
	-- character can actually use): the buff must be in the CURRENT
	-- pool, which build_pool already filters by class, equipped blitz,
	-- combat ability and talents. A slotted psyker legendary on a
	-- Veteran run skips quietly instead of misbehaving.
	local legendary = M.active_legendary()
	if legendary then
		local in_pool = false
		local pool = M.pool()
		for i = 1, #pool do
			if pool[i] == legendary then in_pool = true break end
		end
		if in_pool then
			local ok = M.grant(player_unit, legendary)
			if ok then granted = granted + 1 end
		else
			_debug_log("boons", 0, "slotted legendary " .. tostring(legendary)
				.. " not applicable to this operative/loadout; inert this mission", 0, "info")
		end
	end

	local slotted = M.slotted_ids()
	for i = 1, #slotted do
		local boon = _custom_by_id[slotted[i]]
		if boon and not boon.legendary and not boon.no_buff and M.is_owned(boon.id) then
			if boon.archetype and archetype and boon.archetype ~= archetype then
				_debug_log("boons", 0, "loadout boon " .. boon.id ..
					" skipped (archetype gate)", 0, "info")
			elseif boon.requires_blitz
				and M.blitz_template_name(player_unit) ~= boon.requires_blitz then
				_debug_log("boons", 0, "loadout boon " .. boon.id ..
					" skipped (blitz gate: wants " .. boon.requires_blitz ..
					", have " .. tostring(M.blitz_template_name(player_unit)) .. ")",
					0, "info")
			else
				local ok = M.grant(player_unit, boon.buff_template)
				if ok then granted = granted + 1 end
			end
		end
	end
	return granted
end

-- v0.22.85: reconciler entry point, called from a Pilgrimage.lua tick
-- while a run is active. Re-offers every boon the run should have;
-- grant()'s _applied dedupe makes repeats free, so this heals ordering
-- problems (run activated after spawn, loadout extension late, boon
-- bought mid-run) without ever double-stacking. Reads only; never
-- writes run_state (the 2-second-freeze lesson).
function M.ensure_applied(player_unit)
	if not player_unit then return 0 end
	if not _run_state.is_active() then return 0 end
	local granted = 0
	local state = _run_state.get()
	for name in pairs(state.boons or {}) do
		if not _applied[name] then
			if M.grant(player_unit, name) then granted = granted + 1 end
		end
	end
	granted = granted + (M.apply_loadout(player_unit) or 0)
	return granted
end

function M.init(deps)
	_mod = deps.mod
	_shared = deps.shared
	_run_state = deps.run_state
	_event_log = deps.event_log
	_hooks = deps.hooks
	_icons = deps.icons
	_missions = deps.missions
	-- v0.22.81: loadout deps. wallet for purchases, shop for slot
	-- expansions, passives for template registration.
	_wallet = deps.wallet
	_shop = deps.shop
	_debug_log = deps.debug_log or function() end
	if _migrate_unlimited_power() then
		_debug_log("boons", 0,
			"migrated owned Unlimited Power from Doctrine to Legendary", 0, "info")
	end
	if deps.passives and deps.passives.register_template_source then
		deps.passives.register_template_source(M.CUSTOM)
		-- Target-side child buffs are network templates too, but are not
		-- selectable content of their own.
		deps.passives.register_template_source(M.LEGENDARY_SUPPORT_TEMPLATES)
		deps.passives.register_template_source(M.FAMILY_SUPPORT_TEMPLATES)
		-- v0.26.0: drafted family expansions register through the same
		-- network-safe custom-template path as Doctrines and archetypes.
		deps.passives.register_template_source(M.FAMILY_BOONS)
		-- v0.24.0: archetype stat packages ride the same registration
		-- path; the entries share the CUSTOM shape (buff_template +
		-- custom.stat_buffs), so passives builds them identically.
		deps.passives.register_template_source(M.ARCHETYPES)
	end
end

return M
