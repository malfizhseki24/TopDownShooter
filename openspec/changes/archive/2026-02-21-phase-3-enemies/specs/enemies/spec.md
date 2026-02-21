## ADDED Requirements

### Requirement: Base Enemy Class

All enemies SHALL extend a BaseEnemy class with common functionality.

#### Scenario: Base enemy has required properties

- **WHEN** any enemy is instantiated
- **THEN** enemy has hp, max_hp, contact_damage, move_speed properties
- **AND** enemy has take_damage(damage: int) method
- **AND** enemy has die() method
- **AND** enemy extends CharacterBody2D

#### Scenario: Enemy takes damage

- **WHEN** take_damage(damage) is called on an enemy
- **AND** enemy hp is greater than 0 after reduction
- **THEN** enemy hp is reduced by damage amount
- **AND** enemy flashes white briefly (0.1 sec)
- **AND** enemy plays hit sound effect

#### Scenario: Enemy dies when HP reaches zero

- **WHEN** take_damage reduces enemy hp to 0 or below
- **THEN** die() method is called
- **AND** enemy enters DYING state
- **AND** enemy stops all movement
- **AND** enemy plays death animation (dissolve fade)
- **AND** enemy is removed from scene after 0.5 sec

### Requirement: Shadow Wisp Enemy

Shadow Wisp SHALL be a slow floating orb with homing behavior.

#### Scenario: Shadow Wisp stats

- **WHEN** Shadow Wisp is spawned
- **THEN** hp is 25
- **AND** contact_damage is 10
- **AND** move_speed is 80 px/sec

#### Scenario: Shadow Wisp homing behavior

- **WHEN** Shadow Wisp is in MOVING state
- **THEN** enemy moves toward player position
- **AND** movement is smooth (not teleporting)
- **AND** enemy rotates to face movement direction (optional visual)

#### Scenario: Shadow Wisp contact damage

- **WHEN** Shadow Wisp body collides with player
- **THEN** player.take_damage(10) is called
- **AND** Shadow Wisp does not take damage from contact

### Requirement: Shadow Crawler Enemy

Shadow Crawler SHALL be a fast quadruped that attacks in groups.

#### Scenario: Shadow Crawler stats

- **WHEN** Shadow Crawler is spawned
- **THEN** hp is 40
- **AND** contact_damage is 15
- **AND** move_speed is 150 px/sec

#### Scenario: Shadow Crawler fast movement

- **WHEN** Shadow Crawler is in MOVING state
- **THEN** enemy moves toward player at 150 px/sec
- **AND** movement uses CharacterBody2D velocity

### Requirement: Shadow Stalker Enemy

Shadow Stalker SHALL teleport periodically and ambush the player.

#### Scenario: Shadow Stalker stats

- **WHEN** Shadow Stalker is spawned
- **THEN** hp is 60
- **AND** contact_damage is 20
- **AND** move_speed is 100 px/sec

#### Scenario: Shadow Stalker teleport behavior

- **WHEN** 2 seconds have passed since last teleport
- **THEN** Shadow Stalker teleports to position near player
- **AND** teleport distance is 80-120 px from player
- **AND** enemy is visible for 0.5 sec after teleport before moving

#### Scenario: Shadow Stalker teleport does not overlap player

- **WHEN** Shadow Stalker teleports
- **THEN** new position is not inside player collision
- **AND** new position is within playable area bounds

### Requirement: Shadow Brute Enemy

Shadow Brute SHALL be a tanky enemy with charge attack.

#### Scenario: Shadow Brute stats

- **WHEN** Shadow Brute is spawned
- **THEN** hp is 150
- **AND** contact_damage is 30
- **AND** move_speed is 60 px/sec

#### Scenario: Shadow Brute charge attack

- **WHEN** player is within 150 px of Shadow Brute
- **AND** charge cooldown is ready (3 sec)
- **THEN** Shadow Brute flashes and pauses for 0.3 sec (telegraph)
- **AND** Shadow Brute charges toward player at 300 px/sec
- **AND** charge continues for 0.5 sec or until wall collision

#### Scenario: Shadow Brute charge cooldown

- **WHEN** Shadow Brute completes a charge
- **THEN** charge is on cooldown for 3 seconds
- **AND** Shadow Brute resumes slow movement

### Requirement: Enemy Hit Feedback

Enemies SHALL provide visual and audio feedback when hit.

#### Scenario: Enemy flash on hit

- **WHEN** enemy takes damage
- **THEN** enemy sprite modulate changes to white
- **AND** modulate returns to normal after 0.1 sec

#### Scenario: Enemy knockback on hit

- **WHEN** enemy takes damage
- **THEN** enemy is pushed away from damage source by 50 px
- **AND** knockback takes 0.15 sec

### Requirement: Enemy Death Effects

Enemies SHALL play death animation when HP reaches zero.

#### Scenario: Enemy dissolve animation

- **WHEN** enemy dies
- **THEN** sprite modulate alpha tweens from 1.0 to 0.0 over 0.5 sec
- **AND** enemy is removed from scene after animation completes
- **AND** enemy_died signal is emitted via EventBus

### Requirement: Enemy Animation System

All enemies SHALL use AnimatedSprite2D with directional animations.

#### Scenario: Enemy has required animations

- **WHEN** enemy is instantiated
- **THEN** AnimatedSprite2D has animations: idle, walk, death
- **AND** animations play in correct states

#### Scenario: Enemy direction follows movement

- **WHEN** enemy moves in any direction
- **THEN** animation uses appropriate directional sprites:
  - velocity.y < 0 → north
  - velocity.y > 0 → south
  - velocity.x < 0 → west (or flip_h on east)
  - velocity.x >= 0 → east
