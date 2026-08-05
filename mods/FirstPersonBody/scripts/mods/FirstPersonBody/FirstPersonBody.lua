local mod = get_mod("FirstPersonBody")

-- ---------------------------------------------------------------------------
-- First Person Body
-- ---------------------------------------------------------------------------
-- Shows your own body in first person: correctly posed, correctly animated
-- legs, hips and lower torso when you look down, while the head, upper body
-- and third person weapons stay hidden so nothing blocks the camera, and the
-- normal first person arms and weapon stay exactly as they were.
--
-- How it works, four engine rules discovered the hard way:
--   1. The game decides two things every frame in one function: "should the
--      CAMERA be first person" and "should the EQUIPMENT render first
--      person". This mod intercepts that function and lies only about the
--      second answer, so the camera stays first person while the equipment
--      system keeps the whole third person body spawned, posed and animated
--      by the game itself.
--   2. Once the character's base unit is shown, per-unit visibility on its
--      child units is ignored by the renderer, and flow events only work on
--      units whose flow graphs implement them (face, hair, skin). The only
--      channel that hides ARBITRARY gear and weapon units is per-MESH
--      visibility (Unit.set_mesh_visibility), so that is what hides the
--      occluders. Mesh states are snapshotted first so items that already
--      hide meshes on purpose (weapon skin kitbashes) restore correctly.
--   3. Waking first person units while the equipment system is in third
--      person mode works per-unit, so the viewmodel (arms and weapon) is
--      woken back up after the game's third person pass hides it.
--   4. Every character carries an engine-level camera-proximity dither fade
--      (fully invisible when the camera is closer than ~0.5m to the spine,
--      which in first person is always). While active, the fade system is
--      fed a camera position far away so the fade never engages.
--
-- Compatible with Perspectives: its third person mode sets the game's own
-- _force_third_person_mode flag, which this mod treats as "hands off".

mod.version = "1.11.0"

mod._poll_ttl = 0
mod._diag_delay = 5

-- ---------------------------------------------------------------------------
-- First person lower body
-- ---------------------------------------------------------------------------
-- Earlier attempts flagged the lower body items as first person visible, which
-- made the game spawn them on the FIRST PERSON rig. That rig cannot pose legs,
-- so the meshes collapsed near the camera (the famous floating shoe soles).
--
-- The working approach: every gear slot has two spawned units, one for each
-- perspective, and in first person the game merely hides the third person one
-- (equipment_component.update_item_visibility calls set_unit_visibility on
-- slot.unit_3p). The third person body keeps animating regardless, it is what
-- casts your shadow. So while the camera is in first person, this simply shows
-- the third person units of the lower body slots again: correctly posed,
-- correctly animated legs, no rig tricks needed. The upper body stays hidden,
-- so nothing can block the camera.
--
-- The game re-hides those units whenever it re-evaluates visibility (wield
-- changes, perspective changes), so this is re-applied every update.

local REVEAL_SLOTS = { "slot_gear_lowerbody", "slot_body_legs" }

local function local_player_unit()
	local player_manager = Managers.player
	local player = player_manager and player_manager:local_player_safe(1)

	return player and player.player_unit
end

local function in_first_person(unit)
	local ext = ScriptUnit.has_extension(unit, "unit_data_system")

	if not ext then
		return false
	end

	local ok, component = pcall(ext.read_component, ext, "first_person_mode")

	return ok and component ~= nil and component.wants_1p_camera == true
end

-- ============================================================
-- v1.16: inverted architecture, "the accidental state on purpose".
--
-- Field evidence across v1.10 to v1.15: waking individual THIRD person units
-- while the game is in first person visibility mode never renders them, no
-- matter the mechanism (unit visibility, object visibility, per-mesh force,
-- flow events, base unit, attachments, per-frame bursts). But the game itself
-- rendered the full third person body under a first person camera twice:
-- during every perspective transition, and in the screenshotted "accidental"
-- state, legs and arms correctly posed and animated. And v1.12's floating
-- arms bug proved the OPPOSITE direction works: first person units woken
-- while the game is in third person visibility mode render fine.
--
-- Conclusion: the game's 1p visibility mode is a one way door for 3p units.
-- The only state that renders 3p legs under a 1p camera is the game's own
-- 3p visibility mode. So v1.16 keeps the EQUIPMENT system in third person
-- mode while the CAMERA stays first person:
--   1. Hook _update_first_person_mode, return (false, wants_1p): equipment
--      mode 3p, camera untouched. The game runs its own 3p visibility pass,
--      base unit shown, legs shown, all bookkeeping done by the game.
--   2. Hide the 3p parts that would block or duplicate the view (head,
--      torso, arms, wielded weapon, backpack). Hiding, unlike showing,
--      works reliably in any mode.
--   3. Wake the 1p viewmodel (rig, weapon, arms) that the 3p pass hid,
--      exactly the v1.12 proven direction.

local REVEAL_SET = { slot_gear_lowerbody = true, slot_body_legs = true }

-- Fire a flow event the way the game does: on the slot unit and on every
-- attachment child unit registered for it.
local function fp_slot_flow(slot, base_unit, attachments_by_unit, event_name)
	if not base_unit or not Unit.alive(base_unit) then
		return
	end

	pcall(Unit.flow_event, base_unit, event_name)

	local attachments = attachments_by_unit and attachments_by_unit[base_unit]

	if attachments then
		for i = 1, #attachments do
			local attachment_unit = attachments[i]

			if attachment_unit and Unit.alive(attachment_unit) then
				pcall(Unit.flow_event, attachment_unit, event_name)
			end
		end
	end
end

-- The game's attachments_by_unit tables are TREES keyed by parent unit:
-- [weapon_base] = {receiver}, [receiver] = {barrel, stock, ...}. Reading
-- only the base key (as earlier versions did) misses every nested part,
-- which is where EWC keeps a weapon's actual meshes. Iterate the WHOLE map.
local function for_each_attachment(map, fn)
	if type(map) ~= "table" then
		return
	end

	for _, children in pairs(map) do
		if type(children) == "table" then
			for i = 1, #children do
				local attachment_unit = children[i]

				if attachment_unit and Unit.alive(attachment_unit) then
					fn(attachment_unit)
				end
			end
		end
	end
end

-- Render wake-up for one unit, in two strengths.
--
-- DEEP (the default): unit visibility, then object visibility, then every
-- mesh forced visible by index. Needed for SKINNED units (the first person
-- rig, arms, sleeves, legs), because per-unit visibility is ignored for
-- those and per-mesh is the only channel that reaches them.
--
-- GENTLE (deep == false): unit visibility only, which is exactly the channel
-- the game itself uses to hide and show first person weapons. Used for
-- WEAPONS, and the reason is a bug report from a user running the public
-- Extended Weapon Customization (v1.7.0): the deep wake was too strong for
-- rigid weapon parts. Customization mods hide the parts a kitbash replaces
-- by making their meshes invisible, and switch flashlight lamps off by
-- disabling unit objects. Forcing every mesh and object back on therefore
-- un-did all of that, and their weapon showed a stub revolver body and its
-- replacement at once, spare placeholder parts, and a flashlight that could
-- not be turned off. Rigid parts obey plain unit visibility, so the gentle
-- wake reaches the weapon without touching anything another mod has hidden.
local function wake_unit_render(unit, deep)
	Unit.set_unit_visibility(unit, true, true)

	if deep == false then
		return
	end

	-- REVERTED in v1.10.6, and the reason is worth keeping. v1.10.5 dropped
	-- the second flag here to stop this call reaching down the first person
	-- rig and switching a weapon's flashlight lamp on. It did stop that, and
	-- it also stopped the weapon rendering at all: what looked like an
	-- over-broad "and everything below" is in fact the flag that makes this
	-- call reach the objects the viewmodel is actually built from. Held
	-- weapons vanished from the player's hands. The flashlight is a real
	-- bug, but it is the smaller one, and it needs a fix that names the
	-- lamp rather than one that turns the wake down.
	pcall(Unit.set_unit_objects_visibility, unit, true, true)

	local ok, num_meshes = pcall(Unit.num_meshes, unit)

	if ok and type(num_meshes) == "number" and num_meshes > 0 then
		for i = 1, num_meshes do
			pcall(Unit.set_mesh_visibility, unit, i, true)
		end
	end
end

-- Occluder hiding, the game's own way. Field evidence (v1.14 through v1.16):
-- per-unit visibility calls from Lua lose against the game's recursive base
-- unit show/hide in BOTH directions, so hiding the torso with our own calls
-- silently fails exactly like showing the legs did. The game's native channel
-- for "hide this slot regardless of mode" is an item property: hide_slots.
-- Its visibility pass re-reads the lists from every equipped item on every
-- update and enforces them itself, with its own internal ordering. So while
-- the trick is active, one equipped gear item gets tagged with our occluder
-- list, and the game does all the hiding. Untag on exit, everything reverts.
local FP_HIDE_SLOTS = {
	"slot_primary",
	"slot_secondary",
	"slot_gear_head",
	"slot_gear_upperbody",
	"slot_gear_extra_cosmetic",
	"slot_body_torso",
	"slot_body_arms",
	"slot_body_face",
	"slot_body_hair",
}

local fp_tagged_item = nil
local fp_original_hide_slots = nil

