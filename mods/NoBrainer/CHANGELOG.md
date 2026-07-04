
## [2.0.4] - 2026-07-03
### Fixed
- **Remote minigame interference**: Decode Search (Matching) and Decode Symbols now ignore remote/stale minigame instances that do not belong to the local player. Matching `stop` / `complete` cleanup is also limited to the active solver instance, preventing other players' expedition minigames from clearing NoBrainer state mid-solve.

## [2.0.3] - 2026-07-02
### Fixed
- **Decode Search stop hook warning**: Merged the `MinigameDecodeSearch.stop` cleanup into the existing hook so NoBrainer no longer registers both `hook` and `hook_safe` on the same method, preventing DMF's `Attempting to rehook active hook [stop] with different obj or hook_type` startup warning.

## [2.0.2] - 2026-07-01
### Changed
- **Decode Search submit settle**: Reduced `SEARCH_SUBMIT_SETTLE` from 0.35s to 0.20s so auto-submit triggers sooner after the cursor reaches the correct match while still keeping a short safety settle window.

### Fixed
- **Decode Search stop crash**: Guarded `MinigameDecodeSearch.stop()` against invalid minigame units so the solver skips the vanilla `lua_minigame_stop` flow event when the terminal unit has already been destroyed, preventing `UnitReference is not valid` crashes during Matching cleanup.

## [2.0.1] - 2026-07-01
### Fixed
- **Decode Search auto-submit**: Fixed a submit-state guard that treated a fresh stage with no pending synthetic submit as a stage change, causing the solver to move onto the correct match but never send the auto-press.

## [2.0.0] - 2026-06-28
### Added
- **NoBrainer folder pathing**: Mod folder and load paths use `NoBrainer`, matching the internal DMF ModID and release folder name.
- **Debug message system**: New `enable_debug_messages` checkbox setting. All minigame solvers now report internal state through throttled, deduplicated, copy-friendly debug messages (`mod._debug`, `mod._debug_throttle`, `mod._debug_change`, `mod._debug_event`). Debug output is disabled by default and globally rate-limited to 100 visible messages per 30 seconds.
- **PlayerUnitInputExtension hook**: Input routing now covers both `InputService._get` / `_get_simulate` and `PlayerUnitInputExtension.get`. This enables proper `move` / `move_controller` Vector3 routing for Decode Search, Drill, and Balance auto-solvers, instead of relying only on the four discrete directional action overrides.
- **Central input router hardening**: All auto-solvers now pass through a shared `mod._route_input()` that uses `_apply_route()` — each solver returning `nil` preserves the previous result, preventing a broken solver from propagating `nil` through the input chain. Balance activity checks are nil-safe.
- **Runtime callback isolation**: Internal update/cleanup callbacks are isolated with `pcall`, so one failing module callback cannot prevent the rest of the mod from cleaning up. Each failure is logged once through DMF.
- **Safe gameplay time access**: Runtime paths now use `mod._time()` for guarded `Managers.time:time(...)` access, avoiding transition-time callback errors when the gameplay clock is unavailable.
- **Decode Search submit settle**: After the cursor reaches the target, the solver waits 0.35s (`SEARCH_SUBMIT_SETTLE`) before submitting. This prevents false submits when the cursor is still settling from a move.
- **Decode Search move sync/pending**: Tracks pending moves (`_exp_pending_move`) with a 0.8s timeout to avoid sending duplicate move inputs before RPC sync confirms the cursor position. Moves are blocked during pending sync.
- **Decode Search after-move delay**: 0.30s delay (`SEARCH_AFTER_MOVE_DELAY`) after any cursor movement before allowing submit, preventing premature submission.
- **Decode Search match cache invalidation**: Hooks `MinigameDecodeSearch.generate_board` and `set_symbols` to clear the target match cache and pending/submit state.
- **Drill server-side fallback**: `on_update` now calls `MinigameDrill:on_action_pressed()` directly when running as server (Solo Play / Psykanium) and the search ring is full with the correct target selected. Normal client routing via input pulses remains for online play.
- **Drill stale-instance guard**: `_drill_active_mg()` prefers the minigame instance from the visible Drill view. The server fallback only runs when the server instance and view instance agree on the current correct target (`_same_solution()`), preventing submission on an invisible or stale target.
- **Practice minigame auspex view**: Practice minigames now run inside a scanner/auspex-style UI view instead of only as invisible backend minigame state, making practice closer to the real in-game presentation.

