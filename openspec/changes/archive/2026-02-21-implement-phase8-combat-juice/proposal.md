# Proposal: Combat Juice Systems (Phase 8B)

## Summary

Add screen flash effects, upgrade knockback to impulse-based physics, implement squash/stretch deformation, apply hit flash shader to all enemies, and add enemy glow layers for visual readability. These are the **visual combat feedback layers** that make hits feel impactful.

## Motivation

Currently, enemy hit feedback is a basic red modulate (not using the shader), knockback is a simple position tween, there's no squash/stretch deformation, no screen flash overlays, and no enemy glow layers. The GDD's feedback matrix specifies 3-5 simultaneous feedback channels per hit event — this change delivers the visual and physics channels.

## Scope

### Screen Flash Effects
- Red overlay (player hit): `ColorRect` with 20% opacity red, fade in/out over 0.15s
- Intense red overlay (boss hit): stronger opacity, brief chromatic aberration pulse
- White flash (boss phase transition): full-screen white, 0.15s
- Green pulse (heal shrine use): green overlay, 0.4s fade
- Desaturation on player death: `ColorRect` with grayscale shader + fade to black

### Knockback Polish
- Replace position tween with impulse velocity applied for 1 frame
- Friction decay: `velocity.move_toward(Vector2.ZERO, 600.0 * delta)`
- Per-event knockback distances from feedback matrix (80px arrow, 150px melee, etc.)
- Boss knockback resistance (20px arrow, 40px melee)

### Squash/Stretch
- Enemy squash on hit: scale to `(1.3, 0.7)` → `(1.0, 1.0)` over 0.1s
- Enemy stretch on death: scale to `(0.6, 1.4)` → dissolve
- Player squash on dash landing: `(1.2, 0.8)` → `(1.0, 1.0)` over 0.08s
- Arrow stretch: render at `(0.8, 1.2)` scale for speed feel

### Hit Flash Shader (Enemies)
- Apply `hit_flash.gdshader` to all enemy sprites (currently only player uses it)
- White flash on hit: intensity 1.0→0.0 over 0.08s
- Remove legacy red modulate from `base_enemy._flash_white()`

### Enemy Glow Layer
- Additive blend sprite for eyes/aura on all enemies
- CanvasItemMaterial with additive blend or simple additive shader
- Warm glow colors (red/orange for Shadow types, cyan for Wisp)
- Boss persistent 4-8px shadow aura

## Affected Files

### New
- `scripts/ui/screen_flash.gd` — Screen flash overlay manager
- `scenes/ui/screen_flash.tscn` — ColorRect overlay scene
- `shaders/hit_flash.gdshader` — Hit flash shader file (currently inline)

### Modified
- `scripts/enemies/base_enemy.gd` — knockback physics, squash/stretch, shader hit flash
- `scripts/player/player.gd` — dash landing squash, screen flash emits
- `scripts/player/arrow.gd` — stretch scale on spawn
- `scripts/boss/shadow_boar.gd` — screen flash on phase transition, knockback resistance
- `scripts/autoload/event_bus.gd` — screen flash signals
- `scenes/enemies/*.tscn` — add glow sprites, shader materials
- `scenes/player/player.tscn` — screen flash integration
- `scenes/boss/shadow_boar.tscn` — glow aura sprite

## Dependencies

- Depends on **Phase 8A** (camera-time) for EventBus signals and hitstop integration
