-- SMOG_HUD.lua
local mod = get_mod("SMOG")
local Common = mod._smog_hud_common
local Gui = Gui
local Color = Color
local QuaternionBox = QuaternionBox
local Vector2 = Vector2
local Vector3 = Vector3
local Rotation2D = Rotation2D
local Matrix4x4Box = Matrix4x4Box
local math = math
local math_sin = math.sin
local math_cos = math.cos
local math_floor = math.floor
local math_max = math.max
local math_pi = math.pi
local math_sqrt = math.sqrt
local math_atan2 = math.atan2 or math.atan
local string_format = string.format
local arc_segments = 96
local circle_segments = 16
local meter_text = "SMOG METER"
local meter_text_width_cache = {}
local base_color_box = QuaternionBox(Color(226,205,201,197))
local phase_sixteen_box = QuaternionBox(Color(226,86,190,40))
local phase_thirtytwo_box = QuaternionBox(Color(226,130,225,65))
local phase_fifty_box = QuaternionBox(Color(226,186,225,58))
local phase_sixtysix_box = QuaternionBox(Color(226,250,207,76))
local phase_eightythree_box = QuaternionBox(Color(226,238,126,52))
local phase_hundred_box = QuaternionBox(Color(226,235,54,38))
local needle_color_box = QuaternionBox(Color(240,47,40,53))
local hub_hole_box = QuaternionBox(Color(245,236,235,236))
local meter_color_box = QuaternionBox(Color(230,205,210,205))
local percent_color_box = QuaternionBox(Color(245,0,0,0))
local Renderer = {}
local function phase_for_percent(percent)
if percent <= 0.2 then
return 0,base_color_box
elseif percent <= 16 then
return 16,phase_sixteen_box
elseif percent <= 32 then
return 32,phase_thirtytwo_box
elseif percent <= 50 then
return 50,phase_fifty_box
elseif percent <= 66 then
return 66,phase_sixtysix_box
elseif percent <= 83 then
return 83,phase_eightythree_box
end
return 100,phase_hundred_box
end
local function build_normalized_arc(start_percent,end_percent)
local span_percent = end_percent - start_percent
local segment_count = math_max(1,math_floor(arc_segments * span_percent / 100 + 0.5))
local start_theta = math_pi - start_percent * 0.01 * math_pi
local end_theta = math_pi - end_percent * 0.01 * math_pi
local points = {}
local point_index = 1
for i = 0,segment_count do
local theta = start_theta + (end_theta - start_theta) * i / segment_count
points[point_index] = math_cos(theta)
points[point_index + 1] = -math_sin(theta)
point_index = point_index + 2
end
return points
end
local normalized_arc_parts = {
[0] = {
remainder = build_normalized_arc(0,100),
},
[16] = {
fill = build_normalized_arc(0,16),
remainder = build_normalized_arc(16,100),
},
[32] = {
fill = build_normalized_arc(0,32),
remainder = build_normalized_arc(32,100),
},
[50] = {
fill = build_normalized_arc(0,50),
remainder = build_normalized_arc(50,100),
},
[66] = {
fill = build_normalized_arc(0,66),
remainder = build_normalized_arc(66,100),
},
[83] = {
fill = build_normalized_arc(0,83),
remainder = build_normalized_arc(83,100),
},
[100] = {
fill = build_normalized_arc(0,100),
},
}
local function draw_line(gui,x1,y1,x2,y2,layer,width,color_box)
if not Gui or not Gui.rect_3d or not Rotation2D or not Vector2 or not Vector3 then
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
Gui.rect_3d(gui,transform,Vector3.zero(),layer,Vector2(length,width),color_box:unbox())
return true
end
local function sample(owner)
local revision = mod._smog_hud_sample_revision or 0
if owner._smog_analogue_sample_revision == revision then
return
end
owner._smog_analogue_sample_revision = revision
owner._smog_analogue_percent = Common.clamp(mod._smog_hud_sample_percent or 0,0,100)
owner._smog_analogue_percent_text = string_format("%d%%",math_floor(owner._smog_analogue_percent + 0.5))
end
local function update_line_geometry(target,normalized,cx,cy,radius,width)
local next_index = 1
if normalized and Rotation2D and Matrix4x4Box and Vector2 then
local last_x = cx + normalized[1] * radius
local last_y = cy + normalized[2] * radius
for i = 3,#normalized,2 do
local x = cx + normalized[i] * radius
local y = cy + normalized[i + 1] * radius
local xd = x - last_x
local yd = y - last_y
local length = math_sqrt(xd * xd + yd * yd)
if length > 0 then
local transform = Rotation2D(Vector2(last_x,last_y),-math_atan2(yd,xd))
target[next_index] = Matrix4x4Box(transform)
target[next_index + 1] = length
target[next_index + 2] = width
next_index = next_index + 3
end
last_x = x
last_y = y
end
end
for i = next_index,#target do
target[i] = nil
end
end
local function ensure_arc_geometry(owner,cx,cy,radius,width,fill_percent)
if owner._smog_analogue_arc_cx == cx and owner._smog_analogue_arc_cy == cy and owner._smog_analogue_arc_radius == radius and owner._smog_analogue_arc_width == width and owner._smog_analogue_arc_fill_percent == fill_percent then
return
end
owner._smog_analogue_arc_cx = cx
owner._smog_analogue_arc_cy = cy
owner._smog_analogue_arc_radius = radius
owner._smog_analogue_arc_width = width
owner._smog_analogue_arc_fill_percent = fill_percent
local parts = normalized_arc_parts[fill_percent] or normalized_arc_parts[0]
update_line_geometry(owner._smog_analogue_fill_geometry,parts.fill,cx,cy,radius,width)
update_line_geometry(owner._smog_analogue_remainder_geometry,parts.remainder,cx,cy,radius,width)
end
local function draw_arc_geometry(gui,geometry,color_box,layer)
if not geometry or not Gui or not Gui.rect_3d or not Vector2 or not Vector3 then
return
end
local color = color_box:unbox()
local offset = Vector3.zero()
local size = Vector2(0,0)
for i = 1,#geometry,3 do
size.x = geometry[i + 1]
size.y = geometry[i + 2]
Gui.rect_3d(gui,geometry[i]:unbox(),offset,layer,size,color)
end
end
local function draw_circle(gui,cx,cy,radius,color_box,layer)
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
Gui.triangle(gui,centre,Vector3(last_x,0,last_y),Vector3(x,0,y),layer,color_box:unbox())
last_x,last_y = x,y
end
return true
end
local function draw_hub(gui,cx,cy,scale,hub_color_box,hub_hole_box)
if draw_circle(gui,cx,cy,14 * scale,hub_color_box,821) then
draw_circle(gui,cx,cy,5 * scale,hub_hole_box,822)
return
end
local outer = math_floor(25 * scale + 0.5)
local inner = math_floor(10 * scale + 0.5)
Gui.rect(gui,Vector3(cx - outer * 0.5,cy - outer * 0.5,821),Vector2(outer,outer),hub_color_box:unbox())
Gui.rect(gui,Vector3(cx - inner * 0.5,cy - inner * 0.5,822),Vector2(inner,inner),hub_hole_box:unbox())
end
function Renderer.init(owner)
owner._smog_analogue_sample_revision = -1
owner._smog_analogue_percent = 0
owner._smog_analogue_percent_text = "0%"
owner._smog_analogue_percent_layout = nil
owner._smog_analogue_arc_cx = nil
owner._smog_analogue_arc_cy = nil
owner._smog_analogue_arc_radius = nil
owner._smog_analogue_arc_width = nil
owner._smog_analogue_arc_fill_percent = nil
owner._smog_analogue_fill_geometry = {}
owner._smog_analogue_remainder_geometry = {}
end
function Renderer.draw(owner,dt,gui,scale,screen_width,screen_height)
sample(owner)
local outer_radius = 72 * scale
local inner_radius = 53 * scale
local arc_radius = (outer_radius + inner_radius) * 0.5
local arc_width = math_max(outer_radius - inner_radius,8 * scale)
local cx,cy = Common.position(screen_width,screen_height,scale,outer_radius)
local percent = Common.clamp(owner._smog_analogue_percent or 0,0,100)
local percent_text = owner._smog_analogue_percent_text or string_format("%d%%",math_floor(percent + 0.5))
local fill_percent,phase_color_box = phase_for_percent(percent)
ensure_arc_geometry(owner,cx,cy,arc_radius,arc_width,fill_percent)
draw_arc_geometry(gui,owner._smog_analogue_remainder_geometry,base_color_box,810)
if fill_percent > 0 then
draw_arc_geometry(gui,owner._smog_analogue_fill_geometry,phase_color_box,811)
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
Gui.triangle(gui,p1,p2,p3,820,needle_color_box:unbox())
else
draw_line(gui,cx,cy,tip_x,tip_y,820,8 * scale,needle_color_box)
end
draw_hub(gui,cx,cy,scale,needle_color_box,hub_hole_box)
local small_font = Common.font_path("proxima_nova_bold")
if not small_font then
return
end
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
meter_width = Common.text_width(gui,meter_text,small_font,meter_font_size)
meter_text_width_cache[meter_font_size] = meter_width
end
local meter_x = cx - meter_width * 0.5
local meter_y = cy + 25 * scale
local percent_layout = owner._smog_analogue_percent_layout
if not percent_layout or percent_layout.text ~= percent_text or percent_layout.font ~= small_font or percent_layout.font_size ~= percent_font_size or percent_layout.cx ~= cx or percent_layout.cy ~= cy or percent_layout.scale ~= scale then
local percent_width = Common.text_width(gui,percent_text,small_font,percent_font_size)
percent_layout = {
text = percent_text,
font = small_font,
font_size = percent_font_size,
cx = cx,
cy = cy,
scale = scale,
x = cx - percent_width * 0.5 + 2 * scale,
y = cy - arc_radius - percent_font_size * 0.42 + 8 * scale,
}
owner._smog_analogue_percent_layout = percent_layout
end
Common.draw_text(gui,meter_text,small_font,meter_font_size,meter_x,meter_y,825,meter_color_box:unbox())
Common.draw_text(gui,percent_text,small_font,percent_font_size,percent_layout.x,percent_layout.y,825,percent_color_box:unbox())
end
function Renderer.destroy(owner)
owner._smog_analogue_fill_geometry = nil
owner._smog_analogue_remainder_geometry = nil
end
return Renderer