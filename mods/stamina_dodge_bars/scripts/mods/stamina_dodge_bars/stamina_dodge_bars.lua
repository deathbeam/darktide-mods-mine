-- Stamina & Dodge Bars
-- Dodge-counting logic ported from "Show Remaining Dodges" by mrouzon (contributors: FELITH,
-- xsSplater, deluxghost). Bar rendering / orientation ported from "Keystone & Blitz Bars".
-- Stamina recolouring approach based on "Color My Stamina" by Miles/Burzah.

local mod = get_mod("stamina_dodge_bars")

-- ##################################################
-- Dodge state (updated by the hooks below, read by the dodge HUD element)
-- ##################################################

mod._dodging = false                              -- between entering and exiting a dodge state
mod._waiting_for_dodge_effectiveness_reset = false
mod._draw_widget = false
mod._effective_dodges = 0                         -- max effective dodges with the wielded weapon
mod._effective_dodges_left = nil                  -- remaining effective dodges (can go negative)
mod._consecutive_dodges_cooldown = 0.0
mod._unified_t = 0.0
mod._last_dodge_enter_t = 0.0
mod._unit = nil

-- ##################################################
-- Settings cache
-- ##################################################

local function resolve_text_color(name, fallback)
	local fn = name and Color[name] or Color[fallback]
	if fn then return fn(255, true) end
	return { 255, 255, 255, 255 }
end

mod.refresh_settings = function()
	mod._dodge_show          = mod:get("dodge_show")
	mod._dodge_always_show   = mod:get("dodge_always_show")
	mod._dodge_fade_speed    = mod:get("dodge_fade_speed") or 4
	mod._dodge_show_negative = mod:get("dodge_show_negative")
	mod._dodge_show_counter  = mod:get("dodge_show_counter")
	mod._dodge_show_name     = mod:get("dodge_show_name")

	mod._stamina_show            = mod:get("stamina_show")
	mod._stamina_show_percentage = mod:get("stamina_show_percentage")
	mod._stamina_show_name       = mod:get("stamina_show_name")
	mod._stamina_always_show     = mod:get("stamina_always_show")
	mod._hide_vanilla            = mod:get("hide_vanilla")

	-- Shared gauge text/bracket colors (applied live by both elements each frame).
	mod._value_text_color = resolve_text_color(mod:get("value_text_color"), "ui_blue_light")
	mod._gauge_color      = resolve_text_color(mod:get("gauge_color"), "terminal_text_body")
end
mod.refresh_settings()

-- ##################################################
-- HUD element registration
-- ##################################################

local sdb_hud_elements = {
	{
		use_hud_scale = true,
		class_name = "HudElementSdbStamina",
		filename = "stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_stamina",
		visibility_groups = { "alive", "communication_wheel" }
	},
	{
		use_hud_scale = true,
		class_name = "HudElementSdbDodge",
		filename = "stamina_dodge_bars/scripts/mods/stamina_dodge_bars/hud/hud_element_sdb_dodge",
		visibility_groups = { "alive", "communication_wheel" }
	}
}

for _, element in ipairs(sdb_hud_elements) do
	mod:add_require_path(element.filename)
end

mod:hook(CLASS.UIHud, "init", function(func, self, elements, visibility_groups, params, ...)
	for _, element in ipairs(sdb_hud_elements) do
		if not table.find_by_key(elements, "class_name", element.class_name) then
			table.insert(elements, element)
		end
	end
	return func(self, elements, visibility_groups, params, ...)
end)

-- Hide the vanilla stamina element (which also carries the vanilla dodge counter) when enabled.
-- _draw_widgets covers the frame/text/dodge-counter; _draw_stamina_chunks covers the bar fill
-- (the method Color My Stamina also hooks) in case it is drawn outside _draw_widgets.
mod:hook("HudElementStamina", "_draw_widgets", function(func, self, ...)
	if mod._hide_vanilla then return end
	return func(self, ...)
end)

mod:hook("HudElementStamina", "_draw_stamina_chunks", function(func, self, ...)
	if mod._hide_vanilla then return end
	return func(self, ...)
end)

-- Robust fallback: force the vanilla stamina-bar widget invisible every frame while hiding, in
-- case a game/mod version draws the fill through a path the two draw-hooks above don't cover.
mod:hook_safe("HudElementStamina", "update", function(self, ...)
	if not mod._hide_vanilla then return end
	local widgets = self._widgets_by_name
	if widgets and widgets.stamina_bar then
		widgets.stamina_bar.visible = false
	end
end)

