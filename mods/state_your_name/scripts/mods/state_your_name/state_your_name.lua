local mod = get_mod("state_your_name")
local UISettings = require("scripts/settings/ui/ui_settings")

-- The one authoritative version for this mod. Every release build is stamped
-- from here: tools/build_public.py refuses to package unless --version matches
-- it and a PATCHNOTES file for it exists, and it is written into syn_diag.txt
-- so a submitted diagnostics file always names the exact build it came from.
-- Bump it in the same change that alters shipped behaviour, never after the
-- fact — a version number is a claim about contents.
mod.version = "1.3.0"

mod._expand_identity_held = false
mod._identity_revision = 0
mod._conflict_check_pending = true
mod._warned_conflicts = {}
mod._external_color_poll_ttl = 0
mod._external_color_signature = nil

mod:io_dofile("state_your_name/scripts/mods/state_your_name/state_your_name_identity")
mod:io_dofile("state_your_name/scripts/mods/state_your_name/state_your_name_history")
mod:io_dofile("state_your_name/scripts/mods/state_your_name/state_your_name_inspection")
mod:io_dofile("state_your_name/scripts/mods/state_your_name/state_your_name_hooks")

-- DMF dispatches a keybind_trigger="held" / keybind_type="function_call" binding
-- on the EDGES ONLY: once with is_pressed=true when the key goes down, once with
-- is_pressed=false when it comes up (dmf keybindings.lua: the per-frame call is
-- suppressed by its own `pressed` latch, and the release call is queued only for
-- "held"). It is NOT called every frame, so the old design — arm a 0.15s timer on
-- each call — expired mid-hold and re-armed on release: the two brief "blips"
-- players reported. Latch the key state instead and bump the revision only on the
-- transitions, so the expansion lasts exactly as long as the key is down.
function mod.expand_identity(is_pressed)
	-- `~= false` (not a truthiness test) so a manual call with no argument, e.g.
	-- from the console, still reads as a press.
	local held = is_pressed ~= false

	if held == mod._expand_identity_held then
		return
	end

	mod._expand_identity_held = held
	mod._identity_revision = mod._identity_revision + 1
end

-- Single predicate for "show the expanded identity right now".
function mod.identity_expanded()
	return mod._expand_identity_held == true
end

local NAME_STYLE_ORDER = { "character_account", "account_character", "character", "account" }
local CONFLICTING_MODS = {
	{ label = "True Level", ids = { "true_level" } },
	{ label = "Who Are You", ids = { "who_are_you" } },
	{ label = "CurrentHavoc", ids = { "CurrentHavoc", "current_havoc", "currentHavoc" } },
	{ label = "Teammate Tracker", ids = { "teammate_tracker" } },
	-- Only a conflict once our own kit display is on: both mods then write the
	-- class and talent into the same native name widgets.
	{
		label = "What Are You",
		ids = { "what_are_you", "WhatAreYou", "what_are_you_continued", "WhatAreYouContinued" },
		requires_setting = "show_kit",
	},
}

