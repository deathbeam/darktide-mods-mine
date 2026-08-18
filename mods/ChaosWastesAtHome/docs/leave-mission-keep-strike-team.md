# Leaving a mission without leaving the strike team

How ChaosWastesAtHome makes the escape menu's **Leave Mission** button drop the
mission but keep you in your party, and what to watch for when porting it.

Verified against the decompiled 1.12.3-era source in `Darktide-Source-Code/`.

---

## The problem

The escape menu has two separate buttons:

| Button | Shown when |
|---|---|
| Leave Mission | you are in a mission |
| Leave Party | `_members_in_party() > 0` |

Pressing **Leave Mission** does both — it drops the mission *and* disbands you
out of the strike team — which makes the separate Leave Party button pointless
and is almost never what the player wanted.

## Where it actually happens

Not in the button. The button just names a reason:

```lua
-- scripts/ui/views/system_view/system_view_content_list.lua:437 (and :466)
Managers.multiplayer_session:leave("leave_mission")
```

`MultiplayerSessionManager.leave` only records it
(`multiplayer_session_manager.lua:98`); the work happens later, and the party
decision is made from the reason string in `MechanismLeftSession.init`:

```lua
-- scripts/managers/mechanism/mechanisms/mechanism_left_session.lua:23
if reason == "leave_mission" then
    self:_leave_party()               -- drops the strike team
elseif reason == "skip_end_of_round" then
    -- Nothing
...
elseif reason == "leave_mission_stay_in_party" then
    -- Nothing                        -- stays in it
elseif reason == "quit_game" then
    Application.quit()
else
    self._next_state = StateExitToMainMenu
end
```

`_leave_party` is one line (`:41`):

```lua
self._leave_party_promise = Managers.party_immaterium:leave_party()
```

**So the entire difference between the two behaviours is one string.** The game
already ships the reason you want; nothing needs to be reimplemented.

`leave_mission_stay_in_party` is not invented for this — the game uses it itself
in `mechanism_adventure.lua:337` and `:488`, and
`MultiplayerSessionManager._rpc_ignore_slot_reservation` (`:79`) treats it
identically to `leave_mission`, so slot-reservation behaviour is unchanged.

## The fix

Hook `MultiplayerSessionManager.leave` and rewrite the reason:

```lua
local MultiplayerSessionManager = require("scripts/managers/multiplayer/multiplayer_session_manager")

mod:hook(MultiplayerSessionManager, "leave", function (func, self, reason)
    if reason == "leave_mission" and _should_keep_party() then
        reason = "leave_mission_stay_in_party"
    end

    return func(self, reason)
end)
```

### Why not patch the menu entry instead

You could replace the entry's `trigger_function` in
`system_view_content_list.lua`. Don't: it would mean reimplementing the whole
confirmation popup (title, description, both option buttons and their callbacks),
and it breaks on any patch that touches that popup. Rewriting the reason is a
one-line behavioural change at the point the decision is actually made.

---

## Four traps

### 1. It must be `mod:hook`, not `mod:hook_safe`

`hook_safe` runs *after* the original and cannot change the arguments. Rewriting
the reason is the entire fix, so it needs the wrapping form — whose callback
receives `func` as its first parameter.

### 2. One hook per mod + object + method

A second `mod:hook*` on the same method from the same mod is logged as
`Attempting to rehook active hook` at WARNING level and **silently dropped** —
the later handler never runs, with no error.

If your mod already hooks `MultiplayerSessionManager.leave` for anything else,
this has to go *inside* that hook rather than beside it. ChaosWastesAtHome
already hooked it to catch `skip_end_of_round`, so the two live together:

```lua
mod:hook(MultiplayerSessionManager, "leave", function (func, self, reason)
    if escape.should_keep_party(reason) then
        reason = escape.KEEP_PARTY_REASON
    end

    local result = func(self, reason)

    -- After the original, preserving the ordering the previous hook_safe had.
    if reason == "skip_end_of_round" then
        _queue_next_mission("continue pressed")
    end

    return result
end)
```

