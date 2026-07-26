---@class BetterNameplateMod:DMFMod
local mod                              = get_mod("BetterNameplate")
local UISettings                       = require("scripts/settings/ui/ui_settings")
-- Global Cache
local CLASS                            = CLASS
local Managers                         = Managers
local ScriptUnit                       = ScriptUnit

-- Settings
local mod_settings                     = {
    only_icon_in_nameplate                = mod:get("only_icon_in_nameplate"),
    no_icon_in_nameplate                  = mod:get("no_icon_in_nameplate"),
    class_name_in_nameplate               = mod:get("class_name_in_nameplate"),
    only_class_name_in_nameplate          = mod:get("only_class_name_in_nameplate"),
    only_icon_and_class_name_in_nameplate = mod:get("only_icon_and_class_name_in_nameplate"),
    reduce_screen_margin                  = mod:get("reduce_screen_margin"),
    enhanced_distance_scale               = mod:get("enhanced_distance_scale"),
    hide_off_screen_icon                  = mod:get("hide_off_screen_icon"),
    show_in_close_range                   = mod:get("show_in_close_range"),
    show_in_smoke                         = mod:get("show_in_smoke"),
    opacity_normal                        = mod:get("opacity_normal"),
    fade_when_aim                         = mod:get("fade_when_aim"),
    opacity_aim                           = mod:get("opacity_aim"),
    override_font_size                    = mod:get("override_font_size"),
    font_size                             = mod:get("font_size"),
    override_font_type                    = mod:get("override_font_type"),
    font_type                             = mod:get("font_type"),
    override_font_color                   = mod:get("override_font_color"),
    font_color                            = mod:get("font_color"),
}

-- Params
local DEFAULT_PLAYER_SCREEN_MARGINS    = {
    down  = 0.23148148148148148,
    left  = 0.234375,
    right = 0.234375,
    up    = 0.23148148148148148,
}

local DEFAULT_PLAYER_SCALE_SETTINGS    = {
    distance_max = 20,
    distance_min = 10,
    scale_from   = 0.8,
    scale_to     = 1,
}

local DEFAULT_COMPANION_SCREEN_MARGINS = {
    down  = 0.09259259259259259,
    left  = 0.052083333333333336,
    right = 0.052083333333333336,
    up    = 0.09259259259259259,
}

local DEFAULT_COMPANION_SCALE_SETTINGS = {
    distance_max = 100,
    distance_min = 10,
    scale_from   = 0.8,
    scale_to     = 1,
}

local screen_margins                   = {
    down  = 0.09,
    left  = 0.05,
    right = 0.05,
    up    = 0.09,
}

local scale_settings                   = {
    distance_max = 25,
    distance_min = 0,
    scale_from   = 0.5,
    scale_to     = 1,
}

local is_in_hub                        = true
local alternate_fire_component         = nil
local nameplate_combat_template        = nil
local nameplate_companion_template     = nil
local reset_nameplate                  = false

local player_icon                      = ""
local companion_icon                   = ""

local function get_player_data_extension()
    local player = Managers.player:local_player_safe(1)
    return player and ScriptUnit.extension(player.player_unit, "unit_data_system")
end
local function init_components(player_data_extension)
    player_data_extension = player_data_extension or get_player_data_extension()
    if not player_data_extension then
        return
    end

    alternate_fire_component = player_data_extension:read_component("alternate_fire")
end

local function reset_components()
    alternate_fire_component = nil
end

local function check_is_in_hub()
    local gameModeManager = Managers.state.game_mode
    is_in_hub = gameModeManager and (gameModeManager:is_social_hub() or gameModeManager:is_prologue_hub())
end

local function reset_params()
    is_in_hub = true
    reset_nameplate = false
end

local function recreate_hud()
    local ui_manager = Managers.ui
    if not ui_manager then
        return
    end

    local hud = ui_manager._hud
    if not hud then
        return
    end

    local player = Managers.player:local_player(1)
    local peer_id = player:peer_id()
    local local_player_id = player:local_player_id()
    local elements = hud._element_definitions
    local visibility_groups = hud._visibility_groups

    ui_manager:destroy_player_hud()
    ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
