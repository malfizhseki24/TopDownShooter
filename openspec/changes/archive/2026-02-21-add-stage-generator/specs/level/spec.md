## ADDED Requirements

### Requirement: Stage Generation
The game SHALL procedurally generate stage maps using BSP tree algorithm with configurable parameters.

#### Scenario: Generate stage from seed
- **WHEN** stage scene loads with a seed value
- **THEN** a unique but reproducible map is generated with rooms, corridors, and walls

#### Scenario: Generate random stage
- **WHEN** stage scene loads with seed value -1
- **THEN** a random map is generated using system time as seed

#### Scenario: Regenerate stage
- **WHEN** regenerate() is called during gameplay
- **THEN** the current map is cleared and a new map is generated

---

### Requirement: Room Layout
The generator SHALL create rectangular rooms connected by corridors within the map bounds.

#### Scenario: Room creation
- **WHEN** BSP partitioning completes
- **THEN** rooms are created in leaf nodes with sizes between min_room_size and max_room_size

#### Scenario: Room connectivity
- **WHEN** all rooms are placed
- **THEN** every room is reachable from every other room via corridors

#### Scenario: Boss room placement
- **WHEN** boss_room_enabled is true
- **THEN** the furthest room from player spawn is designated as boss room

---

### Requirement: TileMap Structure
The generator SHALL populate TileMapLayer nodes with appropriate tiles and collision.

#### Scenario: Ground tiles
- **WHEN** tiles are placed
- **THEN** ground layer contains floor tiles in rooms and corridors with no collision

#### Scenario: Wall tiles
- **WHEN** tiles are placed
- **THEN** wall layer contains wall tiles at boundaries with physics collision enabled

#### Scenario: Map bounds
- **WHEN** map is generated
- **THEN** outer edges of the map are solid walls preventing player escape

---

### Requirement: Spawn Points
The generator SHALL place spawn points for player and enemies based on room layout.

#### Scenario: Player spawn
- **WHEN** map generation completes
- **THEN** player spawn point is placed in the first (entrance) room

#### Scenario: Enemy spawns
- **WHEN** map generation completes
- **THEN** enemy spawn points are distributed in rooms based on enemy_density

#### Scenario: Enemy type selection
- **WHEN** placing enemy spawns
- **THEN** enemy types are selected based on room characteristics and progression

---

### Requirement: Stage Configuration
The generator SHALL accept configuration via StageConfig resource for customizable output.

#### Scenario: Configure map size
- **WHEN** StageConfig.map_size is set
- **THEN** generated map fits within specified tile dimensions

#### Scenario: Configure room parameters
- **WHEN** StageConfig room parameters are set
- **THEN** rooms are generated within specified size and count ranges

#### Scenario: Configure enemy density
- **WHEN** StageConfig.enemy_density is set
- **THEN** enemy count scales proportionally to room area
