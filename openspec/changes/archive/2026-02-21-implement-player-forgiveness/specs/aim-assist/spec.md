# aim-assist Specification

## Purpose

Defines the invisible aim assist (soft magnetism) system for arrows, making ranged combat forgiving without the player being aware of the assistance.

## ADDED Requirements

### Requirement: Arrow Soft Magnetism

Arrows SHALL have their trajectory subtly adjusted toward nearby enemies at the moment of firing.

#### Scenario: Arrow bends toward enemy in cone

- **WHEN** player fires an arrow
- **AND** an enemy is within a 12° half-angle cone from the aim direction
- **AND** enemy is within 300 px of the player
- **THEN** arrow direction is rotated toward the enemy by up to 8°
- **AND** the correction is applied once at spawn (arrow then flies straight)

#### Scenario: Nearest enemy in cone is prioritized

- **WHEN** multiple enemies are within the aim cone
- **THEN** the enemy with the smallest angle offset from aim direction is chosen
- **AND** arrow bends toward that enemy

#### Scenario: No correction when no enemy in cone

- **WHEN** player fires an arrow
- **AND** no enemy is within the 12° cone at 300 px range
- **THEN** arrow fires in the exact aim direction
- **AND** no correction is applied

#### Scenario: Aim assist is invisible

- **WHEN** aim assist adjusts an arrow's trajectory
- **THEN** no visual indicator shows the correction
- **AND** no aim reticle snapping occurs
- **AND** the arrow appears to fly naturally

### Requirement: Arrow Hitbox Size

Arrow collision shapes SHALL be larger than the visual arrow sprite to provide generous hit detection.

#### Scenario: Arrow hitbox is oversized

- **WHEN** an arrow is spawned
- **THEN** arrow CollisionShape2D is a Circle with radius 7 px
- **AND** this is approximately 175% of the visual arrow width
- **AND** the larger hitbox makes near-miss arrows connect with enemies
