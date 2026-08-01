-- SMOG_data.lua
local mod = get_mod("SMOG")
local function colour_text(text,colour)
return "{#color(" .. colour .. ")}" .. text .. "{#reset()}"
end
local function heap_size_mb()
local size = 1024
if Application and Application.argv then
local ok,args = pcall(function()
return {Application.argv()}
end)
if ok and args then
for i = 1,#args do
local arg = tostring(args[i])
local inline_size = arg:match("^%-%-lua%-heap%-mb%-size=(%d+)$")
if inline_size then
size = tonumber(inline_size) or size
elseif arg == "--lua-heap-mb-size" and tonumber(args[i + 1]) then
size = tonumber(args[i + 1])
end
end
end
end
return math.floor(size + 0.5)
end
local heap_size_text = colour_text(tostring(heap_size_mb()) .. " MB","255,191,0")
return {
name = mod:localize("mod_name"),
description = mod:localize("mod_description_start") .. " for your " .. heap_size_text .. " sized Lua heap\n" .. mod:localize("mod_description_manual"),
is_togglable = true,
options = {
widgets = {
{
setting_id = "cleaning_permitted",
type = "checkbox",
title = "cleaning_permitted",
default_value = true,
tooltip = "cleaning_permitted_desc",
},
{
setting_id = "auto_clean_on_start",
type = "checkbox",
title = "auto_clean_on_start",
default_value = true,
tooltip = "auto_clean_on_start_desc",
},
{
setting_id = "auto_clean_every_ten_minutes",
type = "checkbox",
title = "auto_clean_every_ten_minutes",
default_value = false,
},
{
setting_id = "notifications",
type = "checkbox",
title = "notifications",
default_value = true,
tooltip = "notifications_desc",
},
{
setting_id = "manual_clear_key",
type = "keybind",
title = "manual_clear_key",
default_value = {"f5"},
tooltip = "manual_clear_key_desc",
keybind_global = true,
keybind_trigger = "pressed",
keybind_type = "function_call",
function_name = "manual_clear",
},
{
setting_id = "notification_y_axis",
type = "numeric",
title = "notification_y_axis",
default_value = 85,
range = {0,100},
decimals_number = 0,
},
{
setting_id = "show_hud_key",
type = "keybind",
title = "show_hud_key",
default_value = {"f8"},
keybind_global = true,
keybind_trigger = "pressed",
keybind_type = "function_call",
function_name = "toggle_hud",
},
{
setting_id = "hud_x_axis",
type = "numeric",
title = "hud_x_axis",
default_value = 5,
range = {0,100},
decimals_number = 0,
},
{
setting_id = "hud_y_axis",
type = "numeric",
title = "hud_y_axis",
default_value = 65,
range = {0,100},
decimals_number = 0,
},
},
},
}