-- Color Selection updates UISettings.player_slot_colors in place and exposes
-- a revision, but identity widgets in menus/lobbies are otherwise only rebuilt
-- when one of our own settings changes. Poll a compact signature so picker
-- changes refresh every State Your Name surface automatically; the color-table
-- values also cover compatible slot-color mods that do not publish a revision.
local function external_color_signature()
	local parts = { tostring(UISettings._colors_revision or 0) }
	local ok, color_mod = pcall(get_mod, "ColorSelection")

	if ok and color_mod and color_mod ~= mod then
		parts[#parts + 1] = tostring(color_mod._colors_revision or 0)

		-- Color Selection intentionally does not rewrite UISettings in the hub,
		-- but its exported color lookup reads these values live. Include them so
		-- changing a picker slider in the Mourningstar still invalidates our text.
		if type(color_mod.get) == "function" then
			local prefixes = {
				"slot1", "slot2", "slot3", "slot4", "bot",
				"veteran", "zealot", "psyker", "ogryn", "broker", "adamant", "cryptic",
			}
			local setting_ok, color_by_class = pcall(color_mod.get, color_mod, "color_by_class")

			parts[#parts + 1] = setting_ok and tostring(color_by_class) or "?"

			for i = 1, #prefixes do
				local prefix = prefixes[i]

				for _, component in ipairs({ "r", "g", "b" }) do
					local value_ok, value = pcall(color_mod.get, color_mod, prefix .. "_" .. component)

					parts[#parts + 1] = value_ok and tostring(value) or "?"
				end
			end
		end
	end

	local colors = UISettings.player_slot_colors

	for slot = 1, 5 do
		local color = colors and colors[slot]

		if type(color) == "table" then
			parts[#parts + 1] = string.format("%s,%s,%s,%s", tostring(color[1]), tostring(color[2]), tostring(color[3]), tostring(color[4]))
		else
			parts[#parts + 1] = "-"
		end
	end

	return table.concat(parts, "|")
end

local function poll_external_colors(dt)
	mod._external_color_poll_ttl = math.max((mod._external_color_poll_ttl or 0) - dt, 0)

	if mod._external_color_poll_ttl > 0 then
		return
	end

	mod._external_color_poll_ttl = 0.2

	local signature = external_color_signature()
	local previous = mod._external_color_signature

	mod._external_color_signature = signature

	if previous and previous ~= signature then
		mod._identity_revision = mod._identity_revision + 1
	end
end

-- DMF creates mods in load-order sequence, so on_enabled can run before a
-- conflicting mod listed after us exists. Check immediately and once again on
-- the first update, when the full load order is guaranteed to be registered.
function mod.check_conflicting_mods()
	local newly_detected = {}

	for i = 1, #CONFLICTING_MODS do
		local conflict = CONFLICTING_MODS[i]

		-- Some entries only overlap while the feature that collides with them
		-- is switched on, and stay silent otherwise.
		local applicable = not conflict.requires_setting or mod:get(conflict.requires_setting) == true

		if applicable then
			local enabled = false

			for j = 1, #conflict.ids do
				local ok, other = pcall(get_mod, conflict.ids[j])

				if ok and other and other ~= mod then
					if type(other.is_enabled) == "function" then
						local state_ok, state = pcall(other.is_enabled, other)

						enabled = not state_ok or state ~= false
					else
						enabled = true
					end

					if enabled then
						break
					end
				end
			end

			if enabled and not mod._warned_conflicts[conflict.label] then
				mod._warned_conflicts[conflict.label] = true
				newly_detected[#newly_detected + 1] = conflict.label
			end
		end
	end

	if #newly_detected > 0 then
		local message = mod:localize("conflict_warning", table.concat(newly_detected, ", "))

		mod:warning(message)
		mod:notify(message)
	end

	return newly_detected
end

-- Keybind target: steps the Name Format setting through its four styles.
-- mod:set with the third argument true routes through on_setting_changed,
-- which bumps the identity revision so one-shot surfaces recompose too.
function mod.cycle_name_style()
	local current = mod:get("name_style") or "character_account"
	local index = 1

	for i = 1, #NAME_STYLE_ORDER do
		if NAME_STYLE_ORDER[i] == current then
			index = i
			break
		end
	end

	local next_style = NAME_STYLE_ORDER[index % #NAME_STYLE_ORDER + 1]

	mod:set("name_style", next_style, true)
	mod:echo(mod:localize("style_" .. next_style))
end

function mod.update(dt)
	if mod._conflict_check_pending then
		mod._conflict_check_pending = false
		mod.check_conflicting_mods()
	end

	poll_external_colors(dt)

	mod.identity:update(dt)
	mod.history:update(dt)
	mod.inspection:update(dt)

	if mod._diag_delay then
		mod._diag_delay = mod._diag_delay - dt

		if mod._diag_delay <= 0 then
			mod._diag_delay = 60
			mod.write_diag()
		end
	end
end

function mod.on_setting_changed(setting_id)
	-- Rebinding a keybind makes DMF rebuild its keybind table, which drops the
	-- pressed latch — a key held across that rebind never delivers its release
	-- edge. Clearing here keeps the expansion from sticking on forever.
	mod._expand_identity_held = false
	mod._identity_revision = mod._identity_revision + 1

	if setting_id == "track_history" and mod:get("track_history") ~= false then
		mod.history:load()
	end
end

function mod.on_enabled()
	mod._conflict_check_pending = true
	mod._external_color_poll_ttl = 0
	mod._external_color_signature = nil
	mod.check_conflicting_mods()

	-- Rev 1 shipped Registry as its automatic default. Move existing Registry
	-- installs to the approved Aquila default once; Registry remains selectable
	-- afterward, and every other saved presentation remains unchanged.
	if not mod:get("_rev2_visual_migrated") then
		if mod:get("presentation_style") == "registry" then
			mod:set("presentation_style", "aquila")
		end

		mod:set("_rev2_visual_migrated", true)
	end

	-- Overhead nameplates became two surfaces (Mourningstar and missions). Carry
	-- the old single setting onto both so anyone who had turned nameplates off,
	-- or turned their progression off, keeps exactly what they chose instead of
	-- silently getting the new defaults.
	if not mod:get("_rev3_nameplate_split_migrated") then
		local old_enabled = mod:get("enable_nameplates")
		local old_progression = mod:get("nameplates_progression")

		if old_enabled ~= nil then
			mod:set("enable_nameplates_hub", old_enabled)
			mod:set("enable_nameplates_mission", old_enabled)
		end

		if old_progression ~= nil then
			mod:set("nameplates_hub_progression", old_progression)
			mod:set("nameplates_mission_progression", old_progression)
		end

		mod:set("_rev3_nameplate_split_migrated", true)
	end

	mod._identity_revision = mod._identity_revision + 1

	-- Disk-cached XP curve first so character select can show total levels
	-- immediately; the live fetch still runs and supersedes it when it lands.
	pcall(function()
		mod.identity:load_cached_xp_table()
	end)

	mod.identity:refresh_xp_table()
	mod.identity:refresh_progressions(true)
	mod.history:on_enabled()

	local havoc_service = Managers.data_service and Managers.data_service.havoc

	if havoc_service and havoc_service.refresh_havoc_rank then
		pcall(function()
			havoc_service:refresh_havoc_rank()
		end)
	end
end

function mod.on_disabled()
	-- DMF skips the release call for a disabled mod, so a key held across a
	-- disable would otherwise latch the expansion on permanently.
	mod._expand_identity_held = false
	mod._identity_revision = mod._identity_revision + 1
	mod.inspection:shutdown()
end

function mod.on_game_state_changed(status, state_name)
	if state_name == "StateGameplay" and status == "exit" then
		mod.history:on_gameplay_exit()
	end
end

-- Public, read-only formatter API for HUD mods that want to cooperate rather
-- than hook the same widgets. Returns nil when the player cannot be resolved.
function mod.compose_player_identity(player, surface)
	return mod.identity:compose_player(player, surface or "team_hud")
end

mod:command("syn_preview", "Preview the current State Your Name presentation", function()
	mod:echo(mod.identity:preview())
end)

mod:command("syn_record", "Show your complete service record with a named player", function(...)
	local name = table.concat({ ... }, " ")

	if name == "" then
		mod:echo(mod:localize("record_command_usage"))
		return
	end

	mod:echo(mod.history:lookup_text(name))
end)

mod:command("syn_levels", "Report XP-curve status and each current player's captured true level", function()
	mod:echo(mod.identity:level_report())
end)

-- Diagnostics go to mods/state_your_name/syn_diag.txt as well as chat,
-- because at least one machine renders no mod chat output at all. The file is
-- also written automatically (15s after load, then every 60s) so a single
-- relaunch produces ground truth without running any command.
local function write_diag_file()
	local uptime = 0

	if rawget(_G, "Application") and type(Application.time_since_launch) == "function" then
		local ok, value = pcall(Application.time_since_launch)

		if ok then
			uptime = value
		end
	end

	local report = table.concat({
		"== State Your Name diagnostics ==",
		string.format("version %s", tostring(mod.version)),
		string.format("written %ds after launch", math.floor(uptime)),
		"",
		"-- true level --",
		mod.identity:level_report(),
		"",
		"-- Havoc summary requests --",
		mod.identity:havoc_report(),
		"",
		"-- glyphs --",
		mod.identity:glyph_report(),
	}, "\n")

	local mods_root = rawget(_G, "Mods")
	local io_lib = mods_root and mods_root.lua and mods_root.lua.io
	local file = io_lib and io_lib.open("./../mods/state_your_name/syn_diag.txt", "w")

	if file then
		file:write(report .. "\n")
		file:close()
	end

	return report
end

mod._diag_delay = 15

function mod.write_diag()
	local ok, report = pcall(write_diag_file)

	return ok and report or nil
end

mod:command("syn_diag", "Write identity/Havoc/glyph diagnostics to syn_diag.txt", function()
	local report = mod.write_diag()

	if report then
		mod:echo(report)
	end
end)
