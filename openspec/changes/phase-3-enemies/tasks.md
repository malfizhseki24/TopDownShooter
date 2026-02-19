# Tasks: Phase 3 - Enemies

## 1. Physics Layer Setup

- [x] 1.1 Add "enemy" layer (layer 2) in Project Settings > 2D Physics
- [x] 1.2 Configure player Hitbox to detect "enemy" layer
- [x] 1.3 Verify collision matrix in project settings

## 2. Base Enemy System

- [x] 2.1 Create `scripts/enemies/base_enemy.gd` with BaseEnemy class
  - Properties: hp, max_hp, contact_damage, move_speed
  - State enum: IDLE, MOVING, ATTACKING, DYING
  - Methods: take_damage(), die(), _flash_white(), _get_contact_damage()
- [x] 2.2 Create `scenes/enemies/base_enemy.tscn` scene structure
  - CharacterBody2D root
  - AnimatedSprite2D for sprites
  - CollisionShape2D for physics
  - Area2D "Hitbox" for player contact detection
- [x] 2.3 Add enemy_died signal to EventBus

## 3. Shadow Wisp Enemy

- [x] 3.1 Create `scripts/enemies/shadow_wisp.gd` extending BaseEnemy
  - Set stats: hp=25, contact_damage=10, move_speed=80
  - Implement _physics_process for homing toward player
- [x] 3.2 Create `scenes/enemies/shadow_wisp.tscn`
  - Use Shadow Wisp sprites from add-character-sprites change
  - Configure AnimatedSprite2D with breathing-idle, walking-4-frames, falling-back-death
- [x] 3.3 Test Shadow Wisp in isolation
  - Spawns, moves toward player, deals contact damage, dies when HP=0

## 4. Shadow Crawler Enemy

- [x] 4.1 Create `scripts/enemies/shadow_crawler.gd` extending BaseEnemy
  - Set stats: hp=35, contact_damage=15, move_speed=120
  - Implement fast movement toward player with attack+bounce behavior
- [x] 4.2 Create `scenes/enemies/shadow_crawler.tscn`
  - Generated Shadow Crawler sprites via PixelLab (quadruped, cat template)
  - Configured AnimatedSprite2D with idle, walk, attack, death animations (4 directions)
- [x] 4.3 Test Shadow Crawler movement speed and damage

## 5. Shadow Stalker Enemy

- [x] 5.1 Create `scripts/enemies/shadow_stalker.gd` extending BaseEnemy
  - Set stats: hp=60, contact_damage=20, move_speed=100
  - Implement teleport timer (2 sec interval)
  - Implement teleport logic: random position 80-120px from player
  - Add 0.5s visible period after teleport
- [x] 5.2 Create `scenes/enemies/shadow_stalker.tscn`
  - Generate Shadow Stalker sprites via PixelLab
  - Configure AnimatedSprite2D with idle, walk, teleport (surprise-uppercut), attack (cross-punch), death
- [x] 5.3 Test teleport behavior and timing

## 6. Shadow Brute Enemy

- [ ] 6.1 Create `scripts/enemies/shadow_brute.gd` extending BaseEnemy
  - Set stats: hp=150, contact_damage=30, move_speed=60
  - Implement charge attack: telegraph (0.3s flash), charge (300 px/sec, 0.5s)
  - Implement 3 sec charge cooldown
  - Trigger charge when player within 150px
- [ ] 6.2 Create `scenes/enemies/shadow_brute.tscn`
  - Generate Shadow Brute sprites via PixelLab
  - Configure AnimatedSprite2D with idle, walk, charge (running-4-frames), attack (two-footed-jump), death
- [ ] 6.3 Test charge telegraph and cooldown

## 7. Enemy Spawn System

- [x] 7.1 Update GameManager with enemy tracking
  - Add enemy_count property
  - Add MAX_ENEMIES constant (10)
  - Track increment/decrement on spawn/death
- [x] 7.2 Create `scripts/enemies/shadow_pool.gd`
  - Export: enemy_scenes (Array[PackedScene]), max_spawn, spawn_interval, detection_radius
  - Implement player detection area
  - Implement spawn timer with global limit check
- [x] 7.3 Create `scenes/enemies/shadow_pool.tscn`
  - Area2D with collision shape for detection
  - Visual sprite for shadow pool effect
- [ ] 7.4 Test spawn system with Shadow Wisp only

## 8. Hit Feedback & Death Effects

- [x] 8.1 Implement enemy flash on hit (modulate white, 0.1 sec)
- [x] 8.2 Implement enemy knockback (50px away from damage source, 0.15 sec)
- [x] 8.3 Implement death dissolve (alpha tween 1.0 → 0.0, 0.5 sec)
- [x] 8.4 Add death sound effect trigger

## 9. Integration

- [ ] 9.1 Update player Hitbox to detect enemy layer
- [ ] 9.2 Update player.gd _on_hitbox_body_entered for enemy damage
- [ ] 9.3 Connect enemy_died signal to GameManager for count tracking
- [ ] 9.4 Test full gameplay loop: spawn → combat → death → respawn

## 10. Verification

- [ ] 10.1 All 4 enemy types spawn and behave correctly
- [ ] 10.2 Global enemy limit (10 max) enforced
- [ ] 10.3 Player takes correct damage from each enemy type
- [ ] 10.4 Enemies die correctly and decrement count
- [ ] 10.5 Hit feedback (flash, knockback) works on all enemies
- [ ] 10.6 Death dissolve animation plays on all enemies

## Dependencies

- Shadow Wisp sprites: ✅ Ready (Character ID: c07cdaed-8134-476c-9906-ec36c89291ef)
- Shadow Crawler sprites: ⏳ Pending (tracked in add-character-sprites/tasks.md section 4)
- Shadow Stalker sprites: ⏳ Pending (tracked in add-character-sprites/tasks.md section 5)
- Shadow Brute sprites: ⏳ Pending (tracked in add-character-sprites/tasks.md section 6)
