local mod = get_mod("KillStats")

local Breed = mod:original_require("scripts/utilities/breed")
local BuffTemplates = mod:original_require("scripts/settings/buff/buff_templates")

local function _get_gameplay_time()
	return Managers.time and Managers.time:has_timer("gameplay") and Managers.time:time("gameplay") or 0
end

local function _get_buff_icon(buff_template_name)
	local template = BuffTemplates[buff_template_name]
	if not template then
		return nil
	end
	
	if template.hide_icon_in_hud then
		return nil
	end
	
	if template.hud_icon then
		return template.hud_icon
	end
	
	return nil
end

local function _should_show_buff(buff_template_name, uptime_percent, duration, min_uptime_pct)
	local template = BuffTemplates[buff_template_name]
	if not template then
		return uptime_percent < 99.9 and uptime_percent >= min_uptime_pct
	end
	
	if not template.hud_icon then
		return false
	end
	
	if template.hide_icon_in_hud then
		return false
	end
	
	if template.max_duration or template.duration then
		return uptime_percent >= min_uptime_pct
	end
	
	if uptime_percent < 99.9 and uptime_percent >= min_uptime_pct then
		return true
	end
	
	return false
end

local KillStatsTracker = class("KillStatsTracker")

function KillStatsTracker:init()
	self._is_open = false
	self._session_stats = self:_create_empty_stats()
	self._session_start = 0
	self._active_buffs = {}
	self._buff_uptime = {}
	self._last_kill_time = 0
end

function KillStatsTracker:_create_empty_stats()
	return {
		total_damage = 0,
		melee_damage = 0,
		ranged_damage = 0,
		crit_damage = 0,
		weakspot_damage = 0,
		bleed_damage = 0,
		burn_damage = 0,
		toxin_damage = 0,
		kills = 0,
		crit_kills = 0,
		weakspot_kills = 0,
		elite_kills = 0,
		special_kills = 0,
		total_hits = 0,
		crit_hits = 0,
		weakspot_hits = 0,
	}
end

function KillStatsTracker:open()
	local input_manager = Managers.input
	local name = self.__class_name

	if not input_manager:cursor_active() then
		input_manager:push_cursor(name)
	end

	self._is_open = true
	Imgui.open_imgui()
end

function KillStatsTracker:close()
	local input_manager = Managers.input
	local name = self.__class_name

	if input_manager:cursor_active() then
		input_manager:pop_cursor(name)
	end

	self._is_open = false
	Imgui.close_imgui()
end

function KillStatsTracker:reset_stats()
	self._session_stats = self:_create_empty_stats()
	self._session_start = _get_gameplay_time()
	self._active_buffs = {}
	self._buff_uptime = {}
	self._last_kill_time = 0
end

function KillStatsTracker:_get_session_duration()
	if self._session_start == 0 then
		return 0
	end
	return _get_gameplay_time() - self._session_start
end

function KillStatsTracker:_track_damage(damage, attack_type, is_critical, is_weakspot)
	local stats = self._session_stats
	
	stats.total_damage = stats.total_damage + damage
	stats.total_hits = stats.total_hits + 1
	
	if attack_type == "melee" then
		stats.melee_damage = stats.melee_damage + damage
	elseif attack_type == "ranged" then
		stats.ranged_damage = stats.ranged_damage + damage
	end
	
	if is_critical then
		stats.crit_damage = stats.crit_damage + damage
		stats.crit_hits = stats.crit_hits + 1
	end
	
	if is_weakspot then
		stats.weakspot_damage = stats.weakspot_damage + damage
		stats.weakspot_hits = stats.weakspot_hits + 1
	end
end

function KillStatsTracker:_track_kill(breed_type, is_critical, is_weakspot)
	local stats = self._session_stats
	
	stats.kills = stats.kills + 1
	self._last_kill_time = _get_gameplay_time()
	
	if is_critical then
		stats.crit_kills = stats.crit_kills + 1
	end
	
	if is_weakspot then
		stats.weakspot_kills = stats.weakspot_kills + 1
	end
	
	if breed_type == "elite" then
		stats.elite_kills = stats.elite_kills + 1
	elseif breed_type == "special" then
		stats.special_kills = stats.special_kills + 1
	end
end

function KillStatsTracker:_track_buff(buff_name, dt)
	if not self._active_buffs[buff_name] then
		self._active_buffs[buff_name] = true
		self._buff_uptime[buff_name] = self._buff_uptime[buff_name] or 0
	end
	self._buff_uptime[buff_name] = self._buff_uptime[buff_name] + dt
end

function KillStatsTracker:_update_buffs(dt)
	local player = Managers.player:local_player_safe(1)
	if not player then
		return
	end
	
	local unit = player.player_unit
	if not unit then
		return
	end
	
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if not buff_extension then
		return
	end
	
	local current_buffs = {}
	local buffs = buff_extension:buffs()
	for i = 1, #buffs do
		local buff = buffs[i]
		if buff and buff:template_name() then
			local buff_name = buff:template_name()
			current_buffs[buff_name] = true
			
			if not self._buff_uptime[buff_name] then
				self._buff_uptime[buff_name] = 0
			end
		end
	end
	
	for buff_name, _ in pairs(current_buffs) do
		self._buff_uptime[buff_name] = self._buff_uptime[buff_name] + dt
	end
	
	for buff_name, _ in pairs(self._active_buffs) do
		if not current_buffs[buff_name] then
			self._active_buffs[buff_name] = nil
		end
	end
	
	self._active_buffs = current_buffs