### Changed
- **Settings access hardened**: Hot-path setting reads go through `mod._N(id, fallback, min, max)` which validates numeric type, clamps to range, and provides a clean fallback. `mod._speed_scale()` now uses `_N()` internally.
- **Lifecycle cleanup upgraded**: Disable, unload, Ctrl+Shift+R reload, and gameplay exit now reset solver/runtime state consistently across all minigames. New `on_unload` handler tears down all state. New `_on_runtime_reset` event lets modules clean up on disable/unload.
- **Decode Symbols auto-solve**: `PRESS_LEAD` increased to 0.095 (from 0.065) for earlier press timing. Release timing now uses `mod._ds_press_until + RELEASE_DURATION` instead of independent timing. New `PlayerCharacterStateMinigame._update_input` hook provides a server-fallback path that calls `minigame:action()` and handles animation events directly. Expanded hold actions: accepts `interact_primary_hold` and `jump_held` alongside `action_one_hold` and `interact_hold`.
- **Decode Search / Matching auto-solve**: Target matching cache invalidated on board/symbol changes. Movement and submit timers clamped to 0 with `math.max`. Submit state cleaned on stop/complete/round exit. Cursor movement routed through both `InputService` and `PlayerUnitInputExtension`. Setting change (`enable_expedition_auto_solve`) triggers full cleanup.
- **Tree Drill auto-solve**: Movement and submit cooldowns clamped with `math.max`. `_drill_active_mg()` prefers view instance. `_is_gameplay()` state check added. Debug reporting for all solver decisions. Setting change cleanup added.
- **Frequency auto-solve**: Input-driven submission via new `_frequency()` function in input.lua using press/release pulses through `action_one_hold` / `interact_hold` / `interact_primary_hold` / `jump_held`. Movement routing through input for client-side play. Server-only axis steering in `on_update` (avoids duplicate client movement). `_freq_on_target` uses `pcall` and `_is_gameplay()` guard. Submit timing managed by `_freq_try_submit()`. Timers clamped with `math.max`.
- **Scan helper**: Scan highlight/outline setter wrapped in `pcall` guards. `has_system` check before accessing `mission_objective_zone_system`. Lifecycle expanded to hook `AuspexScanningEffects.wield` and `destroy`. Registers for `disabled`, `unload`, and `setting_changed` cleanup events. Input state reset includes `mod._current_action`.
- **Balance auto-solve**: New `_reset_balance_tracking()` resets tracked position, velocity, and EMA on start/stop/complete/disable/unload/round exit. Input hook now returns `Vector3(x, y, 0)` for `move`/`move_controller` actions. Debug reporting for active state. Setting change (`enable_balance`) triggers tracking reset.
- **Practice mode**: Practice view paths load from `NoBrainer`. Input state (`_practice_action_held`, `_practice_action_name`, `_practice_frame_axis`) is reset when closing practice. Practice opens blocked with debug message. `enable_practice` setting change closes active session. Closes on `disabled` and `unload` events. `_play_wwise` nil-safe on world manager.
- **Expedition auto-mark**: All navigation-handler method calls wrapped in `pcall`. New activity grace (5s) and registry stability grace (2s) before first mark. 3s mark cooldown between marks. Validates target still exists in registry before marking. Handles `mark_level_by_player` return values. Player lookup nil-safe with `game_session` check. State cleared on `disabled`/`unload`. Debug reporting for all decisions.

