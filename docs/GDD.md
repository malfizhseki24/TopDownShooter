# Game Design Document

## WARRIOR OF THE SUNRISE
*Working Title*

---

## Overview

| Property | Value |
|----------|-------|
| **Genre** | Top-Down Action Roguelite |
| **Dimension** | 2D |
| **Art Style** | Pixel Art - Chibi/SD (Super Deformed) |
| **Tile Size** | 32x32 |
| **Character Max Size** | 128x128 |
| **Combat Style** | Methodical (aim carefully, fewer enemies) |
| **Engine** | Godot 4.6 |
| **Target Platform** | PC (Windows, macOS, Linux) |

### IMPORTANT: Modern Game with Pixel Art Visuals

> **This is a MODERN top-down shooter (like Enter the Gungeon, Nuclear Throne) that uses pixel art as its VISUAL STYLE.**
>
> - **NOT** a retro/pixel-perfect snapping game
> - **Movement**: Sub-pixel, high-precision, smooth (float coordinates)
> - **Physics**: Full interpolation for butter-smooth rendering
> - **Camera**: Physics-syncs with built-in smoothing
> - **Texture Filtering**: Nearest (keeps pixel art sharp at sub-pixel positions)
>
> The pixel art is purely aesthetic. All game mechanics must feel modern and responsive.

---

## Lore & Story

### The Fallen Demigod: KASUARI

**Origin Myth (Based on Sentani & Fakfak Folklore)**

Kasuari was once a bird with magnificent wide wings capable of soaring through the skies. However, consumed by greed and arrogance, it committed a great betrayal. As punishment, its wings were broken (in some versions by the Crowned Dove or Pipit bird), condemning it to become a flightless bird forever bound to walk the earth.

### Game Adaptation

**Protagonist - "Kasuari" (Code Name/Title)**

- **True Identity**: A former War Chief / High General
- **The Fall**: Once a proud and arrogant military leader whose hubris led to a catastrophic defeat. Stripped of honor, rank, and spiritual power ("wings broken")
- **Current State**: Condemned to the Underworld / Forbidden Forest
- **Goal**: Fight through the ever-changing forest to seek redemption and reclaim honor

### Roguelite Story Integration

The Forbidden Forest shifts and changes with each attempt - a manifestation of Kasuari's tormented soul. Each run represents another attempt at redemption. Death means starting over, but the forest remembers...

---

## Core Gameplay

### Gameplay Loop (Linear Room-Based)

```
┌─────────────────────────────────────────────────────────────────┐
│                   LINEAR ROOM PROGRESSION                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐                                               │
│   │ Main Menu   │                                               │
│   │ - New Run   │                                               │
│   └──────┬──────┘                                               │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────────────────────────────────────────────┐        │
│   │                    STAGE 1 (7 Rooms)                │        │
│   │                                                     │        │
│   │  ┌────┐   ┌────┐   ┌────┐   ┌────┐   ┌────┐        │        │
│   │  │ 1  │──▶│ 2  │──▶│ 3  │──▶│ 4  │──▶│ 5  │        │        │
│   │  │Combat   │Combat   │Heal    │Combat   │Combat   │        │
│   │  │Wisp     │Wisp+    │Shrine  │Wisp+    │All      │        │
│   │  │only     │Crawler  │        │Crawler  │types    │        │
│   │  └────┘   └────┘   └────┘   └────┘   └────┘        │        │
│   │                               │                     │        │
│   │                               ▼                     │        │
│   │                           ┌────┐   ┌─────────┐     │        │
│   │                           │ 6  │──▶│   7     │     │        │
│   │                           │Heal    │ BOSS    │     │        │
│   │                           │Shrine  │Shadow   │     │        │
│   │                           │        │Boar     │     │        │
│   │                           └────┘   └─────────┘     │        │
│   └─────────────────────────────────────────────────────┘        │
│                                    │                            │
│                          ┌─────────┴─────────┐                  │
│                          ▼                   ▼                  │
│                   ┌──────────┐        ┌───────────┐             │
│                   │  Die!    │        │ Victory!  │             │
│                   └────┬─────┘        └─────┬─────┘             │
│                        │                    │                    │
│                        └────────┬───────────┘                   │
│                                 ▼                                │
│                        [Return to Menu]                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Controls

| Action | Input |
|--------|-------|
| Move | WASD / Arrow Keys |
| Aim | Mouse / Right Stick |
| Shoot Arrow | Left Click / RT |
| Heavy Attack / Special | Right Click / LT |
| Dash / Dodge | Space / A Button |
| Interact | E / X Button |
| Pause | Escape / Start |

### Core Mechanics

- **Bow & Arrow**: Primary ranged combat with arrow physics, infinite arrows
- **Melee System**: Secondary close-quarters combat with the Casque (heavy attack)
- **Dash/Dodge**: I-frame based evasion with cooldown
- **Linear Room Progression**: Fixed 7-room stages with increasing difficulty
- **Portal System**: Clear enemies to unlock portal to next room
- **Heal Shrines**: Interact to restore HP (one-time use per room)
- **HP Persistence**: Player HP carries between rooms
- **Boss Fights**: Shadow Boar encounter with 2 phases at end of stage

### Room Types

| Room Type | Description | Appears In |
|-----------|-------------|------------|
| **Combat** | Defeat all enemies to spawn portal | Rooms 1, 2, 4, 5 |
| **Heal Shrine** | Interact (E) to restore 50 HP | Rooms 3, 6 |
| **Boss** | Final room, defeat boss to win | Room 7 |

### Room Configuration (Stage 1)

| Room | Type | Enemies | Notes |
|------|------|---------|-------|
| 1 | Combat | 3x Shadow Wisp | Tutorial difficulty |
| 2 | Combat | 2x Wisp + 2x Crawler | Mixed enemy types |
| 3 | Heal | - | Rest point, heal shrine |
| 4 | Combat | 2x Wisp + 2x Crawler + 1x Stalker | Stalker introduced |
| 5 | Combat | 3x Crawler + 2x Stalker + 1x Brute | All enemy types |
| 6 | Heal | - | Rest before boss |
| 7 | Boss | 1x Shadow Boar (enhanced) | Final encounter |

### Stage Progression (Future)

Planned multi-stage progression for post-MVP:

```
Stage 1-2:  Beach/Coastal     → Beginning of journey
Stage 3-4:  Jungle River       → Dense forest with water
Stage 5-6:  Jungle Ruins       → Ancient temple ruins
Stage 7+:   Snow Mountain      → Peak of Jaya Wijaya (redemption)
```

### Arrow System

| Property | Value |
|----------|-------|
| **Ammo** | Infinite |
| **Fire Rate** | 0.5 sec between shots (methodical pace) |
| **Arrow Speed** | 600 px/sec |
| **Arrow Lifetime** | 3 seconds (despawn if no hit) |
| **Damage** | 25 per arrow |

### Camera System

| Property | Value |
|----------|-------|
| **Type** | Smooth follow with trauma-based shake |
| **Follow Lerp Weight** | `lerp_weight = 8.0` (responsive but not instant) |
| **Look-Ahead Distance** | 40 px in aim direction (<!-- NEW: look-ahead -->) |
| **Look-Ahead Smoothing** | `lerp_weight = 4.0` for aim offset (slower than follow) |
| **Trauma Decay Rate** | `trauma -= 3.0 * delta` per frame (fast recovery) |
| **Max Shake Offset** | 8 px (horizontal), 6 px (vertical) |
| **Shake Formula** | `offset = trauma² * max_offset * noise` (quadratic falloff) |

> <!-- NEW --> **Camera Easing**: The camera target is `player_position + (aim_direction * look_ahead_distance)`. This look-ahead gives the player more visibility in the direction they're aiming, which is critical for a ranged combat game. The quadratic trauma formula means small hits produce subtle shakes while large hits produce dramatic ones.

---

## Game Feel & Juice <!-- NEW SECTION -->

> **Design Philosophy**: Every player action must produce immediate, satisfying feedback through multiple sensory channels (visual, audio, haptic). The goal is to make even basic attacks feel impactful. A single arrow hit should produce a white flash, a knockback, a hitstop frame, a hit sound, and a subtle camera shake — all within 0.1 seconds. This layering is what separates a good-feeling game from a flat one.

### Forgiveness & Accessibility Systems <!-- NEW SECTION -->

These systems run invisibly to make the game feel fair and responsive, especially for players who are not action game veterans. The player should never know these systems exist — they should just feel like the game "works."

#### Aim Assist / Soft Magnetism

The bow uses a subtle magnetism system that bends arrow trajectories slightly toward nearby enemies. This compensates for the difficulty of precise aiming in a fast-paced game without making the player feel like they're being helped.

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Magnetism Cone Half-Angle** | 12° | Narrow enough to feel intentional |
| **Snap Radius** | 40 px | How close an enemy must be to the trajectory line |
| **Max Correction Angle** | 8° | Arrow bends no more than this toward target |
| **Activation Distance** | 300 px | Only applies within this range (not across the room) |
| **Priority** | Nearest enemy in cone | If multiple enemies in cone, snap to closest |
| **Visual** | None — arrow flies naturally | No aim reticle snapping, no visible assist |

**Implementation**: On arrow spawn, cast a cone from the player in the aim direction. If any enemy `Area2D` hurtbox overlaps the cone, rotate the arrow's velocity vector toward the nearest enemy by up to `max_correction_angle`. This is a one-time adjustment at spawn — the arrow then flies in a straight line.

```gdscript
# Pseudocode for aim assist
var aim_dir = (get_global_mouse_position() - global_position).normalized()
var best_target: Node2D = null
var best_angle: float = deg_to_rad(12.0)  # cone half-angle

for enemy in get_tree().get_nodes_in_group("enemies"):
    var to_enemy = (enemy.global_position - global_position).normalized()
    var angle = aim_dir.angle_to(to_enemy)
    if abs(angle) < best_angle and global_position.distance_to(enemy.global_position) < 300.0:
        best_angle = abs(angle)
        best_target = enemy

if best_target:
    var to_target = (best_target.global_position - global_position).normalized()
    var corrected = aim_dir.slerp(to_target, 0.3)  # partial correction
    var max_correction = deg_to_rad(8.0)
    if aim_dir.angle_to(corrected) > max_correction:
        corrected = aim_dir.rotated(sign(aim_dir.angle_to(to_target)) * max_correction)
    aim_dir = corrected
