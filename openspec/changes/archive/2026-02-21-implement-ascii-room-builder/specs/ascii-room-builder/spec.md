## ADDED Requirements

### Requirement: ASCII Map Format

Room layouts SHALL be defined as multiline ASCII strings with a standard legend.

#### Scenario: Legend character mapping

- **WHEN** an ASCII map string is parsed
- **THEN** the following characters are recognized:
  - `#` → Wall tile (TERRAIN_WALL, has collision)
  - `.` → Floor tile (TERRAIN_FLOOR, walkable)
  - `P` → Player spawn (floor tile placed, position stored)
  - `E` → Enemy spawn (floor tile placed, position stored)
  - `B` → Boss spawn (floor tile placed, position stored)
  - `S` → Heal shrine (floor tile placed, position stored for shrine instantiation)
  - `X` → Exit portal (floor tile placed, position stored for portal spawn)
  - `O` → Obstacle/decoration (floor tile placed, position stored for destructible instantiation)
  - ` ` (space) → Void (no tile placed)

#### Scenario: Map dimensions are self-describing

- **WHEN** an ASCII map string is parsed
- **THEN** map width equals the longest line length
- **AND** map height equals the number of non-empty lines
- **AND** shorter lines are padded with spaces (void)

### Requirement: Wang Terrain Painting

The builder SHALL use Godot's terrain auto-tiling for correct tile transitions.

#### Scenario: Wall and floor terrain painting

- **WHEN** a room is built from an ASCII map
- **THEN** all wall cells are painted with `set_cells_terrain_connect()` using `TERRAIN_WALL` (terrain index 1)
- **AND** all floor cells are painted with `set_cells_terrain_connect()` using `TERRAIN_FLOOR` (terrain index 0)
- **AND** Wang corner transitions between wall and floor render automatically

#### Scenario: Border padding for clean edges

- **WHEN** a room is built from an ASCII map
- **THEN** a 1-tile border of wall terrain is added around the parsed map
- **AND** this border ensures outer wall tiles have correct neighbor context for terrain painting

### Requirement: Entity Position Extraction

The builder SHALL extract entity positions from the ASCII map and return them as world coordinates.

#### Scenario: Build output contains all positions

- **WHEN** `build_room()` completes
- **THEN** the returned dictionary contains:
  - `tile_layer` — TileMapLayer node with painted terrain
  - `player_spawn` — Vector2 world position of `P` marker
  - `enemy_spawns` — Array[Vector2] world positions of all `E` markers
  - `portal_position` — Vector2 world position of `X` marker
  - `shrine_position` — Vector2 world position of `S` marker (or Vector2.ZERO if none)
  - `boss_spawn` — Vector2 world position of `B` marker (or Vector2.ZERO if none)
  - `obstacle_positions` — Array[Vector2] world positions of all `O` markers

#### Scenario: Tile-to-world coordinate conversion

- **WHEN** entity positions are extracted
- **THEN** tile coordinates are converted to world pixel coordinates using `TileMapLayer.map_to_local()`
- **AND** entities are positioned at the center of their tile cell

### Requirement: Editor Preview

The builder SHALL support @tool script usage for in-editor room visualization.

#### Scenario: Editor preview button

- **WHEN** the room preview scene is open in the Godot editor
- **AND** the developer sets `room_index` and toggles the `build_room` export
- **THEN** the selected room renders in the editor viewport
- **AND** entity positions are shown as Marker2D nodes
- **AND** the preview clears previous content before rebuilding
