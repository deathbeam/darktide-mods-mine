local mod = get_mod("CurioHunter")

local Promise = require("scripts/foundation/utilities/promise")
local StoreNames = require("scripts/settings/backend/store_names")

-- Helpers

local function get_curio_type(description)
	if not description then return nil end

	local traits = (description.overrides or {}).traits or {}
	local found

	for _, trait in ipairs(traits) do
		local id = string.lower(trait.id or "")
		if string.find(id, "health_segment", 1, true) then
			return "wound"
		elseif not found then
			if string.find(id, "health", 1, true) then found = "health"
			elseif string.find(id, "toughness", 1, true) then found = "toughness"
			elseif string.find(id, "stamina", 1, true) then found = "stamina"
			end
		end
	end

	return found
end

local function setting(id, fallback)
	local value = mod:get(id)
	if value == nil or value == "" then return fallback end
	return value
end

local function err_to_string(err)
	if type(err) == "table" then
		local msg = err.message or err.error or err.reason
		if msg then return tostring(msg) end
		local ok, str = pcall(function() return table.tostring(err) end)
		if ok and str then return str end
	end
	return tostring(err)
end

local function debug_echo(format_string, ...)
	if not setting("debug", false) then return end

	local ok, message = pcall(string.format, tostring(format_string), ...)
	mod:echo("[debug] " .. (ok and message or tostring(format_string)))
end

-- State

local sweep_generation = 0
local seen = {}
local in_flight = false
local in_flight_watchdog = 0
local purchased_offers = {}

local purchase_queue = {}
local purchase_in_progress = false
local purchase_in_flight_id = nil
local purchase_in_flight_match = nil
local purchase_in_flight_token = nil
local purchase_attempt_generation = 0
local purchase_cooldown = 0
local purchase_watchdog = 0
local retries = {}
local manual_sweep = false
local first_sweep_done = false
local accumulator = 0

local IN_FLIGHT_TIMEOUT = 30
local QUEUE_DELAY = 1.5
local MAX_RETRIES = 3
local PURCHASE_TIMEOUT = 15
local FIRST_SWEEP_DELAY = 10
local SWEEP_RETRY_DELAY = 30
local first_sweep_timer = FIRST_SWEEP_DELAY

-- Announce

local function announce(match, state)
	local class_label = match.archetype
		and mod:localize("include_" .. string.lower(match.archetype))
		or nil
	local who = class_label
		and string.format("%s | %s", match.character_name, class_label)
		or match.character_name
	mod:echo(string.format("%s: %s curio (power %d, %d cr) [%s]",
		state,
		match.curio_type:sub(1,1):upper() .. match.curio_type:sub(2),
		match.base_level, match.price, who))
end

-- Purchasing

