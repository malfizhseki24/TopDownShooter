# sun-piercer Specification

## Purpose
TBD - created by archiving change add-combat-economy. Update Purpose after archive.
## Requirements
### Requirement: Special Attack Input

The player SHALL be able to trigger the Sun-Piercer attack with a dedicated input when the Energy Meter is full.

#### Scenario: Special attack input mapped

- **WHEN** player presses the "special_attack" input action
- **THEN** it is bound to Mouse Right Button and Space key
- **AND** both inputs trigger the same action

#### Scenario: Special attack triggers when ready

- **WHEN** player presses special_attack input
- **AND** Energy Meter is full (ready state)
- **AND** player is not in windup or firing state
- **THEN** Sun-Piercer windup begins

#### Scenario: Special attack blocked when not ready

- **WHEN** player presses special_attack input
- **AND** Energy Meter is not full
- **THEN** no action occurs
- **AND** no SFX or visual feedback plays

### Requirement: Sun-Piercer Windup

The Sun-Piercer SHALL have a brief windup period that builds anticipation before firing.

#### Scenario: Windup duration and visuals

- **WHEN** Sun-Piercer windup begins
- **THEN** player enters windup state for 0.25 seconds
- **AND** player sprite flashes (0.05s intervals)
- **AND** screen shake triggers (0.2 trauma)
- **AND** windup SFX plays (charging sound)

#### Scenario: Windup locks player movement

- **WHEN** player is in windup state
- **THEN** player movement speed is reduced to 30% of normal
- **AND** player can still change aim direction
- **AND** normal shoot input is ignored

#### Scenario: Windup completes and fires

- **WHEN** 0.25 second windup duration elapses
- **THEN** Sun-Piercer projectile spawns at player position
- **AND** projectile direction matches player aim direction
- **AND** `energy_meter_emptied` signal is emitted
- **AND** `special_attack_fired` signal is emitted with direction
- **AND** fire SFX plays (whoosh)
- **AND** camera pushes slightly in fire direction

### Requirement: Sun-Piercer Projectile Movement

The Sun-Piercer projectile SHALL travel rapidly in a straight line with visual trail effects.

#### Scenario: Projectile speed and direction

- **WHEN** Sun-Piercer projectile spawns
- **THEN** it moves at 400 pixels per second
- **AND** direction is set from player aim at time of fire

#### Scenario: Projectile visual properties

- **WHEN** Sun-Piercer is rendered
- **THEN** sprite size is 32x16 viewport pixels (elliptical)
- **AND** sprite color is bright orange (#ff8800) with white core
- **AND** PointLight2D glow radius is 32px at 60% energy
- **AND** glow color is #ffaa00

#### Scenario: Projectile trail particles

- **WHEN** Sun-Piercer is traveling
- **THEN** fire trail particles emit from the rear
- **AND** particles are orange-yellow gradient
- **AND** particle lifetime is 0.3 seconds

#### Scenario: Projectile lifetime

- **WHEN** Sun-Piercer has existed for 2 seconds
- **OR** Sun-Piercer leaves the viewport bounds
- **THEN** projectile is freed
- **AND** fade-out particle dispersion spawns

### Requirement: Sun-Piercer Damage and Pierce

The Sun-Piercer SHALL deal high damage and pierce through multiple enemies and obstacles.

#### Scenario: Damage on enemy hit

- **WHEN** Sun-Piercer collides with an enemy
- **THEN** enemy takes 80 damage (3x normal arrow damage)
- **AND** `special_attack_hit` signal is emitted
- **AND** damage number spawns (gold color, #ffdd44)

#### Scenario: Unlimited enemy pierce

- **WHEN** Sun-Piercer hits an enemy
- **THEN** projectile continues through the enemy
- **AND** is not destroyed
- **AND** hit cooldown prevents re-hitting same enemy for 0.1s

#### Scenario: Limited obstacle pierce

- **WHEN** Sun-Piercer collides with a wall or destructible
- **THEN** obstacle pierce counter increments
- **AND** projectile continues if counter < 3
- **AND** projectile is destroyed if counter >= 3

#### Scenario: Destructible interaction

- **WHEN** Sun-Piercer collides with a destructible object
- **THEN** destructible is destroyed (1 hit)
- **AND** pierce counter still increments

### Requirement: Sun-Piercer Hit Feedback

The Sun-Piercer SHALL trigger significant juice effects on each enemy hit.

#### Scenario: Hitstop on enemy impact

- **WHEN** Sun-Piercer hits an enemy
- **THEN** hitstop triggers for 0.15 seconds
- **AND** hitstop affects all game objects except HUD

#### Scenario: Screen shake on impact

- **WHEN** Sun-Piercer hits an enemy
- **THEN** screen shake triggers (0.1 trauma per hit)
- **AND** multiple hits stack shake (up to 0.5 trauma max)

#### Scenario: Enemy hit flash

- **WHEN** Sun-Piercer damages an enemy
- **THEN** enemy hit_flash shader activates
- **AND** flash duration is 0.15 seconds

#### Scenario: Impact particle burst

- **WHEN** Sun-Piercer hits an enemy
- **THEN** orange-white particle burst spawns at impact point
- **AND** burst contains 8-12 particles
- **AND** particles scatter outward (100-150 px/s)

### Requirement: Sun-Piercer Collision Configuration

The Sun-Piercer projectile SHALL use appropriate collision layers and masks.

#### Scenario: Collision layer setup

- **WHEN** Sun-Piercer is configured
- **THEN** collision layer is "arrow" layer
- **AND** collision mask includes "enemy" layer
- **AND** collision mask includes "wall" layer

#### Scenario: Collision shape

- **WHEN** Sun-Piercer collision is defined
- **THEN** CollisionShape2D is RectangleShape2D (32x12 pixels)
- **AND** shape is aligned with projectile direction

