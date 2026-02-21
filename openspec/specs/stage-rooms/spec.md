# stage-rooms Specification

## Purpose
TBD - created by archiving change implement-ascii-room-builder. Update Purpose after archive.
## Requirements
### Requirement: Stage 1 Room Progression

Stage 1 SHALL consist of 7 rooms in fixed linear order with escalating difficulty.

#### Scenario: Room sequence matches GDD

- **WHEN** Stage 1 is loaded
- **THEN** rooms are presented in order:
  - Room 1: Combat (3x Shadow Wisp) — tutorial difficulty
  - Room 2: Combat (2x Wisp + 2x Crawler) — mixed enemy types
  - Room 3: Heal Shrine — rest point
  - Room 4: Combat (2x Wisp + 2x Crawler + 1x Stalker) — stalker introduced
  - Room 5: Combat (3x Crawler + 2x Stalker + 1x Brute) — all enemy types
  - Room 6: Heal Shrine — rest before boss
  - Room 7: Boss (Shadow Boar placeholder) — final encounter

#### Scenario: Room type determines behavior

- **WHEN** a combat room is loaded
- **THEN** enemy waves spawn at `E` positions
- **AND** portal spawns at `X` position after all enemies defeated
- **WHEN** a heal room is loaded
- **THEN** heal shrine spawns at `S` position
- **AND** portal spawns immediately (no enemies)
- **WHEN** a boss room is loaded
- **THEN** boss spawns at `B` position
- **AND** victory triggers on boss death (no portal)

### Requirement: Room Layout Design

Each room layout SHALL be designed for top-down bow combat readability and fair gameplay.

#### Scenario: Consistent spatial flow

- **WHEN** any room is rendered
- **THEN** player spawn (`P`) is at the bottom center
- **AND** exit portal (`X`) is at the top center
- **AND** the player progresses "upward" through each room

#### Scenario: Combat rooms have cover

- **WHEN** a combat room layout is defined
- **THEN** interior wall blocks (`#` segments) provide cover for dodging
- **AND** enemy spawn positions (`E`) are distributed across the room (not clustered)
- **AND** no enemy spawns within 3 tiles of the player spawn

#### Scenario: Room sizes escalate with difficulty

- **WHEN** comparing room dimensions
- **THEN** early rooms (1, 3, 6) are viewport-width or smaller (15 tiles wide)
- **AND** mid rooms (2, 4) are slightly wider (17 tiles)
- **AND** late rooms (5) are arena-sized (19 tiles wide)
- **AND** boss room (7) is the largest (21 tiles wide)

### Requirement: Room Blueprints Central Data

All room definitions SHALL be stored in a single `RoomBlueprints` class for easy editing and AI iteration.

#### Scenario: Blueprint data structure

- **WHEN** `RoomBlueprints.ROOMS` dictionary is accessed
- **THEN** each room entry contains:
  - `map` — ASCII string defining the layout
  - `type` — Room type string ("combat", "heal", "boss")
  - `tileset` — Resource path to TileSet for this room
  - `waves` — Array of enemy wave dictionaries (for combat rooms)

#### Scenario: Wave configuration per room

- **WHEN** a combat room blueprint is accessed
- **THEN** `waves` array contains one or more wave dictionaries with:
  - `enemy_type` — StringName identifying the enemy scene
  - `count` — Number of enemies in this wave
  - `spawn_delay` — Seconds between individual enemy spawns in the wave
  - `wave_delay` — Seconds before this wave begins (after previous wave)

### Requirement: Boss Room Setup

Room 7 SHALL spawn the Shadow Boar boss instead of a placeholder enemy.

#### Scenario: Boss room loads Shadow Boar

- **WHEN** RoomManager loads Room 7 (type: boss)
- **THEN** Shadow Boar scene is instantiated at B marker position
- **AND** boss is added to entities node
- **AND** boss is tracked in enemies_in_room count
- **AND** boss_spawned signal is emitted via EventBus

#### Scenario: Boss room clears on boss death

- **WHEN** Shadow Boar dies in Room 7
- **THEN** enemies_in_room reaches 0
- **AND** room is marked as cleared
- **AND** all_rooms_cleared signal triggers victory flow

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

