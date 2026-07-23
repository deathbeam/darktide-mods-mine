local mod = get_mod("ImprovedMeatGrinder")

local Actor        = Actor
local Managers     = Managers
local PhysicsWorld = PhysicsWorld
local Quaternion   = Quaternion
local ScriptUnit   = ScriptUnit
local Unit         = Unit
local Vector3      = Vector3
local Vector3Box   = Vector3Box
local QuaternionBox = QuaternionBox
local World        = World

local Breeds = require("scripts/settings/breed/breeds")

local breeds_data = mod:io_dofile("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_breeds")
mod.breeds_data = breeds_data

local ICONS = { breeds = {}, by_label = {} }
pcall(function()
	local loaded = mod:io_dofile("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_icons")
	if type(loaded) == "table" then
		ICONS.breeds   = loaded.breeds or {}
		ICONS.by_label = loaded.by_label or {}
	end
end)

local WAVES = { presets = {}, trials = {} }
pcall(function()
	local w = mod:io_dofile("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_waves")
	if type(w) == "table" then
		WAVES.presets = w.presets or {}
		WAVES.trials  = w.trials or {}
	end
end)
mod.waves = WAVES

mod.settings   = mod:persistent_table("settings")
mod.lists      = mod.lists or {}
mod.name_cache = mod.name_cache or {}
mod._last_breed = mod._last_breed or nil
mod._menu_spawn_position = nil
mod._invuln = false

local function LF(key, ...) return string.format(mod:localize(key), ...) end

function mod.build_localized_labels()
	pcall(function()
		for i = 1, #WAVES.presets do
			local p = WAVES.presets[i]
			if p and p.id then p.name = mod:localize("preset_" .. p.id) end
		end
		for i = 1, #WAVES.trials do
			local t = WAVES.trials[i]
			if t and t.id then t.name = mod:localize("trial_" .. t.id) end
		end
		if breeds_data and breeds_data.category_order then
			breeds_data.category_label = breeds_data.category_label or {}
			for _, cat in ipairs(breeds_data.category_order) do
				breeds_data.category_label[cat] = mod:localize("cat_" .. cat)
			end
		end
		mod.armor_name = {
			unarmored   = mod:localize("armor_unarmored"),
			infested    = mod:localize("armor_infested"),
			flak        = mod:localize("armor_flak"),
			carapace    = mod:localize("armor_carapace"),
			maniac      = mod:localize("armor_maniac"),
			unyielding  = mod:localize("armor_unyielding"),
			void_shield = mod:localize("armor_void_shield"),
		}
	end)
end
mod.build_localized_labels()

local VIEW_NAME = "improved_meat_grinder_menu"

local S = {}
local function refresh_settings()
	S.count       = mod:get("ps_spawn_count") or 1
	S.side        = 2
	S.slot1       = mod:get("ps_slot_1")
	S.slot2       = mod:get("ps_slot_2")
	S.slot3       = mod:get("ps_slot_3")
	S.slot4       = mod:get("ps_slot_4")
	S.jitter      = mod:get("ps_spread") or 1.5
	S.menu_at_aim = mod:get("ps_menu_spawn_at_aim")
	S.enemy_ai    = mod:get("ps_enemy_ai")
	S.no_defaults = mod:get("ps_no_default_enemies")
	S.select_mode = mod:get("ps_select_mode")
	S.spawn_on_close = mod:get("ps_spawn_on_close")
	S.keep_queue  = mod:get("ps_keep_queue")
end

local function get_player()
	local pm = Managers.player
	return pm and pm:local_player(1)
end

local function get_player_unit(player)
	player = player or get_player()
	return player and player:unit_is_alive() and player.player_unit
end

local function is_server()
	return Managers.state and Managers.state.game_session and Managers.state.game_session:is_server()
end

local function is_shooting_range()
	local gm = Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	return gm == "shooting_range"
end

local function position_at_cursor(local_player)
	if not local_player then return nil end
	local viewport_name = local_player.viewport_name
	local camera_position = Managers.state.camera:camera_position(viewport_name)
	local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
	local camera_direction = Quaternion.forward(camera_rotation)
	local range = 500

	local world = Managers.world:world("level_world")
	local physics_world = World.get_data(world, "physics_world")

	local new_position
	local result = PhysicsWorld.immediate_raycast(physics_world, camera_position, camera_direction, range,
		"all", "types", "both", "collision_filter", "filter_player_character_shooting_raycast_statics")

	if result then
		local player_unit = get_player_unit(local_player)
		for i = 1, #result do
			local hit = result[i]
			local hit_unit = Actor.unit(hit[4])
			if hit_unit ~= player_unit then
				new_position = hit[1]
				break
			end
		end
	end
	return new_position
end

local function position_in_front(player_unit, distance)
	if not Unit.alive(player_unit) then return nil end
	local pos = Unit.local_position(player_unit, 1)
	local rot = Unit.local_rotation(player_unit, 1)
	local fwd = Quaternion.forward(rot)
	return pos + fwd * (distance or 8)
end

local function spawn_rotation(player_unit)
	if Unit.alive(player_unit) then
		return Quaternion.multiply(Unit.local_rotation(player_unit, 1), Quaternion(Vector3(0, 0, 1), math.pi))
	end
	return Quaternion(0, 0, 0, 0)
end

function mod.breed_bulk(breed_name)
	local b = Breeds and Breeds[breed_name]
	local hm = b and b.hit_mass
	if type(hm) == "number" then return hm end
	if type(hm) == "table" then return hm[3] or hm[1] or 1 end
	return 1
end

local function horde_footprint_radius(bulk_sum, spread)
	local r = 0.5 * math.sqrt(math.max(0.0001, bulk_sum or 0))
	local factor = 0.5 + 0.25 * (spread or 2)
	return math.max(0.6, r * factor)
end
mod.horde_footprint_radius = horde_footprint_radius

function mod.list_footprint(list, spread)
	if not list or #list == 0 then return 0.6 end
	local bulk = 0
	for i = 1, #list do bulk = bulk + mod.breed_bulk(list[i]) end
	return horde_footprint_radius(bulk, spread or mod:get("ps_spread") or 2)
end

local GOLDEN_ANGLE = 2.3999632
local function jitter(position, i, disc_radius, count)
	if not position or i <= 1 then return position end
	count = count or i
	local frac = (count > 1) and math.sqrt((i - 1) / (count - 1)) or 0
	local r = (disc_radius or 0) * frac
	local ang = i * GOLDEN_ANGLE
	return position + Vector3(math.cos(ang) * r, math.sin(ang) * r, 0)
end

function mod.breed_label(breed_name)
	local cached = mod.name_cache[breed_name]
	if cached then return cached end
	local label
	local breed = Breeds[breed_name]
	if breed and breed.display_name then
		local ok, s = pcall(Localize, breed.display_name)
		if ok and s and s ~= "" and not string.find(s, "<") then label = s end
	end
	if not label then
		label = (string.gsub(breed_name, "_", " "))
		label = (string.gsub(label, "(%a)([%w']*)", function(a, b) return string.upper(a) .. b end))
	end
	mod.name_cache[breed_name] = label
	return label
end

local CAT_PRIORITY = { "boss", "specialist", "elite", "misc", "regular" }

local function pick_category(cats)
	for p = 1, #CAT_PRIORITY do
		local pref = CAT_PRIORITY[p]
		for i = 1, #cats do
			if cats[i] == pref then return pref end
		end
	end
	return cats[1]
end

local VISIBLE_CATS = { "regular", "elite", "specialist", "boss", "misc" }

