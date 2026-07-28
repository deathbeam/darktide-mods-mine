local mod = get_mod("HavocQuickplay")

mod.VERSION = "2.3.2"

mod.C = {
	MAX_HAVOC_RANK      = 40,
	MIN_HAVOC_RANK      = 1,
	HAVOC_MIN_LEVEL     = 30,
	PARTY_MAX           = 4,
	SENTINEL_ACCOUNT    = "00000000-0000-0000-0000-000000000000",
	PAGE_NAME           = "havoc",
	PAGE_ICON           = "content/ui/materials/icons/generic/havoc",
	PAGE_COLOR          = { 255, 252, 44, 178 },
	WARN_COLOR          = { 255, 250, 236, 4 },
	BASE_TAGS           = { "havoc", "game_mode", "my_havoc_order" },
	SWEEP_INTERVAL      = 1,
	STREAM_WARMUP       = 3,
	COUNTDOWN           = 8,
	DECLINE_TTL         = 1800,
	HOLD_REPEAT_DELAY   = 0.6,
	HOLD_REPEAT_RATE    = 0.08,
	RANK_TTL            = 300,
	RANK_ERROR_BACKOFF  = 60,
	CANCEL_ACTION       = "cancel_matchmaking",
}

mod.STATE = {
	IDLE      = "idle",
	SEARCHING = "searching",
	COUNTDOWN = "countdown",
	JOINING   = "joining",
}

mod.S = {
	state              = mod.STATE.IDLE,
	sweep_timer        = 0,
	next_request_at    = nil,
	next_refresh_at    = nil,

	order              = nil,
	order_fetched_at   = 0,
	order_pending      = false,
	unlock_status      = nil,
	cadence_active     = nil,

	stream_id          = nil,
	listings           = {},

	offers             = {},
	countdown_ends_at  = nil,

	declines           = {},

	notif_id           = nil,
	notif_next_update  = 0,

	queue_blocked      = false,
	left_mission_by_us = false,
	left_mission_at    = nil,

	hosting            = false,
	host_party_id      = nil,
	host_pending       = false,
	host_autostart_off = false,
	host_seen_active   = false,
	host_launched     = false,

	rank_cache         = {},
	rank_pending       = {},
}

local setting_cache = {}

mod.setting = function(id)
	local value = setting_cache[id]

	if value == nil then
		value = mod:get(id)
		setting_cache[id] = value
	end

	return value
end

local _set = mod.set

mod.set = function(self, id, ...)
	setting_cache[id] = nil

	return _set(self, id, ...)
end

mod.on_setting_changed = function(setting_id)
	setting_cache[setting_id] = nil

	if setting_id == "hq_min_rank" and mod.max_rank() < mod.min_rank() then
		mod:set("hq_max_rank", mod.min_rank())
	elseif setting_id == "hq_max_rank" and mod.max_rank() < mod.min_rank() then
		mod:set("hq_min_rank", mod.max_rank())
	end
end

mod.now = function()
	local time_manager = Managers.time

	if not time_manager or not time_manager:has_timer("main") then
		return 0
	end

	return time_manager:time("main")
end

mod.debug = function(fmt, ...)
	if not mod.setting("hq_debug") then
		return
	end

	local ok, text = pcall(string.format, fmt, ...)

	mod:info("%s", ok and text or tostring(fmt))
end

mod.say = function(text)
	mod:notify("%s", tostring(text))
end

mod.loc = function(key, ...)
	return mod:localize(key, ...)
end

mod.clamp_rank = function(value)
	local C = mod.C

	if type(value) ~= "number" then
		return C.MIN_HAVOC_RANK
	end

	if value < C.MIN_HAVOC_RANK then
		return C.MIN_HAVOC_RANK
	end

	if value > C.MAX_HAVOC_RANK then
		return C.MAX_HAVOC_RANK
	end

	return math.floor(value)
end

mod.local_player = function()
	local player_manager = Managers.player

	return player_manager and player_manager:local_player(1) or nil
end

mod.local_account_id = function()
	local player = mod.local_player()

	return player and player:account_id() or nil
end