### Fixed
- **Stale solver state after transitions**: Auto-solver holds, release windows, cooldowns, previous cursor positions, scan state, and balance state are no longer left active after mission exit, disable, or unload.
- **Timer underflow edge cases**: Decode Search, Drill, and Frequency timers now clamp to `0` with `math.max(x - dt, 0)` instead of `x - dt` which could drift negative.
- **Input edge safety**: Auto-solvers no longer risk propagating an invalid route result through the rest of the input chain — each solver returning `nil` preserves the current value.
- **Drill submit in Solo Play**: Drill auto-solve now has a local-server submit fallback that calls `MinigameDrill:on_action_pressed()` directly when the ring is full and the selected target is correct. Only runs when server and view instances agree on the current target.
- **Scan stale highlights after unwield/destroy**: Highlights and auto-hold state are now cleared on `AuspexScanningEffects.wield`, `destroy`, mod disable, and mod unload — not just on `unwield`.

### Compatibility
- **Mod options unchanged**: All existing settings remain the same: highlights, auto-solvers, speed sliders, expedition auto-mark, and practice options. One new setting added: `enable_debug_messages` (default off).
- **Settings compatibility preserved**: `new_mod("NoBrainer", ...)` is unchanged internally, so users keep their existing NoBrainer settings.

## [1.6.3] - 2026-06-27
### Fixed
- **Decode Search (Matching) — robust submit pulse**: Auto-solve could move the cursor to the correct 4-symbol match but fail to submit until the player manually pressed once. Matching now uses an explicit 80ms press + 120ms release pulse and retries within 1.2s if the stage does not advance. Prevents stale-held-input issues and lock-up on high ping or with input-interception mods such as Skitarius.

## [1.6.2] - 2026-06-26
### Changed
- **Decode Symbols — deterministic scheduler replaces UI-triggered arming**: The old solver hooked `is_on_target` (called by the view during `draw_widgets`) to set `_ds_armed`, then pressed on the next input poll. This depended on frame ordering between UI update, input polling, and minigame state. The new scheduler calculates target center mathematically from `start_time`, `current_stage`, `_decode_targets`, and `sweep_duration` — the same data the server uses — and schedules the press independently of the UI cycle. Lower CPU, zero frame-order dependency, identical timing model as the engine.

- **Decode Symbols — explicit press/release pulse**: `mod._ds_input` returns `true` for 80ms then `false` for 120ms after a press, creating a clean rising edge followed by a release that re-arms the game's `_action_held` state machine. Prevents stale-held-input issues.

- **Decode Symbols — snappier visual timing**: `PRESS_LEAD` increased to `0.065` and `PRESS_GRACE` reduced to `0.060`, shifting the synthetic press slightly earlier while keeping the timing window inside the safe target center zone.

- **Decode Symbols — stage-lock against double-submit**: Tracks `_ds_submitted_stage` and refuses to press again on the same stage until the server RPC sets a new `current_stage`. Falls back to a 1.2s timeout if no RPC arrives.

### Fixed
- **Decode Symbols — fail-closed on missing data**: Returns original input (no synthetic press) if `start_time`, `stage`, `target`, `items_per_stage`, or `sweep_duration` is missing or invalid. The old `_ds_on_target` would return `false` and the input hook would pass through — effectively the same behaviour, but the new guard is explicit and covers all edge cases before attempting a press.

### Removed
- **NoBrainer.lua — orphaned `_ds_cooldown` field**: No longer read or written by the new decode-symbols scheduler.

