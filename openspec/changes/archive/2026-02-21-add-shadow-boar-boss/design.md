## Context

The Shadow Boar is the final boss of Stage 1 (Room 7). It's a massive demonic boar consumed by shadow, representing untamed rage and gluttony. The fight has two distinct phases that escalate difficulty. The boss arena is 21x15 tiles with 4 corner pillars (obstacles).

Player arrives with whatever HP they have from rooms 1-6 (no full heal). The boss must feel dangerous but fair — all attacks are telegraphed and dodgeable.

## Goals / Non-Goals

**Goals:**
- Two-phase boss fight with clear behavior escalation
- Charge attack that interacts with the arena (wall stun)
- Phase 2 adds wisp summons and shockwave to increase pressure
- Boss health bar UI with phase transition visual
- All attacks telegraphed so player can react
- Victory triggers on boss death

**Non-Goals:**
- Destructible pillars (future polish — pillars are static obstacles for now)
- Custom boss music / audio (uses existing systems, placeholder SFX)
- Melee-specific boss interactions (bow-only combat for now)
- Save/checkpoint system

## Technical Decisions

### Boss AI: State Machine
The Shadow Boar uses an explicit state machine (not the simple BaseEnemy states). Boss states:
- `IDLE` — brief pause between actions
- `CHASE` — move toward player at base speed
- `TELEGRAPH` — flash + paw ground animation before charge (1 sec)
- `CHARGING` — dash at high speed in locked direction
- `STUNNED` — dazed after hitting wall during charge (2 sec, vulnerable)
- `SLAM` — Phase 2 ground slam with expanding shockwave
- `SUMMONING` — Phase 2 wisp spawn (brief pause)
- `DYING` — death animation, victory trigger

### Phase Transition
At 50% HP (250), the boss enters a brief invulnerable transition state:
1. Boss stops, screen flashes white
2. Boss "roars" (animation + camera trauma)
3. Phase 2 begins with faster values and new attacks

### Collision Setup
- Body collision: CircleShape2D radius 24 (movement/wall collision)
- Hitbox (damage to player): CircleShape2D radius 32
- Hurtbox (receives damage): Separate Area2D, CircleShape2D radius 28

### Extending BaseEnemy
Shadow Boar extends BaseEnemy but overrides most behavior. It keeps:
- `take_damage()` for consistent hit feedback
- `die()` chain (signals, death animation, queue_free)
- `_flash_white()` for hit feedback
- Group membership ("enemy" + "boss")

### Boss Health Bar
Separate UI scene (`boss_health_bar.tscn`) controlled via EventBus signals:
- `boss_spawned` → show bar, set max HP, display name
- `boss_health_changed` → update fill
- `boss_phase_changed` → change bar color (red → purple)
- `boss_defeated` → hide bar with shatter effect (or simple fade)

### Room Manager Integration
- `_setup_boss_room()` loads `shadow_boar.tscn` instead of shadow_brute
- Boss scene preloaded in `_load_scenes()`
- Boss death handled via `enemy_died` signal (already works) + `boss_died` for UI

## Balance Values

| Property | Phase 1 | Phase 2 | Notes |
|----------|---------|---------|-------|
| **Total HP** | 500 | (continues) | GDD spec |
| **Phase 2 Trigger** | — | 250 HP (50%) | GDD spec |
| **Contact Damage** | 25 | 25 | Touch damage |
| **Charge Damage** | 40 | 40 | During charge state |
| **Shockwave Damage** | — | 20 | Phase 2 only |
| **Move Speed** | 80 px/s | 80 px/s | Slow chase |
| **Charge Speed** | 350 px/s | 455 px/s | 30% faster in P2 |
| **Charge Duration** | 0.6 sec | 0.6 sec | |
| **Charge Cooldown** | 4.0 sec | 3.0 sec | Shorter in P2 |
| **Wall Stun Duration** | 2.0 sec | 1.5 sec | Shorter in P2 |
| **Telegraph Duration** | 1.0 sec | 0.7 sec | Snort + paw ground |
| **Shockwave Radius** | — | 120 px | Expanding ring |
| **Shockwave Expand Time** | — | 0.5 sec | |
| **Slam Cooldown** | — | 5.0 sec | |
| **Wisp Summon Interval** | — | 8.0 sec | GDD spec: 2 wisps |
| **Wisp Summon Count** | — | 2 | Per summon cycle |

## Asset Requirements

### Sprites (READY)
- `shadow_boar` character: idle, attack, jump-attack, running-8-frames, walk-8-frames (4 dirs each)
- All stored in `assets/sprites/characters/boss/shadow_boar/`
- SpriteFrames resource: `shadow_boar_frames.tres`

### VFX (TO CREATE)
- **Shadow Trail**: Dark particles left behind during charge (reuse existing particle system or simple trail)
- **Shockwave Ring**: Expanding circle for ground slam (simple shader or animated sprite)
- **Phase Transition Flash**: White screen overlay (can be done with ColorRect tween)
- **Wall Impact Dust**: Particles when boss hits wall (reuse death_smoke or similar)

### Audio (TO SOURCE)
- Boss charge telegraph (snort/grunt)
- Charge impact (wall hit)
- Ground slam
- Phase transition roar
- Boss death

## Decisions (Resolved)

1. **Shadow trails from charges**: Visual-only for MVP. Dark particle trail behind boss during charge — no damage. Can add damage in a future balance pass if boss is too easy.
2. **Boss invulnerable during phase transition**: Yes. 1-sec invulnerability during phase 2 transition (prevents skipping the transition with burst damage).
3. **Max wisps alive during Phase 2**: Cap at 4 (2 per summon, max 2 summons worth alive at once).
