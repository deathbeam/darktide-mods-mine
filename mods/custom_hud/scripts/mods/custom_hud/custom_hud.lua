local mod = get_mod("custom_hud")

-- Cached settings (refreshed on change)
local _cached_opacity = 1

-- Editor overlay-box colours: fill + 4 borders, each in default/hovered/hidden/
-- hidden_hovered states. Resolved once per settings change and baked into the
-- customizer's widget styles at HUD-build time (a colour change triggers a HUD
-- rebuild in on_setting_changed, so the fresh tables are picked up).
local _cached_colors = {}

-- Resolve a "Color name" dropdown + its alpha into a {A,R,G,B} table. Falls back
-- to default_rgb if the stored name is not a live Color.* constructor (e.g. a
-- palette entry removed across a game patch). Runs only on settings change, so
-- the ctor lookup / table alloc here is off the hot path.
local function _get_color_from_setting(setting_id, default_rgb, default_alpha)
    local color_name = mod:get(setting_id)
    if type(color_name) == "string" and color_name ~= "" then
        local ctor = Color[color_name]
        if ctor then
            local color = ctor(255, true)
            if color and #color >= 4 then
                return { default_alpha, color[2], color[3], color[4] }
            end
        end
    end
    return { default_alpha, default_rgb[1], default_rgb[2], default_rgb[3] }
end

local function _refresh_cached_colors()
    -- Fill
    _cached_colors.rect_default = _get_color_from_setting("editor_color_rect_default", {55,55,55}, tonumber(mod:get("editor_color_rect_default_alpha")) or 222)
    _cached_colors.rect_hovered = _get_color_from_setting("editor_color_rect_hovered", {111,222,222}, tonumber(mod:get("editor_color_rect_hovered_alpha")) or 55)
    _cached_colors.rect_hidden = _get_color_from_setting("editor_color_rect_hidden", {0,0,0}, tonumber(mod:get("editor_color_rect_hidden_alpha")) or 0)
    _cached_colors.rect_hidden_hovered = _get_color_from_setting("editor_color_rect_hidden_hovered", {0,0,0}, tonumber(mod:get("editor_color_rect_hidden_hovered_alpha")) or 0)

    -- Top border
    _cached_colors.border_top_default = _get_color_from_setting("editor_color_border_top_default", {155,55,55}, tonumber(mod:get("editor_color_border_top_default_alpha")) or 222)
    _cached_colors.border_top_hovered = _get_color_from_setting("editor_color_border_top_hovered", {255,222,222}, tonumber(mod:get("editor_color_border_top_hovered_alpha")) or 55)
    _cached_colors.border_top_hidden = _get_color_from_setting("editor_color_border_top_hidden", {22,0,0}, tonumber(mod:get("editor_color_border_top_hidden_alpha")) or 111)
    _cached_colors.border_top_hidden_hovered = _get_color_from_setting("editor_color_border_top_hidden_hovered", {55,0,0}, tonumber(mod:get("editor_color_border_top_hidden_hovered_alpha")) or 222)

    -- Bottom border
    _cached_colors.border_bottom_default = _get_color_from_setting("editor_color_border_bottom_default", {88,55,55}, tonumber(mod:get("editor_color_border_bottom_default_alpha")) or 222)
    _cached_colors.border_bottom_hovered = _get_color_from_setting("editor_color_border_bottom_hovered", {155,222,222}, tonumber(mod:get("editor_color_border_bottom_hovered_alpha")) or 55)
    _cached_colors.border_bottom_hidden = _get_color_from_setting("editor_color_border_bottom_hidden", {11,0,0}, tonumber(mod:get("editor_color_border_bottom_hidden_alpha")) or 111)
    _cached_colors.border_bottom_hidden_hovered = _get_color_from_setting("editor_color_border_bottom_hidden_hovered", {22,0,0}, tonumber(mod:get("editor_color_border_bottom_hidden_hovered_alpha")) or 222)

    -- Left border
    _cached_colors.border_left_default = _get_color_from_setting("editor_color_border_left_default", {88,55,55}, tonumber(mod:get("editor_color_border_left_default_alpha")) or 222)
    _cached_colors.border_left_hovered = _get_color_from_setting("editor_color_border_left_hovered", {155,222,222}, tonumber(mod:get("editor_color_border_left_hovered_alpha")) or 55)
    _cached_colors.border_left_hidden = _get_color_from_setting("editor_color_border_left_hidden", {11,0,0}, tonumber(mod:get("editor_color_border_left_hidden_alpha")) or 111)
    _cached_colors.border_left_hidden_hovered = _get_color_from_setting("editor_color_border_left_hidden_hovered", {22,0,0}, tonumber(mod:get("editor_color_border_left_hidden_hovered_alpha")) or 222)

    -- Right border
    _cached_colors.border_right_default = _get_color_from_setting("editor_color_border_right_default", {88,55,55}, tonumber(mod:get("editor_color_border_right_default_alpha")) or 222)
    _cached_colors.border_right_hovered = _get_color_from_setting("editor_color_border_right_hovered", {155,222,222}, tonumber(mod:get("editor_color_border_right_hovered_alpha")) or 55)
    _cached_colors.border_right_hidden = _get_color_from_setting("editor_color_border_right_hidden", {11,0,0}, tonumber(mod:get("editor_color_border_right_hidden_alpha")) or 111)
    _cached_colors.border_right_hidden_hovered = _get_color_from_setting("editor_color_border_right_hidden_hovered", {22,0,0}, tonumber(mod:get("editor_color_border_right_hidden_hovered_alpha")) or 222)
