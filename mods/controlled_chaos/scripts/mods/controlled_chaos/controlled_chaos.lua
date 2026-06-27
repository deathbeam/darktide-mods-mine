local mod = get_mod("controlled_chaos")

--------------------------------------------------------------------------------
-- STATE & CONFIG
--------------------------------------------------------------------------------

local _in_meatgrinder = false
local _havoc_armed = false
local _havoc_active = false
local _rank = 40
local _modifiers = {}
local _player_buffs = {}
local _debuffs_unit = nil
local _player_debuff_handles = {}

local _danger_entry = nil
local _tg_view_open = false
local _name_translations = { en = "Havoc 40" }
local _breed_chances_by_buff = {}
local _ignored_kw_by_buff = {}
local _loaded_visual_mutator = nil
local _visual_cache = {}

local _processed = setmetatable({}, { __mode = "k" })
local _catch_up_remaining = 0

local _VISUAL_BUFFS = {
	headshot_parasite_enemies = "mutator_headshot_parasite_enemies",
	mutator_rotten_armor = "mutator_rotten_armor",
}

local _BUFF_TEMPLATE = {
	buff_cranial_corruption = "headshot_parasite_enemies",
	buff_rotten_armour      = "mutator_rotten_armor",
	buff_pus_hardened_skin  = "havoc_toughened_skin",
	buff_blight_spreads     = "havoc_corrupted_enemies",
	buff_encroaching_garden = "havoc_encroaching_garden",
	buff_final_toll         = "havoc_enraged_enemies_trigger",
	buff_rampaging_enemies  = "havoc_bolstering",
	buff_nurgles_blessing   = "mutator_minion_nurgle_blessing_tougher",
	buff_stimm_blue         = "mutator_stimmed_minion_blue",
	buff_stimm_green        = "mutator_stimmed_minion_green",
	buff_stimm_red          = "mutator_stimmed_minion_red",
	buff_stimm_yellow       = "mutator_stimmed_minion_yellow",
}
local _VISUAL_GROUP = { buff_cranial_corruption = true, buff_rotten_armour = true }
local _STIMM_GROUP = {
	buff_stimm_blue = true, buff_stimm_green = true, buff_stimm_red = true, buff_stimm_yellow = true,
}

local function _selected_visual_mutator()
	for setting_id in pairs(_VISUAL_GROUP) do
		if mod:is_enabled() and mod:get(setting_id) then
			return _VISUAL_BUFFS[_BUFF_TEMPLATE[setting_id]]
		end
	end
	return nil
end

local function _any_enemy_buff_selected()
	for setting_id in pairs(_BUFF_TEMPLATE) do
		if mod:get(setting_id) then return true end
	end
	return false
end

--------------------------------------------------------------------------------
-- REFERENCES & HELPERS
--------------------------------------------------------------------------------

local _Breeds, _DangerSettings, _MINION_TYPE, _HavocModifierConfig, _HavocSettings

local DANGER_PATH = "scripts/settings/difficulty/danger_settings"
local TG_VIEW = "TrainingGroundsOptionsView"

local function _gameplay_time()
	local tm = Managers.time
	if tm and tm.has_timer and tm:has_timer("gameplay") then
		return tm:time("gameplay")
	end
	return nil
end

local function _load_refs()
	if not _DangerSettings then _DangerSettings = require(DANGER_PATH) end
	if not _Breeds then _Breeds = require("scripts/settings/breed/breeds") end
	if not _MINION_TYPE then _MINION_TYPE = require("scripts/settings/breed/breed_settings").types.minion end
	if not _HavocModifierConfig then _HavocModifierConfig = require("scripts/settings/havoc/havoc_modifier_config") end
	if not _HavocSettings then _HavocSettings = require("scripts/settings/havoc_settings") end
end

local function _clamp_level(v)
	v = tonumber(v) or 40
	v = math.floor(v + 0.5)
	if v < 1 then return 1 end
	if v > 40 then return 40 end
	return v
end

local function _challenge_for_rank(r)
	if r <= 10 then return 3 end
	if r <= 20 then return 4 end
	return 5
end

local function _resistance_for_rank(r)
	if r <= 10 then return 3 end
	if r <= 30 then return 4 end
	return 5
end

