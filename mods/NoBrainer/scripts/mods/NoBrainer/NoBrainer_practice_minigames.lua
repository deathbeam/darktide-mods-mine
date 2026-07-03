local mod = get_mod("NoBrainer")
local MinigameSettings = require("scripts/settings/minigame/minigame_settings")

local math_random = math.random
local math_clamp = math.clamp
local math_max = math.max
local math_abs = math.abs
local math_sin = math.sin
local math_cos = math.cos
local math_pi = math.pi
local math_sqrt = math.sqrt
local math_atan2 = math.atan2

local function _gameplay_time()
	return mod._time("gameplay") or 0
end

local WWISE_EVENTS = {
	sfx_minigame_success           = "wwise/events/player/play_device_auspex_scanner_minigame_progress",
	sfx_minigame_success_last      = "wwise/events/player/play_device_auspex_scanner_minigame_progress_last",
	sfx_minigame_fail              = "wwise/events/player/play_device_auspex_scanner_minigame_fail",
	sfx_minigame_bio_selection     = "wwise/events/player/play_device_auspex_bio_minigame_selection",
	sfx_minigame_bio_progress      = "wwise/events/player/play_device_auspex_bio_minigame_progress",
	sfx_minigame_bio_fail          = "wwise/events/player/play_device_auspex_bio_minigame_fail",
	sfx_minigame_sinus_adjust_x    = "wwise/events/player/play_device_auspex_scanner_minigame_sinus_adjust_x",
	sfx_minigame_sinus_adjust_y    = "wwise/events/player/play_device_auspex_scanner_minigame_sinus_adjust_y",
	sfx_minigame_sinus_success_last = "wwise/events/player/play_device_auspex_scanner_minigame_sinus_aligned",
}

local function _play_wwise(wwise_event)
	local world_manager = Managers.world
	local world = world_manager and world_manager:world("level_world")
	if not world then return end
	local wwise_world = World.get_data(world, "wwise_world")
	if not wwise_world then return end
	WwiseWorld.trigger_resource_event(wwise_world, wwise_event)
end

local PracticeBase = {}
PracticeBase.__index = PracticeBase

function PracticeBase:_init_base(stage_amount)
	self._action_held = nil
	self._completed = false
	self._current_stage = 1
	self._current_state = MinigameSettings.game_states.gameplay
	self._stage_amount = stage_amount or 1
	self._should_exit = false
end

function PracticeBase:is_completed()
	return self._completed or self._current_stage > self._stage_amount
end

function PracticeBase:complete()
	self._completed = true
	self._current_stage = self._stage_amount + 1
end

function PracticeBase:current_stage()
	return self._current_stage
end

function PracticeBase:state()
	return self._current_state
end

function PracticeBase:uses_action()
	return true
end

function PracticeBase:uses_joystick()
	return false
end

function PracticeBase:start(player)
	self._action_held = false
	self._player = player
	self._should_exit = false
	self._practice_start = _gameplay_time()
end

function PracticeBase:stop()
	self._should_exit = true
end

function PracticeBase:setup_game()
	return
end

function PracticeBase:handle_state(state)
	if state == MinigameSettings.game_states.intro then
		return MinigameSettings.game_states.gameplay
	elseif state == MinigameSettings.game_states.transition and self:is_completed() then
		return MinigameSettings.game_states.outro
	end
	return state
end

function PracticeBase:set_state(state)
	self._current_state = self:handle_state(state)
end

function PracticeBase:action(held, t)
	if self._action_held == nil then
		self._action_held = held
		if held then
			self:on_action_pressed(t or _gameplay_time())
		end
		return held
	end
	if self._action_held ~= held then
		self._action_held = held
		if held then
			self:on_action_pressed(t or _gameplay_time())
		else
			self:on_action_released(t or _gameplay_time())
		end
		return true
	end
	return false
end

function PracticeBase:on_action_pressed(t) return end
function PracticeBase:on_action_released(t) return end
function PracticeBase:on_axis_set(t, x, y) return end
function PracticeBase:update(dt, t) return end