end

-- Base-class draw hooks wrap EVERY hud element's draw (40-60 per frame) and each
-- DMF hook invocation allocates internally, so they are only installed once a
-- non-default opacity is actually observed. DMF hooks can never be removed, only
-- deactivated (deactivated hooks still pay the full chain cost), so installing
-- lazily is the only way to keep the default-opacity case free.
local _draw_hooks_installed = false
local _ensure_draw_hooks

local function _refresh_cached_settings()
    _cached_opacity = tonumber(mod:get("opacity")) or 1
    mod._opacity = _cached_opacity
    _refresh_cached_colors()
    if _ensure_draw_hooks then
        _ensure_draw_hooks()
    end
end

local hud_element_customizer_path = "custom_hud/scripts/mods/custom_hud/hud_element_customizer"

local function _mod_enabled()
    return not mod.is_enabled or mod:is_enabled()
end

local function _remove_custom_hud_entries(elements, visibility_groups, remove_hide_hud)
    if not elements or not visibility_groups then
        return
    end

    local class_name = "HudElementCustomizer"
    local element_index = table.find_by_key(elements, "class_name", class_name)
    while element_index do
        table.remove(elements, element_index)
        element_index = table.find_by_key(elements, "class_name", class_name)
    end

    local visibility_group_index = table.find_by_key(visibility_groups, "name", "custom_hud")
    while visibility_group_index do
        table.remove(visibility_groups, visibility_group_index)
        visibility_group_index = table.find_by_key(visibility_groups, "name", "custom_hud")
    end

    if remove_hide_hud then
        visibility_group_index = table.find_by_key(visibility_groups, "name", "hide_hud")
        while visibility_group_index do
            table.remove(visibility_groups, visibility_group_index)
            visibility_group_index = table.find_by_key(visibility_groups, "name", "hide_hud")
        end
    end
end

local function _clear_runtime_overrides()
    local position_overrides = mod._position_overrides or {}
    for element in pairs(position_overrides) do
        if element then
            element._is_hidden = false
        end
    end

    mod._position_overrides = {}
end

local function ui_hud_init_hook(func, self, elements, visibility_groups, params)
    -- New HUD build = new element instances. Drop references to the old ones so
    -- our bookkeeping tables don't accumulate dead instances across rebuilds.
    -- (Class-level hook tables must persist: those hooks stay installed on the
    -- class and re-hooking would trigger DMF rehook warnings.)
    mod._hooked_elements = {}
    mod._position_overrides = {}

    _remove_custom_hud_entries(elements, visibility_groups)

    if not _mod_enabled() then
        return func(self, elements, visibility_groups, params)
    end

    _remove_custom_hud_entries(elements, visibility_groups, true)

    local class_name = "HudElementCustomizer"
    table.insert(elements, {
        class_name = class_name,
        filename = hud_element_customizer_path,
        use_hud_scale = true,
        visibility_groups = {
            "custom_hud"
        }
    })

    local visibility_group_name = "custom_hud"
    table.insert(visibility_groups, 1, {
        name = visibility_group_name,
        validation_function = function(hud)
            return _mod_enabled() and mod.is_customizing
        end
    })

    visibility_group_name = "hide_hud"
    table.insert(visibility_groups, 2, {
        name = visibility_group_name,
        validation_function = function(hud)
            return _mod_enabled() and mod.is_hud_hidden
        end
    })

    return func(self, elements, visibility_groups, params)
end

mod:add_require_path(hud_element_customizer_path)
mod:hook("UIHud", "init", ui_hud_init_hook)