### 3. `MatchmakingConstants` is a module, never a global

This one cost a test cycle. Reading it off `_G` returns nil, so any host-type
check written this way silently answers "no" and the whole feature quietly does
nothing:

```lua
-- WRONG - always nil
local constants = rawget(_G, "MatchmakingConstants")

-- RIGHT
local MatchmakingConstants = require("scripts/settings/network/matchmaking_constants")
local HOST_TYPES = MatchmakingConstants.HOST_TYPES
```

`HOST_TYPES` is a `table.enum`, so its values *are* their names. Accepting the
literal `"singleplay"` as a fallback means a future rename degrades instead of
disabling the feature:

```lua
if host_type ~= HOST_TYPES.singleplay and host_type ~= "singleplay" then
    return false
end
```

### 4. Scope it

Rewriting the reason unconditionally changes behaviour for every mission the
player ever leaves, including normal matchmade ones. Gate it on the sessions
your mod owns. ChaosWastesAtHome requires both a `singleplay` host type and its
own "a run is in progress" flag:

```lua
local function _in_our_mission()
    local session = Managers.multiplayer_session
    if not session then return false end

    local ok, host_type = pcall(session.host_type, session)
    if not ok or not host_type then return false end

    if host_type ~= HOST_TYPES.singleplay and host_type ~= "singleplay" then
        return false
    end

    return run.is_launched()   -- your own "this is my session" test
end
```

For TrueSoloQoL the second half is whatever already identifies a true-solo
session; the host-type test alone may be enough.

---

## Related: making the button visible at all

Separate problem, but it bites the same mods. A mission launched with
`Managers.multiplayer_session:boot_singleplayer_session()` has **no way out** of
the escape menu, because both exits are hidden:

- **Leave Mission** — `validation_is_in_standard_mission` returns true only for
  `HOST_TYPES.mission_server`. A solo session is `singleplay`.
- **Exit to Main Menu** — only shown for `prologue`, `prologue_hub`, `hub`,
  `training_grounds`, `shooting_range`. A mission is `coop_complete_objective`.

Fix by wrapping the entry's `validation_function` (wrapping, not replacing, so
non-solo sessions keep vanilla behaviour):

```lua
mod:hook_require("scripts/ui/views/system_view/system_view_content_list", function (content_list)
    -- NOT a flat array. It is keyed by game state:
    --   { StateMainMenu = main_menu_list, default = default_list }
    -- The in-mission entries are in `default`.
    for _, list_name in ipairs({ "default" }) do
        for _, entry in ipairs(content_list[list_name] or {}) do
            if entry.text == "loc_leave_mission_display_name" and entry.validation_function then
                local original = entry.validation_function

                entry.validation_function = function (...)
                    if _in_our_mission() then return true end
                    return original(...)
                end

                return   -- FIRST match only
            end
        end
    end
end)
```

Two things there:

- **The module returns a table of per-state lists, not an array.** Iterating the
  top level with `ipairs` finds nothing.
- **Patch only the first match.** There are two entries with
  `loc_leave_mission_display_name` — the standard-mission one at `:422` and the
  havoc one at `:453`. Patching both puts two identical "Leave Mission" buttons
  in the menu.

If SoloPlay is installed it already patches this, which can mask a broken
implementation of your own — the button appears either way, so test the party
behaviour rather than assuming a visible button means your code ran.

---

## Verifying

1. Form a strike team, start a solo mission, leave it from the escape menu.
2. You should be back in the Mourningstar **still in the party**.
3. The separate Leave Party button should be the only thing that drops it.
4. Log a line when the rewrite fires, at info level so it lands in players' logs
   without them enabling anything. No line means your scoping test is answering
   false — which is exactly how trap 3 presents.