local function _shallow(t)
	local r = {}
	if t then for k, v in pairs(t) do r[k] = v end end
	return r
end

--------------------------------------------------------------------------------
-- DIFFICULTY MODIFIERS & ENEMY STATS
--------------------------------------------------------------------------------

local function _build_modifiers(rank)
	_load_refs()
	local tiers = _HavocModifierConfig[rank]
	local templates = _HavocSettings.modifier_templates
	local positive = _HavocSettings.positive_modifier_templates
	local modifiers, player_buffs = {}, {}

	if tiers then
		for name, tier in pairs(tiers) do
			local tmpl = (templates[name] and templates[name][tier]) or (positive and positive[name] and positive[name][tier])
			if tmpl then
				for k, v in pairs(tmpl) do
					if k == "add_player_buff" then
						player_buffs[#player_buffs + 1] = v
					else
						modifiers[k] = v
					end
				end
			end
		end
	end

	_modifiers = modifiers
	_player_buffs = player_buffs
end

local function _health_additive(breed)
	local tags = breed and breed.tags
	if not tags then return 0 end
	local m = 0
	if tags.elite then m = m + (_modifiers.modify_elite_health or 0) end
	if tags.special then m = m + (_modifiers.modify_special_health or 0) end
	if tags.interrupter then m = m + (_modifiers.modify_special_health or 0) end
	if tags.monster then m = m + (_modifiers.modify_monster_health or 0) end
	if tags.horde then m = m + (_modifiers.modify_horde_health or 0) end
	return m
end

local function _apply_minion_parity(unit, breed)
	local tags = breed and breed.tags
	if not tags then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension then return end
	local t = _gameplay_time()
	if not t then return end

	if tags.horde then
		local mhm = _modifiers.modify_horde_hit_mass or 0
		if mhm > 0 then
			local health_extension = ScriptUnit.has_extension(unit, "health_system")
			if health_extension and health_extension.hit_mass and health_extension.set_hit_mass then
				health_extension:set_hit_mass(health_extension:hit_mass() * (1 + mhm))
			end
		end
	end

	if tags.melee then
		local b = _modifiers.melee_minion_attack_speed_buff
		if b then buff_extension:add_internally_controlled_buff(b, t) end
		b = _modifiers.melee_minion_permanent_damage_buff
		if b then buff_extension:add_internally_controlled_buff(b, t) end
	end

	if (tags.far or tags.close) and not tags.exclude_for_havoc_speed_buff then
		local b = _modifiers.ranged_minion_attack_speed_buff
		if b then buff_extension:add_internally_controlled_buff(b, t) end
	end
end

--------------------------------------------------------------------------------
-- VISUAL OVERRIDE MUTATOR
--------------------------------------------------------------------------------

local function _force_deterministic(instance)
	if not instance or not instance._template then return end
	local template = instance._template
	local rsbt = template.random_spawn_buff_templates
	if not rsbt or not rsbt.breed_chances then return end
	local new_chances = {}
	for breed_name, chance in pairs(rsbt.breed_chances) do
		new_chances[breed_name] = (chance and chance > 0) and 1 or chance
	end
	local new_rsbt = _shallow(rsbt)
	new_rsbt.breed_chances = new_chances
	local new_template = _shallow(template)
	new_template.random_spawn_buff_templates = new_rsbt
	instance._template = new_template
end

local function _override_entry_for(override_template, breed)
	if not override_template or not breed then return nil end
	if breed.name and override_template[breed.name] then return override_template[breed.name] end
	if breed.tags then
		for tag in pairs(breed.tags) do
			if override_template[tag] then return override_template[tag] end
		end
	end
	return override_template.default
end

local _BODY_SLOT = {
	slot_upperbody = true, slot_lowerbody = true, slot_body = true, slot_upper_body = true,
	slot_lower_body = true, slot_base_upperbody = true, slot_base_lowerbody = true,
	slot_base_arms = true, slot_arms = true, slot_legs = true, slot_flesh = true, slot_shield = true,
}

local function _safe_host_slot(slots, used)
	for slot_name, slot_data in pairs(slots) do
		if not used[slot_name] and not _BODY_SLOT[slot_name]
			and not string.find(slot_name, "weapon", 1, true)
			and not string.find(slot_name, "override", 1, true) then
			local id = slot_data and slot_data.item_data
			local name = id and id.name
			if name then
				if string.find(name, "generic_items/empty_minion_item", 1, true) then
					return slot_name
				end
				local node = tostring(id.unwielded_attach_node or id.attach_node or "")
				if node ~= "" and node ~= "j_hips"
					and not string.find(node, "weaponattach", 1, true)
					and not string.find(node, "ap_", 1, true) then
					return slot_name
				end
			end
		end
	end
	return nil
end

local function _patched_change_visual(self, unit)
	local vle = ScriptUnit.has_extension(unit, "visual_loadout_system")
	local slots = vle and vle._slots
	if not slots or not vle._override_slot then return end

	local unit_data = ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data and unit_data.breed and unit_data:breed()
	local entry = _override_entry_for(self._override_template, breed)
	if not entry or not entry.item_slot_data then return end

	local allow_remap = self._template and self._template.template_name == "head_parasite"
	local new, used, used_named, pending = {}, {}, false, {}

	for entry_slot, group in pairs(entry.item_slot_data) do
		if slots[entry_slot] then
			new[entry_slot] = group
			used[entry_slot] = true
			used_named = true
		else
			pending[#pending + 1] = group
		end
	end

	for i = 1, #pending do
		if not allow_remap then return end
		local target = _safe_host_slot(slots, used)
		if not target then return end
		new[target] = pending[i]
		used[target] = true
	end

	if not used_named then return end

	pcall(function()
		vle:_override_slot({ item_slot_data = new, has_gib_override = entry.has_gib_override })
	end)
end

local function _unregister_visual_mutator(mutator_name)
	local manager = Managers.state and Managers.state.mutator
	if manager and manager._mutators then
		manager._mutators[mutator_name] = nil
	end
end

local function _ensure_visual_mutator()
	local manager = Managers.state and Managers.state.mutator
	if not manager or not manager._mutators then return end

	local wanted = _selected_visual_mutator()

	if wanted == _loaded_visual_mutator then return end

	if _loaded_visual_mutator then
		_unregister_visual_mutator(_loaded_visual_mutator)
		_loaded_visual_mutator = nil
	end

	if not wanted then return end

	local instance = _visual_cache[wanted]
	if instance then
		manager._mutators[wanted] = instance
	elseif manager.load_mutator_from_name then
		local ok = pcall(function() manager:load_mutator_from_name(wanted) end)
		if ok then
			instance = manager._mutators[wanted]
			if instance then
				pcall(_force_deterministic, instance)
				instance._change_visual_loadout_equipment = _patched_change_visual
				_visual_cache[wanted] = instance
			end
		end
	end

	if manager._mutators[wanted] then
		_loaded_visual_mutator = wanted
	end
end

--------------------------------------------------------------------------------
-- ENEMY BUFFS
--------------------------------------------------------------------------------

local function _apply_one_buff(buff_extension, breed, template_name, ignored_kw, t)
	if _VISUAL_BUFFS[template_name] then return false end
	local chances = _breed_chances_by_buff[template_name]
	if chances then
		local chance = chances[breed.name]
		if not chance or chance <= 0 then return false end
	end
	if ignored_kw and buff_extension.has_keyword and buff_extension:has_keyword(ignored_kw) then return false end
	if buff_extension.is_valid_target and not buff_extension:is_valid_target(template_name) then return false end
	buff_extension:add_externally_controlled_buff(template_name, t)
	return true
end

local function _apply_enemy_buffs(unit, breed)
	if not breed or breed.breed_type ~= _MINION_TYPE then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension then return end
	local t = _gameplay_time()
	if not t then return end

	local applied = false
	for setting_id, template_name in pairs(_BUFF_TEMPLATE) do
		if mod:get(setting_id) and not _ignored_kw_by_buff[template_name]
			and _apply_one_buff(buff_extension, breed, template_name, nil, t) then
			applied = true
		end
	end
	if applied and buff_extension._update_stat_buffs_and_keywords then
		buff_extension:_update_stat_buffs_and_keywords(t)
	end

	local applied2 = false
	for setting_id, template_name in pairs(_BUFF_TEMPLATE) do
		local ignored_kw = _ignored_kw_by_buff[template_name]
		if ignored_kw and mod:get(setting_id)
			and _apply_one_buff(buff_extension, breed, template_name, ignored_kw, t) then
			applied2 = true
		end
	end
	if applied2 and buff_extension._update_stat_buffs_and_keywords then
		buff_extension:_update_stat_buffs_and_keywords(t)
	end
end

local function _unit_breed(unit)
	local ude = ScriptUnit.has_extension(unit, "unit_data_system")
	if ude and ude.breed then
		local ok, breed = pcall(function() return ude:breed() end)
		if ok then return breed end
	end
	return nil
end

local function _apply_visual_to_existing(unit, breed)
	local mutator_name = _loaded_visual_mutator
	local manager = Managers.state and Managers.state.mutator
	local instance = mutator_name and manager and manager._mutators and manager._mutators[mutator_name]
	local template = instance and instance._template
	local rsbt = template and template.random_spawn_buff_templates
	if not rsbt or not rsbt.breed_chances or not rsbt.buffs then return end
	local chance = rsbt.breed_chances[breed.name]
	if not chance or chance <= 0 then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension then return end
	local first = rsbt.buffs[1]
	if first and buff_extension.has_buff_using_buff_template and buff_extension:has_buff_using_buff_template(first) then
		return
	end
	local t = _gameplay_time()
	if not t then return end
	if instance._change_visual_loadout_equipment then
		pcall(function() instance:_change_visual_loadout_equipment(unit) end)
	end
	for i = 1, #rsbt.buffs do
		local name = rsbt.buffs[i]
		if not (buff_extension.is_valid_target and not buff_extension:is_valid_target(name)) then
			buff_extension:add_externally_controlled_buff(name, t)
		end
	end
	if buff_extension._update_stat_buffs_and_keywords then
		buff_extension:_update_stat_buffs_and_keywords(t)
	end
end

local function _process_enemy(unit, breed)
	if not _processed[unit] then
		_processed[unit] = true
		if _havoc_active then pcall(_apply_minion_parity, unit, breed) end
		pcall(_apply_enemy_buffs, unit, breed)
	end
	pcall(_apply_visual_to_existing, unit, breed)
end

local function _catch_up_existing()
	_load_refs()
	local extension_mgr = Managers.state and Managers.state.extension
	if not extension_mgr or not extension_mgr.has_system or not extension_mgr:has_system("buff_system") then return end
	local buff_system = extension_mgr:system("buff_system")
	if not buff_system or not buff_system.unit_to_extension_map then return end
	local ok, map = pcall(function() return buff_system:unit_to_extension_map() end)
	if not ok or not map then return end
	for unit, _ in pairs(map) do
		if Unit.alive(unit) then
			local breed = _unit_breed(unit)
			if breed and breed.breed_type == _MINION_TYPE then
				_process_enemy(unit, breed)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- MEAT GRINDER LIFECYCLE
--------------------------------------------------------------------------------

local function _is_meatgrinder()
	local state = Managers.state
	local gm = state and state.game_mode
	if not gm then return false end
	local ok, name = pcall(function() return gm:game_mode():name() end)
	return ok and name == "shooting_range"
end

local function _apply_havoc_difficulty()
	_rank = _clamp_level(mod:get("havoc_level"))
	_build_modifiers(_rank)
	local difficulty = Managers.state and Managers.state.difficulty
	if difficulty then
		if difficulty.set_challenge then difficulty:set_challenge(_challenge_for_rank(_rank)) end
		if difficulty.set_resistance then difficulty:set_resistance(_resistance_for_rank(_rank)) end
	end
end

local function _on_enter_meatgrinder()
	_havoc_active = _havoc_armed
	_debuffs_unit = nil
	_processed = setmetatable({}, { __mode = "k" })
	_catch_up_remaining = 0
	_ensure_visual_mutator()
	local have_enemy_buff = _any_enemy_buff_selected()
	if _havoc_active then
		_apply_havoc_difficulty()
	end
	if _havoc_active or have_enemy_buff then
		_catch_up_remaining = 8
	end
end

local function _on_exit_meatgrinder()
	_havoc_armed = false
	_havoc_active = false
	_debuffs_unit = nil
	_player_debuff_handles = {}
	_modifiers = {}
	_player_buffs = {}
	if _loaded_visual_mutator then
		_unregister_visual_mutator(_loaded_visual_mutator)
		_loaded_visual_mutator = nil
	end
	_visual_cache = {}
	_processed = setmetatable({}, { __mode = "k" })
	_catch_up_remaining = 0
end

local function _visual_ready()
	local mutator_name = _loaded_visual_mutator
	if not mutator_name then return true end
	local manager = Managers.state and Managers.state.mutator
	local instance = manager and manager._mutators and manager._mutators[mutator_name]
	if not instance or not instance.is_loading_done then return true end
	local ok, done = pcall(function() return instance:is_loading_done() end)
	return ok and done
end

--------------------------------------------------------------------------------
-- PLAYER DEBUFFS & UPDATE LOOP
--------------------------------------------------------------------------------

local function _apply_player_debuffs(unit, buff_extension, t)
	_player_debuff_handles = {}
	for i = 1, #_player_buffs do
		local _, idx, comp = buff_extension:add_externally_controlled_buff(_player_buffs[i], t)
		if idx then
			_player_debuff_handles[#_player_debuff_handles + 1] = { idx, comp }
		end
	end
	_debuffs_unit = unit
end

local function _remove_player_debuffs(buff_extension)
	if buff_extension and buff_extension.remove_externally_controlled_buff then
		for i = 1, #_player_debuff_handles do
			local h = _player_debuff_handles[i]
			pcall(function() buff_extension:remove_externally_controlled_buff(h[1], h[2]) end)
		end
	end
	_player_debuff_handles = {}
end

local function _maybe_apply_player_debuffs()
	if not _havoc_active or #_player_buffs == 0 then return end
	local player = Managers.player and Managers.player:local_player(1)
	local unit = player and player.player_unit
	if not unit or unit == _debuffs_unit or not Unit.alive(unit) then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension then return end
	local t = _gameplay_time()
	if not t then return end
	_apply_player_debuffs(unit, buff_extension, t)
end

local function _refresh_havoc_live()
	_apply_havoc_difficulty()
	local player = Managers.player and Managers.player:local_player(1)
	local unit = player and player.player_unit
	if not unit or not Unit.alive(unit) then return end
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local t = _gameplay_time()
	if not buff_extension or not t then return end
	_remove_player_debuffs(buff_extension)
	_apply_player_debuffs(unit, buff_extension, t)
end

mod.update = function(dt)
	local in_mg = mod:is_enabled() and _is_meatgrinder()
	if in_mg ~= _in_meatgrinder then
		_in_meatgrinder = in_mg
		if in_mg then _on_enter_meatgrinder() else _on_exit_meatgrinder() end
	end
	if in_mg then
		if _selected_visual_mutator() ~= _loaded_visual_mutator then
			_ensure_visual_mutator()
		end
		if _havoc_active then
			_maybe_apply_player_debuffs()
		end
		if _catch_up_remaining > 0 then
			_catch_up_remaining = _catch_up_remaining - (dt or 0)
			if _visual_ready() then
				_catch_up_existing()
			end
		end
	end
end

--------------------------------------------------------------------------------
-- INITIALISATION & SETTINGS
--------------------------------------------------------------------------------

local function _build_difficulty()
	_load_refs()
	local base = _DangerSettings[4] or _DangerSettings[#_DangerSettings]
	local entry = _shallow(base)
	entry.name = "havoc_training"
	entry.challenge = 5
	entry.resistance = 5
	entry.difficulty = (base.difficulty or 5) + 1
	entry.loc_name = nil
	entry.display_name = "havoc_training_difficulty_name"
	entry.color = { 255, 180, 50, 210 }
	entry.is_unlocked = true
	entry.unlocks_at = 1
	entry.is_auric = false
	_danger_entry = entry
end

local function _update_name()
	_name_translations.en = "Havoc " .. tostring(_clamp_level(mod:get("havoc_level")))
end

local _SAFE_STOP_BUFFS = {
	"havoc_corrupted_enemies",
	"havoc_bolstering",
	"havoc_encroaching_garden",
	"havoc_enraged_enemies_trigger",
	"havoc_enraged_enemies",
	"havoc_toughened_skin",
	"mutator_rotten_armor",
	"headshot_parasite_enemies",
	"mutator_stimmed_minion_blue",
	"mutator_stimmed_minion_green",
	"mutator_stimmed_minion_red",
	"mutator_stimmed_minion_yellow",
}

local function _make_stop_funcs_safe()
	local ok, BuffTemplates = pcall(require, "scripts/settings/buff/buff_templates")
	if not ok or not BuffTemplates then return end
	for i = 1, #_SAFE_STOP_BUFFS do
		local template = BuffTemplates[_SAFE_STOP_BUFFS[i]]
		if template and template.stop_func and not template.__cc_safe_stop then
			local original = template.stop_func
			template.stop_func = function(...)
				pcall(original, ...)
			end
			template.__cc_safe_stop = true
		end
	end
end

local function _build_breed_chances()
	local template_files = {
		"scripts/settings/mutator/templates/mutator_havoc_templates",
		"scripts/settings/mutator/templates/mutator_minion_nurgle_blessing_templates",
	}
	for f = 1, #template_files do
		local ok, MutatorTemplates = pcall(require, template_files[f])
		if ok and MutatorTemplates then
			for _, template in pairs(MutatorTemplates) do
				local rsbt = template.random_spawn_buff_templates
				if rsbt and rsbt.buffs then
					for i = 1, #rsbt.buffs do
						if rsbt.breed_chances then
							_breed_chances_by_buff[rsbt.buffs[i]] = rsbt.breed_chances
						end
						if rsbt.ignored_buff_keyword then
							_ignored_kw_by_buff[rsbt.buffs[i]] = rsbt.ignored_buff_keyword
						end
					end
				end
			end
		end
	end

	local ok2, LocalSettings = pcall(require, "scripts/settings/havoc/havoc_mutator_local_settings")
	if ok2 and LocalSettings and LocalSettings.mutator_stimmed_minions and LocalSettings.mutator_stimmed_minions.breed_chances then
		local bc = LocalSettings.mutator_stimmed_minions.breed_chances
		_breed_chances_by_buff.mutator_stimmed_minion_blue = bc
		_breed_chances_by_buff.mutator_stimmed_minion_green = bc
		_breed_chances_by_buff.mutator_stimmed_minion_red = bc
		_breed_chances_by_buff.mutator_stimmed_minion_yellow = bc
	end
end

local function _make_toughened_skin_safe()
	local ok, BuffTemplates = pcall(require, "scripts/settings/buff/buff_templates")
	if not ok or not BuffTemplates then return end
	local template = BuffTemplates.havoc_toughened_skin
	if not template or not template.start_func or template.__cc_rank_safe then return end
	local original = template.start_func
	template.start_func = function(template_data, template_context)
		if pcall(original, template_data, template_context) then return end
		if not template_context.is_server then return end
		local unit = template_context.unit
		local buff_extension = unit and ScriptUnit.has_extension(unit, "buff_system")
		if buff_extension and buff_extension.stat_buffs then
			local rank = _clamp_level(mod:get("havoc_level"))
			buff_extension:stat_buffs().ranged_damage_taken_multiplier = 0.1 + 0.01 * rank
		end
	end
	template.__cc_rank_safe = true
end

mod.on_all_mods_loaded = function()
	_build_difficulty()
	mod:add_global_localize_strings({ havoc_training_difficulty_name = _name_translations })
	_update_name()
	_make_stop_funcs_safe()
	_build_breed_chances()
	_make_toughened_skin_safe()
end

mod.on_setting_changed = function(setting_id)
	if setting_id == "havoc_level" then
		_update_name()
		if _in_meatgrinder and _havoc_active then
			_refresh_havoc_live()
		end
	elseif _BUFF_TEMPLATE[setting_id] then
		if mod:get(setting_id) then
			local group = (_VISUAL_GROUP[setting_id] and _VISUAL_GROUP) or (_STIMM_GROUP[setting_id] and _STIMM_GROUP)
			if group then
				for other in pairs(group) do
					if other ~= setting_id then mod:set(other, false, false) end
				end
			end
		end
		if _in_meatgrinder then _ensure_visual_mutator() end
	end
end

--------------------------------------------------------------------------------
-- DIFFICULTY PICKER (PSYKHANIUM TERMINAL)
--------------------------------------------------------------------------------

local function _havoc_entry_index()
	if not _DangerSettings or not _danger_entry then return nil end
	for i = 1, #_DangerSettings do
		if _DangerSettings[i] == _danger_entry then return i end
	end
	return nil
end

local function _add_havoc_entry()
	if _havoc_entry_index() then return end
	_DangerSettings[#_DangerSettings + 1] = _danger_entry
end

local function _remove_havoc_entry()
	local i = _havoc_entry_index()
	if i then _DangerSettings[i] = nil end
end

local function _patch_stepper(self)
	if not _tg_view_open then return end
	local widget = self._widgets_by_name and self._widgets_by_name.difficulty_stepper
	local content = widget and widget.content
	if not content or content.__cc_patched then return end
	local original = content.value_id_1
	if type(original) ~= "function" then return end

	content.value_id_1 = function(pass, ui_renderer, ui_style, ui_content, position, size)
		local before = ui_content.danger

		original(pass, ui_renderer, ui_style, ui_content, position, size)

		if not _tg_view_open or ui_content.right_pressed_callback then return end
		if not _DangerSettings or #_DangerSettings <= 5 then return end
		if before ~= 5 or ui_content.danger ~= 5 then return end

		local input_service = ui_renderer.input_service
		local right = ui_content.right_hotspot
		local pressed = (right and right.on_released)
			or (ui_content.right_gamepad_input and input_service and input_service:get(ui_content.right_gamepad_input))

		if pressed then
			ui_content.danger = 6
		end
	end

	content.__cc_patched = true
end

mod:hook(TG_VIEW, "on_enter", function(func, self)
	if mod:is_enabled() and self.training_grounds_settings == "shooting_range" and _danger_entry then
		_load_refs()
		_add_havoc_entry()
		_tg_view_open = true
	end
	return func(self)
end)

mod:hook_safe(TG_VIEW, "on_exit", function(self)
	if _tg_view_open then
		_remove_havoc_entry()
		_tg_view_open = false
	end
end)

mod:hook(TG_VIEW, "_start_training_grounds", function(func, self, mechanism_context)
	local stepper = self._element and self:_element("difficulty_selector")
	local idx = (stepper and stepper.get_current_selected_difficulty and stepper:get_current_selected_difficulty()) or 0
	local sel = _DangerSettings and _DangerSettings[idx]
	_havoc_armed = (mod:is_enabled() and sel and sel.name == "havoc_training") and true or false
	return func(self, mechanism_context)
end)

mod:hook("ViewElementMissionBoardDifficultySelector", "initialize_data", function(func, self, optional_difficulty_index)
	local parent = self:parent()
	local list = (parent and parent.get_difficulty_settings and parent:get_difficulty_settings()) or require(DANGER_PATH)
	local n = (list and #list) or 1
	if optional_difficulty_index and optional_difficulty_index > n then
		optional_difficulty_index = n
	end
	local result = func(self, optional_difficulty_index)
	_patch_stepper(self)
	return result
end)

--------------------------------------------------------------------------------
-- ENEMY STAT HOOKS
--------------------------------------------------------------------------------

mod:hook("DifficultyManager", "get_minion_max_health", function(func, self, breed_name)
	local max_health = func(self, breed_name)
	if _havoc_active then
		_load_refs()
		local breed = _Breeds[breed_name]
		local add = breed and _health_additive(breed)
		if add and add ~= 0 then
			max_health = max_health * (1 + add)
		end
	end
	return max_health
end)

mod:hook("MinionSpawnManager", "spawn_minion", function(func, self, breed_name, position, rotation, side_id, optional_param_table)
	if not _in_meatgrinder then
		return func(self, breed_name, position, rotation, side_id, optional_param_table)
	end

	local unit = func(self, breed_name, position, rotation, side_id, optional_param_table)

	if unit then
		local breed = _unit_breed(unit) or _Breeds[breed_name]
		if breed then
			_processed[unit] = true
			if _havoc_active then
				pcall(_apply_minion_parity, unit, breed)
			end
			pcall(_apply_enemy_buffs, unit, breed)
		end
	end

	return unit
end)

mod:hook("DifficultyManager", "get_minion_attack_power_level", function(func, self, breed, attack_type)
	local power_level = func(self, breed, attack_type)
	if _havoc_active and attack_type == "melee" then
		local m = _modifiers.melee_minion_power_level_modifier
		if m then power_level = power_level * (1 + m) end
	end
	return power_level
end)