end

local function no_icon_in_nameplate(marker, content, type)
    local data = marker.data
    local profile = data:profile()
    local archetype = profile and profile.archetype
    local archetype_name = archetype and archetype.name
    local class_icon = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""

    if type == "player" then
        content.header_text = content.header_text:gsub(player_icon, "")
        content.header_text = content.header_text:gsub(class_icon, "")
    elseif type == "companion" then
        content.header_text = content.header_text:gsub(companion_icon, "")
    end
end

local function class_name_in_nameplate(marker, content, type)
    if type == "player" then
        local data = marker.data
        local profile = data:profile()
        local archetype = profile and profile.archetype
        local archetype_name = archetype and archetype.name
        local class_icon = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""
        local loc_archetype_name = archetype and archetype.archetype_name
        local class_name = loc_archetype_name and Localize(loc_archetype_name)
        if class_name then
            content.header_text = content.header_text:gsub(player_icon, class_name)
            content.header_text = content.header_text:gsub(class_icon, class_name)
        end
    elseif type == "companion" then
        local cyber_mastiff_name = mod:localize("loc_cyber_mastiff")
        if cyber_mastiff_name then
            content.header_text = content.header_text:gsub(companion_icon, cyber_mastiff_name)
        end
    end
end

local function only_class_name_in_nameplate(marker, content, type)
    if type == "player" then
        local data = marker.data
        local profile = data:profile()
        local archetype = profile and profile.archetype
        local archetype_name = archetype and archetype.name
        local class_icon = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""
        local loc_archetype_name = archetype and archetype.archetype_name
        local class_name = loc_archetype_name and Localize(loc_archetype_name)
        if class_name then
            content.header_text = content.icon_text
            content.header_text = content.header_text:gsub(player_icon, class_name)
            content.header_text = content.header_text:gsub(class_icon, class_name)
        end
    elseif type == "companion" then
        local cyber_mastiff_name = mod:localize("loc_cyber_mastiff")
        if cyber_mastiff_name then
            content.header_text = content.icon_text
            content.header_text = content.header_text:gsub(companion_icon, cyber_mastiff_name)
        end
    end
end

local function only_icon_and_class_name_in_nameplate(marker, content, type)
    if type == "player" then
        local data = marker.data
        local profile = data:profile()
        local archetype = profile and profile.archetype
        local archetype_name = archetype and archetype.name
        local class_icon = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""
        local loc_archetype_name = archetype and archetype.archetype_name
        local class_name = loc_archetype_name and Localize(loc_archetype_name)
        if class_name then
            content.header_text = content.icon_text
            content.header_text = content.header_text:gsub(player_icon, player_icon .. " " .. class_name)
            content.header_text = content.header_text:gsub(class_icon, class_icon .. " " .. class_name)
        end
    elseif type == "companion" then
        local cyber_mastiff_name = mod:localize("loc_cyber_mastiff")
        if cyber_mastiff_name then
            content.header_text = content.icon_text
            content.header_text = content.header_text:gsub(companion_icon, companion_icon .. " " .. cyber_mastiff_name)
        end
    end
end

local function override_font_style(style)
    if mod_settings.override_font_size then
        style.header_text.default_font_size = mod_settings.font_size
    end
    if mod_settings.override_font_type then
        style.header_text.font_type = mod_settings.font_type
    end
    if mod_settings.override_font_color then
        style.header_text.text_color = Color[mod_settings.font_color](255, true)
    end
end

local function on_marker_enter(widget, marker, type)
    local content = widget.content
    local style = widget.style
    if mod_settings.only_icon_in_nameplate then
        content.header_text = content.icon_text
        style.header_text.default_font_size = 32
    else
        if mod_settings.no_icon_in_nameplate then
            no_icon_in_nameplate(marker, content, type)
        elseif mod_settings.class_name_in_nameplate then
            class_name_in_nameplate(marker, content, type)
        elseif mod_settings.only_class_name_in_nameplate then
            only_class_name_in_nameplate(marker, content, type)
        elseif mod_settings.only_icon_and_class_name_in_nameplate then
            only_icon_and_class_name_in_nameplate(marker, content, type)
        end
        override_font_style(style)
    end
