# Darktide Mod Development Instructions

## Project Overview
This repository contains Warhammer 40,000: Darktide mods written in Lua. The mods hook into the game's UI and gameplay systems to enhance the player experience.

## Key Principles

### 1. Minimal Changes Philosophy
- Make **surgical, precise edits** - change only what's necessary
- Never delete or modify working code unless absolutely required
- Preserve existing functionality while adding new features
- Keep code changes as small as possible

### 2. Development Workflow
The mods are developed in `/home/deathbeam/git/darktide-mods/mods/` but the game loads them from:
```
/home/deathbeam/.local/share/Steam/steamapps/common/Warhammer 40,000 DARKTIDE/mods/
```

**Important**: After editing files, they must be **copied to the game directory** before restarting Darktide to see changes.

Copy command:
```bash
cd /home/deathbeam/.local/share/Steam/steamapps/common/Warhammer\ 40,000\ DARKTIDE/mods
cp -r /home/deathbeam/git/darktide-mods/mods/[ModName] .
```

### 3. Testing Changes
- Changes require a **full game restart** to take effect
- Darktide caches widget definitions and Lua code on startup
- Simply editing files while the game is running **will not** show changes
- Always verify syntax with `luac -p filename.lua` before copying to game

## Mod-Specific Knowledge

### RingHud
A comprehensive HUD overhaul that displays game information in ring-style widgets around the crosshair.

**Architecture Confusion**: RingHud has TWO parallel file structures:
1. **Active/Production** (root level):
   - `HudElementRingHud.lua` - Main HUD element (currently used)
   - `RingHud_definitions.lua` - Widget definitions (currently used)
   - `RingHud_state.lua` - State management (currently used)

2. **Inactive/Refactored** (`/core/` directory):
   - `HudElementRingHud_player.lua` - Refactored version (NOT used)
   - `RingHud_definitions_player.lua` - Refactored definitions (NOT used)
   - `RingHud_state_player.lua` - Refactored state (NOT used)

**Critical**: The game loads the **root-level** files, NOT the `/core/` versions. Always edit the root-level files.

#### RingHud File Structure
```
RingHud/
├── scripts/mods/RingHud/
│   ├── HudElementRingHud.lua          # Main HUD element (ACTIVE)
│   ├── RingHud_definitions.lua        # Widget definitions (ACTIVE)
│   ├── RingHud_state.lua              # State calculation (ACTIVE)
│   ├── RingHud_data.lua               # Mod settings/config
│   ├── RingHud_localization.lua       # UI text translations
│   ├── features/                       # Feature modules
│   │   ├── pocketable_feature.lua     # Stimm/crate display logic
│   │   ├── peril_feature.lua
│   │   └── ...
│   └── core/                           # Unused refactored code
│       ├── HudElementRingHud_player.lua  # (NOT ACTIVE)
│       ├── RingHud_definitions_player.lua # (NOT ACTIVE)
│       └── RingHud_state_player.lua      # (NOT ACTIVE)
```

#### Widget Definition Pattern
RingHud widgets follow this structure:

1. **Scenegraph Node** - Defines position and size:
```lua
scenegraph_definition = {
    my_widget_node = {
        parent = "container",
        position = { x, y, z },
        size = { width, height },
        horizontal_alignment = "center",
        vertical_alignment = "top",
    },
}
```

2. **Widget Definition** - Defines rendering passes:
```lua
widget_definitions = {
    my_widget = UIWidget.create_definition({
        {
            pass_type = "texture",
            value_id = "icon",
            style_id = "icon",
            style = { color = ARGB.WHITE, offset = { 0, 0, 0 } }
        },
        {
            pass_type = "text",
            value_id = "text",
            style_id = "text",
            value = "",
            style = text_style
        },
    }, "my_widget_node"),
}
```

3. **Update Logic** - In feature modules (e.g., pocketable_feature.lua):
```lua
function Feature.update(widgets, hud_state, hotkey_override)
    local widget = widgets.my_widget
    widget.content.text = "Hello"
    widget.dirty = true
end
```

4. **Draw/Shake Logic** - In HudElementRingHud.lua:
```lua
local w = widgets.my_widget
if w and w.style and w.style.text then
    if apply_shake_to_offset(w.style.text, 0, 0, 1, apply_shake, dx, dy) then
        w.dirty = true
    end
end
```

#### Recent Additions
We recently added **stimm countdown** functionality:
- Shows remaining buff time (green) when stimm is active
- Shows cooldown time (red) when stimm is on cooldown  
- Only displays for broker class (Hive Scum)
- Positioned to the right of the stimm icon
- Properly synced with HUD shake effects

