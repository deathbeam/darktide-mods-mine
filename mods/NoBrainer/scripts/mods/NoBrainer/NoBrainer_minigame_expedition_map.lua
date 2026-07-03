local mod = get_mod("NoBrainer")
local S = mod._S

local POLL_INTERVAL = 1.0
local ACTIVE_GRACE = 5.0
local REGISTRY_GRACE = 2.0
local MARK_COOLDOWN = 3.0
local poll_timer = 0
local active_since = nil
local registry_signature = nil
local registry_changed_at = nil
local next_mark_at = 0
local last_handler = nil
local cooldown_logged_until = 0

local function _call(obj, method, ...)
	local fn = obj and obj[method]
	if not fn then return nil end

	local ok, a, b = pcall(fn, obj, ...)
	if ok then
		return a, b
	end

	return nil
end

local function _get_handler()
	local gm = Managers.state and Managers.state.game_mode
	if not gm then return nil end
	local mode = gm:game_mode()
	if not mode or not mode.get_navigation_handler then return nil end

	local ok, handler = pcall(mode.get_navigation_handler, mode)
	return ok and handler or nil
end

local function _game_time()
	return mod._time("gameplay") or mod._time("main") or 0
end

local function _registry_part(list, prefix)
	local keys = {}

	for idx in pairs(list or {}) do
		keys[#keys + 1] = idx
	end

	table.sort(keys)

	for i = 1, #keys do
		keys[i] = prefix .. tostring(keys[i])
	end

	return table.concat(keys, ",")
end

local function _registry_signature(handler)
	return _registry_part(_call(handler, "get_registered_opportunities"), "o")
		.. "|" .. _registry_part(_call(handler, "get_registered_exits"), "e")
end

local function _reset_readiness(reason)
	active_since = nil
	registry_signature = nil
	registry_changed_at = nil
	next_mark_at = 0
	cooldown_logged_until = 0

	if reason then
		mod._debug_event("expedition", "readiness_reset", { reason = reason })
	end
end

local function _target_exists(handler, level_index)
	local opportunities = _call(handler, "get_registered_opportunities") or {}
	local exits = _call(handler, "get_registered_exits") or {}

	return opportunities[level_index] ~= nil or exits[level_index] ~= nil
end

local function _find_best(list, handler, player_pos)
	local best, best_d2
	for idx, box in pairs(list or {}) do
		local _, marked = _call(handler, "player_slots_by_level_marked", idx)
		if not _call(handler, "is_level_completed", idx) and marked == 0 then
			local p = box and box:unbox()
			if p then
				local dx = p.x - player_pos.x
				local dy = p.y - player_pos.y
				local dz = p.z - player_pos.z
				local d2 = dx * dx + dy * dy + dz * dz
				if not best_d2 or d2 < best_d2 then
					best, best_d2 = idx, d2
				end
			end
		end
	end
	return best
end

local function _all_opps_done(handler)
	local opportunities = _call(handler, "get_registered_opportunities") or {}
	if not next(opportunities) then return false end
	for idx, _ in pairs(opportunities) do
		if not _call(handler, "is_level_completed", idx) then
			return false
		end
	end
	return true
end

local function _clear_auto_mark()
	poll_timer = 0
	mod._exp_auto_mark = nil
	_reset_readiness(nil)
end

local function _tick()
	local now = _game_time()
	local handler = _get_handler()
	if not handler then
		mod._exp_auto_mark = nil
		if last_handler then
			last_handler = nil
			_reset_readiness("no handler")
		end
		return
	end

	if handler ~= last_handler then
		last_handler = handler
		_reset_readiness("handler changed")
	end

	local active = _call(handler, "is_active")
	if active ~= true then
		mod._exp_auto_mark = nil
		_reset_readiness("inactive")
		return
	end

	if not active_since then
		active_since = now
		mod._debug_event("expedition", "active_grace_start", { grace = ACTIVE_GRACE })
		return
	end

	local active_elapsed = now - active_since
	if active_elapsed < ACTIVE_GRACE then
		mod._debug_event_throttle("exp_active_grace_event", 1.0, "expedition", "wait", { elapsed = active_elapsed, reason = "active_grace", wait = ACTIVE_GRACE })
		return
	end

	local signature = _registry_signature(handler)
	if signature ~= registry_signature or not registry_changed_at then
		registry_signature = signature
		registry_changed_at = now
		mod._exp_auto_mark = nil
		mod._debug_event("expedition", "registry_changed", { signature = signature, wait = REGISTRY_GRACE })
		return
	end

	local registry_elapsed = now - (registry_changed_at or now)
	if registry_elapsed < REGISTRY_GRACE then
		mod._debug_event_throttle("exp_registry_grace_event", 1.0, "expedition", "wait", { elapsed = registry_elapsed, reason = "registry_stable", wait = REGISTRY_GRACE })
		return
	end

	if now < next_mark_at then
		if cooldown_logged_until ~= next_mark_at then
			cooldown_logged_until = next_mark_at
			mod._debug_event("expedition", "wait", { reason = "mark_cooldown", remaining = next_mark_at - now, until_t = next_mark_at })
		end

		return
	end

	local player_manager = Managers.player
	local player = player_manager and player_manager:local_player_safe(1)
	local slot = player and player:slot()
	local unit = player and player.player_unit
	local pos = unit and Unit.alive(unit) and Unit.world_position(unit, 1)
	if not slot or not pos then return end
	if not Managers.state or not Managers.state.game_session then return end

	local psm = handler._player_slot_marked
	local my_mark = psm and psm[slot]

	if my_mark and my_mark ~= mod._exp_auto_mark then
		mod._exp_auto_mark = nil
		return
	end

	local last = mod._exp_auto_mark
	if last then
		local slots = _call(handler, "player_slots_by_level_marked", last)
		if slots and slots[slot] then
			if not _call(handler, "is_level_completed", last) then
				return
			end
		elseif _call(handler, "is_level_completed", last) then
		else
			mod._exp_auto_mark = nil
			return
		end
	end

	local nearest = _find_best(_call(handler, "get_registered_opportunities"), handler, pos)
	local mark_reason = "nearest_poi"
	if not nearest and S("enable_expedition_automark_vault") and _all_opps_done(handler) then
		nearest = _find_best(_call(handler, "get_registered_exits"), handler, pos)
		mark_reason = "vault"
	end
	if nearest then
		if not _target_exists(handler, nearest) then
			mod._debug_event("expedition", "mark_skipped", { reason = "target_disappeared", target = nearest })
			next_mark_at = now + MARK_COOLDOWN
			cooldown_logged_until = 0
			return
		end

		if _call(handler, "is_level_completed", nearest) then
			mod._debug_event("expedition", "mark_skipped", { reason = "completed", target = nearest })
			next_mark_at = now + MARK_COOLDOWN
			cooldown_logged_until = 0
			return
		end

		local marked_slots = _call(handler, "player_slots_by_level_marked", nearest)
		if marked_slots and marked_slots[slot] then
			mod._debug_event("expedition", "mark_skipped", { reason = "already_marked", slot = slot, target = nearest })
			mod._exp_auto_mark = nearest
			next_mark_at = now + MARK_COOLDOWN
			cooldown_logged_until = 0
			return
		end

		local reason = mark_reason
		mod._debug_event("expedition", "mark_attempt", { cooldown = MARK_COOLDOWN, reason = reason, slot = slot, target = nearest })
		next_mark_at = now + MARK_COOLDOWN
		cooldown_logged_until = 0
		local impacted, assigned = _call(handler, "mark_level_by_player", nearest, player)
		if impacted and assigned then
			mod._debug_event("expedition", "mark_success", { assigned = assigned, impacted = impacted, reason = reason, target = nearest })
			mod._exp_auto_mark = nearest
			if not S("expedition_automark_silent") then
				mod:echo("NoBrainer: auto-marked nearest expedition POI")
			end
		else
			mod._debug_event("expedition", "mark_failed", { assigned = assigned, impacted = impacted, reason = reason, target = nearest })
		end
	end
end

local function on_update(dt)
	if not mod:is_enabled() then return end
	if not S("enable_expedition_automark") then
		_clear_auto_mark()
		return
	end
	poll_timer = poll_timer + dt
	if poll_timer < POLL_INTERVAL then return end
	poll_timer = 0
	_tick()
end

local function on_round_end()
	_clear_auto_mark()
end

mod._reg("update", on_update)
mod._reg("round_end", on_round_end)
mod._reg("disabled", _clear_auto_mark)
mod._reg("unload", _clear_auto_mark)

return true
