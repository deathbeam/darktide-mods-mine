local mod = get_mod("scoreboard")

-- Persistent Player Manager
-- Safely tracks players and maintains scoreboard data when they disconnect
local PersistentManager = {}

-- Initialize storage
PersistentManager.session_data = {
    active_players = {},      -- Currently connected players
    disconnected_players = {}, -- Players who disconnected but data preserved
    player_order = {},        -- Order players appeared (for column assignment)
    session_start = 0,        -- When the session started
    mission_start = 0,        -- When current mission started
}

-- Settings
PersistentManager.settings = {
    enabled = false,              -- Disabled by default for safety
    max_tracked_players = 8,      -- Maximum players to track
    disconnect_timeout = 300,     -- Seconds to keep disconnected player data
    clear_on_mission_end = false, -- Whether to clear data between missions
}

-- Get unique player identifier (account_id or fallback to name)
function PersistentManager:get_player_id(player)
    if not player then return nil end
    return player:account_id() or player:name() or tostring(player)
end

-- Get player display name with class symbol
function PersistentManager:get_player_display_name(player)
    if not player then return "Unknown" end
    
    local name = player:name() or "Unknown"
    local symbol = player.string_symbol or (player._profile and player._profile.archetype and player._profile.archetype.string_symbol)
    
    if symbol then
        return symbol .. " " .. name
    end
    return name
end

-- Register a new player or update existing one
function PersistentManager:register_player(player)
    if not self.settings.enabled or not player or not self:is_in_mission() then 
        return 
    end
    
    local player_id = self:get_player_id(player)
    if not player_id then return end
    
    local current_time = self:get_current_time()
    
    -- Check if player was previously disconnected
    if self.session_data.disconnected_players[player_id] then
        -- Move back to active players
        self.session_data.active_players[player_id] = self.session_data.disconnected_players[player_id]
        self.session_data.disconnected_players[player_id] = nil
        
        -- Update reconnection info
        self.session_data.active_players[player_id].last_seen = current_time
        self.session_data.active_players[player_id].is_connected = true
        
        mod:echo("Player " .. self:get_player_display_name(player) .. " reconnected")
    else
        -- New player
        if not self.session_data.active_players[player_id] then
            -- Add to order tracking if not already there
            if not table.contains(self.session_data.player_order, player_id) then
                table.insert(self.session_data.player_order, player_id)
            end
            
            self.session_data.active_players[player_id] = {
                player_object = player,
                display_name = self:get_player_display_name(player),
                account_id = player:account_id(),
                join_time = current_time,
                last_seen = current_time,
                is_connected = true,
                column_index = #self.session_data.player_order, -- Assign column based on order
            }
            
            mod:echo("New player tracked: " .. self:get_player_display_name(player))
        else
            -- Update existing active player
            self.session_data.active_players[player_id].last_seen = current_time
            self.session_data.active_players[player_id].player_object = player
            self.session_data.active_players[player_id].is_connected = true
        end
    end
end

-- Mark player as disconnected (preserve their data)
function PersistentManager:mark_disconnected(player_id, player_name)
    if not self.settings.enabled or not self:is_in_mission() then 
        return 
    end
    
    local player_data = self.session_data.active_players[player_id]
    if player_data then
        player_data.disconnect_time = self:get_current_time()
        player_data.is_connected = false
        player_data.player_object = nil -- Clear object reference
        
        -- Move to disconnected list
        self.session_data.disconnected_players[player_id] = player_data
        self.session_data.active_players[player_id] = nil
        
        mod:echo("Player " .. (player_name or player_data.display_name) .. " marked as disconnected")
    end
end

-- Get enhanced player list that includes both active and preserved disconnected players
function PersistentManager:get_enhanced_player_list()
    -- If disabled or not in mission, return normal player list
    if not self.settings.enabled or not self:is_in_mission() then
        local player_manager = Managers.player
        return player_manager and player_manager:players() or {}
    end
    
    local enhanced_players = {}
    local current_time = self:get_current_time()
    
    -- Add active players in their original order
    for _, player_id in ipairs(self.session_data.player_order) do
        local player_data = self.session_data.active_players[player_id]
        if player_data and player_data.is_connected then
            table.insert(enhanced_players, player_data.player_object)
        else
            -- Check if we should keep disconnected player
            local dc_player_data = self.session_data.disconnected_players[player_id]
            if dc_player_data and self:should_keep_disconnected(dc_player_data, current_time) then
                -- Create a mock player object for disconnected player
                local mock_player = self:create_mock_player(dc_player_data)
                table.insert(enhanced_players, mock_player)
            end
        end
    end
    
    return enhanced_players
end

-- Check if disconnected player should still be displayed
function PersistentManager:should_keep_disconnected(player_data, current_time)
    if not player_data.disconnect_time then return false end
    
    local time_since_disconnect = current_time - player_data.disconnect_time
    return time_since_disconnect < self.settings.disconnect_timeout
