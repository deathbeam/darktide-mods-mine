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

local function _show_damage_stats(stats, prefix)
	prefix = prefix or ""
	
	Imgui.text(string.format("%sTotal Damage: %d", prefix, stats.total_damage))
	Imgui.same_line()
	if stats.total_hits > 0 then
		Imgui.text(string.format("(Avg: %.0f per hit)", stats.total_damage / stats.total_hits))
	end
	
	if stats.melee_damage > 0 or stats.ranged_damage > 0 then
		Imgui.indent()
		if stats.melee_damage > 0 then
			Imgui.text(string.format("%sMelee: %d (%.1f%%)", prefix, stats.melee_damage, 
				stats.total_damage > 0 and (stats.melee_damage / stats.total_damage * 100) or 0))
		end
		if stats.ranged_damage > 0 then
			Imgui.text(string.format("%sRanged: %d (%.1f%%)", prefix, stats.ranged_damage, 
				stats.total_damage > 0 and (stats.ranged_damage / stats.total_damage * 100) or 0))
		end
		Imgui.unindent()
	end
	
	if stats.crit_damage > 0 then
		Imgui.text(string.format("%sCrit Damage: %d (%.1f%% of total)", prefix, stats.crit_damage,
			stats.total_damage > 0 and (stats.crit_damage / stats.total_damage * 100) or 0))
	end
	
	if stats.weakspot_damage > 0 then
		Imgui.text(string.format("%sWeakspot Damage: %d (%.1f%% of total)", prefix, stats.weakspot_damage,
			stats.total_damage > 0 and (stats.weakspot_damage / stats.total_damage * 100) or 0))
	end
	
	local dot_damage = stats.bleed_damage + stats.burn_damage + stats.toxin_damage
	if dot_damage > 0 then
		Imgui.text(string.format("%sDOT Damage: %d (%.1f%% of total)", prefix, dot_damage,
			stats.total_damage > 0 and (dot_damage / stats.total_damage * 100) or 0))
		Imgui.indent()
		if stats.bleed_damage > 0 then
			Imgui.text(string.format("%sBleed: %d", prefix, stats.bleed_damage))
		end
		if stats.burn_damage > 0 then
			Imgui.text(string.format("%sBurn: %d", prefix, stats.burn_damage))
		end
		if stats.toxin_damage > 0 then
			Imgui.text(string.format("%sToxin: %d", prefix, stats.toxin_damage))
		end
		Imgui.unindent()
	end
end

local function _show_hit_stats(stats, prefix)
	prefix = prefix or ""
	
	Imgui.text(string.format("%sTotal Hits: %d", prefix, stats.total_hits))
	
	if stats.crit_hits > 0 then
		Imgui.text(string.format("%sCrit Hits: %d (%.1f%%)", prefix, stats.crit_hits,
			stats.total_hits > 0 and (stats.crit_hits / stats.total_hits * 100) or 0))
	end
	
	if stats.weakspot_hits > 0 then
		Imgui.text(string.format("%sWeakspot Hits: %d (%.1f%%)", prefix, stats.weakspot_hits,
			stats.total_hits > 0 and (stats.weakspot_hits / stats.total_hits * 100) or 0))
	end
end

local function _engagement_to_stats(engagement)
	return {
		total_damage = engagement.damage_dealt,
		melee_damage = engagement.melee_damage,
		ranged_damage = engagement.ranged_damage,
		crit_damage = engagement.crit_damage,
		weakspot_damage = engagement.weakspot_damage,
		bleed_damage = engagement.bleed_damage,
		burn_damage = engagement.burn_damage,
		toxin_damage = engagement.toxin_damage,
		total_hits = engagement.hits,
		crit_hits = engagement.crit_hits,
		weakspot_hits = engagement.weakspot_hits,
	}
end

local function _engagement_buff_uptime(engagement)
	local uptime_table = {}
	for buff_name, buff_data in pairs(engagement.buffs or {}) do
		uptime_table[buff_name] = buff_data.uptime or 0
	end
	return uptime_table