local function dedup_lists_by_label(lists)
	local winner = {}
	for _, catkey in ipairs(VISIBLE_CATS) do
		for _, breed in ipairs(lists[catkey]) do
			local label = mod.breed_label(breed)
			local cur = winner[label]
			if not cur then
				winner[label] = breed
			elseif mod.has_icon and mod.has_icon(breed) and not mod.has_icon(cur) then
				winner[label] = breed
			end
		end
	end
	for _, catkey in ipairs(VISIBLE_CATS) do
		local filtered = {}
		for _, breed in ipairs(lists[catkey]) do
			if winner[mod.breed_label(breed)] == breed then
				filtered[#filtered + 1] = breed
			end
		end
		lists[catkey] = filtered
	end
end

function mod.build_breed_lists()
	mod.build_localized_labels()
	local lists = { regular = {}, elite = {}, specialist = {}, boss = {}, misc = {}, all = {} }
	for breed_name, _ in pairs(Breeds) do
		if not breeds_data.blacklist[breed_name] then
			local cats = breeds_data.categories[breed_name]
			if cats and #cats > 0 then
				local c = pick_category(cats)
				if lists[c] then lists[c][#lists[c] + 1] = breed_name end
			end
			lists.all[#lists.all + 1] = breed_name
		end
	end
	for _, arr in pairs(lists) do
		table.sort(arr, function(a, b) return mod.breed_label(a) < mod.breed_label(b) end)
	end
	dedup_lists_by_label(lists)
	mod.lists = lists
	return lists
end

local MissionBuffsData, MissionBuffsParser, MissionBuffsAllowed, FixedFrame
pcall(function() FixedFrame = require("scripts/utilities/fixed_frame") end)
pcall(function() MissionBuffsData = require("scripts/settings/buff/hordes_buffs/hordes_buffs_data") end)
pcall(function() MissionBuffsParser = require("scripts/ui/constant_elements/elements/mission_buffs/utilities/mission_buffs_parser") end)
pcall(function() MissionBuffsAllowed = require("scripts/managers/mission_buffs/mission_buffs_allowed_buffs") end)

function mod.indulgences_available()
	return MissionBuffsData ~= nil and MissionBuffsAllowed ~= nil
end

local function indulg_family_label(key)
	local s = tostring(key):gsub("^hordes_buff_family_", ""):gsub("^hordes_buff_", ""):gsub("_", " ")
	s = s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end)
	return s
end

function mod.build_indulgences()
	local families = {}
	pcall(function()
		if not (MissionBuffsData and MissionBuffsAllowed) then return end
		local bf = MissionBuffsAllowed.buff_families or {}
		local keys = {}
		for k in pairs(bf) do keys[#keys + 1] = k end
		table.sort(keys)
		for _, key in ipairs(keys) do
			local fdata = bf[key]
			local buffs, seen = {}, {}
			local function add(list)
				if type(list) ~= "table" then return end
				for _, bn in pairs(list) do
					if type(bn) == "string" and not seen[bn] and MissionBuffsData[bn] then
						seen[bn] = true
						buffs[#buffs + 1] = bn
					end
				end
			end
			add(fdata.priority_buffs)
			add(fdata.buffs)
			if #buffs > 0 then
				families[#families + 1] = { key = key, label = indulg_family_label(key), buffs = buffs }
			end
		end
	end)
	mod._indulg = families
	return families
end

function mod.indulgence_title(buff_name)
	local bd = MissionBuffsData and MissionBuffsData[buff_name]
	if not bd then return buff_name end
	if bd.title and bd.title ~= "" then
		local ok, s = pcall(Localize, bd.title)
		if ok and s and s ~= "" and not string.find(s, "<") then return s end
	end
	return buff_name
end

function mod.indulgence_desc(buff_name)
	local bd = MissionBuffsData and MissionBuffsData[buff_name]
	if not (bd and MissionBuffsParser) then return "" end
	local ok, d = pcall(function()
		return MissionBuffsParser.get_formated_buff_description(bd, Color.ui_terminal(255, true))
	end)
	if not ok or type(d) ~= "string" then return "" end
	return (d:gsub("{#[^}]*}", ""))
end

local function player_buff_extension()
	local unit = get_player_unit()
	if not (unit and Unit.alive(unit)) then return nil end
	return ScriptUnit.has_extension(unit, "buff_system")
end

function mod.has_indulgence(buff_name)
	local be = player_buff_extension()
	if not (be and be.has_buff_using_buff_template) then return false end
	local ok, r = pcall(function() return be:has_buff_using_buff_template(buff_name) end)
	return ok and r or false
end

local function remove_indulgence(be, buff_name)
	local to_remove = {}
	pcall(function()
		for idx, inst in pairs(be._buffs_by_index or {}) do
			local ok, tmpl = pcall(function() return inst:template() end)
			if ok and tmpl and tmpl.name == buff_name then to_remove[#to_remove + 1] = idx end
		end
	end)
	for _, idx in ipairs(to_remove) do
		pcall(function() be:_remove_internally_controlled_buff(idx) end)
	end
	return #to_remove > 0
end

function mod.toggle_indulgence(buff_name)
	if not buff_name then return end
	if not is_shooting_range() then mod:notify(mod:localize("notify_indulgences_range_only")) return end
	local be = player_buff_extension()
	if not be then return end
	local has = false
	pcall(function() has = be.has_buff_using_buff_template and be:has_buff_using_buff_template(buff_name) end)
	if has then
		remove_indulgence(be, buff_name)
		mod:notify(LF("notify_indulgence_off_fmt", mod.indulgence_title(buff_name)))
	elseif be.add_internally_controlled_buff then
		local t = (FixedFrame and FixedFrame.get_latest_fixed_time()) or 0
		pcall(function() be:add_internally_controlled_buff(buff_name, t) end)
		mod:notify(LF("notify_indulgence_on_fmt", mod.indulgence_title(buff_name)))
	end
end

function mod.clear_indulgences()
	local be = player_buff_extension()
	if not be then return end
	local removed = 0
	for _, fam in ipairs(mod._indulg or {}) do
		for _, bn in ipairs(fam.buffs or {}) do
			if remove_indulgence(be, bn) then removed = removed + 1 end
		end
	end
	mod:notify(LF("notify_indulgences_cleared_fmt", removed))
end

function mod.apply_indulgence(buff_name)
	mod.toggle_indulgence(buff_name)
end

mod._icon_tex   = mod._icon_tex or {}
mod._icon_tried = mod._icon_tried or {}

local function norm_label(s)
	return (tostring(s):lower():gsub("[^%w]", ""))
end

local function icon_file_for(breed_name)
	if not breed_name then return nil end
	local key = norm_label(mod.breed_label(breed_name))
	local by = ICONS.by_label[key]
	if by then return by end
	if ICONS.breeds[breed_name] then return breed_name end
	return nil
end

function mod.has_icon(breed_name)
	return icon_file_for(breed_name) ~= nil
end

local function image_loader()
	local SA = get_mod("SimpleAssets")
	if SA and SA.load_texture then return "simpleassets", SA end
	local DLS = get_mod("DarktideLocalServer")
	if DLS and DLS.get_image and DLS.absolute_path then return "dls", DLS end
	return nil
end

function mod.icons_available()
	return image_loader() ~= nil
end

local function on_icon_loaded(file, data)
	if data and data.texture then
		mod._icon_tex[file] = data.texture
		local view = mod._view
		if view and view._refresh then
			pcall(function() view:_refresh() end)
		end
	end
end

function mod.get_icon(breed_name)
	local file = icon_file_for(breed_name)
	if not file then return nil end
	local cached = mod._icon_tex[file]
	if cached then return cached end

	local kind, loader = image_loader()
	if not kind then return nil end
	if mod._icon_tried[file] then return nil end
	mod._icon_tried[file] = true

	pcall(function()
		if kind == "simpleassets" then

			loader.load_texture("ImprovedMeatGrinder/textures/" .. file .. ".png")
				:next(function(data) on_icon_loaded(file, data) end):catch(function() end)
		else
			local path = loader.absolute_path("textures/" .. file .. ".png")
			loader.get_image(path):next(function(data) on_icon_loaded(file, data) end):catch(function() end)
		end
	end)

	return nil
end

local ARMOR_COLOR = {
	unarmored   = { 90, 195, 90 },
	infested    = { 150, 185, 70 },
	flak        = { 215, 150, 50 },
	carapace    = { 150, 155, 175 },
	maniac      = { 210, 70, 70 },
	unyielding  = { 160, 95, 195 },
	void_shield = { 80, 165, 240 },
}
mod.armor_color = ARMOR_COLOR

local INTERNAL_ARMOR = {
	unarmored              = "unarmored",
	armored                = "flak",
	super_armor            = "carapace",
	berserker              = "maniac",
	resistant              = "unyielding",
	disgustingly_resilient = "infested",
	player                 = "unarmored",
	void_shield            = "void_shield",
}

local function armor_category(a)
	return (a and INTERNAL_ARMOR[a]) or "unarmored"
end

local function hit_zone_armor(breed, zone_name)
	local ov = breed.hitzone_armor_override
	local a = (ov and ov[zone_name]) or breed.armor_type
	return armor_category(a)
end

local function breed_zone_set(breed)
	local set = {}
	local hz = breed.hit_zones
	if type(hz) == "table" then
		for i = 1, #hz do
			local z = hz[i]
			if type(z) == "table" and z.name then set[z.name] = true end
		end
	end
	return set
end

local SUMMARY_GROUPS = {
	{ label = "zone_head",     members = { "head" } },
	{ label = "zone_body",     members = { "torso", "center_mass" } },
	{ label = "zone_arms",     members = { "upper_left_arm", "upper_right_arm", "lower_left_arm", "lower_right_arm" } },
	{ label = "zone_legs",     members = { "upper_left_leg", "lower_left_leg", "upper_right_leg", "lower_right_leg" } },
	{ label = "zone_tail",     members = { "upper_tail", "lower_tail" } },
	{ label = "zone_tongue",   members = { "tongue" } },
	{ label = "zone_tentacle", members = { "tentacle" } },
	{ label = "zone_weakspot", members = { "weakspot" } },
	{ label = "zone_shield",   members = { "shield", "captain_void_shield", "corruptor_armor" } },
}

local EXTRA_ZONES = {
	{ zone = "right_shoulderguard", label = "zone_shoulder" },
	{ zone = "shield",              label = "zone_shield" },
	{ zone = "captain_void_shield", label = "zone_void_shield", cat = "void_shield" },
	{ zone = "backpack",            label = "zone_backpack" },
	{ zone = "tentacle",            label = "zone_tentacle" },
	{ zone = "corruptor_armor",     label = "zone_corruptor" },
	{ zone = "weakspot",            label = "zone_weakspot" },
}

local function extra_zones(breed, zoneset)
	local rows = {}
	for i = 1, #EXTRA_ZONES do
		local e = EXTRA_ZONES[i]
		if zoneset[e.zone] then
			rows[#rows + 1] = { label = mod:localize(e.label), cat = e.cat or hit_zone_armor(breed, e.zone) }
		end
	end
	return rows
end

local function summarize(breed, zoneset)
	local rows = {}
	for i = 1, #SUMMARY_GROUPS do
		local g = SUMMARY_GROUPS[i]
		local cats, seen = {}, {}
		for j = 1, #g.members do
			local zn = g.members[j]
			if zoneset[zn] then
				local c = hit_zone_armor(breed, zn)
				if not seen[c] then seen[c] = true; cats[#cats + 1] = c end
			end
		end
		if #cats > 0 then rows[#rows + 1] = { label = mod:localize(g.label), cats = cats } end
	end
	return rows
end

local function base_health(breed_name)
	local h
	pcall(function()
		local mds = require("scripts/settings/difficulty/minion_difficulty_settings")
		local t = mds and mds.health and mds.health[breed_name]
		if type(t) == "table" then h = t[1] end
	end)
	return h
end

function mod.enemy_stats(breed_name)
	if not breed_name then return nil end
	if breed_name == "attack_valkyrie" then return nil end
	local breed = Breeds and Breeds[breed_name]
	if not breed then return nil end

	local health, diff
	pcall(function()
		local dm = Managers.state and Managers.state.difficulty
		if dm then
			if dm.get_challenge then diff = dm:get_challenge() end
			if dm.get_minion_max_health then health = dm:get_minion_max_health(breed_name) end
		end
	end)
	if type(health) ~= "number" or health <= 0 then health = base_health(breed_name) end

	local zoneset = breed_zone_set(breed)
	local humanoid = (zoneset.torso and zoneset.upper_left_arm and zoneset.upper_left_leg) and true or false

	local zones = {}
	for zn in pairs(zoneset) do zones[zn] = hit_zone_armor(breed, zn) end

	return {
		name = mod.breed_label(breed_name),
		health = (type(health) == "number" and health > 0) and math.floor(health + 0.5) or nil,
		base = armor_category(breed.armor_type),
		humanoid = humanoid,
		zones = zones,
		extras = extra_zones(breed, zoneset),
		summary = summarize(breed, zoneset),
		difficulty = diff,
	}
end

local function do_spawn(breed_name, position, rotation)
	if not Breeds[breed_name] then
		mod:notify(LF("notify_unknown_breed", tostring(breed_name)))
		return nil
	end
	local spawner = Managers.state and Managers.state.minion_spawn
	if not spawner then return nil end

	local params = {
		optional_aggro_state = S.enemy_ai and "aggroed" or "passive",
	}
	if S.enemy_ai then
		local pu = get_player_unit()
		if pu and Unit.alive(pu) then params.optional_target_unit = pu end
	end

	local unit
	local ok = pcall(function()
		unit = spawner:spawn_minion(breed_name, position, rotation, S.side, params)
	end)
	if not ok then return nil end
	return unit
end

local function resolve_base_pose(live)
	local player = get_player()
	local player_unit = get_player_unit(player)
	local rotation = spawn_rotation(player_unit)
	local base
	if live then
		base = position_at_cursor(player) or position_in_front(player_unit, 8)
	else
		local aim = S.menu_at_aim and mod._menu_spawn_position and mod._menu_spawn_position:unbox()
		base = aim or position_in_front(player_unit, 8)
	end
	return base, rotation
end

function mod.spawn_list(breeds, live, is_refill)
	if not breeds or #breeds == 0 then return end
	if not is_server() then
		if not is_refill then mod:notify(mod:localize("notify_host_only")) end
		return
	end
	if not is_shooting_range() then
		if not is_refill then mod:notify(mod:localize("notify_psykhanium_only")) end
		return
	end
	refresh_settings()

	local base, rotation = resolve_base_pose(live)
	if not base then
		if not is_refill then mod:notify(mod:localize("notify_no_spawn_position")) end
		return
	end

	local disc = mod.list_footprint(breeds, S.jitter)
	local spawned = 0
	for i = 1, #breeds do
		local unit = do_spawn(breeds[i], jitter(base, i, disc, #breeds), rotation)
		if unit then
			spawned = spawned + 1
			mod._spawned[#mod._spawned + 1] = unit
		end
	end

	if #breeds > 0 then mod._last_breed = breeds[#breeds] end

	if not is_refill and #breeds > 0 then
		mod._last_group = {}
		for i = 1, #breeds do mod._last_group[i] = breeds[i] end
	end
	if spawned > 0 and not is_refill then
		mod:notify(S.enemy_ai and LF("notify_spawned_active_fmt", spawned) or LF("notify_spawned_fmt", spawned))
	end
end

local Health
pcall(function() Health = require("scripts/utilities/health") end)
mod._spawned = mod._spawned or {}
function mod.count_alive()
	local live = {}
	for i = 1, #mod._spawned do
		local u = mod._spawned[i]
		if u and Unit.alive(u) then
			local alive = true
			if Health and Health.is_alive then
				local ok, res = pcall(function() return Health.is_alive(u) end)
				if ok then alive = res and true or false end
			else
				local h = ScriptUnit.has_extension(u, "health_system")
				if h and h.current_health then
					local ok, hp = pcall(function() return h:current_health() end)
					if ok and hp ~= nil then alive = hp > 0 end
				end
			end
			if alive then live[#live + 1] = u end
		end
	end
	mod._spawned = live
	return #live
end

if mod._immortal_enemies == nil then mod._immortal_enemies = mod:get("ps_immortal_enemies") == true end
function mod.immortal_enemies_on() return mod._immortal_enemies == true end

local function each_enemy_health(fn)
	local map = rawget(_G, "HEALTH_ALIVE")
	if type(map) ~= "table" then return end
	local player_unit = get_player_unit()
	pcall(function()
		for unit in pairs(map) do
			if unit and unit ~= player_unit and Unit.alive(unit) then
				local h = ScriptUnit.has_extension(unit, "health_system")
				if h then fn(unit, h) end
			end
		end
	end)
end

function mod.toggle_immortal_enemies(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_immortal_hp_range_only")) return end
	mod._immortal_enemies = not mod._immortal_enemies
	mod:set("ps_immortal_enemies", mod._immortal_enemies, false)
	if not mod._immortal_enemies then
		each_enemy_health(function(unit, h)
			if h.set_unkillable then pcall(function() h:set_unkillable(false) end) end
		end)
	end
	mod:notify(mod._immortal_enemies and mod:localize("notify_immortal_hp_on") or mod:localize("notify_immortal_hp_off"))
end

local function sustain_immortal_enemies()
	if not mod._immortal_enemies or not is_shooting_range() then return end
	each_enemy_health(function(unit, h)
		if h.set_unkillable then pcall(function() h:set_unkillable(true) end) end
		if h.damage_taken and h.add_heal then
			pcall(function()
				local dmg = h:damage_taken()
				if dmg and dmg > 0 then h:add_heal(dmg, "healing_station") end
			end)
		end
	end)
end

function mod.spawn_breed(breed_name, count, live)
	if not breed_name then return end
	count = math.max(1, count or S.count or 1)
	local list = {}
	for i = 1, count do list[i] = breed_name end
	mod.spawn_list(list, live)
end

mod._queue = mod._queue or {}

function mod.queue_add(breed_name, n)
	n = math.max(1, n or 1)
	for _ = 1, n do mod._queue[#mod._queue + 1] = breed_name end
	return #mod._queue
end

function mod.queue_clear() mod._queue = {} end
function mod.queue_count() return #mod._queue end

function mod.queue_add_one(breed)
	if breed then mod._queue[#mod._queue + 1] = breed end
end
function mod.queue_remove_one(breed)
	for i = #mod._queue, 1, -1 do
		if mod._queue[i] == breed then table.remove(mod._queue, i); return end
	end
end
function mod.queue_remove_type(breed)
	for i = #mod._queue, 1, -1 do
		if mod._queue[i] == breed then table.remove(mod._queue, i) end
	end
end

function mod.queue_spawn(live)
	if #mod._queue == 0 then return end
	local list
	if mod:get("ps_keep_queue") then
		list = {}
		for i = 1, #mod._queue do list[i] = mod._queue[i] end
	else
		list = mod._queue
		mod._queue = {}
	end
	mod.spawn_list(list, live and true or false)
end

function mod.aim_spawn_hold(is_pressed)
	if is_pressed then

		mod._aim_hold_active = is_shooting_range() and true or false
		return
	end

	mod._aim_hold_active = false
	if not is_shooting_range() then
		mod:notify(mod:localize("notify_hold_range_only"))
		return
	end
	if mod.queue_count() == 0 then
		mod:notify(mod:localize("notify_hold_nothing_queued"))
		return
	end
	mod.queue_spawn(true)
end

local function draw_floor_marker(pos)
	local world = Managers.world and Managers.world:world("level_world")
	if not world then return end

	if mod._line_object and mod._line_object_world ~= world then
		mod._line_object = nil
		mod._line_object_world = nil
	end
	if not mod._line_object then
		local ok, lo = pcall(function() return World.create_line_object(world) end)
		if ok and lo then
			mod._line_object = lo
			mod._line_object_world = world
		else
			return
		end
	end

	local radius = mod.list_footprint(mod._queue, mod:get("ps_spread")) + 0.4
	pcall(function()
		local lo = mod._line_object
		LineObject.reset(lo)
		local c = Color(255, 90, 220, 130)
		local center = pos + Vector3(0, 0, 0.06)
		LineObject.add_circle(lo, c, center, radius, Vector3.up(), 32)
		LineObject.add_circle(lo, c, center, 0.35, Vector3.up(), 16)
		LineObject.dispatch(world, lo)
	end)
end
local function clear_floor_marker()
	if not mod._line_object then return end
	local world = Managers.world and Managers.world:world("level_world")
	if world and mod._line_object_world == world then
		pcall(function()
			LineObject.reset(mod._line_object)
			LineObject.dispatch(world, mod._line_object)
		end)
	else

		mod._line_object = nil
		mod._line_object_world = nil
	end
end
mod._draw_floor_marker = draw_floor_marker
mod._clear_floor_marker = clear_floor_marker

function mod.kill_all(self, silent)
	if is_server() and Managers.state and Managers.state.minion_spawn then
		Managers.state.minion_spawn:delete_units()
		if not silent then mod:notify(mod:localize("notify_killed_all")) end
	end
end

function mod.refill(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_refill_range_only")) return end
	local unit = get_player_unit()
	if not Unit.alive(unit) then return end
	if mod.refill_now then
		mod.refill_now(unit)
	else
		local toughness = ScriptUnit.has_extension(unit, "toughness_system")
		if toughness then pcall(function() toughness:recover_percentage_toughness(100, true, "melee_kill") end) end
		local health = ScriptUnit.has_extension(unit, "health_system")
		if health and health.add_heal then pcall(function() health:add_heal(1100, "healing_station") end) end
	end
	mod:notify(mod:localize("notify_refilled"))
end

function mod.toggle_invuln(self)
	if mod.god_toggle then
		mod.god_toggle("invuln")
		mod:notify(mod._god.invuln and mod:localize("notify_god_invuln_on") or mod:localize("notify_god_invuln_off"))
	end
end

function mod.repeat_last(self)
	if mod._last_breed then
		mod.spawn_breed(mod._last_breed, mod:get("ps_spawn_count") or 1, true)
	else
		mod:notify(mod:localize("notify_nothing_spawned"))
	end
end

function mod.player_respawn_pose(player)
	local unit = player and player.player_unit
	if unit and Unit.alive(unit) then
		return Vector3Box(Unit.world_position(unit, 1)), QuaternionBox(Unit.world_rotation(unit, 1))
	end
	if mod._last_pose and mod._last_pose.pos then
		return Vector3Box(mod._last_pose.pos:unbox()), QuaternionBox(mod._last_pose.rot:unbox())
	end
	local cpos, crot
	pcall(function()
		local vp = player and player.viewport_name
		if vp and Managers.state and Managers.state.camera then
			cpos = Managers.state.camera:camera_position(vp)
			crot = Managers.state.camera:camera_rotation(vp)
		end
	end)
	if cpos then return Vector3Box(cpos), QuaternionBox(crot or Quaternion.identity()) end
	return nil
end

function mod.revive_in_place(unit)
	if not (unit and Unit.alive(unit)) then return end
	pcall(function()
		local unit_data = ScriptUnit.has_extension(unit, "unit_data_system")
		if unit_data and unit_data.write_component then
			local comp = unit_data:write_component("assisted_state_input")
			if comp then comp.force_assist = true end
		end
	end)
	pcall(function()
		local health = ScriptUnit.has_extension(unit, "health_system")
		if health and health.add_heal then health:add_heal(999999, "healing_station") end
	end)
	pcall(function()
		local toughness = ScriptUnit.has_extension(unit, "toughness_system")
		if toughness and toughness.recover_percentage_toughness then toughness:recover_percentage_toughness(1, true, "melee_kill") end
	end)
end

function mod.respawn(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_refill_range_only")) return end
	local player = get_player()
	if not player then mod:notify(mod:localize("notify_no_player_unit")) return end

	if player.unit_is_alive and player:unit_is_alive() then
		mod.revive_in_place(player.player_unit)
		mod:notify(mod:localize("notify_respawned"))
		return
	end

	local pos, rot = mod.player_respawn_pose(player)
	if not pos then mod:notify(mod:localize("notify_no_player_unit")) return end
	pcall(function()
		local psm = Managers.state and Managers.state.player_unit_spawn
		if psm and psm.spawn_player then
			psm:spawn_player(player, pos:unbox(), rot:unbox(), nil, true, nil, nil, nil, true)
		end
	end)
	mod:notify(mod:localize("notify_respawned"))
end

local Ammo
pcall(function() Ammo = require("scripts/utilities/ammo") end)

local function warp_charge_component(unit)
	local ude = ScriptUnit.has_extension(unit, "unit_data_system")
	if not ude or not ude.write_component then return nil end
	local ok, wc = pcall(function() return ude:write_component("warp_charge") end)
	if ok then return wc end
	return nil
end

local function zero_warp_charge(unit)
	local wc = warp_charge_component(unit)
	if not wc then return end
	if wc.current_percentage and wc.current_percentage > 0 then wc.current_percentage = 0 end
	if wc.state == "exploding" then wc.state = "idle" end
end

local function defuse_peril(unit)
	local wc = warp_charge_component(unit)
	if not wc then return end
	if wc.state == "exploding" then wc.state = "idle" end
	if wc.current_percentage and wc.current_percentage > 0.95 then wc.current_percentage = 0.9 end
end

local GOD_KEYS = { "toughness", "health", "ammo", "magazine", "ability", "blitz", "stamina", "dodge", "invuln", "no_peril_gain", "no_peril_death" }
mod.god_keys = GOD_KEYS

if not mod._god then
	mod._god = {}
	for i = 1, #GOD_KEYS do
		mod._god[GOD_KEYS[i]] = mod:get("ps_god_" .. GOD_KEYS[i]) == true
	end
end

function mod.god_get(key) return mod._god[key] == true end

function mod.god_all_on()
	for i = 1, #GOD_KEYS do if not mod._god[GOD_KEYS[i]] then return false end end
	return true
end
local function god_any_on()
	for i = 1, #GOD_KEYS do if mod._god[GOD_KEYS[i]] then return true end end
	return false
end
mod.god_any_on = god_any_on

local function apply_invuln(unit)

	local want = mod._god.invuln and is_shooting_range()
	local health = ScriptUnit.has_extension(unit, "health_system")
	if health then pcall(function() health:set_invulnerable(want and true or false) end) end
end

function mod.god_set(key, on)
	on = on and true or false
	if key == "all" then
		for i = 1, #GOD_KEYS do
			mod._god[GOD_KEYS[i]] = on
			mod:set("ps_god_" .. GOD_KEYS[i], on, false)
		end
	elseif mod._god[key] ~= nil then
		mod._god[key] = on
		mod:set("ps_god_" .. key, on, false)
	end
	mod._invuln = mod._god.invuln
	local unit = get_player_unit()
	if Unit.alive(unit) then apply_invuln(unit) end
end

function mod.god_toggle(key)
	local cur = (key == "all") and mod.god_all_on() or mod._god[key]
	mod.god_set(key, not cur)
end

local function refill_toughness(unit)
	local t = ScriptUnit.has_extension(unit, "toughness_system")
	if t then pcall(function() t:recover_percentage_toughness(1, true, "melee_kill") end) end
end
local function refill_health(unit)
	local h = ScriptUnit.has_extension(unit, "health_system")
	if h and h.add_heal then pcall(function() h:add_heal(9999, "healing_station") end) end
end
local function refill_ammo(unit)
	if Ammo and Ammo.add_to_all_slots then pcall(function() Ammo.add_to_all_slots(unit, 1) end) end
end

local function refill_ability(unit, which)
	local a = ScriptUnit.has_extension(unit, "ability_system")
	if not a then return end
	pcall(function()
		if a.max_ability_charges and a.set_ability_charges then
			local maxc = a:max_ability_charges(which)
			if maxc then a:set_ability_charges(which, maxc) end
		end
	end)
	pcall(function()
		if a.reduce_ability_cooldown_percentage then a:reduce_ability_cooldown_percentage(which, 1) end
	end)

	pcall(function()
		local comp = a._ability_components and a._ability_components[which]
		if comp then
			if comp.cooldown ~= nil then comp.cooldown = 0 end
			if comp.cooldown_regen_buffer ~= nil then comp.cooldown_regen_buffer = 0 end
		end
	end)
end
local function refill_stamina(unit)
	local uds = ScriptUnit.has_extension(unit, "unit_data_system")
	if not uds or not uds.write_component then return end
	local ok, comp = pcall(function() return uds:write_component("stamina") end)
	if ok and comp and comp.current_fraction ~= nil then pcall(function() comp.current_fraction = 1 end) end
end

local function refill_dodge(unit)
	local uds = ScriptUnit.has_extension(unit, "unit_data_system")
	if not uds or not uds.write_component then return end
	for _, cname in ipairs({ "dodge_character_state", "sprint_character_state", "locomotion_steering" }) do
		local ok, comp = pcall(function() return uds:write_component(cname) end)
		if ok and comp then
			pcall(function()
				if comp.consecutive_dodges ~= nil then comp.consecutive_dodges = 0 end
				if comp.consecutive_dodges_cooldown ~= nil then comp.consecutive_dodges_cooldown = 0 end
			end)
		end
	end
end

local function refill_magazine(unit)
	if not Ammo or not Ammo.set_current_ammo_in_clips or not Ammo.max_ammo_in_clips then return end
	local uds = ScriptUnit.has_extension(unit, "unit_data_system")
	local vle = ScriptUnit.has_extension(unit, "visual_loadout_system")
	if not uds or not vle or not vle.slot_configuration_by_type then return end
	pcall(function()
		local slots = vle:slot_configuration_by_type("weapon")
		for _, slot in pairs(slots or {}) do
			local ok, comp = pcall(function() return uds:write_component(slot.name) end)
			if ok and comp then
				local maxc = Ammo.max_ammo_in_clips(comp)
				if maxc and maxc > 0 then Ammo.set_current_ammo_in_clips(comp, maxc) end
			end
		end
	end)
end

function mod.refill_now(unit)
	if not Unit.alive(unit) then return end
	refill_toughness(unit)
	refill_health(unit)
	refill_ammo(unit)
	refill_magazine(unit)
	refill_ability(unit, "combat_ability")
	refill_ability(unit, "grenade_ability")
	refill_stamina(unit)
end

local _god_accum = 0
local _cont_accum = 0
local _pose_accum = 0
mod.update = function(dt)

	do
		local in_range = is_shooting_range()
		if in_range ~= mod._in_range_prev then
			mod._in_range_prev = in_range
			if in_range then
				if mod.apply_muffler then mod.apply_muffler() end
				if mod:get("ps_prepare_on_entry") ~= false and mod.calm_arena then
					mod.calm_arena()
				end
				if mod:get("ps_invisible_default") then
					mod._invisible = true
					mod:set("ps_invisible", true, false)
				end
			else
				if mod.release_muffler then mod.release_muffler() end
				if mod.despawn_all_bots then pcall(function() mod.despawn_all_bots(true) end) end
				if mod.wave_stop then mod.wave_stop() end
			end
		end
	end

	if mod._pending_clear_defaults then
		mod._pending_clear_defaults = false
		if is_shooting_range() then pcall(function() mod.kill_all(nil, true) end) end
	end

	_pose_accum = _pose_accum + (dt or 0)
	if _pose_accum >= 0.25 and is_shooting_range() then
		_pose_accum = 0
		local pu = get_player_unit()
		if Unit.alive(pu) then
			mod._last_pose = { pos = Vector3Box(Unit.world_position(pu, 1)), rot = QuaternionBox(Unit.world_rotation(pu, 1)) }
		end
	end

	if mod.whisper_update then mod.whisper_update(dt) end

	sustain_immortal_enemies()

	if mod._continuous then
		_cont_accum = _cont_accum + (dt or 0)
		if _cont_accum >= 0.5 then
			_cont_accum = 0
			if mod.continuous_refill then pcall(mod.continuous_refill) end
		end
	end

	if (mod._god.no_peril_gain or mod._god.no_peril_death) and is_shooting_range() then
		local pu = get_player_unit()
		if Unit.alive(pu) then
			if mod._god.no_peril_gain then zero_warp_charge(pu)
			elseif mod._god.no_peril_death then defuse_peril(pu) end
		end
	end

	if mod._aim_hold_active and is_shooting_range() then
		local pos = position_at_cursor(get_player())
		if pos then draw_floor_marker(pos) end
	elseif mod._line_object then
		clear_floor_marker()
	end

	local wv = mod._wave
	if wv and wv.active and wv.trial and mod._wave_auto ~= false and is_shooting_range() then
		wv.timer = wv.timer + (dt or 0)
		local adv = wv.trial.advance or "clear"
		if adv == "timer" then
			if wv.timer >= (mod.wave_interval or 6) then mod.wave_next() end
		elseif wv.timer > 1.5 and mod.count_alive and mod.count_alive() == 0 then
			mod.wave_next()
		end
	end

	if not god_any_on() then return end
	_god_accum = _god_accum + (dt or 0)
	if _god_accum < 0.25 then return end
	_god_accum = 0
	if not is_shooting_range() then return end
	local unit = get_player_unit()
	if not Unit.alive(unit) then return end
	if mod._god.toughness then refill_toughness(unit) end
	if mod._god.health    then refill_health(unit) end
	if mod._god.ammo      then refill_ammo(unit) end
	if mod._god.magazine  then refill_magazine(unit) end
	if mod._god.ability   then refill_ability(unit, "combat_ability") end
	if mod._god.blitz     then refill_ability(unit, "grenade_ability") end
	if mod._god.stamina   then refill_stamina(unit) end
	if mod._god.dodge     then refill_dodge(unit) end
	if mod._god.invuln    then apply_invuln(unit) end
end

local function _gnotify(key) mod:notify(mod._god[key] and mod:localize("notify_god_" .. key .. "_on") or mod:localize("notify_god_" .. key .. "_off")) end
function mod.toggle_god_mode(self)      mod.god_toggle("all")       mod:notify(mod.god_all_on() and mod:localize("notify_god_all_on") or mod:localize("notify_god_all_off")) end
function mod.toggle_god_toughness(self) mod.god_toggle("toughness") _gnotify("toughness") end
function mod.toggle_god_health(self)    mod.god_toggle("health")    _gnotify("health") end
function mod.toggle_god_ammo(self)      mod.god_toggle("ammo")      _gnotify("ammo") end
function mod.toggle_god_magazine(self)  mod.god_toggle("magazine")  _gnotify("magazine") end
function mod.toggle_god_ability(self)   mod.god_toggle("ability")   _gnotify("ability") end
function mod.toggle_god_blitz(self)     mod.god_toggle("blitz")     _gnotify("blitz") end
function mod.toggle_god_stamina(self)   mod.god_toggle("stamina")   _gnotify("stamina") end
function mod.toggle_god_dodge(self)     mod.god_toggle("dodge")     _gnotify("dodge") end
function mod.toggle_god_no_peril_gain(self)  mod.god_toggle("no_peril_gain")  _gnotify("no_peril_gain") end
function mod.toggle_god_no_peril_death(self) mod.god_toggle("no_peril_death") _gnotify("no_peril_death") end

mod._wave = mod._wave or { active = false, trial = nil, index = 0, timer = 0 }
mod.wave_interval = mod.wave_interval or 6
if mod._wave_auto == nil then
	local saved = mod:get("ps_wave_auto")
	mod._wave_auto = (saved == nil) and true or (saved == true)
end

function mod.wave_auto_get() return mod._wave_auto ~= false end
function mod.wave_auto_toggle()
	mod._wave_auto = not mod.wave_auto_get()
	mod:set("ps_wave_auto", mod._wave_auto, false)
	mod:notify(mod._wave_auto and mod:localize("notify_auto_waves_on") or mod:localize("notify_auto_waves_off"))
end

local function spawn_group(group)
	if not group then return end
	local list = {}
	for breed, n in pairs(group) do
		for _ = 1, math.max(1, n) do list[#list + 1] = breed end
	end
	if #list > 0 then mod.spawn_list(list, false) end
end
mod.spawn_group = spawn_group

function mod.spawn_preset(id)
	for i = 1, #WAVES.presets do
		if WAVES.presets[i].id == id then spawn_group(WAVES.presets[i].group) return end
	end
end

local function find_trial(id)
	for i = 1, #WAVES.trials do
		if WAVES.trials[i].id == id then return WAVES.trials[i] end
	end
end

local function scale_wave(base_wave, factor)
	local out = {}
	for breed, n in pairs(base_wave) do out[breed] = math.max(1, math.floor(n * factor)) end
	return out
end

function mod.wave_stop()
	mod._wave.active = false
	mod._wave.trial = nil
	mod._wave.index = 0
end

function mod.wave_next()
	local w = mod._wave
	if not w.active or not w.trial then return end
	w.index = w.index + 1
	local list = w.trial.waves or {}
	local wv = list[w.index]
	if not wv then
		if w.trial.endless and #list > 0 then
			wv = scale_wave(list[#list], 1 + (w.index - #list) * 0.5)
		else
			mod:notify(LF("notify_trial_complete_fmt", w.trial.name or ""))
			mod.wave_stop()
			return
		end
	end
	w.timer = 0
	spawn_group(wv)
	mod:notify(LF("notify_wave_fmt", w.index))
end

function mod.start_trial(id)
	if not is_shooting_range() then mod:notify(mod:localize("notify_trials_range_only")) return end
	local t = find_trial(id)
	if not t then return end
	mod.kill_all()
	mod._spawned = {}
	mod._wave = { active = true, trial = t, index = 0, timer = 0 }
	mod.wave_next()
end

function mod.wave_active() return mod._wave.active end
function mod.wave_status()
	local w = mod._wave
	if not w.active then return mod:localize("wave_idle") end
	return LF("wave_status_fmt", (w.trial and w.trial.name or "Trial"), w.index)
end

if mod._muffler_off == nil then mod._muffler_off = mod:get("ps_muffler_off") == true end
mod._muffler_forced = mod._muffler_forced or false
local function set_music_zone(zone)
	pcall(function()
		if rawget(_G, "Wwise") and Wwise.set_state then
			Wwise.set_state("music_zone", zone)
		end
	end)
end
function mod.apply_muffler()
	if not is_shooting_range() then return end
	set_music_zone(mod._muffler_off and "combat" or "shooting_range")
	mod._muffler_forced = true
end
function mod.release_muffler()
	if not mod._muffler_forced then return end
	mod._muffler_forced = false
	set_music_zone("combat")
end
function mod.toggle_sound_muffler(self)
	mod._muffler_off = not mod._muffler_off
	mod:set("ps_muffler_off", mod._muffler_off, false)
	if is_shooting_range() then mod.apply_muffler() end
	mod:notify(mod._muffler_off and mod:localize("notify_muffler_off_desc") or mod:localize("notify_muffler_on_desc"))
end
function mod.muffler_off() return mod._muffler_off end

if mod._no_whispers == nil then mod._no_whispers = mod:get("ps_no_whispers") == true end

local WHISPER_STOP_EVENT  = "wwise/events/world/stop_all_mission_sounds"
local WHISPER_ENTER_EVENT = "wwise/events/ui/play_hud_tg_exit_portal_loop"
local WHISPER_TICK = 1
mod._whisper_timer = mod._whisper_timer or 0
mod._whisper_count = mod._whisper_count or 0

local function whisper_play_stop()
	pcall(function()
		local world = Managers.world and Managers.world:world("level_world")
		if not world then return end
		local wwise_world = Managers.world:wwise_world(world)
		if wwise_world and rawget(_G, "WwiseWorld") and WwiseWorld.trigger_resource_event then
			WwiseWorld.trigger_resource_event(wwise_world, WHISPER_STOP_EVENT)
		end
	end)
end
mod._whisper_play_stop = whisper_play_stop

function mod.whisper_update(dt)
	if not is_shooting_range() then mod._whisper_timer = 0 return end
	if mod._whisper_timer and mod._whisper_timer > 0 then
		mod._whisper_timer = mod._whisper_timer - (dt or 0)
		if mod._whisper_timer <= 0 then
			mod._whisper_count = (mod._whisper_count or 0) + 1
			if mod._whisper_count < 3 then
				mod._whisper_timer = WHISPER_TICK
				whisper_play_stop()
			else
				mod._whisper_timer = 0
			end
		end
	end
end

function mod.toggle_whispers(self)
	mod._no_whispers = not mod._no_whispers
	mod:set("ps_no_whispers", mod._no_whispers, false)

	if mod._no_whispers and is_shooting_range() then
		mod._whisper_timer = WHISPER_TICK
		mod._whisper_count = 0
		whisper_play_stop()
	end
	mod:notify(mod._no_whispers and mod:localize("notify_whispers_off_desc") or mod:localize("notify_whispers_on_desc"))
end
function mod.whispers_off() return mod._no_whispers end

pcall(function()
	if rawget(_G, "WwiseWorld") and WwiseWorld.trigger_resource_event then
		mod:hook_safe(WwiseWorld, "trigger_resource_event", function(wwise_world, event_name, ...)
			if mod._no_whispers and event_name == WHISPER_ENTER_EVENT then
				mod._whisper_timer = WHISPER_TICK
				mod._whisper_count = 0
				whisper_play_stop()
			end
		end)
	end
end)

if mod._continuous == nil then mod._continuous = mod:get("ps_continuous") == true end
function mod.continuous_on() return mod._continuous == true end
function mod.toggle_continuous(self)
	mod._continuous = not mod._continuous
	mod:set("ps_continuous", mod._continuous, false)
	mod:notify(mod._continuous and mod:localize("notify_continuous_on") or mod:localize("notify_continuous_off"))
end

function mod.toggle_swap_lineup(self)
	if not is_shooting_range() then
		mod:notify(mod:localize("notify_lineup_range_only"))
		return
	end
	local v = not mod:get("ps_swap_lineup")
	mod:set("ps_swap_lineup", v, true)
	mod:notify(v and mod:localize("notify_lineup_missing") or mod:localize("notify_lineup_default"))
end

function mod.toggle_enemy_ai(self)
	if not is_shooting_range() then
		mod:notify(mod:localize("notify_ai_range_only"))
		return
	end
	local v = not mod:get("ps_enemy_ai")
	mod:set("ps_enemy_ai", v, true)
	mod:notify(v and mod:localize("notify_enemy_ai_on") or mod:localize("notify_enemy_ai_off"))
end

if mod._invisible == nil then mod._invisible = mod:get("ps_invisible") == true end
function mod.invisible_on() return mod._invisible == true end
function mod.toggle_invisible(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_invis_range_only")) return end
	mod._invisible = not mod._invisible
	mod:set("ps_invisible", mod._invisible, false)
	mod:notify(mod._invisible and mod:localize("notify_invisible_on") or mod:localize("notify_invisible_off"))
end

function mod.calm_arena()
	pcall(function() if mod.kill_all then mod.kill_all(nil, true) end end)
	pcall(function() if mod.despawn_all_bots then mod.despawn_all_bots(true) end end)
	if mod.wave_stop then mod.wave_stop() end
	mod._wave = { active = false, trial = nil, index = 0, timer = 0 }
	mod._continuous = false
	mod:set("ps_continuous", false, false)
	mod._invisible = true
	mod:set("ps_invisible", true, false)
	mod:set("ps_enemy_ai", false, true)
	pcall(function()
		each_enemy_health(function(unit)
			pcall(function()
				local nav = ScriptUnit.has_extension(unit, "navigation_system")
				if nav and nav.set_enabled then nav:set_enabled(false) end
			end)
			pcall(function()
				local pe = ScriptUnit.has_extension(unit, "perception_system")
				local pc = pe and pe._perception_component
				if pc then pc.aggro_state = "passive"; pc.target_unit = nil end
			end)
		end)
	end)
	if mod._view and mod._view._refresh then pcall(function() mod._view:_refresh() end) end
end

function mod.reset_to_default(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_reset_range_only")) return end
	mod.calm_arena()
end

mod._bots = mod._bots or {}
mod.MAX_BOTS = 3
mod.bot_profiles = { "bot_1", "bot_2", "bot_3", "bot_4", "bot_5", "bot_6" }

local function get_bot_spawning()
	local ok, bs = pcall(require, "scripts/managers/bot/bot_spawning")
	return ok and bs or nil
end

local function bot_host()
	local ok, host = pcall(function()
		return Managers.bot and Managers.bot.synchronizer_host and Managers.bot:synchronizer_host()
	end)
	return ok and host or nil
end

function mod.bot_count()
	local host = bot_host()
	if not host then return 0 end
	local n = 0
	local ok, ids = pcall(function() return host:active_bot_ids() end)
	if ok and ids then for _ in pairs(ids) do n = n + 1 end end
	return n
end

function mod.spawn_bot(profile_name)
	if not is_server() then mod:notify(mod:localize("notify_bots_host_only")) return end
	if not is_shooting_range() then mod:notify(mod:localize("notify_bots_range_only")) return end
	local host = bot_host()
	local BotSpawning = get_bot_spawning()
	if not host or not BotSpawning then mod:notify(mod:localize("notify_bots_unavailable")) return end
	if mod.bot_count() >= mod.MAX_BOTS then mod:notify(LF("notify_bots_full", mod.MAX_BOTS)) return end
	profile_name = profile_name or "bot_1"
	local id
	pcall(function() id = BotSpawning.spawn_bot_character(profile_name) end)
	if not id then
		pcall(function() id = BotSpawning.spawn_bot_character("bot_training_grounds") end)
	end
	if id then
		mod._bots[id] = profile_name
		mod._last_bot_profile = profile_name
		mod:set("ps_last_bot", profile_name, false)
		mod:notify(LF("notify_bot_spawned", mod.bot_count(), mod.MAX_BOTS))
	else
		mod:notify(mod:localize("notify_bots_unavailable"))
	end
end

function mod.spawn_bot_random()
	local list = mod.bot_profiles
	mod.spawn_bot(list[math.random(1, #list)])
end

function mod.despawn_one_bot()
	if not is_server() then return end
	local host = bot_host()
	local BotSpawning = get_bot_spawning()
	if not host or not BotSpawning then return end
	local target
	for id in pairs(mod._bots) do target = id end
	if not target then
		local ok, ids = pcall(function() return host:active_bot_ids() end)
		if ok and ids then for id in pairs(ids) do target = id break end end
	end
	if target then
		pcall(function() BotSpawning.despawn_bot_character(target, true) end)
		mod._bots[target] = nil
		mod:notify(LF("notify_bot_removed_one", mod.bot_count(), mod.MAX_BOTS))
	end
end

function mod.despawn_all_bots(silent)
	local host = bot_host()
	local BotSpawning = get_bot_spawning()
	if not host or not BotSpawning then mod._bots = {} return end
	local list = {}
	local ok, ids = pcall(function() return host:active_bot_ids() end)
	if ok and ids then for id in pairs(ids) do list[#list + 1] = id end end
	for i = 1, #list do
		pcall(function() BotSpawning.despawn_bot_character(list[i], true) end)
	end
	mod._bots = {}
	if not silent then mod:notify(mod:localize("notify_bots_removed")) end
end

function mod.spawn_bot_key(self) mod.spawn_bot(mod._last_bot_profile or mod:get("ps_last_bot") or "bot_1") end
function mod.clear_bots_key(self) mod.despawn_all_bots() end

if not mod._perception_hooked then
	mod._perception_hooked = true
	pcall(function()
		mod:hook("GameModeManager", "should_disable_minion_perception", function(func, self, ...)
			if is_shooting_range() and mod:get("ps_enemy_ai") then
				return false
			end
			return func(self, ...)
		end)
	end)
end

if not mod._pacing_hooked then
	mod._pacing_hooked = true
	pcall(function()
		local PacingManager = require("scripts/managers/pacing/pacing_manager")
		if PacingManager and PacingManager.update then
			mod:hook(PacingManager, "update", function(func, self, dt, t)
				if is_shooting_range() then return end
				return func(self, dt, t)
			end)
		end
	end)
end

if not mod._bot_hud_hooked then
	mod._bot_hud_hooked = true
	pcall(function()
		local TeamPanelHandler = require("scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler")
		local PlayerCompositions = require("scripts/utilities/players/player_compositions")
		local PersonalPanel = require("scripts/ui/hud/elements/personal_player_panel/hud_element_personal_player_panel")
		local FullTeamPanel = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel")

		local function bot_hud_on()
			return is_shooting_range() and mod:get("ps_show_bot_hud") ~= false
		end

		mod:hook(TeamPanelHandler, "init", function(func, self, ...)
			func(self, ...)
			pcall(function()
				if bot_hud_on() then self._player_composition_name = "players" end
			end)
		end)

		mod:hook(TeamPanelHandler, "_add_panel", function(func, self, unique_id, ui_renderer, fixed_scenegraph_id)
			if not bot_hud_on() then
				return func(self, unique_id, ui_renderer, fixed_scenegraph_id)
			end
			local composition = self._player_composition_name
			local player = PlayerCompositions.player_from_unique_id(composition, unique_id)
			if not player then
				return func(self, unique_id, ui_renderer, fixed_scenegraph_id)
			end
			local scenegraph_id = fixed_scenegraph_id or self:_get_available_scenegraph()
			if not scenegraph_id then
				return func(self, unique_id, ui_renderer, fixed_scenegraph_id)
			end
			local is_my_player = self._my_player == player
			local data = {
				synced = false,
				unique_id = unique_id,
				player = player,
				is_my_player = is_my_player,
				local_player = self._my_player,
				scenegraph_id = scenegraph_id,
				using_fixed_scenegraph_id = fixed_scenegraph_id ~= nil,
			}
			local panel
			local ok = pcall(function()
				local scale = ui_renderer.scale or 1
				if is_my_player then
					panel = PersonalPanel:new(self._parent, self._draw_layer, scale, data)
				else
					panel = FullTeamPanel:new(self._parent, self._draw_layer, scale, data)
				end
			end)
			if not ok or not panel then
				return func(self, unique_id, ui_renderer, fixed_scenegraph_id)
			end
			data.panel = panel
			self._player_panels_array[#self._player_panels_array + 1] = data
			self._player_panel_by_unique_id[unique_id] = data
			self._unique_id_by_scenegraph[scenegraph_id] = unique_id
			self._num_panels = self._num_panels + 1
		end)
	end)
end

if not mod._hud_ext_guard_hooked then
	mod._hud_ext_guard_hooked = true
	pcall(function()
		local UIHud = require("scripts/managers/ui/ui_hud")
		mod:hook(UIHud, "player_extensions", function(func, self)
			local ext = func(self)
			if is_shooting_range() and ext and ext.unit and not Unit.alive(ext.unit) then
				self._extensions = nil
				return nil
			end
			return ext
		end)
	end)
end

function mod.toggle_no_stagger(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_no_stagger_range_only")) return end
	local on = not mod:get("ps_no_stagger")
	mod:set("ps_no_stagger", on, false)
	mod:notify(on and mod:localize("notify_no_stagger_on") or mod:localize("notify_no_stagger_off"))
end

if not mod._stagger_hooked then
	mod._stagger_hooked = true
	pcall(function()
		local Stagger = require("scripts/utilities/attack/stagger")
		local BreedU = require("scripts/utilities/breed")
		local function no_stagger_on()
			return is_shooting_range() and mod:get("ps_no_stagger")
		end
		local function is_minion_unit(unit)
			local ok, res = pcall(function()
				local ude = ScriptUnit.has_extension(unit, "unit_data_system")
				return (ude and BreedU.is_minion(ude:breed())) and true or false
			end)
			return ok and res or false
		end
		mod:hook(Stagger, "apply_stagger", function(func, unit, ...)
			if no_stagger_on() and is_minion_unit(unit) then return false end
			return func(unit, ...)
		end)
		mod:hook(Stagger, "force_stagger", function(func, unit, ...)
			if no_stagger_on() and is_minion_unit(unit) then return end
			return func(unit, ...)
		end)
	end)
end

local BOT_MODES = { "active", "passive", "frozen" }

function mod.bot_mode()
	local m = mod:get("ps_bot_mode")
	if m ~= "passive" and m ~= "frozen" then return "active" end
	return m
end

function mod.cycle_bot_mode(self)
	if not is_shooting_range() then mod:notify(mod:localize("notify_bot_mode_range_only")) return end
	local cur = mod.bot_mode()
	local idx = 1
	for i = 1, #BOT_MODES do
		if BOT_MODES[i] == cur then idx = i break end
	end
	local nxt = BOT_MODES[(idx % #BOT_MODES) + 1]
	mod:set("ps_bot_mode", nxt, false)
	mod:notify(LF("notify_bot_mode_fmt", mod:localize("bot_mode_" .. nxt)))
end

if not mod._bot_mode_hooked then
	mod._bot_mode_hooked = true
	pcall(function()
		local BotBehaviorExtension = require("scripts/extension_systems/behavior/bot_behavior_extension")
		local Blackboard = require("scripts/extension_systems/blackboard/utilities/blackboard")

		local function clear_bot_targets(unit)
			local bbs = rawget(_G, "BLACKBOARDS")
			local blackboard = bbs and bbs[unit]
			if not blackboard then return end
			local pc = Blackboard.write_component(blackboard, "perception")
			if not pc then return end
			pc.target_enemy = nil
			pc.target_enemy_distance = math.huge
			pc.target_enemy_type = "none"
			pc.aggro_target_enemy = nil
			pc.aggro_target_enemy_distance = 0
			pc.opportunity_target_enemy = nil
			pc.priority_target_enemy = nil
			pc.urgent_target_enemy = nil
		end

		mod:hook(BotBehaviorExtension, "update", function(func, self, unit, dt, t, ...)
			if is_shooting_range() then
				local mode = mod.bot_mode()
				if mode == "frozen" then return end
				if mode == "passive" then pcall(function() clear_bot_targets(unit) end) end
			end
			return func(self, unit, dt, t, ...)
		end)
	end)
end

function mod.continuous_refill()
	if not mod._continuous then return end
	if not is_server() or not is_shooting_range() then return end
	local group = mod._last_group
	if not group or #group == 0 then return end
	local target = #group
	local alive = mod.count_alive and mod.count_alive() or 0
	local need = target - alive
	if need <= 0 then return end
	local list = {}
	for i = 1, need do list[i] = group[((i - 1) % #group) + 1] end
	mod.spawn_list(list, false, true)
end

local function spawn_slot(slot_setting)
	local breed = mod:get(slot_setting)
	if not breed or breed == "none" then
		mod:notify(mod:localize("notify_quick_slot_empty"))
		return
	end
	mod.spawn_breed(breed, mod:get("ps_spawn_count") or 1, true)
end

function mod.spawn_slot_1(self) spawn_slot("ps_slot_1") end
function mod.spawn_slot_2(self) spawn_slot("ps_slot_2") end
function mod.spawn_slot_3(self) spawn_slot("ps_slot_3") end
function mod.spawn_slot_4(self) spawn_slot("ps_slot_4") end

function mod.menu_spawn(breed_name)

	local count = mod:get("ps_spawn_count") or 1
	if mod:get("ps_select_mode") then
		return mod.queue_add(breed_name, count)
	end
	mod.spawn_breed(breed_name, count, false)
end

function mod.open_menu(self)
	if not is_shooting_range() then
		mod:notify(mod:localize("notify_open_psykhanium"))
		return
	end
	if Managers.ui:view_active(VIEW_NAME) then
		Managers.ui:close_view(VIEW_NAME)
		return
	end

	refresh_settings()
	local aim = position_at_cursor(get_player())
	mod._menu_spawn_position = aim and Vector3Box(aim) or nil
	mod.queue_clear()
	mod.build_breed_lists()

	local context = { spawner_mod = mod }
	local ok = pcall(function()
		Managers.ui:open_view(VIEW_NAME, nil, nil, nil, nil, context)
	end)
	if not ok then
		mod:notify(mod:localize("notify_menu_failed"))
	end
end

local function register_menu_view()
	local ok, err = pcall(function()
		mod:add_require_path("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_view")
		mod:add_require_path("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_view_definitions")

		mod:register_view({
			view_name = VIEW_NAME,
			view_settings = {
				init_view_function = function(ingame_ui_context)
					return true
				end,
				class              = "PsykhaniumSpawnerView",
				path               = "ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_view",
				package            = "packages/ui/views/options_view/options_view",
				display_name       = "psy_menu_title",
				disable_game_world = false,
				game_world_blur    = 0.6,
				load_always        = true,
				state_bound        = true,
				enter_sound_events = { "wwise/events/ui/play_ui_enter_short" },
				exit_sound_events  = { "wwise/events/ui/play_ui_back_short" },
			},
			view_transitions = {},
			view_options = {
				close_all = false,
				close_previous = false,
			},
		})

		mod:io_dofile("ImprovedMeatGrinder/scripts/mods/ImprovedMeatGrinder/ImprovedMeatGrinder_view")
	end)
	if not ok then
		mod:warning(LF("notify_menu_view_failed", tostring(err)))
	end
end

mod.on_all_mods_loaded = function()
	refresh_settings()
	register_menu_view()
end

mod.on_setting_changed = function(setting_name)
	refresh_settings()

	if setting_name == "ps_no_default_enemies" and mod:get("ps_no_default_enemies") then
		mod._pending_clear_defaults = true
	end
end

mod.on_game_state_changed = function(status, state_name)

	if status == "enter" and state_name == "StateGameplay" then
		pcall(mod.build_breed_lists)
	end
end

pcall(function()
	local WarpCharge = require("scripts/utilities/warp_charge")
	if WarpCharge and WarpCharge.wants_warp_charge_character_state then
		mod:hook(WarpCharge, "wants_warp_charge_character_state", function(func, unit, unit_data_extension)
			if is_shooting_range() and (mod._god.no_peril_death or mod._god.no_peril_gain) then
				return false
			end
			return func(unit, unit_data_extension)
		end)
	end
end)

local MasterItems
pcall(function() MasterItems = require("scripts/backend/master_items") end)

local function deepcopy(orig, copies)
	if type(orig) ~= "table" then return orig end
	copies = copies or {}
	if copies[orig] then return copies[orig] end
	local copy = {}
	copies[orig] = copy
	for k, v in next, orig, nil do copy[deepcopy(k, copies)] = deepcopy(v, copies) end
	return copy
end

pcall(function()
	mod:hook("MinionVisualLoadoutExtension", "init", function(func, self, ctx, unit, init_data, ...)
		if not is_shooting_range() or not MasterItems then
			return func(self, ctx, unit, init_data, ...)
		end
		local ok, cleaned = pcall(function()
			local data = deepcopy(init_data)
			local slots = data.inventory and data.inventory.slots
			if not slots then return data end
			local defs = MasterItems.get_cached()
			local kept_slots = {}
			for slot_name, slot_data in pairs(slots) do
				if not slot_data.is_material_override_slot then
					local items = slot_data.items
					local kept = {}
					if items then
						for i = 1, #items do
							if defs[items[i]] then kept[#kept + 1] = items[i] end
						end
					end
					if #kept > 0 then
						slot_data.items = kept
					elseif items and #items ~= 0 then
						slot_data = nil
					end
				end
				if slot_data then kept_slots[slot_name] = slot_data end
			end
			data.inventory.slots = kept_slots
			return data
		end)
		if ok and cleaned then
			return func(self, ctx, unit, cleaned, ...)
		end
		return func(self, ctx, unit, init_data, ...)
	end)
end)

pcall(function()
	mod:hook("MinionSuppressionExtension", "_get_threshold_and_max_value", function(func, self)
		if not is_shooting_range() then return func(self) end
		local combat_range = self._behavior_component and self._behavior_component.combat_range
		local dm = Managers.state and Managers.state.difficulty
		local threshold = self._suppress_threshold or 9999
		if type(threshold) == "table" then
			threshold = threshold[combat_range] or 9999
			if type(threshold) == "table" then
				threshold = (dm and dm:get_table_entry_by_challenge(threshold)) or 9999
			end
		end
		local max_value = self._max_suppress_value or 9999
		if type(max_value) == "table" then
			max_value = max_value[combat_range] or 9999
			if type(max_value) == "table" then
				max_value = (dm and dm:get_table_entry_by_challenge(max_value)) or 9999
			end
		end
		return threshold, max_value
	end)
end)

do
	local function guard_particle(name)
		pcall(function()
			if rawget(_G, "World") and World[name] then
				mod:hook(World, name, function(func, ...)
					if not is_shooting_range() then return func(...) end
					local ok, res = pcall(func, ...)
					if ok then return res end
					return nil
				end)
			end
		end)
	end
	guard_particle("create_particles")
	guard_particle("create_particles_linked")
	guard_particle("destroy_particles")
	guard_particle("stop_spawning_particles")
end

local function lineup_missing_breeds(vanilla_set)
	local bosses, others = {}, {}
	for name in pairs(breeds_data.categories or {}) do
		if name ~= "attack_valkyrie"
			and not (breeds_data.blacklist and breeds_data.blacklist[name])
			and not vanilla_set[name]
			and Breeds[name] then
			local is_boss = false
			for _, c in ipairs(breeds_data.categories[name]) do
				if c == "boss" then is_boss = true break end
			end
			if is_boss then bosses[#bosses + 1] = name else others[#others + 1] = name end
		end
	end
	table.sort(bosses)
	table.sort(others)
	local out = {}
	for _, n in ipairs(bosses) do out[#out + 1] = n end
	for _, n in ipairs(others) do out[#out + 1] = n end
	return out
end

local LINEUP_ORDER = {
	"chaos_ogryn_houndmaster", "GAP",
	"chaos_beast_of_nurgle", "GAP",
	"chaos_plague_ogryn", "GAP",
	"chaos_spawn", "GAP",
	"chaos_daemonhost",
	"GAP",
	"renegade_twin_captain",
	"renegade_twin_captain_two",
	"cultist_captain",
	"renegade_captain",
	"cultist_ritualist",
	"chaos_armored_hound",
	"renegade_radio_operator",
	"renegade_vanguard",
	"cultist_vanguard",
	"GAP",
	"chaos_poxwalker_bomber",
}

mod:hook_require("scripts/extension_systems/training_grounds/shooting_range_steps", function(instance)
	local function delete_unit(u)
		local us = Managers.state and Managers.state.unit_spawner
		if u and us and us.mark_for_deletion and Unit.alive(u) then
			pcall(function() us:mark_for_deletion(u) end)
		end
	end

	local loop_keys = { "weak_enemies_loop", "medium_enemies_loop", "heavy_enemies_loop" }
	for _, key in ipairs(loop_keys) do
		local step = instance[key]
		if step then

			local orig_cond = step.condition_func
			step.condition_func = function(...)
				if mod:get("ps_no_default_enemies") then return end
				if orig_cond then return orig_cond(...) end
			end

			local orig_on_event = step.on_event
			step.on_event = function(...)
				if mod:get("ps_no_default_enemies") then return end
				if orig_on_event then return orig_on_event(...) end
			end
		end
	end

	local function img_remove(u)
		if not (u and Unit.alive(u)) then return end
		local us = Managers.state and Managers.state.unit_spawner
		if us then pcall(function() us:mark_for_deletion(u) end) end
	end

	local function img_spawn(breed_name, du)
		local spawner = Managers.state and Managers.state.minion_spawn
		if not (spawner and du and Unit.alive(du)) then return nil end
		local params = { optional_aggro_state = "aggroed" }
		local pu = get_player_unit()
		if pu and Unit.alive(pu) then params.optional_target_unit = pu end
		local pos = Unit.local_position(du, 1)
		local rot = Unit.local_rotation(du, 1)
		local ok, unit = pcall(function() return spawner:spawn_minion(breed_name, pos, rot, 2, params) end)
		return ok and unit or nil
	end

	local function img_clear(step_data)
		if not step_data.img_slots then return end
		for _, slot in ipairs(step_data.img_slots) do
			if slot.unit then img_remove(slot.unit) end
			slot.unit = nil
			slot.respawn_t = nil
			slot.spawned_t = nil
		end
	end

	local function img_maintain(step_data, t)
		if not step_data.img_slots then return end
		local health_alive = rawget(_G, "HEALTH_ALIVE")
		for _, slot in ipairs(step_data.img_slots) do
			local alive
			if slot.unit then
				if slot.spawned_t and t < slot.spawned_t + 3 then
					alive = true
				elseif health_alive then
					alive = health_alive[slot.unit]
				else
					alive = Unit.alive(slot.unit)
				end
			end
			if not alive then
				if slot.unit and not slot.respawn_t then
					slot.respawn_t = t + 2
				elseif (not slot.unit) or (slot.respawn_t and t > slot.respawn_t) then
					if slot.unit then img_remove(slot.unit) end
					slot.respawn_t = nil
					slot.unit = img_spawn(slot.breed, slot.du)
					slot.spawned_t = t
				end
			end
		end
	end

	if instance.enemies_loop then
		local orig_start = instance.enemies_loop.start_func
		instance.enemies_loop.start_func = function(scenario_system, player, scenario_data, step_data, t)
			if orig_start then orig_start(scenario_system, player, scenario_data, step_data, t) end
			step_data.img_slots = {}
			step_data.img_swap_state = nil
			local sds = step_data.spawn_datas
			if not sds then return end
			local vanilla = {}
			for _, sd in pairs(sds) do
				if sd.breed_name then vanilla[sd.breed_name] = true end
			end
			local missing = lineup_missing_breeds(vanilla)
			local missing_set = {}
			for _, n in ipairs(missing) do missing_set[n] = true end
			local ordered, used = {}, {}
			for _, name in ipairs(LINEUP_ORDER) do
				if name == "GAP" then
					ordered[#ordered + 1] = false
				elseif missing_set[name] and not used[name] then
					ordered[#ordered + 1] = name
					used[name] = true
				end
			end
			for _, n in ipairs(missing) do
				if not used[n] then ordered[#ordered + 1] = n; used[n] = true end
			end
			local slots = {}
			local cx, cy = 0, 0
			for du in pairs(sds) do
				if du and Unit.alive(du) then
					local p = Unit.local_position(du, 1)
					local sx, sy = Vector3.x(p), Vector3.y(p)
					slots[#slots + 1] = { du = du, x = sx, y = sy }
					cx = cx + sx
					cy = cy + sy
				end
			end
			local n = #slots
			if n > 0 then cx = cx / n; cy = cy / n end

			for _, s in ipairs(slots) do s.ang = math.atan2(s.y - cy, s.x - cx) end
			table.sort(slots, function(a, b) return a.ang < b.ang end)

			if n > 2 then
				local max_gap, start_i = -1, 1
				for i = 1, n do
					local nxt = slots[i % n + 1]
					local gap = nxt.ang - slots[i].ang
					if gap < 0 then gap = gap + 2 * math.pi end
					if gap > max_gap then max_gap = gap; start_i = i % n + 1 end
				end
				local rotated = {}
				for k = 0, n - 1 do rotated[k + 1] = slots[(start_i - 1 + k) % n + 1] end
				slots = rotated
			end
			for i = 1, #slots do
				local breed = ordered[i]
				if breed then
					step_data.img_slots[#step_data.img_slots + 1] = { du = slots[i].du, breed = breed }
				end
			end
		end

		local orig_cond = instance.enemies_loop.condition_func
		instance.enemies_loop.condition_func = function(scenario_system, player, scenario_data, step_data, t)
			if mod:get("ps_no_default_enemies") then
				img_clear(step_data)
				step_data.img_swap_state = nil
				return
			end
			local swap_on = mod:get("ps_swap_lineup") and true or false

			if swap_on ~= step_data.img_swap_state then
				step_data.img_swap_state = swap_on
				if step_data.img_slots then
					for _, slot in ipairs(step_data.img_slots) do
						slot.unit = nil
						slot.respawn_t = nil
						slot.spawned_t = nil
					end
				end
				local flip_sds = step_data.spawn_datas
				if flip_sds then
					for _, sd in pairs(flip_sds) do
						sd.unit = nil
						sd.dissolve_t = nil
					end
				end
				if Managers.state and Managers.state.minion_spawn then
					pcall(function() Managers.state.minion_spawn:delete_units() end)
				end
			end
			if swap_on then
				local sds = step_data.spawn_datas
				if sds then
					for _, sd in pairs(sds) do
						if sd.unit then img_remove(sd.unit); sd.unit = nil; sd.dissolve_t = nil end
					end
				end
				img_maintain(step_data, t)
			else
				if orig_cond then orig_cond(scenario_system, player, scenario_data, step_data, t) end
			end
		end
	end

	if instance.sr_unperceivable_loop then
		instance.sr_unperceivable_loop.condition_func = function(scenario_system, player, scenario_data, step_data, t)
			if not (player and player.player_unit and Unit.alive(player.player_unit)) then
				return false
			end
			local player_unit = player.player_unit
			if not (mod.invisible_on and mod.invisible_on()) then

				if scenario_system:has_scenario_buff(player_unit, "tg_player_unperceivable") then
					scenario_system:remove_scenario_buff(player_unit, "tg_player_unperceivable")
				end
			else

				if not scenario_system:has_scenario_buff(player_unit, "tg_player_unperceivable") then
					scenario_system:add_scenario_buff(player_unit, "tg_player_unperceivable", t)
				end
			end
			pcall(function()
				local ai_on = mod:get("ps_enemy_ai") and true or false
				local players = Managers.player and Managers.player:players()
				if players then
					for _, p in pairs(players) do
						if p ~= player and p.player_unit and Unit.alive(p.player_unit)
							and not (p.is_human_controlled and p:is_human_controlled()) then
							local bu = p.player_unit
							if ai_on then
								if scenario_system:has_scenario_buff(bu, "tg_player_unperceivable") then
									scenario_system:remove_scenario_buff(bu, "tg_player_unperceivable")
								end
							else
								if not scenario_system:has_scenario_buff(bu, "tg_player_unperceivable") then
									scenario_system:add_scenario_buff(bu, "tg_player_unperceivable", t)
								end
							end
						end
					end
				end
			end)
			return false
		end
	end

	if instance.pickup_loop then
		local orig = instance.pickup_loop.condition_func
		local keys = {
			"med_unit", "ammo_unit", "grenade_unit", "syringe_corruption_unit",
			"syringe_ability_boost_unit", "syringe_power_boost_unit", "syringe_speed_boost_unit",
		}
		instance.pickup_loop.condition_func = function(scenario_system, player, scenario_data, step_data, t)
			if mod:get("ps_no_props") then
				for i = 1, #keys do
					delete_unit(step_data[keys[i]])
					step_data[keys[i]] = nil
				end
				return false
			end
			if orig then return orig(scenario_system, player, scenario_data, step_data, t) end
			return false
		end
	end

	if instance.chest_loop then
		local orig = instance.chest_loop.condition_func
		instance.chest_loop.condition_func = function(scenario_system, player, scenario_data, step_data, t)
			if mod:get("ps_no_props") then
				delete_unit(step_data.loadout_unit)
				step_data.loadout_unit = nil
				return false
			end
			if orig then return orig(scenario_system, player, scenario_data, step_data, t) end
			return false
		end
	end
end)

refresh_settings()
