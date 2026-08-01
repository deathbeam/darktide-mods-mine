local mod = get_mod("state_your_name")

local Progression = require("scripts/backend/progression")
local UISettings = require("scripts/settings/ui/ui_settings")

-- CharacterSheet resolves a profile's selected talents into the same
-- ability/blitz/aura triple the lobby's own talent icons are built from, and
-- ProfileUtils composes vanilla's archetype row. Both are required defensively:
-- if either path moves, the kit display degrades to nothing rather than taking
-- every identity surface down with it.
local ok_character_sheet, CharacterSheet = pcall(require, "scripts/utilities/character_sheet")
local ok_profile_utils, ProfileUtils = pcall(require, "scripts/utilities/profile_utils")
local ok_wallet_settings, WalletSettings = pcall(require, "scripts/settings/wallet_settings")

CharacterSheet = ok_character_sheet and CharacterSheet or nil
ProfileUtils = ok_profile_utils and ProfileUtils or nil
WalletSettings = ok_wallet_settings and WalletSettings or nil

local Identity = {
	progressions = {},
	true_levels = {},
	xp_table = nil,
	_xp_backend = nil,
	_xp_request = nil,
	_xp_request_backend = nil,
	_xp_retry_delay = 0,
	_xp_warned = false,
	_progressions_request = nil,
	_progressions_request_backend = nil,
	_progressions_loaded = false,
	_progressions_retry_delay = 0,
	_progressions_warned = false,
	havoc_assignments = {},
	-- Every decorative glyph starts at a value PROVEN to render in the live
	-- proxima_nova_bold (screenshot-verified: em dash, middot, tilde, ASCII,
	-- and the Fatshark PUA insignia). Runtime verification may PROMOTE these
	-- to fancier characters, but only with positive proof; the old
	-- optimistic-default design shipped a .notdef box (U+2726) twice.
	glyphs = {
		arrow = ">",
		devotional = "+",
		emdash = "—",
		first_drop = "",
		-- Vanilla insignia glyphs, byte-escaped so this file stays ASCII-safe:
		-- U+E04F is what hub nameplates append after a Havoc rank, U+E006 after
		-- a character level ("Name - 30 <E006>").
		havoc_icon = "\238\129\143",
		level_icon = "\238\128\134",
		milestone = "*",
		ornament = "\194\183", -- middot
		times = "x",
	},
	_glyphs_verified = false,
}

-- Every surface's setting prefix. Overhead nameplates are TWO surfaces: the
-- Mourningstar and a mission are read completely differently (players want a
-- clean name over a teammate's head mid-fight but the full dataslate in the
-- hub), so each gets its own row here and its own settings.
--
-- The prefix is also the per-surface override prefix, e.g. "nameplates_mission"
-- yields nameplates_mission_name_style. Keep the historical prefixes for the
-- surfaces that already shipped; renaming them would silently reset saved
-- settings.
local SURFACE_PREFIX = {
	team_hud = "team_hud",
	nameplate_hub = "nameplates_hub",
	nameplate_mission = "nameplates_mission",
	lobby = "lobby",
	party_finder = "party_finder",
	chat = "chat",
	combat_feed = "combat_feed",
	menus = "menus",
	social = "social",
	spectator = "spectator",
}

local SURFACE_SETTINGS = {}

for surface, prefix in pairs(SURFACE_PREFIX) do
	SURFACE_SETTINGS[surface] = {
		enabled = "enable_" .. prefix,
		progression = prefix .. "_progression",
		prefix = prefix,
	}
end

-- Back-compat: "nameplate" was one surface before the hub/mission split. Any
-- caller still passing it (including this mod's own public API) resolves to the
-- mission nameplate, which is the one that matters in a fight.
SURFACE_SETTINGS.nameplate = SURFACE_SETTINGS.nameplate_mission
SURFACE_PREFIX.nameplate = SURFACE_PREFIX.nameplate_mission

local HISTORY_SURFACES = {
	team_hud = true,
	lobby = true,
	party_finder = true,
	menus = true,
	social = true,
}

-- Vanilla presence platform glyphs, byte-escaped so this file stays ASCII-safe.
-- Raw PUA characters read back as double-encoded mojibake in tooling and render
-- as broken boxes in game (exactly what shipped before). Codepoints are taken
-- verbatim from presence_entry_immaterium.lua:platform_icon(): U+E06B Steam,
-- U+E06C Xbox, U+E071 PlayStation. The mod tints every icon with the active
-- accent, so the PSN glyph is stored bare (vanilla inline white markup would
-- nest inside our colour tags and break the run).
local PLATFORM_ICONS = {
	steam = "\238\129\171",
	xbox = "\238\129\172",
	psn = "\238\129\177",
	ps5 = "\238\129\177",
	ps4 = "\238\129\177",
}

-- Further vanilla insignia offered as tracker icons, byte-escaped so this file
-- stays ASCII-safe. Each is a glyph the GAME itself draws inside a plain text
-- string — the same standard of proof as the level/Havoc insignia above, and the
-- reason none of these can ship as a .notdef box:
--   U+E005 generic operative  world_marker_template_nameplate.lua:176 (nameplate
--                             header, the fallback when a class has no icon)
--   U+E051 companion          world_marker_template_nameplate_companion.lua:20
--   U+E041 penance            penance_overview_view_blueprints.lua:612,808
local EXTRA_ICONS = {
	operative = "\238\128\133",
	companion = "\238\129\145",
	penance = "\238\129\129",
}

-- Currency insignia are read LIVE from vanilla's own wallet table (the same
-- trick the archetype icons use), so no codepoint is hard-coded and a patch that
-- changes them cannot leave us drawing a stale glyph.
local CURRENCY_ICON_KEYS = {
	credits = "credits",
	marks = "marks",
	aquila = "aquilas",
	plasteel = "plasteel",
	diamantine = "diamantine",
	salvage = "expedition_salvage",
	loot = "expedition_loot",
}

local COLORS = {
	account_dim = { 138, 132, 116 },
	bone = { 226, 220, 193 },
	character = { 255, 235, 190 },
	green = { 80, 205, 95 },
	blue = { 65, 155, 255 },
	purple = { 176, 82, 255 },
	orange = { 255, 132, 30 },
	red = { 245, 70, 58 },
	steel = { 145, 180, 205 },
	gold = { 230, 190, 90 },
}

local CUSTOM_COLOR_DEFAULTS = {
	character = COLORS.character,
	account = COLORS.account_dim,
	level = COLORS.bone,
	prestige = COLORS.bone,
	havoc = COLORS.gold,
	history = COLORS.green,
	kit = COLORS.steel,
	steam = { 102, 192, 244 },
	xbox = { 16, 185, 16 },
	psn = { 0, 112, 209 },
}

-- Surfaces that already print vanilla's own archetype row right below the name.
-- On those the kit is appended to that row instead of the identity line, so the
-- class is never printed twice and no surface grows an extra row.
local ARCHETYPE_ROW_SURFACES = {
	lobby = true,
	menus = true,
	party_finder = true,
}

-- Surfaces that only exist during a mission, for the Display Locations scope.
-- The hub nameplate is deliberately absent: it is a Mourningstar surface.
local MISSION_SURFACES = {
	team_hud = true,
	nameplate = true,
	nameplate_mission = true,
	combat_feed = true,
	chat = true,
	spectator = true,
}

-- Overhead nameplates, whichever context. These support the "second line"
-- progression placement; every other surface has a single row to write into.
local NAMEPLATE_SURFACES = {
	nameplate = true,
	nameplate_hub = true,
	nameplate_mission = true,
}

local ACCENTS = {
	imperial_gold = COLORS.gold,
	servo_green = { 103, 194, 105 },
	arterial_red = { 205, 73, 64 },
	bone_white = COLORS.bone,
}

-- Promotion chains: verification walks each chain and installs the FIRST entry
-- it can positively prove renders. Entries in PROVEN_GLYPHS need no proof;
-- everything else needs a working .notdef baseline plus a distinct measured
-- width, otherwise the safe default above simply stays. The failure mode is a
-- plainer separator, never a box.
local GLYPH_CHAINS = {
	arrow = { "›", ">" },
	devotional = { "†", "+" },
	emdash = { "—", "-" },
	first_drop = { "◇", "•", "" },
	-- No fallback: when the icon cannot be proven the value renders with its
	-- text label instead (glyph verification stores false).
	havoc_icon = { "\238\129\143" },
	level_icon = { "\238\128\134" },
	milestone = { "★", "•", "*" },
	ornament = { "✦", "◆", "•", "\194\183" },
	times = { "×", "x" },
}

-- Characters that render in the live fonts without needing measurement:
-- printable ASCII, plus non-ASCII characters seen rendering in-game
-- (screenshots): em dash, middot, and the two Fatshark insignia the mod uses.
local PROVEN_GLYPHS = {
	["—"] = true,
	["\194\183"] = true,
	["\238\129\143"] = true,
	["\238\128\134"] = true,
}

local function is_proven(glyph)
	if glyph == "" then
		return true
	end

	if PROVEN_GLYPHS[glyph] then
		return true
	end

	-- Printable ASCII only.
	return not glyph:find("[^\32-\126]")
end

local function safe_call(object, method_name, ...)
	if not object or type(object[method_name]) ~= "function" then
		return nil
	end

	local ok, result, second = pcall(object[method_name], object, ...)

	if ok then
		return result, second
	end

	return nil
end

local function nonempty(value)
	return type(value) == "string" and value ~= "" and value ~= "N/A" and value or nil
end

local PLACEHOLDER_NAMES = {
	["(unknown)"] = true,
	["<unknown>"] = true,
	["[n/a]"] = true,
	["[unknown]"] = true,
	["n/a"] = true,
	["unknown"] = true,
	["unknown operative"] = true,
	["unknown player"] = true,
}

local function is_placeholder_name(value)
	return type(value) == "string" and PLACEHOLDER_NAMES[string.lower(value)] == true
end

