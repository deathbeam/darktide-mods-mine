local mod = get_mod("scoreboard")

-- ##### ██████╗ ███████╗██████╗ ███████╗██╗███████╗████████╗███████╗███╗   ██╗████████╗
-- ##### ██╔══██╗██╔════╝██╔══██╗██╔════╝██║██╔════╝╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
-- ##### ██████╔╝█████╗  ██████╔╝█████-- ##### ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
-- ##### ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ##### █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ##### ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ##### ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
-- ##### ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝███████╗   ██║   █████╗  ██╔██╗ ██║   ██║   
-- ##### ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║██║╚════██║   ██║   ██╔══╝  ██║╚██╗██║   ██║   
-- ##### ██║     ███████╗██║  ██║███████║██║███████║   ██║   ███████╗██║ ╚████║   ██║   
-- ##### ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   

local ScoreboardPersistentTracker = {}

-- ##### ██████╗  █████╗ ████████╗ █████╗  ████████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
-- ##### ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
-- ##### ██║  ██║███████║   ██║   ███████║    ██║   ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
-- ##### ██║  ██║██╔══██║   ██║   ██╔══██║    ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
-- ##### ██████╔╝██║  ██║   ██║   ██║  ██║    ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
-- ##### ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

-- Persistent data storage
local persistent_data = mod:persistent_table("persistent_tracker")
persistent_data.tracked_players = persistent_data.tracked_players or {}
persistent_data.mission_players = persistent_data.mission_players or {}
persistent_data.current_mission_id = persistent_data.current_mission_id or nil
persistent_data.disconnected_players = persistent_data.disconnected_players or {}

-- Current session data (resets each game session)
local session_data = {
    active_players = {},
    last_seen = {},
    mission_start_time = nil,
    current_players = {},
    player_column_mapping = {}, -- Maps account_id to column index
    column_assignments = {}, -- Maps column index to account_id
    next_column_index = 1,
    max_columns = 8, -- Configurable maximum columns to display
}

-- ##### ██╗███╗   ██╗██╗████████╗██╗ █████╗ ██╗     ██╗███████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
-- ##### ██║████╗  ██║██║╚══██╔══╝██║██╔══██╗██║     ██║╚══ ██╔═╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
-- ##### ██║██╔██╗ ██║██║   ██║   ██║███████║██║     ██║  ███╔╝ ███████║   ██║   ██║██║   ██║██╔██╗ ██║
-- ##### ██║██║╚██╗██║██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
-- ##### ██║██║ ╚████║██║   ██║   ██║██║  ██║███████╗██║███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
-- ##### ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

function ScoreboardPersistentTracker:init()
    -- Ensure settings are available with defaults
    self.tracking_enabled = mod:get("persistent_tracking") or true
    self.keep_disconnected_setting = mod:get("keep_disconnected_players") or 1
    self.cross_mission_enabled = mod:get("cross_mission_tracking") or false
    self.show_dc_indicator = mod:get("show_disconnected_indicator") or true
    self.max_tracked = mod:get("max_tracked_players") or 50
    
    -- Initialize mission with safety checks
    session_data.mission_start_time = (Managers.time and Managers.time:time("main")) or 0
    session_data.active_players = {}
    session_data.current_players = {}
    
    -- Clean up old data
    self:cleanup_old_data()
end

-- ##### ██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗     ████████╗██████╗  █████╗  ██████╗██╗  ██╗██╗███╗   ██╗ ██████╗ 
-- ##### ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝ 
-- ##### ██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝       ██║   ██████╔╝███████║██║     █████╔╝ ██║██╔██╗ ██║██║  ███╗
-- ##### ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗       ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██║██║╚██╗██║██║   ██║
-- ##### ██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║       ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗██║██║ ╚████║╚██████╔╝
-- ##### ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 