```

#### Input Buffering

Inputs are queued during animations or cooldowns so actions execute at the earliest possible frame. Without this, players feel like the game is "eating" their inputs.

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Buffer Window** | 0.15 sec | Inputs within this window before an action becomes available are queued |
| **Buffered Actions** | Dash, Shoot, Melee | Movement is continuous and not buffered |
| **Queue Depth** | 1 action | Only the most recent buffered input is kept |
| **Clear On** | Action executed or buffer expires | Stale inputs don't fire unexpectedly |

**How it works**: If the player presses Dash while still in a shoot animation, the dash fires on the first frame the shoot animation ends (if within the buffer window). This makes rapid action chaining feel seamless.

```gdscript
# InputBuffer singleton pattern
var _buffer: Dictionary = {}  # { action_name: timestamp }
const BUFFER_WINDOW: float = 0.15

func buffer_action(action: StringName) -> void:
    _buffer[action] = Time.get_ticks_msec() / 1000.0

func consume_action(action: StringName) -> bool:
    if action in _buffer:
        var elapsed = (Time.get_ticks_msec() / 1000.0) - _buffer[action]
        if elapsed <= BUFFER_WINDOW:
            _buffer.erase(action)
            return true
        _buffer.erase(action)
    return false
```

#### Hitbox Manipulation

Making the player's hurtbox smaller than the sprite and the arrow's hitbox larger than the sprite creates a generous "feel" — near-misses on the player don't count, but near-misses with arrows do.

| Element | Sprite Size | Collision Size | Ratio | Shape |
|---------|-------------|----------------|-------|-------|
| **Player Hurtbox** | 48x48 | 20x20 | ~42% | Circle (r=10) centered on feet |
| **Player Physical Body** | 48x48 | 24x24 | 50% | Circle (r=12) for wall collision |
| **Arrow Hitbox** | 8x16 | 14x14 | ~175% | Circle (r=7) — generous |
| **Enemy Hurtbox** | 64x64 | 48x48 | 75% | Circle — easy to hit |
| **Enemy Contact Damage** | 64x64 | 32x32 | 50% | Circle — must get close to hurt player |
| **Boss Hurtbox** | 96x96 | 80x80 | 83% | Circle — large target |
| **Boss Contact Damage** | 96x96 | 60x60 | 63% | Circle — generous for player |

> **Key insight**: The player's hurtbox (damage reception) should be strictly smaller than the player's visual sprite. The arrow hitbox (damage dealing) should be strictly larger. This asymmetry makes the player feel skilled — "I barely dodged that!" and "Great shot!" — when in reality the system is being generous on both ends.

#### Damage Invincibility (I-Frames on Hit)

After the player takes damage, they get a brief invincibility window to prevent "stun-lock" deaths that feel unfair.

| Parameter | Value |
|-----------|-------|
| **I-Frame Duration on Damage** | 0.8 sec |
| **Visual Indicator** | Player sprite flickers (toggle visible every 0.08 sec) |
| **I-Frame Duration on Dash** | Full dash duration (0.2 sec) |
| **Overlapping I-Frames** | Dash i-frames override damage i-frames; longer duration wins |

#### Dash Forgiveness Window

A grace period after taking a hit during which the player can still dash. Prevents the frustrating situation where a player reacts to damage by dashing but the hitstun has already locked them out.

| Parameter | Value |
|-----------|-------|
| **Grace Period** | 0.12 sec after taking hit |
| **Behavior** | If dash is pressed within grace period, execute dash immediately (bypasses hitstun) |

---

### Hit Feedback System (Juice) <!-- REVISED: expanded from original table -->

> **Layering Principle**: Every impact event should trigger 3-5 simultaneous feedback channels. A single arrow hitting an enemy produces: white flash (visual), knockback (physics), hitstop (time), hit SFX (audio), and camera micro-shake (screen). These layers stack to create the feeling of weight and impact.

#### Feedback Matrix

| Event | Visual | Audio | Hitstop | Camera Trauma | Knockback | Duration |
|-------|--------|-------|---------|---------------|-----------|----------|
| **Arrow → Enemy** | Enemy flashes white (1 frame), hit particle burst | Punchy impact SFX | 0.04 sec | +0.08 | 80 px in arrow direction | 0.1 sec |
| **Arrow → Enemy (Kill)** | White flash → dissolve particles, brief slow-mo | Death SFX + bass thump | 0.07 sec | +0.12 | 120 px (corpse/particles flung) | 0.15 sec |
| **Melee → Enemy** | White flash (2 frames), large hit spark, enemy squash | Heavy slash SFX | 0.08 sec | +0.15 | 150 px | 0.15 sec |
| **Melee → Enemy (Kill)** | White flash → explosion particles, slow-mo | Death SFX + heavy bass | 0.12 sec | +0.25 | 200 px (dramatic fling) | 0.2 sec |
| **Enemy → Player** | Screen red flash overlay, player sprite flashes red | Hurt grunt + impact | 0.06 sec | +0.35 | 60 px away from enemy | 0.2 sec |
| **Boss → Player** | Screen red flash (intense), chromatic aberration pulse | Heavy hurt SFX | 0.08 sec | +0.50 | 100 px | 0.25 sec |
| **Arrow → Boss** | Boss flashes white, small hit particle | Heavy impact SFX | 0.03 sec | +0.06 | 20 px (boss is heavy) | 0.1 sec |
| **Melee → Boss** | Boss flashes white (2 frames), large spark | Heavy slash on armor | 0.06 sec | +0.10 | 40 px | 0.12 sec |
| **Boss Phase Transition** | Screen flash white, boss roars, particle explosion | Roar SFX + bass drop | 0.20 sec | +0.60 | 0 (boss is stationary) | 0.5 sec |
| **Player Death** | Slow-mo (0.3 sec), screen desaturates, fade to black | Death SFX + drums fade | 0.15 sec | +0.40 | 0 | 1.5 sec total |
| **Arrow → Destructible** | Object shatters, debris particles fly outward | Pottery break / wood crack | 0.02 sec | +0.03 | N/A (object destroyed) | 0.08 sec |
| **Dash Execute** | Afterimage trail (3-4 ghost sprites), dust puff at start | Whoosh SFX | 0 | 0 | N/A | Dash duration |
| **Heal Shrine Use** | Green particle spiral upward, screen green flash | Chime + nature SFX | 0 | 0 | N/A | 0.8 sec |

#### Hitstop Implementation <!-- NEW -->

Hitstop (also called "freeze frames" or "hit pause") briefly freezes the game on impact to give visual weight to attacks. Both the attacker and the target freeze.

| Parameter | Value |
|-----------|-------|
| **Method** | `Engine.time_scale = 0.0` for duration, then restore to `1.0` |
| **Alternative Method** | Per-entity freeze via `set_physics_process(false)` (more granular) |
| **Light Hit Duration** | 0.03–0.05 sec (arrow on regular enemy) |
| **Heavy Hit Duration** | 0.06–0.10 sec (melee, kill shots) |
| **Boss Phase Transition** | 0.15–0.20 sec (dramatic pause) |
| **Slow-Mo on Kill** | `Engine.time_scale = 0.15` for 0.12 sec, then lerp back to 1.0 |
| **Stacking** | Hitstops do not stack — the longer duration wins |

> **Implementation note**: Use `Engine.time_scale` for global hitstop. Use a dedicated `HitstopManager` autoload that sets the scale, starts a `SceneTreeTimer` (which respects `process_always`), then restores it. For the timer to work during hitstop, create it with `create_timer(duration, true, false, true)` — the last `true` makes it process even when the tree is paused/slowed.

```gdscript
# HitstopManager autoload
var _active: bool = false

func freeze(duration: float) -> void:
    if _active:
        return  # don't stack, let current freeze finish
    _active = true
    Engine.time_scale = 0.0
    await get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1.0
    _active = false

func slow_mo(time_scale: float, duration: float) -> void:
    Engine.time_scale = time_scale
    await get_tree().create_timer(duration, true, false, true).timeout
    # Lerp back to normal over 0.1 sec
    var tween = create_tween()
    tween.tween_method(func(val): Engine.time_scale = val, time_scale, 1.0, 0.1)
```

#### Camera Trauma System <!-- NEW -->

Based on Squirrel Eiserloh's GDC "Math for Game Programmers" talk. Trauma is a float (0.0–1.0) that decays over time. Screen shake intensity is `trauma²` (quadratic), meaning small trauma = barely noticeable, high trauma = violent shake.

| Parameter | Value |
|-----------|-------|
| **Trauma Range** | 0.0 (no shake) to 1.0 (max shake) |
| **Trauma Decay** | `trauma = max(trauma - 3.0 * delta, 0.0)` per frame |
| **Max Shake Offset X** | 8 px |
| **Max Shake Offset Y** | 6 px |
| **Max Rotation** | 2° |
| **Shake Formula** | `offset.x = trauma² * max_x * noise.x` |
| **Noise Source** | `FastNoiseLite` (OpenSimplex2, frequency 4.0) for organic feel |

**Trauma Values Per Event:**

| Event | Trauma Added |
|-------|-------------|
| Arrow hits enemy | +0.08 |
| Arrow kills enemy | +0.12 |
| Melee hits enemy | +0.15 |
| Melee kills enemy | +0.25 |
| Player takes damage | +0.35 |
| Boss takes damage | +0.06 |
| Boss phase transition | +0.60 |
| Boss charge impact (wall) | +0.40 |
| Boss ground slam | +0.50 |
| Destructible breaks | +0.03 |

```gdscript
# Camera2D script with trauma
@export var max_offset := Vector2(8.0, 6.0)
@export var max_rotation_deg := 2.0
@export var trauma_decay := 3.0
@export var noise: FastNoiseLite

var trauma: float = 0.0
var _noise_y: float = 0.0

func add_trauma(amount: float) -> void:
    trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
    trauma = max(trauma - trauma_decay * delta, 0.0)
    var shake_intensity = trauma * trauma  # quadratic falloff
    _noise_y += 1.0
    offset = Vector2(
        max_offset.x * shake_intensity * noise.get_noise_2d(_noise_y, 0.0),
        max_offset.y * shake_intensity * noise.get_noise_2d(0.0, _noise_y)
    )
    rotation_degrees = max_rotation_deg * shake_intensity * noise.get_noise_2d(_noise_y, _noise_y)