local function _is_missing_module_error(error_message, filename)
    if not error_message or not filename then
        return false
    end

    return string.find(error_message, "module '" .. filename .. "' not found", 1, true) ~= nil
        or string.find(error_message, "no lua resource '" .. filename, 1, true) ~= nil
end

local function _remove_unloadable_elements(elements)
    if not elements then
        return
    end

    for i = #elements, 1, -1 do
        local element = elements[i]
        local filename = element and element.filename

        if filename then
            local ok, error_message = pcall(require, filename)
            if not ok and _is_missing_module_error(error_message, filename) then
                table.remove(elements, i)
            end
        end
    end
end

local function recreate_hud()
    local managers = rawget(_G, "Managers")
    local ui_manager = managers and managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player_manager = managers.player
            local player = player_manager and player_manager:local_player(1)
            if not player then
                return
            end

            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            _remove_custom_hud_entries(elements, visibility_groups, _mod_enabled())
            _remove_unloadable_elements(elements)
            ui_manager:destroy_player_hud()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

local function reset_hud()
    mod:set("saved_node_settings", {})
    recreate_hud()
end

function mod.on_setting_changed(setting_id)
    _refresh_cached_settings()

    if mod._refresh_panel_font then
        mod._refresh_panel_font()
    end

    -- Editor colours are captured by reference into the overlay-box widget styles
    -- at build time, so a colour/alpha change needs a HUD rebuild to take effect.
    if string.find(setting_id, "editor_color_", 1, true) == 1 then
        if _mod_enabled() then
            recreate_hud()
        end
        return
    end

    if setting_id == "reset_hud" then
        if mod:get("reset_hud") == 1 then
            mod:notify("HUD Reset")
            mod:set("reset_hud", 0)
            reset_hud()
        end
    end
end

function mod.on_all_mods_loaded()
    _refresh_cached_settings()
    if _mod_enabled() then
        recreate_hud()
    end
end

-- NOTE: this MUST keep recreating the HUD on the load-phase call
-- (initial_call). custom_hud is mod id 24 - the first HUD-rebuilding mod in the
-- load order - and recreate_hud's _remove_unloadable_elements strips element
-- definitions left over from the previous session whose require paths are not
-- registered yet (e.g. HudElementSkitarius, id 59). The sanitized list is what
-- every later rebuild (RingHud, id 54) clones and reuses. Skipping this call
-- makes RingHud's rebuild throw inside UIHud:new -> Managers.ui._hud never gets
-- assigned -> the ENTIRE HUD disappears on reload.
function mod.on_enabled(initial_call)
    _refresh_cached_settings()
    recreate_hud()
end

function mod.on_disabled(initial_call)
    mod.is_customizing = false
    mod.is_hud_hidden = false
    _clear_runtime_overrides()
    recreate_hud()
end

function mod:toggle_hud_customization()
    if not _mod_enabled() then
        return
    end

    local ui_manager = Managers.ui
    local view_handler = ui_manager and ui_manager._view_handler
    local view_using_input = view_handler and view_handler:using_input()

    if view_using_input then
        return
    end

    mod.is_customizing = not mod.is_customizing
end

function mod:toggle_hud_hidden()
    if not _mod_enabled() then
        return
    end

    mod.is_hud_hidden = not mod.is_hud_hidden
end

mod:command("reset_hud", "Restores the default HUD.", function()
    reset_hud()
end)

local _ignored_elements = {
    HudElementCrosshair = true,
    HudElementCrosshairHud = true
}

local function draw_hook(func, self, dt, t, ui_renderer, render_settings, input_service)
    -- Fast path first: at default opacity and not hidden there is nothing to do,
    -- so skip the DMF is_enabled() call and the class-name lookup entirely.
    -- (_is_hidden is only ever set on customized elements, which also carry a
    -- per-instance draw hook that suppresses them - this check is a fallback.)
    local opacity = _cached_opacity
    if opacity == 1 and not self._is_hidden then
        return func(self, dt, t, ui_renderer, render_settings, input_service)
    end

    if not _mod_enabled() then
        return func(self, dt, t, ui_renderer, render_settings, input_service)
    end

    if self._is_hidden then
        return
    end

    if opacity ~= 1 and render_settings
        and not _ignored_elements[self.__class_name] and not self._always_full_alpha then
        render_settings.alpha_multiplier = opacity
    end

    return func(self, dt, t, ui_renderer, render_settings, input_service)
end

_ensure_draw_hooks = function()
    if _draw_hooks_installed or _cached_opacity == 1 then
        return
    end
    _draw_hooks_installed = true
    mod:hook(HudElementBase, "draw", draw_hook)
    mod:hook(ConstantElementBase, "draw", draw_hook)
end