function ScoreboardPersistentTracker:update_player_tracking(players)
    -- Safety check
    if not self.tracking_enabled then
        return players or {}
    end
    
    -- Ensure players is a valid table
    players = players or {}
    
    local current_time = Managers.time and Managers.time:time("main") or 0
    local active_account_ids = {}
    
    -- Track currently active players and assign columns
    for _, player in pairs(players) do
        local account_id = player:account_id() or player:name()
        local player_name = player:name() or "Unknown"
        
        active_account_ids[account_id] = true
        session_data.last_seen[account_id] = current_time
        
        -- Assign column if player doesn't have one
        if not session_data.player_column_mapping[account_id] then
            self:assign_player_column(account_id, player_name)
        end
        
        session_data.current_players[account_id] = {
            name = player_name,
            account_id = account_id,
            player_object = player,
            is_connected = true,
            last_seen = current_time,
            join_time = session_data.active_players[account_id] and session_data.active_players[account_id].join_time or current_time,
            column_index = session_data.player_column_mapping[account_id]
        }
        
        -- Cross-mission tracking
        if self.cross_mission_enabled then
            self:update_cross_mission_data(account_id, player_name)
        end
    end
    
    -- Check for disconnected players
    for account_id, player_data in pairs(session_data.active_players) do
        if not active_account_ids[account_id] then
            -- Player disconnected
            self:handle_player_disconnect(account_id, player_data, current_time)
        end
    end
    
    -- Update active players list
    session_data.active_players = session_data.current_players
    
    -- Return enhanced player list with stable column ordering
    return self:get_enhanced_player_list_with_columns(players)
end

function ScoreboardPersistentTracker:handle_player_disconnect(account_id, player_data, disconnect_time)
    -- Mark as disconnected
    player_data.is_connected = false
    player_data.disconnect_time = disconnect_time
    player_data.last_seen = disconnect_time
    
    -- Store in disconnected players but KEEP their column assignment
    persistent_data.disconnected_players[account_id] = {
        name = player_data.name,
        account_id = account_id,
        disconnect_time = disconnect_time,
        session_time = disconnect_time - (player_data.join_time or disconnect_time),
        is_connected = false,
        column_index = player_data.column_index or session_data.player_column_mapping[account_id]
    }
    
    mod:echo("Player " .. player_data.name .. " disconnected - keeping in column " .. (persistent_data.disconnected_players[account_id].column_index or "unknown"))
end

-- ##### ██████╗ ██████╗ ██╗     ██╗   ██╗███╗   ███╗███╗   ██╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗███╗   ███╗███████╗███╗   ██╗████████╗
-- ##### ██╔════╝██╔═══██╗██║     ██║   ██║████╗ ████║████╗  ██║    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
-- ##### ██║     ██║   ██║██║     ██║   ██║██╔████╔██║██╔██╗ ██║    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
-- ##### ██║     ██║   ██║██║     ██║   ██║██║╚██╔╝██║██║╚██╗██║    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
-- ##### ╚██████╗╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚████║    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
-- #####  ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   

function ScoreboardPersistentTracker:assign_player_column(account_id, player_name)
    -- Find the next available column or reuse existing assignment
    if session_data.player_column_mapping[account_id] then
        return session_data.player_column_mapping[account_id]
    end
    
    -- Find next available column
    local column_index = session_data.next_column_index
    while column_index <= session_data.max_columns and session_data.column_assignments[column_index] do
        column_index = column_index + 1
    end
    
    if column_index > session_data.max_columns then
        -- If we're out of columns, find the oldest disconnected player to replace
        local oldest_disconnect_time = math.huge
        local oldest_account_id = nil
        local oldest_column = nil
        
        for old_account_id, dc_player in pairs(persistent_data.disconnected_players) do
            if dc_player.column_index and dc_player.disconnect_time < oldest_disconnect_time then
                oldest_disconnect_time = dc_player.disconnect_time
                oldest_account_id = old_account_id
                oldest_column = dc_player.column_index
            end
        end
        
        if oldest_account_id then
            -- Replace the oldest disconnected player
            self:release_player_column(oldest_account_id)
            column_index = oldest_column
        else
            -- Fallback to column 1 if all else fails
            column_index = 1
        end
    end
    
    -- Assign the column
    session_data.player_column_mapping[account_id] = column_index
    session_data.column_assignments[column_index] = account_id
    session_data.next_column_index = math.max(session_data.next_column_index, column_index + 1)
    
    mod:echo("Assigned player " .. player_name .. " to column " .. column_index)
    return column_index
end

function ScoreboardPersistentTracker:release_player_column(account_id)
    local column_index = session_data.player_column_mapping[account_id]
    if column_index then
        session_data.column_assignments[column_index] = nil
        session_data.player_column_mapping[account_id] = nil
        persistent_data.disconnected_players[account_id] = nil
        mod:echo("Released column " .. column_index .. " from player " .. account_id)
    end
end

