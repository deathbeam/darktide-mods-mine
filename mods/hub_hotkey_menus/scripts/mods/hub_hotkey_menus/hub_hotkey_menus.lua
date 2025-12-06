local mod = get_mod("hub_hotkey_menus")

local valid_lvls = {
	shooting_range = true,
	hub = true,
}

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

local activate_hub_view = function(view)
	local ui_manager = Managers.ui

	if ui_manager and close_views(view, ui_manager) and can_activate_view(ui_manager, view) then
		local context = {
			hub_interaction = true
		}

		ui_manager:open_view(view, nil, nil, nil, nil, context)
	end
end

mod.activate_barber_vendor_background_view = function(self)
  activate_hub_view("barber_vendor_background_view")
end

mod.activate_contracts_background_view = function(self)
  activate_hub_view("contracts_background_view")
end

mod.activate_crafting_view = function(self)
  activate_hub_view("crafting_view")
end

mod.activate_credits_vendor_background_view = function(self)
  activate_hub_view("credits_vendor_background_view")
end

mod.activate_inbox_view = function(self)
  activate_hub_view("inbox_view")
end

mod.activate_mission_board_view = function(self)
  activate_hub_view("mission_board_view")
end

mod.activate_store_view = function(self)
  activate_hub_view("store_view")
end

mod.activate_training_grounds_view = function(self)
  activate_hub_view("training_grounds_view")
end

mod.activate_social_view = function(self)
	activate_hub_view("social_menu_view")
end

mod.activate_commissary_view = function(self)
	activate_hub_view("cosmetics_vendor_background_view")
end

mod.activate_penance_overview_view = function(self)
	activate_hub_view("penance_overview_view")
end

mod.activate_havoc_background_view = function(self)
	activate_hub_view("havoc_background_view")
end

local function insert_after(list, predicate, item)
	local new_list = table.clone(list)
	
	for i, entry in ipairs(new_list) do
		if predicate(entry) then
			table.insert(new_list, i + 1, item)
			return new_list
		end
	end
	
	table.insert(new_list, item)
	return new_list
end

local function is_in_hub()
	if Managers and Managers.state and Managers.state.game_mode then
		local game_mode_name = Managers.state.game_mode:game_mode_name()
		return game_mode_name == "hub" or (game_mode_name == "shooting_range" and mod:get("enable_in_pykhanium"))
	end
	return false
end

local function is_social_button(item)
	return item.text == "loc_social_view_display_name"
end

local hub_menu_definitions = {
	{
		dev_text = mod:localize("open_contracts_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_contracts_background_view()
		end,
	},
	{
		dev_text = mod:localize("open_crafting_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_crafting_view()
		end,
	},
	{
		dev_text = mod:localize("open_commissary_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_commissary_view()
		end,
	},
	{
		dev_text = mod:localize("open_credits_vendor_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_credits_vendor_background_view()
		end,
	},
	{
		dev_text = mod:localize("open_barber_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_barber_vendor_background_view()
		end,
	},
	{
		dev_text = mod:localize("open_mission_board_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_mission_board_view()
		end,
	},
	{
		dev_text = mod:localize("open_training_grounds_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_training_grounds_view()
		end,
	},
	{
		dev_text = mod:localize("open_havoc_background_view_key"),
		type = "button",
		hide_icon = true,
		validation_function = function()
			return is_in_hub()
		end,
		trigger_function = function()
			mod:activate_havoc_background_view()
		end,
	},
}

mod:hook_require("scripts/ui/views/system_view/system_view_content_list", function(instance)
	if not mod:get("show_in_system_menu") then
		return
	end
	
	for _, menu_def in ipairs(hub_menu_definitions) do
		if not table.find_by_key(instance.default, "dev_text", menu_def.dev_text) then
			instance.default = insert_after(instance.default, is_social_button, menu_def)
		end
	end
	
	for _, menu_def in ipairs(hub_menu_definitions) do
		if not table.find_by_key(instance.StateMainMenu, "dev_text", menu_def.dev_text) then
			instance.StateMainMenu = insert_after(instance.StateMainMenu, is_social_button, menu_def)
		end
	end
end)

mod:hook_require("scripts/ui/views/system_view/system_view_content_blueprints", function(blueprints)
	local original_button_init = blueprints.button.init
	
	blueprints.button.init = function(parent, widget, element, callback_name, disabled)
		original_button_init(parent, widget, element, callback_name, disabled)
		
		if element.hide_icon and widget.style.icon then
			widget.style.icon.visible = false
		end
	end
end)