end

function KillStatsTracker:update(dt)
	local current_time = _get_gameplay_time()
	if current_time == 0 then
		return
	end
	
	local show_after_kill = mod:get("show_after_kill")
	local kill_display_duration = mod:get("kill_display_duration") or 5
	local show_on_kill = show_after_kill and (current_time - self._last_kill_time) < kill_display_duration

	self:_update_buffs(dt)

	local show_stats = self._is_open or show_on_kill
	
	if not show_stats then
		return
	end

	Imgui.set_next_window_size(700, 800, "FirstUseEver")
	local _, closed = Imgui.begin_window("Kill Stats Tracker", "always_auto_resize")

	if closed then
		self:close()
	end

	local duration = self:_get_session_duration()
	local stats = self._session_stats
	
	Imgui.text(string.format("Session Duration: %.1f seconds", duration))
	Imgui.same_line()
	if Imgui.button("Reset Stats") then
		self:reset_stats()
	end
	
	Imgui.spacing()
	
	if Imgui.collapsing_header("Damage Stats", "default_open") then
		Imgui.indent()
		local dps = duration > 0 and stats.total_damage / duration or 0
		Imgui.text(string.format("Total Damage: %d", stats.total_damage))
		Imgui.same_line()
		Imgui.text_colored(0, 255, 0, 255, string.format("(%.1f DPS)", dps))
		
		Imgui.spacing()
		local melee_pct = stats.total_damage > 0 and (stats.melee_damage / stats.total_damage * 100) or 0
		local ranged_pct = stats.total_damage > 0 and (stats.ranged_damage / stats.total_damage * 100) or 0
		
		Imgui.text(string.format("Melee: %d", stats.melee_damage))
		Imgui.same_line()
		Imgui.progress_bar(melee_pct / 100, 150, 20, string.format("%.1f%%", melee_pct))
		
		Imgui.text(string.format("Ranged: %d", stats.ranged_damage))
		Imgui.same_line()
		Imgui.progress_bar(ranged_pct / 100, 150, 20, string.format("%.1f%%", ranged_pct))
		
		Imgui.spacing()
		local crit_pct = stats.total_damage > 0 and (stats.crit_damage / stats.total_damage * 100) or 0
		local weakspot_pct = stats.total_damage > 0 and (stats.weakspot_damage / stats.total_damage * 100) or 0
		
		Imgui.text(string.format("Critical: %d", stats.crit_damage))
		Imgui.same_line()
		Imgui.progress_bar(crit_pct / 100, 150, 20, string.format("%.1f%%", crit_pct))
		
		Imgui.text(string.format("Weakspot: %d", stats.weakspot_damage))
		Imgui.same_line()
		Imgui.progress_bar(weakspot_pct / 100, 150, 20, string.format("%.1f%%", weakspot_pct))
		
		Imgui.unindent()
	end
	
	Imgui.spacing()
	
	if Imgui.collapsing_header("DOT Damage", "default_open") then
		Imgui.indent()
		
		local total_dot = stats.bleed_damage + stats.burn_damage + stats.toxin_damage
		local bleed_pct = total_dot > 0 and (stats.bleed_damage / total_dot * 100) or 0
		local burn_pct = total_dot > 0 and (stats.burn_damage / total_dot * 100) or 0
		local toxin_pct = total_dot > 0 and (stats.toxin_damage / total_dot * 100) or 0
		
		Imgui.text(string.format("Bleed: %d", stats.bleed_damage))
		Imgui.same_line()
		Imgui.progress_bar(bleed_pct / 100, 150, 20, string.format("%.1f%%", bleed_pct))
		
		Imgui.text(string.format("Burn: %d", stats.burn_damage))
		Imgui.same_line()
		Imgui.progress_bar(burn_pct / 100, 150, 20, string.format("%.1f%%", burn_pct))
		
		Imgui.text(string.format("Toxin: %d", stats.toxin_damage))
		Imgui.same_line()
		Imgui.progress_bar(toxin_pct / 100, 150, 20, string.format("%.1f%%", toxin_pct))
		
		Imgui.unindent()
	end
	
	Imgui.spacing()
	
	if Imgui.collapsing_header("Kills", "default_open") then
		Imgui.indent()
		Imgui.text(string.format("Total: %d", stats.kills))
		Imgui.text(string.format("Elite: %d", stats.elite_kills))
		Imgui.text(string.format("Special: %d", stats.special_kills))
		
		Imgui.spacing()
		local crit_kill_pct = stats.kills > 0 and (stats.crit_kills / stats.kills * 100) or 0
		local weakspot_kill_pct = stats.kills > 0 and (stats.weakspot_kills / stats.kills * 100) or 0
		
		Imgui.text("Crit Kills:")
		Imgui.same_line()
		Imgui.progress_bar(crit_kill_pct / 100, 150, 20, string.format("%d (%.1f%%)", stats.crit_kills, crit_kill_pct))
		
		Imgui.text("Weakspot Kills:")
		Imgui.same_line()
		Imgui.progress_bar(weakspot_kill_pct / 100, 150, 20, string.format("%d (%.1f%%)", stats.weakspot_kills, weakspot_kill_pct))
		
		Imgui.unindent()
	end
	
	Imgui.spacing()
	
	if Imgui.collapsing_header("Hit Stats") then
		Imgui.indent()
		Imgui.text(string.format("Total Hits: %d", stats.total_hits))
		
		local crit_hit_rate = stats.total_hits > 0 and (stats.crit_hits / stats.total_hits * 100) or 0
		local weakspot_hit_rate = stats.total_hits > 0 and (stats.weakspot_hits / stats.total_hits * 100) or 0
		
		Imgui.text("Crit Rate:")
		Imgui.same_line()
		Imgui.progress_bar(crit_hit_rate / 100, 200, 20, string.format("%.1f%%", crit_hit_rate))
		
		Imgui.text("Weakspot Rate:")
		Imgui.same_line()
		Imgui.progress_bar(weakspot_hit_rate / 100, 200, 20, string.format("%.1f%%", weakspot_hit_rate))
		
		Imgui.unindent()
	end
	
	if duration > 0 then
		Imgui.spacing()
		
		if Imgui.collapsing_header("Buff Uptime") then
			Imgui.indent()
			
			local min_uptime_pct = mod:get("min_buff_uptime") or 0
			
			local sorted_buffs = {}
			for buff_name, uptime in pairs(self._buff_uptime) do
				local uptime_percent = (uptime / duration) * 100
				if _should_show_buff(buff_name, uptime_percent, duration, min_uptime_pct) then
					local icon = _get_buff_icon(buff_name)
					table.insert(sorted_buffs, {
						name = buff_name,
						uptime = uptime,
						icon = icon
					})
				end
			end
			table.sort(sorted_buffs, function(a, b) return a.uptime > b.uptime end)
			
			if #sorted_buffs > 0 then
				for i, buff_data in ipairs(sorted_buffs) do
					local uptime_percent = (buff_data.uptime / duration) * 100
					
					if buff_data.icon then
						Imgui.image_button(buff_data.icon, 32, 32, 255, 255, 255, 1)
						Imgui.same_line()
					end
					
					Imgui.text(buff_data.name)
					Imgui.same_line()
					Imgui.progress_bar(math.min(uptime_percent / 100, 1.0), 200, 20, string.format("%.1f%%", uptime_percent))
				end
			else
				Imgui.text("No buffs tracked (permanent buffs hidden)")
			end
			
			Imgui.unindent()
		end
	end

	Imgui.end_window()