## [1.6.1] - 2026-06-25
### Changed
- **Speed slider calibration — Decode Search, Drill, Balance**: `5` now maps to the old "Human speed" feel, `10` is the fastest practical speed, `1` is slower than old Human. Migration updated so existing `"Human"` → `5`, `"Inhuman"` → `10`.
- **Decode Search — diagonal movement**: Auto-solver now moves diagonally toward the target instead of one axis at a time, solving puzzles in fewer steps.
- **Balance — new speed profile system**: Instead of a single scale, each speed level has its own blend of EMA lag, deadzone, skip chance, and PD gains. `5` feels like old Human, `10` holds the dot near-center with live data and velocity-aware braking, `1` is noticeably slower than Human.
- **Balance — PD velocity bug fixed**: `_bal_correction()` now receives actual axis velocity instead of `0`. The D term now correctly dampens outward movement and brakes inward drift.
- **Decode Search & Drill — initial cooldown removed**: Auto-solver starts moving immediately when the minigame opens. (Drill still applies an initial cooldown matching the speed setting to prevent instant snap-to-target at non-max speeds.)
- **Decode Search, Drill & Balance — default speeds**: Decode Search `3` → `5`, Drill `3` → `5`, Balance `2` → `5` to match the new `5 = old Human` baseline.

### Fixed
- **Decode Search & Drill — manual WASD blocked during auto-solver cooldown**: Input hooks returned `0` for `move_left/right/forward/backward` during cooldown, making manual cursor control appear dead while auto-solve was paused. Now returns the original input value so manual WASD passes through.
- **Decode Search & Drill — `on_axis_set` zeroing input during cooldown**: Both hooks called `func(self, t, 0, 0)` under cooldown, suppressing any manual move that reached the engine. Removed — the engine now always receives the axis as-is; cooldown is enforced only by the InputService hook skipping synthetic overrides.
- **Decode Search — startup delay re-added by 1.6.0**: The 1.6 speed migration code set an initial `_exp_move_cooldown` in `MinigameDecodeSearch.start`, causing a multi-second delay before the first auto-move. Removed — cooldown is only set after an actual cursor position change.

### Added
- **Balance `_bal_correction()`** — New sign-aware PD function that outputs signed correction values. Positive values push left/forward, negative push right/backward, enabling the input hook to apply corrections in the correct direction.

### Removed
- **`mod._bal_axis()`** — Replaced by `_bal_correction()` with correct velocity handling and signed output.
- **Balance `lazy` variable** — Unused dead code in old `_bal_axis()`.
- **Balance old `mod._speed_scale("balance_solve_speed")` calls** — Replaced by dedicated `_balance_profile()` with per-speed parameters.

## [1.6.0] - 2026-06-24
### Added
- **Expedition POI Auto-Mark** — Automatically marks the nearest opportunity (objective) on the expedition map without pulling out the auspex. Polls every second; when the marked POI is completed, marks the next nearest. Manual marks are respected (auto-mark pauses), manual unmarks are respected (skips that POI). Only targets opportunities — exits and extractions are never touched. Optional: auto-mark vault when all POIs are done. Default: off, notifications on.
- **Speed slider (1–10)** — All four auto-solve speed settings (Decode Search, Tree Drill, Frequency, Balance) now use a numeric slider from 1 (slowest) to 10 (instant) instead of the old "Human speed" / "Inhuman speed" dropdown. 10 levels instead of 2. Old "Human speed" → 3, old "Inhuman speed" → 10.
- **Balance speed scale** — `mod._speed_scale(id)` converts slider value (1–10) to a 0–1 scale used by all solvers for smooth interpolation of timing, strength, and noise parameters.

