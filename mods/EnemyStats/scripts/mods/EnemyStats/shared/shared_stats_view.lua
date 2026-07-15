local ViewElementInputLegend = require('scripts/ui/view_elements/view_element_input_legend/view_element_input_legend')
local ViewElementGrid = require('scripts/ui/view_elements/view_element_grid/view_element_grid')

local function _package_is_available(package_name)
    local application = Application and Application.can_get_resource
    if not application then
        return false
    end
    local ok, exists = pcall(application, 'package', package_name)
    return ok and exists or false
end

-- Build a stats view class (subclass of BaseView) registered under `class_name`.
-- DMF instantiates views by looking up the class name in the global CLASSES table.
--
-- config:
--   mod             - the mod instance (for localize/package_status/load_package)
--   prefix          - scenegraph/widget name prefix (e.g. "weapon_stats")
--   entry_type      - list entry widget type (e.g. "weapon_entry")
--   icon_packages   - optional list of UI package paths to load while the view is open
--   make_blueprints - function(width) returning list blueprints
--   make_definitions - function() returning the view definitions table
--   callbacks:
--   build_list      - function(context) -> list of items
--   matches_search  - function(item, search_text) -> bool (optional)
--   make_entry      - function(item) -> entry table (optional)
--   present_detail  - function(self, entry) (required)
--   on_presented    - function(self, entries) (optional; default selects first)
--   on_select_entry  - function(self, entry) (optional)
local function make_view(class_name, config)
    local View = class(class_name, 'BaseView')

    function View:init(settings, context)
        self._config = config
        self._mod = config.mod
        self._definitions = config.make_definitions()

        View.super.init(self, self._definitions, settings)

        self._pass_draw = false
        self._list = config.build_list(context) or {}
        self._last_search_text = ''
    end

    function View:_load_icon_packages()
        local packages = config.icon_packages
        if not packages then
            return
        end
        local loaded = {}
        for _, pkg in ipairs(packages) do
            if _package_is_available(pkg) and self._mod:package_status(pkg) ~= 'loaded' then
                self._mod:load_package(pkg, nil, true)
                loaded[#loaded + 1] = pkg
            end
        end
        self._loaded_icon_packages = loaded
    end

    function View:_release_icon_packages()
        local loaded = self._loaded_icon_packages
        if not loaded then
            return
        end
        for i = 1, #loaded do
            if self._mod:package_status(loaded[i]) == 'loaded' then
                self._mod:unload_package(loaded[i])
            end
        end
        self._loaded_icon_packages = nil
    end

    function View:on_enter()
        View.super.on_enter(self)

        self:_load_icon_packages()
        self:_setup_input_legend()
        self:_setup_search()
        self:_setup_list_grid()
        self:_setup_detail_grid()
        self:_setup_entries()
    end

    function View:_setup_search()
        local search_widget = self._widgets_by_name[config.prefix .. '_search']
        if search_widget then
            search_widget.content.input_text = ''
            search_widget.content.placeholder_text = self._mod:localize('search_placeholder')

            local style = search_widget.style
            if style then
                style.background.color = { 255, 30, 30, 30 }
                style.baseline.color = Color.terminal_text_body(100, true)
            end
        end
    end

    function View:_setup_input_legend()
        self._input_legend_element = self:_add_element(ViewElementInputLegend, 'input_legend', 10)
        local legend_inputs = self._definitions.legend_inputs

        for i = 1, #legend_inputs do
            local legend_input = legend_inputs[i]
            local on_pressed_callback = legend_input.on_pressed_callback
                and callback(self, legend_input.on_pressed_callback)

            self._input_legend_element:add_entry(
                legend_input.display_name,
                legend_input.input_action,
                legend_input.visibility_function,
                on_pressed_callback,
                legend_input.alignment
            )
        end
    end

    function View:_setup_list_grid()
        if self._list_grid then
            self._list_grid = nil
            self:_remove_element('list_grid')
        end

        local grid_settings = self._definitions.list_grid_settings
        self._list_grid = self:_add_element(ViewElementGrid, 'list_grid', 10, grid_settings)
        self:_update_list_grid_position()
    end

    function View:_setup_detail_grid()
        if self._detail_grid then
            self._detail_grid = nil
            self:_remove_element('detail_grid')
        end

        local grid_settings = self._definitions.detail_grid_settings
        self._detail_grid = self:_add_element(ViewElementGrid, 'detail_grid', 10, grid_settings)
        self:_update_detail_grid_position()
    end

    function View:_update_list_grid_position()
        if not self._list_grid then
            return
        end

        local position = self:_scenegraph_world_position(config.prefix .. '_list_content')
        if position then
            self._list_grid:set_pivot_offset(position[1], position[2])
        end
    end

    function View:_update_detail_grid_position()
        if not self._detail_grid then
            return
        end

        local position = self:_scenegraph_world_position(config.prefix .. '_detail_content')
        if position then
            self._detail_grid:set_pivot_offset(position[1], position[2])
        end
    end

    function View:_list_width()
        local grid_settings = self._definitions.list_grid_settings
        return grid_settings and grid_settings.grid_size[1] or 480
    end

    function View:_detail_width()
        local grid_settings = self._definitions.detail_grid_settings
        return grid_settings and grid_settings.grid_size[1] or 600
    end

    function View:_default_matches_search(item, search_text)
        if search_text == '' then
            return true
        end
        local name = item.name or ''
        return name:lower():find(search_text, 1, true) ~= nil
    end

    function View:_default_make_entry(item)
        return {
            widget_type = config.entry_type,
            name = item.name,
            subtext = item.subtext,
            subtext_color = item.subtext_color,
        }
    end

    if config.setup_entries then
        function View:_setup_entries()
            config.setup_entries(self)
        end
    else
        function View:_setup_entries()
            local search_widget = self._widgets_by_name[config.prefix .. '_search']
            local search_text = search_widget and search_widget.content.input_text or ''
            search_text = search_text:lower()

            local matches = config.matches_search or View._default_matches_search
            local make_entry = config.make_entry or View._default_make_entry

            local entries = {}
            for i = 1, #self._list do
                local item = self._list[i]
                if matches(item, search_text) then
                    entries[#entries + 1] = make_entry(item)
                end
            end

            self._filtered_list = entries

            local blueprints = config.make_blueprints(self:_list_width())
            local left_click_callback = callback(self, 'cb_on_list_entry_left_pressed')
            local on_present_callback = callback(self, '_cb_on_list_presented')

            self._list_grid:present_grid_layout(
                entries,
                blueprints,
                left_click_callback,
                nil,
                nil,
                'down',
                on_present_callback
            )
        end
    end

    function View:_cb_on_list_presented()
        local entries = self._filtered_list
        if not entries or #entries == 0 then
            self:_present_detail(nil)
            return
        end

        if config.on_presented then
            config.on_presented(self, entries)
        else
            self._list_grid:select_grid_index(1)
            self._list_grid:scroll_to_grid_index(1)
            self:_select_entry(entries[1])
        end
    end

    function View:cb_on_list_entry_left_pressed(widget, element)
        self:_select_entry(element)
    end

    function View:_select_entry(entry)
        if entry then
            local index = self._list_grid:index_by_element(entry)
            if index then
                self._list_grid:select_grid_index(index)
            end
        end
        if config.on_select_entry then
            config.on_select_entry(self, entry)
        end
        self:_present_detail(entry)
    end

    function View:_present_detail(entry)
        config.present_detail(self, entry)
    end

    function View:cb_on_close_pressed()
        Managers.ui:close_view(self.view_name)
    end

    function View:update(dt, t, input_service)
        local search_widget = self._widgets_by_name[config.prefix .. '_search']
        if search_widget then
            local current_search = search_widget.content.input_text or ''
            if current_search ~= self._last_search_text then
                self._last_search_text = current_search
                self:_setup_entries()
            end
        end

        return View.super.update(self, dt, t, input_service)
    end

    function View:on_exit()
        if self._input_legend_element then
            self._input_legend_element = nil
            self:_remove_element('input_legend')
        end

        if self._list_grid then
            self._list_grid = nil
            self:_remove_element('list_grid')
        end

        if self._detail_grid then
            self._detail_grid = nil
            self:_remove_element('detail_grid')
        end

        self:_release_icon_packages()

        View.super.on_exit(self)
    end

    return View
end

return make_view