end

local tracker = KillStatsTracker:new()

function mod.update(dt)
	tracker:update(dt)
end

function mod.toggle_kill_stats()
	if tracker._is_open then
		tracker:close()
	else
		tracker:open()
	end
end

function mod.on_game_state_changed(status, state_name)
	if status == "enter" and state_name == "StateGameplay" then
		tracker:reset_stats()
	end
end

mod:hook(CLASS.AttackReportManager, "add_attack_result",
function(func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
	
	local player = Managers.player:local_player_safe(1)
	if player then
		local player_unit = player.player_unit
		if player_unit and attacking_unit == player_unit then
			if tracker._session_start == 0 then
				tracker._session_start = _get_gameplay_time()
			end
			
			local attack_category = attack_type or "melee"
			tracker:_track_damage(damage, attack_category, is_critical_strike, hit_weakspot)
			
			if damage_profile then
				local profile_name = damage_profile.name
				local stats = tracker._session_stats
				
				if profile_name then
					if string.find(profile_name:lower(), "bleed") then
						stats.bleed_damage = stats.bleed_damage + damage
					elseif string.find(profile_name:lower(), "burn") or string.find(profile_name:lower(), "fire") or string.find(profile_name:lower(), "flamer") then
						stats.burn_damage = stats.burn_damage + damage
					elseif string.find(profile_name:lower(), "toxin") or string.find(profile_name:lower(), "neurotoxin") then
						stats.toxin_damage = stats.toxin_damage + damage
					end
				end
			end
			
			if attack_result == "died" then
				local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
				local breed_or_nil = unit_data_extension and unit_data_extension:breed()
				
				if breed_or_nil then
					local breed_type = "normal"
					if breed_or_nil.tags and breed_or_nil.tags.elite then
						breed_type = "elite"
					elseif breed_or_nil.tags and breed_or_nil.tags.special then
						breed_type = "special"
					end
					
					tracker:_track_kill(breed_type, is_critical_strike, hit_weakspot)
				end
			end
		end
	end
	
	return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
end)

mod:hook("UIManager", "using_input", function(func, ...)
	return tracker._is_open or func(...)
end)