function PracticeBase:escape_action(action_two_pressed)
	if action_two_pressed then
		self._should_exit = true
		return true
	end
	return false
end

function PracticeBase:blocks_weapon_actions() return true end
function PracticeBase:should_exit() return self._should_exit or self:is_completed() end
function PracticeBase:angle_check() return false end
function PracticeBase:unit() return nil end
function PracticeBase:unequip_on_exit() return false end

function PracticeBase:play_sound(alias)
	if not alias then return end
	local wwise_event = WWISE_EVENTS[alias]
	if wwise_event then
		_play_wwise(wwise_event)
	end
end

local PracticeDecode = setmetatable({}, { __index = PracticeBase })
PracticeDecode.__index = PracticeDecode

local function _random_decode_targets(stage_amount)
	local targets = {}
	local prev = nil
	for stage = 1, stage_amount do
		local target = math_random(1, MinigameSettings.decode_symbols_items_per_stage)
		if MinigameSettings.decode_symbols_items_per_stage > 1 and prev and target == prev and math_random() < 0.65 then
			target = target % MinigameSettings.decode_symbols_items_per_stage + 1
		end
		targets[stage] = target
		prev = target
	end
	return targets
end

function PracticeDecode:new()
	local stage_amount = MinigameSettings.decode_symbols_stage_amount
	local total = stage_amount * MinigameSettings.decode_symbols_items_per_stage
	local pool = MinigameSettings.decode_symbols_total_items
	local symbols = {}
	for i = 1, total do
		symbols[i] = (i - 1) % pool + 1
	end
	local mg = setmetatable({
		_decode_targets = _random_decode_targets(stage_amount),
		_decode_symbols_sweep_duration = MinigameSettings.decode_symbols_sweep_duration,
		_decode_symbols_items_per_stage = MinigameSettings.decode_symbols_items_per_stage,
		_start_time = _gameplay_time(),
		_symbols = symbols,
	}, PracticeDecode)
	mg:_init_base(stage_amount)
	return mg
end

function PracticeDecode:start(player)
	PracticeBase.start(self, player)
	self._start_time = _gameplay_time()
end

function PracticeDecode:start_time() return self._start_time end
function PracticeDecode:current_decode_target() return self._decode_targets[self._current_stage] end
function PracticeDecode:sweep_duration() return self._decode_symbols_sweep_duration end
function PracticeDecode:symbols() return self._symbols end

function PracticeDecode:_calculate_cursor_time(time)
	local dt = (time or _gameplay_time()) - self._start_time
	local sd = self:sweep_duration()
	local ct = dt % (sd * 2)
	if sd < ct then ct = 2 * sd - ct end
	return ct
end

function PracticeDecode:is_on_target(time)
	local target = self:current_decode_target()
	if not target then return false end
	local sd = self:sweep_duration()
	local margin = 1 / (self._decode_symbols_items_per_stage - 1) * sd
	local start_t = (target - 1.5) * margin
	local end_t = (target - 0.5) * margin
	local ct = self:_calculate_cursor_time(time)
	return start_t < ct and ct < end_t
end

function PracticeDecode:on_action_pressed(t)
	if self:is_on_target(t) then
		local is_last = self._current_stage >= self._stage_amount
		self._current_stage = self._current_stage + 1
		if self._current_stage > self._stage_amount then
			self:complete()
		end
		self:play_sound(is_last and "sfx_minigame_success_last" or "sfx_minigame_success")
	else
		self._current_stage = math_max(self._current_stage - 1, 1)
		self:play_sound("sfx_minigame_fail")
	end
end

local PracticeSearch = setmetatable({}, { __index = PracticeBase })
PracticeSearch.__index = PracticeSearch

local SEARCH_BOARD_W = MinigameSettings.decode_search_board_width
local SEARCH_BOARD_H = MinigameSettings.decode_search_board_height
local SEARCH_CURSOR_W = MinigameSettings.decode_search_cursor_width
local SEARCH_CURSOR_H = MinigameSettings.decode_search_cursor_height

