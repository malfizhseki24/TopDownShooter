# Design: Player Forgiveness & Combat Feel Systems

## Architecture Overview

This change touches the player, arrow, and a new shader. No new autoloads are added — the input buffer and i-frame logic live inside `player.gd` as they are player-specific. The aim assist lives inside the arrow spawn flow in `player.gd`.

## System Interaction Map

```
player.gd
├── _handle_actions()
│   ├── Input Buffering ← checks buffer before cooldown/state gates
│   ├── _shoot()
│   │   └── Aim Assist ← adjust aim_direction before arrow spawn
│   └── _dash()
│       └── Dash Forgiveness ← bypass hitstun if within grace window
├── take_damage()
│   ├── Damage I-Frames ← start 0.8s invincibility + flicker
│   ├── Dash Forgiveness ← record _last_damage_time
│   └── Hit Flash Shader ← tween flash_intensity on sprite material
└── Hitbox Manipulation ← scene structure (HurtboxArea vs CollisionShape2D)
```

## Decision 1: Input Buffer — Player-Local vs Autoload

**Options:**
- A) `InputBufferManager` autoload (like GDD pseudocode)
- B) Buffer logic inside `player.gd` as private vars

**Decision: B — Player-local.** Only the player needs input buffering. No enemy or UI system reads the buffer. Adding an autoload for a single consumer is over-engineering. The buffer is 3 variables (`_buffered_action`, `_buffer_timestamp`, `BUFFER_WINDOW`).

## Decision 2: I-Frame Flicker — Timer vs _process Counter

**Options:**
- A) Two `Timer` nodes (IFrameTimer + FlickerTimer) as in GDD node architecture
- B) Counters in `_physics_process` using `delta` accumulation

**Decision: A — Timer nodes.** The GDD specifies `IFrameTimer` and `FlickerTimer` in the player scene tree. Timers are more readable, don't drift, and auto-stop. The FlickerTimer (0.08 sec, repeating) toggles `sprite.visible`. IFrameTimer (one-shot, 0.8 sec) ends the i-frame period.

## Decision 3: Aim Assist — Where to Apply

**Options:**
- A) In `arrow.gd` `_ready()` — arrow adjusts its own direction
- B) In `player.gd` `_shoot()` — adjust `aim_direction` before passing to arrow

**Decision: B — In player's _shoot().** The correction is a one-time adjustment at spawn. Doing it in the player means the arrow receives its final direction and doesn't need to know about enemies. Keeps arrow.gd simple.

## Decision 4: Hitbox Restructure

Current player scene has a single `Hitbox (Area2D)` used for enemy contact damage detection. The change separates this into:

- `CollisionShape2D` (on CharacterBody2D) — physics/wall collision, Circle r=12
- `HurtboxArea (Area2D)` — damage reception, Circle r=10, on `player` hurtbox layer
- Remove old `Hitbox` Area2D or rename it to `HurtboxArea`

The arrow's `CollisionShape2D` changes from its current size to Circle r=7.

## Decision 5: Hit Flash Shader — Material Setup

The `hit_flash.gdshader` is applied as a `ShaderMaterial` on the player's `AnimatedSprite2D`. The `flash_intensity` uniform is tweened from 1.0→0.0 on hit. For red flash (player damage), `flash_color` is set to `vec4(1.0, 0.2, 0.2, 1.0)` before tweening. For white (respawn), `flash_color` stays default white.

This replaces the current `sprite.modulate = Color.RED` approach.

## Constants Summary (All Tunable)

| Constant | Value | Location |
|----------|-------|----------|
| `DAMAGE_IFRAME_DURATION` | 0.8 | player.gd |
| `IFRAME_FLICKER_INTERVAL` | 0.08 | player.gd |
| `INPUT_BUFFER_WINDOW` | 0.15 | player.gd |
| `DASH_FORGIVENESS_WINDOW` | 0.12 | player.gd |
| `AIM_CONE_HALF_ANGLE` | 12° (0.209 rad) | player.gd |
| `AIM_MAX_CORRECTION` | 8° (0.14 rad) | player.gd |
| `AIM_ASSIST_RANGE` | 300.0 | player.gd |
| `PLAYER_HURTBOX_RADIUS` | 10.0 | player.tscn |
| `PLAYER_BODY_RADIUS` | 12.0 | player.tscn |
| `ARROW_HITBOX_RADIUS` | 7.0 | arrow.tscn |
| `HIT_FLASH_DURATION` | 0.08 | player.gd |
| `HIT_FLASH_RED_DURATION` | 0.12 | player.gd |
