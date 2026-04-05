## Context

Adding 3 activatable skills to deepen player expression. The game is solo-developed with an AI assist ("vibe coding") so simplicity and readability are the top priority. Skills must feel as juicy as the existing kit (hitstop, camera shake, particles) and must be thematically tied to Papuan/Kasuari lore.

## Goals / Non-Goals

- **Goals**: Talon Kick (AoE close), Feather Volley (multi-target ranged), Ancestor's Ward (hit-absorb shield); independent cooldowns; HUD skill bar
- **Non-Goals**: Skill unlock progression, upgrades, shard-gated costs, additional skill slots, gamepad bindings (keyboard-first MVP)

## Technical Decisions

- **Inline in player.gd (not a separate SkillComponent)**: Three skills are not complex enough to warrant a resource-based component system. Constants, cooldown timers (Timer nodes), and state flags are added directly to `player.gd`. If skills grow to 5+ in future, extracting a component is worth revisiting.
- **Independent cooldown Timers (not shared energy)**: Each skill has its own `Timer` node child (5s / 9s / 14s one-shot), keeping cooldowns fully independent. This avoids tradeoff tension with the existing shard/Sun-Piercer economy — skills are a separate layer.
- **Feather Volley reuses arrow scene**: Fires 5 instances of `res://scenes/player/arrow.tscn` at angle offsets (−45°, −22.5°, 0°, +22.5°, +45°), each at 20 damage. No new projectile needed.
- **Ancestor's Ward as an i-frame variant**: Adds an `is_warded` boolean. While warded, the first `take_damage()` call is absorbed (negated), then the ward is consumed. A Timer enforces the 3s max duration. This mirrors the existing `is_invincible` pattern.
- **Talon Kick uses a temporary Area2D overlap check**: On activation, the existing `melee_area` shape is temporarily scaled up (radius 100px), `get_overlapping_bodies()` is called synchronously, then scale is restored. Simpler than spawning a new Area2D scene.

## Balance Values

| Skill | Damage | Radius / Spread | Cooldown | Duration |
|-------|--------|-----------------|----------|----------|
| Talon Kick | 45 per enemy | 100 px AoE | 5 s | instant |
| Feather Volley | 20 × 5 arrows | 90° fan (5 rays) | 9 s | arrow lifetime 3s |
| Ancestor's Ward | — (negates 1 hit) | — | 14 s | ward lasts 3s |

## Asset Requirements

- **Sprites**: No new character sprites needed; existing VFX manager handles particles
- **VFX**: 
  - Talon Kick: ground shockwave ring (VFXManager `spawn()` call with existing or new particle)
  - Feather Volley: feather particle burst from player origin
  - Ancestor's Ward: spirit aura ring around player (simple ColorRect or particle loop)
- **Audio**:
  - `assets/audio/sfx/talon_kick.wav` (heavy impact / stomp)
  - `assets/audio/sfx/feather_volley.wav` (whoosh burst)
  - `assets/audio/sfx/ancestor_ward_activate.wav` (chime / spirit tone)
  - `assets/audio/sfx/ancestor_ward_break.wav` (crack / shatter)
  - Placeholder: reuse existing SFX if custom audio not yet sourced

## Open Questions

- None — brainstorm approved; proceeding to implementation.
