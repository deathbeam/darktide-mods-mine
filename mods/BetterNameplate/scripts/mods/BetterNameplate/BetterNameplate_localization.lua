local localization = {
	mod_name = {
		en = "Better Nameplate",
		["zh-cn"] = "更好的名牌",
	},
	mod_description = {
		en = "Make Nameplates Look Better",
		["zh-cn"] = "让名牌再次伟大",
	},
	display_settings = {
		en = "Display Settings",
		["zh-cn"] = "显示设置",
	},
	only_icon_in_nameplate = {
		en = "Only Icon in Nameplates",
		["zh-cn"] = "名牌仅显示图标",
	},
	no_icon_in_nameplate = {
		en = "No Icon in Nameplates",
		["zh-cn"] = "名牌不显示图标",
	},
	class_name_in_nameplate = {
		en = "Class Name in Nameplates",
		["zh-cn"] = "名牌显示职业名称",
	},
	only_class_name_in_nameplate = {
		en = "Only Class Name in Nameplates",
		["zh-cn"] = "名牌仅显示职业名称",
	},
	only_icon_and_class_name_in_nameplate = {
		en = "Only Icon and Class Name in Nameplates",
		["zh-cn"] = "名牌仅显示图标和职业名称",
	},
	reduce_screen_margin = {
		en = "Reduce Screen Margin",
		["zh-cn"] = "减少屏幕边距",
	},
	reduce_screen_margin_description = {
		en = "Expand the screen-space displayable range of nameplates",
		["zh-cn"] = "扩大名牌在屏幕空间上的可显示范围",
	},
	enhanced_distance_scale = {
		en = "Enhanced Distance Scale",
		["zh-cn"] = "增强距离缩放",
	},
	enhanced_distance_scale_description = {
		en = "Make nameplates shrink more noticeably as they get farther away",
		["zh-cn"] = "使名牌在远距离缩小得更明显",
	},
	hide_off_screen_icon = {
		en = "Hide Off-Screen Icons",
		["zh-cn"] = "隐藏屏幕边缘外的名牌",
	},
	show_in_close_range = {
		en = "Show in Close Range",
		["zh-cn"] = "在近距离显示",
	},
	show_in_close_range_description = {
		en = "Keep clamped off-screen nameplates visible within 15m",
		["zh-cn"] = "让超出屏幕边缘的名牌在15米内依旧显示",
	},
	show_in_smoke = {
		en = "Show in Smoke",
		["zh-cn"] = "在烟雾中显示",
	},
	show_in_smoke_description = {
		en = "Keep nameplates visible inside Veteran smoke grenades",
		["zh-cn"] = "使名牌在老兵的烟雾手雷中继续显示",
	},
	opacity_normal = {
		en = "Nameplates Opacity",
		["zh-cn"] = "名牌不透明度",
	},
	fade_when_aim = {
		en = "Fade When Aim",
		["zh-cn"] = "瞄准时淡出",
	},
	opacity_aim = {
		en = "Opacity",
		["zh-cn"] = "不透明度",
	},
	font_settings = {
		en = "Font Settings",
		["zh-cn"] = "字体设置",
	},
	override_font_size = {
		en = "Override Font Size",
		["zh-cn"] = "覆盖字体大小",
	},
	font_size = {
		en = "Size",
		["zh-cn"] = "大小",
	},
	override_font_type = {
		en = "Override Font Type",
		["zh-cn"] = "覆盖字体类型",
	},
	font_type = {
		en = "Type",
		["zh-cn"] = "类型",
	},
	override_font_color = {
		en = "Override Font Color",
		["zh-cn"] = "覆盖字体颜色",
	},
	font_color = {
		en = "Color",
		["zh-cn"] = "颜色",
	},
	loc_cyber_mastiff = {
		en = "Cyber-Mastiff",
		["zh-cn"] = "智能獒犬",
		["zh-tw"] = "電子獒犬",
	},
}

do
	local function make_text_readable(text)
		local readable = text:gsub("_", " "):gsub("(%a)([%w]*)",
			function(first, rest)
				return first:upper() .. rest
			end)
		return readable
	end

	local function make_text_colorful(text, color_name)
		local InputUtils = require("scripts/managers/input/input_utils")
		local color = Color[color_name](255, true)
		return InputUtils.apply_color_to_input_text(text, color)
	end

	local FontDefinitions = require("scripts/managers/ui/ui_fonts_definitions")
	local fonts = FontDefinitions.fonts or {}

	for font_name, _ in pairs(fonts) do
		localization[font_name] = { en = make_text_readable(font_name) }
	end


	for i, color_name in ipairs(Color.list) do
		localization[color_name] = { en = make_text_colorful(make_text_readable(color_name), color_name) }
	end
end

return localization