local function _random_symbols()
	local pool = MinigameSettings.decode_symbols_total_items
	local symbols = {}
	for i = 1, SEARCH_BOARD_W * SEARCH_BOARD_H do
		symbols[i] = math_random(1, pool)
	end
	return symbols
end

local function _random_targets(symbols)
	local stage_amount = MinigameSettings.decode_search_stage_amount
	local targets = {}
	for stage = 1, stage_amount do
		local x = math_random(0, SEARCH_BOARD_W - SEARCH_CURSOR_W)
		local y = math_random(0, SEARCH_BOARD_H - SEARCH_CURSOR_H)
		local pattern = {}
		for dy = 0, SEARCH_CURSOR_H - 1 do
			for dx = 0, SEARCH_CURSOR_W - 1 do
				local idx = (y + dy) * SEARCH_BOARD_W + (x + dx) + 1
				pattern[#pattern + 1] = symbols[idx]
			end
		end
		targets[stage] = pattern
	end
	return targets
end

function PracticeSearch:new()
	local symbols = _random_symbols()
	local mg = setmetatable({
		_symbols = symbols,
		_decode_targets = _random_targets(symbols),
		_cursor_position = { x = 1, y = 1 },
		_time_since_move = 999,
		_last_move_time = _gameplay_time(),
	}, PracticeSearch)
	mg:_init_base(MinigameSettings.decode_search_stage_amount)
	return mg
end

function PracticeSearch:start(player)
	PracticeBase.start(self, player)
	self._cursor_position = { x = 1, y = 1 }
	self._last_move_time = _gameplay_time()
end

function PracticeSearch:symbols() return self._symbols end
function PracticeSearch:decode_targets() return self._decode_targets end
function PracticeSearch:cursor_position() return self._cursor_position end
function PracticeSearch:time_since_move() return _gameplay_time() - self._last_move_time end

function PracticeSearch:is_on_target()
	local stage = self._current_stage
	local target = self._decode_targets[stage]
	if not target then return false end
	local cx = self._cursor_position.x
	local cy = self._cursor_position.y
	for dy = 0, SEARCH_CURSOR_H - 1 do
		for dx = 0, SEARCH_CURSOR_W - 1 do
			local board_idx = (cy + dy - 1) * SEARCH_BOARD_W + (cx + dx - 1) + 1
			local target_idx = dy * SEARCH_CURSOR_W + dx + 1
			if self._symbols[board_idx] ~= target[target_idx] then
				return false
			end
		end
	end
	return true
end

function PracticeSearch:on_axis_set(t, x, y)
	local now = t or _gameplay_time()
	if now < self._last_move_time + 0.25 then return end
	self._last_move_time = now

	if math_abs(x) > math_abs(y) then
		if x > 0.5 then
			self._cursor_position.x = math_clamp(self._cursor_position.x + 1, 1, SEARCH_BOARD_W - SEARCH_CURSOR_W + 1)
		elseif x < -0.5 then
			self._cursor_position.x = math_clamp(self._cursor_position.x - 1, 1, SEARCH_BOARD_W - SEARCH_CURSOR_W + 1)
		end
	else
		if y > 0.5 then
			self._cursor_position.y = math_clamp(self._cursor_position.y + 1, 1, SEARCH_BOARD_H - SEARCH_CURSOR_H + 1)
		elseif y < -0.5 then
			self._cursor_position.y = math_clamp(self._cursor_position.y - 1, 1, SEARCH_BOARD_H - SEARCH_CURSOR_H + 1)
		end
	end
end

function PracticeSearch:on_action_pressed(t)
	if self:is_on_target() then
		self._current_stage = self._current_stage + 1
		if self._current_stage > self._stage_amount then
			self:complete()
		end
		self:play_sound("sfx_minigame_success")
	else
		self:play_sound("sfx_minigame_fail")
	end
end

function PracticeSearch:uses_joystick() return true end

local PracticeDrill = setmetatable({}, { __index = PracticeBase })
PracticeDrill.__index = PracticeDrill

local DRILL_TEMPLATES = {
	{
		{ x = -0.72, y = 0.23 }, { x = -0.21, y = -0.24 }, { x = 0.11, y = 0.34 },
		{ x = 0.64, y = -0.09 }, { x = 0.27, y = -0.39 },
	},
	{
		{ x = -0.61, y = -0.04 }, { x = -0.07, y = 0.29 }, { x = 0.46, y = -0.22 },
		{ x = 0.75, y = 0.21 }, { x = 0.05, y = -0.43 },
	},
	{
		{ x = -0.77, y = -0.17 }, { x = -0.29, y = 0.35 }, { x = 0.24, y = -0.32 },
		{ x = 0.68, y = 0.09 }, { x = 0.02, y = 0.03 },
	},
}

local function _randomized_drill_targets()
	local result = {}
	for stage = 1, #DRILL_TEMPLATES do
		local base = DRILL_TEMPLATES[stage]
		local mx = math_random(0, 1) == 1 and -1 or 1
		local my = math_random(0, 1) == 1 and -1 or 1
		local rot = (math_random() * 2 - 1) * 0.45
		local sr, cr = math_sin(rot), math_cos(rot)
		local stage_targets = {}
		for i = 1, #base do
			local bx, by = base[i].x * mx, base[i].y * my
			stage_targets[i] = {
				x = math_clamp(bx * cr - by * sr + (math_random() * 2 - 1) * 0.05, -0.82, 0.82),
				y = math_clamp(bx * sr + by * cr + (math_random() * 2 - 1) * 0.05, -0.48, 0.48),
			}
		end
		result[stage] = stage_targets
	end
	return result
end

local DRILL_MOVE_DELAY          = MinigameSettings.drill_move_delay
local DRILL_SEARCH_TIME         = MinigameSettings.drill_search_time
local DRILL_MOVE_DISTANCE_POWER = MinigameSettings.drill_move_distance_power

function PracticeDrill:new()
	local stage_amount = MinigameSettings.drill_stage_amount
	local targets = _randomized_drill_targets()
	local correct = {}
	for stage = 1, stage_amount do
		correct[stage] = math_random(1, #targets[stage])
	end
	local mg = setmetatable({
		_targets = targets,
		_correct_targets = correct,
		_cursor_position = { x = 0, y = 0 },
		_selected_index = nil,
		_search_time = false,
		_last_move = 0,
	}, PracticeDrill)
	mg:_init_base(stage_amount)
	return mg
end

function PracticeDrill:start(player)
	PracticeBase.start(self, player)
	self._cursor_position = { x = 0, y = 0 }
	self._selected_index = nil
	self._search_time = false
	self._last_move = 0
end

function PracticeDrill:targets() return self._targets end
function PracticeDrill:correct_targets() return self._correct_targets end
function PracticeDrill:cursor_position() return self._cursor_position end
function PracticeDrill:selected_index() return self._selected_index end
function PracticeDrill:state() return self._current_state end

function PracticeDrill:is_on_target()
	return self._selected_index == self._correct_targets[self._current_stage]
end

function PracticeDrill:is_searching()
	return self._search_time ~= false
end

function PracticeDrill:search_percentage(t)
	if not self._search_time then return 0 end
	return math_clamp(((t or _gameplay_time()) - self._search_time) / DRILL_SEARCH_TIME, 0, 1)
end

function PracticeDrill:transition_percentage(t) return 0 end

function PracticeDrill:on_axis_set(t, x, y)
	if x == 0 and y == 0 then return end
	if self._current_state ~= MinigameSettings.game_states.gameplay then return end

	local now = t or _gameplay_time()
	if now <= self._last_move + DRILL_MOVE_DELAY then return end
	self._last_move = now

	local aim_radian = math_atan2(y, x)
	local stage = self._current_stage
	local targets = self._targets[stage]
	if not targets then return end

	local cursor_position = self._cursor_position
	local closest_index, lowest_points = nil, math.huge

	for i = 1, #targets do
		if i ~= self._selected_index then
			local target = targets[i]
			local radian = math_atan2(target.y - cursor_position.y, target.x - cursor_position.x)
			local angle = math_abs(radian - aim_radian)
			if angle > math_pi then angle = 2 * math_pi - angle end

			local dist = math_sqrt((cursor_position.x - target.x) * (cursor_position.x - target.x) + (cursor_position.y - target.y) * (cursor_position.y - target.y))
			local points = dist + angle * DRILL_MOVE_DISTANCE_POWER

			if points < lowest_points and angle < math_pi / 3 then
				closest_index = i
				lowest_points = points
			end
		end
	end

	if closest_index then
		self._selected_index = closest_index
		self._search_time = false
		local target = targets[closest_index]
		cursor_position.x = target.x
		cursor_position.y = target.y
		self:play_sound("sfx_minigame_bio_selection")
	end
end

function PracticeDrill:on_action_pressed(t)
	local now = t or _gameplay_time()
	if self._current_state ~= MinigameSettings.game_states.gameplay or not self._selected_index then return end

	if not self._search_time then
		self._search_time = now
		return
	end

	if self:search_percentage(now) < 1 then return end

	if self:is_on_target() then
		self._search_time = false
		self._selected_index = nil
		self._cursor_position.x = 0
		self._cursor_position.y = 0
		self._current_stage = self._current_stage + 1
		self:play_sound("sfx_minigame_bio_progress")
		if self._current_stage > self._stage_amount then
			self:complete()
		end
	else
		self._search_time = false
		self:play_sound("sfx_minigame_bio_fail")
	end
end

function PracticeDrill:uses_joystick() return true end

local PracticeFreq = setmetatable({}, { __index = PracticeBase })
PracticeFreq.__index = PracticeFreq

local FREQ_CHANGE_RATIO_X = MinigameSettings.frequency_change_ratio_x
local FREQ_CHANGE_RATIO_Y = MinigameSettings.frequency_change_ratio_y
local FREQ_MARGIN         = MinigameSettings.frequency_success_margin
local FREQ_MIN_X          = MinigameSettings.frequency_width_min_scale
local FREQ_MAX_X          = MinigameSettings.frequency_width_max_scale
local FREQ_MIN_Y          = MinigameSettings.frequency_height_min_scale
local FREQ_MAX_Y          = MinigameSettings.frequency_height_max_scale
local FREQ_SENSITIVITY    = 0.4

local function _random_freq()
	return {
		x = FREQ_MIN_X + math_random() * (FREQ_MAX_X - FREQ_MIN_X),
		y = FREQ_MIN_Y + math_random() * (FREQ_MAX_Y - FREQ_MIN_Y),
	}
end

local function _random_freq_pair()
	local freq = _random_freq()
	local target
	repeat
		target = _random_freq()
	until math_abs(freq.x - target.x) >= FREQ_MARGIN and math_abs(freq.y - target.y) >= FREQ_MARGIN
	return freq, target
end

function PracticeFreq:new()
	local stage_amount = MinigameSettings.frequency_search_stage_amount
	local freq, target = _random_freq_pair()
	local mg = setmetatable({
		_frequency = freq,
		_target_frequency = target,
		_last_axis_set = 0,
	}, PracticeFreq)
	mg:_init_base(stage_amount)
	return mg
end

function PracticeFreq:start(player)
	PracticeBase.start(self, player)
	local freq, target = _random_freq_pair()
	self._frequency = freq
	self._target_frequency = target
	self._last_axis_set = 0
end

function PracticeFreq:frequency() return self._frequency end
function PracticeFreq:target_frequency() return self._target_frequency end
function PracticeFreq:current_stage() return self._current_stage end
function PracticeFreq:uses_joystick() return true end

function PracticeFreq:is_visually_on_target()
	local cur = self._frequency
	local tgt = self._target_frequency
	return math_abs(cur.x - tgt.x) < FREQ_MARGIN and math_abs(cur.y - tgt.y) < FREQ_MARGIN
end

function PracticeFreq:on_axis_set(t, x, y)
	if not t then t = _gameplay_time() end
	if not self._last_axis_set or self._last_axis_set <= 0 then
		self._last_axis_set = t
		return
	end

	local dt_input = t - self._last_axis_set
	self._last_axis_set = t
	if dt_input > 0.2 then dt_input = 0.2 end

	if x ~= 0 then
		self._frequency.x = math_clamp(self._frequency.x + (x or 0) * FREQ_SENSITIVITY * FREQ_CHANGE_RATIO_X * dt_input, FREQ_MIN_X, FREQ_MAX_X)
		self:play_sound("sfx_minigame_sinus_adjust_x")
	end
	if y ~= 0 then
		self._frequency.y = math_clamp(self._frequency.y + (y or 0) * FREQ_SENSITIVITY * FREQ_CHANGE_RATIO_Y * dt_input, FREQ_MIN_Y, FREQ_MAX_Y)
		self:play_sound("sfx_minigame_sinus_adjust_y")
	end
end

function PracticeFreq:on_action_pressed(t)
	if self:is_visually_on_target() then
		self._current_stage = self._current_stage + 1
		if self._current_stage > self._stage_amount then
			self:complete()
			self:play_sound("sfx_minigame_sinus_success_last")
		else
			local freq, target = _random_freq_pair()
			self._frequency = freq
			self._target_frequency = target
			self:play_sound("sfx_minigame_success")
		end
	else
		if self._current_stage > 1 then
			local freq, target = _random_freq_pair()
			self._frequency = freq
			self._target_frequency = target
		end
		self._current_stage = math_max(self._current_stage - 1, 1)
		self:play_sound("sfx_minigame_bio_fail")
	end
end

local PracticeBalance = setmetatable({}, { __index = PracticeBase })
PracticeBalance.__index = PracticeBalance

local BALANCE_MOVE_RATIO      = MinigameSettings.balance_move_ratio
local BALANCE_PUSH_RATIO      = 2.2
local BALANCE_DISRUPT_INTERVAL = 1.6
local BALANCE_DISRUPT_POWER   = 1.0
local BALANCE_MAX_SPEED       = MinigameSettings.balance_max_speed
local BALANCE_PROGRESS_RATE   = 0.05

function PracticeBalance:new()
	local mg = setmetatable({
		_position = { x = 0, y = 0 },
		_velocity = { x = 0, y = 0 },
		_distance = 0,
		_progression = 0,
		_disrupt_timer = BALANCE_DISRUPT_INTERVAL,
		_last_axis_set = 0,
		_is_stuck = false,
		_sound_alert_time = 0,
	}, PracticeBalance)
	mg:_init_base(1)
	return mg
end

function PracticeBalance:start(player)
	PracticeBase.start(self, player)
	self._position = { x = 0, y = 0 }
	self._velocity = { x = 0, y = 0 }
	self._distance = 0
	self._progression = 0
	self._disrupt_timer = BALANCE_DISRUPT_INTERVAL
	self._last_axis_set = 0
	self._is_stuck = false
	self._sound_alert_time = 0
end

function PracticeBalance:position() return self._position end
function PracticeBalance:distance() return self._distance end
function PracticeBalance:uses_action() return false end
function PracticeBalance:uses_joystick() return true end

function PracticeBalance:progressing()
	return self._distance < 1.0
end

function PracticeBalance:progression()
	return self._progression
end

function PracticeBalance:update(dt, t)
	local pos = self._position
	local vel = self._velocity
	local dist = math_sqrt(pos.x * pos.x + pos.y * pos.y)

	if dist < 1.0 then
		local power = (1.0 - dist) * BALANCE_PUSH_RATIO * dt
		if dist > 0.001 then
			vel.x = vel.x + (pos.x / dist) * power
			vel.y = vel.y + (pos.y / dist) * power
		else
			local angle = math_random() * 2 * math_pi
			vel.x = vel.x + math_cos(angle) * power
			vel.y = vel.y + math_sin(angle) * power
		end
	end

	self._disrupt_timer = self._disrupt_timer - dt
	if not self:progressing() then
		self._disrupt_timer = BALANCE_DISRUPT_INTERVAL
	elseif self._disrupt_timer <= 0 then
		self._disrupt_timer = self._disrupt_timer + BALANCE_DISRUPT_INTERVAL
		local angle = math_random() * 2 * math_pi
		vel.x = vel.x + math_cos(angle) * BALANCE_DISRUPT_POWER
		vel.y = vel.y + math_sin(angle) * BALANCE_DISRUPT_POWER
	end

	vel.x = math_clamp(vel.x, -BALANCE_MAX_SPEED, BALANCE_MAX_SPEED)
	vel.y = math_clamp(vel.y, -BALANCE_MAX_SPEED, BALANCE_MAX_SPEED)

	pos.x = pos.x + vel.x * dt
	pos.y = pos.y + vel.y * dt

	dist = math_sqrt(pos.x * pos.x + pos.y * pos.y)
	if dist > 1.02 then
		pos.x = pos.x / dist * 1.01
		pos.y = pos.y / dist * 1.01
		vel.x = 0
		vel.y = 0
		dist = 1.01
	end

	self._distance = dist

	if dist < 1.0 then
		self._progression = math_clamp(self._progression + BALANCE_PROGRESS_RATE * dt, 0, 1)
		if self._progression >= 1.0 then
			self:complete()
		end
	else
		self._progression = math_clamp(self._progression - BALANCE_PROGRESS_RATE * dt * 2, 0, 1)
	end

	if self._sound_alert_time > 0 then
		self._sound_alert_time = self._sound_alert_time - dt
	else
		local is_stuck = not self:progressing()
		if is_stuck ~= self._is_stuck then
			if is_stuck then
				self:play_sound("sfx_minigame_fail")
			end
			self._is_stuck = is_stuck
			self._sound_alert_time = 0.4
		end
	end
end

function PracticeBalance:on_axis_set(t, x, y)
	if not t then t = _gameplay_time() end
	if not self._last_axis_set or self._last_axis_set <= 0 then
		self._last_axis_set = t
		return
	end

	local dt_input = t - self._last_axis_set
	self._last_axis_set = t
	if dt_input > 0.2 then dt_input = 0.2 end

	if x ~= 0 then
		self._velocity.x = self._velocity.x + x * BALANCE_MOVE_RATIO * dt_input
	end
	if y ~= 0 then
		self._velocity.y = self._velocity.y + y * BALANCE_MOVE_RATIO * dt_input
	end
end

local PracticeMinigameExtension = {}
PracticeMinigameExtension.__index = PracticeMinigameExtension

function PracticeMinigameExtension:new(minigame_type, minigame)
	return setmetatable({
		_minigame = minigame,
		_minigame_type = minigame_type,
	}, PracticeMinigameExtension)
end

function PracticeMinigameExtension:minigame()
	return self._minigame
end

function PracticeMinigameExtension:minigame_type()
	return self._minigame_type
end

local PRACTICE_FACTORIES = {
	decode_symbols = function() return PracticeDecode:new() end,
	decode_search  = function() return PracticeSearch:new() end,
	drill          = function() return PracticeDrill:new() end,
	frequency      = function() return PracticeFreq:new() end,
	balance        = function() return PracticeBalance:new() end,
}

mod._practice_create = function(minigame_type)
	local factory = PRACTICE_FACTORIES[minigame_type]
	if not factory then return nil end
	local mg = factory()
	local ext = PracticeMinigameExtension:new(minigame_type, mg)
	return ext, mg
end

return true
