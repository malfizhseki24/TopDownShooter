## 1. Camera Trauma System

- [x] 1.1 Add `camera_trauma(amount: float)` signal to `scripts/autoload/event_bus.gd`
- [x] 1.2 Upgrade `scripts/camera/pixel_camera.gd` — add `FastNoiseLite` resource, trauma float, `add_trauma()`, quadratic shake in `_process()` (max 8px/6px/2deg, decay 3.0*delta)
- [x] 1.3 Connect `EventBus.camera_trauma` to `add_trauma()` in camera `_ready()`
- [x] 1.4 Remove `_screen_shake()` from `scripts/player/player.gd`; replace with `EventBus.camera_trauma.emit(0.35)` in `take_damage()`
- [x] 1.5 Emit trauma from `scripts/enemies/base_enemy.gd` — +0.08 on hit, +0.12 on kill (detect via hp <= 0); melee type +0.15 hit, +0.25 kill
- [x] 1.6 Emit trauma from `scripts/boss/shadow_boar.gd` — +0.06 on hit, +0.60 on phase transition, +0.40 on wall charge, +0.50 on slam
- [x] 1.7 Playtest: verify micro-shake on arrow hit, heavy shake on player damage, dramatic shake on boss phase transition

## 2. Camera Look-Ahead

- [x] 2.1 Add look-ahead logic to `scripts/camera/pixel_camera.gd` — lerp an `_aim_offset` toward `aim_direction * 40` at weight 4.0, add to target position
- [x] 2.2 Expose player aim direction to camera (either cache player reference or add `EventBus.player_aim_updated(direction)` signal)
- [x] 2.3 Playtest: verify camera leads in aim direction, returns to center when not aiming, doesn't jitter

## 3. Hitstop Manager

- [x] 3.1 Create `scripts/autoload/hitstop_manager.gd` — `freeze(duration)`, `slow_mo(scale, duration)` with no-stack guard
- [x] 3.2 Register `HitstopManager` as autoload in `project.godot`
- [x] 3.3 Emit hitstop from `scripts/enemies/base_enemy.gd` — 0.04s on arrow hit, 0.07s on arrow kill, 0.08s on melee hit, 0.12s on melee kill
- [x] 3.4 Emit hitstop from `scripts/player/player.gd` — 0.06s on regular damage, 0.08s on boss damage
- [x] 3.5 Emit hitstop from `scripts/boss/shadow_boar.gd` — 0.03s on arrow hit, 0.06s on melee hit, 0.20s on phase transition
- [x] 3.6 Playtest: verify brief freeze on hits, heavy freeze on melee kills, time_scale restores correctly

## 4. Kill Slow-Mo

- [x] 4.1 Add kill slow-mo logic: on `EventBus.room_cleared`, trigger `HitstopManager.slow_mo(0.15, 0.12)` + camera trauma +0.25 (skip for boss room)
- [x] 4.2 Playtest: clear a room and verify brief slow-mo on last kill, no slow-mo after boss kill

## 5. GDD Update

- [x] 5.1 Update GDD Phase 8 checkboxes for Camera Trauma System, Camera Look-Ahead, Hitstop Manager, Kill Slow-Mo