end

local function on_marker_update(widget, marker)
    if not marker.draw then
        return
    end

    local style = widget.style
    local icon_text_color = style.icon_text.text_color
    local arrow_color = style.arrow.color
    if mod_settings.hide_off_screen_icon then
        icon_text_color[1] = 0
        arrow_color[1] = 0
    elseif mod_settings.show_in_close_range then
        local content = widget.content
        local edge_clamp_progress = content.edge_clamp_progress
        local clamped_alpha = 255 - 255 * edge_clamp_progress
        icon_text_color[1] = clamped_alpha
        arrow_color[1] = clamped_alpha
    end
    local opacity = mod_settings.fade_when_aim
        and alternate_fire_component
        and alternate_fire_component.is_active
        and mod_settings.opacity_aim
        or mod_settings.opacity_normal
    local header_text_color = style.header_text.text_color
    local default_header_text_color = style.header_text.default_text_color
    header_text_color[1] = default_header_text_color[1] * opacity
    icon_text_color[1] = icon_text_color[1] * opacity
    arrow_color[1] = arrow_color[1] * opacity
end

mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_combat",
    function(instance)
        nameplate_combat_template = instance
        if mod_settings.reduce_screen_margin then
            instance.screen_margins = screen_margins
        end
        if mod_settings.enhanced_distance_scale then
            instance.scale_settings = scale_settings
        end
        mod:hook_safe(instance, "on_enter",
            function(widget, marker)
                on_marker_enter(widget, marker, "player")
            end)
        mod:hook_safe(instance, "update_function",
            function(parent, ui_renderer, widget, marker, template, dt, t)
                on_marker_update(widget, marker)
            end)
    end
)

mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_companion",
    function(instance)
        nameplate_companion_template = instance
        if mod_settings.reduce_screen_margin then
            instance.screen_margins = screen_margins
        end
        if mod_settings.enhanced_distance_scale then
            instance.scale_settings = scale_settings
        end
        mod:hook_safe(instance, "on_enter",
            function(widget, marker)
                on_marker_enter(widget, marker, "companion")
                if mod_settings.only_icon_in_nameplate or mod_settings.no_icon_in_nameplate or mod_settings.class_name_in_nameplate or mod_settings.only_class_name_in_nameplate or mod_settings.only_icon_and_class_name_in_nameplate then
                    Managers.event:unregister(marker, "event_update_player_name")
                end
            end)
        mod:hook_safe(instance, "update_function",
            function(parent, ui_renderer, widget, marker, template, dt, t)
                on_marker_update(widget, marker)
            end)
    end
)

-- disable smoke hide nameplates debuff check
mod:hook(CLASS.PlayerUnitBuffExtension, "has_keyword",
    function(func, self, keyword)
        if mod_settings.show_in_smoke and self._player.viewport_name == "player1" and keyword == "hud_nameplates_disabled" then
            return false
        end

        return func(self, keyword)
    end
)

mod.on_enabled            = function()
    check_is_in_hub()
    init_components()
end

--  Mod Disabled
mod.on_disabled           = function()
    reset_components()
end