function ScoreboardPersistentTracker:get_enhanced_player_list_with_columns(active_players)
    local enhanced_players = {}
    local current_time = (Managers.time and Managers.time:time("main")) or 0
    local column_to_player = {}
    
    -- Ensure active_players is valid
    active_players = active_players or {}
    
    -- First, map all players (active + disconnected) to their columns
    for _, player in pairs(active_players) do
        if player and player.account_id then
            local account_id = player:account_id() or player:name()
            local column_index = session_data.player_column_mapping[account_id]
            if column_index then
                column_to_player[column_index] = player
            end
        end
    end
    
    -- Add disconnected players to their columns if they should be kept
    for account_id, dc_player in pairs(persistent_data.disconnected_players) do
        if self:should_keep_disconnected_player(dc_player, current_time) then
            local column_index = dc_player.column_index
            if column_index and not column_to_player[column_index] then
                -- Create mock player for this column
                local mock_player = self:create_mock_player(dc_player)
                column_to_player[column_index] = mock_player
            end
        else
            -- Remove expired disconnected players
            self:release_player_column(account_id)
        end
    end
    
    -- Build ordered player list based on column assignments
    for column_index = 1, session_data.max_columns do
        if column_to_player[column_index] then
            table.insert(enhanced_players, column_to_player[column_index])
        end
    end
    
    return enhanced_players
end

function ScoreboardPersistentTracker:get_enhanced_player_list(active_players)
    local enhanced_players = {}
    local current_time = Managers.time:time("main")
    
    -- Add active players
    for _, player in pairs(active_players) do
        table.insert(enhanced_players, player)
    end
    
    -- Add disconnected players if they should be kept
    for account_id, dc_player in pairs(persistent_data.disconnected_players) do
        if self:should_keep_disconnected_player(dc_player, current_time) then
            -- Create a mock player object for disconnected players
            local mock_player = self:create_mock_player(dc_player)
            table.insert(enhanced_players, mock_player)
        else
            -- Remove expired disconnected players
            persistent_data.disconnected_players[account_id] = nil
        end
    end
    
    return enhanced_players
end

function ScoreboardPersistentTracker:should_keep_disconnected_player(dc_player, current_time)
    if self.keep_disconnected_setting == 4 then -- Remove immediately
        return false
    elseif self.keep_disconnected_setting == 1 then -- Until mission end
        return true
    elseif self.keep_disconnected_setting == 2 then -- 5 minutes
        return (current_time - dc_player.disconnect_time) < 300
    elseif self.keep_disconnected_setting == 3 then -- 10 minutes
        return (current_time - dc_player.disconnect_time) < 600
    end
    return false
end

function ScoreboardPersistentTracker:create_mock_player(dc_player)
    -- Create a mock player object that maintains the interface expected by the scoreboard
    local mock_player = {
        _account_id = dc_player.account_id,
        _name = dc_player.name,
        _is_disconnected = true,
        _disconnect_time = dc_player.disconnect_time,
        _column_index = dc_player.column_index,
        
        account_id = function(self)
            return self._account_id
        end,
        
        name = function(self)
            local show_dc_indicator = mod:get("show_disconnected_indicator")
            if show_dc_indicator then
                return self._name .. " " .. mod:localize("player_disconnected_indicator")
            end
            return self._name
        end,
        
        is_disconnected = function(self)
            return self._is_disconnected
        end,
        
        disconnect_time = function(self)
            return self._disconnect_time
        end,
        
        get_column_index = function(self)
            return self._column_index
        end
    }
    
    return mock_player
end

-- ##### ███████╗██████╗  ██████╗ ███████╗███████╗      ███╗   ███╗██╗███████╗███████╗██╗ ██████╗ ███╗   ██╗
-- ##### ██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔════╝      ████╗ ████║██║██╔════╝██╔════╝██║██╔═══██╗████╗  ██║
-- ##### ██║     ██████╔╝██║   ██║███████╗███████╗█████╗██╔████╔██║██║███████╗███████╗██║██║   ██║██╔██╗ ██║
-- ##### ██║     ██╔══██╗██║   ██║╚════██║╚════██║╚════╝██║╚██╔╝██║██║╚════██║╚════██║██║██║   ██║██║╚██╗██║
-- ##### ╚██████╗██║  ██║╚██████╔╝███████║███████║      ██║ ╚═╝ ██║██║███████║███████║██║╚██████╔╝██║ ╚████║
-- #####  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝      ╚═╝     ╚═╝╚═╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝

