# Design: Combat Economy System

## Architecture Overview

```
┌─────────────┐    enemy_died    ┌──────────────────┐
│   Enemy     │ ───────────────► │   EventBus       │
└─────────────┘                  └────────┬─────────┘
                                          │
                          shard_dropped   │  meter_updated
                                 │        │        │
                                 ▼        ▼        ▼
                          ┌──────────┐  ┌──────────────┐
                          │SunShard  │  │ EnergyMeter  │
                          │ (spawn)  │  │    (HUD)     │
                          └────┬─────┘  └──────────────┘
                               │
              magnetic_pull    │   collected
                               ▼
                          ┌──────────┐
                          │ Player   │
                          │ collects │
                          └──────────┘
                               │
                    meter_full + special_input
                               │
                               ▼
                       ┌──────────────┐
                       │ Sun-Piercer  │
                       │   (spawn)    │
                       └──────────────┘
```

## Component Details

### 1. Sun Shard (Pickup)

**Scene**: `scenes/pickups/sun_shard.tscn`
**Script**: `scripts/pickups/sun_shard.gd`

```
SunShard (Area2D)
├── Sprite2D (shard sprite, 8x8 viewport pixels, diamond/rhombus shape)
├── AnimationPlayer (idle bob + sparkle animation)
├── PointLight2D (subtle glow, #ffdd44)
└── CollisionShape2D (CircleShape2D, r=12)
```

**Lifecycle**:
1. Spawn at enemy death position with random upward velocity
2. Physics bounce (0.3s) with gravity simulation
3. Settle into idle bob animation
4. Detect player within 80px → activate magnetic pull
5. On collection: emit signal, spawn particle burst, queue_free
6. Fallback: auto-collect after 5 seconds if not picked up

**Juice Elements**:
- Spawn: Small particle burst (white-yellow sparkles)
- Bounce: Simulated physics with dampening
- Idle: Gentle up/down bob (±2px, 1.5s cycle) + occasional sparkle
- Magnetic: Acceleration towards player, stretch sprite in movement direction
- Collect: Scale tween (1.0 → 1.3 → 0), particle burst

### 2. Energy Meter (HUD)

**Scene**: `scenes/ui/energy_meter.tscn`
**Script**: `scripts/ui/energy_meter.gd`

```
EnergyMeter (Control)
├── BackgroundCircle (TextureRect, 24x24, dim outline)
├── FillCircle (TextureRect, radial fill mask)
├── FeatherIcon (TextureRect, 12x12, centered)
└── ReadyGlow (TextureRect, pulsing overlay)
```

**Visual Design**:
- Circular gauge, 24x24 viewport pixels
- Placed 8px below health bar (after dash cooldown)
- Fill color gradient: `#ffdd44` (empty) → `#ff8800` (full)
- Ready state: Outer glow pulse + shard icon brightness

**States**:
| Fill % | Visual | Audio |
|--------|--------|-------|
| 0-99% | Radial fill animates | Soft "collect" chime per feather |
| 100% | Glow pulse, icon bright | "Ready" chime (ascending tone) |
| Firing | Flash white, drain to 0 | "Fire" whoosh |

### 3. Sun-Piercer (Ultimate Attack)

**Scene**: `scenes/player/sun_piercer.tscn`
**Script**: `scripts/player/sun_piercer.gd`

```
SunPiercer (Area2D)
├── Sprite2D (large projectile, 32x32 viewport pixels)
├── PointLight2D (bright glow, #ffaa00)
├── TrailParticles (GPUParticles2D, fire trail)
├── CollisionShape2D (RectangleShape2D, 32x12)
└── HitCooldownTimer (prevents double-hit same enemy)
```

**Stats**:
| Property | Value |
|----------|-------|
| Damage | 80 (3x normal arrow) |
| Speed | 400 px/s (faster than arrow) |
| Pierce | Unlimited enemies + 3 obstacles |
| Wind-up | 0.25 seconds |
| Duration | 2 seconds or until off-screen |
| Cooldown | None (meter is the cooldown) |

**Juice Elements**:
- Wind-up: Player flash, screen shake (0.2 trauma), anticipation SFX
- Fire: Whoosh SFX, camera push in direction
- Travel: Fire trail particles, screen shake (0.1 continuous)
- Hit: Hitstop (0.15s per enemy), damage number, enemy flash
- End: Fade out + particle dispersion

## Input Mapping

Add to Project Settings > Input Map:

```
special_attack (new)
  - Mouse Button: Right Button
  - Key: Space
```

Priority: If both pressed, Right Click takes precedence.

## Signal Contract

Add to `event_bus.gd`:

```gdscript
# Combat Economy signals
signal shard_dropped(position: Vector2)
signal shard_collected
signal energy_meter_changed(current: int, maximum: int)
signal energy_meter_full
signal energy_meter_emptied
signal special_attack_fired(direction: Vector2)
signal special_attack_hit(target: Node, damage: int)
```

## Integration Points

### Enemy Death → Shard Drop

In `base_enemy.gd` or `enemy_spawner.gd`:
```gdscript
func _die():
    # ... existing death logic ...
    if randf() < drop_chance:  # 60% base chance
        EventBus.shard_dropped.emit(global_position)
```

### Player Collection → Meter Update

In `player.gd`:
```gdscript
func _on_shard_collected():
    current_energy = mini(current_energy + 1, MAX_ENERGY)
    EventBus.energy_meter_changed.emit(current_energy, MAX_ENERGY)
    if current_energy >= MAX_ENERGY:
        EventBus.energy_meter_full.emit()
```

### Special Attack Input

In `player.gd`:
```gdscript
func _input(event):
    if event.is_action_pressed("special_attack") and energy_meter_full:
        _fire_sun_piercer()
```

## Balance Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shard drop chance | 60% | Per enemy kill |
| Energy per shard | 1 | No variations |
| Max energy | 10 | ~6-8 kills to fill |
| Sun-Piercer damage | 80 | 3x arrow (25 base) |
| Magnetic pull range | 80px | Radius from player |
| Auto-collect timeout | 5s | Prevents clutter |

## File Structure

```
scenes/
├── pickups/
│   └── sun_shard.tscn
├── player/
│   └── sun_piercer.tscn
└── ui/
    └── energy_meter.tscn

scripts/
├── pickups/
│   └── sun_shard.gd
├── player/
│   └── sun_piercer.gd
└── ui/
    └── energy_meter.gd
```

## Dependencies

- Existing: `EventBus`, `VFXManager`, `HitstopManager`, `AudioManager`
- New: None (uses existing patterns)
