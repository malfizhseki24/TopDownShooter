# Design: Destructible Props

## Key Decisions

### 1. StaticBody2D base, not CharacterBody2D

Destructibles don't move, so `StaticBody2D` is the right base. They have collision shapes for arrows/melee detection but don't participate in physics movement. A dedicated physics layer (layer 6: "destructible") is added so arrows can detect them.

### 2. Arrow collision with destructibles via Area2D overlap

Arrows already use `Area2D` with `_on_body_entered()`. Adding destructibles to a physics layer the arrow monitors means arrows will naturally collide. The arrow calls `destructible.take_damage(arrow_damage)` and then `queue_free()`.

### 3. Break FX as one-shot particle scenes

Each destructible type has a specific break effect scene spawned via VFXManager on destruction. These are `GPUParticles2D` with one-shot emission (4-8 particles, short lifetime). The base destructible calls `VFXManager.spawn(break_fx_scene, global_position)`.

### 4. Drops spawn at destructible position with upward impulse

When a destructible breaks, it rolls the drop table. If a drop spawns, it appears at the break position with a small upward-then-fall arc (tween y position up 10px then down over 0.3s). Drops have a small pickup area that the player walks through.

### 5. Spirit Ember healing uses existing EventBus.player_healed

The Spirit Ember pickup calls `EventBus.player_healed.emit(5)` which the player already listens for. No new healing system needed.

### 6. Shadow Fragment is cosmetic only

Shadow Fragment has no gameplay effect. It increments a counter in GameManager for future meta-progression. For now, it just plays a pickup VFX and sound.

### 7. Boss interaction with Shadow Pillars

Shadow Pillars in the boss room are on both the destructible layer and wall layer. When the boss charges into one, it takes 3 damage (instant break) and the boss gets stunned as if hitting a wall. After breaking, the pillar is gone and the boss can charge through that space.

## Drop Table

| Roll (0-99) | Result | Implementation |
|-------------|--------|----------------|
| 0-79 | Nothing | Just break FX |
| 80-94 | Spirit Ember | Spawn pickup, heal 5 HP on collect |
| 95-99 | Shadow Fragment | Spawn pickup, increment counter |
