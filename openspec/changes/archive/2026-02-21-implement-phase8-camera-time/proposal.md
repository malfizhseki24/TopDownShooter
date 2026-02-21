# Proposal: Camera & Time Systems (Phase 8A)

## Summary

Upgrade the camera from basic lerp follow to a full trauma-based shake system with look-ahead, and add a HitstopManager autoload for freeze frames and slow-mo. These are **foundational systems** that Phase 8B (combat juice) and Phase 8C (VFX) depend on.

## Motivation

The current camera (`pixel_camera.gd`) has basic smooth follow and a hardcoded 4px screen shake in `player.gd`. The GDD specifies a noise-based trauma system with quadratic falloff (Squirrel Eiserloh method), aim-direction look-ahead, and a global hitstop/slow-mo manager. Without these foundations, combat hits feel flat regardless of visual effects.

## Scope

### Camera Trauma System
- Replace hardcoded screen shake with `FastNoiseLite`-based trauma system
- Quadratic falloff: `shake_intensity = trauma * trauma`
- Max offset: 8px horizontal, 6px vertical, 2 deg rotation
- Trauma decay: `3.0 * delta` per frame
- `add_trauma(amount)` API called by EventBus signals

### Camera Look-Ahead
- 40px offset in aim direction
- Separate lerp weight (4.0) slower than camera follow (8.0)
- Target = `player_position + aim_direction * 40`

### Hitstop Manager
- New autoload: `HitstopManager`
- `freeze(duration)` — sets `Engine.time_scale = 0.0`, restores after duration
- `slow_mo(scale, duration)` — sets scale, lerps back to 1.0 over 0.1s
- No stacking — longer duration wins
- Uses `create_timer(duration, true, false, true)` to tick during time_scale=0

### Kill Slow-Mo
- On last enemy killed in room: `time_scale = 0.15` for 0.12s
- Wire via EventBus signals (room_cleared or enemy_died with count check)

## Affected Files

### New
- `scripts/autoload/hitstop_manager.gd`

### Modified
- `scripts/camera/pixel_camera.gd` — trauma system + look-ahead
- `scripts/player/player.gd` — remove `_screen_shake()`, emit trauma via EventBus
- `scripts/autoload/event_bus.gd` — add `camera_trauma(amount)` signal
- `project.godot` — register HitstopManager autoload

## Dependencies

None — this is a foundation change. Phase 8B and 8C depend on this.
