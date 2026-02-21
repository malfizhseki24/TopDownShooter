# enemies Specification

## Purpose
TBD - created by archiving change phase-3-enemies. Update Purpose after archive.
## Requirements
### Requirement: Base Enemy Class

All enemies SHALL extend a BaseEnemy class with common functionality. The Shadow Boar boss also extends BaseEnemy.

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
- **AND** enemy flashes white via shader (0.08 sec)
- **AND** enemy receives impulse knockback and squash deformation

#### Scenario: Enemy dies when HP reaches zero

- **WHEN** take_damage reduces enemy hp to 0 or below
- **THEN** die() method is called
- **AND** enemy enters DYING state
- **AND** enemy stops all movement
- **AND** enemy plays death animation (dissolve fade)
- **AND** enemy is removed from scene after animation
- **AND** EventBus.enemy_died signal is emitted

#### Scenario: Boss enemy uses base class

- **WHEN** Shadow Boar boss is instantiated
- **THEN** boss extends BaseEnemy
- **AND** boss is in "enemy" group AND "boss" group
- **AND** boss take_damage and hit feedback work identically to regular enemies

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

Enemies SHALL provide visual feedback when hit using the shared `hit_flash.gdshader`, impulse-based knockback, and squash/stretch deformation.

#### Scenario: Enemy shader flash on hit

- **WHEN** enemy takes damage
- **THEN** enemy sprite's `ShaderMaterial` `flash_intensity` is set to 1.0 (white)
- **AND** `flash_intensity` tweens to 0.0 over 0.08 seconds

#### Scenario: Enemy impulse knockback on hit

- **WHEN** enemy takes damage
- **THEN** enemy receives a velocity impulse away from the damage source
- **AND** impulse magnitude is 80px (arrow) or 150px (melee), amplified on kill (120px/200px)
- **AND** velocity decays via `move_toward(Vector2.ZERO, 600.0 * delta)` each physics frame

#### Scenario: Enemy squash on hit

- **WHEN** enemy takes damage
- **THEN** enemy sprite scales to `(1.3, 0.7)` and tweens back to `(1.0, 1.0)` over 0.1 seconds

### Requirement: Enemy Death Effects

Enemies SHALL play death animation when HP reaches zero.

#### Scenario: Enemy death stretch

- **WHEN** enemy dies
- **THEN** enemy sprite scales to `(0.6, 1.4)` (death stretch)

#### Scenario: Enemy dissolve animation

- **WHEN** enemy dies
- **THEN** enemy stays visible for 2.5 seconds
- **AND** death smoke VFX spawns at enemy position
- **AND** sprite modulate alpha tweens from 1.0 to 0.0 over 1.0 seconds
- **AND** enemy is removed from scene after animation completes
- **AND** enemy_died signal is emitted via EventBus

### Requirement: Enemy Glow Layer

All enemies SHALL have a visible glow element (eyes, aura, or outline) using additive blend sprites for visual readability against any background.

#### Scenario: Enemy glow sprite setup

- **WHEN** an enemy is rendered
- **THEN** a child `Sprite2D` named `GlowSprite` is present with `CanvasItemMaterial(blend_mode = Add)`
- **AND** the glow texture covers the enemy's eyes or aura region

#### Scenario: Shadow Wisp glow

- **WHEN** a Shadow Wisp is rendered
- **THEN** it has a cyan glow on its core/eyes (color temperature: cool)
- **AND** the glow pixels are at least 40% brighter than the darkest expected background tile

#### Scenario: Shadow Crawler/Stalker/Brute glow

- **WHEN** a Shadow Crawler, Stalker, or Brute is rendered
- **THEN** it has a warm glow (red/orange) on its eyes
- **AND** eye glow size is at least 3x3px for Crawler, 4x4px for Stalker/Brute

#### Scenario: Boss aura glow

- **WHEN** the Shadow Boar boss is rendered
- **THEN** it has a persistent 4-8px shadow/glow aura around its body
- **AND** the aura uses additive blend to dominate visual attention

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