Files modified:
- `RingHud_definitions.lua` - Added stimm_countdown scenegraph and widget
- `RingHud_state.lua` - Added buff/cooldown time calculation
- `pocketable_feature.lua` - Added countdown display logic
- `HudElementRingHud.lua` - Added shake handling for countdown

### StimmCountdown
A standalone mod that adds countdown timer to the vanilla weapon HUD's stimm slot.

**Key Implementation Details**:
- Buff name: `"syringe_broker_buff"`
- Ability type: `"pocketable_ability"`
- Uses `buff_extension._buffs_by_index` to find active buffs
- Calculates time: `duration * duration_progress()`
- Uses `ability_extension:remaining_ability_cooldown()` for cooldown

This mod served as reference for RingHud's stimm countdown integration.

## Common Darktide Lua Patterns

### Accessing Game Extensions
```lua
local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
local ability_ext = ScriptUnit.has_extension(unit, "ability_system")
local health_ext = ScriptUnit.has_extension(unit, "health_system")
```

### Getting Player Information
```lua
local player = Managers.player:local_player_safe(1)
local unit = player and player.player_unit
local profile = player:profile()
local archetype = profile and profile.archetype
```

### Widget Updates
```lua
widget.content.text = "New Text"
widget.style.text.text_color = { 255, 255, 0, 0 }
widget.style.text.visible = true
widget.dirty = true  -- Mark for re-render
```

### Mod Settings
```lua
local my_setting = mod:get("setting_name")
```

## Development Guidelines

### When Asked to Edit a Mod:

1. **Identify the correct files**:
   - For RingHud: Use root-level files, NOT `/core/` versions
   - Check which HudElement file is actually loaded by checking `mod:io_dofile()` calls

2. **Understand the data flow**:
   - State calculation → Definitions → Feature updates → Drawing
   - Follow existing patterns in the mod

3. **Make minimal changes**:
   - Don't refactor working code
   - Add new functionality alongside existing code
   - Preserve original behavior

4. **Test iteratively**:
   - Check syntax: `luac -p file.lua`
   - Copy to game directory
   - Restart game completely
   - Test in-game

5. **Handle positioning carefully**:
   - Scenegraph size affects all child elements
   - Use separate scenegraph nodes for independent positioning
   - Parent nodes to each other for relative positioning
   - Remember: `horizontal_alignment` affects how position is interpreted

6. **Widget best practices**:
   - Explicit `size` in style prevents scaling issues
   - Use `offset` in style for fine positioning
   - Higher z-index renders on top
   - Always set `widget.dirty = true` after changes

## Common Issues & Solutions

### Issue: Changes don't appear in-game
**Solution**: Full game restart required. Editing files while game is running won't work.

### Issue: Widget text renders 1 character per line
**Solution**: Scenegraph node size is too small. Increase width to accommodate text.

### Issue: Widget appears in wrong position
**Solution**: Check `horizontal_alignment` - "center" vs "left" changes anchor point. Also verify parent node is correct.

### Issue: Widget not rendering at all
**Solution**: Ensure widget is defined in `widget_definitions` and the scenegraph node exists. Check if it's being updated in the feature module.

### Issue: Edited wrong file (RingHud confusion)
**Solution**: Check `HudElementRingHud.lua` line 7-8 to see which definitions file is loaded. Use that file, not the `/core/` versions.

## Adding New Config Options

1. **Add to RingHud_data.lua**:
```lua
{
    setting_id = "my_setting",
    type = "numeric",
    default_value = 0,
    range = { -100, 100 },
    decimals_number = 0,
    tooltip = "my_setting_tooltip",
},
```

2. **Add localization to RingHud_localization.lua**:
```lua
my_setting = {
    en = "My Setting Name",
},
my_setting_tooltip = {
    en = "Description of what this setting does.",
},
```

3. **Use in code**:
```lua
local value = mod:get("my_setting") or 0
```

## Code Style

- Use 4 spaces for indentation (not tabs)
- Follow existing naming conventions in the mod
- Add comments only for complex logic, not obvious code
- Keep lines under 120 characters when possible
- Use descriptive variable names

## Integration Philosophy

When integrating functionality from one mod to another (like StimmCountdown → RingHud):
1. Study how the source mod works
2. Adapt to target mod's architecture
3. Follow target mod's patterns and style
4. Keep the integration modular
5. Document what was learned from the source mod

## Notes

- Darktide uses Lua 5.1
- The game provides DMF (Darktide Mod Framework) for mod loading and hooks
- Mods can hook into existing game functions with `mod:hook()` or `mod:hook_safe()`
- UI uses Fatshark's custom UI system, not standard Lua GUI libraries