-- In current game versions the vanilla dodge counter is its OWN element (HudElementDodgeCounter),
-- not part of HudElementStamina, so hide it separately. (No-op on versions without this class.)
mod:hook("HudElementDodgeCounter", "_draw_widgets", function(func, self, ...)
	if mod._hide_vanilla then return end
	return func(self, ...)
end)

local function recreate_hud()
	local ui_manager = Managers.ui
	if not ui_manager then return end
	local hud = ui_manager._hud
	if not hud then return end

	local player = Managers.player:local_player(1)
	if not player then return end

	local peer_id = player:peer_id()
	local local_player_id = player:local_player_id()
	local elements = hud._element_definitions
	local visibility_groups = hud._visibility_groups

	hud:destroy()
	ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
end
mod.recreate_hud = recreate_hud

-- The bars are mission-only; suppress them in the Mourningstar / prologue hub.
mod._is_in_hub = function()
	local gm = Managers.state and Managers.state.game_mode
	local name = gm and gm:game_mode_name()
	return name == "hub" or name == "prologue_hub"
end

mod.reset_logic_variables = function()
	mod._dodging = false
	mod._waiting_for_dodge_effectiveness_reset = false
	mod._draw_widget = false
	mod._effective_dodges = 0
	mod._effective_dodges_left = nil
	mod._consecutive_dodges_cooldown = 0.0
	mod._unified_t = 0.0
	mod._last_dodge_enter_t = 0.0
	mod._unit = nil
end

function mod.on_all_mods_loaded()
	mod.refresh_settings()
	recreate_hud()
end

function mod.on_unload(exit_game)
end

mod.on_setting_changed = function(id)
	mod.refresh_settings()
	-- Orientation / visibility changes need the element rebuilt to re-anchor cleanly.
	if id == "dodge_orientation" or id == "dodge_show"
		or id == "stamina_orientation" or id == "stamina_show" then
		recreate_hud()
	end
end

-- ##################################################
-- Dodge logic (ported from Show Remaining Dodges)
-- ##################################################

local function _get_weapon_dodge_template(unit)
	local weapon_system = ScriptUnit.has_extension(unit, "weapon_system")
	if not weapon_system then return end
	return weapon_system:dodge_template()
end

local function _compute_effective_dodges(unit, buff_extension)
	local weapon_dodge_template = _get_weapon_dodge_template(unit)
	local extra = buff_extension and math.round(buff_extension:stat_buffs().extra_consecutive_dodges or 0) or 0
	return math.ceil((weapon_dodge_template and weapon_dodge_template.diminishing_return_start or 2) + extra)
end

local function _local_player_unit()
	local player = Managers.player and Managers.player:local_player(1)
	return player and player.player_unit
end

-- Establish the dodge count for the LOCAL player as soon as a weapon with a dodge template is
-- available, so the "always show" dodge bar appears from mission start instead of only after the
-- first dodge/slide/weapon-swap (which is when the hooks below first ran). Called every frame from
-- the dodge element; it no-ops once a count exists, and the hooks keep it current afterwards.
mod.ensure_effective_dodges = function()
	if mod._effective_dodges and mod._effective_dodges > 0 then
		return
	end

	local unit = _local_player_unit()
	if not unit then return end

	local weapon_system = ScriptUnit.has_extension(unit, "weapon_system")
	if not weapon_system or not weapon_system:dodge_template() then
		return
	end

	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	mod._unit = unit
	mod._effective_dodges = _compute_effective_dodges(unit, buff_extension)
	if not mod._effective_dodges_left then
		mod._effective_dodges_left = mod._effective_dodges
	end
end

local function _on_dodge_exit(self)
	mod._dodging = false
	mod._waiting_for_dodge_effectiveness_reset = true

	local weapon_dodge_template = self._weapon_extension:dodge_template()
	local base_dodge_template = self._archetype_dodge_template
	local weapon_consecutive_dodges_reset = weapon_dodge_template and weapon_dodge_template.consecutive_dodges_reset or 0
	local stat_buffs = self._buff_extension:stat_buffs()
	local buff_modifier = stat_buffs.dodge_cooldown_reset_modifier
	local buff_dodge_cooldown_reset_modifier = buff_modifier and 1 - (buff_modifier - 1) or 1
	local cooldown = (base_dodge_template.consecutive_dodges_reset + weapon_consecutive_dodges_reset) * buff_dodge_cooldown_reset_modifier

	mod._consecutive_dodges_cooldown = mod._unified_t + cooldown
