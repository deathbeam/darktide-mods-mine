# AutoAbilities - Merged Mod

This mod combines three previously separate mods into one unified system:

## Merged Mods

1. **ChemicalAutoStim** - Automatically uses broker stims when Chemical Dependency isn't at max stacks
2. **QuickDeploy** - Keybinds to instantly deploy ammo/medkits or inject stims
3. **AutoBlitz** - Automatically throws grenades based on conditions, including dogsplosion automation

## Benefits of Merging

- **Shared Code**: All three mods used nearly identical state machines and weapon switching logic
- **No Conflicts**: They now share a single state system, preventing input hijacking conflicts
- **Easier Maintenance**: Bug fixes and improvements apply to all features at once
- **Cleaner Configuration**: One mod settings menu instead of three

## Architecture

### Unified State Machine
All features now use the same `ACTION_STAGES` enum:
- `NONE` - Idle
- `SWITCH_TO` - Switching to target slot
- `WAITING` - Waiting for ability usage (ChemicalAutoStim)
- `PLACE` - Placing/using item (QuickDeploy)
- `AIM_ALLY` - Aiming at ally (QuickDeploy)
- `INJECT_ALLY` - Injecting to ally (QuickDeploy)
- `SWITCH_BACK` - Switching back to previous weapon

### Shared Helper Functions
- `_get_player_unit()` - Get local player unit
- `_get_gameplay_time()` - Get current gameplay time
- `_is_weapon_switching()` - Check if weapon switch in progress
- `_is_weapon_template_valid()` - Validate weapon slot
- `_can_use_ability()` - Check if ability is usable
- `_reset_state()` - Reset all state variables

### Feature Modules

#### ChemicalAutoStim
- Runs in `update()` loop when enabled
- Checks Chemical Dependency stacks every 0.5s
- Automatically injects when below max stacks

#### QuickDeploy
- Triggered by keybinds
- Supports self-injection and ally injection modes
- 2-second timeout for safety

#### AutoBlitz
- Grenade auto-throw with charge thresholds
- Dogsplosion automation with enemy thresholds
- Manual keybind override option
- Allow/block player cancellation

## Configuration

Settings are organized into groups:
- **Chemical AutoStim** - Enable/disable toggle
- **Quick Deploy** - Three keybinds (ammo/medkit, self-stim, ally-stim)
- **Auto Blitz** - Override settings and throw keybind
- **Per-Class Grenades** - Adamant, Ogryn, Veteran, Zealot, Broker

## Migration Notes

If you were using the old separate mods:
1. Disable ChemicalAutoStim, QuickDeploy, and AutoBlitz
2. Enable AutoAbilities
3. Re-configure your settings (they won't transfer automatically)
4. Set up keybinds again

## Technical Details

- Single input hook for all three features
- Prioritizes ChemicalAutoStim when conditions met
- QuickDeploy uses explicit keybind triggers
- AutoBlitz checks grenade slot wielding separately
- All features respect weapon switching states