function ScoreboardPersistentTracker:update_cross_mission_data(account_id, player_name)
    local current_time = (Managers.time and Managers.time:time("main")) or 0
    
    persistent_data.tracked_players[account_id] = persistent_data.tracked_players[account_id] or {
        name = player_name,
        account_id = account_id,
        first_seen = current_time,
        missions_together = 0,
        total_playtime = 0,
        last_mission_time = 0,
        performance_history = {},
    }
    
    local player_data = persistent_data.tracked_players[account_id]
    player_data.name = player_name -- Update name in case it changed
    player_data.last_seen = current_time
    player_data.missions_together = player_data.missions_together + 1
end

function ScoreboardPersistentTracker:get_player_history(account_id)
    return persistent_data.tracked_players[account_id]
end

function ScoreboardPersistentTracker:cleanup_old_data()
    local current_time = (Managers.time and Managers.time:time("main")) or 0
    local max_age = 604800 -- 7 days in seconds
    
    -- Clean up tracked players that haven't been seen in a week
    for account_id, player_data in pairs(persistent_data.tracked_players) do
        if player_data.last_seen and (current_time - player_data.last_seen) > max_age then
            persistent_data.tracked_players[account_id] = nil
        end
    end
    
    -- Limit total tracked players
    local tracked_count = 0
    for _ in pairs(persistent_data.tracked_players) do
        tracked_count = tracked_count + 1
    end
    
    if tracked_count > (self.max_tracked or 50) then
        -- Remove oldest players
        local sorted_players = {}
        for account_id, player_data in pairs(persistent_data.tracked_players) do
            table.insert(sorted_players, {account_id = account_id, last_seen = player_data.last_seen or 0})
        end
        
        table.sort(sorted_players, function(a, b) return a.last_seen < b.last_seen end)
        
        local to_remove = tracked_count - (self.max_tracked or 50)
        for i = 1, to_remove do
            if sorted_players[i] then
                persistent_data.tracked_players[sorted_players[i].account_id] = nil
            end
        end
    end
end

-- ##### ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
-- ##### ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ##### █████╗  ██�██╗██╔╝█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ##### ██╔══╝   ╚████╔╝ ██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ##### ███████╗  ╚██╔╝  ███████╗██║ ╚████║   ██║   ███████║
-- ##### ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

function ScoreboardPersistentTracker:on_mission_start()
    session_data.mission_start_time = (Managers.time and Managers.time:time("main")) or 0
    persistent_data.disconnected_players = {} -- Clear disconnected players from previous mission
    self:init()
end

function ScoreboardPersistentTracker:on_mission_end()
    -- Finalize cross-mission data
    local current_time = (Managers.time and Managers.time:time("main")) or 0
    local mission_duration = current_time - (session_data.mission_start_time or 0)
    
    for account_id, player_data in pairs(session_data.active_players) do
        if self.cross_mission_enabled and persistent_data.tracked_players[account_id] then
            persistent_data.tracked_players[account_id].total_playtime = 
                persistent_data.tracked_players[account_id].total_playtime + mission_duration
            persistent_data.tracked_players[account_id].last_mission_time = mission_duration
        end
    end
    
    -- Clear disconnected players at mission end
    persistent_data.disconnected_players = {}
end

function ScoreboardPersistentTracker:clear_session_data()
    session_data.active_players = {}
    session_data.current_players = {}
    session_data.last_seen = {}
    session_data.player_column_mapping = {}
    session_data.column_assignments = {}
    session_data.next_column_index = 1
    persistent_data.disconnected_players = {}
end

function ScoreboardPersistentTracker:get_session_stats()
    local active_count = 0
    local disconnected_count = 0
    local tracked_count = 0
    
    for _ in pairs(session_data.active_players) do
        active_count = active_count + 1
    end
    
    for _ in pairs(persistent_data.disconnected_players) do
        disconnected_count = disconnected_count + 1
    end
    
    for _ in pairs(persistent_data.tracked_players) do
        tracked_count = tracked_count + 1
    end
    
    local current_time = (Managers.time and Managers.time:time("main")) or 0
    
    return {
        active_players = session_data.active_players,
        disconnected_count = disconnected_count,
        tracked_count = tracked_count,
        mission_duration = current_time - (session_data.mission_start_time or 0)
    }
end

return ScoreboardPersistentTracker
