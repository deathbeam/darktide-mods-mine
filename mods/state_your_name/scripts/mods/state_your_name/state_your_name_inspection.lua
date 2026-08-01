local mod = get_mod("state_your_name")

local Inspection = {
	_pending = nil,
	_active_player = nil,
	_active_source = nil,
}

local PENDING_TIMEOUT = 8
local INVENTORY_VIEW = "inventory_background_view"
local PARTY_INSPECTOR_IDS = {
	"InspectFromPartyFinder",
	"inspect_from_party_finder",
}

local function safe_call(target, method, ...)
	local callback = target and target[method]

	if type(callback) ~= "function" then
		return nil
	end

	local ok, result = pcall(callback, target, ...)

	return ok and result or nil
end

local function notify(localization_key)
	local text = mod:localize(localization_key)

	if type(mod.notify) == "function" then
		mod:notify(text)
	elseif Managers.event then
		Managers.event:trigger("event_add_notification_message", "alert", {
			text = text,
		})
	end
end

function Inspection:surface_enabled(surface)
	if mod:get("enable_inspection") == false then
		return false
	end

	return mod:get("inspect_" .. tostring(surface)) ~= false
end

-- Inspect From Party Finder is deliberately treated as a compatible owner of
-- that one surface. If it is enabled, its button and callbacks stay in charge;
-- Social and lobby inspection from State Your Name remain available.
function Inspection:other_party_inspector_active()
	for i = 1, #PARTY_INSPECTOR_IDS do
		local ok, other = pcall(get_mod, PARTY_INSPECTOR_IDS[i])

		if ok and other and other ~= mod then
			if type(other.is_enabled) ~= "function" then
				return true
			end

			local state_ok, enabled = pcall(other.is_enabled, other)

			if not state_ok or enabled ~= false then
				return true
			end
		end
	end

	return false
end

function Inspection:_profile_from_info(player_info, explicit_profile)
	if explicit_profile then
		return explicit_profile
	end

	return safe_call(player_info, "profile")
end

function Inspection:_live_player(player_info, account_id)
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	local unique_id = player_info and player_info._player_unique_id
	local player = unique_id and (safe_call(player_manager, "player_from_unique_id", unique_id) or safe_call(player_manager, "human_player", unique_id))

	if player and not player.__deleted then
		return player
	end

	local players = safe_call(player_manager, "human_players") or safe_call(player_manager, "players") or {}

	for _, candidate in pairs(players) do
		if candidate and not candidate.__deleted and safe_call(candidate, "account_id") == account_id then
			return candidate
		end
	end

	return nil
end

-- Party Finder and the social roster can expose a complete presence profile
-- without creating a gameplay Player object. The inventory UI only needs this
-- small, read-only player contract. Local peer IDs keep the native talent views
-- alive while the proxy is open; every mutation path is independently blocked
-- by is_readonly and by the proxy not being the local player instance.
function Inspection:_profile_proxy(player_info, account_id, profile)
	local player_manager = Managers.player
	local local_player = player_manager and safe_call(player_manager, "local_player", 1)
	local local_peer_id = safe_call(local_player, "peer_id")
	local local_player_id = safe_call(local_player, "local_player_id") or 1
	local archetype = profile and profile.archetype
	local proxy = {
		remote = true,
		__deleted = false,
		__syn_inspection_proxy = true,
	}

	function proxy:profile()
		return profile
	end

	function proxy:character_id()
		return profile and profile.character_id
	end

	function proxy:archetype_name()
		return archetype and archetype.name
	end

	function proxy:account_id()
		return account_id
	end

	function proxy:name()
		return profile and profile.name or safe_call(player_info, "character_name") or mod:localize("unknown_player")
	end

	function proxy:peer_id()
		return local_peer_id
	end

	function proxy:local_player_id()
		return local_player_id
	end

	function proxy:unique_id()
		return "syn-inspection:" .. tostring(account_id or profile and profile.character_id or "unknown")
	end

	function proxy:slot()
		return safe_call(player_info, "slot") or 1
	end

	return proxy
end

function Inspection:resolve_player(player_info, explicit_profile, explicit_account_id)
	local account_id = explicit_account_id or safe_call(player_info, "account_id")
	local live_player = self:_live_player(player_info, account_id)
	local live_profile = safe_call(live_player, "profile")

	if live_player and live_profile then
		return live_player, live_profile
	end

	local profile = self:_profile_from_info(player_info, explicit_profile)

	if profile then
		return self:_profile_proxy(player_info, account_id, profile), profile
	end

	return nil, nil
end

function Inspection:_profile_is_inspectable(profile)
	return profile ~= nil
		and profile.character_id ~= nil
		and profile.archetype ~= nil
		and profile.loadout ~= nil
end

function Inspection:_open(player, source)
	local ui_manager = Managers.ui
	local profile = safe_call(player, "profile")

	if not ui_manager or not self:_profile_is_inspectable(profile) then
		notify("inspection_unavailable")
		return false
	end

	if safe_call(ui_manager, "view_active", INVENTORY_VIEW) then
		notify("inspection_already_open")
		return false
	end

	local context = {
		is_readonly = true,
		player = player,
		syn_inspection = true,
		syn_inspection_source = source,
	}
	local ok = pcall(ui_manager.open_view, ui_manager, INVENTORY_VIEW, nil, nil, nil, nil, context)

	if not ok then
		notify("inspection_unavailable")
		return false
	end

	self._active_player = player
	self._active_source = source

	return true
end

function Inspection:inspect_player(player, source)
	if not self:surface_enabled(source) then
		return false
	end

	if not player or player.__deleted then
		notify("inspection_unavailable")
		return false
	end

	self._pending = nil

	return self:_open(player, source)
end

function Inspection:inspect_player_info(player_info, source, explicit_profile, explicit_account_id)
	if not self:surface_enabled(source) then
		return false
	end

	local player, profile = self:resolve_player(player_info, explicit_profile, explicit_account_id)

	if player and self:_profile_is_inspectable(profile) then
		self._pending = nil

		return self:_open(player, source)
	end

	self._pending = {
		account_id = explicit_account_id or safe_call(player_info, "account_id"),
		elapsed = 0,
		player_info = player_info,
		profile = explicit_profile,
		source = source,
	}
	notify("inspection_loading")

	return false
end

function Inspection:inspect_account(account_id, source, explicit_profile)
	local social = Managers.data_service and Managers.data_service.social
	local player_info = social and account_id and safe_call(social, "get_player_info_by_account_id", account_id)

	return self:inspect_player_info(player_info, source, explicit_profile, account_id)
end

function Inspection:update(dt)
	local ui_manager = Managers.ui

	if self._active_player and (not ui_manager or not safe_call(ui_manager, "view_active", INVENTORY_VIEW)) then
		self._active_player = nil
		self._active_source = nil
	end

	local pending = self._pending

	if not pending then
		return
	end

	pending.elapsed = pending.elapsed + (dt or 0)

	local player, profile = self:resolve_player(pending.player_info, pending.profile, pending.account_id)

	if player and self:_profile_is_inspectable(profile) then
		self._pending = nil
		self:_open(player, pending.source)
	elseif pending.elapsed >= PENDING_TIMEOUT then
		self._pending = nil
		notify("inspection_unavailable")
	end
end

function Inspection:shutdown()
	self._pending = nil

	local ui_manager = Managers.ui

	if self._active_player and ui_manager and safe_call(ui_manager, "view_active", INVENTORY_VIEW) then
		pcall(ui_manager.close_view, ui_manager, INVENTORY_VIEW)
	end

	self._active_player = nil
	self._active_source = nil
end

mod.inspection = Inspection
