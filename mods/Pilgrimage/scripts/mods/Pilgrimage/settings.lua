-- settings.lua
--
-- The read layer over DMF settings, plus the single source of truth for defaults.
--
-- Two rules that keep this sane as the mod grows:
--
--   1. DEFAULTS lives here and Pilgrimage_data.lua imports it, so a default value is
--      written down exactly once.
--
--   2. Nothing outside this file calls mod:get for a gameplay value. Every setting
--      gets a named accessor that validates and clamps, so a corrupted or
--      out-of-range stored value degrades to the default instead of propagating a
--      nil or a nonsense number into gameplay code.
--
-- IMPORTANT: this file is loaded TWICE. Once by bootstrap, and once by
-- Pilgrimage_data.lua (which needs DEFAULTS). mod:io_dofile does not go through
-- Lua's require cache, so those are two separate instances. That is only safe
-- because DEFAULTS is a pure literal table with no runtime state in it. Never put
-- mutable state in this file above the init function.

local M = {}

local _mod
local _log_levels

-- ---------------------------------------------------------------------------
-- DEFAULTS: pure literal, no function calls, no runtime reads
-- ---------------------------------------------------------------------------

M.DEFAULTS = {
	-- Diagnostics
	enable_perf      = false,
	enable_event_log = false,
	-- v0.23.0 (Nexus beta): master switch for the ad-hoc diagnostic
	-- FILE writers (ff_diag.txt, bot_spawn_diag.txt). Default off so
	-- public installs never accumulate log files; the dev install turns
	-- it on (options checkbox or /pil_diagnostics on).
	diagnostics_enabled = false,
	-- v0.23.3 (FB-2): testing / cheat mode. Master off; the sub-toggles
	-- default on so flipping the master gives the full kit, but they
	-- only act while the master is on. Penance earning is suspended
	-- while cheat_mode is on (penances.observe gate).
	cheat_mode          = false,
	cheat_invulnerable  = true,
	cheat_one_shot      = true,
	log_level        = "off",

	-- Terminal
	enable_terminal_prompt   = true,
	terminal_prompt_distance = 4,

	-- Debug: which preset the capture-all keybind acts on. v0.22.31 added
	-- a keybind wrapper for /pil_preset_capture_all so Kaizen can capture
	-- from the character-select screen without typing a chat command; the
	-- dropdown here decides which preset gets the capture, since a keybind
	-- can't take arguments. Defaults to sister_argenta (the only preset
	-- shipping today).
	capture_target_preset = "sister_argenta",

	-- Run
	--
	-- v0.20.0: renamed from enable_auto_chain and DEFAULT FLIPPED from true
	-- to false. The default flow now drops the player back at the terminal
	-- between legs (so they can use the Emporium, reslot, or just breathe).
	-- Blitz mode is the old auto-launch behavior, opt-in, and cannot be
	-- toggled mid-run: once you commit to a Blitz run you either finish it
	-- or abandon it. See chain.lua and route_view.lua for the enforcement.
	enable_blitz_mode  = false,
	run_length         = 3,
	run_boons_per_leg  = 1,
	run_seeded         = false,
	run_seed           = 0,

	-- Curses
	curses_havoc_pool      = true,
	-- v0.20.3: live-event curses (barren, saints, endless_hordes, and
	-- friends) borrow templates from Fatshark's live events. Templates
	-- are always in the code, but individual MUTATORS inside them may
	-- be retired between patches. Off-switch so a broken one can be
	-- isolated without editing the catalogue.
	curses_live_event_pool = true,
	curses_stacking        = true,
	curses_guard           = true,

	-- Tactical overlay panel
	enable_overlay_panel = true,

	-- Skip boon effects whose particles this mission never loaded, instead of
	-- letting the engine crash on them.
	fx_guard = true,
	-- v0.25.1: load the Mortis level package with run missions so boon
	-- visuals actually show (augentism's technique). Off = pre-v0.25.1
	-- behaviour, guard-only, for memory-constrained installs.
	fx_full_visuals    = true,

	-- Difficulty ramp starting point. "malice" | "heresy" | "damnation" |
	-- "uprising". Each leg's actual danger goes up from here, capping at
	-- Damnation, then adds enemy-only scaling tiers past that.
	starting_difficulty = "malice",

	-- v0.22.45: Skitarii bots auto-dispatch their servo skull at
	-- stalled decoding interactables (data interrogators). Uses the
	-- vanilla "companion order" smart tag path, no bot AI patching.
	-- Default on so any Cryptic preset the user runs picks it up
	-- immediately. Toggle off if it ever misbehaves in a specific
	-- mission.
	enable_bot_hack_orders = true,
}