```

#### Hit Flash Shader <!-- NEW -->

A simple shader applied to all damageable sprites that flashes them white on hit. Driven by `AnimationPlayer` or tween.

```gdshader
// hit_flash.gdshader
shader_type canvas_item;

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = mix(tex, flash_color * tex.a, flash_intensity);
}
```

**Usage**: On hit, tween `flash_intensity` from `1.0` to `0.0` over `0.08 sec`. For red flash (player damage), set `flash_color` to `vec4(1.0, 0.2, 0.2, 1.0)`.

#### Knockback & Squash/Stretch <!-- NEW -->

| Parameter | Value |
|-----------|-------|
| **Knockback Method** | Apply impulse velocity for 1 frame, then friction decays it |
| **Knockback Friction** | `velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)` |
| **Enemy Squash on Hit** | Scale to `(1.3, 0.7)` then tween back to `(1.0, 1.0)` over 0.1 sec |
| **Enemy Stretch on Death** | Scale to `(0.6, 1.4)` then dissolve |
| **Player Squash on Land** | After dash ends: scale `(1.2, 0.8)` → `(1.0, 1.0)` over 0.08 sec |
| **Arrow Stretch** | Arrows rendered at `(0.8, 1.2)` scale to feel fast |

---

## Game Structure

### Stage Design (Linear Room-Based)

Each stage consists of **7 pre-designed rooms** with increasing difficulty:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROOM FLOW DIAGRAM                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Player spawns at bottom center, portal spawns at top            │
│                                                                  │
│  ┌──────────────┐                                               │
│  │    Room 1    │  Combat: 3 Wisps + destructibles              │
│  │   ╔══════╗   │  Easy start, learn controls                   │
│  │   ║ 👻👻👻║   │  Portal → Room 2                              │
│  │   ╚══════╝   │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 2    │  Combat: 2 Wisps + 2 Crawlers                 │
│  │   ╔══════╗   │  Mixed enemies, faster pace                   │
│  │   ║👻👻👾👾║   │  Portal → Room 3                              │
│  │   ╚══════╝   │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 3    │  HEAL SHRINE                                   │
│  │   ╔══════╗   │  Interact (E) to heal 50 HP                   │
│  │   ║  💚  ║   │  Portal → Room 4 (auto-unlock)                │
│  │   ╚══════╝   │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 4    │  Combat: 2 Wisps + 2 Crawlers + 1 Stalker     │
│  │   ╔══════╗   │  Stalker teleporting enemy introduced         │
│  │   ║👻👾👻👁️║   │  Portal → Room 5                              │
│  │   ╚══════╝   │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 5    │  Combat: ALL ENEMY TYPES                       │
│  │   ╔══════╗   │  3 Crawlers + 2 Stalkers + 1 Brute            │
│  │   ║👾👾👁️👹║   │  Hardest combat room                          │
│  │   ╚══════╝   │  Portal → Room 6                              │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 6    │  HEAL SHRINE                                   │
│  │   ╔══════╗   │  Rest before boss                              │
│  │   ║  💚  ║   │  Portal → Room 7 (BOSS)                        │
│  │   ╚══════╝   │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐                                               │
│  │    Room 7    │  BOSS: SHADOW BOAR                             │
│  │   ╔══════╗   │  Enhanced version (3x HP, 2x damage)           │
│  │   ║  🐗   ║   │  Defeat = VICTORY                             │
│  │   ╚══════╝   │                                               │
│  └──────────────┘                                               │
│                                                                  │
│  Legend: 👻 Wisp  👾 Crawler  👁️ Stalker  👹 Brute  💚 Shrine    │
└─────────────────────────────────────────────────────────────────┘
```

#### Room Components

**Every Room Contains:**
- **TileLayer**: Pre-painted terrain (32x32 tiles)
- **Player Spawn**: Bottom center (y=400)
- **Portal Spawn**: Top center (y=80) - for Combat rooms
- **Destructible Props**: 3-8 breakable objects scattered around the room (<!-- NEW -->)

**Combat Rooms:**
- 3-6 Enemy spawn positions
- Portal spawns after all enemies defeated
- Destructible props serve as cover and target practice

**Heal Rooms:**
- Heal Shrine at center
- Auto-clears (no enemies)
- Portal spawns immediately
- Intact decorative props (unbroken, calmer atmosphere)

**Boss Room:**
- Single boss spawn at center-top
- No portal (victory triggers on boss death)
- Shadow pillars along edges (destructible by boss charges for dramatic effect)

### Destructible Environment <!-- NEW SECTION -->

Small breakable objects placed throughout combat rooms. These serve multiple design purposes:

1. **Target practice** — something satisfying to shoot before/between enemy waves
2. **Room dressing** — makes procedurally-decorated rooms feel hand-crafted
3. **Micro-rewards** — breaking things feels good and occasionally drops minor pickups
4. **Teaching tool** — Room 1 has pots near the spawn point, encouraging new players to shoot before enemies arrive

#### Destructible Types

| Object | HP | Visual | Break FX | Lore |
|--------|-----|--------|----------|------|
| **Ancient Clay Pot** | 1 | Small brown/terracotta pot with tribal markings | Shards fly outward (4-6 pieces), dust puff | Remnants of the old civilization |
| **Shadow Pillar** | 3 | Dark crystal/stone obelisk with faint purple glow | Shatters into dark fragments, brief shadow burst | Corrupted spirit anchors |
| **Corrupted Root** | 1 | Twisted dark vine/root cluster on ground | Snaps apart, small leaf particles | Forest corruption made physical |
| **Bone Totem** | 2 | Small animal skull on a stick with feathers | Skull pops off, feathers scatter | Shaman warning markers |

#### Destructible Drops (Rare)

| Drop | Chance | Effect |
|------|--------|--------|
| **Nothing** | 80% | Just satisfying particles |
| **Spirit Ember** | 15% | Small glowing pickup, heals 5 HP |
| **Shadow Fragment** | 5% | Visual-only collectible (future meta-progression hook) |

#### Destructible Placement Rules

- **Room 1**: 5-6 pots near player spawn (tutorial — encourages shooting)
- **Room 2-5**: 3-5 mixed destructibles at room edges and corners
- **Heal Rooms**: 2-3 intact decorative objects (bone totems, no pots — calm atmosphere)
- **Boss Room**: 4 shadow pillars at arena edges (boss can charge through them)
- **Never block paths**: Destructibles must not obstruct movement between spawn and portal

#### Technical Implementation

```
scenes/interactables/
├── destructible_pot.tscn
├── destructible_pillar.tscn
├── destructible_root.tscn
└── destructible_totem.tscn
```

Each destructible is a `StaticBody2D` with:
- `CollisionShape2D` (blocks arrows and movement)
- `Sprite2D` with hit flash shader
- `Area2D` child for detecting arrow/melee hits
- On death: spawn `GPUParticles2D` (debris), queue_free, optional drop spawn

#### Technical Structure

```
scenes/rooms/
├── room_1.tscn          # Combat: Wisps only
├── room_2.tscn          # Combat: Wisps + Crawlers
├── room_3.tscn          # Heal Shrine
├── room_4.tscn          # Combat: + Stalker
├── room_5.tscn          # Combat: All types
├── room_6.tscn          # Heal Shrine
└── room_7.tscn          # Boss Arena

resources/rooms/
├── room_1.tres          # Room config + enemy data
├── ...
└── room_7.tres          # Boss config

resources/stage_configs/
└── stage_1.tres         # Stage 1 room list
```

#### Room Manager System

The `RoomManager` handles:
1. Loading room scene (tile template)
2. Spawning enemies based on room config
3. Tracking enemy count
4. Spawning portal when room cleared
5. Transitioning to next room via portal

```gdscript
# Room data structure
class_name RoomDataResource

enum RoomType { COMBAT, HEAL_SHRINE, BOSS }

@export var room_type: RoomType
@export var room_scene: PackedScene
@export var player_spawn_position: Vector2
```

### Enemy Types: Shadow Creatures

Manifestations of Kasuari's past sins and corrupted spirits of the forbidden forest.

| Enemy | HP | Damage | Speed | Behavior |
|-------|-----|--------|-------|----------|
| **Shadow Wisp** | 25 | 10 | Slow | Floating, slow homing toward player |
| **Shadow Crawler** | 35 | 15 | Fast | Ground movement, attacks in groups of 2-3 |
| **Shadow Stalker** | 60 | 20 | Medium | Teleports every 2 sec, ambush attack |
| **Shadow Brute** | 150 | 30 | Slow | Tanky, charges player when in range |

#### Enemy Spawn Rules (Room-Based)
- Enemies spawn at **pre-defined positions** in each room
- Spawn count and type **fixed per room** (not procedural)
- Enemy waves spawn with **delays** for pacing
- **No respawning** in room-based system (enemies are permanent until killed)

#### Enemy Design Notes

- **Visual**: Dark silhouettes with glowing eyes (color indicates type)
- **Spawn**: Emerge from shadow pools on the ground
- **Death FX**: Dissolve into black particles
- **Max On Screen**: 8-10 (methodical combat)

### Boss: SHADOW BOAR

A massive boar consumed by shadow, representing untamed rage and gluttony.

| Property | Value |
|----------|-------|
| **Total HP** | 500 (scales with difficulty) |
| **Phase 2 Trigger** | 50% HP |
| **Contact Damage** | 25 |
| **Charge Damage** | 40 |
| **Shockwave Damage** | 20 |

#### Phase 1: Rampage (100%-50% HP)
- Charges across arena in straight lines
- Leaves shadow trails that damage player
- Vulnerable after charging into walls (stunned 2 sec)

#### Phase 2: Shadow Storm (50%-0% HP)
- Summons 2 Shadow Wisps every 8 seconds
- Ground slam creates expanding shadow shockwave
- Charge attacks become 30% faster

#### Design Notes
- **Visual**: Oversized boar with shadow aura, glowing red eyes, black mist emanating from body
- **Size**: 192x128 (larger than regular enemies)
- **Arena**: Generated as the final (largest) room
- **Telegraphing**: Snort + paw ground animation (1 sec) before charge
- **Destructible Interaction**: Boss charges destroy shadow pillars on contact, creating debris particles and making the arena feel dynamic (<!-- NEW -->)

---

## Visual & Audio

### Art Direction

