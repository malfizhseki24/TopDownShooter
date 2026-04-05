# Feature: Active Skill System (Keys 1, 2, 3)

## Why

The current kit (Bow, Melee, Dash, Sun-Piercer) lacks mid-combat options — there is no AoE burst around the player, no multi-target ranged option, and no defensive cooldown to fall back on when surrounded. Three activatable skills mapped to keys 1/2/3 give Kasuari more expressive power in encounters and reinforce the Papuan lore through thematic abilities.

## What Changes

- **NEW INPUT ACTIONS**: `skill_1` (Key 1), `skill_2` (Key 2), `skill_3` (Key 3) registered in project.godot
- **NEW SKILL — Talon Kick (1)**: AoE burst in 100px radius around player, 45 damage, 5s cooldown — references the cassowary's iconic deadly kick
- **NEW SKILL — Feather Volley (2)**: Fires 5 arrows in a 90° fan simultaneously, 20 damage each, 9s cooldown — references Kasuari's lost wings (core to the redemption lore)
- **NEW SKILL — Ancestor's Ward (3)**: Activates a hit-absorb shield for up to 3s (negates one incoming hit), 14s cooldown — ancestral spirit protection
- **NEW SIGNALS** on EventBus: `skill_activated`, `skill_cooldown_started`, `skill_cooldown_ready`
- **NEW HUD ELEMENT**: Skill bar with 3 slots showing cooldown overlay, key label, and ready glow — positioned below energy meter

## Impact

- Affected systems: `active-skills` (new), `hud` (modified — new skill bar)
- Affected files:
  - `project.godot` — new input actions
  - `scripts/player/player.gd` — skill execution + cooldown state
  - `scripts/autoload/event_bus.gd` — new skill signals
  - `scripts/ui/hud.gd` + `scenes/ui/hud.tscn` — skill bar node + connection
  - `scripts/ui/skill_bar.gd` + `scenes/ui/skill_bar.tscn` (new files)
- No save-breaking changes (skills reset with each run)
- No balance disruption to existing combat; skills are additive
