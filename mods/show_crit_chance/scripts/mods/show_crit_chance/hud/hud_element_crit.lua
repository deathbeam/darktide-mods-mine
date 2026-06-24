-- Show Crit Chance mod by mroużon. Ver. 1.1.3
-- Thanks to Zombine, Redbeardt and others for their input into the community. Their work helped me a lot in the process of creating this mod.

local mod = get_mod("show_crit_chance")

local Definitions = mod:io_dofile("show_crit_chance/scripts/mods/show_crit_chance/hud/hud_element_crit_definitions")
local Settings = mod:io_dofile("show_crit_chance/scripts/mods/show_crit_chance/hud/hud_element_crit_settings")

local HudElementCrit = class("HudElementCrit", "HudElementBase")

-- Table of buffs giving 100% crit chance.
-- Keys are buff names, values are functions returning buff validity
local guaranteed_crit_buffs = {
    ["zealot_dash_buff"] = function(...)
        if mod._is_melee then
            return true
        end
        return false
    end,
    ["psyker_guaranteed_ranged_shot_on_stacked"] = function(buff)
        if mod._is_ranged and buff:stack_count() and buff:stack_count() == 5 then
            return true
        end
        return false
    end
}

local _check_for_guaranteed_crit = function(player_unit)
    mod._guaranteed_crit = false

    if not player_unit then
        return
    end

    local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
    if not buff_extension then
        return
    end

	local buffs = buff_extension:buffs()

	for i = #buffs, 1, -1 do
		local buff = buffs[i]
		local buff_template = buff:template()
		local buff_validator = buff_template and guaranteed_crit_buffs[buff_template.name]

		if buff_validator and buff_validator(buff) == true then
			mod._guaranteed_crit = true

			break
		end
	end
end

local _convert_chance_to_text = function(chance)
    local chance_number = tonumber(chance)

    if not chance_number then
        return mod._crit_chance_indicator_icon .. "NaN"
    end

    local percent_value = chance_number * 100

    if mod._show_floating_point then
        local rounded_percent_value = math.floor(percent_value * 100 + 0.5) / 100

        if rounded_percent_value == -0 then
            rounded_percent_value = 0
        end

        return string.format("%s%.2f%%", mod._crit_chance_indicator_icon, rounded_percent_value)
    end

    local rounded_percent = math.floor(percent_value + 0.5)

    return string.format("%s%d%%", mod._crit_chance_indicator_icon, rounded_percent)
end

HudElementCrit.on_resolution_modified = function(self)
	HudElementCrit.super.on_resolution_modified(self)
end

HudElementCrit.init = function(self, parent, draw_layer, start_scale)
	HudElementCrit.super.init(self, parent, draw_layer, start_scale, Definitions)
end

HudElementCrit.destroy = function(self, ui_renderer)
	HudElementCrit.super.destroy(self, ui_renderer)
end

HudElementCrit.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCrit.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	-- Sadly, this require needs to be here because of NetworkConstants :(
    -- Seems like a game code issue
    local CriticalStrike = require("scripts/utilities/attack/critical_strike")
    if not CriticalStrike or not CriticalStrike.chance then
        return
    end

    -- Update widget
	local crit_chance_widget = self._widgets_by_name.crit_chance_indicator
    if crit_chance_widget then
        -- Prevent profile:profile() from trying to execute if invalid
        if not mod._player.profile then
            crit_chance_widget.content.crit_chance_indicator_text = ""
            return
        end

        -- Set visibility
		local visible = true

        if mod._only_in_training_grounds then
			-- Check for Psykhanium
            local game_mode_name = Managers.state.game_mode:game_mode_name()
            visible = game_mode_name == "shooting_range"
		end

		if mod._is_melee == false and mod._is_ranged == false then
			-- We aren't holding any weapon
            visible = false
        end

		crit_chance_widget.style.crit_chance_indicator_text.visible = visible

		if visible then
			-- Calculate crit chance
			_check_for_guaranteed_crit(mod._player.player_unit)

            if mod._guaranteed_crit then
                mod._current_crit_chance = 1.0
            elseif (ScriptUnit.extension(mod._player.player_unit, "buff_system") ~= nil) then
                mod._current_crit_chance = CriticalStrike.chance(mod._player, mod._weapon_handling_template, mod._is_ranged, mod._is_melee)
            end

			-- Update indicator text
       		crit_chance_widget.content.crit_chance_indicator_text = _convert_chance_to_text(mod._current_crit_chance)
		end
    end
end

HudElementCrit.set_offset = function(self, vertical, horizontal)
	self._widgets_by_name.crit_chance_indicator.style.crit_chance_indicator_text.offset = {
		Settings.widget_horizontal_offset + horizontal,
		Settings.widget_vertical_offset + vertical,
		0
	}
end

HudElementCrit.set_text_appearance = function(self, appearance)
	self._widgets_by_name.crit_chance_indicator.style.crit_chance_indicator_text.text_color = appearance
end

HudElementCrit.set_font = function(self, type, size)
    self._widgets_by_name.crit_chance_indicator.style.crit_chance_indicator_text.font_type = type
	self._widgets_by_name.crit_chance_indicator.style.crit_chance_indicator_text.font_size = size
end

return HudElementCrit
