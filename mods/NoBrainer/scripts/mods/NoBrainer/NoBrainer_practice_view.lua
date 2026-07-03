local mod = get_mod("NoBrainer")

local MinigameBalanceView = require("scripts/ui/views/scanner_display_view/minigame_balance_view")
local MinigameDecodeSearchView = require("scripts/ui/views/scanner_display_view/minigame_decode_search_view")
local MinigameDecodeSymbolsView = require("scripts/ui/views/scanner_display_view/minigame_decode_symbols_view")
local MinigameDrillView = require("scripts/ui/views/scanner_display_view/minigame_drill_view")
local MinigameFrequencyView = require("scripts/ui/views/scanner_display_view/minigame_frequency_view")
local MinigameNoneView = require("scripts/ui/views/scanner_display_view/minigame_none_view")
local MinigameSettings = require("scripts/settings/minigame/minigame_settings")
local ScannerDisplayViewDefinitions = require("scripts/ui/views/scanner_display_view/scanner_display_view_definitions")
local ScannerDisplayViewDrillSettings = require("scripts/ui/views/scanner_display_view/scanner_display_view_drill_settings")
local ScannerDisplayViewFrequencySettings = require("scripts/ui/views/scanner_display_view/scanner_display_view_frequency_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local OVERLAY_PANEL_SIZE = 1260
local RENDER_SIZE = 1024
local PRACTICE_DISPLAY_SCALE = 0.58
local FRAME_TEXTURE = "content/ui/materials/dividers/horizontal_frame_big_lower"
local OUTLINE_TEXTURE = "content/ui/materials/frames/frame_tile_2px"
local FRAME_SIZE = { 1096, 150 }
local FRAME_MARGIN = -100
local OUTLINE_SIZE = { 1096, 1096 }
local BACKDROP_ALPHA = 165
local DRILL_SONAR_ALPHA_MULTIPLIER = 0.2
local FREQUENCY_SIDE_PADDING = 35
local FREQUENCY_WIDGET_SIZE = {}

local scenegraph_definition = {
    screen = table.clone(UIWorkspaceSettings.screen),
    overlay_panel = {
        horizontal_alignment = "center",
        parent = "screen",
        vertical_alignment = "center",
        size = { OVERLAY_PANEL_SIZE, OVERLAY_PANEL_SIZE },
        position = { 0, 0, 25 },
    },
    scanner_base = {
        horizontal_alignment = "center",
        parent = "overlay_panel",
        vertical_alignment = "center",
        size = { RENDER_SIZE, RENDER_SIZE },
        position = { 0, 0, 5 },
    },
    center_pivot = {
        horizontal_alignment = "center",
        parent = "scanner_base",
        vertical_alignment = "center",
        size = { 0, 0 },
        position = { 0, 0, 1 },
    },
}

local HIDDEN_STOCK = {
    decoration_eagle = true,
    decoration_inquisition = true,
    decoration_left_mark = true,
    decoration_right_mark = true,
    decoration_skull = true,
    scanner_background = true,
    noise_background = true,
    edge_fade = true,
}

local function _scanner_green(alpha)
    return { alpha, 0, 255, 110 }
end

local function _practice_frame_widgets()
    return {
        overlay_backdrop = UIWidget.create_definition({
            {
                pass_type = "texture",
                style_id = "background",
                value = "content/ui/materials/backgrounds/default_square",
                style = {
                    color = {
                        BACKDROP_ALPHA,
                        0,
                        0,
                        0,
                    },
                    offset = {
                        (RENDER_SIZE - OUTLINE_SIZE[1]) / 2,
                        (RENDER_SIZE - OUTLINE_SIZE[2]) / 2,
                        -2,
                    },
                },
            },
        }, "scanner_base", nil, OUTLINE_SIZE),
        auspex_frame_top = UIWidget.create_definition({
            {
                pass_type = "rotated_texture",
                style_id = "frame",
                value = FRAME_TEXTURE,
                style = {
                    angle = math.rad(180),
                    color = _scanner_green(144),
                    offset = {
                        (RENDER_SIZE - FRAME_SIZE[1]) / 2,
                        FRAME_MARGIN,
                        7,
                    },
                    pivot = {},
                },
            },
        }, "scanner_base", nil, FRAME_SIZE),
        auspex_frame_bottom = UIWidget.create_definition({
            {
                pass_type = "texture",
                style_id = "frame",
                value = FRAME_TEXTURE,
                style = {
                    color = _scanner_green(144),
                    offset = {
                        (RENDER_SIZE - FRAME_SIZE[1]) / 2,
                        RENDER_SIZE - FRAME_SIZE[2] - FRAME_MARGIN,
                        7,
                    },
                },
            },
        }, "scanner_base", nil, FRAME_SIZE),
        auspex_frame_left = UIWidget.create_definition({
            {
                pass_type = "rotated_texture",
                style_id = "frame",
                value = FRAME_TEXTURE,
                style = {
                    angle = math.rad(-90),
                    color = _scanner_green(144),
                    offset = {
                        FRAME_MARGIN + FRAME_SIZE[2] / 2 - FRAME_SIZE[1] / 2,
                        (RENDER_SIZE - FRAME_SIZE[2]) / 2,
                        7,
                    },
                    pivot = {},
                },
            },
        }, "scanner_base", nil, FRAME_SIZE),
        auspex_frame_right = UIWidget.create_definition({
            {
                pass_type = "rotated_texture",
                style_id = "frame",
                value = FRAME_TEXTURE,
                style = {
                    angle = math.rad(90),
                    color = _scanner_green(144),
                    offset = {
                        RENDER_SIZE - FRAME_MARGIN - FRAME_SIZE[2] / 2 - FRAME_SIZE[1] / 2,
                        (RENDER_SIZE - FRAME_SIZE[2]) / 2,
                        7,
                    },
                    pivot = {},
                },
            },
        }, "scanner_base", nil, FRAME_SIZE),
        auspex_outline = UIWidget.create_definition({
            {
                pass_type = "texture",
                style_id = "frame",
                value = OUTLINE_TEXTURE,
                style = {
                    color = _scanner_green(70),
                    scale_to_material = true,
                    offset = {
                        (RENDER_SIZE - OUTLINE_SIZE[1]) / 2,
                        (RENDER_SIZE - OUTLINE_SIZE[2]) / 2,
                        6,
                    },
                },
            },
        }, "scanner_base", nil, OUTLINE_SIZE),
    }
end

local PRACTICE_FRAME_WIDGETS = _practice_frame_widgets()
local built_definitions = {}

local function _build_definitions(minigame_type)
    if built_definitions[minigame_type] then
        return built_definitions[minigame_type]
    end

    local stock = ScannerDisplayViewDefinitions[minigame_type]
    if not stock then
        stock = ScannerDisplayViewDefinitions[MinigameSettings.types.none]
    end

    local widget_definitions = {}

    for name, definition in pairs(PRACTICE_FRAME_WIDGETS) do
        widget_definitions[name] = definition
    end

    for name, definition in pairs(stock.widget_definitions) do
        if not HIDDEN_STOCK[name] then
            widget_definitions[name] = definition
        end
    end

    local defs = {
        scenegraph_definition = scenegraph_definition,
        widget_definitions = widget_definitions,
    }

    built_definitions[minigame_type] = defs

    return defs
end

local MINIGAME_VIEWS = {
    [MinigameSettings.types.none] = MinigameNoneView,
    [MinigameSettings.types.balance] = MinigameBalanceView,
    [MinigameSettings.types.decode_search] = MinigameDecodeSearchView,
    [MinigameSettings.types.decode_symbols] = MinigameDecodeSymbolsView,
    [MinigameSettings.types.drill] = MinigameDrillView,
    [MinigameSettings.types.frequency] = MinigameFrequencyView,
}

local STOCK_DRAW_DRILL_WIDGETS = MinigameDrillView._nobrainer_stock_draw_widgets or MinigameDrillView.draw_widgets
MinigameDrillView._nobrainer_stock_draw_widgets = STOCK_DRAW_DRILL_WIDGETS

local STOCK_UPDATE_DRILL_BACKGROUND = MinigameDrillView._nobrainer_stock_update_background or MinigameDrillView._update_background
MinigameDrillView._nobrainer_stock_update_background = STOCK_UPDATE_DRILL_BACKGROUND

local STOCK_DRAW_FREQUENCY = MinigameFrequencyView._nobrainer_stock_draw_frequency or MinigameFrequencyView._draw_frequency
MinigameFrequencyView._nobrainer_stock_draw_frequency = STOCK_DRAW_FREQUENCY

MinigameDrillView._update_background = function(self, widgets_by_name, minigame)
    if not self._nobrainer_practice_drill then
        return STOCK_UPDATE_DRILL_BACKGROUND(self, widgets_by_name, minigame)
    end

    local stage = minigame:current_stage()
    local correct_targets = minigame:correct_targets()

    if not stage or #correct_targets == 0 then
        return
    end

    local widget_size = ScannerDisplayViewDrillSettings.background_rings_size
    local state = minigame:state()
    local scale_percentage = 1

	if state ~= MinigameSettings.game_states.gameplay then
		local t_gameplay = mod._time("gameplay") or 0
		local transition_percentage = minigame:transition_percentage(t_gameplay)

        scale_percentage = math.clamp(transition_percentage * 2 - 1, 0, 1)
    end

    local x_pos = ScannerDisplayViewDrillSettings.board_starting_offset_x
    local y_pos = ScannerDisplayViewDrillSettings.board_starting_offset_y
    local background_widgets = self._background_widgets

    for i = 1, #background_widgets do
        local widget = background_widgets[i]
        local size = widget.content.size
        local scale = (i - 1 + scale_percentage) / 3

        size[1] = widget_size[1] * scale
        size[2] = widget_size[2] * scale
        widget.offset[1] = x_pos - size[1] / 2
        widget.offset[2] = y_pos - size[2] / 2
    end
end

local function _draw_practice_drill_background(self, ui_renderer)
    local background_widgets = self._background_widgets

    if not background_widgets or #background_widgets == 0 then
        return
    end

    local outline_half_width = OUTLINE_SIZE[1] * 0.5
    local outline_half_height = OUTLINE_SIZE[2] * 0.5

    for i = 1, #background_widgets do
        local widget = background_widgets[i]
        local size = widget.content and widget.content.size
        local offset = widget.offset

        if size and offset then
            local center_x = offset[1] + size[1] * 0.5
            local center_y = offset[2] + size[2] * 0.5
            local max_half_width = math.max(0, outline_half_width - math.abs(center_x))
            local max_half_height = math.max(0, outline_half_height - math.abs(center_y))
            local max_size = math.max(0, math.min(max_half_width * 2, max_half_height * 2))

            if max_size > 1 then
                local draw_size = math.min(size[1], size[2], max_size)
                local style = widget.style and widget.style.highlight

                if style and style.size then
                    style.size[1] = draw_size
                    style.size[2] = draw_size
                end

                if style and style.color then
                    if style._nobrainer_base_alpha == nil then
                        style._nobrainer_base_alpha = style.color[1] or 255
                    end

                    style.color[1] = math.floor(style._nobrainer_base_alpha * DRILL_SONAR_ALPHA_MULTIPLIER)
                end

                offset[1] = center_x - draw_size * 0.5
                offset[2] = center_y - draw_size * 0.5
                size[1] = draw_size
                size[2] = draw_size

                UIWidget.draw(widget, ui_renderer)
            end
        end
    end
end

MinigameDrillView.draw_widgets = function(self, dt, t, input_service, ui_renderer)
    if not self._nobrainer_practice_drill then
        return STOCK_DRAW_DRILL_WIDGETS(self, dt, t, input_service, ui_renderer)
    end

    local minigame_extension = self._minigame_extension

    if not minigame_extension or not self._target_widgets or not self._stage_widgets then
        return
    end

    local minigame = minigame_extension:minigame(MinigameSettings.types.drill)
    local current_stage = minigame:current_stage()
    local state = minigame:state()

    if not current_stage or current_stage > #self._target_widgets then
        return
    end

    _draw_practice_drill_background(self, ui_renderer)

    if state == MinigameSettings.game_states.gameplay or state == MinigameSettings.game_states.transition then
        local target_widgets = self._target_widgets[current_stage]

        for i = 1, #target_widgets do
            UIWidget.draw(target_widgets[i], ui_renderer)
        end
    end

    local stage_widgets = self._stage_widgets

    for i = 1, #stage_widgets do
        local widget = stage_widgets[i]

        if i < current_stage or i == current_stage and t % 1 > 0.5 then
            widget.style.highlight.color = {
                255,
                0,
                255,
                0,
            }
        else
            widget.style.highlight.color = {
                255,
                0,
                64,
                0,
            }
        end

        UIWidget.draw(widget, ui_renderer)
    end
end

MinigameFrequencyView._draw_frequency = function(self, frequency, color, t, ui_renderer)
    if not self._nobrainer_practice_frequency then
        return STOCK_DRAW_FREQUENCY(self, frequency, color, t, ui_renderer)
    end

    if not self._frequency_widgets or #self._frequency_widgets == 0 then
        return
    end

    local visible_width = math.max(OUTLINE_SIZE[1] - FREQUENCY_SIDE_PADDING * 2, 0)
    local widget_width = ScannerDisplayViewFrequencySettings.frequency_widget_size[1] * frequency.x
    local widget_height = ScannerDisplayViewFrequencySettings.frequency_widget_size[2] * frequency.y

    if visible_width <= 0 or widget_width <= 0 or widget_height <= 0 then
        return
    end

    FREQUENCY_WIDGET_SIZE[1] = widget_width
    FREQUENCY_WIDGET_SIZE[2] = widget_height

    local left_edge = -visible_width * 0.5
    local right_edge = visible_width * 0.5
    local starting_offset_y = ScannerDisplayViewFrequencySettings.frequency_starting_offset_y
    local scroll_fraction = t * MinigameSettings.frequency_speed % 1
    local max_widgets = math.min(#self._frequency_widgets, math.ceil(visible_width / widget_width) + 3)

    for i = 1, max_widgets do
        local widget = self._frequency_widgets[i]
        local offset_x = left_edge + widget_width * (i - 1 - scroll_fraction)
        local right = offset_x + widget_width

        if offset_x >= left_edge and right <= right_edge then
            widget.content.size = FREQUENCY_WIDGET_SIZE
            widget.style.style_id_1.color = color
            widget.offset[1] = offset_x
            widget.offset[2] = starting_offset_y - widget_height * 0.5
            widget.offset[3] = 1

            UIWidget.draw(widget, ui_renderer)
        end
    end
end

local NoBrainerPracticeView = class("NoBrainerPracticeView", "BaseView")

function NoBrainerPracticeView:init(settings, context)
    local minigame_type = context.minigame_type or MinigameSettings.types.none
    local definitions = _build_definitions(minigame_type)

    NoBrainerPracticeView.super.init(self, definitions, settings, context)

    self._base_render_scale = nil
    self._minigame_type = minigame_type
    self._no_cursor = true

    local view_class = MINIGAME_VIEWS[minigame_type] or MinigameNoneView
    self._minigame = view_class:new(context)

    if minigame_type == MinigameSettings.types.frequency and self._minigame then
        self._minigame._nobrainer_practice_frequency = true
    elseif minigame_type == MinigameSettings.types.drill and self._minigame then
        self._minigame._nobrainer_practice_drill = true
    end
end

function NoBrainerPracticeView:on_enter()
    self._base_render_scale = Managers.ui and Managers.ui:view_render_scale() or 1
    self:set_render_scale(self._base_render_scale * PRACTICE_DISPLAY_SCALE)
    NoBrainerPracticeView.super.on_enter(self)
end

function NoBrainerPracticeView:dialogue_system()
    return nil
end

function NoBrainerPracticeView:is_using_input()
    return false
end

function NoBrainerPracticeView:update(dt, t, input_service)
    if self._render_scale ~= (self._base_render_scale or 1) * PRACTICE_DISPLAY_SCALE then
        self:set_render_scale((self._base_render_scale or 1) * PRACTICE_DISPLAY_SCALE)
    end

    if self._minigame and self._minigame.update then
        self._minigame:update(dt, t, self._widgets_by_name)
    end

    return NoBrainerPracticeView.super.update(self, dt, t, input_service)
end

function NoBrainerPracticeView:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
    local ok = pcall(NoBrainerPracticeView.super._draw_widgets, self, dt, t, input_service, ui_renderer, render_settings)

    if ok and self._minigame and self._minigame.draw_widgets then
        pcall(self._minigame.draw_widgets, self._minigame, dt, t, input_service, ui_renderer)
    end
end

function NoBrainerPracticeView:destroy()
    if self._minigame then
        if self._minigame.delete then
            self._minigame:delete()
        end

        self._minigame = nil
    end

    NoBrainerPracticeView.super.destroy(self)
end

return NoBrainerPracticeView
