local mod = get_mod("state_your_name")
local identity = mod.identity
local inspection = mod.inspection
local Progression = require("scripts/backend/progression")
local CLASS = rawget(_G, "CLASS")

local logged_errors = {}

local function guarded(key, callback)
	local ok, result = pcall(callback)

	if not ok and not logged_errors[key] then
		logged_errors[key] = true
		mod:error("State Your Name disabled a failing %s integration: %s", key, tostring(result))
	end

	return ok and result or nil
end

-- DMF hook_require replays its callback every time the file is required again
-- (HUD rebuilds re-require every element, and any other mod's require of the
-- same path counts too). Re-running a callback rehooks the same instance and
-- DMF warns "Attempting to rehook active hook" on every transition, so each
-- presented instance runs its callback once — weak keys keep unloaded modules
-- collectable, and a genuinely fresh instance after a cache bust still hooks.
local seen_required_instances = {}

local function hook_require_once(path, callback)
	local seen = seen_required_instances[path]

	if not seen then
		seen = setmetatable({}, { __mode = "k" })
		seen_required_instances[path] = seen
	end

	mod:hook_require(path, function(instance)
		if seen[instance] then
			return
		end

		seen[instance] = true

		callback(instance)
	end)
end

local function set_widget_text(widget, field, value)
	if not widget or not widget.content or not value or value == "" then
		return
	end

	if widget.content[field] ~= value then
		widget.content[field] = value
		widget.dirty = true
	end
end

local function configured_font_size()
	local value = tonumber(mod:get("font_size"))

	return value and value > 0 and math.max(1, math.min(value, 40)) or nil
end

local function identity_font_size(native_size)
	return configured_font_size() or native_size
end

-- Most identity surfaces expose their native text style. Remember the values
-- owned by vanilla (or another UI mod) so setting the override back to 0 can
-- restore them instead of leaving the last custom size stuck on the widget.
local function apply_font_override(widget, field)
	local style = widget and widget.style and widget.style[field]

	if not style then
		return
	end

	local size = configured_font_size()
	local original = style.__syn_original_font_size

	if size then
		if not original then
			original = {
				default_font_size = style.default_font_size or false,
				font_size = style.font_size or false,
			}
			style.__syn_original_font_size = original
		end

		local changed = style.font_size ~= size
			or (style.default_font_size ~= nil and style.default_font_size ~= size)

		style.font_size = size

		if style.default_font_size ~= nil then
			style.default_font_size = size
		end

		if changed then
			widget.dirty = true
		end
	elseif original then
		style.font_size = original.font_size or nil

		if style.default_font_size ~= nil or original.default_font_size then
			style.default_font_size = original.default_font_size or nil
		end

		style.__syn_original_font_size = nil
		widget.dirty = true
	end
end

local function fit_widget_line(ui_renderer, widget, field, text, default_font_size, max_width, line_height)
	local style = widget and widget.style and widget.style[field]

	if not style then
		return
	end

	style.font_size = default_font_size
	style.size = style.size or { max_width, line_height or default_font_size + 6 }
	style.size[1] = max_width
	style.size[2] = style.size[2] or line_height or default_font_size + 6
	-- The UI pass repeats the width fit at draw time, while the explicit fit
	-- below updates retained widgets immediately on the frame we rewrite them.
	style.text_fit_with = true

	if not text or text == "" or not ui_renderer or not rawget(_G, "UIRenderer")
		or type(UIRenderer.scaled_font_size_by_width) ~= "function" then
		return
	end

	local ok, fitted = pcall(
		UIRenderer.scaled_font_size_by_width,
		ui_renderer,
		text,
		style.font_type or "proxima_nova_bold",
		default_font_size,
		max_width
	)

	if ok and tonumber(fitted) then
		style.font_size = math.min(default_font_size, math.max(tonumber(fitted), 1))
	end
end

local function recolor_player_prefix(prefix, record)
	local color = record and record.slot_color

	if not identity:color_selection_active() or not prefix or prefix == "" or not color then
		return prefix or ""
	end

	-- Vanilla caches the archetype-symbol prefix separately from the name. Strip
	-- only Darktide color wrappers, then rebuild it from the same live color used
	-- by the composed character name so a picker change cannot leave the icon on
	-- its previous color.
	local plain = prefix:gsub("{#color%(%d+,%d+,%d+,%d+%)}", "")
		:gsub("{#color%(%d+,%d+,%d+%)}", "")
		:gsub("{#reset%(%)%}", "")
		:gsub("%s+$", "")

	return string.format("{#color(%d,%d,%d)}%s{#reset()} ", color[1], color[2], color[3], plain)
end

local function is_own_player(player)
	return player and not player.remote
end

-- Capture the cumulative XP that vanilla profile conversion intentionally
-- leaves out. The value is stored in our own cache; game profile tables and
-- network payloads are never mutated.
hook_require_once("scripts/utilities/profile_utils", function(ProfileUtils)
	mod:hook(ProfileUtils, "character_to_profile", function(func, character, gear_list, progression)
		if character and progression then
			identity:capture_progression(character.id, progression)
		end

		return func(character, gear_list, progression)
	end)

	mod:hook(ProfileUtils, "backend_profile_data_to_profile", function(func, backend_profile_data)
		local progression = backend_profile_data and backend_profile_data.progression
		local character = backend_profile_data and backend_profile_data.character

		if character and progression then
			identity:capture_progression(character.id, progression)
		end

		return func(backend_profile_data)
	end)
end)

-- Darktide refreshes the selected character's progression after a mission
-- without rebuilding the profile. Observe that existing request so a capped
-- character's displayed total advances immediately, without another request.
mod:hook(Progression, "get_progression", function(func, self, entity_type, id)
	local request = func(self, entity_type, id)

	if entity_type == "character" and request and type(request.next) == "function" then
		request:next(function(progression)
			identity:capture_progression(id, progression)
		end):catch(function()
			-- The caller owns error handling for the original request. This branch
			-- only observes successful responses and must not add an unhandled one.
		end)
	end

	return request
end)