### Changed
- **Balance solver — rewritten to scale-based**: Old code checked `speed == "human"` / `"inhuman"` with fixed constants. New code uses the slider's 0–1 scale to smoothly interpolate PD gain (0.3–1.0), EMA lag (0.02–0.50), lazy deadzone (0.15–0.40), skip chance (0–20%). At speed 1 it's sluggish with visible lag; at speed 10 it holds center perfectly.
- **Frequency solver — rewritten to direct API calls**: Old code hooked `InputService._get` for `action == "move"`, but the game never calls `_get("move")` — movement is composed from four cached directional inputs. This meant frequency auto-solve was **non-functional**. Now calls `mg:on_axis_set()` for steering and `mg:test_frequency()` (server) / `mg:on_action_pressed()` (client) for submission from `on_update`.
- **Drill solver — reverted to InputService overrides**: Direct API calls (`mg:on_axis_set()`) don't work for Drill because `MinigameDrill.on_axis_set` bails on client. Reverted to InputService-override approach: `_drill` in the input hook overrides `move_right`/`move_left`/`move_forward`/`move_backward` through the character state machine to the server's `on_axis_set`. Cursor movement works both offline and online.
- **Drill — cooldown moved to InputService throttling**: Per-move cooldown was in `on_axis_set` hook (no effect online). Now enforced in `_drill` input hook: during cooldown, directional overrides return 0. Cursor position tracking in `on_update` sets cooldown when cursor changes via RPC-synced `cursor_position()`.
- **Decode Search — submission cleanup**: `on_update_exp` called `mg:on_action_pressed(t)` (no-op on client) and set `_exp_submitted_stage`, blocking the working InputService path. Removed submission logic from `on_update_exp` — `_expedition` now handles all pressing.

### Fixed
- **Drill & Decode Search — cursor teleporting**: When cooldown blocked `on_axis_set`, `_last_axis_set`/`_last_move` weren't updated. First unblocked call had `dt ≈ cooldown_duration`, causing instant jump to target. Fixed by calling `func(self, t, 0, 0)` during cooldown to update timestamps without moving.
- **Darktide patch compatibility — `player_slot_by_level_marked` removed**: Navigation handler API renamed from singular `player_slot_by_level_marked` to plural `player_slots_by_level_marked`. Returns `(table, count)` instead of `slot_or_nil`. All expedition map code updated.
- **Darktide patch compatibility — stale Vector3**: `POSITION_LOOKUP[unit]` returns stale Vector3 references. Expedition map now uses `Unit.world_position(unit, 1)` for fresh positions.

### Removed
- **Frequency `_freq_press_until`, `_freq_release_until`, `_freq_speed`**: No longer needed since the solver uses direct API calls.
- **Decode Symbols `_ds_count` and `_ds_cool`**: Old integer-counter state machine (replaced by `_ds_armed` boolean in 1.4.6, vestigial code remained).
- **`_bal.speed` string field**: Replaced by `bal.scale` numeric field.

## [1.5.0] - 2026-06-19
### Added
- **Practice Mode** — Standalone overlay for manual minigame training without auto-solvers. Press F10 to open in Mourningstar or Psykanium (not available during missions). Supports all five minigames: Decode Symbols, Decode Search (Matching), Tree Drill, Frequency Matching, and Train (Balance). Auto-solvers are disabled during practice; highlights and visual aids are suppressed so you train with the same information as the real game. Each practice session tracks your completion time and reports it in chat (e.g. "Finished Tree Drill in 12.45 seconds!").

### Details
- **Decode Symbols practice** — Sweeping cursor, press to lock in the correct column. Same timing window as the real game. Plays success/fail sounds and reports completion time.
- **Decode Search (Matching) practice** — Grid-based matching puzzle with 250ms cursor movement delay matching the real game. Move to a region and press to check the pattern.
- **Tree Drill practice** — Cursor snaps between target circles using angular targeting (±60° cone). Move to aim, press to start the scan timer, press again to confirm when the ring fills. Wrong answers play fail sound and stay on the same stage.
- **Frequency Matching practice** — Waveform matching with dt-based input. Move your waveform to overlap the target waveform, then press to submit. Keyboard input uses 0.4× sensitivity for precise control. Wrong answers advance back one stage with a new random target.
- **Train (Balance) practice** — Continuous real-time balancing challenge. Outward push force stronger near center, random disruptions every 1.6s, hard wall at radius 1.02. Progression takes ~20 seconds of cumulative time inside the zone. Harder than the real game (push ratio 2.2×, disruption power 1.0, interval 1.6s).
- **Movement blocking** — Character does not move while using WASD during practice. Input is routed to the minigame only.
- **Settings** — Enable/disable practice mode (default: off), choose minigame type, rebind toggle key (default: F10).
- **Sound effects** — All practice minigames play real game sounds via direct Wwise events: selection, progress, fail, frequency adjust, balance stall alerts.
- **Location restriction** — Practice mode only activates in the Mourningstar hub and Psykanium. Attempting to open it in a mission shows a chat message.

