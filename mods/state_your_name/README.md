# State Your Name

State Your Name composes public player identity, progression, Havoc, and your
local service history inside the name widgets Darktide already renders. It also
opens Darktide's native character screen in a strictly read-only mode so you
can inspect the public loadout of players you meet. It does not add a competing
HUD element or mutate profile/network payloads.

## Compatibility

State Your Name replaces the display roles of True Level, Who Are You,
CurrentHavoc, Teammate Tracker, and — with Show Operative Kit enabled — What
Are You / What Are You (Continued). Remove those from `mod_load_order.txt`
when running this mod — they rewrite the same native name widgets and the two
mods will fight over the text every frame.

If any of those mods are still enabled, State Your Name displays a one-time
startup warning naming the conflict. Disable the listed mod and restart
Darktide before reporting missing or overwritten identity text.

Your Teammate Tracker history is not lost: this mod reads and keeps appending
BoffeeH's exact `teammate_tracker_history.txt` format (credit to Teammate
Tracker for the format), so years of records carry over both ways.

This mod shares no code with True Level or any other identity mod; the
true-level math and every hook were built clean-room against the game's own
scripts.

Inspect From Party Finder is compatible. When it is enabled, State Your Name
detects it and leaves Party Finder inspection to that mod instead of adding a
second button. Social-menu and mission-lobby inspection remain available.

Color Selection / Player Slot Color Picker is compatible in either load order.
Its source-level markup is normalized before State Your Name composes the
identity, then its live selected slot/class color is reapplied to the character
name and cached archetype symbol. Picker changes invalidate every cached identity surface automatically,
including in the Mourningstar, without a manual sync command. Its selected
colors also remain available to the Player Slot accent theme.

NumericUI and Better Nameplates are compatible. State Your Name composes after
NumericUI's concrete team panels and registers each cached nameplate template
only once, including across repeated HUD and level package loads.

## Release feature set

- Unified operative inspection using Darktide's native read-only character
  screen. Inspect Party Finder applicants and group previews, choose **Inspect
  Loadout** from any available Social player popup, or click an operative card
  during the pre-mission countdown. Weapons, curios, perks, blessings,
  cosmetics, the complete talent tree, and specialization skills are included.
- Remote profiles that resolve late are queued for up to eight seconds. Offline
  friends and records without a public character profile are clearly marked
  unavailable instead of opening an empty or stale screen.
- Mouse, keyboard, and controller paths are supported. Party Finder applicants
  use its native inspect action on controller; the lobby exposes Inspect while
  navigating a player's weapon/talent summary.
- The end-of-mission XP bar works past level 30: it fills toward your next
  total level (143 -> 144), rolls over with the native level-up sting, and
  counts per-level XP ("8,450 / 11,100") instead of sitting full at the cap.
- Social menu roster lines carry the composed identity: total level, Havoc,
  and your shared record next to friends and recent players.
- Character select shows character + total level only (your own account name
  and account-wide Havoc were redundant on every row) and never wraps onto
  the archetype line.
- Menus, lobby, and end screen re-compose when async data resolves. Temporary
  backend account placeholders such as `[unknown]` are suppressed, and lobby
  or end-screen rows recheck twice per second so the real account name appears
  as soon as presence finishes resolving. `~` Havoc estimates update in place
  as well.
- The mission lobby uses four bounded rows per 350px operative card: identity,
  account/progression, title, and archetype. Each row width-fits independently,
  and the weapon/talent summary moves down as a group to preserve spacing.
- The four-column end-of-mission lineup uses both native identity rows and
  width-fits identity, progression, title, and archetype inside each 440px
  player panel, preventing long text from overlapping adjacent operatives.
- A bindable key cycles the Name Format live; the existing hold-to-expand key
  is unchanged.
- **Show Your Own Account Name** can hide only your local account identity and
  platform icon. Your character name, total level, Havoc, and other enabled
  details remain visible, and teammate account names are unaffected.
- **Identity Font Size** overrides the native font size on gameplay and menu
  identity widgets; `0` preserves each surface's original size. Chat and the
  combat feed retain their shared native line size.
- Character names, account names, total levels, Havoc values, and service
  records each have an independent opt-in RGB override. Disabled overrides keep
  the existing player-slot, tier, heat, dimming, and win-rate color behavior.

## Rev 2 feature set

- Seven complete presentation grammars. Aquila is the new default; Cogitator
  and Litany join the retained Registry, Dossier, Rail, and Classic styles.
- Character, platform/account, or combined identity; platform icons,
  discriminator hiding, deduplication, and Unicode-safe truncation.
- Total character level from cumulative XP and Darktide's live XP curve. The
  startup fetch handles profiles converted before DMF loads.