- **Style**: Pixel Art - Chibi/SD (Super Deformed)
- **Character Proportions**: 2-3 heads tall (large head, small body)
- **Head Size**: Exaggerated (40-50% of character height)
- **Body**: Compact, stylized, cute yet menacing for enemies
- **Tile Size**: 32x32
- **Character Max Size**: 128x128 (Pixellab constraint)
- **Influences**: Tribal, Papuan indigenous art motifs, Japanese SD art style
- **Environment**: Dense jungle, ancient ruins, spiritual underworld

#### Enemy Visual Readability Rules <!-- NEW SECTION -->

> **CRITICAL RULE**: Every enemy must be instantly readable against any AI-generated background. Since backgrounds are generated by Pixellab and may vary in color/detail, enemies must carry their own visual contrast.

| Rule | Specification | Reason |
|------|--------------|--------|
| **Silhouette Test** | Every enemy must be identifiable as a solid black silhouette at 50% scale | Ensures readability even on busy backgrounds |
| **Emission Glow** | All enemies must have at least one glowing element (eyes, aura, or outline) | Guarantees visibility against dark environments |
| **Glow Color Contrast** | Enemy glow colors must be warm (red, orange) or cool (cyan) — never green or brown | Green/brown blends into jungle environments |
| **Minimum Brightness Delta** | Enemy glow pixels must be ≥ 40% brighter (luminance) than the darkest expected background tile | Prevents enemies from disappearing into shadows |
| **Outline Requirement** | All enemy sprites must have a 1px outline in a color lighter than their body fill | Creates separation from any background |
| **Eye Glow Size** | Enemy eyes must be ≥ 3x3 px for Wisps/Crawlers, ≥ 4x4 px for Stalker/Brute | Eyes are the primary identification cue |
| **Boss Aura** | Shadow Boar must have a persistent 4-8 px shadow/glow aura around body | Boss must dominate visual attention |

**Pixellab Prompt Enforcement**: When generating enemy sprites, always include these keywords:
- `"high contrast against dark backgrounds"`
- `"prominent glowing [color] eyes"`
- `"visible outline, dark but distinct from background"`

**Godot Enforcement**: Apply a `CanvasItemMaterial` with `light_mode = Light Only` or use a simple additive shader for enemy eye/glow regions to ensure they always pop visually regardless of the underlying tileset colors.

#### Technical Rendering (Godot 4.6)

| Setting | Value | Purpose |
|---------|-------|---------|
| **Pixel Snapping** | DISABLED | Allows smooth sub-pixel movement |
| **Physics Interpolation** | ENABLED | Smooth rendering between physics ticks |
| **Texture Filter** | Nearest | Keeps pixel art sharp |
| **Camera Process** | Physics callback | Syncs with player movement |

> **Note**: Pixel art is the VISUAL style only. The game uses modern smooth movement mechanics similar to Enter the Gungeon or Nuclear Throne.

#### Chibi/SD Style Guidelines

| Element | Specification |
|---------|--------------|
| **Head-to-Body Ratio** | 1:1 to 1:2 (large heads) |
| **Eyes** | Exaggerated, expressive (larger on player) |
| **Limbs** | Shorter, stubbier proportions |
| **Silhouettes** | Clear, readable shapes despite small size |
| **Expressions** | Exaggerated emotions for readability |
| **Player (Kasuari)** | Cute but fierce warrior aesthetic |
| **Enemies** | Menacing but stylized shadow creatures |
| **Boss** | Intimidating oversized chibi form |

### Color Palette

| Usage | Colors (Hex) |
|-------|-------------|
| **Kasuari Primary** | `#1a1a2e` (dark blue-black), `#16213e` (navy) |
| **Kasuari Accent** | `#e94560` (blood red), `#f1f1f1` (bone white) |
| **Shadow Enemies** | `#0f0f0f` (black), `#2d132c` (dark purple) |
| **Shadow Glow** | `#ee4540` (red glow), `#70c1b3` (cyan - rare type) |
| **Environment** | `#1e3a1e` (dark green), `#3d2914` (brown), `#1a1a2e` (night sky) |
| **UI** | `#f1f1f1` (white), `#e94560` (red accent) |
| **Destructible Props** | `#8b6914` (clay/terracotta), `#4a3728` (dark wood), `#2d132c` (shadow crystal) | <!-- NEW -->
| **Pickups** | `#70c1b3` (spirit ember glow), `#f0e68c` (warm highlight) | <!-- NEW -->

### Audio Direction

**Philosophy**: Fusion of traditional Papuan/Indonesian instruments with modern electronic beats. Intense but atmospheric.

| Layer | Style | Purpose |
|-------|-------|---------|
| **Base** | Tifa / Kendang (traditional drums) | Rhythmic foundation |
| **Melody** | Suling (bamboo flute) samples | Haunting, mystical atmosphere |
| **Intensity** | Synth bass + electronic beats | Combat energy, modern feel |
| **Accent** | Tribal vocal chants | Boss moments, high tension |

#### Audio by Game State

| State | Music Style |
|-------|-------------|
| **Exploration** | Slow tribal drums, ambient nature sounds, soft suling |
| **Combat** | Intense beat drop, synth bass, faster Tifa patterns |
| **Boss** | Full fusion - heavy drums + synth + vocal chants |
| **Victory** | Triumphant traditional melody, fading to ambient |
| **Death/Game Over** | Somber, fading drums |

#### SFX Priority List

1. Bow draw & release (satisfying "twang")
2. Arrow hit impact (differentiated: enemy hit vs. destructible hit) <!-- REVISED -->
3. Dash/dodge whoosh
4. Enemy death dissolve
5. Shadow spawn emergence
6. Boss charge telegraph
7. Destructible break (pottery shatter, crystal crack, wood snap) <!-- NEW -->
8. Hitstop impact bass thump (low-frequency punch layered under hit SFX) <!-- NEW -->
9. UI confirm/deny
10. Spirit Ember pickup chime <!-- NEW -->

---

## AI Asset Pipeline (Vibe Code)

### Asset Sources

| Asset Type | Source | Notes |
|------------|--------|-------|
| **Characters** | Pixellab | Max 128x128, use prompts below |
| **Environment Tiles** | Pixellab | 32x32 tiles, Wang tilesets |
| **Destructible Props** | Pixellab (map objects) | 32x32 or 48x48, transparent background | <!-- NEW -->
| **VFX** | Internet search | Free particle effects, sprite sheets |
| **SFX** | Internet search | Freesound.org, pixabay.com/music |
| **Music** | AI generation / Internet search | Traditional + electronic fusion |

### Pixellab Prompts - Environment Tilesets

#### Jungle Ruins Tileset (Ground + Wall Transitions)
```
Pixel art Wang tileset, top-down view,
Lower terrain: dark jungle floor with dirt, roots, fallen leaves, muted dark green brown, Papuan forest theme
Upper terrain: ancient stone ruins wall with moss and tribal carvings, dark gray green
Transition: moss-covered stone edges with scattered leaves
32x32 tiles, 16 tiles, seamless transitions, high top-down view
```

### Pixellab Prompts - Destructible Props <!-- NEW SECTION -->

#### Ancient Clay Pot
```
Pixel art game object, top-down view, high top-down,
small ancient clay pot with tribal geometric patterns, terracotta color,
muted brown and orange, clean dark outline, basic shading,
transparent background, 32x32 pixels
```

#### Shadow Pillar
```
Pixel art game object, top-down view, high top-down,
dark crystal obelisk with faint purple glow at core, corrupted stone base,
muted black and dark purple, subtle glow effect, clean outline,
transparent background, 32x48 pixels
```

#### Corrupted Root
```
Pixel art game object, top-down view, high top-down,
twisted dark vine root cluster, thorny and corrupted, dark green-black,
muted colors, organic shape, clean outline, basic shading,
transparent background, 32x32 pixels
```

#### Bone Totem
```
Pixel art game object, top-down view, high top-down,
small animal skull on wooden stick with feather decorations, tribal shaman marker,
muted bone white and brown, clean outline, basic shading,
transparent background, 32x48 pixels
```

### Character Sprite Art Style Reference

**Primary Reference: Octopath Traveler Heroes**

The character sprites should follow the art style of Octopath Traveler's playable characters:
- **Proportions**: Chibi/SD (2-3 heads tall), similar to Primrose, Therion, Olberic
- **Outlines**: Clean single-color outlines (not black, use dark variant of character color)
- **Shading**: Soft dithering, 2-3 shade levels per color, subtle highlights
- **Colors**: Muted, atmospheric palette - not oversaturated
- **Detail Level**: Moderate - readable at small sizes but not overly complex
- **Animation**: Clear key poses, readable silhouettes in motion
- **Personality**: Each character has distinctive features (hair, clothing, weapons)

### Pixellab Prompts - Characters

**IMPORTANT**: All characters use **Octopath Traveler Heroes-inspired Chibi/SD style** with clean outlines and muted colors.

#### Kasuari (Player)
```
Pixel art character sprite, top-down view, Octopath Traveler style chibi hero,
tribal warrior with cassowary-inspired armor, dark skin, black feather headdress with bone casque,
holding wooden bow, flowing grass skirt, tribal bone jewelry,
muted color palette: dark navy blue, deep black, muted blood red accents, bone white,
clean dark outline (not pure black), soft shading, 2-3 color shades per element,
4-directional rotation, idle breathing pose, 48x48 pixels, high top-down view
```

**Animation Frames Needed:**
| Animation | Frames | Size |
|-----------|--------|------|
| Idle (per direction) | 4 | 48x48 |
| Walk (per direction) | 4 | 48x48 |
| Shoot (per direction) | 3 | 48x48 |
| Dash (per direction) | 6 | 48x48 |
| Death (per direction) | 7 | 48x48 |

#### Shadow Wisp
```
Pixel art enemy sprite, top-down view, Octopath Traveler style chibi,
floating shadow orb spirit, round blob shape with wispy edges,
small glowing red eyes (minimum 3x3 pixels, high contrast),
ethereal trailing mist, visible bright outline for readability against dark backgrounds,
muted dark purple and black, prominent red glow accents,
clean dark outline, soft shading, 4-directional, 64x64 pixels
```

#### Shadow Crawler
```
Pixel art enemy sprite, top-down view, Octopath Traveler style chibi,
quadruped shadow creature, short stubby legs, hunched body,
glowing cyan eyes (minimum 3x3 pixels, high contrast against dark backgrounds),
feral but cute silhouette, visible outline for readability,
muted black and dark purple gradient, clean outline,
soft shading, 4-directional, 64x64 pixels
```