mod.character_level = function()
	local player = mod.local_player()

	if not player then
		return nil
	end

	local ok, profile = pcall(player.profile, player)

	return ok and profile and tonumber(profile.current_level) or nil
end

mod.character_id = function()
	local player = mod.local_player()
	local ok, id = pcall(function()
		return player and player:character_id()
	end)

	return ok and id or "unknown"
end

mod.presence_name = function()
	local presence_manager = Managers.presence

	return presence_manager and presence_manager:presence() or nil
end

mod.in_hub = function()
	return mod.presence_name() == "hub"
end

mod.in_mission = function()
	local presence = mod.presence_name()

	return presence == "mission" or presence == "end_of_round"
end

mod.in_havoc_mission = function()
	local difficulty_manager = Managers.state and Managers.state.difficulty

	if not difficulty_manager or not difficulty_manager.get_parsed_havoc_data then
		return false
	end

	local ok, data = pcall(difficulty_manager.get_parsed_havoc_data, difficulty_manager)

	return ok and data ~= nil
end

mod.party = function()
	return Managers.party_immaterium
end

mod.party_size = function()
	local party_manager = mod.party()

	if not party_manager then
		return 1
	end

	local ok, members = pcall(party_manager.all_members, party_manager)

	if not ok or type(members) ~= "table" then
		return 1
	end

	local count = #members

	return count > 0 and count or 1
end

mod.party_id = function()
	local party_manager = mod.party()

	if not party_manager then
		return nil
	end

	local ok, id = pcall(party_manager.party_id, party_manager)

	return ok and id or nil
end

mod.region = function()
	local region_service = Managers.data_service and Managers.data_service.region_latency

	if not region_service then
		return nil
	end

	local ok, region = pcall(region_service.get_prefered_mission_region, region_service)

	return ok and region or nil
end

mod.set_state = function(new_state)
	local S = mod.S

	if S.state == new_state then
		return
	end

	mod.debug("state %s -> %s", S.state, new_state)

	S.state = new_state
end

mod.is_queued = function()
	return mod.S.state ~= mod.STATE.IDLE
end

local BASE = "HavocQuickplay/scripts/mods/HavocQuickplay/"

mod:io_dofile(BASE .. "HavocQuickplay_order")
mod:io_dofile(BASE .. "HavocQuickplay_host")
mod:io_dofile(BASE .. "HavocQuickplay_queue")
mod:io_dofile(BASE .. "HavocQuickplay_ui")

mod.update = function(dt)
	local S = mod.S

	if S.state ~= mod.STATE.IDLE then
		mod.queue_update(dt)
	end

	local timer = S.sweep_timer + dt

	if timer < mod.C.SWEEP_INTERVAL then
		S.sweep_timer = timer

		return
	end

	S.sweep_timer = 0

	mod.prune_declines()
	mod.host_sweep()

	if S.state ~= mod.STATE.IDLE then
		mod.queue_sweep()
	end
end

mod.on_game_state_changed = function(status, state_name)
	if status ~= "enter" then
		return
	end

	mod.refresh_order(true)

	if mod.in_hub() then
		mod.S.queue_blocked = false
	end
end

mod.on_disabled = function()
	mod.cancel_queue(nil)
	mod.stop_host()
end

mod.on_unload = function()
	mod.cancel_queue(nil)
	mod.stop_host()
end

mod.on_all_mods_loaded = function()
	mod.refresh_order(true)
end

mod:command("hqp_q", mod.loc("hq_cmd_queue_desc"), function()
	if mod.is_queued() then
		mod.say(mod.loc("hq_notify_already_queued"))

		return
	end

	mod.start_queue()
end)

mod:command("hqp_cancel", mod.loc("hq_cmd_cancel_desc"), function()
	if mod.is_queued() then
		mod.cancel_queue(mod.loc("hq_notify_cancelled"))
	elseif mod.S.hosting then
		mod.stop_host()
		mod.say(mod.loc("hq_notify_host_stopped"))
	else
		mod.say(mod.loc("hq_notify_not_queued"))
	end
end)

mod:command("hqp_status", mod.loc("hq_cmd_status_desc"), function()
	mod.print_status()
end)
