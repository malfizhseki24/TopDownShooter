## ADDED Requirements

### Requirement: Room Transition Visual Feedback

Room transitions SHALL provide visual feedback via a black fade overlay.

#### Scenario: Fade to black on room exit

- **WHEN** player enters a portal and room transition begins
- **THEN** screen fades to black over 0.3 seconds
- **AND** room loads while screen is black
- **AND** screen fades back in over 0.3 seconds

### Requirement: Static Obstacle Placement

Rooms SHALL spawn static obstacle props at ASCII `O` marker positions.

#### Scenario: Obstacles spawn from blueprint

- **WHEN** a room is loaded from its ASCII blueprint
- **THEN** a static pillar is instantiated at each `O` marker position
- **AND** pillar collides on physics layer 4 (wall)
- **AND** player, enemies, and arrows are blocked by the pillar

#### Scenario: Obstacles cleared on room change

- **WHEN** a new room is loaded
- **THEN** all obstacles from the previous room are removed