-- Capture mission metadata before players spawn, and commit the compatible
-- teammate-tracker row as soon as Darktide declares the outcome. This makes
-- the just-finished mission visible on the end screen without double-writing
-- again when StateGameplay exits.
if CLASS and CLASS.StateGameplay then
	mod:hook(CLASS.StateGameplay, "on_enter", function(func, self, parent, params, creation_context, ...)
		local result = func(self, parent, params, creation_context, ...)

		guarded("service history start", function()
			mod.history:begin(params)
		end)

		return result
	end)
end

if CLASS and CLASS.GameModeManager and CLASS.GameModeManager._set_end_conditions_met then
	mod:hook(CLASS.GameModeManager, "_set_end_conditions_met", function(func, self, outcome, ...)
		local result = func(self, outcome, ...)

		guarded("service history outcome", function()
			mod.history:finish(outcome)
		end)

		return result
	end)
end

-- The end-of-round report hands the progression manager the character's raw
-- cumulative XP; vanilla immediately clamps a capped character's copy to the
-- level-30 table value (ProgressionManager._cap_xp), which is why the end
-- screen's XP bar sits full forever. Capture the raw values first.
if CLASS and CLASS.ProgressionManager and CLASS.ProgressionManager._parse_stats then
	mod:hook(CLASS.ProgressionManager, "_parse_stats", function(func, self, stats)
		guarded("session XP capture", function()
			-- Offline sessions (SoloPlay and any other run without a backend
			-- game session) parse a dummy report whose XP numbers are
			-- placeholders, not this character's; stash nothing from those.
			if self.is_using_dummy_report and self:is_using_dummy_report() then
				return
			end

			if stats and stats.type == "character" then
				identity:capture_session_stats(stats)
			end
		end)

		return func(self, stats)
	end)
end

-- Re-seed the end screen's experience bar in true-level space so it keeps
-- filling and rolling over past the cap. Vanilla's own update loop then runs
-- the animation, level text swaps, and level-up sting unchanged; only the
-- seeded thresholds differ.
hook_require_once("scripts/ui/views/end_player_view/end_player_view", function(EndPlayerView)
	mod:hook(EndPlayerView, "_setup_progress_bar", function(func, self)
		local result = func(self)

		guarded("true-level XP bar", function()
			local session_report = self._session_report
			local experience_settings = session_report and session_report.experience_settings

			-- An offline session (SoloPlay runs, anything without a backend
			-- game session) presents ProgressionManager's dummy report, whose
			-- experience table is a 12-level placeholder curve — capturing it
			-- as the character curve once turned a level ~240 character into
			-- "LV 2220". Nothing in a dummy report is real, so leave the
			-- vanilla bar alone as well.
			local progression_manager = Managers.progression

			if progression_manager and progression_manager.is_using_dummy_report and progression_manager:is_using_dummy_report() then
				return
			end

			-- The report delivers the authoritative character XP curve with
			-- every mission; capture it regardless of any toggle so total
			-- levels resolve even when the backend curve fetch fails, and so
			-- the disk cache stays current across game patches.
			if experience_settings and experience_settings.experience_table then
				identity:set_xp_table(experience_settings.experience_table, "end_of_round")
			end

			if mod:get("true_level_xp_bar") == false or mod:get("show_true_level") == false then
				return
			end

			local stash = identity:session_stats()

			if not experience_settings or not stash then
				return
			end

			-- Characters still below the cap animate correctly in vanilla,
			-- including the climb onto level 30 itself; leave those alone.
			local start_level = tonumber(session_report.start_character_level)
			local max_level = tonumber(experience_settings.max_level)

			if not start_level or not max_level or start_level < max_level then
				return
			end

			local state = identity:xp_bar_state(experience_settings.experience_table, max_level, stash.start_xp, stash.current_xp)

			if not state then
				return
			end

			self._experience_table = state.experience_table
			self._max_level = state.max_level
			self._max_level_experience = state.max_level_experience
			self._current_level = state.current_level
			self._starting_experience = state.starting_experience
			self._experience_for_current_level = state.experience_for_current_level
			self._experience_for_next_level = state.experience_for_next_level

			local widgets_by_name = self._widgets_by_name

			set_widget_text(widgets_by_name and widgets_by_name.current_level_text, "text", tostring(state.current_level))
			set_widget_text(widgets_by_name and widgets_by_name.next_level_text, "text", tostring(state.current_level + 1))
			self:_update_experience_bar(0)

			-- Vanilla hides the "+ XP" chip right after its own initial bar
			-- refresh; our re-drive re-registered it for timed visibility,
			-- which would fade a stray "+ 0" in. Mirror vanilla's end state.
			local gain_widget = widgets_by_name and widgets_by_name.experience_gain

			if gain_widget then
				gain_widget.visible = false
			end

			if self._timed_visibility_widgets then
				self._timed_visibility_widgets.experience_gain = nil
			end
		end)

		return result
	end)
end)

