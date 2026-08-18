-- Pilgrimage_localization.lua
--
-- All player-visible strings. Keys match setting_ids by convention, with a
-- _tooltip suffix for the hover text, so the data file can derive them.

local function title(text)
	-- Darktide's UI colour markup. Amber for group headers matches the terminal look.
	return "{#color(200,140,20)}" .. text .. "{#reset()}"
end

return {
	mod_name = {
		en = "Pilgrimage",
	},
	mod_description = {
		en = "A solo expedition mode. Chain missions into a single run, gaining boons " ..
		     "and curses along the way.",
	},

	curses_havoc_pool = {
		en = "Havoc curses",
	},
	curses_havoc_pool_tooltip = {
		en = "Allow curses borrowed from Havoc's modifier list, such as Cranial " ..
		     "Corruption and Stimmed Foes. Turn this off if a Havoc curse misbehaves " ..
		     "in a normal mission. Only the explicit modifiers are used; Havoc's " ..
		     "hidden penalties to ammo, health and toughness are never applied.",
	},

	curses_stacking = {
		en = "Curses stack across the run",
	},
	curses_stacking_tooltip = {
		en = "Each assignment keeps the curses of every assignment before it, the way " ..
		     "boons do. Assignment 3 runs its own curse plus the modifiers of " ..
		     "assignments 1 and 2. Turn this off to run only each assignment's own " ..
		     "curse.",
	},

	enable_overlay_panel = {
		en = "Pilgrimage panel on the tactical overlay",
	},
	enable_overlay_panel_tooltip = {
		en = "While holding the tactical overlay key (TAB by default) during a " ..
		     "pilgrimage, a small translucent panel in the top right shows the " ..
		     "current assignment, its conditions (including stacked ones), whether " ..
		     "their modifiers are verified live, and what comes next.",
	},

	-- v0.23.4: the starting_difficulty widget and its option labels are gone.
	-- Difficulty has been governed by the selected War Plan since the plans
	-- shipped; the dropdown only ever fed debug fallbacks.

	-- v0.23.4: enable_blitz_mode had a widget since the auto-chain rework but
	-- never got loc entries, so the checkbox showed a raw key with no tooltip.
	enable_blitz_mode = {
		en = "Blitz mode (auto-launch next assignment)",
	},
	enable_blitz_mode_tooltip = {
		en = "When an assignment is completed, the next one launches by itself " ..
		     "after the return to the Mourningstar, banner and all. With this " ..
		     "off, the road waits: you visit the terminal and press Continue " ..
		     "when ready. The choice is locked in when a run starts, so " ..
		     "flipping it mid-run affects the next run, not the current one.",
	},

	-- v0.23.4: curses_live_event_pool also had a widget without loc entries.
	curses_live_event_pool = {
		en = "Live-event curses",
	},
	curses_live_event_pool_tooltip = {
		en = "Allow curses borrowed from past live events, such as Shambling " ..
		     "Pyres. These lean on mutators Fatshark can retire between " ..
		     "patches, so if a condition stops applying after a game update, " ..
		     "turn this off to isolate it. Existence is also verified at draw " ..
		     "time, so a retired curse is skipped rather than promised.",
	},

	fx_guard = {
		en = "Protect against missing boon effects",
	},
	-- v0.25.1 (technique credit: augentism, Chaos Wastes at Home).
	fx_full_visuals = {
		en = "Full boon visuals",
	},
	fx_full_visuals_tooltip = {
		en = "Load the Mortis Trials effect package alongside each " ..
		     "assignment so boon visual effects actually display, instead " ..
		     "of being safely skipped. Costs a little extra loading time " ..
		     "and memory. Turn off on memory-constrained machines; boons " ..
		     "keep working either way, only the flashes differ.",
	},
	fx_guard_tooltip = {
		en = "Some boon visual effects only exist in the Mortis Trials levels. " ..
		     "Spawning one in a normal mission crashes the game, so this skips " ..
		     "any effect the mission provably cannot show. The boon itself still " ..
		     "works, only that flash is missing. Turning this off restores the " ..
		     "crash, so leave it on unless you are testing.",
	},

	curses_guard = {
		en = "Verify curses apply in the mission",
	},
	curses_guard_tooltip = {
		en = "Loading a mission resets the game's scripts, which can silently drop " ..
		     "the assignment's curse. This checks the curse the mission is about to " ..
		     "run against the one the launch asked for, restores it if the game " ..
		     "lost it, and shows one line confirming which modifiers are active. " ..
		     "Only ever acts in your own solo assignments, never in public games.",
	},

	-- Groups -----------------------------------------------------------------
	group_run = {
		en = title("Run"),
	},
	group_terminal = {
		en = title("Terminal"),
	},
	group_diagnostics = {
		en = title("Diagnostics"),
	},
	group_debug = {
		en = title("Debug shortcuts"),
	},

	capture_target_preset = {
		en = "Capture-all target preset",
	},
	capture_target_preset_tooltip = {
			en = "The preset the capture-all keybind acts on. Add your intended character " ..
		     "to Character Select, load into it so the game caches its profile, then " ..
		     "press the keybind. The character, exact loadout, NPC Look, Personality Picker " ..
		     "voice, and EWC weapons are pinned when their optional mods are installed. " ..
		     "The keybind does the same " ..
		     "thing as /pil_preset_capture_all in chat.",
	},
	-- v0.22.57: dropdown labels track the current display_name for each
	-- preset. Internal ids (the key suffix) are historical and never
	-- change so saved captures stay valid across the renames.
	capture_target_none = { en = "None (keybind disabled)" },
	capture_target_seneschal_abelard = { en = "T3  |  Abelard Werserian" },
	capture_target_cassia_orsellio = { en = "T3  |  Cassia Orsellio" },
	capture_target_interrogator_heinrix = { en = "T3  |  Heinrix van Calox" },
	capture_target_idira_tlass = { en = "T3  |  Idira Tlass" },
	capture_target_princess_jae = { en = "T3  |  Jae Heydari" },
	capture_target_spinner_kibellah = { en = "T3  |  Kibellah" },
	capture_target_magos_haneumann = { en = "T3  |  Pasqal Haneumann" },
	capture_target_sister_argenta = { en = "T3  |  Sister Argenta" },
	capture_target_solomorne = { en = "T3  |  Solomorne Anthar" },
	capture_target_theodora_von_valancius = { en = "T3  |  Theodora von Valancius" },
	capture_target_arbites_marshal = { en = "T2  |  Arbites Marshal" },
	capture_target_electropriest = { en = "T2  |  Electropriest" },
	capture_target_heavy_combat_servitor = { en = "T2  |  Heavy Combat Servitor" },
	capture_target_heavy_gunner = { en = "T2  |  Heavy Gunner" },
	capture_target_kasrkin_marksman = { en = "T2  |  Kasrkin Marksman" },
	capture_target_krieg_guardsman = { en = "T2  |  Krieg Guardsman" },
	capture_target_ministorum_flamer = { en = "T2  |  Ministorum Flamer" },
	capture_target_sanctioned_psychic_enforcer = { en = "T2  |  Sanctioned Psychic Enforcer" },
	capture_target_sister_of_battle = { en = "T2  |  Sister of Battle" },
	capture_target_sister_repentia = { en = "T2  |  Sister Repentia" },
	capture_target_spyer = { en = "T2  |  Spyer" },
	capture_target_tech_priest = { en = "T2  |  Tech Priest" },
	capture_target_black_ship_fodder = { en = "T1  |  Black Ship Fodder" },
	capture_target_cartel_recruit = { en = "T1  |  Cartel Recruit" },
	capture_target_grog = { en = "T1  |  Grog" },
	capture_target_militarum_preacher = { en = "T1  |  Militarum Preacher" },
	capture_target_moebian_conscript = { en = "T1  |  Moebian 21st Conscript" },
	capture_target_moebian_deputy = { en = "T1  |  Moebian Deputy" },
	capture_target_skitarius_2137 = { en = "T1  |  Sk1tar1us 2137" },

	capture_all_keybind = {
		en = "Capture all preset data",
	},
	capture_all_keybind_tooltip = {
		en = "Snapshots the current character, loadout, look, personality, and EWC weapons " ..
		     "into the target preset. Missing optional mods are skipped safely. Future changes " ..
		     "will no longer drift into the bot; the snapshot is frozen at press time.",
	},

	-- Run --------------------------------------------------------------------
	enable_auto_chain = {
		en = "Chain missions automatically",
	},
	enable_auto_chain_tooltip = {
		en = "When a leg ends, automatically launch the next one after you return to " ..
		     "the Mourningstar. Only acts while a run is in progress.",
	},
	-- v0.23.4: run_length, run_boons_per_leg, run_seeded and run_seed loc
	-- entries removed with their widgets. Mission count comes from the War
	-- Plan, boon choices from Zero Waste, and seeding moved to /pil_seed
	-- in chat, which takes a typed number instead of a ten-digit slider.

	-- Terminal ---------------------------------------------------------------
	enable_terminal_prompt = {
		en = "Show terminal prompt",
	},
	enable_terminal_prompt_tooltip = {
		en = "Display an on-screen prompt when standing near the pilgrimage terminal " ..
		     "in the Mourningstar.",
	},
	terminal_prompt_distance = {
		en = "Prompt distance (m)",
	},
	terminal_prompt_distance_tooltip = {
		en = "How close you must be to the terminal before the prompt appears.",
	},

	enable_bot_hack_orders = {
		en = "Skitarii bots auto-hack interrogators",
	},
	enable_bot_hack_orders_tooltip = {
		en = "When any bot preset in your slots is a Skitarii (Magos Haneumann, for " ..
		     "instance) and has the servo skull blitz equipped, that bot will " ..
		     "auto-dispatch its skull at nearby stalled data interrogators. Uses the " ..
		     "same 'companion order' ping that a human Skitarii would double-tap. " ..
		     "Skips interrogators anyone else is already handling.",
	},

	-- Diagnostics ------------------------------------------------------------
	log_level = {
		en = "Log level",
	},
	log_level_tooltip = {
		en = "Console logging verbosity. Leave off unless you are diagnosing a problem.",
	},
	log_level_off = {
		en = "Off",
	},
	log_level_info = {
		en = "Info",
	},
	log_level_debug = {
		en = "Debug",
	},
	log_level_trace = {
		en = "Trace",
	},
	enable_event_log = {
		en = "Write event log file",
	},
	enable_event_log_tooltip = {
		en = "Write a detailed diagnostic file to the game's dump folder. Useful when " ..
		     "reporting a bug, otherwise leave off.",
	},
	enable_perf = {
		en = "Profile performance",
	},
	diagnostics_enabled = {
		en = "Write troubleshooting files",
	},
	group_testing = {
		en = "Testing / Cheat Mode",
	},
	cheat_mode = {
		en = "Enable cheat mode",
	},
	cheat_mode_tooltip = {
		en = "Testing toolkit for trying out Pilgrimage content. While this is " ..
		     "on, penances CANNOT be earned (nothing already earned is lost). " ..
		     "The toggles below pick the effects.",
	},
	cheat_invulnerable = {
		en = "Cheat: no health damage",
	},
	cheat_invulnerable_tooltip = {
		en = "Your operative cannot take health damage while cheat mode is on.",
	},
	cheat_one_shot = {
		en = "Cheat: one-shot kills",
	},
	cheat_one_shot_tooltip = {
		en = "Your attacks deal massively multiplied damage to enemies while " ..
		     "cheat mode is on.",
	},
	terminal_keybind = {
		en = "Open terminal keybind",
	},
	terminal_keybind_tooltip = {
		en = "Opens the Pilgrimage terminal from anywhere, no physical terminal " ..
		     "needed. Unbound by default.",
	},
	diagnostics_enabled_tooltip = {
		en = "Write extra troubleshooting files into the Pilgrimage mod folder " ..
		     "(ff_diag.txt and similar). Only useful when reporting or hunting " ..
		     "a bug, otherwise leave off.",
	},
	enable_perf_tooltip = {
		en = "Measure how long the mod's own work takes each frame. Use /pil_perf to " ..
		     "see the report. Leave off during normal play.",
	},
}
