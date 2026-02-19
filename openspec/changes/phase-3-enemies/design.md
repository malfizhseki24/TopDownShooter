## Context

Phase 2 established player combat (bow, melee, dash) and death/respawn mechanics. Now we need enemies to create the core gameplay loop. The GDD specifies 4 enemy types with distinct behaviors, plus a spawn system using shadow pools.

**Current State:**
- Player has Hitbox Area2D for detecting collisions
- EventBus exists for game-wide signals
- GameManager tracks game state (PLAYING, PAUSED, etc.)
- Shadow Wisp sprites ready; other enemy sprites pending

**Constraints:**
- Max 8-10 enemies on screen (methodical combat)
- Pixel art sprites (64x64 for enemies)
- Smooth sub-pixel movement (no pixel snapping)
- Physics interpolation enabled

## Goals / Non-Goals

**Goals:**
- Create reusable base enemy class with common functionality
- Implement 4 distinct enemy types with unique behaviors
- Build shadow pool spawn system for enemy waves
- Add hit feedback (flash, knockback) and death effects (dissolve)
- Integrate with existing player damage system

**Non-Goals:**
- Boss implementation (Phase 4)
- Enemy drops/loot (future feature)
- Multiple spawn configurations per pool (MVP simplicity)
- Enemy pathfinding (behaviors are simple homing/charging)

## Decisions

### 1. Inheritance vs Composition for Enemy Types

**Decision: Use inheritance with virtual methods**

Base class `BaseEnemy` extends `CharacterBody2D` with:
- Common stats (hp, damage, speed)
- Shared methods (take_damage, die, _flash_white)
- Virtual methods for behaviors (_move_toward_player, _special_behavior)

**Rationale:**
- All enemies share 80% of functionality (HP, damage, death)
- Each enemy type only overrides movement/attack behavior
- Simpler than composition for this scope
- Matches Godot patterns (CharacterBody2D hierarchy)

**Alternatives Considered:**
- Composition (separate behavior components) - overkill for 4 enemy types
- Single enemy scene with type enum - would create spaghetti conditionals

### 2. Enemy State Management

**Decision: Simple enum-based state machine**

```gdscript
enum State { IDLE, MOVING, ATTACKING, DYING }
var current_state: State = State.IDLE
```

**Rationale:**
- Enemies have simple state needs (move/attack/die)
- No complex transitions like player (dash, shoot interrupts)
- Easy to debug and extend

### 3. Spawn System Architecture

**Decision: ShadowPool as autonomous spawner**

Each ShadowPool:
- Stores array of enemy scene references
- Has max_enemies and spawn_interval
- Spawns when player enters detection area
- Tracks spawned enemies to respect global max (via GameManager)

**Rationale:**
- Encapsulates spawn logic in one node
- Level designers place pools visually in editor
- No central spawner manager needed

### 4. Hit Detection Architecture

**Decision: Enemy Area2D for player collision, method call for damage**

- Enemy has Area2D "Hitbox" detecting player layer
- On body_entered, call `player.take_damage(contact_damage)`
- Arrows detect enemy layer, call `enemy.take_damage(arrow_damage)`

**Rationale:**
- Mirrors existing player Hitbox pattern
- Direct method calls simpler than signals for damage
- Area2D provides reliable collision detection

### 5. Death Effect Implementation

**Decision: Modulate fade + tween, then queue_free**

```gdscript
func die():
    current_state = State.DYING
    var tween = create_tween()
    tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)
```

**Rationale:**
- Simple dissolve effect without particle system
- Matches "dissolve into black particles" intent at MVP scope
- Can upgrade to actual particles later

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Too many enemies spawn | GameManager tracks global count, pools check before spawning |
| Enemies stack on each other | Add separation force in physics process |
| Shadow Stalker teleport feels unfair | Add 0.5s visible period after teleport before attacking |
| Shadow Brute charge too fast | Telegraph with flash + 0.3s pause before charge |
| Performance with 10 enemies | Keep behaviors simple, use Object Pooling if needed (future) |

## Migration Plan

1. **Add physics layers** - Project Settings > 2D Physics: add "enemy" (layer 4)
2. **Create base_enemy** - Script + scene with common functionality
3. **Implement Shadow Wisp first** - Simplest behavior, validates base class
4. **Add remaining enemies** - One at a time, test each
5. **Create ShadowPool** - Spawn system with Wisp only, then expand
6. **Integration test** - Full gameplay loop with all enemy types

**Rollback:** Each enemy is independent scene - can disable individually if issues arise.

## Open Questions

- [ ] Should enemies have spawn-in animation? (Currently no - dissolve on death only)
- [ ] Exact knockback distance? (Start with 50px, tune in playtesting)
- [ ] Shadow Crawler "group" behavior - just spawn 2-3, or coordinate movement? (MVP: just spawn multiples)