end

local function _reset_dodges_trait_proc_func(params, template_data, template_context)
	local dodge_write_component = template_data.dodge_write_component
	dodge_write_component.consecutive_dodges = 0
	mod._effective_dodges_left = mod._effective_dodges
end

-- Recompute on weapon swap
mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, t, skip_wield_action)
	-- This hook also fires for bot players on the client; only react to the local player's swaps,
	-- or a bot's buff extension would overwrite the local dodge count (now that it's set at spawn).
	if self._player ~= (Managers.player and Managers.player:local_player(1)) then return end
	if not mod._unit then return end

	local old_effective_dodges = mod._effective_dodges
	mod._effective_dodges = _compute_effective_dodges(mod._unit, self._buff_extension)

	if mod._effective_dodges_left then
		mod._effective_dodges_left = mod._effective_dodges_left + (mod._effective_dodges - old_effective_dodges)
	end
end)

-- Dodge start: flags + decrement remaining
mod:hook_safe("PlayerCharacterStateDodging", "on_enter", function(self, unit, dt, t, previous_state, params)
	-- Band-aid: the game can enter the dodging state multiple times in one frame.
	if t - mod._last_dodge_enter_t < 0.05 then return end
	mod._last_dodge_enter_t = t

	mod._dodging = true
	mod._draw_widget = true
	mod._unit = unit

	mod._effective_dodges = _compute_effective_dodges(unit, self._buff_extension)

	if not mod._waiting_for_dodge_effectiveness_reset then
		mod._effective_dodges_left = mod._effective_dodges
	end
	mod._effective_dodges_left = (mod._effective_dodges_left or mod._effective_dodges) - 1
end)

-- Slide-dodging / sprint-slides pause the dodge cooldown
mod:hook_safe("PlayerCharacterStateSliding", "on_enter", function(self, unit, dt, t, previous_state, params)
	if t - mod._last_dodge_enter_t < 0.05 then return end
	mod._last_dodge_enter_t = t

	mod._dodging = true
	mod._unit = unit
	mod._effective_dodges = _compute_effective_dodges(unit, self._buff_extension)

	if mod._waiting_for_dodge_effectiveness_reset and previous_state == "dodging" then
		mod._effective_dodges_left = (mod._effective_dodges_left or mod._effective_dodges) - 1
	end

	if not mod._effective_dodges_left then
		mod._effective_dodges_left = mod._effective_dodges
	end
end)

mod:hook_safe("PlayerCharacterStateDodging", "on_exit", function(self, unit, t, next_state)
	_on_dodge_exit(self)
end)

mod:hook_safe("PlayerCharacterStateSliding", "on_exit", function(self, unit, t, next_state)
	_on_dodge_exit(self)
end)

-- 'Agile' weapon trait support (weakspot hit resets dodge count)
mod:hook_require("scripts/settings/buff/buff_templates", function(templates)
	if templates.weapon_trait_bespoke_combatsword_p3_weakspot_hit_resets_dodge_count then
		templates.weapon_trait_bespoke_combatsword_p3_weakspot_hit_resets_dodge_count.proc_func = _reset_dodges_trait_proc_func
	end
	if templates.weapon_trait_bespoke_combataxe_p2_weakspot_hit_resets_dodge_count then
		templates.weapon_trait_bespoke_combataxe_p2_weakspot_hit_resets_dodge_count.proc_func = _reset_dodges_trait_proc_func
	end
end)

mod:hook_safe("StateGameplay", "on_exit", function(self, on_shutdown)
	mod.reset_logic_variables()
end)

-- ##################################################
-- Debug: dump HUD element class names (used to locate the vanilla stamina/dodge element to hide)
-- ##################################################

mod:command("sdb_dump_hud", "List HUD element class names", function()
	local hud = Managers.ui and Managers.ui._hud
	if not hud then
		mod:echo("[SDB] no hud")
		return
	end
	local names = {}
	for _, def in pairs(hud._element_definitions or {}) do
		names[#names + 1] = tostring(def.class_name)
	end
	table.sort(names)
	mod:echo("[SDB] HUD elements: " .. table.concat(names, ", "))
end)