#### Shadow Stalker
```
Pixel art enemy sprite, top-down view, Octopath Traveler style chibi,
humanoid shadow figure with oversized hooded head, ethereal cloak,
large glowing white eyes (minimum 4x4 pixels, high contrast),
small body, mysterious silhouette, visible outline for readability against dark backgrounds,
muted dark purple and black, clean outline, soft shading,
4-directional, 64x64 pixels
```

#### Shadow Brute
```
Pixel art enemy sprite, top-down view, Octopath Traveler style chibi,
hulking shadow monster, large head with bulky silhouette,
small legs, slow heavy presence, glowing red eyes (minimum 4x4 pixels, high contrast),
visible bright outline for readability against dark backgrounds,
muted black with dark red accents, clean outline, soft shading,
4-directional, 64x64 pixels
```

#### Shadow Boar (Boss)
```
Pixel art boss sprite, top-down view, Octopath Traveler style chibi,
massive demonic boar, huge head with tusks, shadow aura emanating (4-8px glow around body),
glowing red eyes (minimum 5x5 pixels, intense), intimidating but stylized silhouette,
high contrast against dark backgrounds, visible outline,
muted black with dark red glow, clean outline, soft shading,
4-directional, 96x96 pixels
```

### VFX Search Keywords

| Effect | Search Terms |
|--------|--------------|
| Arrow trail | "pixel art arrow trail sprite", "projectile effect 2d" |
| Enemy death | "pixel art death particles", "enemy dissolve sprite" |
| Hit impact | "pixel art hit effect", "impact flash sprite" |
| Shadow spawn | "dark portal sprite", "summon effect pixel" |
| Boss shockwave | "shockwave sprite sheet", "ground slam effect 2d" |
| Dash trail | "dash afterimage sprite", "motion blur pixel" |
| Destructible break | "pixel art pottery break", "debris particles sprite sheet" | <!-- NEW -->
| Pickup glow | "pixel art item pickup glow", "collectible sparkle sprite" | <!-- NEW -->

### SFX Search Sources & Keywords

| Sound | Source | Search Terms |
|-------|--------|--------------|
| Bow draw | Freesound.org | "bow draw", "arrow pull" |
| Arrow release | Freesound.org | "bow release", "arrow shoot" |
| Arrow hit | Freesound.org | "arrow impact", "arrow hit flesh" |
| Dash | Freesound.org | "whoosh", "dash sound" |
| Enemy hit | Freesound.org | "hit flesh", "impact soft" |
| Enemy death | Freesound.org | "shadow dissolve", "monster death" |
| Boss charge | Freesound.org | "boar grunt", "beast roar" |
| Pottery break | Freesound.org | "pottery smash", "clay pot break" | <!-- NEW -->
| Crystal shatter | Freesound.org | "crystal break", "glass shatter small" | <!-- NEW -->
| Pickup chime | Freesound.org | "item pickup chime", "collect sound" | <!-- NEW -->
| Hitstop thump | Freesound.org | "bass impact", "low thump hit" | <!-- NEW -->
| UI click | Freesound.org | "menu click", "ui select" |

---

## Technical Specifications

### Built With

- **Engine**: Godot 4.6 (2D)
- **Physics**: Godot Physics 2D
- **Language**: GDScript

### Godot Node Architecture <!-- NEW SECTION -->

Recommended node structures and patterns for key game systems.

#### Player Scene Tree

```
Player (CharacterBody2D)
├── CollisionShape2D           # Physical body (wall collision, r=12)
├── HurtboxArea (Area2D)       # Damage reception (r=10, SMALLER than sprite)
│   └── CollisionShape2D
├── Sprite2D                   # Player sprite with hit_flash.gdshader material
│   └── ShaderMaterial         # hit_flash.gdshader (flash_intensity, flash_color)
├── AnimationPlayer            # Drives sprite frames AND shader parameters
├── AnimationTree              # State machine: Idle → Walk → Shoot → Dash
├── DashTrailTimer (Timer)     # Spawns afterimage sprites during dash
├── ShootCooldownTimer (Timer) # 0.5 sec fire rate
├── DashCooldownTimer (Timer)  # 1.0 sec dash cooldown
├── IFrameTimer (Timer)        # 0.8 sec damage invincibility
├── FlickerTimer (Timer)       # 0.08 sec toggle visibility during i-frames
├── InputBufferComponent       # Custom node: tracks buffered inputs
├── ArrowSpawnPoint (Marker2D) # Rotates with aim direction
└── AudioStreamPlayer2D        # Positional SFX (bow, dash, hurt)
```

#### Enemy Scene Tree

```
BaseEnemy (CharacterBody2D)
├── CollisionShape2D           # Physical body
├── HurtboxArea (Area2D)       # Takes damage (generous hitbox)
│   └── CollisionShape2D
├── DamageArea (Area2D)        # Deals contact damage (smaller than hurtbox)
│   └── CollisionShape2D
├── Sprite2D                   # Enemy sprite with hit_flash.gdshader
│   └── ShaderMaterial         # hit_flash.gdshader
├── GlowSprite (Sprite2D)     # Eyes/aura layer with additive blend ← NEW
│   └── CanvasItemMaterial     # blend_mode = Add (always visible)
├── AnimationPlayer            # Hit flash, death dissolve, idle bob
├── NavigationAgent2D          # Pathfinding to player (or simple steering)
├── DetectionArea (Area2D)     # Aggro range
├── StateChart / StateMachine  # Idle → Chase → Attack → Stagger → Death
└── AudioStreamPlayer2D        # Enemy SFX
```

#### Camera Scene Tree

```
GameCamera (Camera2D)
├── Script: camera_trauma.gd   # Trauma system (see Camera Trauma System section)
├── FastNoiseLite (Resource)   # Noise for organic shake (OpenSimplex2, freq 4.0)
├── ScreenFlash (ColorRect)    # Full-screen color overlay for hit/heal effects
│   └── ShaderMaterial         # screen_flash.gdshader (color, intensity, fade)
└── Note: Follow target set via script, not as child of Player
```

> **Camera Note**: The camera should NOT be a child of the Player node. Instead, it should be a sibling in the scene tree that follows the player via script (`global_position = lerp(global_position, target, weight * delta)`). This decoupling allows the camera to add look-ahead, trauma shake, and easing independently without inheriting player transforms.

#### Arrow Scene Tree

```
Arrow (Area2D)                 # Area2D, not RigidBody — simpler and more controllable
├── CollisionShape2D           # Circle r=7 (LARGER than visual, generous hitbox)
├── Sprite2D                   # Arrow sprite, stretched (0.8, 1.2) for speed feel
├── GPUParticles2D             # Trail particles (small, fading white/yellow dots)
├── VisibleOnScreenNotifier2D  # Auto-despawn when off screen
└── AudioStreamPlayer2D        # Travel whoosh (looping, quiet)
```

#### Destructible Scene Tree <!-- NEW -->

```
Destructible (StaticBody2D)
├── CollisionShape2D           # Blocks movement and arrows
├── HitArea (Area2D)           # Detects arrow/melee overlap
│   └── CollisionShape2D
├── Sprite2D                   # Intact prop with hit_flash.gdshader
│   └── ShaderMaterial
├── AnimationPlayer            # Hit flash animation
├── BreakParticles (GPUParticles2D)  # Debris on death (emitting=false, one_shot=true)
└── BreakSFX (AudioStreamPlayer2D)   # Break sound
```

#### HitstopManager (Autoload) <!-- NEW -->

```
HitstopManager (Node)
├── Script: hitstop_manager.gd
└── Purpose: Global time_scale manipulation for freeze frames and slow-mo
```

#### Key AnimationPlayer Tracks <!-- NEW -->

The `AnimationPlayer` on damageable entities should include these reusable animation tracks:

| Animation Name | Tracks | Duration | Notes |
|----------------|--------|----------|-------|
| `hit_flash` | `Sprite2D:material:shader_parameter/flash_intensity` → 1.0 to 0.0 | 0.08 sec | Triggered on any damage received |
| `hit_flash_red` | Same as above but `flash_color` = red | 0.12 sec | Player-only, on taking damage |
| `death_dissolve` | `Sprite2D:modulate:a` → 1.0 to 0.0, scale → (0.6, 1.4) | 0.4 sec | Enemy death, combined with particles |
| `idle_bob` | `Sprite2D:position:y` → sine wave ±2px | 0.8 sec (loop) | Floating enemies (Wisp) |
| `spawn_emerge` | `Sprite2D:scale` → (0,0) to (1.1, 0.9) to (1,1) | 0.3 sec | Squash/stretch on spawn |

### Player Stats

| Property | Value |
|----------|-------|
| **Max HP** | 100 |
| **Move Speed** | 200 px/sec |
| **Dash Speed** | 400 px/sec |
| **Dash Duration** | 0.2 sec |
| **Dash Cooldown** | 1.0 sec |
| **Dash I-Frames** | Full dash duration (0.2 sec) |
| **Damage I-Frames** | 0.8 sec (with sprite flicker) | <!-- NEW -->
| **Melee Damage** | 35 |
| **Melee Range** | 64 px |
| **Input Buffer Window** | 0.15 sec | <!-- NEW -->
| **Dash Forgiveness Window** | 0.12 sec after taking hit | <!-- NEW -->

### Performance Targets

| Target | Value |
|--------|-------|
| **Frame Rate** | 60 FPS stable |
| **Max Enemies On Screen** | 10 (methodical combat) |
| **Max Destructibles Per Room** | 8 |  <!-- NEW -->
| **Max Particles Simultaneous** | 200 (GPUParticles2D pooling) | <!-- NEW -->
| **Resolution** | 1920x1080 (scalable) |
| **Viewport** | 480x270 (pixel perfect, 4x scale) |
| **Stage Generation Time** | < 100ms |

### In-Game HUD Design (MVP)

> **Design Philosophy**: The HUD should be nearly invisible during gameplay. Dark, translucent elements that only draw attention when the player's state changes (HP loss, cooldown ready, room transition). No bright borders, no unnecessary chrome. The jungle and combat should dominate the screen — the HUD whispers, it doesn't shout.

