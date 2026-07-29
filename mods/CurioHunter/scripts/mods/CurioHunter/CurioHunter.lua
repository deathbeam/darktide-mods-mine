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

local function debug_echo(...)
	if setting("debug", false) then
		mod:echo("[debug] " .. string.format(...))
	end
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
local purchase_cooldown = 0
local purchase_watchdog = 0
local retries = {}
local manual_sweep = false
local first_sweep_done = false

local IN_FLIGHT_TIMEOUT = 30
local QUEUE_DELAY = 1.5
local MAX_RETRIES = 3
local PURCHASE_TIMEOUT = 15
local FIRST_SWEEP_DELAY = 10
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
	if purchased_offers[match.offer_id] then return end
	if purchase_in_flight_id == match.offer_id then return end

	for _, queued in ipairs(purchase_queue) do
		if queued.offer_id == match.offer_id then return end
	end

	purchase_queue[#purchase_queue + 1] = match
end

local function execute_purchase(match, on_complete)
	if not Managers or not Managers.data_service or not Managers.data_service.store then
		debug_echo("no data_service.store available")
		if on_complete then on_complete(false) end
		return
	end

	local store = Managers.data_service.store
	store:invalidate_wallets_cache()

	local ok, promise = pcall(function()
		return store:purchase_item(match.offer)
	end)

	if not ok or not promise then
		debug_echo("purchase_item failed for %s: %s", tostring(match.offer_id), tostring(promise))
		if on_complete then on_complete(false) end
		return
	end

	promise:next(function()
		purchased_offers[match.offer_id] = true
		retries[match.offer_id] = nil
		debug_echo("BUY OK: %s curio %s", match.curio_type, tostring(match.offer_id))
		if not setting("silent", false) then announce(match, "BOUGHT") end
		if on_complete then on_complete(true) end
	end):catch(function(err)
		local err_str = err_to_string(err)
		debug_echo("BUY FAILED: %s curio %s -> %s", match.curio_type, tostring(match.offer_id), err_str)

		if string.find(err_str, "No such offer", 1, true)
			or string.find(err_str, "Transaction id mismatch", 1, true) then
			purchased_offers[match.offer_id] = true
			retries[match.offer_id] = nil
		else
			local n = (retries[match.offer_id] or 0) + 1
			retries[match.offer_id] = n
			if n <= MAX_RETRIES then
				queue_purchase(match)
			else
				purchased_offers[match.offer_id] = true
				retries[match.offer_id] = nil
			end
		end

		if on_complete then on_complete(false) end
	end)
end

-- Filtering

local function evaluate(entries)
	local min_power = setting("min_power", 70)
	local matches = {}

	for _, entry in ipairs(entries or {}) do
		-- Class filter
		local archetype = entry.archetype
		if archetype and not setting("include_" .. string.lower(archetype), true) then
			goto continue
		end

		local offer = entry.offer
		if not offer then goto continue end

		local description = offer.description
		if not description then goto continue end
		if description.type ~= "gadget" then goto continue end

		local base_level = (description.overrides or {}).baseItemLevel or 0
		if base_level < min_power then goto continue end

		local curio_type = get_curio_type(description)
		if not curio_type then goto continue end

		local action = setting("action_" .. curio_type, "notify")
		if action == "ignore" then goto continue end
		if purchased_offers[offer.offerId] then goto continue end

		local price = 0
		if offer.price and offer.price.amount then
			price = offer.price.amount.amount or 0
		end

		matches[#matches + 1] = {
			offer = offer,
			offer_id = offer.offerId,
			curio_type = curio_type,
			base_level = base_level,
			price = price,
			action = action,
			character_name = entry.character_name,
			archetype = entry.archetype,
		}

		::continue::
	end

	table.sort(matches, function(a, b) return a.base_level > b.base_level end)
	return matches
end

-- Store fetching

local function fetch_all_credit_stores(on_done)
	if not Managers or not Managers.backend then
		debug_echo("fetch aborted: no Managers.backend")
		on_done({})
		return
	end

	if not Managers.backend:authenticated() then
		debug_echo("fetch aborted: not authenticated")
		on_done({})
		return
	end

	local profiles_service = Managers.data_service and Managers.data_service.profiles
	local store_backend = Managers.backend.interfaces and Managers.backend.interfaces.store

	if not profiles_service or not store_backend then
		debug_echo("fetch aborted: missing services")
		on_done({})
		return
	end

	local fetch_promise = profiles_service:fetch_all_profiles()
	if not fetch_promise then
		debug_echo("fetch aborted: fetch_all_profiles returned nil")
		on_done({})
		return
	end

	fetch_promise:next(function(result)
		local profiles = result and result.profiles or {}
		debug_echo("fetched %d profiles", #profiles)
		local promises = {}
		local lookup = {}

		for i = 1, #profiles do
			local profile = profiles[i]
			local archetype_name = profile.archetype and profile.archetype.name
			local method = archetype_name and StoreNames.by_archetype.credit[archetype_name]

			if method and store_backend[method] then
				lookup[#lookup + 1] = profile
				promises[#promises + 1] = store_backend[method](store_backend, nil, profile.character_id):catch(function(err)
					debug_echo("store fetch failed for %s (%s): %s",
						tostring(profile.name or "Unknown"), tostring(archetype_name), err_to_string(err))
					return nil
				end)
			else
				debug_echo("no store method for archetype %s (tried %s)", tostring(archetype_name), tostring(method))
			end
		end

		if #promises == 0 then
			debug_echo("no store promises created")
			on_done({})
			return
		end

		return Promise.all(unpack(promises)):next(function(stores)
			local entries = {}

			for i = 1, #stores do
				local store = stores[i]
				local profile = lookup[i]
				if not store then goto next_store end

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
								character_name = profile.name or "Unknown",
								archetype = profile.archetype and profile.archetype.name,
							}
						end
					end
				end

				::next_store::
			end

			debug_echo("collected %d store entries", #entries)
			on_done(entries)
		end)
	end):catch(function(err)
		debug_echo("fetch chain rejected: %s", err_to_string(err))
		on_done({})
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

	fetch_all_credit_stores(function(entries)
		if gen ~= sweep_generation then
			debug_echo("discarding stale sweep (gen %d vs %d)", gen, sweep_generation)
			return
		end

		in_flight = false
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

		if is_manual and not acted and not setting("silent", false) then
			mod:echo("No matching curios found")
		end
	end)
end

-- Update loop

local accumulator = 0

mod.update = function(dt)
	if not mod:is_enabled() then return end
	if not Managers or not Managers.backend then return end
	if not Managers.backend:authenticated() then return end

	-- Sweep watchdog
	if in_flight then
		in_flight_watchdog = in_flight_watchdog + dt
		if in_flight_watchdog >= IN_FLIGHT_TIMEOUT then in_flight = false end
	end

	-- Purchase queue
	if purchase_cooldown > 0 then purchase_cooldown = purchase_cooldown - dt end

	if purchase_in_progress then
		purchase_watchdog = purchase_watchdog + dt
		if purchase_watchdog >= PURCHASE_TIMEOUT then
			if purchase_in_flight_id then
				local n = (retries[purchase_in_flight_id] or 0) + 1
				retries[purchase_in_flight_id] = n
				if n > MAX_RETRIES then
					purchased_offers[purchase_in_flight_id] = true
					retries[purchase_in_flight_id] = nil
				end
			end
			purchase_in_progress = false
			purchase_in_flight_id = nil
			purchase_cooldown = QUEUE_DELAY
		end
	end

	if not purchase_in_progress and purchase_cooldown <= 0 and #purchase_queue > 0 then
		local match = table.remove(purchase_queue, 1)
		purchase_in_progress = true
		purchase_in_flight_id = match.offer_id
		purchase_watchdog = 0
		execute_purchase(match, function()
			if purchase_in_flight_id == match.offer_id then
				purchase_in_progress = false
				purchase_in_flight_id = nil
				purchase_cooldown = QUEUE_DELAY
			end
		end)
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
	local poll_seconds = setting("poll_seconds", 300)
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
	purchase_cooldown = 0
	purchase_watchdog = 0
	retries = {}
	manual_sweep = false
	first_sweep_done = false
	first_sweep_timer = FIRST_SWEEP_DELAY
end

mod.on_enabled = function() reset_state() end
mod.on_disabled = function() reset_state() end