-- Compose the personal and teammate panels after the handler has updated every
-- concrete panel. NumericUI hooks HudElementPersonalPlayerPanel and
-- HudElementTeamPlayerPanel directly; hooking only their shared base class is
-- bypassed when NumericUI loads first because its wrappers retain the old base
-- implementation. The handler is the last common lifecycle point and covers
-- mission, hub, and training-ground panel variants without that load-order gap.
hook_require_once("scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler", function(TeamPanelHandler)
	mod:hook_safe(TeamPanelHandler, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
		guarded("team HUD", function()
			identity:verify_glyphs(ui_renderer)

			if not identity:surface_enabled("team_hud") then
				return
			end

			for _, data in ipairs(self._player_panels_array or {}) do
				local panel = data.panel
				local player = data.player

				if panel and player and not player.__deleted and (not is_own_player(player) or mod:get("show_self") ~= false) then
					local text, record = identity:compose_player_cached(player, "team_hud")
					local prefix = recolor_player_prefix(panel._player_name_prefix, record)
					local widget = panel._widgets_by_name and panel._widgets_by_name.player_name
					local text_style = widget and widget.style and widget.style.text
					local text_size = text_style and text_style.size
					local full = text and (prefix .. text)

					if widget and text_style and full then
						-- In Expeditions the salvage counter (expedition_currency)
						-- sits at x~330 in this 380px panel. When it is showing,
						-- scale the name DOWN so it clears the counter instead of
						-- overrunning it — never truncate. This sets font_size
						-- directly, exactly like the Identity Font Size option; it
						-- does NOT use fit_widget_line / text_fit_with, which
						-- detaches this bottom-aligned row.
						local currency = panel._widgets_by_name.expedition_currency
						local currency_shown = currency and currency.content and currency.content.visible
						local desired = identity_font_size(16)
						local fit_key = tostring(desired) .. "|" .. tostring(currency_shown) .. "|" .. full

						if widget.__syn_name_fit ~= fit_key then
							apply_font_override(widget, "text")

							local font_size = desired

							if currency_shown and rawget(_G, "UIRenderer")
								and type(UIRenderer.scaled_font_size_by_width) == "function" then
								local ok, fitted = pcall(UIRenderer.scaled_font_size_by_width,
									ui_renderer, full, text_style.font_type or "hud_body", desired, 320)

								if ok and tonumber(fitted) then
									font_size = math.max(math.min(tonumber(fitted), desired), 8)
								end
							end

							-- Set both, mirroring apply_font_override (proven safe);
							-- keep the box wide so nothing clips — the smaller font
							-- alone keeps the text left of the counter.
							text_style.font_size = font_size
							text_style.default_font_size = font_size

							if text_size and (text_size[1] or 0) < 700 then
								text_size[1] = 700
							end

							widget.__syn_name_fit = fit_key
							widget.dirty = true
						end

						set_widget_text(widget, "text", full)
					end
				end
			end
		end)
	end)
end)

local ProfileUtils = require("scripts/utilities/profile_utils")
local UISettings = require("scripts/settings/ui/ui_settings")

-- Nameplate markers update every frame, per player, so everything expensive is
-- memoised together: the identity, the account-data read that decides whether
-- titles show, the archetype symbol, the slot color, and vanilla's
-- character_title (a loadout read plus a localization that previously ran sixty
-- times a second per nameplate).
local nameplate_cache = setmetatable({}, { __mode = "k" })