#### HUD Layout (480x270 Viewport)

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  ┌─ TOP LEFT ──────────┐            ┌─ TOP RIGHT ──────────┐  │
│  │ ❤ ████████████░░░░  │            │   ● ● ● ○ ○ ○ ○      │  │
│  │   72/100 HP         │            │   Room 3 / 7          │  │
│  │ ◈ ███████░░░  Dash  │            └──────────────────────┘  │
│  └─────────────────────┘                                      │
│                                                                │
│                          -25          (floating dmg numbers)   │
│                               -10                              │
│                                                                │
│                        ╔═══════════╗                           │
│                        ║   [E]     ║  (contextual prompt)     │
│                        ║  Interact ║                           │
│                        ╚═══════════╝                           │
│                                                                │
│                                                                │
│  ┌─ BOTTOM CENTER (Boss room only) ──────────────────────┐    │
│  │  SHADOW BOAR   ████████████████████░░░░░░░░  250/500  │    │
│  └───────────────────────────────────────────────────────┘    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

#### 1. Player Health Bar

| Property | Value |
|----------|-------|
| **Position** | Top-left, 8px from edges |
| **Size** | 80 x 8 px (viewport pixels) |
| **Background** | `#1a1a2e` at 60% opacity (dark navy, nearly invisible) |
| **Fill Color** | `#e94560` (blood red — from palette) |
| **Low HP Color** | `#ff2040` (brighter red, pulses when ≤ 25 HP) |
| **Low HP Pulse** | Sine wave modulate alpha: `0.6 + 0.4 * sin(time * 6.0)` |
| **Damage Flash** | On HP loss: a trailing ghost bar in `#f1f1f1` (white) shrinks to match new HP over 0.4 sec (shows damage taken) |
| **Heal Flash** | On HP gain: fill bar expands instantly, brief green tint `#70c1b3` for 0.2 sec |
| **Border** | 1px outline in `#0f0f0f` (subtle, not bright) |
| **Text** | None by default. Optional: small `72/100` text in `#f1f1f1` only appears for 1.5 sec after HP changes, then fades |
| **Font** | Pixel font, 5px height (viewport scale) |

**Godot Node**:
```
HUD (CanvasLayer, layer=10)
└── HealthBar (Control)
    ├── BarBackground (ColorRect)        # #1a1a2e, 60% alpha
    ├── DamageTrail (ColorRect)          # #f1f1f1, tweens width on damage
    ├── BarFill (ColorRect)              # #e94560, width = (current_hp / max_hp) * 80
    ├── BarBorder (NinePatchRect)        # 1px #0f0f0f outline
    └── HPText (Label)                   # Optional, fades in/out
```

#### 2. Dash Cooldown Indicator

| Property | Value |
|----------|-------|
| **Position** | Below health bar, 8px from left, 18px from top |
| **Size** | 48 x 4 px (smaller and thinner than HP bar) |
| **Background** | `#1a1a2e` at 40% opacity |
| **Fill Color (Charging)** | `#16213e` (dark navy — muted while recharging) |
| **Fill Color (Ready)** | `#70c1b3` (cyan) — brief 0.15 sec flash then fades to invisible |
| **Fill Direction** | Left to right, proportional to `(cooldown_elapsed / 1.0)` |
| **Ready State** | Bar flashes cyan, then the entire bar fades to 0% opacity over 0.3 sec (invisible when ready — no clutter) |
| **Cooldown Active** | Bar fades in to 40% opacity, fills left-to-right over 1.0 sec |
| **Icon** | Small 5x5 diamond glyph `◈` to the left of the bar in `#f1f1f1` at 50% opacity |

> **Why this works**: The dash bar is only visible when the dash is on cooldown. When ready, it vanishes. This keeps the screen clean during normal gameplay while giving clear feedback during combat when the player is waiting for their dash.

**Godot Node**:
```
HUD (CanvasLayer)
└── DashCooldown (Control)
    ├── DashIcon (TextureRect)           # Small diamond/dash icon
    ├── DashBarBG (ColorRect)            # #1a1a2e, 40% alpha
    └── DashBarFill (ColorRect)          # Width tweened over cooldown duration
```

#### 3. Room Progress Indicator

| Property | Value |
|----------|-------|
| **Position** | Top-right, 8px from edges |
| **Style** | 7 small circles in a horizontal row (one per room) |
| **Circle Size** | 5 x 5 px each, 3px gap between |
| **Completed Room** | Filled circle `●` in `#f1f1f1` (white) |
| **Current Room** | Filled circle `●` in `#e94560` (red) with slow pulse (alpha 0.7–1.0) |
| **Future Room** | Hollow circle `○` in `#f1f1f1` at 30% opacity |
| **Boss Room (7th)** | Slightly larger circle (7x7 px), `#ee4540` (red glow) when current |
| **Transition Animation** | On room change: current dot scales up 150% → back to 100% over 0.2 sec |
| **Heal Room Indicator** | Rooms 3 and 6 have a subtle green tint `#70c1b3` when completed |

```
Example: Player is in Room 4

  ● ● ●̃ ◉ ○ ○̃ ○
  1 2 3  4  5 6 7
  ↑     ↑        ↑
  done  current  boss (larger)

  ●̃ = completed heal room (green tint)
  ○̃ = future heal room (green tint, dimmed)
```

**Godot Node**:
```
HUD (CanvasLayer)
└── RoomProgress (HBoxContainer)
    ├── RoomDot1 (TextureRect)           # Swap between filled/hollow/pulse textures
    ├── RoomDot2 (TextureRect)
    ├── RoomDot3 (TextureRect)           # Heal room: green tint
    ├── RoomDot4 (TextureRect)
    ├── RoomDot5 (TextureRect)
    ├── RoomDot6 (TextureRect)           # Heal room: green tint
    └── RoomDot7 (TextureRect)           # Larger, boss indicator
```

#### 4. Contextual Interaction Prompts

Floating prompts that appear above interactable objects when the player is within interaction range. They do not exist on the HUD layer — they are world-space UI.

| Property | Value |
|----------|-------|
| **Trigger Distance** | 48 px from interactable center |
| **Position** | 16 px above the interactable sprite, world-space |
| **Style** | `[E]` text in `#f1f1f1` with 1px `#0f0f0f` shadow |
| **Sub-label** | Smaller text below: `"Heal"`, `"Enter"`, etc. in `#f1f1f1` at 60% opacity |
| **Font Size** | Key label: 7px, sub-label: 5px (viewport scale) |
| **Appear Animation** | Fade in (0→1 alpha over 0.15 sec) + float up 4px |
| **Disappear Animation** | Fade out (1→0 alpha over 0.1 sec) |
| **Idle Animation** | Gentle vertical bob: ±1px sine wave, period 1.5 sec |
| **Background** | None — text only with drop shadow. Keeps it lightweight. |

**Prompt Variants:**

| Interactable | Key Label | Sub-label | Notes |
|-------------|-----------|-----------|-------|
| **Heal Shrine** | `[E]` | `Heal` | Green tint `#70c1b3` on sub-label. Disappears after use. |
| **Portal (Active)** | `[E]` | `Enter` | Only shows when portal is active (enemies cleared) |
| **Portal (Locked)** | — | `Defeat all enemies` | No key prompt. Red-tinted `#e94560` text. Shown briefly on first approach, then hides. |

**Godot Node** (on each interactable scene, not on HUD):
```
HealShrine (StaticBody2D)
├── ...existing nodes...
└── InteractPrompt (Control)
    ├── KeyLabel (Label)                 # "[E]" — pixel font
    └── ActionLabel (Label)              # "Heal" — smaller, dimmer
```

> **Why world-space**: Contextual prompts should float above the object they refer to, not be pinned to a screen corner. This keeps the player's eyes on the action instead of scanning HUD edges for information.

#### 5. Boss Health Bar

Only visible in Room 7 during the Shadow Boar fight. Dominates the bottom of the screen to convey boss significance.

| Property | Value |
|----------|-------|
| **Position** | Bottom-center, 12px from bottom edge |
| **Size** | 240 x 10 px (half the viewport width — large and prominent) |
| **Background** | `#1a1a2e` at 80% opacity |
| **Fill Color** | `#ee4540` (red glow) |
| **Phase 2 Fill** | `#2d132c` (dark purple) — color shifts at 50% HP to signal phase change |
| **Damage Trail** | White ghost bar `#f1f1f1` that trails behind on damage (same as player HP bar, 0.6 sec drain) |
| **Border** | 2px outline in `#0f0f0f` (thicker than player HP — more imposing) |
| **Boss Name** | `"SHADOW BOAR"` label centered above the bar in `#f1f1f1`, 7px font |
| **Name Font Style** | ALL CAPS, slight letter spacing (+1px) |
| **Appear Animation** | On boss room enter: slides up from below viewport over 0.5 sec with ease-out. Name fades in 0.3 sec after bar arrives. |
| **Phase Transition FX** | At 50% HP: bar flashes white, screen shake, fill color transitions from red → purple over 0.3 sec |
| **Defeat Animation** | Bar shatters into particles (reuse destructible break FX), slides down off screen |

**Godot Node**:
```
HUD (CanvasLayer)
└── BossHealthBar (Control, visible=false)    # Toggled on by EventBus signal
    ├── BossName (Label)                      # "SHADOW BOAR"
    ├── BarBackground (ColorRect)             # #1a1a2e, 80% alpha
    ├── DamageTrail (ColorRect)               # #f1f1f1, width tweens on damage
    ├── BarFill (ColorRect)                   # #ee4540 → #2d132c at phase 2
    ├── BarBorder (NinePatchRect)             # 2px #0f0f0f outline
    └── AnimationPlayer                       # Enter, phase_transition, defeat anims
```

#### 6. Floating Damage Numbers

Numbers that pop out of enemies (or the player) on every hit. Adds a layer of responsive feedback and lets the player visually track their damage output.

| Property | Value |
|----------|-------|
| **Spawn Position** | At the hit point (collision location), not entity center |
| **Initial Offset** | Random ±8 px horizontal to prevent overlap on rapid hits |
| **Float Direction** | Upward, 40 px over lifetime |
| **Float Curve** | Ease-out (fast initial rise, decelerates) |
| **Lifetime** | 0.6 sec |
| **Fade** | Alpha 1.0 → 0.0 over final 0.3 sec of lifetime |
| **Font** | Pixel font, bold |
| **Scale Pop** | Spawns at 150% scale, tweens to 100% over first 0.1 sec (punch-in effect) |

