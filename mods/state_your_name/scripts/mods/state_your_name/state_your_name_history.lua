local mod = get_mod("state_your_name")
local DMF = get_mod("DMF")

local _io = DMF:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then _io = DMF.deepcopy(Mods.lua.io) end

local _os = DMF:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then _os = DMF.deepcopy(Mods.lua.os) end

local HISTORY_FOLDER = "/Fatshark/Darktide/teammate_tracker_history/"
local HISTORY_FILE = "teammate_tracker_history.txt"

local History = {
	records = {},
	active = nil,
	_roster_timer = 0,
	_loaded = false,
}

local function safe_call(object, method_name, ...)
	if not object or type(object[method_name]) ~= "function" then
		return nil
	end

	local ok, result = pcall(object[method_name], object, ...)

	return ok and result or nil
end

local function split_plain(value, separator)
	local fields = {}
	local start = 1
	separator = separator or ";"

	while true do
		local stop = string.find(value, separator, start, true)

		if not stop then
			fields[#fields + 1] = string.sub(value, start)
			break
		end

		fields[#fields + 1] = string.sub(value, start, stop - 1)
		start = stop + #separator
	end

	return fields
end

local function sanitize(value)
	value = tostring(value or "")
	value = value:gsub("[:;\r\n]", "-")

	return value
end

local function normalized(value)
	return string.lower(tostring(value or ""))
end

local function directory_exists(path)
	local ok, _, code = _os.rename(path .. "/", path .. "/")

	return ok or code == 13
end

function History:path()
	local appdata = _os.getenv("APPDATA")

	return appdata and appdata .. HISTORY_FOLDER .. HISTORY_FILE or nil
end

function History:_ensure_directory()
	local appdata = _os.getenv("APPDATA")

	if not appdata then
		return false
	end

	local path = appdata .. HISTORY_FOLDER

	if not directory_exists(path) then
		pcall(_os.execute, 'mkdir "' .. path .. '"')
	end

	return directory_exists(path)
end

function History:_record(account_id)
	local record = self.records[account_id]

	if not record then
		record = {
			account_id = account_id,
			wins = 0,
			losses = 0,
			games = 0,
			quits = 0,
			seen = 0,
			names = {},
		}
		self.records[account_id] = record
	end

	return record
end

function History:_ingest_line(line)
	if type(line) ~= "string" or line == "" then
		return
	end

	local entries = split_plain(line, ";")
	local timestamp = entries[1]
	local outcome = entries[2]
	local mission_name

	for i = 3, #entries do
		if string.sub(entries[i], 1, 13) == "mission_info:" then
			local mission = split_plain(entries[i], ":")
			mission_name = mission[2]
			break
		end
	end

	for i = 3, #entries do
		local entry = entries[i]

		if string.sub(entry, 1, 13) ~= "mission_info:" and entry ~= "" then
			local player = split_plain(entry, ":")
			local account_id = player[1]

			if account_id and account_id ~= "" then
				local record = self:_record(account_id)
				local name = player[4]
				local quit_code = tonumber(player[5]) or 0

				record.seen = record.seen + 1
				record.character_id = player[2] or record.character_id
				record.archetype = player[3] or record.archetype
				record.character_name = name or record.character_name

				if name and name ~= "" then
					record.names[normalized(name)] = name
				end

				if outcome == "won" then
					record.wins = record.wins + 1
					record.games = record.games + 1
				elseif outcome == "lost" then
					record.losses = record.losses + 1
					record.games = record.games + 1
				end

				if quit_code > 0 then
					record.quits = record.quits + 1
				end

				if not record.first_at or timestamp < record.first_at then
					record.first_at = timestamp
					record.first_mission = mission_name
				end

				if not record.last_at or timestamp > record.last_at then
					record.last_at = timestamp
					record.last_mission = mission_name
				end
			end
		end
	end
end

function History:load()
	self.records = {}
	self._loaded = true

	local path = self:path()

	if not path then
		return false
	end

	local file = _io.open(path, "r")

	if not file then
		self:_ensure_directory()
		file = _io.open(path, "a+")

		if file then file:close() end

		return file ~= nil
	end

	for line in file:lines() do
		self:_ingest_line(line)
	end

	file:close()

	return true
end

function History:on_enabled()
	if not self._loaded then
		self:load()
	end
end

function History:record_for(account_id)
	if not account_id or account_id == mod.identity:local_account_id() then
		return nil
	end

	return self.records[account_id]
end

function History:is_first_drop(account_id)
	if mod:get("track_history") == false or not account_id or account_id == mod.identity:local_account_id() then
		return false
	end

	return self.records[account_id] == nil
end

function History:record_text(account_id, expanded, glyphs, presentation)
	local record = self:record_for(account_id)
	local minimum = tonumber(mod:get("record_min_games")) or 1

	if not record or record.games < minimum then
		return nil
	end

	local separator = "·"
	local winrate = record.games > 0 and math.floor(record.wins / record.games * 100 + 0.5) or 0
	local text

	if expanded then
		text = tostring(record.wins) .. "W" .. separator .. tostring(record.losses) .. "L"

		if mod:get("show_quits") ~= false and record.quits > 0 then
			text = text .. separator .. tostring(record.quits) .. "Q"
		end
	else
		local style = mod:get("record_style") or "winrate_games"
		local legacy = presentation == "registry" or presentation == "dossier" or presentation == "rail" or presentation == "classic"

		if legacy then
			text = "+" .. tostring(record.wins) .. " -" .. tostring(record.losses)
		elseif style == "wins_losses" then
			text = tostring(record.wins) .. "W" .. separator .. tostring(record.losses) .. "L"
		elseif style == "games" then
			text = (glyphs and glyphs.times or "x") .. tostring(record.games)
		elseif presentation == "cogitator" then
			text = tostring(winrate) .. "%:" .. tostring(record.games) .. "G"
		elseif presentation == "litany" then
			text = tostring(winrate) .. "%:" .. tostring(record.games) .. "G"
		else
			text = tostring(winrate) .. "%" .. separator .. tostring(record.games) .. "G"
		end
	end

	return text, winrate
end

function History:find_by_name(name)
	local query = normalized(name)
	local partial

	if query == "" then
		return nil
	end

	for _, record in pairs(self.records) do
		for normalized_name in pairs(record.names or {}) do
			if normalized_name == query then
				return record
			elseif not partial and string.find(normalized_name, query, 1, true) then
				partial = record
			end
		end
	end

	return partial
end

function History:lookup_text(name)
	local record = self:find_by_name(name)

	if not record then
		return string.format(mod:localize("record_not_found"), tostring(name or ""))
	end

	local display_name = record.character_name or name or record.account_id
	local first = record.first_at or mod:localize("record_unknown_date")
	local last = record.last_at or mod:localize("record_unknown_date")
	local first_mission = record.first_mission or "?"
	local last_mission = record.last_mission or "?"

	if rawget(_G, "Localize") then
		local first_ok, first_localized = pcall(Localize, first_mission)
		local last_ok, last_localized = pcall(Localize, last_mission)

		if first_ok and first_localized and first_localized ~= "" then first_mission = first_localized end
		if last_ok and last_localized and last_localized ~= "" then last_mission = last_localized end
	end

	return string.format("%s — %dW · %dL · %dQ · %d games · first %s (%s) · last %s (%s)", display_name, record.wins, record.losses, record.quits, record.games, first, first_mission, last, last_mission)
end

function History:begin(params)
	if mod:get("track_history") == false then
		self.active = nil
		return
	end

	params = params or {}
	local mechanism_data = params.mechanism_data or {}
	local mission_name = params.mission_name or safe_call(Managers.state and Managers.state.mission, "mission_name")
	local game_mode = params.game_mode_name or params.game_mode or safe_call(Managers.mechanism, "mechanism_name") or "coop_complete_objective"

	if not mission_name or string.find(mission_name, "hub", 1, true) or game_mode == "hub" then
		self.active = nil
		return
	end

	local challenge = mechanism_data.challenge or params.challenge
	local resistance = mechanism_data.resistance or params.resistance or 1
	local difficulty = challenge and ("havoc_rank_" .. tostring(challenge)) or ("difficulty_" .. tostring(resistance))

	self.active = {
		mission_name = mission_name,
		difficulty = difficulty,
		circumstance = mechanism_data.circumstance_name or "default",
		game_mode = game_mode,
		session_id = "unknown_session_id",
		roster = {},
		recorded = false,
		elapsed = 0,
	}
	self._roster_timer = 0
	self:capture_roster()
end

function History:capture_roster()
	local active = self.active
	local player_manager = Managers.player

	if not active or active.recorded or not player_manager then
		return
	end

	local players = safe_call(player_manager, "human_players") or {}
	local current_accounts = {}

	for _, player in pairs(players) do
		local account_id = safe_call(player, "account_id")
		local profile = safe_call(player, "profile")

		if account_id and profile then
			current_accounts[account_id] = true
			local archetype = profile.archetype
			local roster_entry = active.roster[account_id] or {}

			roster_entry.account_id = account_id
			roster_entry.character_id = profile.character_id or "unknown_character_id"
			roster_entry.archetype = archetype and archetype.name or "unknown"
			roster_entry.name = safe_call(player, "name") or profile.name or "Unknown"
			roster_entry.missing_since = nil
			roster_entry.departed = false
			active.roster[account_id] = roster_entry
		end
	end

	-- Do not treat the normal empty spawn/teardown windows as quits. Once a
	-- roster has existed for a few seconds, an account must stay absent across
	-- three polls before it is written with teammate_tracker's quit code 2.
	if active.elapsed >= 5 then
		for account_id, player in pairs(active.roster) do
			if not current_accounts[account_id] and not player.departed then
				player.missing_since = player.missing_since or active.elapsed

				if active.elapsed - player.missing_since >= 3 then
					player.departed = true
				end
			end
		end
	end
end

function History:update(dt)
	if not self.active or self.active.recorded then
		return
	end

	self.active.elapsed = (self.active.elapsed or 0) + dt
	self._roster_timer = self._roster_timer - dt

	if self._roster_timer <= 0 then
		self._roster_timer = 1
		self:capture_roster()
	end
end

function History:_normalized_outcome(outcome)
	outcome = string.lower(tostring(outcome or "left"))

	if outcome == "won" or outcome == "win" or outcome == "victory" then
		return "won"
	elseif outcome == "lost" or outcome == "loss" or outcome == "defeat" or outcome == "failed" then
		return "lost"
	end

	return "left"
end

function History:finish(outcome)
	local active = self.active

	if not active or active.recorded or mod:get("track_history") == false then
		return
	end

	self:capture_roster()

	local normalized_outcome = self:_normalized_outcome(outcome)
	local local_id = mod.identity:local_account_id()
	local fields = { _os.date("%Y-%m-%d %H:%M:%S"), normalized_outcome }

	for account_id, player in pairs(active.roster) do
		local quit_code = player.departed and 2 or 0

		if normalized_outcome == "left" and account_id == local_id then
			quit_code = 1
		end

		fields[#fields + 1] = table.concat({
			sanitize(account_id),
			sanitize(player.character_id),
			sanitize(player.archetype),
			sanitize(player.name),
			tostring(quit_code),
		}, ":")
	end

	fields[#fields + 1] = table.concat({
		"mission_info",
		sanitize(active.mission_name),
		sanitize(active.difficulty),
		sanitize(active.circumstance),
		sanitize(active.session_id),
		sanitize(active.game_mode),
	}, ":")

	local line = table.concat(fields, ";")
	local path = self:path()

	if path and self:_ensure_directory() then
		local file = _io.open(path, "a+")

		if file then
			file:write(line .. "\n")
			file:flush()
			file:close()
		end
	end

	self:_ingest_line(line)
	active.recorded = true
	mod._identity_revision = mod._identity_revision + 1
end

function History:on_gameplay_exit()
	if self.active and not self.active.recorded then
		self:finish("left")
	end

	self.active = nil
end

mod.history = History