local function clean_name(value)
	value = nonempty(value)

	if not value then
		return nil
	end

	-- Color Selection decorates Player:name()/character_name() at the source.
	-- Consume only its known Darktide color wrappers before applying our normal
	-- brace escaping; otherwise safe markup becomes visible "[#color(...)]".
	-- Unrecognized brace content is still escaped below as name text.
	value = value:gsub("{#color%(%d+,%d+,%d+,%d+%)}", "")
	value = value:gsub("{#color%(%d+,%d+,%d+%)}", "")
	value = value:gsub("{#reset%(%)}", "")
	value = value:gsub("[%c]", " ")
	value = value:gsub("^%s+", ""):gsub("%s+$", "")

	if is_placeholder_name(value) then
		return nil
	end

	value = value:gsub("{", "["):gsub("}", "]")

	if mod:get("hide_discriminator") then
		value = value:gsub("#%d%d%d%d$", "")
	end

	value = value:gsub("^%s+", ""):gsub("%s+$", "")

	if is_placeholder_name(value) then
		return nil
	end

	local max_length = tonumber(mod:get("max_name_length")) or 24

	if max_length > 0 and rawget(_G, "Utf8") and Utf8.string_length(value) > max_length then
		-- ASCII ".." rather than an ellipsis character: truncation must never
		-- gamble on an unproven glyph.
		value = Utf8.sub_string(value, 1, math.max(max_length - 1, 1)) .. ".."
	end

	return nonempty(value)
end

local function normalized(value)
	value = value or ""
	value = value:gsub("#%d%d%d%d$", "")

	return string.lower(value)
end

local function current_time()
	local time_manager = Managers.time
	local value = time_manager and safe_call(time_manager, "time", "main")

	if value then
		return value
	end

	if rawget(_G, "Application") and type(Application.time_since_launch) == "function" then
		local ok, result = pcall(Application.time_since_launch)

		if ok then
			return result
		end
	end

	return 0
end

local function local_account_id()
	local grpc = rawget(_G, "gRPC")

	if grpc and type(grpc.get_account_id) == "function" then
		local ok, account_id = pcall(grpc.get_account_id)

		if ok then
			return account_id
		end
	end

	local presence_manager = Managers.presence
	local myself = presence_manager and safe_call(presence_manager, "presence_entry_myself")

	return safe_call(myself, "account_id")
end

local function presence_for(account_id)
	local presence_manager = Managers.presence

	if not presence_manager then
		return nil
	end

	if not account_id or account_id == "" then
		return safe_call(presence_manager, "presence_entry_myself")
	end

	return safe_call(presence_manager, "get_presence", account_id)
end

local function player_info_for(account_id)
	local social = Managers.data_service and Managers.data_service.social

	return social and account_id and safe_call(social, "get_player_info_by_account_id", account_id) or nil
end

local function color_markup(text, color, enabled)
	if not text or not enabled or not color then
		return text
	end

	return string.format("{#color(%d,%d,%d)}%s{#reset()}", color[1], color[2], color[3], text)
end

local function color_from_slot(slot_color)
	if type(slot_color) ~= "table" then
		return nil
	end

	if slot_color[4] then
		return { slot_color[2], slot_color[3], slot_color[4] }
	end

	return { slot_color[1], slot_color[2], slot_color[3] }
end

-- Color Selection deliberately decorates Player:name() at the source. We
-- strip that wrapper in clean_name() so it cannot leak into localization or be
-- double-wrapped, then reapply its live slot/class color here as ordinary
-- State Your Name markup. This keeps the two mods composable in either load
-- order while still honoring the color the player chose.
local function color_selection_mod()
	local ok, color_mod = pcall(get_mod, "ColorSelection")

	if not ok or not color_mod or color_mod == mod then
		return nil
	end

	if type(color_mod.is_enabled) == "function" then
		local enabled_ok, enabled = pcall(color_mod.is_enabled, color_mod)

		if not enabled_ok or enabled == false then
			return nil
		end
	end

	return color_mod
end

local function color_selection_color(account_id, slot)
	local color_mod = color_selection_mod()
	local getter = color_mod and color_mod.get_color_for_account_id

	if type(getter) ~= "function" then
		return nil
	end

	-- Color Selection exports this as a plain function rather than a colon
	-- method, so do not inject the mod table as the first argument.
	local ok, color = pcall(getter, account_id, slot)

	return ok and type(color) == "table" and color or nil
end

function Identity:color_selection_active()
	return color_selection_mod() ~= nil
end

-- How far a Color Selection pick reaches across one operative's line. Players
-- who use that mod to tell teammates apart mid-fight want the WHOLE entry in
-- their chosen colour, not just the character name.
local CS_SCOPE = {
	character = { character = true },
	character_and_account = { character = true, account = true },
	whole_line = { character = true, account = true, line = true },
}

local function scale_color(color, factor)
	return {
		math.floor(color[1] * factor + 0.5),
		math.floor(color[2] * factor + 0.5),
		math.floor(color[3] * factor + 0.5),
	}
end

function Identity:_color_selection_covers(run)
	local scope = CS_SCOPE[mod:get("color_selection_scope") or "character"] or CS_SCOPE.character

	return scope[run] == true
end

-- The live per-player pick, or nil when Color Selection is absent/disabled or
-- has not resolved a colour for this player.
function Identity:_color_selection_color(record)
	local color = record and record.slot_color

	if not color or not color_selection_mod() then
		return nil
	end

	return color
end

local function level_from_progression(progression, xp_table)
	if type(progression) ~= "table" then
		return nil
	end

	local current_level = tonumber(progression.currentLevel)
	local current_xp = tonumber(progression.currentXp)

	if not current_level then
		return nil
	end

	if type(xp_table) ~= "table" or #xp_table < 2 then
		return current_level
	end

	local max_level = #xp_table

	if current_level < max_level or not current_xp then
		return current_level
	end

	local max_level_xp = tonumber(xp_table[max_level])
	local previous_level_xp = tonumber(xp_table[max_level - 1])

	if not max_level_xp or not previous_level_xp or max_level_xp <= previous_level_xp then
		return current_level
	end

	local repeat_xp = max_level_xp - previous_level_xp
	local excess_xp = math.max(current_xp - max_level_xp, 0)

	return max_level + math.floor(excess_xp / repeat_xp)
end

function Identity:_recalculate(character_id)
	local progression = self.progressions[character_id]
	local level = level_from_progression(progression, self.xp_table)

	if level and self.true_levels[character_id] ~= level then
		self.true_levels[character_id] = level

		return true
	end

	return false
end