**Damage Number Variants:**

| Context | Text | Color | Size | Extra FX |
|---------|------|-------|------|----------|
| **Arrow → Enemy** | `"-25"` | `#f1f1f1` (white) | 6px | None |
| **Melee → Enemy** | `"-35"` | `#f0e68c` (warm yellow) | 7px | Slightly larger — melee feels heavier |
| **Arrow → Boss** | `"-25"` | `#f1f1f1` (white) | 5px | Smaller against boss (boss is tanky) |
| **Melee → Boss** | `"-35"` | `#f0e68c` (warm yellow) | 6px | None |
| **Enemy → Player** | `"-15"` | `#e94560` (blood red) | 7px | Floats down instead of up (differentiates from dealt damage) |
| **Boss → Player** | `"-40"` | `#ff2040` (bright red) | 8px | Floats down, slight screen shake stacks with camera trauma |
| **Heal Shrine** | `"+50"` | `#70c1b3` (cyan/green) | 8px | Floats up with sparkle particles |
| **Spirit Ember Pickup** | `"+5"` | `#70c1b3` (cyan/green) | 5px | Smaller, subtle |

> **Readability rule**: Damage-dealt numbers float UP (white/yellow). Damage-taken numbers float DOWN (red). Healing numbers float UP (green). This directional convention lets the player instantly distinguish good from bad without reading the number.

**Godot Implementation**:

Damage numbers are spawned as independent scenes (not children of the damaged entity, since enemies may die mid-float). Spawn them as children of a persistent `DamageNumberLayer` node.

```
DamageNumber (Node2D)                        # Instanced per hit, self-freeing
├── Label (Label)                            # The number text
│   └── LabelSettings                        # Font, size, color, outline
└── Script: damage_number.gd                 # Handles float, fade, self queue_free
```

```gdscript
# damage_number.gd
extends Node2D

@export var float_distance: float = 40.0
@export var lifetime: float = 0.6
@export var float_up: bool = true  # false for damage-taken (floats down)

func setup(value: int, color: Color, font_size: int, is_heal: bool = false) -> void:
    var label := $Label as Label
    label.text = ("+%d" if is_heal else "-%d") % abs(value)
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", font_size)

    # Random horizontal offset to avoid stacking
    position.x += randf_range(-8.0, 8.0)

    # Scale pop: 150% → 100%
    scale = Vector2(1.5, 1.5)
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

    # Float up or down
    var direction := -1.0 if float_up else 1.0
    tween.parallel().tween_property(self, "position:y",
        position.y + (float_distance * direction), lifetime
    ).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

    # Fade out during final half
    tween.tween_property(label, "modulate:a", 0.0, lifetime * 0.5).set_delay(lifetime * 0.5)

    # Self-destruct
    tween.tween_callback(queue_free)
```

**Spawn helper** (in a DamageNumberManager autoload or utility):
```gdscript
const DamageNumberScene = preload("res://scenes/ui/damage_number.tscn")

func spawn_damage_number(pos: Vector2, value: int, type: StringName) -> void:
    var instance = DamageNumberScene.instantiate()
    get_tree().current_scene.get_node("DamageNumberLayer").add_child(instance)
    instance.global_position = pos

    match type:
        &"arrow_hit":
            instance.setup(value, Color("#f1f1f1"), 6)
        &"melee_hit":
            instance.setup(value, Color("#f0e68c"), 7)
        &"player_hurt":
            instance.setup(value, Color("#e94560"), 7)
            instance.float_up = false
        &"boss_hurt_player":
            instance.setup(value, Color("#ff2040"), 8)
            instance.float_up = false
        &"heal":
            instance.setup(value, Color("#70c1b3"), 8, true)
        &"ember_pickup":
            instance.setup(value, Color("#70c1b3"), 5, true)
```

#### HUD Scene Tree Summary

```
HUD (CanvasLayer, layer=10, process_mode=ALWAYS)
├── HealthBar (Control)
│   ├── BarBackground (ColorRect)
│   ├── DamageTrail (ColorRect)
│   ├── BarFill (ColorRect)
│   ├── BarBorder (NinePatchRect)
│   ├── HPText (Label)
│   └── AnimationPlayer                     # Low HP pulse, damage flash, heal flash
├── DashCooldown (Control)
│   ├── DashIcon (TextureRect)
│   ├── DashBarBG (ColorRect)
│   ├── DashBarFill (ColorRect)
│   └── AnimationPlayer                     # Ready flash, fade in/out
├── RoomProgress (HBoxContainer)
│   ├── RoomDot1–7 (TextureRect)
│   └── AnimationPlayer                     # Room transition dot scale pulse
├── BossHealthBar (Control, visible=false)
│   ├── BossName (Label)
│   ├── BarBackground (ColorRect)
│   ├── DamageTrail (ColorRect)
│   ├── BarFill (ColorRect)
│   ├── BarBorder (NinePatchRect)
│   └── AnimationPlayer                     # Slide-in, phase transition, defeat
└── DamageNumberLayer (Node2D)              # Container for floating numbers
```

> **process_mode = ALWAYS**: The HUD CanvasLayer must use `process_mode = ALWAYS` so it remains visible and updating during hitstop (when `Engine.time_scale = 0`). Damage numbers should also process during slow-mo so they don't freeze awkwardly mid-float.

#### HUD File Structure

```
scenes/ui/
├── hud.tscn                    # Main HUD scene (CanvasLayer)
├── health_bar.tscn             # Player HP bar (reusable)
├── dash_cooldown.tscn          # Dash indicator
├── room_progress.tscn          # 7-dot room tracker
├── boss_health_bar.tscn        # Boss HP bar
└── damage_number.tscn          # Instanced per hit

scripts/ui/
├── hud.gd                      # Listens to EventBus signals, delegates to children
├── health_bar.gd               # Tween logic for fill, trail, pulse
├── dash_cooldown.gd            # Show/hide based on cooldown state
├── room_progress.gd            # Updates dots on room_changed signal
├── boss_health_bar.gd          # Show/hide, phase transition FX
└── damage_number.gd            # Float, fade, self-destruct
```

#### EventBus Signals for HUD

The HUD listens to global signals — it never polls or references game nodes directly.

```gdscript
# In EventBus autoload — add these signals
signal player_health_changed(current_hp: int, max_hp: int)
signal player_dash_started(cooldown_duration: float)
signal player_dash_ready()
signal room_changed(room_index: int, total_rooms: int)
signal boss_spawned(boss_name: String, boss_hp: int, boss_max_hp: int)
signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_phase_changed(phase: int)
signal boss_defeated()
signal damage_dealt(position: Vector2, amount: int, type: StringName)
signal damage_taken(position: Vector2, amount: int, type: StringName)
signal player_healed(position: Vector2, amount: int)
```

### Scope: First Iteration (MVP)

**What's IN:**
- 1 playable character (Kasuari) with bow & arrow + dash + melee
- 4 enemy types (Shadow creatures)
- 1 boss (Shadow Boar with 2 phases)
- **Linear room progression** (7 rooms per stage)
- **Portal system** (clear enemies → spawn portal → next room)
- **Heal shrines** (interact to restore HP)
- **HP persistence** across rooms
- **In-game HUD**: Health bar, dash cooldown, room progress, boss HP bar, contextual [E] prompts, floating damage numbers
- Hit feedback system (flash, shake, hitstop)
- **Aim assist / soft magnetism** (invisible) <!-- NEW -->
- **Input buffering** (dash, shoot, melee) <!-- NEW -->
- **Hitbox manipulation** (generous for player) <!-- NEW -->
- **Destructible environment props** (pots, pillars, roots, totems) <!-- NEW -->
- **Hitstop / freeze frames** on heavy impacts <!-- NEW -->
- **Camera trauma system** with noise-based shake <!-- NEW -->
- Main menu (New Run, Quit)
- Pause menu (Resume, Quit Run)
- Game over screen (Try Again, Quit)
- Victory screen (Continue, Quit)

**What's OUT (for now):**
- Multiple stages/biomes
- Permanent upgrades/meta progression
- Seed sharing / Daily challenge
- Multiple weapons
- Dialogue/story cutscenes
- Environmental hazards
- Collectibles (beyond spirit embers)
- Arrow count (infinite ammo)
- Leaderboards
- Gamepad rumble/haptics
- Accessibility options menu (text size, colorblind modes — post-MVP)

---

## Development Roadmap

### Phase 1: Foundation ✅
- [x] Project structure setup (folders, autoloads)
- [x] Pixel perfect camera setup (480x270 viewport)
- [x] Smooth follow camera
- [x] Player movement (8-directional, 200 px/sec)
- [x] Player aiming (mouse direction)
- [x] Bow & arrow shooting (0.5 sec fire rate, infinite)

### Phase 2: Player Polish ✅
- [x] Dash/dodge (400 px/sec, 0.2 sec, 1.0 sec cooldown)
- [x] I-frames system (0.2 sec dash, 0.8 sec on-hit)
- [x] Melee attack (35 damage, 64 px range)
- [x] Player health system (100 HP)
- [x] Player death & respawn
- [x] Player hit feedback (hit flash shader, screen shake)
- [x] Input buffering system (0.15 sec window)
- [x] Dash forgiveness window (0.12 sec post-hit)
- [x] Aim assist / soft magnetism (12° cone, 8° max correction)
- [x] Hitbox restructure (player hurtbox r=10, body r=12, arrow r=7)
- [x] EventBus dash signals (player_dash_started, player_dash_ready)

### Phase 3: Enemies ✅
- [x] Base enemy class (HP, damage, speed, behavior)
- [x] Shadow Wisp (25 HP, slow homing)
- [x] Shadow Crawler (40 HP, fast, groups)
- [x] Shadow Stalker (60 HP, teleport every 2 sec)
- [x] Shadow Brute (150 HP, charge attack)
- [x] Enemy spawn system
- [x] Enemy hit feedback (flash white, knockback)
- [x] Enemy death (dissolve particles)

### Phase 4: Boss ✅
- [x] Boss arena scene (Room 7, 21x15 tiles)
- [x] Shadow Boar base (500 HP, state machine AI)
- [x] Phase 1: Charge attack, shadow trails, wall stun
- [x] Phase 2 trigger (250 HP, invulnerable transition, 50% size increase)
- [x] Phase 2: Wisp summon, shockwave, faster charges
- [x] Boss health bar UI (slide-in, phase color change, fade-out)
- [x] Boss death → victory trigger