mod.on_all_mods_loaded    = function()
    local true_level = get_mod("true_level")
    if true_level then
        mod:hook(true_level, "is_enabled_feature",
            function(func, ref, ...)
                if mod_settings.only_icon_in_nameplate and ref == "nameplate" and not is_in_hub then
                    return false
                end

                return func(ref, ...)
            end)
    end
    local who_are_you = get_mod("who_are_you")
    if who_are_you then
        mod:hook_safe(CLASS.HudElementWorldMarkers, "_calculate_markers", function(self)
            if not mod_settings.only_icon_in_nameplate and not mod_settings.no_icon_in_nameplate and not mod_settings.class_name_in_nameplate and not mod_settings.only_class_name_in_nameplate and not mod_settings.only_icon_and_class_name_in_nameplate then
                return
            end

            local markers = self._markers_by_type["nameplate_party"]
            if not markers then
                return
            end

            for i = 1, #markers do
                local marker = markers[i]
                local widget = marker.widget
                local content = widget.content
                local style = widget.style
                if mod_settings.only_icon_in_nameplate then
                    content.header_text = content.icon_text
                    style.header_text.default_font_size = 32
                elseif mod_settings.no_icon_in_nameplate then
                    no_icon_in_nameplate(marker, content, "player")
                elseif mod_settings.class_name_in_nameplate then
                    class_name_in_nameplate(marker, content, "player")
                elseif mod_settings.only_class_name_in_nameplate then
                    only_class_name_in_nameplate(marker, content, "player")
                elseif mod_settings.only_icon_and_class_name_in_nameplate then
                    only_icon_and_class_name_in_nameplate(marker, content, "player")
                end
            end
        end)
    end
end

mod.on_setting_changed    = function(setting_id)
    local result = mod:get(setting_id)
    mod_settings[setting_id] = result
    reset_nameplate = true
    if setting_id == "reduce_screen_margin" then
        if nameplate_combat_template then
            nameplate_combat_template.screen_margins = result and screen_margins or DEFAULT_PLAYER_SCREEN_MARGINS
        end
        if nameplate_companion_template then
            nameplate_companion_template.screen_margins = result and screen_margins or DEFAULT_COMPANION_SCREEN_MARGINS
        end
    elseif setting_id == "enhanced_distance_scale" then
        if nameplate_combat_template then
            nameplate_combat_template.scale_settings = result and scale_settings or DEFAULT_PLAYER_SCALE_SETTINGS
        end
        if nameplate_companion_template then
            nameplate_companion_template.scale_settings = result and scale_settings or DEFAULT_COMPANION_SCALE_SETTINGS
        end
    elseif setting_id == "only_icon_in_nameplate" then
        if result then
            mod:set("no_icon_in_nameplate", false, true)
            mod:set("class_name_in_nameplate", false, true)
            mod:set("only_class_name_in_nameplate", false, true)
            mod:set("only_icon_and_class_name_in_nameplate", false, true)
        end
    elseif setting_id == "no_icon_in_nameplate" then
        if result then
            mod:set("only_icon_in_nameplate", false, true)
            mod:set("class_name_in_nameplate", false, true)
            mod:set("only_class_name_in_nameplate", false, true)
            mod:set("only_icon_and_class_name_in_nameplate", false, true)
        end
    elseif setting_id == "class_name_in_nameplate" then
        if result then
            mod:set("only_icon_in_nameplate", false, true)
            mod:set("no_icon_in_nameplate", false, true)
            mod:set("only_class_name_in_nameplate", false, true)
            mod:set("only_icon_and_class_name_in_nameplate", false, true)
        end
    elseif setting_id == "only_class_name_in_nameplate" then
        if result then
            mod:set("only_icon_in_nameplate", false, true)
            mod:set("no_icon_in_nameplate", false, true)
            mod:set("class_name_in_nameplate", false, true)
            mod:set("only_icon_and_class_name_in_nameplate", false, true)
        end
    elseif setting_id == "only_icon_and_class_name_in_nameplate" then
        if result then
            mod:set("only_icon_in_nameplate", false, true)
            mod:set("no_icon_in_nameplate", false, true)
            mod:set("class_name_in_nameplate", false, true)
            mod:set("only_class_name_in_nameplate", false, true)
        end
    end
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "GameplayStateRun" then
        if status == "enter" then
            check_is_in_hub()
        elseif status == "exit" then
            reset_params()
        end
    end
end

mod:hook_safe(CLASS.PlayerUnitDataExtension, "init",
    function(self)
        if self._player.viewport_name == "player1" then
            init_components(self)
        end
    end)

mod:hook_safe(CLASS.PlayerUnitDataExtension, "destroy",
    function(self)
        if self._player.viewport_name == "player1" then
            reset_components()
        end
    end)

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, force_close)
    if view_name == "dmf_options_view" and reset_nameplate then
        recreate_hud()
        reset_nameplate = false
    end
end)