-- Write the merged list onto one item and VERIFY it took. Some item tables
-- (NPC Look proxies over master data) reject plain writes, so fall back to
-- rawset, and only report success when a read-back returns our table.
local function fp_try_tag(item)
	if not item then
		return false
	end

	local original = item.hide_slots
	local merged = {}

	if type(original) == "table" then
		for i = 1, #original do
			merged[#merged + 1] = original[i]
		end
	end

	for i = 1, #FP_HIDE_SLOTS do
		merged[#merged + 1] = FP_HIDE_SLOTS[i]
	end

	pcall(function()
		item.hide_slots = merged
	end)

	if item.hide_slots ~= merged then
		pcall(rawset, item, "hide_slots", merged)
	end

	if item.hide_slots ~= merged then
		return false
	end

	fp_tagged_item = item
	fp_original_hide_slots = original
	mod._fp_tag_name = item.name or "unnamed"

	return true
end

local function fp_tag_carrier(equipment, wielded_slot_name)
	if fp_tagged_item then
		for _, slot in pairs(equipment) do
			if slot.item == fp_tagged_item then
				-- Tag still in place on an equipped item. Re-assert the diag
				-- name in case something cleared it.
				mod._fp_tag_name = mod._fp_tag_name or fp_tagged_item.name or "tagged, unnamed"

				return false
			end
		end

		-- The carrier left the loadout; its item table is gone with it.
		fp_tagged_item = nil
		fp_original_hide_slots = nil
		mod._fp_tag_name = nil
	end

	-- Candidate carriers in order of preference: gear first, then any
	-- equipped non-weapon slot, the wielded weapon last (EWC-built weapon
	-- items are plain writable tables, so that one always accepts the tag).
	local candidates = {}
	local preferred = { "slot_gear_lowerbody", "slot_gear_upperbody", "slot_body_torso", "slot_body_legs", "slot_body_arms" }

	for i = 1, #preferred do
		local slot = equipment[preferred[i]]

		if slot and slot.equipped and slot.item then
			candidates[#candidates + 1] = slot.item
		end
	end

	for slot_name, slot in pairs(equipment) do
		if slot.equipped and slot.item and not slot.wieldable and not string.find(slot_name, "companion") then
			candidates[#candidates + 1] = slot.item
		end
	end

	local wielded_slot = wielded_slot_name and equipment[wielded_slot_name]

	if wielded_slot and wielded_slot.equipped and wielded_slot.item then
		candidates[#candidates + 1] = wielded_slot.item
	end

	for i = 1, #candidates do
		if fp_try_tag(candidates[i]) then
			return true -- newly tagged: caller should run a game visibility pass
		end
	end

	mod._fp_tag_name = "TAG FAILED (" .. tostring(#candidates) .. " candidates)"

	return false
end

local function fp_untag_carrier()
	if not fp_tagged_item then
		return false
	end

	local item = fp_tagged_item

	pcall(function()
		item.hide_slots = fp_original_hide_slots
	end)

	fp_tagged_item = nil
	fp_original_hide_slots = nil
	mod._fp_tag_name = nil

	return true
end

-- Mesh-level hiding. Unified render model, settled by v1.19/v1.20 field
-- data: once the character's base unit is shown, child units render as part
-- of it and PER-UNIT visibility on them is ignored (the game's own hide of
-- the torso ran, flag proved it, mesh still drew). Flow events only work on
-- units whose graphs implement them (face, hair, body skin, 1p units),
-- which is exactly why the face vanished but gear and weapons did not. The
-- channel that works on ARBITRARY units is per-MESH visibility, the same
-- API the EWC hide fixes use, proven on weapons and gear in both
-- perspectives.
-- Some meshes are intentionally hidden already (EWC hide fixes on skinned
-- weapons), so before hiding a unit its mesh states are snapshotted (when
-- the engine exposes a getter) and restore replays the snapshot instead of
-- blindly switching everything on.
local fp_mesh_snapshots = {}
local fp_in_tripwire = false

local function snapshot_meshes(unit)
	if fp_mesh_snapshots[unit] ~= nil then
		return
	end

	local ok, num_meshes = pcall(Unit.num_meshes, unit)

	if not ok or type(num_meshes) ~= "number" then
		fp_mesh_snapshots[unit] = false

		return
	end

	local snap = {}
	local getter = Unit.is_mesh_visible

	for i = 1, num_meshes do
		if getter then
			local g_ok, vis = pcall(getter, unit, i)

			snap[i] = not (g_ok and vis == false)
		else
			snap[i] = true
		end
	end

	fp_mesh_snapshots[unit] = snap
end

local fp_mesh_hidden_units = {}

local function hide_all_meshes(unit)
	if not unit or not Unit.alive(unit) then
		return
	end

	snapshot_meshes(unit)

	local ok, num_meshes = pcall(Unit.num_meshes, unit)

	if ok and type(num_meshes) == "number" and num_meshes > 0 then
		fp_mesh_hidden_units[unit] = num_meshes

		for i = 1, num_meshes do
			pcall(Unit.set_mesh_visibility, unit, i, false)
		end
	end
end

-- Weapons resist every visibility channel (their meshes live in units the
-- child walk cannot always reach, and their scripts re-show them), so they
-- get a channel nothing re-asserts: SCALE. Collapsing the slot unit's root
-- scale to near zero collapses the entire linked tree with it, proven in
-- this game by the EWC hide-fix work where an accidental parent zero-scale
-- collapsed every child. Original scales are snapshotted and restored.
local fp_scaled_units = {}

local function scale_hide_unit(unit)
	if not unit or not Unit.alive(unit) then
		return
	end

	if fp_scaled_units[unit] == nil then
		local ok, original = pcall(Unit.local_scale, unit, 1)

		fp_scaled_units[unit] = (ok and original and Vector3Box and Vector3Box(original)) or true
	end

	pcall(Unit.set_local_scale, unit, 1, Vector3(0.0001, 0.0001, 0.0001))
	Unit.set_unit_visibility(unit, false, true)
	pcall(Unit.set_unit_objects_visibility, unit, false, true)
end

local function scale_restore_unit(unit)
	local saved = fp_scaled_units[unit]

	if saved == nil then
		return
	end

	fp_scaled_units[unit] = nil

	if not unit or not Unit.alive(unit) then
		return
	end

	local scale

	if saved ~= true and saved.unbox then
		local ok, unboxed = pcall(saved.unbox, saved)

		if ok then
			scale = unboxed
		end
	end

	pcall(Unit.set_local_scale, unit, 1, scale or Vector3(1, 1, 1))
	Unit.set_unit_visibility(unit, true, true)
	pcall(Unit.set_unit_objects_visibility, unit, true, true)
end

-- Weapon flow graphs and per-frame slot scripts re-show weapon meshes
-- continuously (that is also how vanilla stows weapons), so a periodic hide
-- loses the race. This flat loop re-hides every registered unit and is cheap
-- enough to run EVERY FRAME: the last write each frame is ours.
local function reassert_hidden_meshes()
	for unit, num_meshes in pairs(fp_mesh_hidden_units) do
		if Unit.alive(unit) and type(num_meshes) == "number" then
			for i = 1, num_meshes do
				pcall(Unit.set_mesh_visibility, unit, i, false)
			end
		end
	end

	for unit in pairs(fp_scaled_units) do
		if Unit.alive(unit) then
			pcall(Unit.set_local_scale, unit, 1, Vector3(0.0001, 0.0001, 0.0001))
			Unit.set_unit_visibility(unit, false, true)
		end
	end
end

local function restore_meshes(unit)
	if not unit or not Unit.alive(unit) then
		return
	end

	fp_in_tripwire = true

	local snap = fp_mesh_snapshots[unit]
	local ok, num_meshes = pcall(Unit.num_meshes, unit)

	if ok and type(num_meshes) == "number" and num_meshes > 0 then
		for i = 1, num_meshes do
			local visible = true

			if type(snap) == "table" and snap[i] == false then
				visible = false
			end

			pcall(Unit.set_mesh_visibility, unit, i, visible)
		end
	end

	fp_in_tripwire = false
end

local function set_slot_meshes_3p(slot, visible)
	local unit_3p = slot and slot.unit_3p

	if not unit_3p or not Unit.alive(unit_3p) then
		return false
	end

	local worker = visible and restore_meshes or hide_all_meshes

	worker(unit_3p)

	local attachments = slot.attachments_by_unit_3p and slot.attachments_by_unit_3p[unit_3p]

	if attachments then
		for i = 1, #attachments do
			worker(attachments[i])
		end
	end

	return true
end

-- Wake a slot's third person side (lower body): the game's 3p pass already
-- shows it, this is insurance against latched fades, mesh force included.
local function reveal_slot_3p(slot)
	local unit_3p = slot and slot.unit_3p

	if not unit_3p or not Unit.alive(unit_3p) then
		return false
	end

	wake_unit_render(unit_3p)

	local attachments = slot.attachments_by_unit_3p and slot.attachments_by_unit_3p[unit_3p]

	if attachments then
		for i = 1, #attachments do
			local attachment_unit = attachments[i]

			if attachment_unit and Unit.alive(attachment_unit) then
				wake_unit_render(attachment_unit)
			end
		end
	end

	if slot.hidden_3p ~= false then
		slot.hidden_3p = false
		fp_slot_flow(slot, unit_3p, slot.attachments_by_unit_3p, "lua_visible")
	end

	return true
end

-- Wake a slot's first person side (viewmodel: weapon, arms, sleeves).
-- This is the direction the floating arms bug proved renders under 3p mode.
local function reveal_slot_1p(slot, deep)
	local unit_1p = slot and slot.unit_1p

	if not unit_1p or not Unit.alive(unit_1p) then
		return false
	end

	wake_unit_render(unit_1p, deep)

	for_each_attachment(slot.attachments_by_unit_1p, function(attachment_unit)
		wake_unit_render(attachment_unit, deep)
	end)

	if slot.hidden_1p ~= false then
		slot.hidden_1p = false
		fp_slot_flow(slot, unit_1p, slot.attachments_by_unit_1p, "lua_visible")
	end

	return true
end

-- True only when the camera is actually first person right now. Reads the
-- extension's camera want (NOT is_in_first_person_mode, which this very mod
-- now spoofs to false). Perspectives, hubs, knockdowns and cinematics all
-- funnel through _force_third_person_mode or wants_1p, so all are covered.
local function camera_truly_first_person(unit)
	local fp_ext = ScriptUnit.has_extension(unit, "first_person_system")

	if fp_ext then
		if fp_ext._force_third_person_mode then
			return false
		end

		if fp_ext.wants_first_person_camera then
			local ok, wants_1p = pcall(fp_ext.wants_first_person_camera, fp_ext)

			if ok then
				return wants_1p == true
			end
		end
	end

	-- Fallback if the extension is unreachable: the raw component flag.
	return in_first_person(unit)
end

-- THE CORE TRICK. The game recomputes (show_1p_equipment, wants_1p_camera)
-- every frame in this function. When it decides on full first person and the
-- feature is on, lie about the first value only: the camera system keeps
-- reading wants_1p (stays first person), the equipment system reads the
-- spoofed false and keeps the body in its third person visibility state.
-- During transitions, forced third person (Perspectives, knockdown, hub) and
-- for non-local units the original values pass through untouched.
mod:hook(CLASS.PlayerUnitFirstPersonExtension, "_update_first_person_mode", function(func, self, t)
	local show_1p_equipment, wants_1p_camera = func(self, t)

	-- Scanners get the plain truth (v1.11.0). The auspex minigame is drawn
	-- onto the device's own first person screen, and while the equipment
	-- system is running in third person that screen is not the one being
	-- rendered, so the puzzle is simply absent and the objective cannot be
	-- completed. No amount of waking fixes it, because the missing thing is
	-- the interface, not a mesh. Gating on the WIELDED SLOT rather than on a
	-- particular item covers every scanner the game has, the ones scattered
	-- around missions and the Expedition one alike, since they are all
	-- wielded in the device slot.
	local device_wielded = false

	if mod:get("fp_device_truth") ~= false then
		local d_ok, wielded_slot = pcall(function()
			local unit_data = ScriptUnit.has_extension(self._unit, "unit_data_system")
			local inventory = unit_data and unit_data:read_component("inventory")

			return inventory and inventory.wielded_slot
		end)

		if d_ok and type(wielded_slot) == "string" and string.find(wielded_slot, "device", 1, true) then
			device_wielded = true
		end
	end

	if show_1p_equipment and wants_1p_camera and not self._force_third_person_mode and self._is_local_unit and mod:get("fp_lower_body") and not device_wielded then
		-- ADS exception (field-confirmed by control test): sight alignment
		-- consults the first person mode we spoof, and told "third person"
		-- it floats scopes above the crosshair. So during alternate fire the
		-- hook tells the TRUTH, letting the game align sights its own way.
		-- BUT (user's point): the body must stay when it can actually be in
		-- frame, aiming steeply downward or slide-aiming with legs kicked
		-- forward. In those moments the lie holds and the sights carry
		-- their slight offset only while shooting the floor near your feet.
		local aiming = false
		local ok, alternate_fire = pcall(function()
			local unit_data = ScriptUnit.has_extension(self._unit, "unit_data_system")

			return unit_data and unit_data:read_component("alternate_fire")
		end)

		if ok and alternate_fire and alternate_fire.is_active then
			aiming = true
		end

		if aiming and mod:get("fp_ads_reveal") then
			-- Steep downward pitch. The engage angle is a setting (default
			-- tuned in play to 42.1 degrees down); release sits 8 degrees
			-- shallower for hysteresis, so the mode does not flap at the
			-- boundary. The comparison happens in downness space (sine of
			-- the pitch), the same measure the telemetry reads.
			local body_can_be_in_frame = false
			local p_ok, downness = pcall(function()
				local fp_unit = self._first_person_unit
				local forward = Quaternion.forward(Unit.local_rotation(fp_unit, 1))

				return math.max(0, -forward.z)
			end)

			if p_ok and type(downness) == "number" then
				local angle = tonumber(mod:get("fp_ads_angle")) or 42.1
				local engage = math.sin(math.rad(angle))
				local release = math.sin(math.rad(math.max(5, angle - 8)))
				local threshold = mod._fp_ads_lying and release or engage

				if downness > threshold then
					body_can_be_in_frame = true
				end
			end

			-- Sliding: legs stretch forward into view regardless of pitch.
			if not body_can_be_in_frame then
				local s_ok, state = pcall(function()
					local unit_data = ScriptUnit.has_extension(self._unit, "unit_data_system")
					local character_state = unit_data and unit_data:read_component("character_state")

					return character_state and character_state.state_name
				end)

				if s_ok and state == "sliding" then
					body_can_be_in_frame = true
				end
			end

			if body_can_be_in_frame then
				aiming = false -- keep the lie, body stays visible
				mod._fp_ads_lying = true
			else
				mod._fp_ads_lying = false
			end
		else
			mod._fp_ads_lying = false
		end

		if not aiming then
			mod._fp_spoof_calls = (mod._fp_spoof_calls or 0) + 1

			return false, wants_1p_camera
		end
	end

	return show_1p_equipment, wants_1p_camera
end)

-- ---------------------------------------------------------------------------
-- Weapon customization mods read the flag this mod lies about (v1.9.0)
-- ---------------------------------------------------------------------------
-- Extended Weapon Customization does its own sight alignment: while you aim,
-- it slides the weapon into the position its sight expects, and it decides
-- whether to do that by asking is_in_first_person_mode(), which is exactly
-- the answer this mod spoofs. Told "third person", it slides the offset back
-- to zero instead, and the sight sits off the crosshair. The same question
-- picks which flashlight it toggles, the first person lamp or the third
-- person one, which is how a flashlight ends up stuck.
--
-- Those extensions do not care about equipment visibility, they only want to
-- know whether the player is looking down this weapon, and the honest answer
-- to that is yes: the camera IS in first person. So they are told the truth,
-- while the equipment system keeps its lie. This is a compatibility shim, so
-- it installs only if those classes exist and can be switched off.
local EWC_FIRST_PERSON_CLASSES = {
	"SightExtension",
	"FlashlightExtension",
	"DamageTypeExtension",
	"ShieldTransparencyExtension",
}

local function fp_is_spoofing(fp_ext)
	return fp_ext ~= nil
		and fp_ext._is_local_unit == true
		and fp_ext._show_1p_equipment == false
		and fp_ext._wants_1p_camera == true
end

-- v1.10.0: the shim above is not enough, because customization mods do not
-- all ask through their own classes. EWC's attachment callbacks call the
-- ENGINE method straight, `self.first_person_extension:is_in_first_person_mode()`,
-- to pick which copy of an attachment to hide and to fire their
-- "perspective changed" callbacks. Told third person, they hide the third
-- person duplicates, which nobody was looking at, and leave both first
-- person ones on screen: a boltgun wearing two sights at once.
--
-- So the lie is narrowed to the one reader that needs it. The stored flag
-- stays as it was, but the QUESTION now answers honestly for everybody
-- except the visual loadout's own visibility pass, which is the single
-- consumer whose "third person" answer is what reveals the body. That pass
-- is fenced off below, and it caches the answer for its own later work, so
-- equipping and wielding keep the body too.
mod:hook(CLASS.PlayerUnitVisualLoadoutExtension, "update", function(func, self, unit, dt, t, ...)
	local was = mod._fp_in_loadout_update

	-- v1.10.3: the fence is ONE question wide, not the whole call. The
	-- visual loadout asks once, near the top of its update, and caches the
	-- answer for the rest of its work, so only that first question needs the
	-- lie. Everything else running inside this window belongs to other
	-- systems: Visible Equipment's own extension updates from in here, asks
	-- the same question to decide whether to show the weapons it puts on your
	-- body, and a fence that covered the whole call answered "third person",
	-- which is why holstered weapons reappeared the moment the aiming reveal
	-- flipped the equipment over.
	mod._fp_in_loadout_update = true

	local ok, result = pcall(func, self, unit, dt, t, ...)

	mod._fp_in_loadout_update = was

	return ok and result or nil
end)

mod:hook(CLASS.PlayerUnitFirstPersonExtension, "is_in_first_person_mode", function(func, self)
	local answer = func(self)

	if answer == false and mod._fp_in_loadout_update then
		-- Consume the fence: this is the loadout's own question.
		mod._fp_in_loadout_update = false

		return answer
	end

	if answer == false
		and mod:get("fp_lower_body")
		and mod:get("fp_customization_compat") ~= false
		and fp_is_spoofing(self)
	then
		mod._fp_truth_answers = (mod._fp_truth_answers or 0) + 1

		return true
	end

	return answer
end)

local function install_customization_compat()
	if mod._fp_compat_installed then
		return
	end

	local classes = rawget(_G, "CLASS")

	if type(classes) ~= "table" then
		return
	end

	local hooked = 0

	for i = 1, #EWC_FIRST_PERSON_CLASSES do
		local class_table = classes[EWC_FIRST_PERSON_CLASSES[i]]

		if type(class_table) == "table" and type(class_table.is_in_first_person_mode) == "function" then
			local ok = pcall(function()
				mod:hook(class_table, "is_in_first_person_mode", function(func, self)
					if mod:get("fp_lower_body") and mod:get("fp_customization_compat") ~= false
						and fp_is_spoofing(self.first_person_extension) then
						return true
					end

					return func(self)
				end)
			end)

			if ok then
				hooked = hooked + 1
			end
		end
	end

	mod._fp_compat_installed = hooked > 0
	mod._fp_compat_hooks = hooked
end

function mod.on_all_mods_loaded()
	pcall(install_customization_compat)
end

local fp_active = false

-- Pitch limits (user-tuned to their sweet spot via the telemetry): free look
-- below the soft boundary, growing resistance through the soft zone, a hard
-- wall past it, and a separate lower wall while sprinting (which also
-- replaces body-hiding on sprint with something more immersive). Applied at
-- the TRUE SOURCE (v1.3.1 lesson): DefaultPlayerOrientation.pre_update is
-- where the frame's mouse/stick input is integrated into the persistent
-- orientation table that BOTH the camera handler and the fixed-frame aim
-- cache read from. v1.3.0 clamped HumanInputHandler.fixed_update's pitch
-- argument, but that is only a per-frame SNAPSHOT of the orientation table;
-- the accumulator itself kept the unclamped value and the camera reads the
-- accumulator, so nothing visibly changed. Clamping the stored pitch right
-- after the game's own integration is authoritative for camera and aim
-- alike. The pitch sign convention is calibrated at runtime against our own
-- camera telemetry, so a convention mismatch cannot cap upward looks.
local function fp_clamp_pitch(pitch_rad, dt)
	local telemetry = mod._fp_pitch_deg
	local arg_deg = math.deg(pitch_rad)

	if mod._fp_clamp_sign == nil then
		if telemetry and math.abs(telemetry) > 15 and math.abs(arg_deg) > 5 then
			mod._fp_clamp_sign = ((arg_deg > 0) == (telemetry > 0)) and 1 or -1
		else
			return pitch_rad
		end
	end

	local sign = mod._fp_clamp_sign
	local down_deg = sign * arg_deg

	local soft = mod:get("fp_pitch_soft") or 51.1
	local hard = mod:get("fp_pitch_hard") or 53.7
	local sprint_cap = mod:get("fp_pitch_sprint") or 44.1

	if hard < soft then
		hard = soft
	end

	local prev = mod._fp_pitch_prev or down_deg
	local accepted = down_deg

	if mod._fp_sprint_is then
		local cap = sprint_cap

		if prev > cap then
			-- Sprint started while looking deeper: pull up smoothly, no snap.
			cap = math.max(cap, prev - 240 * (dt or 0.016))
		end

		if accepted > cap then
			accepted = cap
		end
	elseif accepted > prev then
		local target = accepted

		accepted = prev

		local remaining = target - prev

		if accepted < soft then
			local free = math.min(remaining, soft - accepted)

			accepted = accepted + free
			remaining = remaining - free
		end

		if remaining > 0 then
			local zone = (accepted - soft) / math.max(0.001, hard - soft)
			local factor = math.max(0.08, 1 - zone) * 0.3

			accepted = accepted + remaining * factor
		end

		if accepted > hard then
			accepted = hard
		end
	end

	if accepted > hard then
		accepted = hard
	end

	mod._fp_pitch_prev = accepted
	mod._fp_clamp_active = accepted < down_deg - 0.01

	return sign * math.rad(accepted)
end

mod:hook(CLASS.DefaultPlayerOrientation, "pre_update", function(func, self, main_t, main_dt, input, sensitivity_modifier, rotation_contraints)
	func(self, main_t, main_dt, input, sensitivity_modifier, rotation_contraints)

	if fp_active and mod:get("fp_lower_body") and mod:get("fp_pitch_clamp") then
		local orientation = self._orientation

		if orientation and type(orientation.pitch) == "number" then
			-- The game stores pitch wrapped to [0, 2pi); normalize to
			-- (-pi, pi] so up/down are signed, clamp, then wrap back.
			local normalized = (orientation.pitch + math.pi) % (2 * math.pi) - math.pi
			local ok, clamped = pcall(fp_clamp_pitch, normalized, main_dt)

			if ok and type(clamped) == "number" then
				orientation.pitch = clamped % (2 * math.pi)
				mod._fp_clamp_fires = (mod._fp_clamp_fires or 0) + 1
			end
		end
	else
		mod._fp_pitch_prev = nil
	end
end)

-- THE FADE DEFEAT (restored in v1.1.2 after the dip-removal splice
-- accidentally deleted it, which removed the legs entirely): every character
-- carries an engine camera-proximity dither fade, fully invisible when the
-- camera is closer than ~0.5m to the spine, which in first person is always.
-- While the trick is active, feed the fade system a camera position far away
-- so the proximity fade never engages. Stealth transparency uses a separate
-- min_fade floor and is unaffected. Gate closed = original behavior.
mod:hook(CLASS.FadeSystem, "update", function(func, self, context, dt, t, ...)
	if fp_active and mod:get("fp_lower_body") then
		local unit = local_player_unit()

		if unit and Unit.alive(unit) and camera_truly_first_person(unit) then
			local ok = pcall(function()
				local player_manager = Managers.player
				local camera_manager = Managers.state.camera
				local player = player_manager and player_manager:local_player(1)
				local pos = player and camera_manager and camera_manager:camera_position(player.viewport_name)

				if not pos then
					error("no camera position")
				end

				Fade.update(self._fade_system, pos + Vector3(0, 0, 1000))
			end)

			if ok then
				mod._fp_fade_defeats = (mod._fp_fade_defeats or 0) + 1

				return
			end
		end
	end

	return func(self, context, dt, t, ...)
end)

-- Hand everything back to the game for the current (unspoofed) mode.
local function restore_revealed()
	if not fp_active then
		return
	end

	fp_active = false
	mod._fp_restores = (mod._fp_restores or 0) + 1

	fp_untag_carrier()

	local unit = local_player_unit()

	if not unit or not Unit.alive(unit) then
		return
	end

	local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")

	if not ext then
		return
	end

	-- Undo the mesh-level occluder hiding before handing back to the game;
	-- nothing in the game's own pass would re-show those meshes otherwise.
	local equipment = ext._equipment

	if equipment then
		for slot_name, slot in pairs(equipment) do
			if not string.find(slot_name, "companion") then
				set_slot_meshes_3p(slot, true)
			end
		end
	end

	-- Restore EVERY registry unit, including base-sweep strangers (NPC Look
	-- extra units and similar) that belong to no equipment slot; the old
	-- slot-only loop left those hidden forever.
	for hidden_unit in pairs(fp_mesh_hidden_units) do
		if Unit.alive(hidden_unit) then
			restore_meshes(hidden_unit)
			Unit.set_unit_visibility(hidden_unit, true, true)
		end
	end

	fp_mesh_snapshots = {}
	fp_mesh_hidden_units = {}

	for unit in pairs(fp_scaled_units) do
		scale_restore_unit(unit)
	end

	fp_scaled_units = {}

	-- Our mesh restore is blind (the engine has no mesh state getter), so
	-- it un-hides meshes that EWC skin fixes deliberately hid, doubling the
	-- base weapon under skins after every 1p round trip. If EWC (Kaizen
	-- consolidated fork) is present, ask it to re-apply its fixes from the
	-- spawn registry it keeps, restoring skins exactly as spawned.
	pcall(function()
		local ewc = get_mod("extended_weapon_customization")
		local registry = ewc and ewc._fix_reapply_registry

		if not registry or not ewc.apply_unit_fixes then
			return
		end

		for slot_name, slot in pairs(equipment) do
			if slot.wieldable and slot.unit_3p and Unit.alive(slot.unit_3p) then
				local entry = registry[slot.unit_3p]

				if entry then
					pcall(ewc.apply_unit_fixes, ewc, entry.item_data, slot.unit_3p, entry.map, entry.lookup, entry.fixes, false)
				end
			end
		end
	end)

	if ext.force_update_item_visibility then
		pcall(ext.force_update_item_visibility, ext)
	elseif ext._update_item_visibility then
		pcall(ext._update_item_visibility, ext, ext._is_in_first_person_mode)
	end
end

function mod.refresh_first_person_body()
	if not mod:get("fp_lower_body") then
		pcall(restore_revealed)
	end
end

-- One pass over the equipment while the trick is active. The game (in its
-- third person mode) keeps the body visible and, via the hide_slots tag,
-- hides the occluders itself. Our work: keep the tag on an equipped item,
-- keep the lower body awake, wake the viewmodel back up.
local fp_in_pass = false

function mod.fp_reveal_pass(ext, force)
	if not mod:get("fp_lower_body") then
		return -2
	end

	local equipment = ext and ext._equipment

	if not equipment then
		return -1
	end

	if fp_in_pass then
		-- Re-entered through our own force_update call below; skip.
		return mod._fp_last_shown or 0
	end

	local inventory = ext._inventory_component
	local wielded_slot_name = inventory and inventory.wielded_slot

	local newly_tagged = fp_tag_carrier(equipment, wielded_slot_name)

	-- Respawn tracker: fingerprint the wielded slot's bookkept unit set.
	-- If the same slot's set changes identity (units replaced), something
	-- respawned the weapon behind our backs, orphaning the previous copy.
	if wielded_slot_name then
		local tracked_slot = equipment[wielded_slot_name]

		if tracked_slot then
			local parts = { tostring(tracked_slot.unit_3p) }

			for_each_attachment(tracked_slot.attachments_by_unit_3p, function(attachment_unit)
				parts[#parts + 1] = tostring(attachment_unit)
			end)

			table.sort(parts)

			local sig = table.concat(parts, ",")

			mod._fp_sigs = mod._fp_sigs or {}

			local prev = mod._fp_sigs[wielded_slot_name]

			if prev and prev ~= sig then
				mod._fp_sig_changes = (mod._fp_sig_changes or 0) + 1

				local t_ok, t_now = pcall(function()
					return Managers.time:time("gameplay")
				end)

				mod._fp_sig_last = t_ok and tostring(t_now) or "?"
			end

			mod._fp_sigs[wielded_slot_name] = sig
		end
	end

	fp_in_pass = true
	mod._fp_full_passes = (mod._fp_full_passes or 0) + 1

	-- A fresh tag only takes effect when the game runs a visibility pass,
	-- so run one now (it hides the occluder slots itself).
	if newly_tagged and ext.force_update_item_visibility then
		pcall(ext.force_update_item_visibility, ext)
	end

	local shown = 0

	-- Hide the occluders at MESH level, the only channel arbitrary gear and
	-- weapon units respect. Companion (dog) slots are never touched. The
	-- traversal also walks scene-graph CHILD units (when the engine exposes
	-- them), because EWC-built weapons spawn their kitbash parts as child
	-- units that never appear in the game's attachments_by_unit_3p table.
	local current_hidden = {}

	local function hide_unit_tree(unit, depth)
		if not unit or not Unit.alive(unit) or current_hidden[unit] then
			return
		end

		hide_all_meshes(unit)

		current_hidden[unit] = true

		if depth <= 0 or not Unit.get_child_units then
			return
		end

		local ok, children = pcall(Unit.get_child_units, unit)

		if ok and type(children) == "table" then
			for i = 1, #children do
				hide_unit_tree(children[i], depth - 1)
			end
		end
	end

	local current_scaled = {}

	for slot_name, slot in pairs(equipment) do
		if not REVEAL_SET[slot_name] and not string.find(slot_name, "companion") then
			local unit_3p = slot.unit_3p

			if unit_3p and Unit.alive(unit_3p) then
				if slot.wieldable then
					-- Weapons, blitz launchers, luggables. Diag evidence
					-- (v1.0.4): the base unit has zero meshes, our scale
					-- write HOLDS on it, all map units got scaled, and the
					-- weapon still rendered → the engine's link propagation
					-- re-derives linked units' transforms after mod code
					-- every frame, so no transform channel can win. MESH
					-- visibility is the one channel proven to persist on
					-- exactly these units (EWC hide fixes set it once at
					-- spawn and it sticks), so hide every mesh of every
					-- unit in the full attachment tree. Restore is
					-- all-visible for now, which un-hides EWC skin fix
					-- meshes until a re-equip; proper fix queued (re-apply
					-- fixes via the EWC fork's own registry).
					scale_hide_unit(unit_3p)
					hide_all_meshes(unit_3p)

					current_scaled[unit_3p] = true
					current_hidden[unit_3p] = true

					for_each_attachment(slot.attachments_by_unit_3p, function(attachment_unit)
						scale_hide_unit(attachment_unit)
						hide_all_meshes(attachment_unit)

						current_scaled[attachment_unit] = true
						current_hidden[attachment_unit] = true
					end)
				else
					hide_unit_tree(unit_3p, 3)

					for_each_attachment(slot.attachments_by_unit_3p, function(attachment_unit)
						hide_unit_tree(attachment_unit, 2)
					end)
				end
			end
		end
	end

	-- Sweep the character base unit's scene-graph children: EWC rebuilds
	-- weapons out of units that never appear in the slot bookkeeping, so
	-- anything attached to the character that is not part of the revealed
	-- lower body trees gets hidden too (weapons, blitz launchers, whatever
	-- is glued to the character).
	local protected = {}

	local function protect_tree(unit, depth)
		if not unit or not Unit.alive(unit) or protected[unit] then
			return
		end

		protected[unit] = true

		if depth <= 0 or not Unit.get_child_units then
			return
		end

		local ok, children = pcall(Unit.get_child_units, unit)

		if ok and type(children) == "table" then
			for i = 1, #children do
				protect_tree(children[i], depth - 1)
			end
		end
	end

	for i = 1, #REVEAL_SLOTS do
		local slot = equipment[REVEAL_SLOTS[i]]

		if slot then
			protect_tree(slot.unit_3p, 3)

			local reveal_attachments = slot.unit_3p and slot.attachments_by_unit_3p and slot.attachments_by_unit_3p[slot.unit_3p]

			if reveal_attachments then
				for a = 1, #reveal_attachments do
					protect_tree(reveal_attachments[a], 2)
				end
			end
		end
	end

	local base_3p = ext._unit

	if base_3p and Unit.alive(base_3p) and Unit.get_child_units then
		local ok, children = pcall(Unit.get_child_units, base_3p)

		if ok and type(children) == "table" then
			for i = 1, #children do
				local child = children[i]

				if child and Unit.alive(child) and not protected[child] then
					hide_unit_tree(child, 2)
				end
			end
		end
	end

	-- Scaled units that left the loadout (dropped crate, swapped weapon):
	-- restore their scale immediately so nothing in the world stays tiny.
	for unit in pairs(fp_scaled_units) do
		if not current_scaled[unit] then
			scale_restore_unit(unit)
		end
	end

	-- Units mesh-hidden earlier that are no longer part of the loadout
	-- (dropped med crates and luggables, swapped weapons, changed outfits):
	-- restore their meshes immediately so nothing in the world stays
	-- invisible.
	for unit in pairs(fp_mesh_hidden_units) do
		if not current_hidden[unit] then
			if Unit.alive(unit) then
				restore_meshes(unit)
			end

			fp_mesh_hidden_units[unit] = nil
			fp_mesh_snapshots[unit] = nil
		end
	end

	-- Keep the lower body awake (mesh force is insurance against latched
	-- flow fades).
	if not mod._fp_sprint_hidden then
		for i = 1, #REVEAL_SLOTS do
			local slot = equipment[REVEAL_SLOTS[i]]

			if slot and reveal_slot_3p(slot) then
				shown = shown + 1
			end
		end
	end

	-- Wake the first person viewmodel the third person pass hid: the 1p rig
	-- itself, the wielded weapon, arms and sleeves.
	local fp_unit = ext._first_person_unit

	if fp_unit and Unit.alive(fp_unit) then
		wake_unit_render(fp_unit)
	end

	local wielded_slot = wielded_slot_name and equipment[wielded_slot_name]

	-- Gentle on the weapon: see wake_unit_render. Weapon parts are rigid and
	-- answer to plain unit visibility, so nothing another mod hid on them
	-- (kitbash leftovers, flashlight lamps) gets forced back on.
	if wielded_slot and reveal_slot_1p(wielded_slot, mod:get("fp_deep_weapon_wake") == true) then
		shown = shown + 1
	end

	if reveal_slot_1p(equipment.slot_body_arms) then
		shown = shown + 1
	end

	if reveal_slot_1p(equipment.slot_gear_upperbody) then
		shown = shown + 1
	end

	-- THE OVERLAY, identified at last (user's nuke evidence: 3p set moved,
	-- overlay stayed; overlay exists only in 1p): our recursive rig wake
	-- re-shows EVERYTHING under the 1p rig, including the STOWED weapons'
	-- first person units, which vanilla hides via plain unit visibility,
	-- the very channel the wake overrides. Re-hide the 1p side of every
	-- wieldable slot that is not currently wielded.
	for slot_name, slot in pairs(equipment) do
		if slot.wieldable and slot_name ~= wielded_slot_name and not string.find(slot_name, "companion") then
			local unit_1p = slot.unit_1p

			if unit_1p and Unit.alive(unit_1p) then
				Unit.set_unit_visibility(unit_1p, false, true)
				pcall(Unit.set_unit_objects_visibility, unit_1p, false, true)

				local m_ok, num_meshes = pcall(Unit.num_meshes, unit_1p)

				if m_ok and type(num_meshes) == "number" then
					for i = 1, num_meshes do
						pcall(Unit.set_mesh_visibility, unit_1p, i, false)
					end
				end

				for_each_attachment(slot.attachments_by_unit_1p, function(attachment_unit)
					Unit.set_unit_visibility(attachment_unit, false, true)
					pcall(Unit.set_unit_objects_visibility, attachment_unit, false, true)

					local a_ok, a_meshes = pcall(Unit.num_meshes, attachment_unit)

					if a_ok and type(a_meshes) == "number" then
						for i = 1, a_meshes do
							pcall(Unit.set_mesh_visibility, attachment_unit, i, false)
						end
					end
				end)
			end

			-- And the THIRD person side of the same stowed slots (v1.9.0).
			-- The reveal runs the equipment system in third person, which is
			-- what puts your holstered weapons on your body, and vanilla
			-- parks those behind you where the camera never looks. Mods that
			-- reposition them, Visible Equipment above all, move them onto
			-- the hips, and then the top of a stowed hammer sits right in
			-- the middle of the view when you look down. The camera is in
			-- first person, so nobody is looking at your back: hide them.
			-- Only unit visibility, the game's own channel for this, so
			-- whatever another mod hid stays hidden and the restore is the
			-- game's own visibility pass rather than a blind re-show.
			local unit_3p = slot.unit_3p

			if mod:get("fp_hide_holstered") ~= false and unit_3p and Unit.alive(unit_3p) then
				Unit.set_unit_visibility(unit_3p, false, true)

				for_each_attachment(slot.attachments_by_unit_3p, function(attachment_unit)
					Unit.set_unit_visibility(attachment_unit, false, true)
				end)

				mod._fp_holstered_hidden = true
			end
		end
	end

	fp_active = true
	fp_in_pass = false

	return shown
end

-- ---------------------------------------------------------------------------
-- Effects follow the LIE, so they have to be pulled back (v1.6.0)
-- ---------------------------------------------------------------------------
-- Reported: Psyker hand effects and the Thunder Hammer charge spawn slightly
-- BELOW where they belong. Cause found in the engine, and it is our own lie
-- coming home.
--
-- Effects do not float in the world, they are attached to named "fx source"
-- nodes on a unit, and the game keeps two copies of every such node: one on
-- the first person viewmodel you actually see, one on the third person body
-- that stands in the world. Which copy an effect uses is decided by asking
-- the first person extension is_in_first_person_mode(), and that function
-- returns the exact flag this mod spoofs to false. So both effect owners
-- move their sources onto the third person rig: the hands effects onto the
-- real body's hands (a little lower than the viewmodel arms, hence "a bit
-- below"), and weapon effects onto the third person weapon.
--
-- Two owners, two repairs:
--   1. The player's own effect sources (hands, body, breed effects) are
--      re-pointed inside PlayerUnitFxExtension.update, which reads the flag
--      directly. There, and only there, the flag is told the truth for the
--      duration of the call, so the game moves those sources to the
--      viewmodel by itself. The lie is restored immediately afterwards.
--   2. Weapon effect sources cannot be fixed that way, because the visual
--      loadout reads the same flag in the same breath as the item visibility
--      that IS the body reveal. So the game is allowed to move them to the
--      third person weapon, and then they are moved back here, using the
--      weapon's own source list. This only fires when a mismatch is actually
--      seen, so no effect is restarted needlessly.
local WeaponTemplate = nil

do
	local ok, lib = pcall(require, "scripts/utilities/weapon/weapon_template")

	if ok then
		WeaponTemplate = lib
	end
end

mod:hook(CLASS.PlayerUnitFxExtension, "update", function(func, self, unit, dt, t)
	local fp_ext = self._first_person_extension
	local spoofing = fp_ext
		and fp_ext._is_local_unit
		and fp_ext._show_1p_equipment == false
		and fp_ext._wants_1p_camera == true

	if not spoofing or not mod:get("fp_lower_body") or not mod:get("fp_fx_sources") then
		return func(self, unit, dt, t)
	end

	fp_ext._show_1p_equipment = true

	local ok, result = pcall(func, self, unit, dt, t)

	fp_ext._show_1p_equipment = false
	mod._fp_fx_truth_frames = (mod._fp_fx_truth_frames or 0) + 1

	return ok and result or nil
end)

-- ---------------------------------------------------------------------------
-- Effects that are ALREADY playing when the perspective changes (v1.8.0)
-- ---------------------------------------------------------------------------
-- Moving an effect SOURCE only decides where the NEXT effect appears. An
-- effect already on screen was linked to a unit and a node at the moment it
-- was created and stays married to it, so swapping perspective mid effect
-- leaves it hanging off the rig it was born on.
--
-- Looping effects (charge-ups, glows) already survive this: the engine's own
-- spawner move stops and restarts them at the new source. What it cannot
-- help are the one-shot bursts, because nobody keeps their id after
-- spawning, so there is nothing left to re-aim.
--
-- So keep the ids ourselves. Every linked effect the local player spawns is
-- recorded, and on a perspective change each one still playing is re-linked
-- to the same source on the rig now being rendered, with the viewmodel field
-- of view flag flipped to match. The list is capped and prunes itself, and
-- the ones that matter are short lived anyway.
local ROOT_ATTACH_NAME = ""
local MAX_TRACKED_PARTICLES = 24
local tracked_particles = {}

-- Reported from a live mission end (Nexus, 4 August 2026): asking the engine
-- whether a particle is still playing FAULTS if the world that particle
-- belonged to has gone away, and a mission ending tears its world down while
-- this list still holds ids from it. Engine faults of that kind are not
-- catchable from Lua, pcall or no pcall, so the only safe course is never to
-- ask about a particle that could belong to a dead world. Every entry
-- carries the generation it was born in; leaving gameplay bumps the
-- generation and empties the list, so nothing from a previous world is ever
-- queried again.
local particle_generation = 0

local function fp_forget_particles()
	for i = #tracked_particles, 1, -1 do
		tracked_particles[i] = nil
	end

	particle_generation = particle_generation + 1
end

local function fp_spawner_for(ext, spawner_name, attach_name)
	local spawners = ext._vfx_spawners and ext._vfx_spawners[spawner_name]

	return spawners and spawners[attach_name or ROOT_ATTACH_NAME]
end

mod:hook(CLASS.PlayerUnitFxExtension, "_spawn_unit_particles", function(func, self, particle_name, spawner_name, link, orphaned_policy, position_offset, rotation_offset, scale, create_network_index, optional_attachment_name)
	local particle_id = func(self, particle_name, spawner_name, link, orphaned_policy, position_offset, rotation_offset, scale, create_network_index, optional_attachment_name)

	if link and particle_id and mod:get("fp_fx_sources") and mod:get("fp_fx_relink") ~= false then
		pcall(function()
			local fp_ext = self._first_person_extension

			if not fp_ext or not fp_ext._is_local_unit then
				return
			end

			-- The offsets are engine temporaries, so they are boxed to
			-- survive past this frame and rebuilt into a pose on re-link.
			tracked_particles[#tracked_particles + 1] = {
				ext = self,
				id = particle_id,
				gen = particle_generation,
				spawner = spawner_name,
				attach = optional_attachment_name,
				orphaned = orphaned_policy,
				pos = position_offset and Vector3Box(position_offset) or nil,
				rot = rotation_offset and QuaternionBox(rotation_offset) or nil,
				scale = scale and Vector3Box(scale) or nil,
			}

			if #tracked_particles > MAX_TRACKED_PARTICLES then
				table.remove(tracked_particles, 1)
			end
		end)
	end

	return particle_id
end)

local function fp_relink_particles(want_1p)
	if mod:get("fp_fx_relink") == false then
		return
	end

	for i = #tracked_particles, 1, -1 do
		local entry = tracked_particles[i]
		local drop = true

		if entry.gen ~= particle_generation then
			table.remove(tracked_particles, i)
		else
		pcall(function()
			local ext = entry.ext
			local world = ext and ext._world
			local owner = ext and ext._unit

			-- The owning unit going away is the cheap, safe signal that this
			-- particle's world is on its way out too.
			if not world or not owner or not Unit.alive(owner) then
				return
			end

			if not World.are_particles_playing(world, entry.id) then
				return
			end

			local spawner = fp_spawner_for(ext, entry.spawner, entry.attach)

			if not spawner then
				return
			end

			-- Same choice of unit and node the game makes when spawning.
			local node_unit, node

			if want_1p or not spawner.node_3p then
				node_unit, node = spawner.unit, spawner.node
			else
				node_unit, node = ext._unit, spawner.node_3p
			end

			if not node_unit or not Unit.alive(node_unit) then
				return
			end

			local pose = Matrix4x4.identity()

			if entry.pos then
				Matrix4x4.set_translation(pose, entry.pos:unbox())
			end

			if entry.rot then
				Matrix4x4.set_rotation(pose, entry.rot:unbox())
			end

			if entry.scale then
				Matrix4x4.set_scale(pose, entry.scale:unbox())
			end

			World.link_particles(world, entry.id, node_unit, node, pose, entry.orphaned)
			pcall(World.set_particles_use_custom_fov, world, entry.id, want_1p and true or false)

			mod._fp_fx_relinks = (mod._fp_fx_relinks or 0) + 1
			drop = false
		end)

		if drop then
			table.remove(tracked_particles, i)
		end
		end
	end
end

-- Weapon effect sources: park them on the perspective that is actually being
-- rendered. want_1p true while the body reveal runs, false to hand them back.
--
-- The handing back matters (v1.6.1, reported: gunfire coming from in front of
-- the character in third person). The game only moves these sources when its
-- own first person flag CHANGES, and while the reveal runs that flag already
-- reads false. Switching to a real third person camera therefore changes it
-- from false to false, the game does nothing, and any source this mod had
-- moved to the viewmodel stayed there, firing from a weapon parented to the
-- camera, out in front of the character. So whatever this mod moves, this
-- mod has to move back the moment the reveal stops.
local function fp_sync_weapon_fx(ext, want_1p)
	if not WeaponTemplate then
		return
	end

	local fx = ext._fx_extension
	local equipment = ext._equipment
	local all_sources = ext._fx_sources

	if not fx or not equipment or not all_sources then
		return
	end

	for slot_name, slot in pairs(equipment) do
		local sources = all_sources[slot_name]
		local wanted = want_1p and slot.unit_1p or slot.unit_3p
		local attachments = want_1p and slot.attachments_by_unit_1p or slot.attachments_by_unit_3p
		local lookup = want_1p and slot.attachment_id_lookup_1p or slot.attachment_id_lookup_3p

		if sources and slot.equipped and slot.wieldable and wanted and Unit.alive(wanted) then
			local t_ok, template = pcall(WeaponTemplate.weapon_template_from_item, slot.item)
			local config = t_ok and template and template.fx_sources

			if config then
				for alias, source_name in pairs(sources) do
					local node_name = config[alias]

					if node_name then
						-- Where does this source sit right now? One that is
						-- already in the right place is left alone: moving a
						-- source restarts any looping effect hanging off it.
						local r_ok, current = pcall(function()
							local u = fx:vfx_spawner_unit_and_node(source_name)

							return u
						end)

						if r_ok and current ~= nil and current ~= wanted then
							pcall(fx.move_vfx_spawner, fx, source_name, wanted, attachments, lookup, node_name)

							mod._fp_fx_moves = (mod._fp_fx_moves or 0) + 1
							mod._fp_fx_last = string.format("%s.%s -> %s", tostring(slot_name), tostring(alias),
								want_1p and "1p" or "3p")
						end
					end
				end
			end
		end
	end

	mod._fp_fx_owned = want_1p

	-- Effects already in flight follow the sources.
	pcall(fp_relink_particles, want_1p)
end

-- Hand the weapon sources back to wherever the game's own flag says they
-- belong, which outside the reveal is the honest answer and with the option
-- switched off mid-reveal is simply the untouched behaviour. Only does
-- anything if this mod moved them in the first place.
local function fp_release_weapon_fx(unit)
	if not mod._fp_fx_owned then
		return
	end

	local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")
	local fp_ext = ScriptUnit.has_extension(unit, "first_person_system")

	if not ext or not fp_ext then
		return
	end

	local game_says_1p = fp_ext:is_in_first_person_mode() == true

	pcall(fp_sync_weapon_fx, ext, game_says_1p)

	mod._fp_fx_owned = false
end

-- Holstered weapons, re-asserted EVERY frame (v1.10.2). Hiding them once per
-- pass is not enough: aiming re-runs the game's visibility work constantly,
-- and mods that place weapons on the body re-show their own units whenever
-- they please, so anything hidden only twice a second comes back the moment
-- the aiming reveal flips the equipment into third person. This is a handful
-- of unit visibility calls, the cheapest channel there is.
local function fp_hide_holstered_units()
	local unit = local_player_unit()
	local ext = unit and ScriptUnit.has_extension(unit, "visual_loadout_system")
	local equipment = ext and ext._equipment
	local inventory = ext and ext._inventory_component
	local wielded = inventory and inventory.wielded_slot

	if not equipment then
		return
	end

	for slot_name, slot in pairs(equipment) do
		if slot.wieldable and slot_name ~= wielded and not string.find(slot_name, "companion") then
			local unit_3p = slot.unit_3p

			if unit_3p and Unit.alive(unit_3p) then
				Unit.set_unit_visibility(unit_3p, false, true)

				for_each_attachment(slot.attachments_by_unit_3p, function(attachment_unit)
					Unit.set_unit_visibility(attachment_unit, false, true)
				end)

				mod._fp_holstered_hidden = true
			end
		end
	end
end

local function poll_reveal(force)
	local unit = local_player_unit()

	if not unit or not Unit.alive(unit) then
		return
	end

	if not camera_truly_first_person(unit) or not mod:get("fp_lower_body") then
		mod._fp_gate_was_true = false

		if fp_active then
			pcall(restore_revealed)
		end

		-- Effects too: give the weapon sources back to the game's own choice
		-- of perspective, or third person keeps firing from the viewmodel.
		pcall(fp_release_weapon_fx, unit)

		return
	end

	-- Entering true first person starts a burst: the pass re-asserts every
	-- frame for a second, so late re-hides and re-shows lose the race.
	if not mod._fp_gate_was_true then
		mod._fp_gate_was_true = true
		mod._fp_burst = 1
	end

	local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")

	mod._fp_poll_calls = (mod._fp_poll_calls or 0) + 1
	mod._fp_last_shown = mod.fp_reveal_pass(ext, force)

	if ext then
		if mod:get("fp_fx_sources") then
			pcall(fp_sync_weapon_fx, ext, true)
		else
			pcall(fp_release_weapon_fx, unit)
		end
	end
end

-- The game re-evaluates equipment visibility on every equip and wield change
-- (and on the mode flip our spoof causes). Under the spoof the call comes in
-- with is_in_first_person_mode == false, so no early-out on that argument:
-- gate purely on the camera and run a forced pass right after the game's own.
mod:hook_safe(CLASS.PlayerUnitVisualLoadoutExtension, "_update_item_visibility", function(self, is_in_first_person_mode)
	if not mod:get("fp_lower_body") then
		return
	end

	local unit = local_player_unit()

	if not unit or self._unit ~= unit or not camera_truly_first_person(unit) then
		return
	end

	mod._fp_hook_calls = (mod._fp_hook_calls or 0) + 1
	mod._fp_burst = 1
	mod._fp_last_shown = mod.fp_reveal_pass(self, true)

	-- This is the moment the game itself moves weapon effect sources to the
	-- third person weapon, so correct them in the same breath.
	if mod:get("fp_fx_sources") then
		pcall(fp_sync_weapon_fx, self, true)
	end
end)


function mod.update(dt)
	dt = tonumber(dt) or 0

	-- Instant restore: check the gate EVERY FRAME while the trick is active,
	-- so switching to third person hands the body back to the game within a
	-- frame.
	if fp_active then
		local unit_check = local_player_unit()

		if not unit_check or not Unit.alive(unit_check) or not mod:get("fp_lower_body") or not camera_truly_first_person(unit_check) then
			mod._fp_gate_was_true = false

			pcall(restore_revealed)
		end
	end

	-- Per-frame re-hide of everything currently mesh-hidden: defeats the
	-- weapon scripts and flow graphs that re-show weapon meshes each frame.
	if fp_active then
		pcall(reassert_hidden_meshes)
	end

	-- Look-down FOV boost (the user's design, The Finals style): widen the
	-- field of view as the pitch drops, so the ground and your legs feel
	-- present instead of cropped. Uses the game's own public FOV multiplier
	-- (CameraManager:set_fov_multiplier), quadratically eased so level play
	-- is untouched; the player's base multiplier is restored exactly when
	-- the feature deactivates.
	pcall(function()
		local camera_manager = Managers.state.camera

		if not camera_manager then
			return
		end

		local boost = (mod:get("fp_fov_boost") or 0) / 100

		-- Pitch telemetry runs regardless of the FOV setting.
		if fp_active then
			local unit = local_player_unit()
			local fp_ext = unit and ScriptUnit.has_extension(unit, "first_person_system")
			local fp_unit = fp_ext and fp_ext._first_person_unit

			if fp_unit and Unit.alive(fp_unit) then
				pcall(function()
					local forward = Quaternion.forward(Unit.local_rotation(fp_unit, 1))
					local z = math.max(-1, math.min(1, forward.z))
					local pitch_deg = -math.deg(math.asin(z))

					mod._fp_pitch_deg = pitch_deg

					if pitch_deg > (mod._fp_pitch_max or 0) then
						mod._fp_pitch_max = pitch_deg
					end
				end)
			end
		end

		-- Never while aiming (v1.10.1). Weapon customization mods set the
		-- camera's field of view directly for a sight's own zoom, and this
		-- multiplier writes the same value every frame, so the two fight and
		-- the sight drifts off the crosshair. Aiming also has nothing to do
		-- with looking at your own legs, which is what this setting is for.
		local fov_aiming = false

		if fp_active and boost ~= 0 then
			pcall(function()
				local unit = local_player_unit()
				local unit_data = unit and ScriptUnit.has_extension(unit, "unit_data_system")
				local alternate_fire = unit_data and unit_data:read_component("alternate_fire")

				fov_aiming = alternate_fire ~= nil and alternate_fire.is_active == true
			end)
		end

		if fp_active and boost ~= 0 and not fov_aiming and mod:get("fp_lower_body") then
			local unit = local_player_unit()
			local fp_ext = unit and ScriptUnit.has_extension(unit, "first_person_system")
			local fp_unit = fp_ext and fp_ext._first_person_unit
			local downness = 0

			if fp_unit and Unit.alive(fp_unit) then
				local forward = Quaternion.forward(Unit.local_rotation(fp_unit, 1))

				downness = math.max(0, -forward.z)
			end

			if mod._fp_base_fov_mult == nil then
				mod._fp_base_fov_mult = camera_manager._fov_multiplier or 1
			end

			-- Signed: negative narrows the FOV as you look down (renders the
			-- legs larger and closer, the user's intended feel), positive
			-- widens. Clamped so extreme settings cannot invert the camera.
			local factor = math.max(0.5, 1 + boost * downness * downness)

			camera_manager:set_fov_multiplier(mod._fp_base_fov_mult * factor)
			mod._fp_fov_frames = (mod._fp_fov_frames or 0) + 1
		elseif mod._fp_base_fov_mult ~= nil then
			camera_manager:set_fov_multiplier(mod._fp_base_fov_mult)

			mod._fp_base_fov_mult = nil
		end
	end)

	-- Burst window: after a perspective transition, re-assert the reveal
	-- every frame for one second, then fall back to the 0.5s poll.
	if (mod._fp_burst or 0) > 0 then
		mod._fp_burst = mod._fp_burst - dt

		pcall(poll_reveal, true)
	end

	-- Optional: hide the revealed body while sprinting (the camera lags the
	-- sprint lean, putting your own backside in frame). Mesh-blank the
	-- reveal slots every frame during the sprint state; the normal pass
	-- re-wakes them within half a second of stopping, plus a burst.
	-- The DETECTION runs for either consumer (body hiding, or the pitch
	-- clamp's sprint cap); the mesh HIDING only when its own option is on.
	local want_hide_sprint = mod:get("fp_hide_sprint")

	if fp_active and (want_hide_sprint or mod:get("fp_pitch_clamp")) then
		pcall(function()
			local unit = local_player_unit()
			local unit_data = unit and ScriptUnit.has_extension(unit, "unit_data_system")
			local sprint = unit_data and unit_data:read_component("sprint_character_state")
			local character_state = unit_data and unit_data:read_component("character_state")
			local locomotion = unit_data and unit_data:read_component("locomotion")
			local sliding = character_state and character_state.state_name == "sliding"

			-- Field evidence: the component flags only registered sprint-jumps
			-- (113 frames in a session), so steady sprint is caught by SPEED:
			-- nothing but sprinting moves a grounded player this fast.
			local speed = 0

			if locomotion and locomotion.velocity_current then
				local v_ok, flat_speed = pcall(function()
					return Vector3.length(Vector3.flat(locomotion.velocity_current))
				end)

				if v_ok and type(flat_speed) == "number" then
					speed = flat_speed
				end
			end

			local flags = sprint and (sprint.is_sprinting == true or sprint.is_sprint_jumping == true)
			local sprinting = (flags or speed > 5.4) and not sliding

			mod._fp_sprint_is = sprinting and true or false
			mod._fp_sprint_raw = string.format("is=%s jump=%s speed=%.1f slide=%s",
				tostring(sprint and sprint.is_sprinting), tostring(sprint and sprint.is_sprint_jumping),
				speed, tostring(sliding))

			if sprinting and want_hide_sprint then
				mod._fp_sprint_hidden = true
				mod._fp_sprint_hides = (mod._fp_sprint_hides or 0) + 1

				local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")
				local equipment = ext and ext._equipment

				if equipment then
					for i = 1, #REVEAL_SLOTS do
						local slot = equipment[REVEAL_SLOTS[i]]
						local unit_3p = slot and slot.unit_3p

						if unit_3p and Unit.alive(unit_3p) then
							local m_ok, num_meshes = pcall(Unit.num_meshes, unit_3p)

							if m_ok and type(num_meshes) == "number" then
								for m = 1, num_meshes do
									pcall(Unit.set_mesh_visibility, unit_3p, m, false)
								end
							end
						end
					end
				end
			elseif mod._fp_sprint_hidden then
				mod._fp_sprint_hidden = false
				mod._fp_burst = 0.5
			end
		end)
	else
		mod._fp_sprint_hidden = false
		mod._fp_sprint_is = false
	end

	if fp_active and mod:get("fp_lower_body") and mod:get("fp_hide_holstered") ~= false then
		pcall(fp_hide_holstered_units)
	end

	mod._poll_ttl = (mod._poll_ttl or 0) - dt

	if mod._poll_ttl > 0 then
		return
	end

	mod._poll_ttl = 0.5

	pcall(poll_reveal)

	-- The periodic diagnostics file is opt-in (a release build should not be
	-- writing to disk every few seconds). The /fpb command still reports on
	-- demand regardless, and the pitch telemetry the clamp calibrates against
	-- runs either way; only the file writing is gated here.
	if mod._diag_delay and mod:get("fp_diagnostics") then
		mod._diag_delay = mod._diag_delay - 0.5

		if mod._diag_delay <= 0 then
			mod._diag_delay = mod:get("fp_lower_body") and 5 or 60
			mod.write_diagnostics()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Diagnostics written to a file (mod log output does not reach console_logs)
-- ---------------------------------------------------------------------------
local function write_diagnostics()
	local lines = {
		"== First Person Body: diagnostics ==",
		string.format("version %s", tostring(mod.version)),
		"",
		string.format("option: %s | hook calls: %s | poll calls: %s | full passes: %s | units shown last pass: %s | restores: %s",
			tostring(mod:get("fp_lower_body")), tostring(mod._fp_hook_calls or 0), tostring(mod._fp_poll_calls or 0), tostring(mod._fp_full_passes or 0), tostring(mod._fp_last_shown or "never"), tostring(mod._fp_restores or 0)),
		string.format("hide tag carried by: %s", tostring(mod._fp_tag_name or "none")),
		string.format("spoof lies so far: %s | fade defeats: %s", tostring(mod._fp_spoof_calls or 0), tostring(mod._fp_fade_defeats or 0)),
		string.format("engine apis: get_child_units=%s is_mesh_visible=%s", type(Unit.get_child_units), type(Unit.is_mesh_visible)),
		string.format("mesh re-show hits: %s", tostring(mod._fp_reshow_hits or 0)),
		string.format("%s", tostring(mod._fp_nuke_result or "nuke test: not run")),
		string.format("wielded set respawns observed: %s (last at t=%s)", tostring(mod._fp_sig_changes or 0), tostring(mod._fp_sig_last or "never")),
		string.format("fov boost frames: %s (setting: %s%%)", tostring(mod._fp_fov_frames or 0), tostring(mod:get("fp_fov_boost") or 0)),
		string.format("camera pitch: current=%.1f deg | session max down=%.1f deg (positive = down)", mod._fp_pitch_deg or 0, mod._fp_pitch_max or 0),
		string.format("pitch clamp: on=%s sign=%s accepted=%.1f active=%s fires=%s", tostring(mod:get("fp_pitch_clamp")), tostring(mod._fp_clamp_sign or "uncalibrated"), mod._fp_pitch_prev or 0, tostring(mod._fp_clamp_active or false), tostring(mod._fp_clamp_fires or 0)),
		string.format("fx sources: on=%s truth frames=%s weapon moves=%s owned=%s last=%s", tostring(mod:get("fp_fx_sources")), tostring(mod._fp_fx_truth_frames or 0), tostring(mod._fp_fx_moves or 0), tostring(mod._fp_fx_owned or false), tostring(mod._fp_fx_last or "none")),
		string.format("fx relink: on=%s tracked=%s relinked=%s", tostring(mod:get("fp_fx_relink") ~= false), tostring(#tracked_particles), tostring(mod._fp_fx_relinks or 0)),
		string.format("customization compat: on=%s hooks=%s | holstered hidden=%s", tostring(mod:get("fp_customization_compat") ~= false), tostring(mod._fp_compat_hooks or 0), tostring(mod._fp_holstered_hidden or false)) .. string.format(" | honest answers=%s", tostring(mod._fp_truth_answers or 0)),
		string.format("sprint: option=%s detected=%s hide frames=%s | raw: %s", tostring(mod:get("fp_hide_sprint")), tostring(mod._fp_sprint_is or false), tostring(mod._fp_sprint_hides or 0), tostring(mod._fp_sprint_raw or "none")),
		string.format("re-shower: %s", tostring(mod._fp_reshow_trace or "none caught")),
	}

	local unit = local_player_unit()

	if not unit or not Unit.alive(unit) then
		lines[#lines + 1] = "player unit: none"
	else
		lines[#lines + 1] = "first person camera: " .. tostring(in_first_person(unit))

		local fp_ext = ScriptUnit.has_extension(unit, "first_person_system")

		if fp_ext then
			local ok_w, wants = pcall(fp_ext.wants_first_person_camera, fp_ext)
			local ok_m, mode1p = pcall(fp_ext.is_in_first_person_mode, fp_ext)

			lines[#lines + 1] = string.format("gate: %s | forced_3p: %s | wants_1p_cam: %s | equip_mode_1p: %s",
				tostring(camera_truly_first_person(unit)),
				tostring(fp_ext._force_third_person_mode),
				ok_w and tostring(wants) or "?",
				ok_m and tostring(mode1p) or "?")
		else
			lines[#lines + 1] = "first person extension: unreachable"
		end

		local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")
		local equipment = ext and ext._equipment

		if not equipment then
			lines[#lines + 1] = "equipment: unreachable"
		else
			local inv_parts = {}

			for slot_name, slot in pairs(equipment) do
				if slot.equipped or slot.unit_3p then
					inv_parts[#inv_parts + 1] = string.format("%s%s%s", slot_name,
						slot.wieldable and "[w]" or "",
						(slot.unit_3p and Unit.alive(slot.unit_3p)) and "+" or "-")
				end
			end

			table.sort(inv_parts)
			lines[#lines + 1] = "slots: " .. table.concat(inv_parts, " ")

			local inventory = ext._inventory_component
			local wielded_name = inventory and inventory.wielded_slot
			local wielded = wielded_name and equipment[wielded_name]

			if wielded and wielded.unit_3p and Unit.alive(wielded.unit_3p) then
				local mesh_ok, meshes = pcall(Unit.num_meshes, wielded.unit_3p)
				local scale_ok, scale_x = pcall(function()
					local v = Unit.local_scale(wielded.unit_3p, 1)

					return v and v.x
				end)
				local keys, units, alive_units, dead_units, total_meshes = 0, 0, 0, 0, 0

				if type(wielded.attachments_by_unit_3p) == "table" then
					for _, children in pairs(wielded.attachments_by_unit_3p) do
						keys = keys + 1

						if type(children) == "table" then
							units = units + #children

							for i = 1, #children do
								local attachment_unit = children[i]

								if attachment_unit and Unit.alive(attachment_unit) then
									alive_units = alive_units + 1

									local m_ok, m_n = pcall(Unit.num_meshes, attachment_unit)

									if m_ok and type(m_n) == "number" then
										total_meshes = total_meshes + m_n
									end
								else
									dead_units = dead_units + 1
								end
							end
						end
					end
				end

				local child_ok, children = pcall(Unit.get_child_units, wielded.unit_3p)

				local near_units, far_units, far_sample = 0, 0, nil
				local p_ok, player_pos = pcall(Unit.world_position, unit, 1)

				if p_ok and player_pos and type(wielded.attachments_by_unit_3p) == "table" then
					for _, children_list in pairs(wielded.attachments_by_unit_3p) do
						if type(children_list) == "table" then
							for i = 1, #children_list do
								local attachment_unit = children_list[i]

								if attachment_unit and Unit.alive(attachment_unit) then
									local w_ok, w_pos = pcall(Unit.world_position, attachment_unit, 1)

									if w_ok and w_pos then
										local d_ok, dist = pcall(function()
											return Vector3.length(w_pos - player_pos)
										end)

										if d_ok and type(dist) == "number" then
											if dist < 3 then
												near_units = near_units + 1
											else
												far_units = far_units + 1
												far_sample = far_sample or string.format("%.1f m away", dist)
											end
										end
									end
								end
							end
						end
					end
				end

				lines[#lines + 1] = string.format("map unit positions: near player=%s far=%s (%s)",
					tostring(near_units), tostring(far_units), tostring(far_sample or "none"))
				lines[#lines + 1] = string.format("wielded %s: meshes=%s scale=%s map_keys=%s map_units=%s alive=%s dead=%s map_meshes=%s children=%s",
					tostring(wielded_name),
					mesh_ok and tostring(meshes) or "?",
					(scale_ok and type(scale_x) == "number") and string.format("%.4f", scale_x) or "?",
					tostring(keys), tostring(units), tostring(alive_units), tostring(dead_units), tostring(total_meshes),
					child_ok and type(children) == "table" and tostring(#children) or "?")
			end
			local slots = { "slot_gear_lowerbody", "slot_body_legs", "slot_body_torso", "slot_body_arms", "slot_gear_upperbody" }

			for i = 1, #slots do
				local slot = equipment[slots[i]]
				local unit_1p = slot and slot.unit_1p
				local unit_3p = slot and slot.unit_3p
				local item = slot and slot.item
				local item_name = item and item.name or "none"

				lines[#lines + 1] = string.format("%s: %s 1p=%s 3p=%s hidden_1p=%s hidden_3p=%s", slots[i], tostring(item_name),
					tostring(unit_1p and Unit.alive(unit_1p) and "alive" or "missing"),
					tostring(unit_3p and Unit.alive(unit_3p) and "alive" or "missing"),
					slot and tostring(slot.hidden_1p) or "-",
					slot and tostring(slot.hidden_3p) or "-")
			end
		end
	end

	local report = table.concat(lines, "\n")
	local mods_root = rawget(_G, "Mods")
	local io_lib = mods_root and mods_root.lua and mods_root.lua.io
	local file = io_lib and io_lib.open("./../mods/FirstPersonBody/fpb_diag.txt", "w")

	if file then
		file:write(report .. "\n")
		file:close()
	end

	return report
end

function mod.write_diagnostics()
	local ok, report = pcall(write_diagnostics)

	return ok and report or nil
end

-- Identity probe (safe, twice field-proven): unlink the wielded weapon's
-- bookkept units and drop them 200m. Whatever moves is the bookkept set;
-- whatever stays on screen is an orphan. Re-equip restores. (The census
-- dragnet variant is retired: enumerating and touching arbitrary world
-- units hard-faulted the engine beneath pcall.)
function mod.run_nuke_test()
	local unit = local_player_unit()

	if not unit or not Unit.alive(unit) then
		return
	end

	local ext = ScriptUnit.has_extension(unit, "visual_loadout_system")
	local equipment = ext and ext._equipment
	local inventory = ext and ext._inventory_component
	local wielded_name = inventory and inventory.wielded_slot
	local wielded = wielded_name and equipment and equipment[wielded_name]

	if not wielded then
		return
	end

	local world = Managers.world and Managers.world:world("level_world")
	local moved = 0

	local function nuke(target_unit)
		if not target_unit or not Unit.alive(target_unit) then
			return
		end

		if world then
			pcall(World.unlink_unit, world, target_unit)
		end

		local ok = pcall(function()
			local pos = Unit.world_position(target_unit, 1)

			Unit.set_local_position(target_unit, 1, pos + Vector3(0, 0, -200))
		end)

		if ok then
			moved = moved + 1
		end
	end

	nuke(wielded.unit_3p)

	for_each_attachment(wielded.attachments_by_unit_3p, nuke)

	mod._fp_nuke_result = string.format("nuke test: moved %s units of %s", tostring(moved), tostring(wielded_name))
	pcall(function()
		mod:echo(mod._fp_nuke_result)
	end)
end

function mod.on_setting_changed(setting_id)
	if setting_id == "fp_lower_body" then
		mod.refresh_first_person_body()
	elseif setting_id == "fpb_nuke_test" and mod:get("fpb_nuke_test") then
		pcall(mod.run_nuke_test)
		mod:set("fpb_nuke_test", false, false)
	end
end

mod:command("fpb", "Report the First Person Body state", function()
	local report = mod.write_diagnostics()

	if report then
		mod:echo(report)
	end
end)

-- Leaving gameplay takes the mission world with it, so everything tracked
-- from that world is dropped before anything can ask about it again.
function mod.on_game_state_changed(status, state_name)
	if state_name == "StateGameplay" or state_name == "StateLoading" then
		pcall(fp_forget_particles)
	end
end