local function queue_purchase(match)
	if not match or not match.offer_id then return end
	if purchased_offers[match.offer_id] then return end
	if purchase_in_flight_id == match.offer_id then return end

	for _, queued in ipairs(purchase_queue) do
		if queued.offer_id == match.offer_id then return end
	end

	purchase_queue[#purchase_queue + 1] = match
end

local function clear_purchase_attempt(token)
	if purchase_in_flight_token ~= token then return false end

	purchase_in_progress = false
	purchase_in_flight_id = nil
	purchase_in_flight_match = nil
	purchase_in_flight_token = nil
	purchase_watchdog = 0
	purchase_cooldown = QUEUE_DELAY

	return true
end

local function retry_purchase(match)
	local offer_id = match and match.offer_id
	if not offer_id or purchased_offers[offer_id] then return end

	local n = (retries[offer_id] or 0) + 1
	retries[offer_id] = n

	if n <= MAX_RETRIES then
		queue_purchase(match)
	else
		purchased_offers[offer_id] = true
		retries[offer_id] = nil
		debug_echo("giving up on offer %s after %d retries", tostring(offer_id), MAX_RETRIES)
	end
end

local function execute_purchase(match, on_complete)
	local function complete(success, terminal, err)
		if on_complete then on_complete(success, terminal, err) end
	end

	if not Managers or not Managers.data_service or not Managers.data_service.store then
		debug_echo("no data_service.store available")
		complete(false, false, "store service unavailable")
		return
	end

	local store = Managers.data_service.store
	store:invalidate_wallets_cache()

	local ok, promise = pcall(function()
		return store:purchase_item(match.offer)
	end)

	if not ok or not promise or type(promise.next) ~= "function" then
		debug_echo("purchase_item failed for %s: %s", tostring(match.offer_id), tostring(promise))
		complete(false, false, promise)
		return
	end

	promise:next(function()
		purchased_offers[match.offer_id] = true
		retries[match.offer_id] = nil
		debug_echo("BUY OK: %s curio %s", match.curio_type, tostring(match.offer_id))
		if not setting("silent", false) then announce(match, "BOUGHT") end
		complete(true, false)
	end):catch(function(err)
		local err_str = err_to_string(err)
		debug_echo("BUY FAILED: %s curio %s -> %s", match.curio_type, tostring(match.offer_id), err_str)

		local terminal = string.find(err_str, "No such offer", 1, true)
			or string.find(err_str, "Transaction id mismatch", 1, true)

		if terminal then
			purchased_offers[match.offer_id] = true
			retries[match.offer_id] = nil
		end

		complete(false, terminal and true or false, err)
	end)
end

-- Filtering

local function evaluate(entries)
	local min_power = tonumber(setting("min_power", 70)) or 70
	local matches = {}

	for _, entry in ipairs(entries or {}) do
		-- Class filter
		local archetype = entry.archetype
		if archetype and not setting("include_" .. string.lower(archetype), true) then
			goto continue
		end

		local offer = entry.offer
		if not offer then goto continue end

		local offer_id = offer.offerId
		if not offer_id then goto continue end

		local description = offer.description
		if not description then goto continue end
		if description.type ~= "gadget" then goto continue end

		local base_level = tonumber((description.overrides or {}).baseItemLevel) or 0
		if base_level < min_power then goto continue end

		local curio_type = get_curio_type(description)
		if not curio_type then goto continue end

		local action = setting("action_" .. curio_type, "notify")
		if action == "ignore" then goto continue end
		if purchased_offers[offer_id] then goto continue end

		local price = 0
		if offer.price and offer.price.amount then
			price = tonumber(offer.price.amount.amount) or 0
		end

		matches[#matches + 1] = {
			offer = offer,
			offer_id = offer_id,
			curio_type = curio_type,
			base_level = base_level,
			price = price,
			action = action,
			character_name = entry.character_name or "Unknown",
			archetype = entry.archetype,
		}

		::continue::
	end

	table.sort(matches, function(a, b) return a.base_level > b.base_level end)
	return matches
end

-- Store fetching

local function fetch_all_credit_stores(on_done)
	local finished = false

	local function finish(entries, succeeded)
		if finished then return end
		finished = true
		on_done(entries or {}, succeeded == true)
	end

	if not Managers or not Managers.backend then
		debug_echo("fetch aborted: no Managers.backend")
		finish({}, false)
		return
	end

	if not Managers.backend:authenticated() then
		debug_echo("fetch aborted: not authenticated")
		finish({}, false)
		return
	end

	local backend_interfaces = Managers.backend.interfaces
	local characters_backend = backend_interfaces and backend_interfaces.characters
	local store_backend = backend_interfaces and backend_interfaces.store

	if not characters_backend or not characters_backend.fetch or not store_backend then
		debug_echo("fetch aborted: missing backend interfaces")
		finish({}, false)
		return
	end

	-- Fetch raw character records instead of full profiles. Full profile conversion
	-- touches MasterItems and can run before its cache has been initialized.
	local ok, fetch_promise = pcall(characters_backend.fetch, characters_backend)
	if not ok or not fetch_promise or type(fetch_promise.next) ~= "function" then
		debug_echo("fetch aborted: characters fetch failed: %s", tostring(fetch_promise))
		finish({}, false)
		return
	end

	fetch_promise:next(function(characters)
		characters = characters or {}
		debug_echo("fetched %d characters", #characters)

		local promises = {}
		local lookup = {}
		local time_since_launch = Application and Application.time_since_launch
			and Application.time_since_launch()
			or nil

		for i = 1, #characters do
			local character = characters[i]
			local archetype_name = character and character.archetype
			local character_id = character and character.id
			local method = archetype_name and StoreNames.by_archetype.credit[archetype_name]

			if character_id and method and store_backend[method] then
				local store_ok, store_promise = pcall(
					store_backend[method],
					store_backend,
					time_since_launch,
					character_id
				)

				if store_ok and store_promise and type(store_promise.catch) == "function" then
					lookup[#lookup + 1] = {
						name = character.name or "Unknown",
						archetype = archetype_name,
						character_id = character_id,
					}
					promises[#promises + 1] = store_promise:catch(function(err)
						debug_echo("store fetch failed for %s (%s): %s",
							tostring(character.name or "Unknown"), tostring(archetype_name), err_to_string(err))

						-- Promise.all stores results in a Lua array. Returning false rather
						-- than nil preserves indexes for every character.
						return false
					end)
				else
					debug_echo("store call failed for %s (%s): %s",
						tostring(character.name or "Unknown"), tostring(archetype_name), tostring(store_promise))
				end
			else
				debug_echo("no store method for archetype %s (tried %s)", tostring(archetype_name), tostring(method))
			end
		end

		if #promises == 0 then
			debug_echo("no store promises created")
			finish({}, false)
			return
		end

		return Promise.all(unpack(promises)):next(function(stores)
			local entries = {}
			local successful_store_count = 0

			for i = 1, #promises do
				local store = stores[i]
				local character = lookup[i]
				if not store then goto next_store end

				successful_store_count = successful_store_count + 1

				local personal
				if store.data and store.data.personal then personal = store.data.personal
				elseif store.personal then personal = store.personal
				elseif store.items then personal = store.items
				end

				if personal then
					for j = 1, #personal do
						local item = personal[j]
						if item then
							entries[#entries + 1] = {
								offer = item,
								character_name = character.name,
								archetype = character.archetype,
							}
						end
					end
				end

				::next_store::
			end

			debug_echo("collected %d store entries", #entries)
			finish(entries, successful_store_count > 0)
		end)
	end):catch(function(err)
		debug_echo("fetch chain rejected: %s", err_to_string(err))
		finish({}, false)
	end)
end

-- Sweep

local function sweep()
	if in_flight then return end

	in_flight = true
	in_flight_watchdog = 0
	local is_manual = manual_sweep
	manual_sweep = false
	local gen = sweep_generation

	fetch_all_credit_stores(function(entries, fetch_succeeded)
		if gen ~= sweep_generation then
			debug_echo("discarding stale sweep (gen %d vs %d)", gen, sweep_generation)
			return
		end

		in_flight = false
		if not fetch_succeeded then
			local poll_seconds = tonumber(setting("poll_seconds", 3600)) or 3600
			accumulator = math.max(accumulator, math.max(0, poll_seconds - SWEEP_RETRY_DELAY))
		end

		local matches = evaluate(entries)
		debug_echo("evaluated %d entries -> %d matches", #entries, #matches)
		local acted = false

		for _, match in ipairs(matches) do
			if not seen[match.offer_id] then
				seen[match.offer_id] = true
				acted = true
				if match.action == "buy" then
					debug_echo("queueing buy: %s curio power %d (%d cr)", match.curio_type, match.base_level, match.price)
					queue_purchase(match)
				elseif match.action == "notify" then
					announce(match, "FOUND")
				end
			end
		end

		if is_manual and not setting("silent", false) then
			if not fetch_succeeded then
				mod:echo("Store check failed; retrying soon")
			elseif not acted then
				mod:echo("No matching curios found")
			end
		end
	end)
end

-- Update loop

mod.update = function(dt)
	if not mod:is_enabled() then return end
	if not Managers or not Managers.backend then return end
	if not Managers.backend:authenticated() then return end

	-- Sweep watchdog
	if in_flight then
		in_flight_watchdog = in_flight_watchdog + dt
		if in_flight_watchdog >= IN_FLIGHT_TIMEOUT then
			sweep_generation = sweep_generation + 1
			in_flight = false
			in_flight_watchdog = 0

			local poll_seconds = tonumber(setting("poll_seconds", 3600)) or 3600
			accumulator = math.max(accumulator, math.max(0, poll_seconds - SWEEP_RETRY_DELAY))
		end
	end

	-- Purchase queue
	if purchase_cooldown > 0 then purchase_cooldown = purchase_cooldown - dt end

	if purchase_in_progress then
		purchase_watchdog = purchase_watchdog + dt
		if purchase_watchdog >= PURCHASE_TIMEOUT then
			local token = purchase_in_flight_token
			local match = purchase_in_flight_match

			if clear_purchase_attempt(token) then
				debug_echo("purchase timed out for offer %s", tostring(match and match.offer_id))
				retry_purchase(match)
			end
		end
	end

	while #purchase_queue > 0 and purchased_offers[purchase_queue[1].offer_id] do
		table.remove(purchase_queue, 1)
	end

	if not purchase_in_progress and purchase_cooldown <= 0 and #purchase_queue > 0 then
		local match = table.remove(purchase_queue, 1)

		if not purchased_offers[match.offer_id] then
			purchase_attempt_generation = purchase_attempt_generation + 1
			local token = purchase_attempt_generation

			purchase_in_progress = true
			purchase_in_flight_id = match.offer_id
			purchase_in_flight_match = match
			purchase_in_flight_token = token
			purchase_watchdog = 0

			execute_purchase(match, function(success, terminal)
				if not clear_purchase_attempt(token) then return end
				if not success and not terminal then retry_purchase(match) end
			end)
		end
	end

	-- Initial sweep
	if not first_sweep_done then
		first_sweep_timer = first_sweep_timer - dt
		if first_sweep_timer <= 0 then
			first_sweep_done = true
			sweep()
		end
		return
	end

	-- Poll timer
	accumulator = accumulator + dt
	local poll_seconds = tonumber(setting("poll_seconds", 3600)) or 3600
	if accumulator >= poll_seconds then
		accumulator = 0
		sweep()
	end
end

-- Callbacks

mod.check_now = function()
	seen = {}
	manual_sweep = true
	if in_flight then
		sweep_generation = sweep_generation + 1
		in_flight = false
	end
	sweep()
end

mod.on_setting_changed = function()
	accumulator = 0
end

local function reset_state()
	sweep_generation = sweep_generation + 1
	accumulator = 0
	seen = {}
	in_flight = false
	in_flight_watchdog = 0
	purchased_offers = {}
	purchase_queue = {}
	purchase_in_progress = false
	purchase_in_flight_id = nil
	purchase_in_flight_match = nil
	purchase_in_flight_token = nil
	purchase_attempt_generation = purchase_attempt_generation + 1
	purchase_cooldown = 0
	purchase_watchdog = 0
	retries = {}
	manual_sweep = false
	first_sweep_done = false
	first_sweep_timer = FIRST_SWEEP_DELAY
end

mod.on_enabled = function() reset_state() end
mod.on_disabled = function() reset_state() end