end

local function _show_complete_stats(stats, duration, buff_uptime, title_prefix)
	title_prefix = title_prefix or ""
	
	Imgui.spacing()
	
	if Imgui.collapsing_header(title_prefix .. "Damage Stats", "default_open") then
		Imgui.indent()
		
		local dps = duration > 0 and stats.total_damage / duration or 0
		Imgui.text(string.format("Total Damage: %d", stats.total_damage))
		if duration > 0 then
			Imgui.same_line()
			Imgui.text_colored(0, 255, 0, 255, string.format("(%.1f DPS)", dps))
		end
		
		Imgui.spacing()
		local melee_pct = stats.total_damage > 0 and (stats.melee_damage / stats.total_damage * 100) or 0
		local ranged_pct = stats.total_damage > 0 and (stats.ranged_damage / stats.total_damage * 100) or 0
		
		if stats.melee_damage > 0 then
			Imgui.text(string.format("Melee: %d", stats.melee_damage))
			Imgui.same_line()
			Imgui.progress_bar(melee_pct / 100, 150, 20, string.format("%.1f%%", melee_pct))
		end
		
		if stats.ranged_damage > 0 then
			Imgui.text(string.format("Ranged: %d", stats.ranged_damage))
			Imgui.same_line()
			Imgui.progress_bar(ranged_pct / 100, 150, 20, string.format("%.1f%%", ranged_pct))
		end
		
		Imgui.spacing()
		local crit_pct = stats.total_damage > 0 and (stats.crit_damage / stats.total_damage * 100) or 0
		local weakspot_pct = stats.total_damage > 0 and (stats.weakspot_damage / stats.total_damage * 100) or 0
		
		if stats.crit_damage > 0 then
			Imgui.text(string.format("Critical: %d", stats.crit_damage))
			Imgui.same_line()
			Imgui.progress_bar(crit_pct / 100, 150, 20, string.format("%.1f%%", crit_pct))
		end
		
		if stats.weakspot_damage > 0 then
			Imgui.text(string.format("Weakspot: %d", stats.weakspot_damage))
			Imgui.same_line()
			Imgui.progress_bar(weakspot_pct / 100, 150, 20, string.format("%.1f%%", weakspot_pct))
		end
		
		Imgui.unindent()
	end
	
	Imgui.spacing()
	
	local total_dot = stats.bleed_damage + stats.burn_damage + stats.toxin_damage
	if total_dot > 0 and Imgui.collapsing_header(title_prefix .. "DOT Damage", "default_open") then
		Imgui.indent()
		
		local bleed_pct = total_dot > 0 and (stats.bleed_damage / total_dot * 100) or 0
		local burn_pct = total_dot > 0 and (stats.burn_damage / total_dot * 100) or 0
		local toxin_pct = total_dot > 0 and (stats.toxin_damage / total_dot * 100) or 0
		
		if stats.bleed_damage > 0 then
			Imgui.text(string.format("Bleed: %d", stats.bleed_damage))
			Imgui.same_line()
			Imgui.progress_bar(bleed_pct / 100, 150, 20, string.format("%.1f%%", bleed_pct))
		end
		
		if stats.burn_damage > 0 then
			Imgui.text(string.format("Burn: %d", stats.burn_damage))
			Imgui.same_line()
			Imgui.progress_bar(burn_pct / 100, 150, 20, string.format("%.1f%%", burn_pct))
		end
		
		if stats.toxin_damage > 0 then
			Imgui.text(string.format("Toxin: %d", stats.toxin_damage))
			Imgui.same_line()
			Imgui.progress_bar(toxin_pct / 100, 150, 20, string.format("%.1f%%", toxin_pct))
		end
		
		Imgui.unindent()
	end
	
	Imgui.spacing()
	
	if Imgui.collapsing_header(title_prefix .. "Hit Stats") then
		Imgui.indent()
		
		Imgui.text(string.format("Total Hits: %d", stats.total_hits))
		
		local crit_hit_rate = stats.total_hits > 0 and (stats.crit_hits / stats.total_hits * 100) or 0
		local weakspot_hit_rate = stats.total_hits > 0 and (stats.weakspot_hits / stats.total_hits * 100) or 0
		
		if stats.crit_hits > 0 then
			Imgui.text("Crit Rate:")
			Imgui.same_line()
			Imgui.progress_bar(crit_hit_rate / 100, 200, 20, string.format("%.1f%%", crit_hit_rate))
		end
		
		if stats.weakspot_hits > 0 then
			Imgui.text("Weakspot Rate:")
			Imgui.same_line()
			Imgui.progress_bar(weakspot_hit_rate / 100, 200, 20, string.format("%.1f%%", weakspot_hit_rate))
		end
		
		Imgui.unindent()
	end
	
	if duration > 0 and buff_uptime then
		Imgui.spacing()
		
		if Imgui.collapsing_header(title_prefix .. "Buff Uptime") then
			Imgui.indent()
			
			local min_uptime_pct = mod:get("min_buff_uptime") or 0
			
			local sorted_buffs = {}
			for buff_name, uptime in pairs(buff_uptime) do
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
end