-- How many complete level-1-to-30 XP amounts the character has earned — the
-- "reached max level N times" count some players call prestige. The curve is
-- cumulative, so xp_table[max_level] is exactly the XP a fresh character needs
-- to reach the cap once, and dividing the running total by it counts the laps.
-- Needs the same real currentXp that drives true level (present on captured
-- progressions), so it returns nil until that has resolved.
function Identity:_prestige(character_id)
	if not character_id or type(self.xp_table) ~= "table" then
		return nil
	end

	local progression = self.progressions[character_id]
	local current_xp = progression and tonumber(progression.currentXp)
	local cap_xp = tonumber(self.xp_table[#self.xp_table])

	if not current_xp or not cap_xp or cap_xp <= 0 then
		return nil
	end

	return math.floor(current_xp / cap_xp)
end

-- Where the curve cache lives; a field so the offline harness can retarget it.
Identity.xp_curve_path = "./../mods/state_your_name/syn_xp_curve.txt"

local function mods_io()
	local mods_root = rawget(_G, "Mods")

	return mods_root and mods_root.lua and mods_root.lua.io
end

function Identity:_save_xp_table()
	if self._xp_table_saved or self._xp_table_source == "disk" or type(self.xp_table) ~= "table" then
		return
	end

	local io_lib = mods_io()
	local file = io_lib and io_lib.open(self.xp_curve_path, "w")

	if not file then
		return
	end

	for i = 1, #self.xp_table do
		file:write(tostring(self.xp_table[i]) .. "\n")
	end

	file:close()

	self._xp_table_saved = true
end

-- The character XP curve is static per game version, so one sighting (backend
-- fetch or an end-of-round report) is cached on disk and reloaded at startup.
-- That keeps total levels working from the first character-select frame even
-- when the backend fetch fails all session.
function Identity:load_cached_xp_table()
	if self.xp_table then
		return false
	end

	local io_lib = mods_io()
	local file = io_lib and io_lib.open(self.xp_curve_path, "r")

	if not file then
		return false
	end

	local values = {}

	for line in file:lines() do
		local value = tonumber(line)

		if value then
			values[#values + 1] = value
		end
	end

	file:close()

	for i = 2, #values do
		if values[i] <= values[i - 1] then
			return false
		end
	end

	return self:set_xp_table(values, "disk")
end

-- How much each curve source is trusted. The backend endpoint is the
-- authority; an end-of-round report is normally real but an offline session's
-- report carries a placeholder curve, so the backend may replace it; the disk
-- cache only seeds an empty session and never replaces a live value.
local XP_SOURCE_RANK = {
	disk = 1,
	end_of_round = 2,
	backend = 3,
}

-- The placeholder character curve DummySessionReport.fetch_xp_table hands out
-- when a session has no backend report (SoloPlay runs, testify). It once
-- slipped in through an offline end screen and extrapolated a level ~240
-- character to 2220, so no source is allowed to supply it.
local DUMMY_XP_TABLE = {
	0,
	100,
	200,
	500,
	1085,
	1755,
	2510,
	3350,
	4275,
	5285,
	6380,
	7560,
}

local function is_dummy_xp_table(xp_table)
	if #xp_table ~= #DUMMY_XP_TABLE then
		return false
	end

	for i = 1, #DUMMY_XP_TABLE do
		if tonumber(xp_table[i]) ~= DUMMY_XP_TABLE[i] then
			return false
		end
	end

	return true
end

function Identity:set_xp_table(xp_table, source)
	source = source or "backend"

	-- A less-trusted source never replaces a more-trusted curve; an equal
	-- source refreshes in place, which is how patch-day changes land.
	if self.xp_table and (XP_SOURCE_RANK[source] or 0) < (XP_SOURCE_RANK[self._xp_table_source] or 0) then
		return false
	end

	if type(xp_table) ~= "table" or #xp_table < 2 then
		if source ~= "disk" then
			self._xp_last_error = "response shape rejected (not an ascending numeric array)"
		end

		return false
	end

	local max_level = #xp_table
	local max_level_xp = tonumber(xp_table[max_level])
	local previous_level_xp = tonumber(xp_table[max_level - 1])

	if not max_level_xp or not previous_level_xp or max_level_xp <= previous_level_xp then
		if source ~= "disk" then
			self._xp_last_error = "response shape rejected (not an ascending numeric array)"
		end

		return false
	end

	if is_dummy_xp_table(xp_table) then
		if source ~= "disk" then
			self._xp_last_error = "rejected the offline-session placeholder curve"
		end

		return false
	end

	self.xp_table = xp_table
	self._xp_table_source = source
	self._xp_warned = false
	self._xp_last_error = nil

	if source ~= "disk" then
		self._xp_table_saved = false
		self:_save_xp_table()
	end

	local changed = false

	for character_id in pairs(self.progressions) do
		changed = self:_recalculate(character_id) or changed
	end

	if changed then
		mod._identity_revision = mod._identity_revision + 1
	end

	return true
end

-- Backend promises reject with a raw table as often as a string, and those
-- stringify to a useless "table: 0x...". Pull out the fields the backend
-- actually fills so both the warning and syn_diag.txt name the real failure
-- (an MS Store launch race reported itself as "Missing Xbox Live user" here,
-- and every bit of that was invisible before).
local function describe_error(err)
	if type(err) ~= "table" then
		return tostring(err)
	end

	local parts = {}

	for _, key in ipairs({ "header", "message", "description", "code", "status" }) do
		local value = err[key]

		if type(value) == "string" or type(value) == "number" then
			parts[#parts + 1] = tostring(value)
		end
	end

	return #parts > 0 and table.concat(parts, ": ") or tostring(err)
end

-- Failures whose text names a known startup race: the backend or the platform
-- account simply is not ready yet, and the next retry resolves it.
local function is_startup_race(text)
	return string.find(text, "NotInitialized", 1, true) ~= nil
		or string.find(text, "Missing Xbox Live user", 1, true) ~= nil
		or string.find(text, "not initialized", 1, true) ~= nil
end

local function live_progression_backend()
	local backend = Managers.backend
	local interfaces = backend and backend.interfaces

	return interfaces and interfaces.progression
end

function Identity:refresh_xp_table(force)
	local live_backend = live_progression_backend()

	-- DMF can enable while the backend manager exists but its interfaces are not
	-- ready yet. If that early request is still pending/backed off when character
	-- profiles arrive, abandon our reference to it and retry against the live
	-- interface used by the character-select view itself.
	if force and not self.xp_table then
		if self._xp_request and live_backend and self._xp_request_backend == live_backend then
			return
		end

		self._xp_backend = nil
		self._xp_request = nil
		self._xp_request_backend = nil
		self._xp_retry_delay = 0
	end

	-- A disk-cached or end-of-round curve keeps display working, but only the
	-- backend copy is authoritative; the live fetch continues until it lands.
	if (self.xp_table and self._xp_table_source == "backend") or self._xp_request or self._xp_retry_delay > 0 or not Managers.backend then
		return
	end

	self._xp_backend = live_backend or self._xp_backend or Progression:new()

	local ok, request = pcall(self._xp_backend.get_xp_table, self._xp_backend, "character")

	if not ok or not request then
		self._xp_retry_delay = 10
		self._xp_last_error = "request creation failed: " .. tostring(request)
		return
	end

	self._xp_request = request
	self._xp_request_backend = self._xp_backend

	request:next(function(xp_table)
		-- A backend-ready menu event may have superseded an earlier startup
		-- request. Its late completion must not overwrite the active request.
		if self._xp_request ~= request then
			return
		end

		self._xp_request = nil
		self._xp_request_backend = nil

		if not self:set_xp_table(xp_table) then
			self._xp_retry_delay = 30
		end
	end):catch(function(error)
		if self._xp_request ~= request then
			return
		end

		self._xp_request = nil
		self._xp_request_backend = nil
		self._xp_retry_delay = 30
		self._xp_last_error = describe_error(error)

		-- With a cached curve loaded this retry is silent housekeeping, and a
		-- startup race resolves itself on the next attempt. Neither is worth a
		-- chat warning; the diag file still carries _xp_last_error either way.
		if not self._xp_warned and not self.xp_table and not is_startup_race(self._xp_last_error) then
			self._xp_warned = true
			mod:warning("Could not fetch the character XP curve; total level will use vanilla level until retry: %s", self._xp_last_error)
		end
	end)
end

function Identity:refresh_progressions(force)
	local live_backend = live_progression_backend()

	if force then
		if self._progressions_request and live_backend and self._progressions_request_backend == live_backend then
			return
		end

		self._xp_backend = nil
		self._progressions_request = nil
		self._progressions_request_backend = nil
		self._progressions_loaded = false
		self._progressions_retry_delay = 0
	end

	if self._progressions_loaded or self._progressions_request or self._progressions_retry_delay > 0 or not Managers.backend then
		return
	end

	self._xp_backend = live_backend or self._xp_backend or Progression:new()

	local ok, request = pcall(self._xp_backend.get_entity_type_progression, self._xp_backend, "character")

	if not ok or not request then
		self._progressions_retry_delay = 10
		self._progressions_last_error = "request creation failed: " .. tostring(request)
		return
	end

	self._progressions_request = request
	self._progressions_request_backend = self._xp_backend

	request:next(function(progressions)
		if self._progressions_request ~= request then
			return
		end

		self._progressions_request = nil
		self._progressions_request_backend = nil

		if type(progressions) ~= "table" then
			self._progressions_retry_delay = 30
			self._progressions_last_error = "response was not a table"
			return
		end

		self._progressions_loaded = true
		self._progressions_warned = false
		self._progressions_last_error = nil

		for _, progression in pairs(progressions) do
			if type(progression) == "table" then
				self:capture_progression(progression.id, progression)
			end
		end
	end):catch(function(error)
		if self._progressions_request ~= request then
			return
		end

		self._progressions_request = nil
		self._progressions_request_backend = nil
		self._progressions_retry_delay = 30
		self._progressions_last_error = describe_error(error)
		self._progressions_failures = (self._progressions_failures or 0) + 1

		-- Same silence rule as the curve fetch, plus one attempt of grace: the
		-- first fetch routinely loses a race with backend or platform login
		-- (MS Store installs report "Missing Xbox Live user" here), and the
		-- retry 30 seconds later succeeds. Only a repeat failure is news.
		if not self._progressions_warned and self._progressions_failures > 1
			and not is_startup_race(self._progressions_last_error) then
			self._progressions_warned = true
			mod:warning("Could not fetch character progressions; total level will use vanilla level until retry: %s", self._progressions_last_error)
		end
	end)
end

function Identity:update(dt)
	if self._xp_retry_delay > 0 then
		self._xp_retry_delay = math.max(self._xp_retry_delay - dt, 0)
	end

	if (not self.xp_table or self._xp_table_source ~= "backend") and not self._xp_request and self._xp_retry_delay == 0 then
		self:refresh_xp_table()
	end

	if self._progressions_retry_delay > 0 then
		self._progressions_retry_delay = math.max(self._progressions_retry_delay - dt, 0)
	end

	if not self._progressions_loaded and not self._progressions_request and self._progressions_retry_delay == 0 then
		self:refresh_progressions()
	end
end

function Identity:capture_progression(character_id, progression)
	character_id = character_id or progression and progression.id

	if not character_id or type(progression) ~= "table" then
		return
	end

	-- currentXp is what lets us compute the true level past 30, and for other
	-- players it is only present on the profile the presence entry parses. A
	-- mid-mission profile sync can re-enter this with a progression that carries
	-- only the capped currentLevel; keep the richer stored record instead of
	-- letting that clobber it and snap the player back to 30.
	local existing = self.progressions[character_id]

	if existing and tonumber(existing.currentXp) and not tonumber(progression.currentXp) then
		return
	end

	self.progressions[character_id] = progression

	if self:_recalculate(character_id) then
		mod._identity_revision = mod._identity_revision + 1
	end

	self:refresh_xp_table()
end

-- End-of-mission session stats, captured raw from the progression manager
-- before vanilla clamps them to the level cap. This is what lets the end
-- screen's own XP bar keep filling past 30.
function Identity:capture_session_stats(stats)
	local start_xp = stats and tonumber(stats.startXp)
	local current_xp = stats and tonumber(stats.currentXp)

	if not start_xp or not current_xp then
		return
	end

	self.session_xp = {
		start_xp = start_xp,
		current_xp = current_xp,
		at = current_time(),
	}
end

function Identity:session_stats()
	local stash = self.session_xp

	if not stash then
		return nil
	end

	-- A stash left over from a much earlier mission could disagree with the
	-- report being presented; the end screen appears within minutes of parsing.
	if current_time() - (stash.at or 0) > 1800 then
		return nil
	end

	return stash
end

-- Recasts the end screen's experience-bar state into true-level space: the
-- vanilla curve up to the cap, then the 29->30 span repeating, exactly like
-- level_from_progression counts. Thresholds are shifted so the bar's XP text
-- counts within the current level ("8,450 / 11,100") instead of printing
-- seven-digit cumulative totals that would overflow the widget.
-- Returns nil whenever the inputs cannot support a bar past the cap; the
-- caller then leaves vanilla's clamped presentation alone.
function Identity:xp_bar_state(experience_table, max_level, start_xp, current_xp)
	max_level = tonumber(max_level)
	start_xp = tonumber(start_xp)
	current_xp = tonumber(current_xp)

	if type(experience_table) ~= "table" or not max_level or max_level < 2 or not start_xp then
		return nil
	end

	local cap_xp = tonumber(experience_table[max_level])
	local previous_xp = tonumber(experience_table[max_level - 1])

	if not cap_xp or not previous_xp or cap_xp <= previous_xp or start_xp < cap_xp then
		return nil
	end

	local span = cap_xp - previous_xp

	current_xp = math.max(current_xp or start_xp, start_xp)

	local start_level = max_level + math.floor((start_xp - cap_xp) / span)
	local end_level = max_level + math.floor((current_xp - cap_xp) / span)
	local top_level = end_level + 2
	local offset = cap_xp + (start_level - max_level) * span
	local extended = {}

	for i = 1, top_level do
		local threshold

		if i <= max_level then
			threshold = tonumber(experience_table[i]) or cap_xp
		else
			threshold = cap_xp + (i - max_level) * span
		end

		extended[i] = threshold - offset
	end

	return {
		experience_table = extended,
		max_level = top_level,
		max_level_experience = extended[top_level],
		current_level = start_level,
		starting_experience = start_xp - offset,
		experience_for_current_level = extended[start_level],
		experience_for_next_level = extended[start_level + 1],
	}
end

-- Resolving a kit walks every node in the archetype's talent layout, which is
-- far too expensive to repeat per frame for four players. Results are cached
-- against the profile table itself (weak keys, so a replaced profile is
-- collectable) and re-derived on a slow timer to pick up builds edited in place.
local KIT_CACHE = setmetatable({}, { __mode = "k" })
local KIT_TTL = 30

local function localize_key(key)
	local localizer = rawget(_G, "Localize")

	if type(key) ~= "string" or key == "" or type(localizer) ~= "function" then
		return nil
	end

	local ok, text = pcall(localizer, key)

	return ok and nonempty(text) or nil
end

-- Talent names are never truncated: an ability whose name is cut in half tells
-- you less than nothing. Surfaces that can overflow scale their text down to
-- fit instead, which is what fit_widget_line does for every card row.
local function kit_label(entry)
	local talent = type(entry) == "table" and entry.talent
	local text = talent and localize_key(talent.display_name)

	if not text then
		return nil
	end

	return nonempty((text:gsub("[%c]", " "):gsub("{", "["):gsub("}", "]")))
end

function Identity:_kit(profile)
	if not CharacterSheet or type(profile) ~= "table" then
		return nil
	end

	local archetype = profile.archetype
	local talents = profile.talents

	-- The archetype table (not the bare name string) and at least one selected
	-- talent are both required. Without talents, class_loadout would resolve the
	-- archetype's level-one defaults and confidently report a build the player
	-- is not running.
	if type(archetype) ~= "table" or type(talents) ~= "table" or next(talents) == nil then
		return nil
	end

	local cached = KIT_CACHE[profile]

	if cached and current_time() - cached.at < KIT_TTL then
		return cached.kit
	end

	local destination = { ability = {}, blitz = {}, aura = {} }
	local ok = pcall(CharacterSheet.class_loadout, profile, destination, nil, talents, true)
	local kit

	if ok then
		local archetype_icons = UISettings and UISettings.archetype_font_icon

		kit = {
			ability = kit_label(destination.ability),
			blitz = kit_label(destination.blitz),
			aura = kit_label(destination.aura),
			class_name = localize_key(archetype.archetype_name),
			class_icon = archetype.name and archetype_icons and archetype_icons[archetype.name] or nil,
		}

		if not kit.ability and not kit.blitz and not kit.aura then
			kit = nil
		end
	end

	KIT_CACHE[profile] = { at = current_time(), kit = kit }

	return kit
end

function Identity:kit_enabled(surface)
	-- A per-surface override wins outright, in both directions: a surface can
	-- opt out of the kit even when it is on globally, or opt in even when the
	-- Kit Locations scope would have excluded it.
	local override = self:_surface_get(surface, "kit")

	if override ~= nil then
		return override == "on" and mod:get("show_kit") == true
	end

	if mod:get("show_kit") ~= true then
		return false
	end

	local scope = mod:get("kit_surfaces") or "all"

	if scope == "all" or not surface then
		return true
	end

	local in_mission = MISSION_SURFACES[surface] == true

	return scope == "mission" and in_mission or scope == "menus" and not in_mission
end

-- The class prefix. On surfaces that carry vanilla's own archetype row the
-- class is already named there, so callers pass omit_class and only the
-- selected abilities are appended.
function Identity:_kit_class_prefix(kit, omit_class)
	local mode = mod:get("kit_class_name") or "auto"

	if omit_class or mode == "never" then
		return nil
	end

	-- The archetype insignia lives in the same Fatshark PUA block as the level
	-- and Havoc insignia, so glyph verification's verdict on those is the
	-- verdict on this one. If PUA cannot be proven to render in the live font,
	-- fall back to the class name rather than gambling on a .notdef box.
	local pua_renders = self.glyphs.level_icon and self.glyphs.havoc_icon
	local icon = mod:get("use_game_icons") ~= false and pua_renders and kit.class_icon or nil

	if mode == "always" then
		-- Vanilla's own archetype format: icon then name.
		if icon and kit.class_name then
			return icon .. " " .. kit.class_name
		end

		return kit.class_name or icon
	end

	-- auto: the class insignia alone is unambiguous to anyone who plays the
	-- game and costs one character, so it is preferred over spelling the class
	-- out on the surfaces that have no archetype row of their own.
	return icon or kit.class_name
end

function Identity:_kit_text(record, style, colors_enabled, options)
	options = options or {}

	local kit = self:_kit(record and record.profile)

	if not kit then
		return nil
	end

	-- Holding the expand key always reveals the complete kit.
	local detail = options.expanded and "ability_blitz_aura" or mod:get("kit_detail") or "ability"
	local parts = {}
	local prefix = self:_kit_class_prefix(kit, options.omit_class)

	if prefix then
		parts[#parts + 1] = prefix
	end

	if kit.ability then
		parts[#parts + 1] = kit.ability
	end

	if detail ~= "ability" and kit.blitz then
		parts[#parts + 1] = kit.blitz
	end

	if detail == "ability_blitz_aura" and kit.aura then
		parts[#parts + 1] = kit.aura
	end

	if #parts == 0 then
		return nil
	end

	local separator = self:_progression_separator(style)
	local color = self:_custom_color("kit", COLORS.steel)

	return color_markup(table.concat(parts, " " .. separator .. " "), color, colors_enabled)
end

-- Join a composed line to its kit using the same separator the progression
-- values use, so an identity row reads as one continuous dataslate line.
function Identity:_append_kit(text, kit_text, style, colors_enabled, record)
	if not kit_text then
		return text
	end

	if not text then
		return kit_text
	end

	local separator = self:_progression_separator(style)

	return text .. color_markup(" " .. separator .. " ", self:_accent(record), colors_enabled) .. kit_text
end

-- Replacement text for vanilla's archetype row on the surfaces that have one:
-- "Veteran - Executioner's Stance". Rebuilt from the profile every call rather
-- than from the widget's current text, so repeated refreshes cannot stack
-- suffixes. Returns nil when vanilla's own row should be left untouched.
function Identity:archetype_row(record, surface, colors_enabled)
	if not ARCHETYPE_ROW_SURFACES[surface] or not self:kit_enabled(surface) then
		return nil
	end

	local style = mod:get("presentation_style") or "aquila"
	local kit_text = self:_kit_text(record, style, colors_enabled, {
		expanded = mod.identity_expanded(),
		omit_class = true,
		surface = surface,
	})

	if not kit_text then
		return nil
	end

	local profile = record and record.profile
	local ok, base = pcall(function()
		return ProfileUtils and profile and ProfileUtils.character_archetype_title(profile) or nil
	end)

	base = ok and nonempty(base) or nil

	if not base then
		return kit_text
	end

	local separator = self:_progression_separator(style)

	return base .. color_markup(" " .. separator .. " ", self:_accent(record), colors_enabled) .. kit_text
end

function Identity:surface_enabled(surface)
	local config = SURFACE_SETTINGS[surface] or SURFACE_SETTINGS.team_hud

	return mod:get(config.enabled) ~= false
end

function Identity:surface_progression(surface)
	local config = SURFACE_SETTINGS[surface] or SURFACE_SETTINGS.team_hud

	return mod:get(config.progression) ~= false
end

-- Per-surface overrides. Every content setting can be answered globally (the
-- setting in the main groups) or overridden for one surface, so a player can run
-- e.g. bare character names over teammates' heads while the team HUD still shows
-- account names, level and Havoc. Each override defaults to "inherit", which
-- means the whole system is inert until someone deliberately changes a surface —
-- an important property, because it guarantees no upgrade changes anyone's
-- display.
--
-- _surface_get returns nil for "inherit" (and for an unknown surface), so every
-- caller reads `local v = self:_surface_get(surface, key); if v == nil then <the
-- global> end`.
function Identity:_surface_get(surface, key)
	local config = surface and SURFACE_SETTINGS[surface]

	if not config then
		return nil
	end

	local value = mod:get(config.prefix .. "_" .. key)

	if value == nil or value == "inherit" then
		return nil
	end

	return value
end

-- Tri-state on/off override -> boolean, falling back to a global setting that is
-- "on unless explicitly false" (the convention every content toggle here uses).
function Identity:_surface_flag(surface, key, global_key)
	local override = self:_surface_get(surface, key)

	if override ~= nil then
		return override == "on" or override == true
	end

	return mod:get(global_key) ~= false
end

function Identity:local_account_id()
	return local_account_id()
end

function Identity:verify_glyphs(ui_renderer)
	if self._glyphs_verified or not ui_renderer or not rawget(_G, "UIRenderer") then
		return
	end

	local function measure(text)
		local ok, width, height = pcall(UIRenderer.text_size, ui_renderer, text, "proxima_nova_bold", 18)

		if ok and tonumber(width) and tonumber(height) then
			return width, height
		end

		return nil
	end

	local present_width = measure("A")

	if not present_width or present_width <= 0 then
		-- The renderer cannot measure at all; keep the safe defaults and try
		-- again with the next renderer that comes along.
		return
	end

	-- Missing-glyph baselines. Slug either drops an unmapped character (zero
	-- width) or draws the fixed .notdef box; both shipped verifiers before this
	-- one guessed wrong about which, so measure BOTH behaviors: U+FFFF (a
	-- noncharacter, engines often skip it outright) and U+F6FF (private-use far
	-- outside Fatshark's E0xx range, so it draws the box if anything does).
	local box_widths = {}

	for _, sentinel in ipairs({ "\239\191\191", "\239\155\191" }) do
		local width = measure(sentinel)

		if width and width > 0 and math.abs(width - present_width) >= 0.5 then
			box_widths[#box_widths + 1] = width
		end
	end

	-- Without at least one usable box baseline, a measured width proves
	-- nothing (the ✦ box measured "fine" twice); only proven literals pass.
	local can_detect = #box_widths > 0

	local function renders(glyph)
		if is_proven(glyph) then
			return true
		end

		if not can_detect then
			return false
		end

		local width, height = measure(glyph)

		if not width or width <= 0 or not height or height <= 0 then
			return false
		end

		for i = 1, #box_widths do
			if math.abs(width - box_widths[i]) < 0.5 then
				return false
			end
		end

		return true
	end

	for key, chain in pairs(GLYPH_CHAINS) do
		local matched = false

		for i = 1, #chain do
			if renders(chain[i]) then
				self.glyphs[key] = chain[i]
				matched = true
				break
			end
		end

		if not matched then
			-- Icon chains have no safe tail: false switches those values to
			-- their text labels. Text chains keep the safe default instead.
			if not is_proven(chain[#chain]) then
				self.glyphs[key] = false
			end
		end
	end

	self._glyphs_verified = true
end

-- The highest-rank order in the player's own order list; this is exactly what
-- the Havoc terminal's "key" state offers to launch as host.
local function best_order_rank(orders)
	if type(orders) ~= "table" then
		return nil
	end

	local best

	for i = 1, #orders do
		local order = orders[i]
		local rank = type(order) == "table" and type(order.data) == "table" and tonumber(order.data.rank)

		if rank and (not best or best < rank) then
			best = rank
		end
	end

	return best
end

function Identity:_resolve_havoc(cache, value, ttl)
	if cache.value ~= value then
		cache.value = value
		mod._identity_revision = mod._identity_revision + 1
	end

	cache.expires_at = current_time() + ttl
	cache.retry_at = nil
	cache.last_error = nil
end

function Identity:_request_launchable_havoc(account_id, is_local)
	if type(account_id) ~= "string" or not account_id:match("^[%x%-]+$") or not Managers.backend then
		return
	end

	local now = current_time()
	local cache = self.havoc_assignments[account_id]

	if cache and (cache.request or now < (cache.expires_at or 0) or now < (cache.retry_at or 0)) then
		return
	end

	cache = cache or {}
	self.havoc_assignments[account_id] = cache

	-- The local player's launchable rank comes from the orders backend — the
	-- same source the Havoc table itself reads before offering the "key" —
	-- with the summary's held order as the fallback. Other accounts only
	-- expose the summary endpoint.
	local havoc_service = is_local and Managers.data_service and Managers.data_service.havoc

	if havoc_service and type(havoc_service.available_orders) == "function" then
		local ok, request = pcall(havoc_service.available_orders, havoc_service)

		if ok and request and type(request.next) == "function" then
			cache.request = request

			request:next(function(orders)
				cache.request = nil

				local rank = best_order_rank(orders)

				if rank then
					self:_resolve_havoc(cache, rank, 180)
				else
					self:_request_summary_rank(account_id, cache)
				end
			end):catch(function()
				cache.request = nil
				self:_request_summary_rank(account_id, cache)
			end)

			return
		end
	end

	self:_request_summary_rank(account_id, cache)
end

function Identity:_request_summary_rank(account_id, cache)
	local ok, request = pcall(Managers.backend.title_request, Managers.backend, "/data/" .. account_id .. "/havoc/summary")

	if not ok or not request or type(request.next) ~= "function" then
		cache.retry_at = current_time() + 30
		return
	end

	cache.request = request

	request:next(function(data)
		cache.request = nil

		-- Tolerate both response shapes title_request has been seen returning:
		-- a wrapper with .body and the parsed body directly.
		local body = type(data) == "table" and (type(data.body) == "table" and data.body or data) or nil

		-- summary.currentOrder is the order the account holds right now —
		-- what their Havoc terminal offers to launch as host. highestRank is
		-- the all-time peak, NOT the current rank; displaying the peak as
		-- "current" is exactly the drift players reported once their held
		-- order sat below it.
		local order = body and (type(body.currentOrder) == "table" and body.currentOrder
			or type(body.current_order) == "table" and body.current_order
			or nil)
		local rank = order and tonumber(order.rank)

		if rank then
			self:_resolve_havoc(cache, rank, 180)
		elseif body then
			-- A well-formed summary without a current order means the account
			-- holds no Havoc order at all (never unlocked Havoc, or nothing
			-- held this cadence) — an answer, not a failure. Cache the
			-- absence (longer TTL; it rarely changes) so the account is not
			-- re-polled every 30 seconds forever.
			self:_resolve_havoc(cache, false, 600)
		else
			cache.retry_at = current_time() + 30
			cache.last_error = "response carried no parseable summary"
		end
	end):catch(function(error)
		cache.request = nil
		cache.retry_at = current_time() + 30
		cache.last_error = tostring(error)
	end)
end

-- Diagnostic: one line per requested account showing whether the Havoc
-- summary resolved, is backing off, or failed — and why. The ~ estimates on
-- screen persist exactly when this reports a failure.
function Identity:havoc_report()
	local lines = {}

	for account_id, cache in pairs(self.havoc_assignments) do
		local state

		if cache.value then
			state = string.format("rank %d (exact)", cache.value)
		elseif cache.value == false then
			state = "no Havoc order held (exact)"
		elseif cache.request then
			state = "request in flight"
		elseif cache.retry_at then
			state = string.format("backing off (retry in %ds)", math.max(math.ceil(cache.retry_at - current_time()), 0))
		else
			state = "not requested yet"
		end

		if cache.last_error then
			state = state .. " | last error: " .. cache.last_error
		end

		lines[#lines + 1] = string.format("%s: %s", tostring(account_id):sub(1, 12), state)
	end

	if #lines == 0 then
		return "No Havoc summary requests made yet."
	end

	table.sort(lines)

	return table.concat(lines, "\n")
end

function Identity:glyph_report()
	local lines = { string.format("verified: %s", tostring(self._glyphs_verified)) }
	local keys = {}

	for key in pairs(self.glyphs) do
		keys[#keys + 1] = key
	end

	table.sort(keys)

	for _, key in ipairs(keys) do
		local value = self.glyphs[key]

		if value == false then
			value = "(text label fallback)"
		elseif value == "" then
			value = "(none)"
		end

		lines[#lines + 1] = string.format("%s = %s", key, tostring(value))
	end

	return table.concat(lines, "\n")
end

function Identity:record(account_id, profile, character_name, player_info, slot_color, slot)
	local presence = presence_for(account_id)
	local presence_profile = safe_call(presence, "character_profile")

	profile = profile or safe_call(player_info, "profile") or presence_profile
	character_name = clean_name(character_name)
		or clean_name(safe_call(player_info, "character_name"))
		or clean_name(profile and profile.name)
		or clean_name(safe_call(presence, "character_name"))

	local is_local = account_id == local_account_id()
	local platform = nonempty(safe_call(player_info, "platform"))
		or nonempty(safe_call(presence, "platform"))
		or (is_local and rawget(_G, "AUTH_PLATFORM")) or nil

	-- player_info:platform() hands back the literal "Unknown" until the platform
	-- resolves; treat that as no platform so the icon uses the cross-network
	-- glyph rather than keying a lookup on a bogus value.
	if platform == "Unknown" then
		platform = nil
	end

	local platform_user_id = safe_call(player_info, "platform_user_id")

	-- Resolve the account/persona name through the chain vanilla uses for its own
	-- social UI. The presence persona/account name covers most players, but a
	-- fresh presence entry is often still empty for teammates; player_info's
	-- user_display_name adds the platform-social and cached-account fallbacks that
	-- the presence entry alone misses. That gap is why so many players rendered
	-- with no account name at all. no_platform_icon = true keeps the bare name so
	-- we can attach our own icon; "N/A" is filtered by clean_name.
	local account_name = clean_name(safe_call(presence, "platform_persona_name_or_account_name", platform, platform_user_id))
		or clean_name(safe_call(presence, "account_name"))
		or clean_name(safe_call(player_info, "user_display_name", true, true))

	if not account_name and is_local then
		account_name = clean_name(safe_call(Managers.account, "user_display_name"))
	end

	local character_id = profile and profile.character_id or presence_profile and presence_profile.character_id
	local true_level = character_id and self.true_levels[character_id]
	local current_level = tonumber(profile and profile.current_level)
		or tonumber(presence_profile and presence_profile.current_level)
	local weekly_havoc = tonumber(safe_call(presence, "havoc_rank_cadence_high"))
	local all_time_havoc = tonumber(safe_call(presence, "havoc_rank_all_time_high"))

	self:_request_launchable_havoc(account_id, is_local)

	local launchable = account_id and self.havoc_assignments[account_id]

	slot_color = color_selection_color(account_id, slot) or slot_color

	return {
		account_id = account_id,
		account_name = account_name,
		all_time_havoc = all_time_havoc,
		character_id = character_id,
		character_name = character_name,
		launchable_havoc = launchable and launchable.value,
		platform = platform,
		prestige = character_id and self:_prestige(character_id) or nil,
		profile = profile,
		slot_color = color_from_slot(slot_color),
		true_level = true_level or current_level,
		weekly_havoc = weekly_havoc,
	}
end

-- Per-frame surfaces (team HUD, nameplates, spectator banner) ask for the same
-- identity sixty times a second, and rebuilding it each time is what made this
-- mod cost frames: every rebuild runs a full record() — a dozen guarded manager
-- calls plus dozens of setting lookups — then builds the string again, for
-- every player, on every surface, on the render path.
--
-- One policy for all of it: a result stays valid while the identity revision is
-- unchanged and the entry is younger than COMPOSE_TTL. The revision covers
-- everything the mod knows changed (settings, progression, Havoc, colors); the
-- timer covers what arrives asynchronously without announcing itself (presence
-- names resolving). A third of a second is imperceptible for name text and cuts
-- the work by a factor of ~20.
local COMPOSE_TTL = 0.35
local compose_cache = setmetatable({}, { __mode = "k" })

function Identity:cache_valid(entry)
	return entry ~= nil
		and entry.revision == mod._identity_revision
		and current_time() - entry.at < COMPOSE_TTL
end

function Identity:cache_stamp(entry)
	entry.revision = mod._identity_revision
	entry.at = current_time()

	return entry
end

-- Cached record + composed text for a live player. Callers on per-frame paths
-- must still write the result to their widget every frame, because vanilla
-- rewrites those fields asynchronously; writing a cached string is a compare,
-- not a rebuild.
function Identity:compose_player_cached(player, surface)
	if not player then
		return nil, nil
	end

	local by_surface = compose_cache[player]

	if not by_surface then
		by_surface = {}
		compose_cache[player] = by_surface
	end

	local entry = by_surface[surface]

	if self:cache_valid(entry) then
		return entry.text, entry.record
	end

	if not entry then
		entry = {}
		by_surface[surface] = entry
	end

	entry.record = self:record_player(player)
	entry.text = self:compose(entry.record, surface)

	self:cache_stamp(entry)

	return entry.text, entry.record
end

function Identity:record_player(player)
	if not player or player.__deleted or safe_call(player, "is_human_controlled") == false then
		return nil
	end

	local account_id = safe_call(player, "account_id")
	local profile = safe_call(player, "profile")
	local character_name = safe_call(player, "name")
	local player_info = player_info_for(account_id)
	local slot = safe_call(player, "slot")
	local slot_color = slot and UISettings.player_slot_colors[slot]

	return self:record(account_id, profile, character_name, player_info, slot_color, slot)
end

function Identity:record_player_info(player_info, profile)
	if not player_info then
		return nil
	end

	local account_id = safe_call(player_info, "account_id")
	local slot = safe_call(player_info, "slot")
	local slot_color = slot and UISettings.player_slot_colors[slot]

	return self:record(account_id, profile, safe_call(player_info, "character_name"), player_info, slot_color, slot)
end

function Identity:record_local_profile(profile)
	return self:record(local_account_id(), profile, profile and profile.name, nil, nil)
end

-- U+E06F, the glyph vanilla presence returns for any other/unknown platform.
local CROSS_NETWORK_ICON = "\238\129\175"

local function platform_icon(record)
	if mod:get("show_platform_icon") == false then
		return nil
	end

	local specific = PLATFORM_ICONS[record.platform]

	if specific then
		return specific
	end

	-- Restricted local accounts must defer to vanilla's privacy-safe presence
	-- icon, which already collapses hidden platforms to the cross-network glyph.
	local restricted = safe_call(Managers.account, "user_has_restriction")

	if restricted and record.account_id ~= local_account_id() then
		local presence = presence_for(record.account_id)

		return nonempty(safe_call(presence, "platform_icon", record.platform)) or CROSS_NETWORK_ICON
	end

	-- Unknown or still-loading platform: show the cross-network glyph so every
	-- player carries a platform marker instead of silently dropping it.
	return CROSS_NETWORK_ICON
end

-- Which color-override key a record's platform maps to, or nil for platforms
-- with no dedicated override (unknown/cross-network stays on the accent).
local PLATFORM_COLOR_KEY = {
	steam = "steam",
	xbox = "xbox",
	psn = "psn",
	ps5 = "psn",
	ps4 = "psn",
}

-- The platform icon's color. Defaults to the accent (unchanged behaviour); a
-- per-platform override, when enabled, tints Steam/Xbox/PlayStation icons
-- independently so a mixed lobby is readable at a glance.
function Identity:_platform_color(record, accent)
	local key = record and record.platform and PLATFORM_COLOR_KEY[record.platform]

	if key and mod:get(key .. "_color_override") == true then
		return self:_custom_color(key, accent)
	end

	return accent
end

function Identity:_accent(record)
	-- "Whole line" scope: the Color Selection pick becomes this operative's
	-- accent, which carries it to the separators, platform icon, and any tracker
	-- whose own tint is switched off — so the entire entry reads as one colour.
	local cs_color = self:_color_selection_color(record)

	if cs_color and self:_color_selection_covers("line") then
		return cs_color
	end

	local theme = mod:get("accent_theme") or "imperial_gold"

	if theme == "custom" then
		return {
			tonumber(mod:get("accent_custom_r")) or 230,
			tonumber(mod:get("accent_custom_g")) or 190,
			tonumber(mod:get("accent_custom_b")) or 90,
		}
	elseif theme == "player_slot" then
		return record.slot_color or COLORS.gold
	end

	return ACCENTS[theme] or COLORS.gold
end

function Identity:_custom_color(prefix, fallback)
	if mod:get(prefix .. "_color_override") ~= true then
		return fallback
	end

	local defaults = CUSTOM_COLOR_DEFAULTS[prefix] or fallback or COLORS.bone
	local function channel(suffix, default)
		local value = tonumber(mod:get(prefix .. "_color_" .. suffix)) or default

		return math.floor(math.max(0, math.min(value, 255)) + 0.5)
	end

	return {
		channel("r", defaults[1]),
		channel("g", defaults[2]),
		channel("b", defaults[3]),
	}
end

function Identity:_account_visible(record)
	local account_id = record and record.account_id

	return not (account_id and account_id == local_account_id() and mod:get("show_own_account_name") == false)
end

function Identity:_level_color(level, accent)
	local color

	if mod:get("level_tier_colors") == false then
		color = accent
	elseif level >= 1000 then
		color = COLORS.red
	elseif level >= 750 then
		color = COLORS.orange
	elseif level >= 500 then
		color = COLORS.purple
	elseif level >= 250 then
		color = COLORS.blue
	elseif level >= 100 then
		color = COLORS.green
	elseif level >= 30 then
		color = COLORS.bone
	else
		color = COLORS.account_dim
	end

	return self:_custom_color("level", color)
end

function Identity:_havoc_color(rank, accent)
	local color

	if mod:get("havoc_heat_colors") == false then
		color = accent
	elseif rank >= 40 then
		color = { 255, 55, 52 }
	elseif rank >= 35 then
		color = COLORS.red
	elseif rank >= 26 then
		color = COLORS.orange
	elseif rank >= 16 then
		color = COLORS.gold
	else
		color = COLORS.steel
	end

	return self:_custom_color("havoc", color)
end

function Identity:_winrate_color(winrate, accent)
	local color

	if mod:get("winrate_tint") == false or winrate == nil then
		color = accent
	elseif winrate >= 60 then
		color = COLORS.green
	elseif winrate >= 45 then
		color = COLORS.bone
	else
		color = COLORS.red
	end

	return self:_custom_color("history", color)
end

function Identity:_separator(style)
	local override = mod:get("separator_glyph") or "auto"
	local middot = "\194\183"
	local first_drop = self.glyphs.first_drop
	local overrides = {
		star = self.glyphs.ornament,
		diamond = first_drop and first_drop ~= "" and first_drop or middot,
		dot = middot,
		pipe = "|",
		dash = "—",
	}

	if override ~= "auto" then
		local chosen = overrides[override]

		return chosen and chosen ~= "" and chosen or middot
	elseif style == "aquila" then
		return self.glyphs.ornament
	elseif style == "cogitator" then
		return "::"
	elseif style == "litany" then
		return self.glyphs.devotional
	elseif style == "registry" or style == "rail" then
		return "|"
	elseif style == "dossier" then
		return "//"
	end

	return "·"
end

function Identity:_progression_separator(style)
	if (mod:get("separator_glyph") or "auto") == "auto" and style == "aquila" then
		return "·"
	end

	return self:_separator(style)
end

function Identity:_identity_text(record, style, expanded, colors_enabled, options)
	options = options or {}

	local surface = options.surface
	local character_name = record.character_name
	local account_visible = self:_account_visible(record)
	local account_name = account_visible and record.account_name or nil
	local icon

	-- options.show_platform_icon is an internal per-call decision (compose_split
	-- places the icon on exactly one of its two rows); the per-surface override
	-- is the user-facing one and can only take the icon away, never force it onto
	-- a row that was not meant to carry it.
	if account_visible and options.show_platform_icon ~= false
		and self:_surface_flag(surface, "platform_icon", "show_platform_icon") then
		icon = platform_icon(record)
	end

	local name_style = options.name_style
		or expanded and "character_account"
		or self:_surface_get(surface, "name_style")
		or mod:get("name_style")
		or "character_account"
	local accent = self:_accent(record)

	if mod:get("deduplicate_names") ~= false and character_name and account_name and normalized(character_name) == normalized(account_name) then
		account_name = nil
	end

	-- The character-only style never renders the account, so drop it before the
	-- icon is placed below; that lets the icon fall onto the character name
	-- instead of being stranded on a name that is never shown.
	if name_style == "character" then
		account_name = nil
	end

	local cs_color = self:_color_selection_color(record)
	local dim = not expanded and mod:get("dim_account_name") ~= false
	local account_default

	if cs_color and self:_color_selection_covers("account") then
		-- Same hue as the character name so one operative reads as one colour.
		-- Dimming only lowers brightness (0.62 is the stock account_dim/bone
		-- ratio), it never changes the hue.
		account_default = dim and scale_color(cs_color, 0.62) or cs_color
	else
		account_default = dim and COLORS.account_dim or COLORS.bone
	end

	local account_color = self:_custom_color("account", account_default)
	local character_color = self:_custom_color("character", cs_color or COLORS.character)
	local character = color_markup(character_name, character_color, colors_enabled)
	local account = color_markup(account_name, account_color, colors_enabled)
	local icon_text = icon and color_markup(icon, self:_platform_color(record, accent), colors_enabled)

	-- Keep the platform icon with the account identity when present, otherwise
	-- fall it back onto the character name so it never disappears for players
	-- whose account name has not resolved (or who are shown character-only).
	if icon_text then
		if account then
			account = icon_text .. " " .. account
		elseif character then
			character = icon_text .. " " .. character
		end
	end

	local function join(first, second, reversed)
		if not first or not second then
			return first or second
		end

		if style == "aquila" then
			return first .. color_markup(" " .. self.glyphs.emdash .. " ", accent, colors_enabled) .. second
		elseif style == "litany" then
			return first .. color_markup(" · ", accent, colors_enabled) .. second
		elseif style == "registry" then
			return first .. color_markup(" // ", accent, colors_enabled) .. second
		end

		return first .. color_markup(" (", accent, colors_enabled) .. second .. color_markup(")", accent, colors_enabled)
	end

	local text

	if name_style == "account" then
		if options.strict_name_style then
			text = account
		else
			text = account or character
		end
	elseif name_style == "account_character" then
		text = join(account, character, true)
	elseif name_style == "character" then
		if options.strict_name_style then
			text = character
		else
			text = character or account
		end
	else
		text = join(character, account)
	end

	if not text and options.allow_missing then
		return nil
	end

	text = text or mod:localize("unknown_player")

	if style == "litany" then
		text = color_markup(self.glyphs.devotional .. " ", accent, colors_enabled) .. text
	end

	return text
end

-- The tracker insignia are all Fatshark PUA. The level and Havoc glyphs are the
-- mod's own verified insignia (false when the font could not render them); the
-- archetype icons are read live from the table vanilla itself draws every frame,
-- so they are gated on the verified insignia as proof that PUA renders on this
-- font at all. Nothing here can resolve to a speculative codepoint, and emoji
-- are deliberately unreachable — the whole feature degrades to a text label,
-- never a box.
Identity.ARCHETYPE_ICON_KEYS = {
	"veteran", "zealot", "psyker", "ogryn", "adamant", "broker", "cryptic",
}

local ARCHETYPE_ICON_SET = {}
for _, key in ipairs(Identity.ARCHETYPE_ICON_KEYS) do
	ARCHETYPE_ICON_SET[key] = true
end

function Identity:_pua_renders()
	return (self.glyphs.level_icon and self.glyphs.havoc_icon) and true or false
end

function Identity:_choice_glyph(choice)
	if choice == "level" then
		return self.glyphs.level_icon or nil
	elseif choice == "havoc" then
		return self.glyphs.havoc_icon or nil
	elseif ARCHETYPE_ICON_SET[choice] then
		if not self:_pua_renders() then
			return nil
		end

		local icons = UISettings and UISettings.archetype_font_icon

		return icons and nonempty(icons[choice]) or nil
	elseif EXTRA_ICONS[choice] then
		-- Same gate as the archetype icons: the mod's own verified insignia are
		-- the proof that this font renders the Fatshark PUA block at all. Worst
		-- case is a text label, never a box.
		return self:_pua_renders() and EXTRA_ICONS[choice] or nil
	elseif CURRENCY_ICON_KEYS[choice] then
		if not self:_pua_renders() then
			return nil
		end

		local wallet = WalletSettings and WalletSettings[CURRENCY_ICON_KEYS[choice]]

		return wallet and nonempty(wallet.string_symbol) or nil
	end

	return nil
end

-- The insignia for a tracker, honouring the master Game Icons toggle, the
-- aquila/litany style gate, and the per-tracker icon choice. "default" keeps the
-- historic behaviour (level and Havoc wear their own insignia; prestige borrows
-- the level insignia). Legacy styles keep their text labels by design.
local ICON_DEFAULT_CHOICE = {
	level_icon = "level",
	havoc_icon = "havoc",
	prestige_icon = "level",
}

function Identity:_game_icon(key, style)
	if mod:get("use_game_icons") == false then
		return nil
	end

	if key == "level_icon" and mod:get("show_level_label") == false then
		return nil
	end

	if style ~= "aquila" and style ~= "litany" then
		return nil
	end

	local default_choice = ICON_DEFAULT_CHOICE[key]

	if not default_choice then
		return self.glyphs[key] or nil
	end

	local choice = mod:get(key) or "default"

	if choice == "none" then
		return nil
	end

	if choice == "default" then
		choice = default_choice
	end

	return self:_choice_glyph(choice)
end

-- The number a level tracker prints. "total" is the running true level (535);
-- "over_cap" renders anything past the cap as 30(+x) the way True Level does,
-- and leaves sub-cap levels and the cap itself as a plain number.
function Identity:_format_level(level)
	if not level then
		return nil
	end

	if (mod:get("level_format") or "total") == "over_cap" and level > 30 then
		return "30(+" .. (level - 30) .. ")"
	end

	return tostring(level)
end

-- Whether the level shows at all is decided by the caller (_progression_text),
-- which resolves the per-surface override against the global Show Total Level.
-- Re-checking the global here would make a per-surface "always show" impossible.
function Identity:_level_text(record, style, colors_enabled)
	if not record.true_level then
		return nil
	end

	local level = tonumber(record.true_level)
	local text = self:_format_level(level) or tostring(record.true_level)

	if level and level >= 1000 and mod:get("milestone_flair") ~= false then
		text = text .. " " .. self.glyphs.milestone
	end

	local icon = self:_game_icon("level_icon", style)

	if icon then
		text = text .. " " .. icon
	end

	return color_markup(text, self:_level_color(level or 0, self:_accent(record)), colors_enabled)
end

-- Prestige: how many times the character has earned a full level-1-to-30 XP
-- amount (see Identity:_prestige). Opt-in and its own tracker, so it never
-- displaces the level number; it borrows the level tier color and, by default,
-- the level insignia.
function Identity:_prestige_text(record, style, colors_enabled)
	if mod:get("show_prestige") ~= true then
		return nil
	end

	local prestige = tonumber(record.prestige)

	if not prestige or prestige <= 0 then
		return nil
	end

	local text = tostring(prestige)
	local icon = self:_game_icon("prestige_icon", style)

	if icon then
		text = text .. " " .. icon
	end

	local level = tonumber(record.true_level) or 0

	-- Override off: prestige keeps borrowing the total-level color (including any
	-- custom level color). Override on: a flat RGB of the player's choosing.
	-- Deliberately no separate prestige tier ramp — prestige is derived from the
	-- same XP as total level, so a prestige-keyed ramp could never disagree with
	-- the level ramp; it would be a setting that changes nothing.
	return color_markup(text, self:_custom_color("prestige", self:_level_color(level, self:_accent(record))), colors_enabled)
end

function Identity:_havoc_text(record, style, expanded, colors_enabled)
	local show_launchable = expanded or mod:get("show_havoc_assignments") ~= false
	local show_weekly = expanded or mod:get("show_havoc_weekly") ~= false
	local show_all_time = expanded or mod:get("show_havoc_all_time") == true
	local values = {}
	local launchable = record.launchable_havoc
	local estimated = false

	if show_launchable and not launchable and record.weekly_havoc then
		launchable = record.weekly_havoc
		estimated = true
	end

	local function append(value, approximation)
		value = tonumber(value)

		if not value then
			return
		end

		local previous = values[#values]

		if previous and previous.value == value and mod:get("collapse_equal_havoc") ~= false then
			return
		end

		values[#values + 1] = { value = value, estimated = approximation }
	end

	if show_launchable then
		append(launchable, estimated)
	end

	if show_weekly then
		append(record.weekly_havoc, false)
	end

	if show_all_time then
		append(record.all_time_havoc, false)
	end

	if #values == 0 then
		return nil
	end

	local rendered = {}

	for i = 1, #values do
		local value = values[i]
		local prefix = value.estimated and "~" or ""

		rendered[i] = color_markup(prefix .. tostring(value.value), self:_havoc_color(value.value, self:_accent(record)), colors_enabled)
	end

	local connector = style == "classic" and "/" or self.glyphs.arrow
	local text = table.concat(rendered, color_markup(connector, self:_accent(record), colors_enabled))
	local icon = self:_game_icon("havoc_icon", style)

	if icon then
		text = text .. " " .. color_markup(icon, self:_havoc_color(values[1].value, self:_accent(record)), colors_enabled)
	end

	return text
end

function Identity:_history_text(record, surface, expanded, colors_enabled)
	if record.history_text then
		return color_markup(record.history_text, self:_winrate_color(record.history_winrate, self:_accent(record)), colors_enabled)
	end

	if not mod.history or not (expanded or HISTORY_SURFACES[surface]) then
		return nil
	end

	local text, winrate = mod.history:record_text(record.account_id, expanded, self.glyphs, mod:get("presentation_style") or "aquila")

	return color_markup(text, self:_winrate_color(winrate, self:_accent(record)), colors_enabled)
end

function Identity:_first_drop_text(record, surface, colors_enabled)
	if surface ~= "lobby" or mod:get("first_drop_marker") == false or not mod.history then
		return nil
	end

	if mod.history:is_first_drop(record.account_id) then
		local glyph = self.glyphs.first_drop
		local prefix = glyph and glyph ~= "" and (glyph .. " ") or ""

		return color_markup(prefix .. mod:localize("first_drop_short"), self:_accent(record), colors_enabled)
	end

	return nil
end

function Identity:_progression_text(record, style, surface, expanded, colors_enabled, level_only)
	-- Per-surface content gates. Each is "inherit" by default, so this resolves
	-- to the global setting until a player deliberately overrides one surface.
	-- The level gate covers prestige too: prestige is a second reading of the
	-- same number, so a surface that does not want levels does not want it.
	local want_level = self:_surface_flag(surface, "level", "show_true_level")
	local want_havoc = self:_surface_get(surface, "havoc")
	local want_record = self:_surface_get(surface, "record")

	local level = want_level and self:_level_text(record, style, colors_enabled) or nil
	local prestige = want_level and not level_only
		and self:_prestige_text(record, style, colors_enabled) or nil
	local havoc = not level_only and want_havoc ~= "off"
		and self:_havoc_text(record, style, expanded, colors_enabled) or nil
	local history = not level_only and want_record ~= "off"
		and self:_history_text(record, surface, expanded, colors_enabled) or nil
	local first_drop = not level_only and want_record ~= "off"
		and self:_first_drop_text(record, surface, colors_enabled) or nil
	local accent = self:_accent(record)
	local show_level_label = mod:get("show_level_label") ~= false
	local function level_prefix(label)
		return show_level_label and color_markup(label, accent, colors_enabled) or ""
	end
	local parts = {}

	if style == "cogitator" then
		if level then parts[#parts + 1] = level_prefix("LV ") .. level end
		if prestige then parts[#parts + 1] = color_markup("PR ", accent, colors_enabled) .. prestige end
		if havoc then parts[#parts + 1] = color_markup("HV ", accent, colors_enabled) .. havoc end
		if history then parts[#parts + 1] = color_markup("WR ", accent, colors_enabled) .. history end
	elseif style == "registry" then
		local bracket = {}
		if level then bracket[#bracket + 1] = level_prefix("LV ") .. level end
		if prestige then bracket[#bracket + 1] = color_markup("P ", accent, colors_enabled) .. prestige end
		if havoc then bracket[#bracket + 1] = color_markup("H ", accent, colors_enabled) .. havoc end
		if #bracket > 0 then parts[#parts + 1] = color_markup("[", accent, colors_enabled) .. table.concat(bracket, color_markup(" | ", accent, colors_enabled)) .. color_markup("]", accent, colors_enabled) end
		if history then parts[#parts + 1] = history end
	elseif style == "dossier" then
		if level then parts[#parts + 1] = level_prefix("LVL ") .. level end
		if prestige then parts[#parts + 1] = color_markup("PRESTIGE ", accent, colors_enabled) .. prestige end
		if havoc then parts[#parts + 1] = color_markup("HAVOC ", accent, colors_enabled) .. havoc end
		if history then parts[#parts + 1] = history end
	elseif style == "rail" then
		if level then parts[#parts + 1] = level_prefix("LV ") .. level end
		if prestige then parts[#parts + 1] = color_markup("P ", accent, colors_enabled) .. prestige end
		if havoc then parts[#parts + 1] = color_markup("H ", accent, colors_enabled) .. havoc end
		if history then parts[#parts + 1] = history end
	elseif style == "classic" then
		if level then parts[#parts + 1] = level_prefix("L") .. level end
		if prestige then parts[#parts + 1] = color_markup("P", accent, colors_enabled) .. prestige end
		if havoc then parts[#parts + 1] = color_markup("H", accent, colors_enabled) .. havoc end
		if history then parts[#parts + 1] = history end
	else
		if level then
			-- Aquila and Litany use the vanilla insignia when available and a
			-- readable LV fallback when it is disabled or unavailable.
			local label = show_level_label and not self:_game_icon("level_icon", style) and level_prefix("LV ") or ""

			parts[#parts + 1] = label .. level
		end

		if prestige then
			-- Prestige self-labels with its chosen insignia when one renders,
			-- otherwise a short PR tag like the level row above it.
			local label = self:_game_icon("prestige_icon", style) and "" or color_markup("PR ", accent, colors_enabled)

			parts[#parts + 1] = label .. prestige
		end

		if havoc then
			-- With the vanilla insignia active the value is self-labelling.
			local label = self:_game_icon("havoc_icon", style) and "" or color_markup("H ", accent, colors_enabled)

			parts[#parts + 1] = label .. havoc
		end

		if history then parts[#parts + 1] = history end
	end

	if first_drop then
		parts[#parts + 1] = first_drop
	end

	if #parts == 0 then
		return nil
	end

	if style == "registry" then
		return table.concat(parts, color_markup(" ", accent, colors_enabled))
	end

	local separator = self:_progression_separator(style)

	return table.concat(parts, color_markup(" " .. separator .. " ", accent, colors_enabled))
end

function Identity:_join_identity_progression(identity, progression, style, position, colors_enabled, record)
	if not progression then
		return identity
	end

	if position == "second_line" then
		return identity .. "\n" .. progression
	end

	local accent = self:_accent(record)
	local connector

	if style == "aquila" then
		connector = " " .. (((mod:get("separator_glyph") or "auto") == "auto") and self.glyphs.ornament or self:_separator(style)) .. " "
	elseif style == "cogitator" then
		connector = " :: "
	elseif style == "litany" then
		connector = " " .. self.glyphs.devotional .. " "
	elseif style == "dossier" then
		connector = "  //  "
	elseif style == "rail" then
		connector = "  |  "
	elseif style == "classic" then
		connector = " · "
	else
		connector = "  "
	end

	connector = color_markup(connector, accent, colors_enabled)

	if position == "before" then
		return progression .. connector .. identity
	end

	return identity .. connector .. progression
end

function Identity:compose(record, surface, options)
	if not record then
		return nil
	end

	options = options or {}
	local expanded = mod.identity_expanded()
	local style = mod:get("presentation_style") or "aquila"
	local colors_enabled = options.use_colors ~= false

	-- Tell _identity_text which surface it is composing for so the per-surface
	-- name-style and platform-icon overrides apply. Copied rather than mutated:
	-- callers reuse their options tables.
	local identity_options = options

	if options.surface == nil then
		identity_options = {}

		for key, value in pairs(options) do
			identity_options[key] = value
		end

		identity_options.surface = surface
	end

	local identity = self:_identity_text(record, style, expanded, colors_enabled, identity_options)
	local include_progression = options.include_progression

	-- Surfaces with their own archetype row receive the kit there instead, so
	-- the class is never printed twice and no row is added anywhere.
	local kit_text = options.omit_kit ~= true and not ARCHETYPE_ROW_SURFACES[surface]
		and self:kit_enabled(surface)
		and self:_kit_text(record, style, colors_enabled, { expanded = expanded, surface = surface })
		or nil

	if include_progression == nil then
		include_progression = expanded or self:surface_progression(surface)
	end

	if not include_progression then
		return self:_append_kit(identity, kit_text, style, colors_enabled, record)
	end

	local progression = self:_progression_text(record, style, surface, expanded, colors_enabled, options.level_only)
	local position = mod:get("progression_position") or "after"

	if position == "second_line" and not NAMEPLATE_SURFACES[surface] and surface ~= "lobby" then
		position = "after"
	end

	local text = self:_join_identity_progression(identity, progression, style, position, colors_enabled, record)

	return self:_append_kit(text, kit_text, style, colors_enabled, record)
end

-- Dense four-column lineups have two native name rows but only 440px per
-- player. Return a primary identity row and a secondary identity/progression
-- row so callers can use both without flattening every value into one line.
-- The chosen Name Format still controls which identity appears first.
function Identity:compose_split(record, surface, options)
	if not record then
		return nil, nil
	end

	options = options or {}

	local expanded = mod.identity_expanded()
	local style = mod:get("presentation_style") or "aquila"
	local colors_enabled = options.use_colors ~= false
	local name_style = expanded and "character_account"
		or options.name_style
		or self:_surface_get(surface, "name_style")
		or mod:get("name_style")
		or "character_account"
	local has_character = nonempty(record.character_name) ~= nil
	local has_account = self:_account_visible(record) and nonempty(record.account_name) ~= nil

	if has_character and has_account and mod:get("deduplicate_names") ~= false
		and normalized(record.character_name) == normalized(record.account_name) then
		has_account = false
	end

	local order = {}
	local function append(kind, present)
		if present then
			order[#order + 1] = kind
		end
	end

	if name_style == "account_character" then
		append("account", has_account)
		append("character", has_character)
	elseif name_style == "account" then
		append("account", has_account)
		append("character", not has_account and has_character)
	elseif name_style == "character" then
		append("character", has_character)
		append("account", not has_character and has_account)
	else
		append("character", has_character)
		append("account", has_account)
	end

	local primary_kind = order[1]
	local secondary_kind = order[2]
	local function identity_part(kind, allow_missing)
		if not kind then
			return nil
		end

		return self:_identity_text(record, style, expanded, colors_enabled, {
			allow_missing = allow_missing,
			name_style = kind,
			show_platform_icon = kind == "account" or (not secondary_kind and kind == primary_kind),
			strict_name_style = true,
			surface = surface,
		})
	end

	local primary = identity_part(primary_kind, false)

	if not primary then
		primary = self:_identity_text(record, style, expanded, colors_enabled, options)
	end

	local secondary = identity_part(secondary_kind, true)
	local include_progression = options.include_progression

	if include_progression == nil then
		include_progression = expanded or self:surface_progression(surface)
	end

	local progression = include_progression
		and self:_progression_text(record, style, surface, expanded, colors_enabled, options.level_only)
		or nil

	if secondary and progression then
		local position = mod:get("progression_position") or "after"

		if position == "second_line" then
			position = "after"
		end

		secondary = self:_join_identity_progression(secondary, progression, style, position, colors_enabled, record)
	elseif progression then
		secondary = progression
	end

	-- Split surfaces normally own an archetype row, which takes the kit
	-- instead. Any that do not still get it, on the secondary row.
	if not ARCHETYPE_ROW_SURFACES[surface] and self:kit_enabled(surface) then
		local kit_text = self:_kit_text(record, style, colors_enabled, { expanded = expanded, surface = surface })

		secondary = self:_append_kit(secondary, kit_text, style, colors_enabled, record)
	end

	return primary, secondary
end

function Identity:compose_player(player, surface, options)
	return self:compose(self:record_player(player), surface, options)
end

function Identity:compose_player_info(player_info, surface, profile, options)
	return self:compose(self:record_player_info(player_info, profile), surface, options)
end

function Identity:compose_local_profile(profile, surface, options)
	return self:compose(self:record_local_profile(profile), surface, options)
end

function Identity:preview()
	local style = mod:get("presentation_style") or "aquila"
	local history_text = style == "cogitator" and "67:12" or style == "litany" and "67%:12" or "67%·12"

	if style == "registry" or style == "dossier" or style == "rail" or style == "classic" then
		history_text = "+8 -4"
	end

	return self:compose({
		account_id = "preview",
		account_name = "oagoz",
		character_name = "Kharvach",
		true_level = 535,
		launchable_havoc = 30,
		weekly_havoc = 34,
		all_time_havoc = 40,
		history_text = history_text,
		history_winrate = 67,
	}, "team_hud", { include_progression = true })
end

-- Diagnostic for the "everyone should show a true level" path: reports whether
-- the account XP curve has loaded and, per current human player, whether their
-- progression was captured and whether it carried the currentXp needed to read
-- past level 30. Run it in a lobby or mission.
local function fetch_state_line(label, loaded_text, request, retry_delay, last_error)
	local state

	if loaded_text then
		state = loaded_text
	elseif request then
		state = "request in flight"
	elseif retry_delay and retry_delay > 0 then
		state = string.format("backing off (retry in %ds)", math.ceil(retry_delay))
	else
		state = "not requested yet"
	end

	if last_error then
		state = state .. " | last error: " .. last_error
	end

	return label .. ": " .. state
end

function Identity:level_report()
	local xp_ready = type(self.xp_table) == "table" and #self.xp_table >= 2
	local lines = {
		fetch_state_line(
			"XP curve",
			xp_ready and string.format("loaded (%d levels, source: %s)", #self.xp_table, self._xp_table_source or "backend") or nil,
			self._xp_request,
			self._xp_retry_delay,
			self._xp_last_error
		),
		fetch_state_line(
			"Own progressions",
			self._progressions_loaded and "loaded" or nil,
			self._progressions_request,
			self._progressions_retry_delay,
			self._progressions_last_error
		),
	}

	if not xp_ready then
		lines[#lines + 1] = "Every true level reads the capped level until the XP curve arrives."
	end

	local players = Managers.player and safe_call(Managers.player, "human_players") or {}
	local found = false

	for _, player in pairs(players) do
		found = true

		local profile = safe_call(player, "profile")
		local character_id = profile and profile.character_id
		local captured = character_id and self.progressions[character_id]
		local has_xp = captured and tonumber(captured.currentXp) ~= nil
		local level = character_id and self.true_levels[character_id]
		local name = clean_name(safe_call(player, "name")) or "?"
		local state

		if not captured then
			state = "progression not captured yet"
		elseif has_xp then
			state = "captured with XP"
		else
			state = "captured but no XP (shows capped level)"
		end

		lines[#lines + 1] = string.format("%s: level %s (%s)", name, level and tostring(level) or "?", state)
	end

	if not found then
		lines[#lines + 1] = "No human players found — run this in a lobby or mission."
	end

	return table.concat(lines, "\n")
end

mod.identity = Identity
