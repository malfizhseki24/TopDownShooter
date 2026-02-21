# Feature: Implement Phase 7 — HUD System & UI Polish

## Why

The current HUD is a placeholder ProgressBar + Labels with no visual identity, no feedback layering, and no alignment with the game's Papuan-folklore pixel art aesthetic. Every shipped action game earns player trust through a HUD that **communicates state changes instantly and disappears when irrelevant**. Right now the player cannot:

- See dash cooldown status (critical during combat)
- Track room progression at a glance
- Receive per-hit floating damage numbers (the most impactful missing feedback layer)
- See contextual interact prompts in world-space near shrines/portals

The boss health bar exists but lacks the damage-trail "ghost bar" effect, phase transition FX, and defeat shatter specified in the GDD. The main menu, pause menu, game over, and victory screens are functional but are not tracked as Phase 7 deliverables — they already exist and work.

This change implements the **6 remaining HUD systems** from the GDD's In-Game HUD Design section plus wires them through EventBus for full signal-driven architecture.

## What Changes

### New HUD Elements (6 systems)
- **Player Health Bar** — Custom ColorRect-based bar with damage trail ghost bar, low-HP pulse (`sin(time*6)`), heal flash (green tint), optional HP text that fades after changes
- **Dash Cooldown Indicator** — Thin bar below health bar, only visible during cooldown, flashes cyan on ready then fades to invisible
- **Room Progress Indicator** — 7-dot horizontal row (top-right), color-coded (completed/current/future/heal/boss), pulse on room change
- **Boss Health Bar Polish** — Upgrade existing boss_health_bar.tscn with damage trail, phase transition bar flash, defeat shatter particles, GDD-spec sizing (240x10)
- **Contextual [E] Prompts** — World-space floating prompts on interactables (heal shrine, portal) with appear/disappear animations and idle bob
- **Floating Damage Numbers** — Per-hit world-space text (color-coded by type: white=arrow, yellow=melee, red=player-hurt, green=heal), directional float (up=dealt, down=taken), scale pop, auto-cleanup

### EventBus Integration
- Wire all 6 HUD elements through EventBus signals (no direct node references from HUD to game objects)
- Add missing signals: `damage_dealt`, `damage_taken` with position + amount + type data
- Ensure HUD CanvasLayer uses `process_mode = ALWAYS` for hitstop compatibility

### Architecture Refactor
- Extract HUD from game.tscn inline nodes into dedicated `hud.tscn` scene with its own `hud.gd` script
- Each HUD element is a self-contained sub-scene (health_bar.tscn, dash_cooldown.tscn, room_progress.tscn, damage_number.tscn)
- Reuse existing boss_health_bar.tscn (upgrade in place)

## Impact

- **Affected game systems**: hud (NEW), menus (existing — track completion), damage-numbers (NEW), interact-prompts (NEW), boss (MODIFIED — health bar upgrade), game-state (MODIFIED — new EventBus signals)
- **Affected files**:
  - NEW: `scenes/ui/hud.tscn`, `scripts/ui/hud.gd`, `scenes/ui/health_bar.tscn`, `scripts/ui/health_bar.gd`, `scenes/ui/dash_cooldown.tscn`, `scripts/ui/dash_cooldown.gd`, `scenes/ui/room_progress.tscn`, `scripts/ui/room_progress.gd`, `scenes/ui/damage_number.tscn`, `scripts/ui/damage_number.gd`, `scripts/ui/interact_prompt.gd`
  - MODIFIED: `scenes/ui/boss_health_bar.tscn`, `scripts/ui/boss_health_bar.gd`, `scripts/autoload/event_bus.gd`, `scenes/levels/game.tscn`, `scripts/levels/game.gd`, `scripts/player/player.gd`, `scripts/enemies/base_enemy.gd`, `scripts/boss/shadow_boar.gd`, `scenes/interactables/room_portal.tscn`, `scenes/interactables/heal_shrine.tscn`
- **Asset pipeline**: PixelLab-generated health bar frame sprite (`assets/sprites/ui/health_bar_frame.png`) for tribal-themed bar border
- **No save-breaking changes**
- **No balance changes**