### Phase 5: Linear Room System ✅
- [x] Pixellab tileset generation
- [x] TileSet converter with collision
- [x] RoomDataResource class
- [x] LinearStageConfig class
- [x] RoomManager implementation
- [x] Portal system (spawn on room clear)
- [x] Portal interaction (E to travel)
- [x] Heal Shrine interactable
- [x] HP persistence across rooms
- [x] Room 1 template and testing
- [x] Rooms 2-7 templates (all 7 rooms in RoomBlueprints with ASCII maps)
- [x] Full stage flow test (manual — Rooms 1-7 progression, boss, victory)
- [x] Room transition VFX (black fade overlay, 0.3s tween)
- [x] Static obstacle props in rooms (pillar StaticBody2D at O markers)

### Phase 6: Roguelite System ✅
- [x] RunManager implementation (start_run, end_run, seed management)
- [x] Run statistics tracking (enemies killed, damage taken, time elapsed)
- [x] Game flow integration (Main Menu → Game → Victory/Game Over → Retry/New Run/Menu)
- [ ] Progressive difficulty scaling (post-MVP — no scaling between runs yet)

### Phase 7: UI & Menus
- [x] In-game HUD (basic health, room indicator)
- [x] **HUD: Player Health Bar** — Damage trail, low-HP pulse, heal flash
- [x] **HUD: Dash Cooldown** — Fill bar, ready flash, auto-hide when ready
- [x] **HUD: Room Progress** — 7-dot indicator with pulse on room change
- [x] **HUD: Boss Health Bar** — Slide-in, phase transition FX, defeat shatter
- [x] **HUD: Contextual [E] Prompts** — World-space float above shrines/portals
- [x] **HUD: Floating Damage Numbers** — Per-hit spawn, color-coded, directional float
- [x] **HUD: EventBus Integration** — Wire all HUD signals (health, dash, room, boss, damage)
- [x] Main menu (New Run, Quit)
- [x] Pause menu
- [x] Game over screen
- [x] Victory screen

### Phase 8: Polish & Juice <!-- REVISED: significantly expanded -->
- [x] **Camera Trauma System**: Implement noise-based shake with quadratic falloff
- [x] **Camera Look-Ahead**: 40 px offset in aim direction with smooth lerp
- [x] **Hitstop Manager**: Autoload with freeze frame and slow-mo support
- [x] **Hit Flash Shader**: `hit_flash.gdshader` on all enemy + player sprites
- [x] **Screen Flash Effects**: Red overlay (player hit), white flash (boss transition), green pulse (heal)
- [x] **Knockback Polish**: Impulse-based knockback with friction decay
- [x] **Squash/Stretch**: Enemy hit squash, death stretch, player dash landing
- [x] **Dash Afterimages**: Trail of 3-4 fading ghost sprites during dash
- [x] **Arrow Trail**: `GPUParticles2D` on arrows (small fading dots)
- [x] **Destructible Props**: All 4 types implemented with break FX and particles
- [x] **Enemy Glow Layer**: Additive blend sprite for eyes/aura on all enemies
- [x] **Portal VFX**: Idle shimmer, activation burst, travel warp
- [x] **Heal Shrine VFX**: Green particle spiral, screen green pulse on use
- [x] **Spawn Emerge VFX**: Squash/stretch scale animation on enemy spawn
- [x] **Kill Slow-Mo**: Brief `time_scale = 0.15` on last enemy killed in room
- [x] **SFX Implementation**: All priority sounds (bow, hit, death, break, UI)
- [x] **Music Implementation**: Exploration, combat, boss tracks with crossfade
- [x] **Balancing Pass**: Test all damage, HP, speed, and forgiveness values

---

## Appendix: Change Summary <!-- NEW SECTION -->

This section documents what was added or revised from the original GDD to elevate game feel, juice, and accessibility.

### New Sections Added
1. **Game Feel & Juice** — Top-level section establishing the design philosophy for feedback and polish
2. **Forgiveness & Accessibility Systems** — Aim assist, input buffering, hitbox manipulation, dash forgiveness
3. **Hitstop Implementation** — Freeze frame system with `Engine.time_scale` and `HitstopManager` autoload
4. **Camera Trauma System** — Squirrel Eiserloh-style trauma with quadratic shake and noise
5. **Hit Flash Shader** — GLSL shader for white/red flash on damage with AnimationPlayer integration
6. **Knockback & Squash/Stretch** — Physics-based knockback and sprite deformation for weight
7. **Destructible Environment** — 4 prop types with HP, break FX, rare drops, and placement rules
8. **Enemy Visual Readability Rules** — Contrast, glow, and silhouette requirements for AI-generated sprites
9. **Godot Node Architecture** — Detailed scene tree recommendations for Player, Enemy, Camera, Arrow, Destructible, and HitstopManager
10. **Key AnimationPlayer Tracks** — Reusable animation definitions for hit flash, death dissolve, idle bob, spawn
11. **In-Game HUD Design (MVP)** — Complete HUD spec: health bar (damage trail, low-HP pulse), dash cooldown (auto-hide), room progress (7-dot), boss health bar (phase transition FX), contextual [E] prompts (world-space), floating damage numbers (color-coded, directional), full scene tree, file structure, and EventBus signals

### Revised Sections
1. **Camera System** — Added look-ahead (40 px), trauma-based shake, specific lerp values
2. **Hit Feedback System** — Expanded from 5-row table to 13-row feedback matrix with hitstop durations, trauma values, and knockback distances
3. **Room Components** — Added destructible props to every room type description
4. **Boss Design Notes** — Added destructible interaction (boss charges destroy shadow pillars)
5. **Pixellab Character Prompts** — Added visual readability keywords (high contrast, minimum eye size, visible outline)
6. **Color Palette** — Added destructible and pickup colors
7. **SFX Priority List** — Expanded from 7 to 10 entries (destructible, hitstop, pickup sounds)
8. **Player Stats** — Added damage i-frames (0.8s), input buffer (0.15s), dash forgiveness (0.12s)
9. **Performance Targets** — Added max destructibles (8) and max particles (200)
10. **MVP Scope** — Added 6 new items to "What's IN" (aim assist, input buffering, hitbox manipulation, destructibles, hitstop, camera trauma); replaced basic HUD line with detailed HUD element list
11. **Development Roadmap Phase 2** — Added input buffering, dash forgiveness, aim assist tasks
12. **Development Roadmap Phase 5** — Added destructible placement task
13. **Development Roadmap Phase 7** — Expanded from 5 items to 12 with dedicated HUD sub-tasks
14. **Development Roadmap Phase 8** — Expanded from 8 to 18 detailed polish tasks with specific system names

---

## Changelog

| Date | Changes |
|------|---------|
| 2026-02-17 | Initial GDD creation |
| 2026-02-17 | Updated: 2D pixel art, bow & arrow weapon |
| 2026-02-17 | Added: Enemy types, Shadow Boar boss, audio direction, MVP scope, detailed roadmap |
| 2026-02-17 | Completed: Player stats, enemy stats, boss stats, arrow system, camera system, color palette, AI asset pipeline (Pixellab prompts), VFX/SFX search keywords, hit feedback system, pixel perfect viewport |
| 2026-02-19 | **MAJOR UPDATE**: Changed genre to Roguelite, added procedural stage generation system (BSP), seed-based runs, daily challenge mode, progressive difficulty. |
| 2026-02-20 | **MAJOR PIVOT**: Replaced procedural BSP generation with **linear room-based progression** (Hades/Cult of the Lamb style). Added: RoomManager, Portal system, Heal Shrines, HP persistence across rooms. Removed: Procedural generation, seed system, daily challenge. Updated: Gameplay loop, stage design, room configuration, GDD structure. |
| 2026-02-21 | **GAME FEEL OVERHAUL**: Added forgiveness systems (aim assist, input buffering, hitbox manipulation, dash forgiveness). Added juice systems (hitstop, camera trauma, hit flash shader, knockback, squash/stretch). Added destructible environment (4 prop types with break FX and drops). Added enemy visual readability rules for AI-generated sprites. Added detailed Godot node architecture for all major entities. Expanded hit feedback to 13-event matrix. Expanded Phase 8 roadmap from 8 to 18 polish tasks. |
| 2026-02-21 | **HUD DESIGN**: Added complete In-Game HUD Design (MVP) section under Technical Specifications. Specs for: Player Health Bar (damage trail, low-HP pulse), Dash Cooldown (auto-hide), Room Progress (7-dot indicator), Boss Health Bar (phase transition FX, defeat shatter), Contextual [E] Prompts (world-space), Floating Damage Numbers (color-coded, directional float, GDScript implementation). Added HUD scene tree, file structure, and 11 EventBus signals. Expanded Phase 7 roadmap from 5 to 12 tasks. |
| 2026-02-21 | **PLAYER FORGIVENESS IMPLEMENTED**: Completed all Phase 2 forgiveness systems. Implemented: hit flash shader (`shaders/hit_flash.gdshader`), hitbox restructure (player body r=12, hurtbox r=10, arrow r=7), damage i-frames (0.8s with 0.08s sprite flicker), input buffering (0.15s window for dash/shoot/melee), dash forgiveness window (0.12s post-hit), aim assist / soft magnetism (12° cone, 8° max correction, 300px range), EventBus dash signals. Phase 2 marked complete. |
| 2026-02-21 | **PHASE 3 ENEMIES VERIFIED & ARCHIVED**: Verified all 4 enemy types — Shadow Wisp (25 HP, homing + bounce), Shadow Crawler (35 HP, fast chase + attack + bounce), Shadow Stalker (60 HP, teleport every 2s + smoke VFX), Shadow Brute (150 HP, charge telegraph 0.3s + charge 300px/s + 3s cooldown + 50% bonus damage). Verified ShadowPool spawn system (global MAX_ENEMIES=10, local limit 3/pool, player proximity detection). Verified hit feedback (red flash 0.1s + knockback 50px) and death dissolve (2.5s wait + death_smoke VFX + 1.0s alpha fade) on all enemies. Cleaned up debug prints in shadow_stalker.gd. Fixed GDD Shadow Crawler HP (40→35 to match implementation). |

---

*This is a living document. Update as the project evolves.*
