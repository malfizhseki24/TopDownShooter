## 1. AudioManager Upgrade

- [x] 1.1 Upgrade `scripts/autoload/audio_manager.gd` — add SFX pool (8 `AudioStreamPlayer2D` instances), `play_sfx_at(sound, position)` method with pooling
- [x] 1.2 Add music crossfade system — two `AudioStreamPlayer` nodes, `play_music(track)` with 1.0s crossfade, `stop_music()`
- [x] 1.3 Add game state music transitions — connect to EventBus signals (`room_loaded`, `enemy_spawned`, `boss_spawned`, `room_cleared`, `victory`, `game_over`) to switch music states

## 2. SFX Implementation

- [x] 2.1 Add placeholder SFX files to `assets/sfx/` — bow_shoot.wav, arrow_hit.wav, arrow_hit_destructible.wav, dash_whoosh.wav, enemy_death.wav, enemy_spawn.wav, boss_charge.wav, destructible_break_pot.wav, destructible_break_crystal.wav, destructible_break_wood.wav, destructible_break_bone.wav, hitstop_thump.wav, ui_confirm.wav, ui_deny.wav, pickup_chime.wav
- [x] 2.2 Hook SFX in `scripts/player/player.gd` — bow twang on `_shoot()`, dash whoosh on `_dash()`, hurt SFX on `take_damage()`, death SFX on die
- [x] 2.3 Hook SFX in `scripts/player/arrow.gd` — arrow hit on enemy/destructible collision
- [x] 2.4 Hook SFX in `scripts/enemies/base_enemy.gd` — death dissolve on `die()`, spawn emergence on spawn
- [x] 2.5 Hook SFX in `scripts/boss/shadow_boar.gd` — charge telegraph on `_start_telegraph()`, slam impact on `_spawn_shockwave()`, phase transition roar
- [x] 2.6 Hook SFX in destructible scripts — type-specific break sound on destruction
- [x] 2.7 Hook SFX in `scripts/autoload/hitstop_manager.gd` — bass thump on `freeze()` call
- [x] 2.8 Hook SFX in UI scripts — confirm/deny on button press

## 3. Music Implementation

- [x] 3.1 Add placeholder music tracks to `assets/music/` — exploration.ogg, combat.ogg, boss.ogg, victory.ogg, game_over.ogg
- [x] 3.2 Configure AudioManager music state machine — map game states to track files
- [x] 3.3 Test music transitions — verify crossfade on room enter, combat start, boss spawn, victory, death

## 4. Balancing Pass

- [ ] 4.1 Playtest all 7 rooms + boss with all Phase 8 systems active
- [x] 4.2 Tune hitstop durations — verify freeze feels punchy, not sticky; adjust if any feel too long
- [x] 4.3 Tune camera trauma values — verify shake intensity is noticeable but not nauseating
- [x] 4.4 Tune knockback distances — verify enemies don't clip through walls, boss resistance feels heavy
- [x] 4.5 Tune damage/HP/speed — verify player survives 3-4 regular hits, boss fight lasts 60-90s
- [x] 4.6 Verify SFX volume levels — combat sounds should be prominent, UI subtle, music as background

## 5. GDD Update

- [x] 5.1 Update GDD Phase 8 checkboxes for SFX Implementation, Music Implementation, Balancing Pass
