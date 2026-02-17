# player-aiming Specification

## Purpose
TBD - created by archiving change phase-1-foundation. Update Purpose after archive.
## Requirements
### Requirement: Mouse-Based Aiming

The player SHALL aim toward the mouse cursor position.

#### Scenario: Aim direction calculated

- **WHEN** mouse cursor is at any position on screen
- **THEN** player calculates direction vector from player to mouse
- **AND** direction vector is normalized

#### Scenario: Aim direction updates continuously

- **WHEN** player moves mouse
- **THEN** aim direction updates in real-time
- **AND** no perceptible input lag

### Requirement: Global Mouse Position

Aiming SHALL use global coordinates to correctly handle camera offset.

#### Scenario: Aiming works with camera offset

- **WHEN** camera is not at world origin
- **THEN** aim direction is calculated using `get_global_mouse_position()`
- **AND** aiming is accurate regardless of camera position

### Requirement: Aim Direction Accessible

The current aim direction SHALL be accessible for arrow spawning.

#### Scenario: Aim direction available to bow system

- **WHEN** bow system needs to spawn an arrow
- **THEN** player provides current aim direction
- **AND** direction is a normalized Vector2

