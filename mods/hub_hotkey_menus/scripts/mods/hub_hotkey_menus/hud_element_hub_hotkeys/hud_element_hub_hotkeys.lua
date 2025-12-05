local mod = get_mod("hub_hotkey_menus")

local _definitions = mod:io_dofile("hub_hotkey_menus/scripts/mods/hub_hotkey_menus/hud_element_hub_hotkeys/hud_element_hub_hotkeys_definitions")

local HudElementHubHotkeys = class("HudElementHubHotkeys", "HudElementBase")

function HudElementHubHotkeys:init(parent, draw_layer, start_scale)
    HudElementHubHotkeys.super.init(self, parent, draw_layer, start_scale, _definitions)
    self._visible_entries = {}
    self:_update_visible_entries()
end

function HudElementHubHotkeys:_update_visible_entries()
    local entries_with_keys = {}
    
    for i, entry in ipairs(_definitions.hotkey_entries) do
        local keybind = mod:get(entry.key)
        if keybind and type(keybind) == "table" and #keybind > 0 then
            local key_str = keybind[1]
            if type(key_str) == "string" and key_str ~= "" then
                local keybind_text = key_str:gsub("keyboard_", ""):gsub("mouse_", ""):upper()
                table.insert(entries_with_keys, {
                    index = i,
                    entry = entry,
                    keybind_text = keybind_text,
                    label = mod:localize(entry.key)
                })
            end
        end
    end
    
    table.sort(entries_with_keys, function(a, b)
        return a.keybind_text < b.keybind_text
    end)
    
    self._visible_entries = entries_with_keys
    
    for i = 1, #_definitions.hotkey_entries do
        local widget = self._widgets_by_name["hotkey_entry_" .. i]
        if widget then
            widget.content.visible = false
        end
    end
    
    for display_index, visible_entry in ipairs(self._visible_entries) do
        local widget = self._widgets_by_name["hotkey_entry_" .. visible_entry.index]
        if widget then
            widget.content.keybind_text = visible_entry.keybind_text
            widget.content.label_text = visible_entry.label
            widget.content.visible = true
            
            local y_offset = _definitions.padding + (display_index - 1) * _definitions.entry_height
            widget.style.keybind_text.offset[2] = y_offset
            widget.style.label_text.offset[2] = y_offset
        end
    end
end

function HudElementHubHotkeys:update(dt, t, ui_renderer, render_settings, input_service)
    HudElementHubHotkeys.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

function HudElementHubHotkeys:draw(dt, t, ui_renderer, render_settings, input_service)
    if not mod:get("show_hotkey_list") then
        return
    end
    
    local game_mode_name = Managers.state.game_mode:game_mode_name()
    if game_mode_name ~= "hub" and game_mode_name ~= "shooting_range" then
        return
    end
    
    if game_mode_name == "shooting_range" and not mod:get("enable_in_pykhanium") then
        return
    end
    
    local ui_manager = Managers.ui
    if ui_manager and ui_manager:has_active_view() then
        return
    end
    
    HudElementHubHotkeys.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementHubHotkeys
