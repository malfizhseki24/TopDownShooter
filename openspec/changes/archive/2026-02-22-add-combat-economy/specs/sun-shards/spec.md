# sun-shards Specification Delta

## Purpose
Energy pickup items dropped by defeated enemies. Sun Shards are crystalline fragments that feature physics-based spawn behavior and magnetic attraction to the player.

## ADDED Requirements

### Requirement: Shard Drop on Enemy Death

Defeated enemies SHALL have a chance to spawn a Sun Shard pickup at their death position.

#### Scenario: Enemy drops shard on death

- **WHEN** an enemy dies
- **AND** a random roll succeeds (60% base chance)
- **THEN** a Sun Shard spawns at the enemy's global position
- **AND** the `shard_dropped` signal is emitted

#### Scenario: Enemy does not drop shard

- **WHEN** an enemy dies
- **AND** a random roll fails (40% chance)
- **THEN** no shard spawns
- **AND** no signal is emitted

### Requirement: Shard Spawn Physics

Sun Shards SHALL spawn with an upward velocity burst and bounce before settling into an idle state.

#### Scenario: Shard spawns with upward velocity

- **WHEN** a shard is spawned
- **THEN** it receives a random upward velocity (80-120 px/s)
- **AND** it receives a random horizontal velocity (-30 to +30 px/s)

#### Scenario: Shard bounces on ground

- **WHEN** shard velocity.y > 0 and shard touches ground
- **THEN** velocity.y is multiplied by -0.5 (bounce dampening)
- **AND** velocity.x is multiplied by 0.8 (friction)

#### Scenario: Shard settles into idle

- **WHEN** shard total velocity < 10 px/s
- **THEN** physics simulation stops
- **AND** idle bob animation begins (±2px vertical, 1.5s cycle)
- **AND** occasional sparkle effect plays (random interval 1-3s)

### Requirement: Shard Magnetic Pull

Sun Shards SHALL be attracted to the player when within magnetic range.

#### Scenario: Shard detects nearby player

- **WHEN** player is within 80 pixels of a shard
- **THEN** the shard enters magnetic pull state
- **AND** accelerates towards the player (200 px/s²)

#### Scenario: Shard stretches during pull

- **WHEN** shard is in magnetic pull state
- **THEN** sprite stretches in movement direction (max 1.3x scale)
- **AND** stretch returns to normal on collection

#### Scenario: Shard collected by player

- **WHEN** shard collides with player HurtboxArea
- **THEN** `shard_collected` signal is emitted
- **AND** collection particle burst spawns (5-8 white-yellow sparkles)
- **AND** collection SFX plays
- **AND** shard scales from 1.0 to 1.3 to 0 over 0.2s
- **AND** shard is freed after tween completes

### Requirement: Shard Auto-Collect Timeout

Sun Shards SHALL automatically collect after a timeout to prevent room clutter.

#### Scenario: Shard auto-collects after timeout

- **WHEN** a shard has existed for 5 seconds without being collected
- **THEN** `shard_collected` signal is emitted
- **AND** shard is freed immediately (no animation)

### Requirement: Shard Visual Design

Sun Shards SHALL have a distinctive crystalline visual appearance with glow effect.

#### Scenario: Shard visual properties

- **WHEN** a shard is rendered
- **THEN** sprite size is 8x8 viewport pixels
- **AND** sprite shape is diamond/rhombus (crystal fragment)
- **AND** sprite color is golden yellow (#ffdd44)
- **AND** PointLight2D glow radius is 16px at 30% energy
- **AND** glow color is #ffdd44

#### Scenario: Shard collision properties

- **WHEN** a shard checks for collisions
- **THEN** CollisionShape2D is CircleShape2D with radius 12px
- **AND** collision layer is 0 (no layer)
- **AND** collision mask is player layer only