## [1.4.7] - 2026-06-15
### Fixed
- **Decode Symbols — Edge-column misses at moderate ping**: `prec = 0.3` left only 100ms margin between detection-window edge and game-window edge at edge columns (1, 7). Users at ~100ms one-way latency hitting the window boundary experienced "just barely hits it, goes back up" glitches. Reverted to `prec = 0.35` — 0.1s window centered with 117ms margin at edges, reliable up to ~234ms RTT at any column position.

## [1.4.6] - 2026-06-15
### Fixed
- **Decode Search (Matching) — Duplicate submit under RPC latency**: After auto-submitting a correct match, the server's RPC takes 50–150ms to advance the stage. During this window `_current_stage` is unchanged on the client, so `_expedition` could attempt a duplicate submit on the same stage. Now tracks `_exp_submitted_stage` to prevent re-submission until the RPC confirms the stage has advanced.
- **Decode Symbols — Missed presses under latency**: Pre-press cursor verification in the input hook caused false negatives — the 16ms gap between the view's `is_on_target` call and the input poll was enough for the cursor to leave the detection window at 30fps or high latency. Removed the pre-press check entirely; the centered detection window and 150ms cooldown are sufficient to prevent double-presses.

### Changed
- **Decode Symbols — Simplified state machine**: Replaced `_ds_count` (integer counter) with `_ds_armed` (boolean). Removed `_ds_count_same()` helper, removed `_ds_mg` reference (no longer needed without pre-press), dropped unused `off` parameter from `_ds_on_target`. Input hook is now 11 lines; `is_on_target` hook is 6 lines.
- **Decode Symbols — Detection window**: `prec` constant changed from 0.35 to 0.3 for a standardised 0.13s window centered in the game's 0.333s window. Same ping reliability, no magic numbers.

Version 1.4.5
## [1.4.5] - 2026-06-14
### Fixed
- **Decode Symbols — Online timing accuracy**: Detection window was the full 0.333s game window, making the press point random within the column. On high ping (>100ms RTT), presses detected near the window edge arrived at the server after the cursor had already left the game's validation window, causing misses. Now uses a centered `prec = 0.35` filter (0.1s window centered in the game's 0.333s window), ensuring detection always occurs close to center with maximum ping margin in both directions. Reliable up to ~280ms RTT.
- **Decode Symbols — Double-presses at high ping**: With the wide window, 150ms cooldown expired while the cursor was still in view, triggering re-detection of already-solved rows before the server RPC updated `_current_stage`. Fixed with `_ds_pending_stage` / `_ds_pressed_stage` stage tracking: the input hook refuses to press for a stage it has already pressed, and the guard clears automatically when `set_current_stage` RPC arrives.
- **Decode Symbols — Pre-press cursor verification**: The `_ds_mg` reference (set in `start`) is passed to the input hook so it can call `_ds_on_target` immediately before pressing — if the cursor has already left the window, no press occurs and the cursor continues sweeping.