-- ============================================================================
-- Position re-pinning
-- ============================================================================
-- Lives in THIS file, not hud_element_customizer.lua: the element file is
-- re-executed by the engine's require on every HUD (re)build, so top-level
-- mod:hook calls there fire repeatedly (rehook warnings, duplicate chain
-- entries per reload). The main script runs once per mod lifecycle.

-- set_scenegraph_position signature differs between game versions (6-arg with
-- alignment vs 4-arg). Latch the working variant on first success instead of
-- re-probing with a failed pcall every call. Latches only on success so a bad
-- scenegraph id doesn't lock in the wrong variant.
local _sg_pos_variant -- nil = not yet detected, 6 or 4 = detected arg count

local function _set_element_sg_position(element, scenegraph_id, x, y, z)
    local v = _sg_pos_variant
    if v == 6 then
        return pcall(element.set_scenegraph_position, element, scenegraph_id, x, y, z, "left", "top")
    elseif v == 4 then
        return pcall(element.set_scenegraph_position, element, scenegraph_id, x, y, z)
    end

    local ok = pcall(element.set_scenegraph_position, element, scenegraph_id, x, y, z, "left", "top")
    if ok then
        _sg_pos_variant = 6
        return true
    end
    ok = pcall(element.set_scenegraph_position, element, scenegraph_id, x, y, z)
    if ok then
        _sg_pos_variant = 4
    end
    return ok
end

-- Exposed for the customizer's apply pass (looked up at call time, so the
-- re-executed element file never captures a stale reference).
mod._set_element_sg_position = _set_element_sg_position

-- Re-pin one element's overridden nodes. Compare-before-set is the
-- load-bearing part: set_scenegraph_position flags _update_scenegraph, which
-- makes the element's next update run a FULL UIScenegraph.update_scenegraph
-- recalc AND set_dirty() over every widget. Positions are mutated in place by
-- the engine, so once pinned the compare holds and the steady-state cost is a
-- few number compares per node. If the element moves the node itself, the
-- compare fails and we re-pin (same one-frame correction as before).
local function _repin_element_nodes(element, nodes)
    local sg = element._ui_scenegraph
    if type(sg) ~= "table" or type(nodes) ~= "table" then
        return
    end

    for sid, pos in pairs(nodes) do
        -- rawget: some scenegraph registries are strict-readonly and ferror on
        -- missing keys (saved layouts can reference nodes from disabled mods).
        local node = rawget(sg, sid)
        local p = node and node.position
        if p and (p[1] ~= pos[1] or p[2] ~= pos[2] or p[3] ~= pos[3]) then
            _set_element_sg_position(element, sid, pos[1], pos[2], pos[3])
        end
    end
end

local function _repin_all_overrides()
    if not _mod_enabled() then
        return
    end

    local overrides = mod._position_overrides
    if overrides then
        for element, entry in pairs(overrides) do
            _repin_element_nodes(element, entry.nodes)
        end
    end
end

-- ONE post-update pass for all customized elements (replaces per-class update
-- hooks: one DMF chain per class per instance per frame). Runs after UIHud has
-- updated every element - the same timing the per-class hooks had.
mod:hook_safe("UIHud", "update", _repin_all_overrides)
-- Constant elements (chat, notification feed, ...) update through their own
-- manager and keep running in menus/loading where UIHud doesn't exist. When
-- both managers tick in the same frame the second pass is all matching
-- compares - effectively free.
mod:hook_safe("UIConstantElements", "update", _repin_all_overrides)

-- NOTE: deliberately no mod.on_unload cleanup of _hooked_elements /
-- _position_overrides. On reload the OLD mod object's hooks stay permanently
-- active and keep running during the next load phase; wiping its bookkeeping
-- made the old HudElementCustomizer re-hook every element instance again
-- (visible in console_logs as custom_hud instance draw hooks appearing BEFORE
-- "Loading mod custom_hud"). Leave the old object's state intact so its
-- handlers stay idempotent.

mod:hook_safe(UIViewHandler, "open_view", function(self, view_name)
    mod.is_customizing = false
end)

mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
    if view_name == "dmf_options_view" or view_name == "options_view" then
        _refresh_cached_settings()
        mod.is_customizing = false
    end
end)

mod._hooked_elements = {}
mod._hooked_element_draw_widgets = {}
mod._position_overrides = {}
-- Plain value read by the customizer's per-instance draw hooks (avoids a
-- function call per customized element per frame).
mod._opacity = 1
-- Editor overlay-box colour cache, consumed by the customizer's box widgets.
-- Populated by _refresh_cached_settings before any HUD (re)build.
mod._cached_colors = _cached_colors
