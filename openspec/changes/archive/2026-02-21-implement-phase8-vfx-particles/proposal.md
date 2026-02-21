# Proposal: VFX & Particles (Phase 8C)

## Summary

Implement visual effects for dash afterimages, arrow trails, portal animations, heal shrine particles, and enemy spawn emergence. These are the **particle and animation effects** that bring the world to life.

## Motivation

Currently, VFXManager exists and spawns basic effects (hit_spark, death_smoke, shadow_spawn, dash_trail, explosion), but the GDD specifies richer effects: dash afterimage trails (3-4 fading ghost sprites), GPU particle arrow trails, portal idle/activation/travel VFX, heal shrine green spiral, and squash/stretch spawn emergence. These effects complete the visual polish layer.

## Scope

### Dash Afterimages
- 3-4 ghost sprite copies spawned during dash
- Each copy fades from 60% opacity to 0 over 0.15s
- Copies are tinted slightly (desaturated or blue-shifted)
- Spawned every ~0.05s during the 0.2s dash

### Arrow Trail
- `GPUParticles2D` child on arrow scene
- Small fading dots behind the arrow
- Emission rate ~30/s, lifetime 0.2s, fade to transparent
- Color matches arrow sprite palette

### Portal VFX
- **Idle shimmer**: Subtle floating particle animation (locked portals show dim version)
- **Activation burst**: Particle burst when room is cleared and portal unlocks
- **Travel warp**: Screen effect when player enters portal

### Heal Shrine VFX
- Green particle spiral upward on use (0.8s duration)
- Idle subtle glow/float particles when unused
- Particles stop after shrine is consumed

### Spawn Emerge VFX
- Squash/stretch scale animation: `(0, 0)` → `(1.1, 0.9)` → `(1.0, 1.0)` over 0.3s
- Dark shadow/smoke puff at spawn point
- Applied to all enemies on spawn

## Affected Files

### New
- `scenes/vfx/dash_afterimage.tscn` — Ghost sprite effect
- `scenes/vfx/arrow_trail.tscn` — GPUParticles2D for arrow
- `scenes/vfx/portal_vfx.tscn` — Portal idle/activation/travel effects
- `scenes/vfx/heal_shrine_vfx.tscn` — Green particle spiral
- `scenes/vfx/spawn_emerge.tscn` — Spawn puff effect
- `scripts/vfx/dash_afterimage.gd` — Afterimage spawner logic
- `scripts/vfx/portal_vfx.gd` — Portal VFX controller

### Modified
- `scripts/player/player.gd` — spawn afterimages during dash
- `scenes/player/arrow.tscn` — add GPUParticles2D child
- `scripts/enemies/base_enemy.gd` — spawn emerge animation in `_ready()` or spawn method
- `scripts/interactables/heal_shrine.gd` — trigger heal VFX on use
- Portal scene files — add portal VFX nodes

## Dependencies

- Depends on **Phase 8A** (camera-time) for EventBus trauma signals used alongside VFX
- Independent of **Phase 8B** (combat-juice) but will layer on top of it