### Changed
- **Decode Symbols — Removed 40ms sustained press**: Press is now single-frame (previously was 40ms `_ds_press_deadline`). Removes 40ms of additional latency that compounded with network delay. Dead code cleaned: `DS_PRESS_HOLD`, `DS_PRESS_GAP`, `_ds_press_window()`, `_ds_cool()`, and deadline tracking removed from `on_update`.
- **Decode Symbols — Removed FixedFrame clock**: Reverted `_calculate_cursor_time` to use the view's `t` parameter (`gameplay_time`) instead of `FixedFrame.get_latest_fixed_time()`. The FixedFrame approach was 16-30ms stale on clients, causing late detection that added to ping latency. Removed `require("scripts/utilities/fixed_frame")` dependency.
- **Decode Symbols — Tooltip**: Updated to note ~280ms ping reliability so users on very high-ping servers can disable auto-solve.

Version 1.4.3
### Fixed
- **Decode Search (Matching) — Human speed**: Cooldown was set on every `on_axis_set` call, including zero-input and on-target frames, causing up to 1.875s of wasted dead time at the start of each stage. On small 2×2 boards this made auto-move appear non-functional. Fixed by only setting cooldown when `on_axis_set` actually changes the cursor position.
- **Defense-in-depth**: `mod._exp_move_cooldown` is now initialized in `NoBrainer.lua` alongside all other state, and all reads are nil-guarded.
- **Drill — Human speed**: Same cooldown bug as Decode Search — `on_axis_set` set cooldown on every call, including zero-input frames. Fixed by only setting `_drill_move_cooldown` when cursor position actually changes.
- **Defense-in-depth**: `mod._drill_move_cooldown` initialized in `NoBrainer.lua` alongside other state.
### Changed
- **Balance (Train) — Inhuman mode**: Increased damping coefficient (Kd 0.89→0.95) and added light inward-velocity damping to prevent center overshoot. Tighter control, less wobble.
### Performance
- Balance human-EMA gated behind `st.timer > 0` so it stops after the minigame ends.
- Decode Symbols input: `time("gameplay")` moved after `_ds_count`/`_ds_cooldown` guards.
- `_decode_layout` returns cached table instead of allocating per frame.
- Frequency highlight: `math.rad()` constants moved to module level.
- Input hook skips all 7 solvers via `_any_minigame_active()` gate when no minigame is active.
- Input hook: global references (`Managers`, `math.*`) localized to module scope.

Version 1.4.1
## [1.4.1] - 2026-06-14
### Fixed
- **Auspex Scan — Stale highlights**: When the auspex minigame completed, the mod's 1-second refresh loop kept re-applying `set_scanning_outline(true)` and `set_scanning_highlight(true)` on scannable objects even after no scanning zone was active — leaving highlighted objects visible to the mod user that no one else could see. Fixed by guarding the highlight refresh with `sys:any_active_scanning_zone()`. Highlights are now cleared immediately when the scanning zone is no longer active.

Version 1.4.0
## [1.4.0] - 2026-06-13
### Added
- **Frequency Matching** — Directional arrows highlight which way to push the waveform toward the correct target.
- **Frequency Matching — Auto-Solve**: Automatically steers the waveform to the target and submits. Two speed modes: Inhuman (instant) and Human (delayed reactions with natural wobble).
### Fixed
- **Decode Search (Expedition) (Human speed)** — `_exp_move` no longer computes movement vector during cooldown. Early-return on `_exp_move_cooldown > 0` saves ~10 table-lookups per frame while movement is blocked by `on_axis_set`.
- **Balance (Train)** — Online play caused velocity spikes from RPC bursts, making the Inhuman solver oscillate between edges. Raw velocity is now clamped at ±10 (was ±50) and EMA-smoothed (alpha 0.30) so a single burst cannot saturate the D-term.

# Changelog

## [1.3.0] - 2026-06-09

### Added
- **Auspex Scan — Auto-Scan**: Holds the scan action for the full 1s duration automatically.
- **Auspex Scan — Scannable refresh**: Scannable objects list refreshed every 1s so new targets get highlights.

