# bow-arrow Specification

## Purpose
TBD - created by archiving change phase-1-foundation. Update Purpose after archive.
## Requirements
### Requirement: Arrow Firing

The player SHALL fire arrows when the shoot input is pressed.

#### Scenario: Arrow spawns on shoot input

- **WHEN** player presses shoot button (left click)
- **THEN** an arrow spawns at player position
- **AND** arrow travels in aim direction

#### Scenario: Arrow speed

- **WHEN** arrow is fired
- **THEN** arrow travels at 600 px/sec
- **AND** velocity is constant (no deceleration)

### Requirement: Fire Rate Limiting

Arrows SHALL fire at a maximum rate of one arrow every 0.5 seconds.

#### Scenario: Fire rate enforced

- **WHEN** player holds shoot button
- **THEN** arrows fire at most once every 0.5 seconds
- **AND** no arrows are skipped or doubled

#### Scenario: Fire rate cooldown

- **WHEN** an arrow is fired
- **THEN** fire cooldown timer starts (0.5 sec)
- **AND** next arrow cannot fire until cooldown expires

### Requirement: Infinite Ammo

The player SHALL have unlimited arrows.

#### Scenario: No ammo restriction

- **WHEN** player fires many arrows
- **THEN** arrow count is not tracked
- **AND** player can always fire (subject to fire rate)

### Requirement: Arrow Lifetime

Arrows SHALL despawn after 3 seconds if they do not hit anything.

#### Scenario: Arrow despawns on timeout

- **WHEN** an arrow has been traveling for 3 seconds
- **THEN** arrow is removed from scene
- **AND** no memory leak occurs

### Requirement: Arrow Collision

Arrows SHALL detect collisions with enemies and walls.

#### Scenario: Arrow hits wall

- **WHEN** arrow collides with a wall
- **THEN** arrow is removed from scene
- **AND** no damage is dealt

#### Scenario: Arrow hits enemy

- **WHEN** arrow collides with an enemy
- **THEN** arrow is removed from scene
- **AND** enemy takes 25 damage

### Requirement: Arrow Physics Layer

Arrows SHALL be on the `arrow` physics layer and collide with `enemy` and `wall` layers.

#### Scenario: Arrow layer configuration

- **WHEN** arrow is spawned
- **THEN** arrow is on layer 3 (arrow)
- **AND** arrow collides with layers 2 (enemy) and 4 (wall)
- **AND** arrow does not collide with layer 1 (player)