- Level number format: the running total (535) or the over-cap 30(+505) form.
- Optional Prestige tracker (Pr. N = complete Level 1-to-30 XP amounts earned),
  its own tracker so it never displaces the level number.
- Optional per-tracker in-game insignia (level, Havoc, or any class icon) for
  the Level, Prestige, and Havoc trackers. Only game-rendered glyphs are
  offered; unrenderable fonts fall back to text labels, never a box.
- Per-platform icon color overrides (Steam / Xbox / PlayStation) alongside the
  independent character, account, level, Havoc, and service-record colors.
- Option to show all trackers on the character-selection cards, not just level.
- Per-surface display settings: each location (team HUD, Mourningstar and
  mission nameplates, lobby, Party Finder, chat, combat feed, menus, social,
  spectator) can override Name Format, platform icon, level, Havoc, service
  record, and kit. Each defaults to inheriting the global setting.
- Overhead nameplates are two independent locations (Mourningstar / Missions).
- Color Selection Reach: extend a picked color from the character name to the
  account name or the whole line.
- Independent milestone tier colors and optional 1000+ star flair.
- Optional number-only levels remove `LV`, `LVL`, `L`, and the level insignia
  across every presentation while preserving the level number and tier color.
- Havoc shown as launchable rank, weekly high, and optional all-time high.
  Your own launchable rank reads the orders backend (the same source the
  Havoc table uses to offer its key); other accounts use the held order from
  the per-account Havoc summary route. Both cache with a three-minute TTL,
  one in-flight request per account, and error backoff. `~` always
  identifies the temporary presence-derived estimate.
- Optional class and kit display (off by default): shows which class ability
  each operative is running, read from their live talent selection. On the
  mission lobby, post-mission lineup, and character select it joins vanilla's
  existing archetype row ("Veteran - Executioner's Stance") rather than adding
  a row; everywhere else it appends to the identity line. Kit Detail adds the
  Blitz and Aura, and holding Expand Identity always reveals the full kit.
  Class Label defaults to the game's own archetype insignia where no archetype
  row already names the class. Kit Locations can restrict it to in-mission or
  to menu surfaces.
- Local win/loss/quit service history. Existing
  `%APPDATA%/Fatshark/Darktide/teammate_tracker_history/teammate_tracker_history.txt`
  data is imported, and new missions keep using that compatible text format.
- Record styles: `67%·12G`, `8W·4L`, or `×12`; configurable minimum games,
  win-rate tint, expanded W/L/Q view, and lobby-only first-drop markers.
- Imperial Gold, Servo Green, Arterial Red, Bone White, player-slot, and custom
  RGB accents, plus independent character/account/level/Havoc/record colors.
  Account dimming, progression placement, and separator override are
  independently configurable.
- Level and Havoc values carry Darktide's own insignia glyphs (the U+E006
  level and U+E04F Havoc icons vanilla nameplates use) in the Aquila and
  Litany presentations; disable with "Use In-Game Insignia" to get text
  labels. Unknown platforms fall back to vanilla's cross-network glyph.
- Fancy glyphs are checked against the active UI renderer and fall back through
  ASCII-safe chains; unverifiable insignia fall back to text labels.
- Progression and service records appear on the team HUD, lobby, Party Finder,
  and end screen by default. Chat and combat feed stay compact; nameplates do
  not expose service history.
- Native title, archetype icon, player-slot color, privacy, block, and
  visibility behavior is retained where the underlying widget provides it.

## Commands

- `/syn_preview` prints the active presentation with representative values.
- `/syn_record <name>` prints W/L/Q, games, and first/last shared mission dates
  for a named player.
- `/syn_levels` reports XP-curve readiness and the captured total level for
  each current player.
- `/syn_diag` writes true-level, Havoc-request, and glyph diagnostics to
  `mods/state_your_name/syn_diag.txt` and also prints them when chat is visible.

## Operative inspection

- **Party Finder:** click the inspect icon on an applicant, click a member card
  in a group preview, or click a member of your own listed party. Controller
  users can select an applicant and use Party Finder's normal inspect action.
- **Social Menu:** open a player's action popup and choose **Inspect Loadout**.
  The action is disabled when Darktide has no active character profile for that
  player, which is common for offline friends.
- **Mission Lobby:** click any occupied operative card. On controller, enable
  loadout tooltip navigation, select one of that player's weapons or talents,
  and use the standard Inspect action.

Every inspection opens with `is_readonly = true`. Darktide's own ownership and
read-only checks remain intact, so the screen cannot equip weapons, spend talent
points, change cosmetics, or save presets for the inspected player.

## Installation

Place `state_your_name` directly in Darktide's `mods` directory and add it to
`mods/mod_load_order.txt` after `dmf`. Restart Darktide after updating hooks.
