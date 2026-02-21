# Design: Camera & Time Systems

## Key Decisions

### 1. Upgrade existing pixel_camera.gd rather than create new script

The current `pixel_camera.gd` already handles smooth follow and pixel snap. Rather than creating a separate `camera_trauma.gd` as the GDD scene tree suggests, we'll add trauma and look-ahead directly to the existing camera script. This avoids a breaking change in `game.tscn` which references `pixel_camera.gd`.

### 2. EventBus signal for trauma instead of direct camera reference

Game entities should not hold a reference to the camera. Instead, a new `EventBus.camera_trauma(amount)` signal is emitted by the camera's own `_ready()` connection. Any system that causes shake just emits the signal.

The camera script connects to `EventBus.camera_trauma` in `_ready()` and calls `add_trauma(amount)`.

### 3. HitstopManager uses Engine.time_scale (not per-entity freeze)

The GDD offers two methods. `Engine.time_scale` is simpler and affects everything uniformly. The HUD already uses `process_mode = ALWAYS` so it's unaffected. The key trick is using `create_timer(duration, true, false, true)` — the 4th arg makes the timer process during time_scale=0.

### 4. Remove player._screen_shake() after trauma system is live

The current hardcoded shake in player.gd will be replaced by `EventBus.camera_trauma.emit(0.35)` in `take_damage()`. The `_screen_shake()` method is deleted.

### 5. Kill Slow-Mo triggers on last enemy in room

The GameManager/RoomManager already tracks `enemies_in_room`. When `EventBus.enemy_died` fires and the room enemy count reaches 0, the last-kill slow-mo triggers. This check happens in `hitstop_manager.gd` by listening to `enemy_died` and checking the room state.

## Trauma Values (from GDD Feedback Matrix)

| Event | Trauma | Where Emitted |
|-------|--------|---------------|
| Arrow hits enemy | +0.08 | `base_enemy.take_damage()` |
| Arrow kills enemy | +0.12 | `base_enemy.die()` |
| Melee hits enemy | +0.15 | `base_enemy.take_damage()` (melee type) |
| Melee kills enemy | +0.25 | `base_enemy.die()` (melee type) |
| Player takes damage | +0.35 | `player.take_damage()` |
| Boss takes damage | +0.06 | `shadow_boar.take_damage()` |
| Boss phase transition | +0.60 | `shadow_boar._do_phase_transition()` |
| Boss charge wall impact | +0.40 | `shadow_boar._on_charge_hit_wall()` |
| Boss ground slam | +0.50 | `shadow_boar._spawn_shockwave()` |
| Destructible breaks | +0.03 | (future — Phase 8D) |

## Hitstop Durations (from GDD Feedback Matrix)

| Event | Duration | Method |
|-------|----------|--------|
| Arrow → Enemy | 0.04s | freeze |
| Arrow → Enemy (kill) | 0.07s | freeze |
| Melee → Enemy | 0.08s | freeze |
| Melee → Enemy (kill) | 0.12s | freeze |
| Enemy → Player | 0.06s | freeze |
| Boss → Player | 0.08s | freeze |
| Arrow → Boss | 0.03s | freeze |
| Melee → Boss | 0.06s | freeze |
| Boss Phase Transition | 0.20s | freeze |
| Player Death | 0.15s | freeze |
| Arrow → Destructible | 0.02s | freeze |
| Last enemy killed | 0.12s at 0.15x | slow_mo |
