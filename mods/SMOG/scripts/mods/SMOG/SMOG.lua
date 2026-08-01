-- SMOG.lua
local mod = get_mod("SMOG")
local Managers = Managers
local Application = Application
local collectgarbage = collectgarbage
local math_floor = math.floor
local math_abs = math.abs
local math_max = math.max
local string_format = string.format
local tostring = tostring
local tonumber = tonumber
local pcall = pcall
local type = type
local os_clock = os and os.clock
local dmf = get_mod("DMF")
local check_interval = 1
local interval_clean_time = 600
local manual_clear_cooldown = 3
local over_eighty_pause = 80
local over_eighty_stepmul = 500
local over_eighty_boost_pause = 70
local over_eighty_boost_stepmul = 650
local saved_gc_pause = nil
local saved_gc_stepmul = nil
local staged_step_kb = 32
local staged_max_steps = 16
local staged_budget_seconds = 0.001
local over_eighty_delay_seconds = 5
local warning_return_delay_seconds = 2
local growth_window_seconds = 30
local auto_notification_seconds = 5
local manual_notification_seconds = 6
local notification_fade_seconds = 1
local live_memory_warning_percent = 80
local accumulator = 0
local interval_accumulator = 0
local growth_accumulator = 0
local scheduled_delays = {}
local scheduled_reasons = {}
local due_reasons = {}
local scheduled_count = 0
local next_manual_clear_t = 0
local over_eighty_since = nil
local over_eighty_active = false
local over_eighty_tuned = false
local over_eighty_boosted = false
local over_eighty_last_mb = 0
local over_eighty_no_progress_t = 0
local high_threshold_cycle_active = false
local warning_acknowledged = false
local ninety_collect_done = false
local ninetyfive_collect_done = false
local pending_warning_return_delay = nil
local previous_game_mode_name = nil
local previous_safe_zone_state = nil
local notification_text = nil
local notification_tail = nil
local notification_green_text = false
local notification_good = true
local notification_expiry = 0
local notification_duration = auto_notification_seconds
local notification_manual = false
local threshold_notification_text = nil
local threshold_notification_red_text = false
local notification_queue_text = {}
local notification_queue_tail = {}
local notification_queue_green_text = {}
local notification_queue_good = {}
local notification_queue_duration = {}
local notification_queue_count = 0
local notification_queue_limit = 3
local first_update_done = false
local last_persisted_heap_state = nil
local hud_registered = false
local hud_register_retry_t = 0
mod.cleaning_permitted = mod:get("cleaning_permitted") ~= false
mod.convenient_moment_cleans = mod:get("auto_clean_on_start")
mod.auto_clean_every_ten_minutes = mod:get("auto_clean_every_ten_minutes")
mod.automatic_notifications = mod:get("notifications") ~= false
mod._smog_hud_visible = mod._smog_hud_visible == true
mod._smog_notification_active = false
mod._smog_hud_x_axis = tonumber(mod:get("hud_x_axis")) or 5
mod._smog_hud_y_axis = tonumber(mod:get("hud_y_axis")) or 65
mod._smog_notification_y_axis = tonumber(mod:get("notification_y_axis")) or 85
local function memory_usage_mb()
local used_kb = collectgarbage("count") or 0
return used_kb / 1024
end
local function fmt_mb(value)
return string_format("%.2f",value or 0)
end
local function fmt_delta(value)
local sign = value >= 0 and "-" or "+"
return sign .. fmt_mb(math_abs(value or 0))
end
local function current_time()
local time_manager = Managers and Managers.time
if time_manager and time_manager.time then
local ok,value = pcall(time_manager.time,time_manager,"main")
if ok and value then
return value
end
end
if os_clock then
return os_clock()
end
return 0
end
local function heap_size_mb()
local size = 1024
if Application and Application.argv then
local ok,args = pcall(function()
return {Application.argv()}
end)
if ok and args then
for i = 1,#args do
local arg = tostring(args[i])
local inline_size = arg:match("^%-%-lua%-heap%-mb%-size=(%d+)$")
if inline_size then
size = tonumber(inline_size) or size
elseif arg == "--lua-heap-mb-size" and tonumber(args[i + 1]) then
size = tonumber(args[i + 1])
end
end
end
end
return size
end
local detected_heap_mb = heap_size_mb()
local threshold_thirty_mb = detected_heap_mb * 0.3
local threshold_eighty_mb = detected_heap_mb * 0.8
local threshold_eightyfive_mb = detected_heap_mb * 0.85
local threshold_ninety_mb = detected_heap_mb * 0.9
local threshold_ninetyfive_mb = detected_heap_mb * 0.95
local growth_sample_mb = memory_usage_mb()
local function usage_percent(usage_mb)
if detected_heap_mb <= 0 then
return 0
end
return (usage_mb or memory_usage_mb()) / detected_heap_mb * 100
end
mod._smog_usage_percent = function()
return usage_percent()
end
local function save_settings_now()
if dmf and dmf.save_unsaved_settings_to_file then
pcall(dmf.save_unsaved_settings_to_file)
end
end
local function heap_state(percent)
return (percent or usage_percent()) >= live_memory_warning_percent and live_memory_warning_percent or 0
end
local function persist_heap_state(percent)
local state = heap_state(percent)
if last_persisted_heap_state ~= state then
last_persisted_heap_state = state
mod:set("_smog_last_heap_percent",state)
save_settings_now()
end
end
local function mark_unclean_start()
local previous_clean = mod:get("_smog_clean_shutdown")
local previous_percent = tonumber(mod:get("_smog_last_heap_percent")) or 0
if previous_clean == false and previous_percent < live_memory_warning_percent then
mod:echo("It looks like you crashed out from a live memory problem last time. This is not a Lua heap issue so SMOG could not help.")
end
local state = heap_state(usage_percent())
last_persisted_heap_state = state
mod:set("_smog_clean_shutdown",false)
mod:set("_smog_last_heap_percent",state)
save_settings_now()
end
mark_unclean_start()
local function update_notification_active()
mod._smog_notification_active = threshold_notification_text ~= nil or notification_text ~= nil or notification_queue_count > 0
end
local function clear_notification()
notification_text = nil
notification_tail = nil
notification_green_text = false
notification_expiry = 0
notification_duration = auto_notification_seconds
notification_manual = false
update_notification_active()
end
local function clear_queued_notifications()
for i = 1,notification_queue_count do
notification_queue_text[i] = nil
notification_queue_tail[i] = nil
notification_queue_green_text[i] = nil
notification_queue_good[i] = nil
notification_queue_duration[i] = nil
end
notification_queue_count = 0
update_notification_active()
end
local function clear_threshold_notification()
threshold_notification_text = nil
threshold_notification_red_text = false
update_notification_active()
end
local function set_threshold_notification(text,red_text)
clear_notification()
clear_queued_notifications()
threshold_notification_text = text
threshold_notification_red_text = red_text == true
update_notification_active()
end
local function clear_all_notifications()
clear_notification()
clear_queued_notifications()
clear_threshold_notification()
end
local function queue_notification(text,good,duration,tail,green_text)
if notification_queue_count >= notification_queue_limit then
return
end
notification_queue_count = notification_queue_count + 1
notification_queue_text[notification_queue_count] = text
notification_queue_tail[notification_queue_count] = tail
notification_queue_green_text[notification_queue_count] = green_text == true
notification_queue_good[notification_queue_count] = good ~= false
notification_queue_duration[notification_queue_count] = duration or auto_notification_seconds
update_notification_active()
end
local function pop_notification(now)
if notification_queue_count <= 0 then
clear_notification()
return false
end
local text = notification_queue_text[1]
local tail = notification_queue_tail[1]
local good = notification_queue_good[1]
local green_text = notification_queue_green_text[1]
local duration = notification_queue_duration[1] or auto_notification_seconds
for i = 1,notification_queue_count - 1 do
notification_queue_text[i] = notification_queue_text[i + 1]
notification_queue_tail[i] = notification_queue_tail[i + 1]
notification_queue_green_text[i] = notification_queue_green_text[i + 1]
notification_queue_good[i] = notification_queue_good[i + 1]
notification_queue_duration[i] = notification_queue_duration[i + 1]
end
notification_queue_text[notification_queue_count] = nil
notification_queue_tail[notification_queue_count] = nil
notification_queue_green_text[notification_queue_count] = nil
notification_queue_good[notification_queue_count] = nil
notification_queue_duration[notification_queue_count] = nil
notification_queue_count = notification_queue_count - 1
notification_text = text
notification_tail = tail
notification_green_text = green_text == true
notification_good = good ~= false
notification_duration = duration
notification_expiry = (now or current_time()) + duration
notification_manual = false
update_notification_active()
return true
end
local function show_notification(text,good,is_manual,tail,green_text)
local now = current_time()
if is_manual then
clear_queued_notifications()
notification_text = text
notification_tail = tail
notification_green_text = green_text == true
notification_good = good ~= false
notification_duration = manual_notification_seconds
notification_expiry = now + manual_notification_seconds
notification_manual = true
update_notification_active()
return
end
if not mod.automatic_notifications then
return
end
if notification_manual and notification_expiry > now then
return
end
if notification_text and notification_expiry > now then
queue_notification(text,good,auto_notification_seconds,tail,green_text)
return
end
notification_text = text
notification_tail = tail
notification_green_text = green_text == true
notification_good = good ~= false
notification_duration = auto_notification_seconds
notification_expiry = now + auto_notification_seconds
notification_manual = false
update_notification_active()
end
local hud_notification_state = {}
mod._smog_get_notification = function(now)
now = now or current_time()
if threshold_notification_text then
hud_notification_state.text = threshold_notification_text
hud_notification_state.tail = nil
hud_notification_state.green_text = false
hud_notification_state.red_text = threshold_notification_red_text == true
hud_notification_state.good = false
hud_notification_state.expiry = now + 3600
hud_notification_state.duration = 3600
hud_notification_state.manual = true
hud_notification_state.fade_seconds = notification_fade_seconds
return hud_notification_state
end
if not notification_text then
if not pop_notification(now) then
return nil
end
elseif notification_expiry <= now then
if not pop_notification(now) then
return nil
end
end
hud_notification_state.text = notification_text
hud_notification_state.tail = notification_tail
hud_notification_state.green_text = notification_green_text == true
hud_notification_state.red_text = false
hud_notification_state.good = notification_good ~= false
hud_notification_state.expiry = notification_expiry
hud_notification_state.duration = notification_duration
hud_notification_state.manual = notification_manual == true
hud_notification_state.fade_seconds = notification_fade_seconds
return hud_notification_state
end
local function cleaning_allowed()
return mod.cleaning_permitted ~= false
end
local function show_cleaning_not_permitted()
show_notification("Cleaning not permitted; change in options menu.",false,true)
end
local function clear_scheduled_cleans()
for i = 1,scheduled_count do
scheduled_delays[i] = nil
scheduled_reasons[i] = nil
end
scheduled_count = 0
end
local function reset_growth_window(after_mb)
growth_sample_mb = after_mb or memory_usage_mb()
growth_accumulator = 0
end
local function cleaned_message(before_mb,after_mb,freed_mb)
local before_percent = usage_percent(before_mb)
local after_percent = usage_percent(after_mb)
local cleaned_percent = math_max(before_percent - after_percent,0)
return string_format("Cleaned %.1f%%",cleaned_percent),string_format(" (%s MB > %s MB) (%s MB)",fmt_mb(before_mb),fmt_mb(after_mb),fmt_delta(freed_mb))
end
local function perform_collect(notification_mode)
local before_mb = memory_usage_mb()
if not cleaning_allowed() then
if notification_mode == "manual" then
show_cleaning_not_permitted()
end
return before_mb,before_mb,0,false
end
collectgarbage("collect")
local after_mb = memory_usage_mb()
local freed_mb = before_mb - after_mb
if notification_mode == "manual" then
local message,tail = cleaned_message(before_mb,after_mb,freed_mb)
show_notification(message,freed_mb >= 0,true,tail,true)
elseif notification_mode == "auto" then
show_notification("Routine cleaning...",true,false)
end
reset_growth_window(after_mb)
return before_mb,after_mb,freed_mb,true
end
local function apply_over_eighty_tuning(boosted)
local pause = boosted and over_eighty_boost_pause or over_eighty_pause
local stepmul = boosted and over_eighty_boost_stepmul or over_eighty_stepmul
if not over_eighty_tuned then
local pause_ok,previous_pause = pcall(collectgarbage,"setpause",pause)
local stepmul_ok,previous_stepmul = pcall(collectgarbage,"setstepmul",stepmul)
if pause_ok then
saved_gc_pause = previous_pause or saved_gc_pause
end
if stepmul_ok then
saved_gc_stepmul = previous_stepmul or saved_gc_stepmul
end
else
pcall(collectgarbage,"setpause",pause)
pcall(collectgarbage,"setstepmul",stepmul)
end
pcall(collectgarbage,"restart")
over_eighty_tuned = true
end
local function restore_over_eighty_tuning()
if not over_eighty_tuned then
return
end
if saved_gc_pause then
pcall(collectgarbage,"setpause",saved_gc_pause)
end
if saved_gc_stepmul then
pcall(collectgarbage,"setstepmul",saved_gc_stepmul)
end
pcall(collectgarbage,"restart")
over_eighty_tuned = false
saved_gc_pause = nil
saved_gc_stepmul = nil
end
local function reset_high_threshold_cycle()
high_threshold_cycle_active = false
warning_acknowledged = false
ninety_collect_done = false
ninetyfive_collect_done = false
pending_warning_return_delay = nil
clear_threshold_notification()
end
local function stop_over_eighty_process()
over_eighty_active = false
over_eighty_boosted = false
over_eighty_no_progress_t = 0
restore_over_eighty_tuning()
end
local function finish_over_eighty_process()
local was_active = over_eighty_active
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
if was_active then
show_notification("Now under 80%.",true,false)
end
end
local function begin_over_eighty_process(usage_mb)
if not cleaning_allowed() or over_eighty_active then
return
end
over_eighty_active = true
over_eighty_boosted = false
over_eighty_last_mb = usage_mb or memory_usage_mb()
over_eighty_no_progress_t = 0
apply_over_eighty_tuning(false)
show_notification("Heap remained above 80%. Incremental cleaning...",false,false)
end
local function tick_over_eighty_staged(dt)
if not over_eighty_active then
return
end
if not cleaning_allowed() then
stop_over_eighty_process()
return
end
local usage_mb = memory_usage_mb()
if usage_mb < threshold_eighty_mb then
finish_over_eighty_process()
return
end
local start_time = os_clock and os_clock() or nil
local steps = 0
repeat
local finished = collectgarbage("step",staged_step_kb)
steps = steps + 1
if finished then
break
end
if start_time and os_clock and os_clock() - start_time >= staged_budget_seconds then
break
end
until steps >= staged_max_steps
local after_step_mb = memory_usage_mb()
if after_step_mb < threshold_eighty_mb then
finish_over_eighty_process()
return
end
if not over_eighty_boosted then
if after_step_mb >= over_eighty_last_mb then
over_eighty_no_progress_t = over_eighty_no_progress_t + (dt or 0)
if over_eighty_no_progress_t >= growth_window_seconds then
over_eighty_boosted = true
over_eighty_no_progress_t = 0
apply_over_eighty_tuning(true)
show_notification("Heap is not falling. Increasing incremental cleaning.",false,false)
end
else
over_eighty_no_progress_t = 0
end
end
over_eighty_last_mb = after_step_mb
end
local function game_mode_manager()
return Managers and Managers.state and Managers.state.game_mode
end
local function game_mode_name()
local manager = game_mode_manager()
if not manager then
return nil
end
if manager.game_mode_name then
local ok,name = pcall(manager.game_mode_name,manager)
if ok and name then
return name
end
end
if manager.game_mode then
local ok,game_mode = pcall(manager.game_mode,manager)
if ok and game_mode and game_mode.name then
local ok_name,name = pcall(game_mode.name,game_mode)
if ok_name then
return name
end
end
end
return nil
end
local function game_mode_state()
local manager = game_mode_manager()
if manager and manager.game_mode_state then
local ok,state = pcall(manager.game_mode_state,manager)
if ok then
return state
end
end
return nil
end
local function cinematic_active()
local cinematic = Managers and Managers.state and Managers.state.cinematic
if cinematic and cinematic.cinematic_active then
local ok,active = pcall(cinematic.cinematic_active,cinematic)
if ok and active then
return true
end
end
return false
end
local function hud_blocked_text(value)
if value == nil then
return false
end
local text = type(value) == "string" and value or tostring(value)
return text:find("[Ll]oading") ~= nil or text:find("[Cc]inematic") ~= nil or text:find("[Cc]utscene") ~= nil or text:find("[Vv]alkyrie") ~= nil or text:find("[Bb]riefing") ~= nil
end
local function hud_view_active(view_name)
local ui_manager = Managers and Managers.ui
if not ui_manager or not ui_manager.has_active_view then
return false
end
local ok,active = pcall(ui_manager.has_active_view,ui_manager,view_name)
return ok and active == true
end
local function hud_blocked_view_active()
return hud_view_active("cinematic_view") or hud_view_active("cutscene_view") or hud_view_active("loading_view") or hud_view_active("mission_intro_view") or hud_view_active("mission_outro_view") or hud_view_active("lobby_view")
end
local function ui_state_name()
local ui_manager = Managers and Managers.ui
if not ui_manager or not ui_manager.get_current_state_name then
return nil
end
local ok,name = pcall(ui_manager.get_current_state_name,ui_manager)
if ok then
return name
end
return nil
end
local function hud_context_allowed()
if not game_mode_manager() then
return false
end
if cinematic_active() or hud_blocked_view_active() then
return false
end
local ui_state = ui_state_name()
if ui_state == "StateLoading" or ui_state == "GameplayStateInit" or ui_state == "StateExitToMainMenu" or ui_state == "StateMissionServerExit" or hud_blocked_text(ui_state) then
return false
end
local name = game_mode_name()
if hud_blocked_text(name) then
return false
end
local state = game_mode_state()
if state == "leaving_game" or state == "done" or hud_blocked_text(state) then
return false
end
return true
end
local function clean_dmf_chat_notifications()
local event_manager = Managers and Managers.event
if event_manager and event_manager.trigger then
pcall(event_manager.trigger,event_manager,"event_clear_notifications")
end
end
mod._smog_hud_context_allowed = hud_context_allowed
local hud_element_definition = {
class_name = "HudElementSMOGDisplay",
filename = "SMOG/scripts/mods/SMOG/SMOG_HUD",
use_hud_scale = true,
visibility_groups = {
"dead",
"alive",
"communication_wheel",
"tactical_overlay",
"player_in_danger_zone",
"emote_wheel",
"in_hub_view",
"in_view",
"popup",
},
}
local function register_smog_hud_element()
if hud_registered then
return true
end
if not mod.register_hud_element then
return false
end
local ok,result = pcall(mod.register_hud_element,mod,hud_element_definition)
if ok and result then
hud_registered = true
if dmf and dmf.inject_hud_elements then
pcall(dmf.inject_hud_elements,mod)
end
return true
end
return false
end
register_smog_hud_element()
mod.toggle_hud = function()
mod._smog_hud_visible = not mod._smog_hud_visible
clean_dmf_chat_notifications()
end
local function game_mode_object()
local manager = game_mode_manager()
if not manager or not manager.game_mode then
return nil
end
local ok,game_mode = pcall(manager.game_mode,manager)
if ok then
return game_mode
end
return nil
end
local function in_safe_zone()
local game_mode = game_mode_object()
if game_mode and game_mode.in_safe_zone then
local ok,result = pcall(game_mode.in_safe_zone,game_mode)
if ok then
return result == true
end
end
local pacing = Managers and Managers.state and Managers.state.pacing
if pacing and pacing.get_in_safe_zone then
local ok,result = pcall(pacing.get_in_safe_zone,pacing)
if ok then
return result == true
end
end
return nil
end
local function is_hub_mode(name)
return name == "hub" or name == "prologue_hub" or name == "hub_singleplay"
end
local function is_training_mode(name)
return name == "training_grounds" or name == "shooting_range"
end
local function is_mortis_mode(name)
return name == "survival"
end
local function is_expedition_mode(name)
return name == "expedition"
end
local function manual_clear_action()
local binding = mod:get("manual_clear_key")
if type(binding) == "table" and #binding > 0 then
local keys = {}
for i = 1,#binding do
local key = tostring(binding[i])
if key ~= "" then
keys[#keys + 1] = string.upper(key)
end
end
if #keys > 0 then
return "press [" .. table.concat(keys," + ") .. "]"
end
elseif type(binding) == "string" and binding ~= "" then
return "press [" .. string.upper(binding) .. "]"
end
return "type /smog"
end
local function warning_eightyfive_text()
return "Heap above 85%: " .. manual_clear_action() .. " urgently."
end
local function warning_post_ninety_text()
return "Automatic cleaning did not lower the heap below 80%: " .. manual_clear_action() .. " urgently."
end
local function warning_ninetyfive_text()
local exit_text = is_hub_mode(game_mode_name()) and "leave the game" or "leave the mission"
return "You are likely to crash unless you " .. manual_clear_action() .. " or " .. exit_text .. "."
end
local function trigger_eightyfive_warning()
high_threshold_cycle_active = true
warning_acknowledged = false
ninety_collect_done = false
ninetyfive_collect_done = false
pending_warning_return_delay = nil
set_threshold_notification(warning_eightyfive_text(),false)
mod._smog_hud_visible = true
end
local function trigger_ninety_collect()
if ninety_collect_done or warning_acknowledged or not threshold_notification_text then
return
end
ninety_collect_done = true
pending_warning_return_delay = nil
set_threshold_notification("Heap reached 90%. Cleaning automatically...",false)
local _,after_mb = perform_collect(false)
if after_mb >= threshold_eighty_mb then
pending_warning_return_delay = warning_return_delay_seconds
end
end
local function trigger_ninetyfive_collect()
if ninetyfive_collect_done then
return
end
ninetyfive_collect_done = true
ninety_collect_done = true
pending_warning_return_delay = nil
set_threshold_notification(warning_ninetyfive_text(),true)
perform_collect(false)
end
local function tick_pending_warning_return(dt)
if not pending_warning_return_delay then
return
end
pending_warning_return_delay = pending_warning_return_delay - (dt or 0)
if pending_warning_return_delay > 0 then
return
end
pending_warning_return_delay = nil
if not warning_acknowledged and memory_usage_mb() >= threshold_eighty_mb then
set_threshold_notification(warning_post_ninety_text(),false)
end
end
local function schedule_convenient_clean(reason,delay)
if not mod.convenient_moment_cleans or not cleaning_allowed() then
return
end
for i = 1,scheduled_count do
if scheduled_reasons[i] == reason then
scheduled_delays[i] = delay
return
end
end
scheduled_count = scheduled_count + 1
scheduled_reasons[scheduled_count] = reason
scheduled_delays[scheduled_count] = delay
end
local function check_convenient_transitions()
local name = game_mode_name()
if name ~= previous_game_mode_name then
if previous_game_mode_name and (is_training_mode(previous_game_mode_name) or is_mortis_mode(previous_game_mode_name) or is_expedition_mode(previous_game_mode_name)) then
schedule_convenient_clean("activity_end",1)
end
if is_hub_mode(name) then
schedule_convenient_clean("mourningstar",30)
elseif is_training_mode(name) or is_mortis_mode(name) or is_expedition_mode(name) then
schedule_convenient_clean("activity_start",1)
end
previous_game_mode_name = name
end
local safe_zone = in_safe_zone()
if safe_zone ~= nil and previous_safe_zone_state ~= nil and safe_zone ~= previous_safe_zone_state and safe_zone then
schedule_convenient_clean("sanctuary",1)
end
if safe_zone ~= nil then
previous_safe_zone_state = safe_zone
end
end
local function remove_scheduled_clean(index)
for i = index,scheduled_count - 1 do
scheduled_delays[i] = scheduled_delays[i + 1]
scheduled_reasons[i] = scheduled_reasons[i + 1]
end
scheduled_delays[scheduled_count] = nil
scheduled_reasons[scheduled_count] = nil
scheduled_count = scheduled_count - 1
end
local function run_convenient_clean(reason)
if not mod.convenient_moment_cleans or not cleaning_allowed() then
return
end
local name = game_mode_name()
if reason == "mourningstar" then
if is_hub_mode(name) then
perform_collect("auto")
end
elseif reason == "gameplay_enter" then
if is_hub_mode(name) then
schedule_convenient_clean("mourningstar",30)
else
perform_collect("auto")
end
else
perform_collect("auto")
end
end
local function tick_scheduled_clean(dt)
if scheduled_count <= 0 then
return
end
local due_count = 0
for i = scheduled_count,1,-1 do
scheduled_delays[i] = scheduled_delays[i] - (dt or 0)
if scheduled_delays[i] <= 0 then
due_count = due_count + 1
due_reasons[due_count] = scheduled_reasons[i]
remove_scheduled_clean(i)
end
end
if due_count > 0 then
for i = 1,due_count do
local reason = due_reasons[i]
due_reasons[i] = nil
run_convenient_clean(reason)
end
end
end
local function check_growth_trigger(usage_mb)
growth_accumulator = growth_accumulator + check_interval
if growth_accumulator < growth_window_seconds then
return
end
local previous_mb = growth_sample_mb or usage_mb
local delta_mb = usage_mb - previous_mb
local delta_percent = delta_mb / detected_heap_mb * 100
growth_sample_mb = usage_mb
growth_accumulator = 0
if cleaning_allowed() and usage_mb > threshold_thirty_mb and delta_percent >= 15 then
show_notification("Heap jumped over 15% in 30 seconds. Cleaning...",false,false)
perform_collect(false)
end
end
local function check_thresholds()
local usage_mb = memory_usage_mb()
if not cleaning_allowed() then
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
check_growth_trigger(usage_mb)
return
end
if usage_mb < threshold_eighty_mb then
finish_over_eighty_process()
check_growth_trigger(usage_mb)
return
end
local now = current_time()
if not over_eighty_since then
over_eighty_since = now
end
if usage_mb >= threshold_eightyfive_mb and not high_threshold_cycle_active then
trigger_eightyfive_warning()
end
if usage_mb >= threshold_ninetyfive_mb and not ninetyfive_collect_done then
trigger_ninetyfive_collect()
elseif usage_mb >= threshold_ninety_mb and high_threshold_cycle_active and not ninety_collect_done and not warning_acknowledged then
trigger_ninety_collect()
end
usage_mb = memory_usage_mb()
if usage_mb < threshold_eighty_mb then
finish_over_eighty_process()
check_growth_trigger(usage_mb)
return
end
if not over_eighty_active and now - over_eighty_since >= over_eighty_delay_seconds then
begin_over_eighty_process(usage_mb)
end
check_growth_trigger(usage_mb)
end
mod.manual_clear = function()
local t = current_time()
if not cleaning_allowed() then
show_cleaning_not_permitted()
return
end
if t < next_manual_clear_t then
return
end
next_manual_clear_t = t + manual_clear_cooldown
clean_dmf_chat_notifications()
if high_threshold_cycle_active then
warning_acknowledged = true
ninety_collect_done = true
pending_warning_return_delay = nil
clear_threshold_notification()
end
local _,after_mb = perform_collect("manual")
if after_mb < threshold_eighty_mb then
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
end
end
mod:command("smog",mod:localize("command_clear_desc"),function()
mod.manual_clear()
end)
mod.on_setting_changed = function(changed_setting)
if changed_setting == "cleaning_permitted" then
mod.cleaning_permitted = mod:get("cleaning_permitted") ~= false
if not cleaning_allowed() then
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
clear_scheduled_cleans()
interval_accumulator = 0
end
elseif changed_setting == "auto_clean_on_start" then
mod.convenient_moment_cleans = mod:get("auto_clean_on_start")
elseif changed_setting == "auto_clean_every_ten_minutes" then
mod.auto_clean_every_ten_minutes = mod:get("auto_clean_every_ten_minutes")
interval_accumulator = 0
elseif changed_setting == "notifications" then
mod.automatic_notifications = mod:get("notifications") ~= false
if not mod.automatic_notifications then
clear_queued_notifications()
if not notification_manual then
clear_notification()
end
end
elseif changed_setting == "hud_x_axis" then
mod._smog_hud_x_axis = tonumber(mod:get("hud_x_axis")) or 5
elseif changed_setting == "hud_y_axis" then
mod._smog_hud_y_axis = tonumber(mod:get("hud_y_axis")) or 65
elseif changed_setting == "notification_y_axis" then
mod._smog_notification_y_axis = tonumber(mod:get("notification_y_axis")) or 85
end
end
mod.on_game_state_changed = function(status,state_name)
if status == "enter" then
if state_name == "StateGameplay" then
schedule_convenient_clean("gameplay_enter",1)
end
elseif status == "exit" and state_name == "StateGameplay" and mod.convenient_moment_cleans and cleaning_allowed() then
perform_collect("auto")
end
end
mod.update = function(dt)
if mod.is_enabled and not mod:is_enabled() then
return
end
if type(dt) ~= "number" or dt <= 0 then
return
end
if not hud_registered then
hud_register_retry_t = hud_register_retry_t - dt
if hud_register_retry_t <= 0 then
hud_register_retry_t = 2
register_smog_hud_element()
end
end
if not first_update_done then
first_update_done = true
previous_game_mode_name = game_mode_name()
previous_safe_zone_state = in_safe_zone()
if is_hub_mode(previous_game_mode_name) then
schedule_convenient_clean("mourningstar",30)
end
end
accumulator = accumulator + dt
local check_due = false
if accumulator >= check_interval then
accumulator = accumulator - check_interval
persist_heap_state(usage_percent())
check_due = true
end
if not cleaning_allowed() then
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
interval_accumulator = 0
clear_scheduled_cleans()
return
end
tick_scheduled_clean(dt)
if mod.auto_clean_every_ten_minutes then
interval_accumulator = interval_accumulator + dt
if interval_accumulator >= interval_clean_time then
interval_accumulator = 0
perform_collect("auto")
end
else
interval_accumulator = 0
end
tick_pending_warning_return(dt)
tick_over_eighty_staged(dt)
if check_due then
check_convenient_transitions()
check_thresholds()
end
end
local function clean_shutdown()
local state = heap_state(usage_percent())
last_persisted_heap_state = state
mod:set("_smog_clean_shutdown",true)
mod:set("_smog_last_heap_percent",state)
save_settings_now()
end
mod.on_unload = function(exit_game)
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
clear_scheduled_cleans()
clear_all_notifications()
mod._smog_hud_visible = false
clean_shutdown()
end
mod.on_disabled = function(initial_call)
stop_over_eighty_process()
over_eighty_since = nil
reset_high_threshold_cycle()
clear_scheduled_cleans()
clear_all_notifications()
mod._smog_hud_visible = false
clean_shutdown()
end