local KillStatsTracker = class("KillStatsTracker")

function KillStatsTracker:init()
	self._is_open = false
	self._active_buffs = {}
	self._buff_uptime = {}
	self._last_kill_time = 0
	self._engagements = {}
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
	self._active_buffs = {}
	self._buff_uptime = {}
	self._last_kill_time = 0
	self._engagements = {}
end

function KillStatsTracker:_get_session_duration()
	if #self._engagements == 0 then
		return 0
	end
	
	local first_start = self._engagements[1].start_time
	local last_end = _get_gameplay_time()
	
	for _, engagement in ipairs(self._engagements) do
		if engagement.end_time and engagement.end_time > last_end then
			last_end = engagement.end_time
		end
	end
	
	return last_end - first_start
end

function KillStatsTracker:_calculate_session_stats()
	local stats = {
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
	
	for _, engagement in ipairs(self._engagements) do
		stats.total_damage = stats.total_damage + engagement.damage_dealt
		stats.total_hits = stats.total_hits + engagement.hits
		stats.crit_hits = stats.crit_hits + engagement.crit_hits
		stats.weakspot_hits = stats.weakspot_hits + engagement.weakspot_hits
		
		if not engagement.in_progress then
			stats.kills = stats.kills + 1
		end
		
		if engagement.melee_damage then
			stats.melee_damage = stats.melee_damage + engagement.melee_damage
		end
		if engagement.ranged_damage then
			stats.ranged_damage = stats.ranged_damage + engagement.ranged_damage
		end
		if engagement.crit_damage then
			stats.crit_damage = stats.crit_damage + engagement.crit_damage
		end
		if engagement.weakspot_damage then
			stats.weakspot_damage = stats.weakspot_damage + engagement.weakspot_damage
		end
		if engagement.bleed_damage then
			stats.bleed_damage = stats.bleed_damage + engagement.bleed_damage
		end
		if engagement.burn_damage then
			stats.burn_damage = stats.burn_damage + engagement.burn_damage
		end
		if engagement.toxin_damage then
			stats.toxin_damage = stats.toxin_damage + engagement.toxin_damage
		end
		
		if not engagement.in_progress then
			if engagement.had_crit then
				stats.crit_kills = stats.crit_kills + 1
			end
			if engagement.had_weakspot then
				stats.weakspot_kills = stats.weakspot_kills + 1
			end
			
			if engagement.breed_type == "elite" then
				stats.elite_kills = stats.elite_kills + 1
			elseif engagement.breed_type == "special" then
				stats.special_kills = stats.special_kills + 1
			end
		end
	end
	
	return stats
end

function KillStatsTracker:_start_enemy_engagement(unit, breed_name)
	for _, engagement in ipairs(self._engagements) do
		if engagement.unit == unit and engagement.in_progress then
			return
		end
	end
	
	local current_time = _get_gameplay_time()
	local engagement = {
		unit = unit,
		breed_name = breed_name,
		breed_type = nil,
		start_time = current_time,
		end_time = nil,
		duration = 0,
		in_progress = true,
		damage_dealt = 0,
		melee_damage = 0,
		ranged_damage = 0,
		crit_damage = 0,
		weakspot_damage = 0,
		bleed_damage = 0,
		burn_damage = 0,
		toxin_damage = 0,
		hits = 0,
		crit_hits = 0,
		weakspot_hits = 0,
		had_crit = false,
		had_weakspot = false,
		dps = 0,
		buffs = {}
	}
	
	for buff_name, _ in pairs(self._active_buffs) do
		engagement.buffs[buff_name] = {
			uptime = 0,
			uptime_percent = 0
		}
	end
	
	table.insert(self._engagements, engagement)
end

function KillStatsTracker:_find_engagement(unit)
	for _, engagement in ipairs(self._engagements) do
		if engagement.unit == unit and engagement.in_progress then
			return engagement
		end
	end
	return nil
end

function KillStatsTracker:_track_enemy_damage(unit, damage, attack_type, is_critical, is_weakspot, damage_type)
	local engagement = self:_find_engagement(unit)
	if not engagement then
		return
	end
	
	engagement.damage_dealt = engagement.damage_dealt + damage
	engagement.hits = engagement.hits + 1
	
	if attack_type == "melee" then
		engagement.melee_damage = engagement.melee_damage + damage
	elseif attack_type == "ranged" then
		engagement.ranged_damage = engagement.ranged_damage + damage
	end
	
	if is_critical then
		engagement.crit_damage = engagement.crit_damage + damage
		engagement.crit_hits = engagement.crit_hits + 1
		engagement.had_crit = true
	end
	
	if is_weakspot then
		engagement.weakspot_damage = engagement.weakspot_damage + damage
		engagement.weakspot_hits = engagement.weakspot_hits + 1
		engagement.had_weakspot = true
	end
	
	if damage_type == "bleed" then
		engagement.bleed_damage = engagement.bleed_damage + damage
	elseif damage_type == "burn" then
		engagement.burn_damage = engagement.burn_damage + damage
	elseif damage_type == "toxin" then
		engagement.toxin_damage = engagement.toxin_damage + damage
	end
end

function KillStatsTracker:_finish_enemy_engagement(unit, breed_type)
	local engagement = self:_find_engagement(unit)
	if not engagement then
		return
	end
	
	local current_time = _get_gameplay_time()
	engagement.end_time = current_time
	engagement.duration = current_time - engagement.start_time
	engagement.breed_type = breed_type
	engagement.in_progress = false
	engagement.dps = engagement.duration > 0 and engagement.damage_dealt / engagement.duration or 0
	
	for buff_name, buff_data in pairs(engagement.buffs) do
		if buff_data.uptime > 0 then
			buff_data.uptime_percent = engagement.duration > 0 and (buff_data.uptime / engagement.duration * 100) or 0
		end
	end
	
	self._last_kill_time = current_time
end

function KillStatsTracker:_update_enemy_buffs(dt)
	local current_time = _get_gameplay_time()
	
	for _, engagement in ipairs(self._engagements) do
		if engagement.in_progress then
			if ALIVE[engagement.unit] then
				engagement.duration = current_time - engagement.start_time
				engagement.dps = engagement.duration > 0 and engagement.damage_dealt / engagement.duration or 0
				
				for buff_name, _ in pairs(self._active_buffs) do
					if not engagement.buffs[buff_name] then
						engagement.buffs[buff_name] = {
							uptime = 0,
							uptime_percent = 0
						}
					end
					engagement.buffs[buff_name].uptime = engagement.buffs[buff_name].uptime + dt
					engagement.buffs[buff_name].uptime_percent = engagement.duration > 0 and (engagement.buffs[buff_name].uptime / engagement.duration * 100) or 0
				end
			else
				engagement.in_progress = false
				engagement.end_time = current_time
				engagement.duration = current_time - engagement.start_time
				engagement.dps = engagement.duration > 0 and engagement.damage_dealt / engagement.duration or 0
			end
		end
	end
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
	
	self:_update_enemy_buffs(dt)
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
	local stats = self:_calculate_session_stats()
	
	Imgui.text(string.format("Session Duration: %.1f seconds", duration))
	Imgui.same_line()
	if Imgui.button("Reset Stats") then
		self:reset_stats()
	end
	
	Imgui.text(string.format("Kills: %d (Elite: %d, Special: %d)", 
		stats.kills, stats.elite_kills, stats.special_kills))
	
	if duration > 0 and stats.total_damage > 0 then
		Imgui.text_colored(0, 255, 0, 255, string.format("Session DPS: %.0f", stats.total_damage / duration))
	end
	
	Imgui.spacing()
	Imgui.separator()
	
	_show_complete_stats(stats, duration, self._buff_uptime, "Session ")
	
	if #self._engagements > 0 then
		Imgui.spacing()
		
		if Imgui.collapsing_header("Engagements") then
			Imgui.indent()
			
			local max_display = mod:get("max_kill_history") or 10
			local displayed = 0
			
			for i = #self._engagements, 1, -1 do
				if displayed >= max_display then
					break
				end
				
				local engagement = self._engagements[i]
				
				local status = engagement.in_progress and "IN PROGRESS" or "KILLED"
				local breed_type_str = engagement.breed_type or "unknown"
				local header_text = string.format("#%d: %s [%s] (%s) - %.1fs - %d dmg (%.0f DPS)", 
					i, engagement.breed_name, status, breed_type_str, engagement.duration, engagement.damage_dealt, engagement.dps)
				
				if Imgui.tree_node(header_text) then
					local eng_stats = _engagement_to_stats(engagement)
					local eng_buffs = _engagement_buff_uptime(engagement)
					
					_show_complete_stats(eng_stats, engagement.duration, eng_buffs, "")
					
					Imgui.tree_pop()
				end
				
				displayed = displayed + 1
			end
			
			if #self._engagements > max_display then
				Imgui.text(string.format("... and %d more engagements", #self._engagements - max_display))
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
			local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
			local breed_or_nil = unit_data_extension and unit_data_extension:breed()
			
			if breed_or_nil then
				tracker:_start_enemy_engagement(attacked_unit, breed_or_nil.name)
				
				local damage_type_str = nil
				if damage_profile then
					local profile_name = damage_profile.name
					if profile_name then
						if string.find(profile_name:lower(), "bleed") then
							damage_type_str = "bleed"
						elseif string.find(profile_name:lower(), "burn") or string.find(profile_name:lower(), "fire") or string.find(profile_name:lower(), "flamer") then
							damage_type_str = "burn"
						elseif string.find(profile_name:lower(), "toxin") or string.find(profile_name:lower(), "neurotoxin") then
							damage_type_str = "toxin"
						end
					end
				end
				
				tracker:_track_enemy_damage(attacked_unit, damage, attack_type, is_critical_strike, hit_weakspot, damage_type_str)
			end
			
			if attack_result == "died" then
				if breed_or_nil then
					local breed_type = "normal"
					if breed_or_nil.tags and breed_or_nil.tags.elite then
						breed_type = "elite"
					elseif breed_or_nil.tags and breed_or_nil.tags.special then
						breed_type = "special"
					end
					
					tracker:_finish_enemy_engagement(attacked_unit, breed_type)
				end
			end
		end
	end
	
	return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
end)

mod:hook("UIManager", "using_input", function(func, ...)
	return tracker._is_open or func(...)
end)
