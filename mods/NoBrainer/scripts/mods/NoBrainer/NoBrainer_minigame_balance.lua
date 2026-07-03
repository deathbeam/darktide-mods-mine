local mod = get_mod("NoBrainer")
local S = mod._S

local MinigameSettings = require("scripts/settings/minigame/minigame_settings")

mod._bal = {
	timer    = 0,
	enabled  = true,
	strength = 0.75,
	speed    = 5,
	scale    = 0,
	alpha_pos = 0.08,
	alpha_vel = 0.05,
	lazy_limit = 0.35,
	skip_chance = 0.25,
	apply_skip_chance = 0.12,
	kp = 0.43,
	kd = 0.10,
	x = 0, y = 0,
	vx = 0, vy = 0,
	dist = 0,
	prev_x = 0, prev_y = 0,
	delayed_x = 0, delayed_y = 0,
	delayed_dist = 0,
	delayed_vx = 0, delayed_vy = 0,
}

local st = mod._bal
local balance_active = false
local balance_completed = false

local function _reset_balance_tracking()
	st.timer = 0
	st.x, st.y = 0, 0
	st.vx, st.vy = 0, 0
	st.dist = 0
	st.prev_x, st.prev_y = 0, 0
	st.delayed_x, st.delayed_y = 0, 0
	st.delayed_dist = 0
	st.delayed_vx, st.delayed_vy = 0, 0
end

local function _balance_profile()
	local speed = mod._N("balance_solve_speed", 5, 1, 10)

	if speed <= 5 then
		local t = (speed - 1) / 4

		return {
			speed = speed,
			scale = 0.10 + t * 0.30,
			alpha_pos = 0.02 + t * 0.06,
			alpha_vel = 0.01 + t * 0.04,
			lazy_limit = 0.45 - t * 0.10,
			skip_chance = 0.40 - t * 0.15,
			apply_skip_chance = 0.18 - t * 0.06,
			kp = 0.22 + t * 0.21,
			kd = 0.02 + t * 0.08,
		}
	end

	local t = (speed - 5) / 5

	return {
		speed = speed,
		scale = 0.40 + t * 0.60,
		alpha_pos = 0.08 + t * 0.92,
		alpha_vel = 0.05 + t * 0.95,
		lazy_limit = 0.35 - t * 0.33,
		skip_chance = 0.25 * (1 - t),
		apply_skip_chance = 0.12 * (1 - t),
		kp = 0.43 + t * 1.17,
		kd = 0.10 + t * 1.10,
	}
end

local function _apply_balance_profile()
	local profile = _balance_profile()

	for key, value in pairs(profile) do
		st[key] = value
	end
end

mod:hook_safe("MinigameBalanceView", "_update_cursor", function(self)
	if not S("enable_balance") then return end
	local ext = self._minigame_extension
	local mg = ext and ext:minigame(MinigameSettings.types.balance)
	if not mg then mod._debug_event_throttle("balance_no_mg_event", 1.5, "balance", "wait", { reason = "no_minigame" }); return end
	if mg.is_completed and mg:is_completed() then return end
	local state = mg.state and mg:state()
	if state and state ~= MinigameSettings.game_states.gameplay then mod._debug_event_throttle("balance_not_gameplay_event", 1.5, "balance", "wait", { reason = "not_gameplay", state = state }); return end
	local p = mg:position()
	st.x, st.y = p.x, p.y
	st.dist = math.sqrt(p.x * p.x + p.y * p.y)
	st.timer = 0.05
end)

local function on_update(dt)
	if st.timer > 0 then
		st.timer = st.timer - dt
		if dt > 0 then
			local raw_vx = (st.x - st.prev_x) / dt
			local raw_vy = (st.y - st.prev_y) / dt
			st.vx = st.vx + (math.clamp(raw_vx, -10, 10) - st.vx) * 0.30
			st.vy = st.vy + (math.clamp(raw_vy, -10, 10) - st.vy) * 0.30
		end
	end
	st.prev_x, st.prev_y = st.x, st.y

	if st.timer > 0 then
		local alpha_pos = st.alpha_pos or 0.08
		local alpha_vel = st.alpha_vel or alpha_pos * 0.67

		st.delayed_x = st.delayed_x + (st.x - st.delayed_x) * alpha_pos
		st.delayed_y = st.delayed_y + (st.y - st.delayed_y) * alpha_pos
		st.delayed_dist = math.sqrt(st.delayed_x * st.delayed_x + st.delayed_y * st.delayed_y)
		st.delayed_vx = st.delayed_vx + (st.vx - st.delayed_vx) * alpha_vel
		st.delayed_vy = st.delayed_vy + (st.vy - st.delayed_vy) * alpha_vel
	else
		st.delayed_x, st.delayed_y = st.x, st.y
		st.delayed_dist = st.dist
		st.delayed_vx, st.delayed_vy = st.vx, st.vy
	end

	if balance_active and st.enabled and st.timer > 0 then
		mod._debug_event_throttle("balance_state_event", 1.0, "balance", "active", { dist = st.dist or 0, vx = st.vx or 0, vy = st.vy or 0, delayed_dist = st.delayed_dist or 0 })
	end
end

mod:hook_safe("MinigameBalance", "start", function()
	if not S("enable_balance") then return end
	_reset_balance_tracking()
	balance_active = true
	balance_completed = false
	st.enabled = true
	_apply_balance_profile()
	mod._debug_event("balance", "start", { kd = st.kd, kp = st.kp, scale = st.scale, speed = st.speed })
end)
mod:hook_safe("MinigameBalance", "stop", function()
	if balance_active and not balance_completed then
		mod._debug_event("balance", "stop")
	end

	balance_active = false
	balance_completed = false
	_reset_balance_tracking()
end)
mod:hook_safe("MinigameBalance", "complete", function()
	if balance_active then
		mod._debug_event("balance", "complete")
	end

	balance_active = false
	balance_completed = true
	_reset_balance_tracking()
end)

local function on_setting(id)
	if id == "balance_solve_speed" then _apply_balance_profile() end
	if id == "enable_balance" and not S("enable_balance") then _reset_balance_tracking() end
end
local function on_enabled() st.enabled = true; _apply_balance_profile() end
local function on_disabled() balance_active = false; balance_completed = false; st.enabled = false; _reset_balance_tracking() end
local function on_round_end() balance_active = false; balance_completed = false; _reset_balance_tracking() end

mod._reg("update", on_update)
mod._reg("setting_changed", on_setting)
mod._reg("enabled", on_enabled)
mod._reg("disabled", on_disabled)
mod._reg("round_end", on_round_end)
mod._reg("unload", on_round_end)

function mod._bal_correction(axis, vel, dist, strength)
	local response = axis * strength * (st.kp or 0.43) + (vel or 0) * strength * (st.kd or 0.10)
	local v = math.abs(response)

	if v <= 0.015 then return nil end

	local sign = response > 0 and 1 or -1

	if dist >= 0.88 then
		v = v + (dist - 0.88) / 0.1 * 0.15
	end

	return sign * math.clamp(v, 0, 1)
end

_apply_balance_profile()

return true