end

-- Create mock player object for disconnected players
function PersistentManager:create_mock_player(player_data)
    local mock_player = {
        -- Basic identification
        name = function() return player_data.display_name or "Disconnected" end,
        account_id = function() return player_data.account_id end,
        
        -- Visual indicators for disconnected state
        string_symbol = "(DC)", -- Disconnected indicator
        _profile = player_data._profile,
        
        -- Mock functions for compatibility
        is_disconnected = function() return true end,
        _is_mock = true,
    }
    
    return mock_player
end

-- Update player tracking (called during scoreboard updates)
function PersistentManager:update_tracking()
    if not self.settings.enabled or not self:is_in_mission() then 
        return 
    end
    
    local player_manager = Managers.player
    if not player_manager then return end
    
    local current_players = player_manager:players() or {}
    local current_player_ids = {}
    
    -- Register/update all current players
    for _, player in pairs(current_players) do
        local player_id = self:get_player_id(player)
        if player_id then
            self:register_player(player)
            current_player_ids[player_id] = true
        end
    end
    
    -- Check for players who disconnected
    for player_id, player_data in pairs(self.session_data.active_players) do
        if not current_player_ids[player_id] then
            self:mark_disconnected(player_id, player_data.display_name)
        end
    end
end

-- Initialize the session
function PersistentManager:init()
    -- Ultimate safety: wrap everything in pcall
    local success, error_msg = pcall(function()
        -- Only initialize during actual missions, not in hub
        if not self:is_in_mission() then
            self.settings.enabled = false
            return
        end
        
        self.session_data.session_start = self:get_current_time()
        self.session_data.mission_start = self:get_current_time()
        
        -- Get settings from mod (with safety fallbacks)
        local success, enabled = pcall(function() return mod:get("persistent_players") end)
        self.settings.enabled = (success and enabled) or false
        
        local success2, timeout = pcall(function() return mod:get("persistent_disconnect_timeout") end)
        self.settings.disconnect_timeout = (success2 and timeout) or 300
        
        local success3, clear = pcall(function() return mod:get("persistent_clear_on_mission") end)
        self.settings.clear_on_mission_end = (success3 and clear) or false
        
        if self.settings.enabled then
            mod:echo("Persistent player tracking initialized for mission")
        end
    end)
    
    if not success then
        self.settings.enabled = false
        mod:echo("Failed to initialize persistent tracking: " .. tostring(error_msg))
    end
end

-- Check if we're in an actual mission (not hub)
function PersistentManager:is_in_mission()
    -- Enhanced safety checks
    if not Managers then return false end
    if not Managers.state then return false end
    
    local game_state_machine = Managers.state.game_session
    if not game_state_machine then return false end
    
    -- Additional safety check for game_state_machine method
    if not game_state_machine.game_state_machine then return false end
    
    local success, state_machine = pcall(function()
        return game_state_machine:game_state_machine()
    end)
    
    if not success or not state_machine then return false end
    
    -- Additional safety check for current_state_name method
    if not state_machine.current_state_name then return false end
    
    local success2, current_state = pcall(function()
        return state_machine:current_state_name()
    end)
    
    if not success2 or not current_state then return false end
    
    return current_state == "GameplayStateRun" or current_state == "GameplayStateWaitForPlayers"
end

-- Safe time getter with fallback
function PersistentManager:get_current_time()
    if Managers.time then
        return Managers.time:time("main")
    end
    return os.time() -- Fallback to OS time
end

-- Clear session data
function PersistentManager:clear_session()
    self.session_data = {
        active_players = {},
        disconnected_players = {},
        player_order = {},
        session_start = self:get_current_time(),
        mission_start = self:get_current_time(),
    }
    mod:echo("Persistent tracking data cleared")
end

-- Get session statistics
function PersistentManager:get_stats()
    local active_count = 0
    for _ in pairs(self.session_data.active_players) do
        active_count = active_count + 1
    end
    
    local disconnected_count = 0
    for _ in pairs(self.session_data.disconnected_players) do
        disconnected_count = disconnected_count + 1
    end
    
    local current_time = self:get_current_time()
    
    return {
        enabled = self.settings.enabled,
        in_mission = self:is_in_mission(),
        active_players = active_count,
        disconnected_players = disconnected_count,
        total_tracked = #self.session_data.player_order,
        session_duration = current_time - self.session_data.session_start,
    }
end

-- Update settings (called when mod settings change)
function PersistentManager:update_settings()
    local old_enabled = self.settings.enabled
    
    self.settings.enabled = mod:get("persistent_players") or false
    self.settings.disconnect_timeout = mod:get("persistent_disconnect_timeout") or 300
    self.settings.clear_on_mission_end = mod:get("persistent_clear_on_mission") or false
    
    -- If just enabled, initialize
    if self.settings.enabled and not old_enabled then
        self:init()
    end
end

return PersistentManager
