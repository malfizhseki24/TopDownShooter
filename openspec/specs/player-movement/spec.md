# player-movement Specification

## Purpose
TBD - created by archiving change phase-1-foundation. Update Purpose after archive.
## Requirements
### Requirement: 8-Directional Movement

The player SHALL move in 8 directions based on keyboard input at 200 pixels per second.

#### Scenario: Player moves with input

- **WHEN** player presses movement keys (WASD or arrow keys)
- **THEN** player moves in the corresponding direction
- **AND** movement speed is 200 px/sec

#### Scenario: Diagonal movement normalized

- **WHEN** player presses two movement keys simultaneously (e.g., W + D)
- **THEN** player moves diagonally
- **AND** diagonal speed is normalized (not faster than cardinal directions)

#### Scenario: Player stops on no input

- **WHEN** player releases all movement keys
- **THEN** player velocity becomes zero
- **AND** player stops moving immediately

### Requirement: Collision Detection

The player SHALL collide with walls and obstacles.

#### Scenario: Player blocked by walls

- **WHEN** player attempts to move into a wall
- **THEN** player stops at the wall boundary
- **AND** player does not pass through the wall

### Requirement: Movement in Physics Process

Player movement SHALL be processed in `_physics_process` for consistent physics behavior.

#### Scenario: Movement frame rate independent

- **WHEN** game runs at different frame rates
- **THEN** player movement speed remains consistent
- **AND** movement uses delta time for calculations