-- Feature gates are a name-to-setting-id indirection. Gameplay code asks
-- `Settings.is_feature_enabled("terminal_prompt")` and never has to know the
-- setting id, so renaming a setting is a one-line change here.
local FEATURE_GATES = {
	perf           = "enable_perf",
	event_log      = "enable_event_log",
	terminal_prompt = "enable_terminal_prompt",
	blitz_mode      = "enable_blitz_mode",
}

-- ---------------------------------------------------------------------------
-- Primitive readers
-- ---------------------------------------------------------------------------

local function _read_bool(setting_id, default_value)
	if not _mod then return default_value end
	local value = _mod:get(setting_id)
	if value == nil then return default_value end
	return value == true
end

local function _read_number(setting_id, default_value, min_value, max_value)
	if not _mod then return default_value end
	local value = tonumber(_mod:get(setting_id))
	if not value then return default_value end
	if min_value and value < min_value then return default_value end
	if max_value and value > max_value then return default_value end
	return value
end

local function _read_string(setting_id, default_value, valid_values)
	if not _mod then return default_value end
	local value = _mod:get(setting_id)
	if type(value) ~= "string" then return default_value end
	if valid_values and not valid_values[value] then return default_value end
	return value
end

-- ---------------------------------------------------------------------------
-- Feature gates
-- ---------------------------------------------------------------------------

local _warned_unknown = {}

-- Policy: fail OPEN for gates. An unknown feature name is always a bug in our own
-- code, but crashing a player's game over it is worse than running the feature. We
-- warn once so the bug is still visible in a log.
function M.is_feature_enabled(feature_name)
	local setting_id = FEATURE_GATES[feature_name]
	if not setting_id then
		if not _warned_unknown[feature_name] and _mod then
			_warned_unknown[feature_name] = true
			_mod:warning("Pilgrimage: unknown feature gate '" ..
				tostring(feature_name) .. "' (defaulting to enabled)")
		end
		return true
	end
	return _read_bool(setting_id, M.DEFAULTS[setting_id] ~= false)
end

-- ---------------------------------------------------------------------------
-- Named accessors
-- ---------------------------------------------------------------------------

function M.perf_enabled()
	return _read_bool("enable_perf", M.DEFAULTS.enable_perf)
end

function M.event_log_enabled()
	return _read_bool("enable_event_log", M.DEFAULTS.enable_event_log)
end

function M.log_level_raw()
	return _read_string("log_level", M.DEFAULTS.log_level,
		{ off = true, info = true, debug = true, trace = true })
end

function M.log_level()
	return _log_levels.resolve_setting(M.log_level_raw())
end

function M.terminal_prompt_distance()
	return _read_number("terminal_prompt_distance", M.DEFAULTS.terminal_prompt_distance, 1, 20)
end

-- Blitz mode. When on, finishing a leg auto-launches the next one from the
-- Mourningstar (the old auto_chain behavior). When off, the player lands
-- back at the terminal and starts the next leg deliberately, giving the
-- Emporium a chance to matter. Only ever acts while a run is active.
--
-- The intent is that Blitz is chosen ONCE, pre-run, and lives for the run's
-- duration. There is a run-scoped lock set by run_state.start(), so a mid-run
-- setting flip does not switch modes underfoot.
function M.blitz_mode_enabled()
	return _read_bool("enable_blitz_mode", M.DEFAULTS.enable_blitz_mode)
end

function M.run_length()
	return _read_number("run_length", M.DEFAULTS.run_length, 1, 10)
end

function M.boons_per_leg()
	return _read_number("run_boons_per_leg", M.DEFAULTS.run_boons_per_leg, 0, 5)
end

function M.run_seeded()
	return _read_bool("run_seeded", M.DEFAULTS.run_seeded)
end

function M.configured_seed()
	return _read_number("run_seed", M.DEFAULTS.run_seed, 0, 2147483646)
end

-- ---------------------------------------------------------------------------

function M.reset_all()
	if not _mod then return {} end
	local failures = {}
	for setting_id, default_value in pairs(M.DEFAULTS) do
		local ok, err = pcall(function() _mod:set(setting_id, default_value, true) end)
		if not ok then
			failures[#failures + 1] = setting_id .. " (" .. tostring(err) .. ")"
		end
	end
	return failures
end

function M.init(deps)
	_mod = deps.mod
	_log_levels = deps.log_levels
end

return M
