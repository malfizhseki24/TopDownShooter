## ADDED Requirements

### Requirement: Dash Afterimages

The player's dash SHALL produce 3-4 fading ghost sprite copies to create a speed trail effect.

#### Scenario: Afterimage spawning during dash

- **WHEN** the player initiates a dash
- **THEN** a ghost sprite is spawned at the player's position every 0.05 seconds during the 0.2s dash
- **AND** each ghost captures the player's current animation frame texture
- **AND** each ghost starts at 60% opacity and fades to 0% over 0.15 seconds
- **AND** the ghost self-frees after fading

### Requirement: Arrow Trail

Arrows SHALL have a subtle particle trail using `GPUParticles2D`.

#### Scenario: Arrow trail particles

- **WHEN** an arrow is in flight
- **THEN** a `GPUParticles2D` child emits small fading dots at ~30 particles/second
- **AND** each particle has a lifetime of 0.2 seconds and fades to transparent
- **AND** particles are 2-3px in size, colored to match the arrow sprite

#### Scenario: Arrow trail stops on impact

- **WHEN** an arrow hits an enemy, boss, or wall
- **THEN** the `GPUParticles2D.emitting` is set to `false`
- **AND** remaining particles fade naturally before the arrow is freed

### Requirement: Portal VFX

Portals SHALL have visual effects for idle, activation, and travel states.

#### Scenario: Portal idle shimmer

- **WHEN** a portal is present in a room (locked or unlocked)
- **THEN** subtle floating particles shimmer around the portal
- **AND** locked portals show a dimmer/slower version of the shimmer

#### Scenario: Portal activation burst

- **WHEN** all enemies in a room are defeated and the portal unlocks
- **THEN** a particle burst plays at the portal position
- **AND** the idle shimmer transitions to a brighter, more active version

#### Scenario: Portal travel effect

- **WHEN** the player enters an active portal
- **THEN** a warp particle burst plays at the portal
- **AND** a brief visual effect (particle implosion or screen flash) signals the transition

### Requirement: Heal Shrine VFX

Heal shrines SHALL have idle particles and a use effect.

#### Scenario: Heal shrine idle glow

- **WHEN** a heal shrine is available (not yet used)
- **THEN** subtle green floating particles hover around the shrine

#### Scenario: Heal shrine use effect

- **WHEN** the player uses a heal shrine
- **THEN** a green particle spiral moves upward from the shrine over 0.8 seconds
- **AND** the idle glow particles stop (shrine is consumed)

### Requirement: Spawn Emerge VFX

Enemies SHALL play a spawn emergence animation when entering the room.

#### Scenario: Enemy spawn scale animation

- **WHEN** an enemy spawns
- **THEN** the enemy sprite scales from `(0, 0)` to `(1.1, 0.9)` to `(1.0, 1.0)` over 0.3 seconds
- **AND** the enemy is invulnerable during the spawn animation

#### Scenario: Enemy spawn smoke

- **WHEN** an enemy spawns
- **THEN** a dark smoke puff particle effect plays at the spawn position
- **AND** the smoke effect is a one-shot that self-frees
