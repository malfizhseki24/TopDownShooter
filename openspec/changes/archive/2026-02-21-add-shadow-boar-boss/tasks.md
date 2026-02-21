# Tasks: Add Shadow Boar Boss

## 1. Shadow Boar Core Rewrite

- [x] 1.1 Rewrite `scripts/boss/shadow_boar.gd` — replace current placeholder with state machine (IDLE, CHASE, TELEGRAPH, CHARGING, STUNNED, SLAM, SUMMONING, DYING)
- [x] 1.2 Implement Phase 1 chase behavior (move toward player at 80 px/sec)
- [x] 1.3 Implement charge telegraph (1.0 sec flash, lock direction toward player)
- [x] 1.4 Implement charge execution (350 px/sec for 0.6 sec or until wall collision)
- [x] 1.5 Implement wall stun detection (check `move_and_slide()` collision, 2.0 sec stun)
- [x] 1.6 Implement Phase 2 trigger at 250 HP (invulnerable 1 sec, screen flash — camera trauma skipped, no system exists)
- [x] 1.7 Implement Phase 2 value escalation (charge speed 455, cooldown 3s, telegraph 0.7s, stun 1.5s)
- [x] 1.8 Implement Phase 2 ground slam (jump-attack anim, shockwave area damage 20, 120px radius)
- [x] 1.9 Implement Phase 2 wisp summoning (2 wisps every 8 sec, max 4 alive)
- [x] 1.10 Implement die() — silently remove summoned wisps (queue_free), emit boss_died, call super.die()
- [x] 1.11 Remove respawn logic (SCENE const, RESPAWN_DELAY, _respawn method)

## 2. Scene Setup

- [x] 2.1 Update `scenes/boss/shadow_boar.tscn` — HP 500 set in _ready(), collision radius 24, hitbox radius 32
- [x] 2.2 Hurtbox: using Hitbox Area2D with collision_mask=1 for player detection (separate hurtbox not needed — arrows use hitbox)
- [x] 2.3 Verify AnimatedSprite2D uses `shadow_boar_frames.tres` with all animations mapped
- [x] 2.4 Map animations: idle→idle, walk→walk-8-frames, charge→running-8-frames, attack→attack, slam→jump-attack

## 3. Room Manager Integration

- [x] 3.1 Add shadow_boar scene to `_load_scenes()` in room_manager.gd
- [x] 3.2 Update `_setup_boss_room()` to use `&"shadow_boar"` instead of `&"shadow_brute"`
- [x] 3.3 Boss emits `EventBus.boss_spawned` from its own _ready() (not room_manager)

## 4. VFX

- [x] 4.1 Shockwave: programmatic expanding Area2D + CircleShape2D with explosion VFX
- [x] 4.2 Shadow trail: reuses `shadow_spawn` VFX from VFXManager
- [x] 4.3 Wall impact dust: reuses `death_smoke` VFX from VFXManager
- [x] 4.4 Phase transition screen flash: inline CanvasLayer + ColorRect with tween fade

## 5. Boss Health Bar UI

- [x] 5.1 Create `scenes/ui/boss_health_bar.tscn` — ProgressBar with boss name label
- [x] 5.2 Create `scripts/ui/boss_health_bar.gd` — connect to EventBus signals (boss_spawned, enemy_hit, boss_phase_changed, boss_died)
- [x] 5.3 Implement slide-in animation on boss_spawned (from below, 0.5 sec ease-out)
- [x] 5.4 Implement phase color change (red → purple fill on phase 2)
- [x] 5.5 Implement fade-out on boss_died
- [x] 5.6 Add boss health bar to game.tscn HUD layer

## 6. EventBus Integration

- [x] 6.1 Verify `boss_spawned`, `boss_died`, `boss_phase_changed` signals exist in event_bus.gd (already declared)
- [x] 6.2 Emit `boss_spawned` from shadow_boar._ready()
- [x] 6.3 Emit `boss_phase_changed(2)` from shadow_boar on phase transition
- [x] 6.4 Emit `boss_died` from shadow_boar.die()

## 7. Verification & Bug Fixes

- [x] 7.1 Fix double-decrement: boss_died + enemy_died both decremented enemies_in_room — skip bosses in _on_enemy_died
- [x] 7.2 Fix premature room clear: wisps dying in boss room no longer trigger room clear (boss death is the only clear trigger)
- [x] 7.3 Fix wisp cleanup: boss die() uses queue_free instead of die() to avoid spurious enemy_died signals
- [x] 7.4 Fix slam animation await: use current sprite animation instead of velocity-derived direction

## 8. Playtesting & Runtime Fixes

- [x] 8.1 Verify boss spawns correctly in Room 7
- [x] 8.2 Test Phase 1: charge telegraph visible, charge direction locked, wall stun works
- [x] 8.3 Test Phase 2 transition: invulnerability, screen flash, values change
- [x] 8.4 Test Phase 2: shockwave damage, wisp summoning, faster charges
- [x] 8.5 Test boss death: wisps killed, health bar hides, victory triggers
- [x] 8.6 Test full run: Rooms 1-7 progression, HP carries over, boss fight, victory screen
- [x] 8.7 Fix victory screen not appearing — VictoryScreen and GameOver scenes were not instanced in game.tscn; added to HUD with process_mode=ALWAYS
- [x] 8.8 Add Phase 2 size increase — sprite scales 50% bigger (0.5→0.75) with TRANS_BACK tween
- [x] 8.9 Fix Phase 2 wisps not spawning if boss killed quickly — set wisp timer to interval at phase start so first batch spawns immediately

## Dependencies

- Sprites: shadow_boar (idle, attack, jump-attack, running-8-frames, walk-8-frames) — READY
- BaseEnemy: die(), take_damage(), _flash_white() — READY
- RoomManager: _setup_boss_room(), _spawn_boss() — READY
- EventBus: boss signals — READY (already declared)
- VFXManager: spawn() — READY
- Room 7 blueprint: 21x15 arena with B marker — READY
