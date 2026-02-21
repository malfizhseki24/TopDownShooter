# Design: Audio Implementation

## Key Decisions

### 1. Upgrade existing AudioManager rather than replace

The `AudioManager` autoload already exists and has `play_sfx(sound, position)`. We upgrade it with music crossfade, SFX pooling, and game-state-aware music transitions. No new autoload needed.

### 2. SFX uses AudioStreamPlayer2D pool for spatial audio

Combat SFX (hits, breaks, spawns) use positional audio via `AudioStreamPlayer2D`. A pool of 8 pre-spawned players avoids per-frame allocation. Non-positional SFX (UI, music) use regular `AudioStreamPlayer`.

### 3. Music crossfade with two AudioStreamPlayers

Two `AudioStreamPlayer` nodes alternate: when transitioning, the new track fades in on player B while player A fades out. Duration: 1.0s crossfade. Music state is tracked and only transitions when game state changes (room entered, combat started, boss spawned, etc.).

### 4. Game state drives music transitions

| Trigger | Music State |
|---------|-------------|
| `room_loaded` (no enemies) | Exploration |
| `enemy_spawned` (first in room) | Combat |
| `boss_spawned` | Boss |
| `room_cleared` | Exploration (after brief combat tail) |
| `victory` | Victory |
| `player_died` / `game_over` | Death |

### 5. Placeholder audio for MVP

For initial implementation, we use simple placeholder sounds (generated or sourced from free libraries). The audio direction (Papuan fusion) is documented but full production audio is a future asset task. Placeholder SFX should still be correctly hooked up at all trigger points.

### 6. Balancing pass is manual testing with documented targets

The balancing pass is not automated. It involves playing through all 7 rooms + boss with all Phase 8 systems active, noting where values feel off, and adjusting. Key targets:
- Player should survive 3-4 hits from regular enemies
- Boss fight should last 60-90 seconds
- Hitstop should feel punchy but never annoying
- Camera shake should be noticeable but not nauseating
- Knockback should feel impactful without pushing enemies through walls

## SFX Integration Points

| SFX | Trigger Location | Spatial |
|-----|-----------------|---------|
| Bow twang | `player._shoot()` | Yes (player pos) |
| Arrow hit enemy | `arrow._on_body_entered()` | Yes (hit pos) |
| Arrow hit destructible | `arrow._on_body_entered()` | Yes (hit pos) |
| Dash whoosh | `player._dash()` | Yes (player pos) |
| Enemy death | `base_enemy.die()` | Yes (enemy pos) |
| Enemy spawn | `base_enemy._play_spawn_effect()` | Yes (spawn pos) |
| Boss charge | `shadow_boar._start_telegraph()` | Yes (boss pos) |
| Destructible break | `base_destructible._break()` | Yes (break pos) |
| Hitstop thump | `hitstop_manager.freeze()` | No (global) |
| UI confirm | `main_menu` button press | No (global) |
| Pickup chime | `spirit_ember._on_body_entered()` | Yes (pickup pos) |
