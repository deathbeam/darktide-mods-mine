local mod = get_mod("scoreboard")

local scoreboard_view_settings = {
    shading_environment = "content/shading_environments/ui/system_menu",
    scoreboard_size = {1480, mod:get("scoreboard_panel_height")}, -- Increased for 6th column
    scoreboard_row_height = 16,           -- Fixed typo from "coreboard"
    scoreboard_row_header_height = 20,    -- Reduced from 30  
    scoreboard_row_big_height = 24,       -- Reduced from 36
    scoreboard_row_score_height = 24,     -- Reduced from 36
    scoreboard_column_width = 180,        -- Column width for data columns
    scoreboard_column_header_width = 300, -- Header column width
    scoreboard_fade_length = 0.1,
}
return settings("ScoreboardViewSettings", scoreboard_view_settings)  