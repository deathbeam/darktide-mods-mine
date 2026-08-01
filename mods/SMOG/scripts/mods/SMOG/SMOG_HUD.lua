-- SMOG_HUD.lua
local mod = get_mod("SMOG")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local Managers = Managers
local Gui = Gui
local Color = Color
local Vector2 = Vector2
local Vector3 = Vector3
local Rotation2D = Rotation2D
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP
local pcall = pcall
local type = type
local math = math
local math_sin = math.sin
local math_cos = math.cos
local math_floor = math.floor
local math_abs = math.abs
local math_max = math.max
local math_pi = math.pi
local math_sqrt = math.sqrt
local math_atan2 = math.atan2 or math.atan
local string_format = string.format
local meter_bounds_width = 184
local meter_bounds_height = 222
local notice_bounds_width = 720
local notice_bounds_height = 48
local definitions = {
scenegraph_definition = {
screen = UIWorkspaceSettings.screen,
smog_root = {
parent = "screen",
size = {
meter_bounds_width,
meter_bounds_height,
},
horizontal_alignment = "left",
vertical_alignment = "top",
position = {
0,
0,
900,
},
},
smog_notice = {
parent = "screen",
size = {
notice_bounds_width,
notice_bounds_height,
},
horizontal_alignment = "left",
vertical_alignment = "top",
position = {
0,
0,
900,
},
},
},
widget_definitions = {},
}
local refresh_interval = 0.5
local draw_fail_backoff = 120
local arc_segments = 96
local circle_segments = 16
local meter_text = "SMOG METER"
local label_text = "SMOG"
local font_path_cache = {}
local meter_text_width_cache = {}
local function clamp(value,low,high)
if value < low then
return low
elseif value > high then
return high
end
return value
end
local function current_time()
local time_manager = Managers and Managers.time
if time_manager and time_manager.time then
local ok,value = pcall(time_manager.time,time_manager,"main")
if ok and value then
return value
end
end
return 0
end
local function colour(alpha,r,g,b)
return Color(alpha,math_floor(r + 0.5),math_floor(g + 0.5),math_floor(b + 0.5))
end
local function phase_for_percent(percent)
if percent <= 0.2 then
return 0,205,201,197
elseif percent <= 16 then
return 16,86,190,40
elseif percent <= 32 then
return 32,130,225,65
elseif percent <= 50 then
return 50,186,225,58
elseif percent <= 66 then
return 66,250,207,76
elseif percent <= 83 then
return 83,238,126,52
end
return 100,235,54,38
end
local function point_on_arc(cx,cy,radius,theta)
return cx + radius * math_cos(theta),cy - radius * math_sin(theta)
end
local function font_path(font_type)
local cached = font_path_cache[font_type]
if cached then
return cached
end
local font_manager = Managers and Managers.font
if not font_manager or not font_manager.data_by_type then
return nil
end
local ok,font_data = pcall(font_manager.data_by_type,font_manager,font_type)
if ok and font_data and font_data.path then
font_path_cache[font_type] = font_data.path
return font_data.path
end
ok,font_data = pcall(font_manager.data_by_type,font_manager,"arial")
if ok and font_data and font_data.path then
font_path_cache[font_type] = font_data.path
return font_data.path
end
return nil
end
local function text_width(gui,text,font,font_size)
if Gui and Gui.slug_text_extents then
local ok,min,max = pcall(Gui.slug_text_extents,gui,text,font,font_size)
if ok and min and max then
return max[1] - min[1]
end
end
return #(text or "") * font_size * 0.55
end
local function draw_line(gui,x1,y1,x2,y2,layer,width,color)
if not Gui or not Gui.rect_3d or not Rotation2D or not Vector2 then
return false
end
local xd = x2 - x1
local yd = y2 - y1
local length = math_sqrt(xd * xd + yd * yd)
if length <= 0 then
return true
end
local angle = -math_atan2(yd,xd)
local transform = Rotation2D(Vector2(x1,y1),angle)
Gui.rect_3d(gui,transform,Vector2(0,0),layer,Vector2(length,width),color)
return true
end
local function context_allowed()
if mod and mod.is_enabled and not mod:is_enabled() then
return false
end
local allowed = mod and mod._smog_hud_context_allowed
if type(allowed) ~= "function" then
return false
end
local ok,result = pcall(allowed)
return ok and result == true
end
local class_name = "HudElementSMOGDisplay"
local HudElementSMOGDisplay = rawget(_G,class_name)
if not HudElementSMOGDisplay then
HudElementSMOGDisplay = class(class_name,"HudElementBase")
_G[class_name] = HudElementSMOGDisplay
end
function HudElementSMOGDisplay:init(parent,draw_layer,start_scale)
HudElementSMOGDisplay.super.init(self,parent,draw_layer,start_scale,definitions)
self._sample_timer = refresh_interval
self._percent = 0
self._percent_text = "0%"
self._draw_fail_cooldown = 0
end
function HudElementSMOGDisplay:_sample(dt)
self._sample_timer = self._sample_timer + (dt or 0)
if self._sample_timer < refresh_interval then
return
end
self._sample_timer = 0
local percent = 0
local percent_function = mod and mod._smog_usage_percent
if type(percent_function) == "function" then
local ok,value = pcall(percent_function)
if ok and type(value) == "number" then
percent = value
end
end
self._percent = clamp(percent,0,100)
self._percent_text = string_format("%d%%",math_floor(self._percent + 0.5))
end
function HudElementSMOGDisplay:_draw_arc(gui,cx,cy,radius,start_percent,end_percent,color,layer,width)
if end_percent <= start_percent then
return
end
local start_theta = math_pi - start_percent * 0.01 * math_pi
local end_theta = math_pi - end_percent * 0.01 * math_pi
local segment_count = math_max(1,math_floor(arc_segments * (end_percent - start_percent) / 100 + 0.5))
local last_x,last_y = point_on_arc(cx,cy,radius,start_theta)
for i = 1,segment_count do
local theta = start_theta + (end_theta - start_theta) * i / segment_count
local x,y = point_on_arc(cx,cy,radius,theta)
draw_line(gui,last_x,last_y,x,y,layer,width,color)
last_x,last_y = x,y
end
end
function HudElementSMOGDisplay:_draw_circle(gui,cx,cy,radius,color,layer)
if not Gui or not Gui.triangle or not Vector3 then
return false
end
local centre = Vector3(cx,0,cy)
local last_x = cx + radius
local last_y = cy
for i = 1,circle_segments do
local theta = i / circle_segments * math_pi * 2
local x = cx + radius * math_cos(theta)
local y = cy + radius * math_sin(theta)
Gui.triangle(gui,centre,Vector3(last_x,0,last_y),Vector3(x,0,y),layer,color)
last_x,last_y = x,y
end
return true
end
function HudElementSMOGDisplay:_draw_hub(gui,cx,cy,scale,hub_color,hub_hole)
if self:_draw_circle(gui,cx,cy,14 * scale,hub_color,821) then
self:_draw_circle(gui,cx,cy,5 * scale,hub_hole,822)
return
end
local outer = math_floor(25 * scale + 0.5)
local inner = math_floor(10 * scale + 0.5)
Gui.rect(gui,Vector3(cx - outer * 0.5,cy - outer * 0.5,821),Vector2(outer,outer),hub_color)
Gui.rect(gui,Vector3(cx - inner * 0.5,cy - inner * 0.5,822),Vector2(inner,inner),hub_hole)
end
local function apply_scenegraph_bounds(self,node_name,x,y,width,height,z)
self:_set_scenegraph_size(node_name,width,height)
self:set_scenegraph_position(node_name,x,y,z,"left","top")
end
function HudElementSMOGDisplay:_sync_scenegraph_node(node_name,x,y,width,height,z)
if not node_name or not self._ui_scenegraph then
return
end
if type(self.set_scenegraph_position) ~= "function" or type(self._set_scenegraph_size) ~= "function" then
return
end
self._smog_scenegraph_bounds = self._smog_scenegraph_bounds or {}
local previous = self._smog_scenegraph_bounds[node_name]
local next_x = math_floor((x or 0) + 0.5)
local next_y = math_floor((y or 0) + 0.5)
local next_w = math_max(1,math_floor((width or 1) + 0.5))
local next_h = math_max(1,math_floor((height or 1) + 0.5))
local next_z = z or 900
if previous and math_abs(previous[1] - next_x) < 1 and math_abs(previous[2] - next_y) < 1 and math_abs(previous[3] - next_w) < 1 and math_abs(previous[4] - next_h) < 1 and previous[5] == next_z then
return
end
local ok = pcall(apply_scenegraph_bounds,self,node_name,next_x,next_y,next_w,next_h,next_z)
if ok then
self._smog_scenegraph_bounds[node_name] = {
next_x,
next_y,
next_w,
next_h,
next_z,
}
end
end
function HudElementSMOGDisplay:_sync_meter_bounds(cx,cy,scale,outer_radius)
local width = math_max(1,outer_radius * 2 + 40 * scale)
local height = math_max(1,outer_radius * 2 + 78 * scale)
local x = cx - width * 0.5
local y = cy - outer_radius - 24 * scale
self:_sync_scenegraph_node("smog_root",x,y,width,height,900)
end
function HudElementSMOGDisplay:_sync_notice_bounds(x,y,width,height,scale)
local padding = 14 * (scale or 1)
self:_sync_scenegraph_node("smog_notice",x - padding,y - padding * 0.5,width + padding * 2,height + padding,900)
end
function HudElementSMOGDisplay:_position(screen_width,screen_height,scale,outer_radius)
local x_axis = clamp(mod._smog_hud_x_axis or 5,0,100)
local y_axis = clamp(mod._smog_hud_y_axis or 65,0,100)
local horizontal_margin = outer_radius + 18 * scale
local top_margin = outer_radius + 30 * scale
local bottom_margin = 48 * scale
local available_x = math_max(screen_width - horizontal_margin * 2,0)
local available_y = math_max(screen_height - top_margin - bottom_margin,0)
local cx = horizontal_margin + available_x * x_axis * 0.01
local cy = top_margin + available_y * y_axis * 0.01
return cx,cy
end
function HudElementSMOGDisplay:_draw_text(gui,text,font,font_size,x,y,layer,color)
Gui.slug_text(gui,text,font,font_size,Vector3(x,y,layer),nil,color)
end
function HudElementSMOGDisplay:_draw_meter(gui,scale,screen_width,screen_height)
local outer_radius = 72 * scale
local inner_radius = 53 * scale
local arc_radius = (outer_radius + inner_radius) * 0.5
local arc_width = math_max(outer_radius - inner_radius,8 * scale)
local cx,cy = self:_position(screen_width,screen_height,scale,outer_radius)
self:_sync_meter_bounds(cx,cy,scale,outer_radius)
local percent = clamp(self._percent or 0,0,100)
local percent_text = self._percent_text or string_format("%d%%",math_floor(percent + 0.5))
local fill_percent,r,g,b = phase_for_percent(percent)
local alpha = 226
local base_color = colour(alpha,205,201,197)
local phase_color = colour(alpha,r,g,b)
local needle_color = colour(240,47,40,53)
local hub_color = colour(240,47,40,53)
local hub_hole = colour(245,236,235,236)
self:_draw_arc(gui,cx,cy,arc_radius,0,100,base_color,810,arc_width)
if fill_percent > 0 then
self:_draw_arc(gui,cx,cy,arc_radius,0,fill_percent,phase_color,811,arc_width)
end
local theta = math_pi - percent * 0.01 * math_pi
local dx = math_cos(theta)
local dy = -math_sin(theta)
local px = -dy
local py = dx
local tip_x = cx + dx * (outer_radius - 8 * scale)
local tip_y = cy + dy * (outer_radius - 8 * scale)
local base_x = cx + dx * (15 * scale)
local base_y = cy + dy * (15 * scale)
local needle_half = 5.5 * scale
if Gui and Gui.triangle and Vector3 then
local p1 = Vector3(tip_x,0,tip_y)
local p2 = Vector3(base_x + px * needle_half,0,base_y + py * needle_half)
local p3 = Vector3(base_x - px * needle_half,0,base_y - py * needle_half)
Gui.triangle(gui,p1,p2,p3,820,needle_color)
else
draw_line(gui,cx,cy,tip_x,tip_y,820,8 * scale,needle_color)
end
self:_draw_hub(gui,cx,cy,scale,hub_color,hub_hole)
local small_font = font_path("proxima_nova_bold")
if small_font then
local meter_font_size = math_floor(11 * scale + 0.5)
if meter_font_size < 9 then
meter_font_size = 9
end
local percent_font_size = math_floor(13 * scale + 0.5)
if percent_font_size < 10 then
percent_font_size = 10
end
local meter_width = meter_text_width_cache[meter_font_size]
if not meter_width then
meter_width = text_width(gui,meter_text,small_font,meter_font_size)
meter_text_width_cache[meter_font_size] = meter_width
end
local meter_x = cx - meter_width * 0.5
local meter_y = cy + 25 * scale
local percent_width = text_width(gui,percent_text,small_font,percent_font_size)
local percent_x = cx - percent_width * 0.5 + 2 * scale
local percent_y = cy - arc_radius - percent_font_size * 0.42 + 8 * scale
local meter_color = Color(230,205,210,205)
local percent_color = Color(245,0,0,0)
self:_draw_text(gui,meter_text,small_font,meter_font_size,meter_x,meter_y,825,meter_color)
self:_draw_text(gui,percent_text,small_font,percent_font_size,percent_x,percent_y,825,percent_color)
end
end
function HudElementSMOGDisplay:_draw_notice(gui,scale,screen_width,screen_height)
local getter = mod and mod._smog_get_notification
if type(getter) ~= "function" then
return
end
local now = current_time()
local ok,state = pcall(getter,now)
if not ok or not state or not state.text then
return
end
local remaining = math_max((state.expiry or 0) - now,0)
if remaining <= 0 then
return
end
local fade_seconds = state.fade_seconds or 1
local fade = remaining >= fade_seconds and 1 or math_max(remaining / fade_seconds,0)
local alpha = math_floor(235 * fade + 0.5)
if alpha <= 0 then
return
end
local font = font_path("proxima_nova_bold")
if not font then
return
end
local font_size = math_floor(22 * scale + 0.5)
if font_size < 16 then
font_size = 16
end
local square_size = math_floor(12 * scale + 0.5)
if square_size < 9 then
square_size = 9
end
local gap = math_floor(8 * scale + 0.5)
local text = state.text or ""
local tail = state.tail
local label_width = text_width(gui,label_text,font,font_size)
local message_width = text_width(gui,text,font,font_size)
local tail_width = tail and text_width(gui,tail,font,font_size) or 0
local total_width = label_width + gap + square_size + gap + message_width + tail_width
local x = (screen_width - total_width) * 0.5
local notification_y_axis = clamp(mod._smog_notification_y_axis or 85,0,100)
local y = clamp(screen_height * notification_y_axis * 0.01 - font_size * 0.5,0,math_max(screen_height - font_size,0))
self:_sync_notice_bounds(x,y,total_width,font_size + square_size * 0.25,scale)
local square_colour = state.good ~= false and Color(alpha,90,200,90) or Color(alpha,220,40,40)
local text_colour = Color(alpha,205,210,205)
local green_text_colour = Color(alpha,90,200,90)
local red_text_colour = Color(alpha,220,40,40)
local full_red = state.red_text == true
local label_colour = full_red and red_text_colour or text_colour
local message_colour = full_red and red_text_colour or state.green_text == true and green_text_colour or text_colour
local tail_colour = full_red and red_text_colour or text_colour
local label_x = x
local square_x = label_x + label_width + gap
local message_x = square_x + square_size + gap
Gui.slug_text(gui,label_text,font,font_size,Vector3(label_x,y,991),nil,label_colour)
Gui.rect(gui,Vector3(square_x,y + font_size * 0.25,990),Vector2(square_size,square_size),square_colour)
Gui.slug_text(gui,text,font,font_size,Vector3(message_x,y,991),nil,message_colour)
if tail then
Gui.slug_text(gui,tail,font,font_size,Vector3(message_x + message_width,y,991),nil,tail_colour)
end
end
function HudElementSMOGDisplay:_draw_smog(dt,gui)
local resolution = RESOLUTION_LOOKUP or {}
local scale = resolution.scale or 1
local screen_width = resolution.width or 1920
local screen_height = resolution.height or 1080
self:_draw_notice(gui,scale,screen_width,screen_height)
if mod._smog_hud_visible == true then
self:_sample(dt)
self:_draw_meter(gui,scale,screen_width,screen_height)
end
end
function HudElementSMOGDisplay:_draw_widgets(dt,t,input_service,ui_renderer,render_settings)
if mod._smog_hud_visible ~= true and mod._smog_notification_active ~= true then
self._draw_fail_cooldown = 0
return
end
if not context_allowed() then
return
end
if self._draw_fail_cooldown > 0 then
self._draw_fail_cooldown = self._draw_fail_cooldown - 1
return
end
local gui = ui_renderer and ui_renderer.gui
if not gui or not Gui or not Vector2 or not Vector3 or not Color then
return
end
local ok = pcall(HudElementSMOGDisplay._draw_smog,self,dt,gui)
if not ok then
self._draw_fail_cooldown = draw_fail_backoff
end
end
function HudElementSMOGDisplay:destroy(ui_renderer)
self._sample_timer = refresh_interval
self._percent = 0
self._percent_text = "0%"
HudElementSMOGDisplay.super.destroy(self,ui_renderer)
end
return HudElementSMOGDisplay