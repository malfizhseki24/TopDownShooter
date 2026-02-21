## Why

Phase 2 established the player's combat and respawn systems. Now we need enemies to fight - the core gameplay loop requires hostile Shadow Creatures that challenge the player, enable combat interactions, and trigger the death/respawn mechanics we built. Without enemies, the player cannot take damage, die, respawn, or experience the intended gameplay.

## What Changes

### New Systems
- **Base Enemy Class**: Abstract foundation with HP, damage, speed, movement behavior, and common methods (take_damage, die)
- **Shadow Wisp**: Slow floating orb with homing behavior (25 HP, 10 contact damage)
- **Shadow Crawler**: Fast quadruped that attacks in groups (40 HP, 15 contact damage)
- **Shadow Stalker**: Teleporting ambusher (60 HP, 20 contact damage, teleports every 2 sec)
- **Shadow Brute**: Tanky charger (150 HP, 30 contact damage, charge attack)
- **Enemy Spawn System**: Shadow pools that spawn enemies at configured intervals
- **Enemy Hit Feedback**: Flash white on hit, knockback, dissolve particles on death

### Integration Points
- Player hitbox detects enemy contact for damage
- Enemy death triggers could spawn drops (future)
- Boss Phase 2 will summon Shadow Wisps

## Capabilities

### New Capabilities
- `enemies`: Base enemy system and all 4 enemy types (Shadow Wisp, Shadow Crawler, Shadow Stalker, Shadow Brute) with behaviors, stats, hit feedback, and death effects
- `enemy-spawn`: Shadow pool spawning system with configurable enemy types and intervals

### Modified Capabilities
- `player`: Contact damage detection from enemies (player Hitbox already exists, needs enemy layer collision)
- `game-state`: Enemy spawning tied to game state (spawn on PLAYING, pause on PAUSED)

## Impact

### New Files
- `scripts/enemies/base_enemy.gd` - Abstract base class
- `scripts/enemies/shadow_wisp.gd` - Slow homing orb
- `scripts/enemies/shadow_crawler.gd` - Fast quadruped
- `scripts/enemies/shadow_stalker.gd` - Teleporting ambusher
- `scripts/enemies/shadow_brute.gd` - Charging tank
- `scripts/enemies/shadow_pool.gd` - Spawn point
- `scenes/enemies/base_enemy.tscn` - Base enemy scene
- `scenes/enemies/shadow_wisp.tscn`
- `scenes/enemies/shadow_crawler.tscn`
- `scenes/enemies/shadow_stalker.tscn`
- `scenes/enemies/shadow_brute.tscn`
- `scenes/enemies/shadow_pool.tscn`

### Modified Files
- `scripts/player/player.gd` - Enemy collision detection (use existing Hitbox)
- `scripts/autoload/event_bus.gd` - Add enemy signals (enemy_died, enemy_spawned)
- `scripts/autoload/game_manager.gd` - Spawn pool references

### Physics Layers
- Add "enemy" layer for enemy bodies
- Add "enemy_hitbox" layer for enemy damage detection
- Configure player hitbox to detect enemy layer

### Dependencies
- Shadow Wisp sprites already generated (Character ID: c07cdaed-8134-476c-9906-ec36c89291ef)
- Shadow Crawler, Stalker, Brute sprites pending (tracked in add-character-sprites change)