### Fixed
- **Auspex Scan — Unwield cleanup**: Highlights removed when scanner is put away.
- **Auspex Scan — Auto-Scan stalling**: Replaced `_completed_scanning` override with a time-based hold. Keeps `action_one_hold=true` for 1.15s so the game's 1s confirm timer completes naturally.
- **Auspex Scan — Shared table reference**: `scannable_units()` returns a static table cleared every frame. Mod now copies data into its own table.
- **Auspex Scan — is_active guard**: Input hooks check `is_active()` before triggering.
- **Auspex Scan — Weapon-action guard**: Input simulation checks `current_action == "action_scan"`.
- **Auspex Scan — Alive guard**: `_set_hl` checks `Unit.alive(unit)` before accessing extensions.
- **Auspex Scan — Debounce cooldown**: 300ms debounce prevents re-trigger from LOS flicker.
- **Auspex Scan — State cleanup**: `last_target`, `_scan_auto_pending`, and cooldown cleared on weapon change.
- **Decode Symbols — Online timing**: The `is_on_target` view hook receives `gameplay_time` but the game's `_decode_start_time` uses the `FixedFrame` clock synced between client and server. These clocks diverge online (30-100ms), so the cursor position computed by the mod was off by that amount — causing presses too early or too late. Now uses `FixedFrame.get_latest_fixed_time()` to compute the exact same cursor position the server validates against. Also added a pre-press verification in the input hook that double-checks the cursor is still in the target window before pressing, eliminating edge-column misses and "click randomly" behaviour.
- **Decode Search (Expedition)** — Cursor now moves one axis at a time instead of diagonal. Diagonal movement skipped over columns too quickly.

## [1.2.0] - 2026-06-10

### Added
- **Auto-Balance Speed** setting — "Inhuman speed" (instant) or "Human speed" (delayed reaction with noise). Default: Human speed.

### Fixed
- **Decode Symbols** detection window was ~0.2s instead of the game's 0.333s — `prec = 0.2` artificially narrowed both sides of the formula. Now matches `MinigameDecodeSymbols.is_on_target` exactly.
- **Decode Symbols** cooldown row 2 failure — final press cooldown was only 60ms, too short for the server RPC to update `_current_stage` before the cursor swept past the next row. Now 150ms.
- **Decode Symbols** network race — `_ds_stage_done` guard caused permanent lock when stage bounced back (e.g., 3→4→3). Fixed with auto-clear and unconditional `set_current_stage` clear.
- **Decode Symbols** interact-bleed — player's `interact` from opening the minigame leaked into auto-solve. Input hook now clears and returns original value so `_action_held` initialises correctly.
- **Decode Symbols** highlight crash — `mg:current_stage()` could return `nil` in race between `start` and `setup_game`. Added nil-guard.
- **Balance** failed on multi-click runs due to fixed strain modifier interaction.

### Changed
- **Decode Symbols** press timing: hold 40ms, gap 60ms between multi-presses, cooldown 150ms.
- Removed `_ds_networked()` — timing constants now work identically for network and singleplayer.

### Removed
- **Expedition (Decode Search) — Auto-Solve Speed** setting (hardcoded to Human speed internally).

## [1.1.0] - 2026-06-08

### Added
- **Auto-Solve Speed** setting for Expedition (Decode Search) puzzle — choose between "Inhuman speed" (instant, as before) and "Human speed" (1.875 seconds per cursor move). Default: Human speed.
- **Auto-Solve Speed** setting for Drill (Tree) puzzle — choose between "Inhuman speed" (instant, as before) and "Human speed" (2 seconds per cursor move). Default: Human speed.

### Changed
- Drill puzzle movement is now throttled via `MinigameDrill.on_axis_set` hook instead of InputService, ensuring the game's internal move system works correctly with the speed limiter.
- Expedition puzzle movement is now throttled via `MinigameDecodeSearch.on_axis_set` hook for the same reason.

### Removed
- **Drill Step Delay** setting from mod options (hardcoded to 150ms internally).
