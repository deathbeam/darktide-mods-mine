--[[
    author: dalo_kraff
	
	-----
 
	Copyright 2022 dalo_kraff

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
  to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or
  substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.
 
	-----

	Description: Open various menus from the hub world with hotkeys
--]]

local mod = get_mod("hub_hotkey_menus")

local Promise = require("scripts/foundation/utilities/promise")

-- ##########################################################
-- ################## Variables #############################

local valid_lvls = {
	shooting_range = true,
	hub = true,
}

-- ##########################################################
-- ############## Internal Functions ########################

local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		valid_lvls["shooting_range"] = mod:get("enable_in_pykhanium")
		return valid_lvls[Managers.state.game_mode:game_mode_name()] or false
	end
end

local can_activate_view = function(ui_manager, view)
	return is_in_valid_lvl() and (not ui_manager:chat_using_input()) and (not ui_manager:has_active_view(view))
end

local close_views = function(view, ui_manager)
	if mod:get("close_menu_with_hotkey") then
		local activeViews = ui_manager:active_views()
		for _, active_view in pairs(activeViews) do
			if active_view == view then
				ui_manager:close_all_views()
				return false
			end
		end
	end
	return true
end

local _is_view_loading = false
local function open_view_from_anywhere(view_name)
	local ui_manager = Managers.ui
	
	-- If we're in hub, use the hub interaction approach
	if is_in_valid_lvl() and ui_manager and close_views(view_name, ui_manager) and can_activate_view(ui_manager, view_name) then
		local context = {
			hub_interaction = true
		}
		ui_manager:open_view(view_name, nil, nil, nil, nil, context)
	
	-- If we're in main menu, use the narrative loading approach (like Psych Ward)
	elseif Managers.player and Managers.narrative then
		local player = Managers.player:local_player(1)
		if player and player:profile() then
			local character_id = player:profile().character_id
			local narrative_promise = Managers.narrative:load_character_narrative(character_id)
			
			if not _is_view_loading then
				_is_view_loading = true
				
				Promise.all(narrative_promise):next(function(_)
					_is_view_loading = false
					
					Managers.ui:open_view(view_name, nil, nil, nil, nil, {
						hub_interaction = true,
					})
				end):catch(function()
					_is_view_loading = false
					return
				end)
			end
		end
	end
end

-- ##########################################################
-- ################## Functions #############################

mod.activate_barber_vendor_background_view = function(self)
  open_view_from_anywhere("barber_vendor_background_view")
end

mod.activate_contracts_background_view = function(self)
  open_view_from_anywhere("contracts_background_view")
end

mod.activate_crafting_view = function(self)
  open_view_from_anywhere("crafting_view")
end

mod.activate_credits_vendor_background_view = function(self)
  open_view_from_anywhere("credits_vendor_background_view")
end

mod.activate_inbox_view = function(self)
  open_view_from_anywhere("inbox_view")
end

mod.activate_mission_board_view = function(self)
  open_view_from_anywhere("mission_board_view")
end

mod.activate_store_view = function(self)
  open_view_from_anywhere("store_view")
end

mod.activate_training_grounds_view = function(self)
  open_view_from_anywhere("training_grounds_view")
end

mod.activate_social_view = function(self)
	open_view_from_anywhere("social_menu_view")
end

mod.activate_commissary_view = function(self)
	open_view_from_anywhere("cosmetics_vendor_background_view")
end

mod.activate_penance_overview_view = function(self)
	open_view_from_anywhere("penance_overview_view")
end

mod.activate_havoc_background_view = function(self)
    open_view_from_anywhere("havoc_background_view")
end

-- mod.activate_main_menu_view = function(self)
-- 	activate_hub_view("main_menu_background_view")
-- end



-- ##########################################################
-- ################### Hooks ################################

local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local menu_buttons = {
    { id = "btn_mission_board", label = "Mission Board", func = "activate_mission_board_view" },
    { id = "btn_crafting", label = "Crafting", func = "activate_crafting_view" },
    { id = "btn_contracts", label = "Contracts", func = "activate_contracts_background_view" },
    { id = "btn_training", label = "Training Grounds", func = "activate_training_grounds_view" },
    { id = "btn_barber", label = "Barber", func = "activate_barber_vendor_background_view" },
    { id = "btn_commissary", label = "Commissary", func = "activate_commissary_view" },
    { id = "btn_credits", label = "Marks", func = "activate_credits_vendor_background_view" },
    { id = "btn_store", label = "Premium Store", func = "activate_store_view" },
    { id = "btn_social", label = "Social", func = "activate_social_view" },
    { id = "btn_penance", label = "Penances", func = "activate_penance_overview_view" },
    -- { id = "btn_havoc", label = "Havoc", func = "activate_havoc_background_view" },
    { id = "btn_inbox", label = "Inbox", func = "activate_inbox_view" },
}

local button_size = { 150, 40 }
local button_offset = { 0, button_size[2] + 5, 0 }

-- Hook into main menu view definitions to add buttons
local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)
    if not mod:get("enable_buttons") then
        return
    end
    
    -- Add buttons to scenegraph and widget definitions
    for i, button_info in ipairs(menu_buttons) do
        local parent_button = i == 1 and "character_list_background" or menu_buttons[i - 1].id
        
        definitions.scenegraph_definition[button_info.id] = {
            parent = parent_button,
            vertical_alignment = i == 1 and "top" or "top",
            horizontal_alignment = i == 1 and "right" or "left",
            size = button_size,
            position = i == 1 and { 160, 140, 0 } or button_offset
        }
        
        local button_template = table.clone(ButtonPassTemplates.terminal_button_small)
        local button = UIWidget.create_definition(button_template, button_info.id, {
            text = button_info.label,
            view_name = button_info.func
        })
        
        definitions.widget_definitions[button_info.id] = button
    end
end)

-- Set up button interactions
mod:hook_safe(CLASS.MainMenuView, "_setup_interactions", function(self)
    if not mod:get("enable_buttons") then
        return
    end
    
    local widgets_by_name = self._widgets_by_name
    
    for _, button_info in ipairs(menu_buttons) do
        local widget = widgets_by_name[button_info.id]
        if widget and widget.content then
            local content = widget.content
            if content.view_name then
                content.hotspot.pressed_callback = function()
                    local func_name = content.view_name
                    if func_name and mod[func_name] then
                        mod[func_name](mod)
                    end
                end
            end
        end
    end
end)

-- ##########################################################
-- ################### Script ###############################

-- ##########################################################