local function build_nameplate_text(player, surface)
	local combat = surface == "nameplate_mission"
	local show_title = true

	if combat then
		local save_data = Managers.save and Managers.save:account_data()
		local interface_settings = save_data and save_data.interface_settings
		local nameplate_type = interface_settings and interface_settings.character_nameplates_in_mission_type

		if nameplate_type == "none" then
			return
		end

		show_title = nameplate_type == "name_and_title"
	end

	local text, record = identity:compose_player_cached(player, surface)

	if not text then
		return nil
	end

	local profile = player:profile()
	local archetype = profile and profile.archetype
	local archetype_name = archetype and archetype.name
	local symbol = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""
	local prefix = symbol .. " "

	if combat or identity:color_selection_active() then
		local slot = player:slot()
		local slot_color = record and record.slot_color
		local color = slot_color and { 255, slot_color[1], slot_color[2], slot_color[3] }
			or UISettings.player_slot_colors[slot]
			or Color.ui_hud_green_light(255, true)

		prefix = "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. symbol .. "{#reset()} "
	end

	if show_title then
		local title = profile and ProfileUtils.character_title(profile)

		if title and title ~= "" then
			text = text .. "\n" .. title
		end
	end

	return prefix .. text
end

local function apply_nameplate(marker, surface)
	if not identity:surface_enabled(surface) then
		return
	end

	local player = marker and marker.data

	if not player or player.__deleted or (player.is_human_controlled and not player:is_human_controlled()) then
		return
	end

	if is_own_player(player) and mod:get("show_self") == false then
		return
	end

	local entry = nameplate_cache[marker]

	-- The surface is part of the key, not just the value: one marker instance is
	-- only ever hub or mission, but keying on it means a template that somehow
	-- served both could never hand back the other context's text.
	if not identity:cache_valid(entry) or entry.surface ~= surface then
		entry = entry or {}
		entry.surface = surface
		entry.text = build_nameplate_text(player, surface)
		nameplate_cache[marker] = identity:cache_stamp(entry)
	end

	if not entry.text then
		return
	end

	-- The write itself still repeats every frame: vanilla rewrites header_text
	-- asynchronously, and set_widget_text compares before touching the widget.
	apply_font_override(marker.widget, "header_text")
	set_widget_text(marker.widget, "header_text", entry.text)
end

-- Which nameplate template belongs to which context. Vanilla already draws a
-- different template in the Mourningstar than in a mission, so the split needs
-- no runtime detection: the template IS the context. That lets the two be
-- configured independently — a bare character name over a teammate's head in a
-- mission, the full dataslate in the hub, or the reverse.
local NAMEPLATE_PATHS = {
	{
		path = "scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate",
		surface = "nameplate_hub",
	},
	{
		path = "scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_party_hud",
		surface = "nameplate_hub",
	},
	{
		path = "scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_combat",
		surface = "nameplate_mission",
	},
}

local function register_nameplate_hook(path, surface)
	hook_require_once(path, function(template)
		mod:hook(template, "update_function", function(func, parent, ui_renderer, widget, marker, template_arg, dt, t)
			local result = func(parent, ui_renderer, widget, marker, template_arg, dt, t)

			guarded("nameplate", function()
				identity:verify_glyphs(ui_renderer)
				apply_nameplate(marker, surface)
			end)

			return result
		end)
	end)
end

for i = 1, #NAMEPLATE_PATHS do
	local config = NAMEPLATE_PATHS[i]

	register_nameplate_hook(config.path, config.surface)
end

-- Pre-mission lobby operative cards.
hook_require_once("scripts/ui/views/lobby_view/lobby_view", function(LobbyView)
	local LOBBY_LINE_WIDTH = 328

	LobbyView.cb_syn_inspect_lobby_slot = function(self, slot)
		if not inspection:surface_enabled("lobby") or not slot or not slot.player then
			return
		end

		-- Unlike vanilla's dormant callback, this does not depend on the lobby's
		-- 3D character unit finishing its spawn. The inventory view owns a separate
		-- profile/package loader and can safely begin as soon as Player:profile()
		-- exists, which is already guaranteed for an occupied card.
		inspection:inspect_player(slot.player, "lobby")
	end

	LobbyView.cb_syn_inspect_focused_lobby_slot = function(self)
		if not inspection:surface_enabled("lobby") then
			return
		end

		local slot_index = self._focused_slot_index
		local loadout_index = self._loadout_widget_navigation_index

		if not slot_index and loadout_index then
			local widgets_per_slot = self._show_weapons and 2 or 3

			slot_index = math.ceil(loadout_index / widgets_per_slot)
		end

		local slot = slot_index and self._spawn_slots and self._spawn_slots[slot_index]

		if slot and slot.occupied then
			self:cb_syn_inspect_lobby_slot(slot)
		end
	end

	local function attach_lobby_inspection(self, slot)
		local widget = slot and slot.panel_widget
		local content = widget and widget.content
		local hotspot = content and content.hotspot
		local enabled = inspection:surface_enabled("lobby")

		if not content or not hotspot then
			return
		end

		content.character_inspect = enabled and mod:localize("inspect_operative") or ""

		if enabled then
			hotspot.pressed_callback = callback(self, "cb_syn_inspect_lobby_slot", slot)
		end
	end

	local function apply_lobby_slot(self, player, slot)
		identity:verify_glyphs(self._ui_renderer)

		if not identity:surface_enabled("lobby") then
			return
		end

		if not player or player.__deleted then
			return
		end

		if is_own_player(player) and mod:get("show_self") == false then
			return
		end

		local record = identity:record_player(player)
		local primary, secondary = identity:compose_split(record, "lobby")
		local widget = slot and slot.panel_widget

		if not widget or not widget.content or not widget.style then
			return
		end

		set_widget_text(widget, "character_name", primary)
		widget.content.guild_name = secondary or ""
		-- Vanilla currently reserves the guild row but never populates it. Use it
		-- as a dedicated identity/progression row and hide its decorative divider,
		-- leaving title and archetype on their own rows below.
		widget.content.has_guild = true

		local style = widget.style

		if style.guild_divider then
			style.guild_divider.color = style.guild_divider.color or { 0, 255, 255, 255 }
			style.guild_divider.color[1] = 0
		end

		if style.character_name and style.character_name.offset then
			style.character_name.offset[2] = 100
		end

		if style.guild_name and style.guild_name.offset then
			style.guild_name.offset[2] = 128
		end

		if style.character_title and style.character_title.offset then
			style.character_title.offset[2] = 153
		end

		if style.character_archetype_title and style.character_archetype_title.offset then
			style.character_archetype_title.offset[2] = 177
		end

		-- The kit rides vanilla's own archetype row rather than adding a fifth.
		local archetype_row = identity:archetype_row(record, "lobby", true)

		if archetype_row then
			widget.content.character_archetype_title = archetype_row
		end

		fit_widget_line(self._ui_renderer, widget, "character_name", primary, identity_font_size(22), LOBBY_LINE_WIDTH, 28)
		fit_widget_line(self._ui_renderer, widget, "guild_name", secondary, identity_font_size(18), LOBBY_LINE_WIDTH, 24)
		fit_widget_line(self._ui_renderer, widget, "character_title", widget.content.character_title, 18, LOBBY_LINE_WIDTH, 24)
		fit_widget_line(self._ui_renderer, widget, "character_archetype_title", widget.content.character_archetype_title, 18, LOBBY_LINE_WIDTH, 23)
		widget.dirty = true
	end

	mod:hook(LobbyView, "_assign_player_to_slot", function(func, self, player, slot)
		local result = func(self, player, slot)

		guarded("mission lobby", function()
			self.__syn_slots = self.__syn_slots or {}
			self.__syn_slots[slot] = player
			self.__syn_revision = mod._identity_revision
			self.__syn_name_poll_ttl = 0.5

			attach_lobby_inspection(self, slot)
			apply_lobby_slot(self, player, slot)
		end)

		return result
	end)

	-- Account names, true levels, and Havoc summaries frequently resolve a few
	-- seconds after the card was assigned. Presence/account updates do not expose
	-- a revision event, so poll the four cards twice per second as well as
	-- reacting immediately to known identity revisions.
	mod:hook_safe(LobbyView, "update", function(self, dt, t, input_service)
		guarded("mission lobby refresh", function()
			if not self.__syn_slots then
				return
			end

			self.__syn_name_poll_ttl = math.max((self.__syn_name_poll_ttl or 0) - dt, 0)

			local revision_changed = self.__syn_revision ~= mod._identity_revision
			local name_poll_due = self.__syn_name_poll_ttl == 0

			if not revision_changed and not name_poll_due then
				return
			end

			self.__syn_revision = mod._identity_revision
			self.__syn_name_poll_ttl = 0.5

			for slot, player in pairs(self.__syn_slots) do
				apply_lobby_slot(self, player, slot)
			end
		end)
	end)
end)

-- The lobby already has gamepad navigation for each player's weapon/talent
-- summary. Add the standard Inspect action while one of those summaries is
-- selected; mouse users inspect by clicking the operative card itself.
hook_require_once("scripts/ui/views/lobby_view/lobby_view_definitions", function(definitions)
	local legend_inputs = definitions.legend_inputs
	local scenegraph = definitions.scenegraph_definition
	local loadout = scenegraph and scenegraph.loadout

	-- The fourth text row now ends near the vanilla loadout origin. Move weapon
	-- and talent summaries down as one scenegraph group so the class label keeps
	-- a full line of breathing room instead of trading one overlap for another.
	if loadout and loadout.position then
		loadout.position[2] = 215
	end

	if legend_inputs then
		legend_inputs[#legend_inputs + 1] = {
			alignment = "right_alignment",
			display_name = "loc_weapon_inventory_inspect_button",
			input_action = "hotkey_item_inspect",
			on_pressed_callback = "cb_syn_inspect_focused_lobby_slot",
			visibility_function = function(parent)
				return inspection:surface_enabled("lobby")
					and not parent._using_cursor_navigation
					and parent._use_gamepad_tooltip_navigation
					and parent._loadout_widget_navigation_index ~= nil
			end,
		}
	end
end)

-- Both Party Finder player rows are 760px wide with their text block starting
-- 180px in (past the portrait), and vanilla leaves the text itself unbounded —
-- so anything longer than the card simply ran off the edge. Listed-group rows
-- can use the remainder; request and preview rows stop short of the right-hand
-- strip our inspect button occupies (40px button at a -140px offset).
local PARTY_LISTED_LINE_WIDTH = 560
local PARTY_REQUEST_LINE_WIDTH = 400

-- Party Finder: own listed-group member cards.
hook_require_once("scripts/ui/views/group_finder_view/group_finder_view", function(GroupFinderView)
	local PlayerCompositions = require("scripts/utilities/players/player_compositions")
	local Text = require("scripts/utilities/ui/text")

	GroupFinderView.cb_syn_inspect_account = function(self, account_id, profile)
		if inspection:surface_enabled("party_finder") and not inspection:other_party_inspector_active() then
			inspection:inspect_account(account_id, "party_finder", profile)
		end
	end

	local function add_inspection_callback(hotspot, account_id, profile)
		if not hotspot or not account_id or not inspection:surface_enabled("party_finder")
			or inspection:other_party_inspector_active() then
			return
		end

		-- A plain closure that calls the inspection module directly — never a
		-- callback bound to an object by method name. Grid blueprints hand us the
		-- ViewElementGrid as "parent", which has no cb_ method, so a name-bound
		-- callback crashed the instant it fired. Re-check the toggles at press
		-- time so a setting changed after the row was built is respected.
		hotspot.pressed_callback = function()
			if inspection:surface_enabled("party_finder") and not inspection:other_party_inspector_active() then
				inspection:inspect_account(account_id, "party_finder", profile)
			end
		end
	end

	local function listed_party_players()
		local players = {}
		local party_players = PlayerCompositions.players("party", {})

		for _, player in pairs(party_players or {}) do
			players[#players + 1] = player
		end

		table.sort(players, function(a, b)
			return (a:name() or "") < (b:name() or "")
		end)

		return players
	end

	mod:hook(GroupFinderView, "_update_listed_group", function(func, self)
		local result = func(self)

		guarded("Party Finder listed inspection", function()
			local players = listed_party_players()

			for i = 1, math.min(#players, 4) do
				local player = players[i]
				local widget = self._widgets_by_name and self._widgets_by_name["team_member_" .. i]
				local content = widget and widget.content

				add_inspection_callback(content and content.hotspot, player:account_id(), player:profile())
			end
		end)

		guarded("Party Finder group identity", function()
			if not identity:surface_enabled("party_finder") then
				return
			end

			identity:verify_glyphs(self._ui_renderer)

			local players = listed_party_players()

			for i = 1, math.min(#players, 4) do
				local player = players[i]
				local widget = self._widgets_by_name and self._widgets_by_name["team_member_" .. i]

				if not (is_own_player(player) and mod:get("show_self") == false) then
					local record = identity:record_player(player)
					local text = identity:compose(record, "party_finder")

					apply_font_override(widget, "character_name")
					set_widget_text(widget, "character_name", text)

					-- The kit rides vanilla's archetype row here too, replacing
					-- a level/Havoc suffix the name row already carries.
					local archetype_row = identity:archetype_row(record, "party_finder", true)

					if archetype_row and widget and widget.content then
						widget.content.character_archetype_title = archetype_row
					end

					-- Vanilla leaves these rows unbounded, so a long identity
					-- line simply ran off the card. Scale to fit instead.
					fit_widget_line(self._ui_renderer, widget, "character_name", text,
						identity_font_size(26), PARTY_LISTED_LINE_WIDTH, 30)
					fit_widget_line(self._ui_renderer, widget, "character_archetype_title",
						widget and widget.content and widget.content.character_archetype_title,
						18, PARTY_LISTED_LINE_WIDTH, 54)
				end
			end
		end)

		return result
	end)

	-- Group previews use the same entry blueprint as join requests, but the
	-- entire preview card is otherwise inert. Make that card the inspect target.
	mod:hook_safe(GroupFinderView, "_populate_preview_grid", function(self)
		guarded("Party Finder preview inspection", function()
			local grid = self._preview_grid
			local widgets = grid and grid:widgets()

			for i = 1, #(widgets or {}) do
				local content = widgets[i].content
				local element = content and content.element

				if element and element.is_preview and element.account_id then
					local profile = element.presence_info and element.presence_info.profile

					add_inspection_callback(content.hotspot, element.account_id, profile)
				end
			end
		end)
	end)

	-- Applicant rows already reserve confirm and special-1 for accept/decline.
	-- Reuse Party Finder's native inspect action for controller/keyboard users;
	-- it is unused while the view is in the advertising state.
	mod:hook(GroupFinderView, "_handle_input", function(func, self, input_service, dt, t)
		if inspection:surface_enabled("party_finder") and not inspection:other_party_inspector_active()
			and not self:using_cursor_navigation() and self._state == "advertising"
			and input_service:get("group_finder_group_inspect") then
			local grid = self._player_request_grid
			local widget = grid and grid:selected_grid_widget()
			local element = widget and widget.content and widget.content.element

			if element and element.account_id then
				self:cb_syn_inspect_account(element.account_id, element.presence_info and element.presence_info.profile)
				return
			end
		end

		return func(self, input_service, dt, t)
	end)

	-- Put the inspect binding beside the native accept binding so gamepad users
	-- are not expected to discover a hidden action.
	mod:hook(GroupFinderView, "_update_player_request_button_accept", function(func, self)
		local result = func(self)

		guarded("Party Finder inspect prompt", function()
			if not inspection:surface_enabled("party_finder") or inspection:other_party_inspector_active() then
				return
			end

			local widget = self._widgets_by_name and self._widgets_by_name.player_request_button_accept
			local inspect_text = Text.add_button_hint(
				"group_finder_group_inspect",
				mod:localize("inspect_loadout"),
				"View",
				Localize("loc_input_legend_text_template"),
				false
			)
			local accept_text = widget and widget.content and widget.content.text

			if not widget or not accept_text or string.find(accept_text, mod:localize("inspect_loadout"), 1, true) then
				return
			end

			local text = accept_text .. "    " .. inspect_text
			local width = self:_text_size(text, widget.style.text, { 1000, 50 })

			widget.content.text = text
			self:_set_scenegraph_size("player_request_button_accept", width + 10)
			self:_set_scenegraph_position("player_request_button_accept", -(width + 40))
			self:_force_update_scenegraph()
		end)

		return result
	end)
end)

-- Party Finder: incoming applicant cards are blueprints rather than a view
-- method, so hook only the specific native entry initializer.
hook_require_once("scripts/ui/views/group_finder_view/group_finder_view_definitions", function(definitions)
	local blueprint = definitions.grid_blueprints and definitions.grid_blueprints.player_request_entry

	if blueprint and blueprint.init then
		local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
		local pass_template = blueprint.pass_template
		local has_inspect_button = false

		for i = 1, #(pass_template or {}) do
			if pass_template[i].style_id == "inspect_hotspot" then
				has_inspect_button = true
				break
			end
		end

		-- The shared style/content ID is an interoperability marker used by
		-- Inspect From Party Finder. Whichever mod loads second sees it and does
		-- not add a duplicate control.
		if not has_inspect_button and not inspection:other_party_inspector_active() then
			local function inspect_visible(content)
				local element = content.element or content.parent and content.parent.element
				local surface_owned = inspection:surface_enabled("party_finder")
					or inspection:other_party_inspector_active()

				return surface_owned
					and element and not element.is_preview
					and Managers.ui:using_cursor_navigation()
			end

			local function inspect_button_change(content, style)
				ButtonPassTemplates.terminal_button_change_function(content, style, "inspect_hotspot")
			end

			pass_template[#pass_template + 1] = {
				content_id = "inspect_hotspot",
				pass_type = "hotspot",
				style_id = "inspect_hotspot",
				content = {},
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					offset = { -140, 0, 8 },
					size = { 40, 40 },
				},
				visibility_function = inspect_visible,
			}
			pass_template[#pass_template + 1] = {
				pass_type = "texture",
				style_id = "syn_inspect_background",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					offset = { -140, 0, 8 },
					size = { 40, 40 },
					default_color = Color.terminal_background(nil, true),
					selected_color = Color.terminal_background_selected(nil, true),
				},
				change_function = inspect_button_change,
				visibility_function = inspect_visible,
			}
			pass_template[#pass_template + 1] = {
				pass_type = "texture",
				style_id = "syn_inspect_icon",
				value = "content/ui/materials/icons/system/escape/party_finder",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					offset = { -140, 0, 10 },
					size = { 40, 40 },
				},
				visibility_function = inspect_visible,
			}
			pass_template[#pass_template + 1] = {
				pass_type = "texture",
				style_id = "syn_inspect_frame",
				value = "content/ui/materials/frames/frame_tile_2px",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					scale_to_material = true,
					offset = { -140, 0, 11 },
					size = { 40, 40 },
					default_color = Color.terminal_frame(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
				},
				change_function = inspect_button_change,
				visibility_function = inspect_visible,
			}
		end

		mod:hook(blueprint, "init", function(func, parent, widget, element, callback_name, secondary_callback_name, ui_renderer)
			local result = func(parent, widget, element, callback_name, secondary_callback_name, ui_renderer)

			guarded("Party Finder request", function()
				local account_id = element and element.account_id
				local profile = element and element.presence_info and element.presence_info.profile
				local inspect_hotspot = widget.content and widget.content.inspect_hotspot

				if inspect_hotspot and account_id and inspection:surface_enabled("party_finder")
					and not inspection:other_party_inspector_active() then
					-- A grid blueprint's "parent" is the ViewElementGrid, not the
					-- view (view_element_grid.lua calls init(self, ...)), so
					-- binding a view method by name here produced a callback to
					-- a method that does not exist and crashed on click. Call
					-- the inspection module directly instead of routing through
					-- any object, and re-check the toggles at press time so a
					-- setting changed after the row was built is respected.
					inspect_hotspot.pressed_callback = function()
						if inspection:surface_enabled("party_finder") and not inspection:other_party_inspector_active() then
							inspection:inspect_account(account_id, "party_finder", profile)
						end
					end
				end

				if identity:surface_enabled("party_finder") then
					identity:verify_glyphs(ui_renderer)

					local social = Managers.data_service and Managers.data_service.social
					local player_info = social and account_id and social:get_player_info_by_account_id(account_id)
					local record = identity:record_player_info(player_info, profile)
					local text = identity:compose(record, "party_finder")

					apply_font_override(widget, "character_name")
					set_widget_text(widget, "character_name", text)

					local archetype_row = identity:archetype_row(record, "party_finder", true)

					if archetype_row and widget.content then
						widget.content.character_archetype_title = archetype_row
					end

					-- These rows reserve the right-hand strip for the inspect
					-- button, so they fit into a narrower line than the listed
					-- group panel above.
					fit_widget_line(ui_renderer, widget, "character_name", text,
						identity_font_size(26), PARTY_REQUEST_LINE_WIDTH, 30)
					fit_widget_line(ui_renderer, widget, "character_archetype_title",
						widget.content and widget.content.character_archetype_title,
						18, PARTY_REQUEST_LINE_WIDTH, 54)
				end
			end)

			return result
		end)
	end
end)

-- New chat messages ask this method for their sender label. Participant
-- matching and moderation continue using vanilla character/account IDs.
hook_require_once("scripts/ui/constant_elements/elements/chat/constant_element_chat", function(ConstantElementChat)
	mod:hook(ConstantElementChat, "_participant_displayname", function(func, self, participant)
		local original = func(self, participant)

		if not identity:surface_enabled("chat") or not participant then
			return original
		end

		return guarded("chat", function()
			local player_info = self:_find_participant_player_info(participant)

			return identity:compose_player_info(player_info, "chat") or original
		end) or original
	end)
end)

-- Combat-feed kill messages. Enemy names and all feed logic remain vanilla.
hook_require_once("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed", function(CombatFeed)
	local Text = require("scripts/utilities/ui/text")

	mod:hook(CombatFeed, "_get_unit_presentation_name", function(func, self, unit)
		if not identity:surface_enabled("combat_feed") then
			return func(self, unit)
		end

		local player_unit_spawn = Managers.state.player_unit_spawn
		local player = player_unit_spawn and unit and player_unit_spawn:owner(unit)

		if not player then
			return func(self, unit)
		end

		if is_own_player(player) and mod:get("show_self") == false then
			return func(self, unit)
		end

		local replacement = guarded("combat feed", function()
			local text = identity:compose_player(player, "combat_feed", { use_colors = false })
			local color = UISettings.player_slot_colors[player:slot()] or Color.ui_hud_green_light(255, true)

			return text and Text.apply_color_to_text(text, color)
		end)

		return replacement or func(self, unit)
	end)
end)

-- Social menu roster. Every roster row's character line funnels through this
-- one formatter (friends, recent players, blocked, invites), so replacing its
-- result covers the whole roster. Vanilla renders the account name on its own
-- separate row in each entry, so the composition is character-only here; the
-- progression suffix (total level, Havoc, shared record) replaces vanilla's
-- capped "name - 30" format. An empty result means an offline friend with no
-- active character, which must stay vanilla's account-only presentation.
hook_require_once("scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup_content_list", function(ContentList)
	mod:hook(ContentList, "from_player_info", function(func, parent, player_info)
		local menu_items, num_menu_items = func(parent, player_info)

		if not inspection:surface_enabled("social") or not player_info then
			return menu_items, num_menu_items
		end

		local profile_ok, profile = pcall(function()
			return player_info:profile()
		end)
		local blocked_ok, blocked = pcall(function()
			return player_info:is_blocked()
		end)
		local available = profile_ok and profile ~= nil and (not blocked_ok or not blocked)
		local list_item = {
			blueprint = available and "button" or "disabled_button_with_explanation",
			callback = callback(parent, "cb_syn_inspect_social_player", player_info),
			is_disabled = not available,
			label = mod:localize("inspect_loadout"),
			reason_for_disabled = available and "" or mod:localize("inspection_unavailable_reason"),
		}

		menu_items[num_menu_items + 1] = list_item

		return menu_items, num_menu_items + 1
	end)
end)

hook_require_once("scripts/ui/views/social_menu_roster_view/social_menu_roster_view", function(SocialMenuRosterView)
	SocialMenuRosterView.cb_syn_inspect_social_player = function(self, player_info)
		if not inspection:surface_enabled("social") then
			return
		end

		self:_close_popup_menu()
		inspection:inspect_player_info(player_info, "social")
	end

	mod:hook(SocialMenuRosterView, "formatted_character_name", function(func, self, player_info)
		local original = func(self, player_info)

		if not identity:surface_enabled("social") or not player_info or original == "" then
			return original
		end

		local replacement = guarded("social menu", function()
			identity:verify_glyphs(self._ui_renderer)

			local own_player = player_info.is_own_player and player_info:is_own_player()

			if own_player and mod:get("show_self") == false then
				return nil
			end

			return identity:compose_player_info(player_info, "social", nil, { name_style = "character" })
		end)

		return replacement or original
	end)
end)

-- Native spectating banner.
hook_require_once("scripts/ui/hud/elements/spectator/hud_element_spectator_text", function(SpectatorText)
	mod:hook(SpectatorText, "update", function(func, self, dt, t, ui_renderer, render_settings, input_service)
		local result = func(self, dt, t, ui_renderer, render_settings, input_service)

		guarded("spectator", function()
			if not identity:surface_enabled("spectator") then
				return
			end

			local player = self._parent and self._parent:player()

			if is_own_player(player) and mod:get("show_self") == false then
				return
			end

			local text = identity:compose_player_cached(player, "spectator")

			if text then
				local widget = self._widgets_by_name.spectating_text

				apply_font_override(widget, "text")
				set_widget_text(widget, "text", Localize("loc_spectator_mode_spectating_player", true, {
					player_name = " " .. text,
				}))
			end
		end)

		return result
	end)
end)

-- Character selection cards. Every card is the local account, so the account
-- name, Havoc rank, and record would repeat identically on each row; compose
-- character + total level only, which also keeps the 36px name row on one
-- line instead of wrapping onto the archetype title below it. The separate
-- archetype line is retained, minus vanilla's now-duplicate level suffix.
hook_require_once("scripts/ui/views/main_menu_view/main_menu_view", function(MainMenuView)
	local function apply_character_card(self, profile, widget)
		identity:verify_glyphs(self._ui_renderer)

		if not identity:surface_enabled("menus") or mod:get("show_self") == false then
			return
		end

		-- Character-select cards are all the local account, so the account name,
		-- Havoc, and record repeat identically on every row; the mod keeps the
		-- name row to character + level by default. "All trackers" opts back in
		-- to Havoc and (when enabled) prestige for players who want the full
		-- dataslate here, matching True Level's character-select behaviour.
		local level_only = mod:get("char_select_all_trackers") ~= true

		set_widget_text(widget, "character_name", identity:compose_local_profile(profile, "menus", {
			name_style = "character",
			level_only = level_only,
		}))
		apply_font_override(widget, "character_name")

		if identity:surface_progression("menus") and widget and widget.content then
			local record = identity:record_local_profile(profile)

			widget.content.character_archetype_title = identity:archetype_row(record, "menus", true)
				or ProfileUtils.character_archetype_title(profile)
		end
	end

	-- This is the first character-select signal fired after the backend profile
	-- list and backend interfaces are both ready. The initial on_enabled fetch can
	-- run before that point and enter its retry delay, leaving every capped card
	-- at level 30 until the Mourningstar. Restart both reads here, using the live
	-- progression interface, and the revision refresh below will recompose every
	-- card as each response arrives.
	mod:hook_safe(MainMenuView, "_event_profiles_changed", function(self)
		guarded("character select progression fetch", function()
			identity:refresh_xp_table(true)
			identity:refresh_progressions(true)
		end)
	end)

	mod:hook(MainMenuView, "_set_player_profile_information", function(func, self, profile, widget)
		local result = func(self, profile, widget)

		guarded("character select", function()
			self.__syn_cards = self.__syn_cards or {}
			self.__syn_cards[widget] = profile
			self.__syn_revision = mod._identity_revision

			apply_character_card(self, profile, widget)
		end)

		return result
	end)

	-- The cards are composed once, but the XP curve, captured progressions,
	-- and Havoc summaries resolve asynchronously afterwards. Reapply when any
	-- identity input changes so the cards never freeze on early estimates.
	mod:hook_safe(MainMenuView, "update", function(self, dt, t, input_service)
		guarded("character select refresh", function()
			if not self.__syn_cards or self.__syn_revision == mod._identity_revision then
				return
			end

			self.__syn_revision = mod._identity_revision

			for widget, profile in pairs(self.__syn_cards) do
				apply_character_card(self, profile, widget)
			end
		end)
	end)
end)

-- End-of-mission lineup. Each of the four native panels is only 440px wide.
-- Keep the selected identity order but split it across vanilla's two name
-- rows, then fit each row to the panel instead of allowing centered text to
-- spill into the neighboring player's column.
hook_require_once("scripts/ui/views/end_view/end_view", function(EndView)
	local END_LINE_WIDTH = 408

	local function apply_end_lineup(self)
		identity:verify_glyphs(self._ui_renderer)

		if not identity:surface_enabled("menus") then
			return
		end

		for _, slot in ipairs(self._spawn_slots or {}) do
			local player_info = slot.player_info
			local widget = slot.widget

			if player_info and widget then
				local own_player = player_info.is_own_player and player_info:is_own_player()

				if not (own_player and mod:get("show_self") == false) then
					local record = identity:record_player_info(player_info)
					local primary, secondary = identity:compose_split(record, "menus")

					set_widget_text(widget, "character_name", primary)

					secondary = secondary or ""

					if widget.content.account_name ~= secondary then
						widget.content.account_name = secondary
					end

					-- Post-game keeps its four native rows; the kit joins the
					-- archetype row rather than adding a fifth.
					local archetype_row = identity:archetype_row(record, "menus", true)

					if archetype_row then
						widget.content.character_archetype_title = archetype_row
					end

					fit_widget_line(self._ui_renderer, widget, "character_name", primary, identity_font_size(24), END_LINE_WIDTH, 30)
					fit_widget_line(self._ui_renderer, widget, "account_name", secondary, identity_font_size(18), END_LINE_WIDTH, 24)
					fit_widget_line(self._ui_renderer, widget, "character_title", widget.content.character_title, 18, END_LINE_WIDTH, 24)
					fit_widget_line(self._ui_renderer, widget, "character_archetype_title", widget.content.character_archetype_title, 18, END_LINE_WIDTH, 24)
					widget.dirty = true
				end
			end
		end
	end

	mod:hook(EndView, "_set_character_names", function(func, self)
		local result = func(self)

		guarded("end screen", function()
			self.__syn_names_set = true
			self.__syn_revision = mod._identity_revision
			self.__syn_name_poll_ttl = 0.5

			apply_end_lineup(self)
		end)

		return result
	end)

	-- The lineup composes while account names, true levels, and Havoc data may
	-- still be resolving (including the just-earned XP the progression refresh
	-- delivers mid-screen). Presence has no name-resolution revision, so use the
	-- same bounded poll as the lobby in addition to normal identity revisions.
	mod:hook_safe(EndView, "update", function(self, dt, t, input_service)
		guarded("end screen refresh", function()
			if not self.__syn_names_set then
				return
			end

			self.__syn_name_poll_ttl = math.max((self.__syn_name_poll_ttl or 0) - dt, 0)

			local revision_changed = self.__syn_revision ~= mod._identity_revision
			local name_poll_due = self.__syn_name_poll_ttl == 0

			if not revision_changed and not name_poll_due then
				return
			end

			self.__syn_revision = mod._identity_revision
			self.__syn_name_poll_ttl = 0.5

			apply_end_lineup(self)
		end)
	end)
end)
