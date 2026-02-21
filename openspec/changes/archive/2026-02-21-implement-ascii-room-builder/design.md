# Design: ASCII Room Builder

## Overview

This design replaces the BSP procedural generation pipeline with a text-driven room building system. Rooms are defined as ASCII strings, parsed into tile grids, and rendered using Godot's Wang terrain auto-tiling system.

## Architecture

```
room_blueprints.gd          ascii_room_builder.gd         room_manager.gd
┌──────────────────┐        ┌─────────────────────┐       ┌──────────────────┐
│ ROOM_1_MAP = """ │        │ build_room(ascii,    │       │ load_room(index)  │
│ ###############  │───────▶│   tileset, config)   │◀──────│                  │
│ #......X......#  │        │                      │       │ Uses builder to   │
│ ...            │        │ Returns:             │       │ generate rooms    │
│ """            │        │  - TileMapLayer      │       │ on the fly        │
│                  │        │  - spawn_positions   │       └──────────────────┘
│ ROOMS = {        │        │  - portal_position   │
│   1: { map, ... }│        │  - shrine_position   │
│ }                │        │  - player_spawn      │
└──────────────────┘        └─────────────────────┘
```

## ASCII Parser Algorithm

### Step 1: Parse ASCII to Grid
```
Input: multiline string
Output: 2D array of characters + dimensions (width, height)

1. Split string by newline
2. Trim empty leading/trailing lines
3. Width = longest line length
4. Height = number of lines
5. Pad shorter lines with spaces
```

### Step 2: Classify Cells
```
For each cell (col, row):
  '#' → wall_cells.append(Vector2i(col, row))
  '.', 'P', 'E', 'B', 'S', 'X', 'O' → floor_cells.append(Vector2i(col, row))
  'P' → player_spawn = Vector2i(col, row)
  'E' → enemy_spawns.append(Vector2i(col, row))
  'B' → boss_spawn = Vector2i(col, row)
  'S' → shrine_position = Vector2i(col, row)
  'X' → portal_position = Vector2i(col, row)
  'O' → obstacle_positions.append(Vector2i(col, row))
  ' ' → skip (void, no tile)
```

### Step 3: Add Border Padding
Add a 1-tile border of wall cells around the entire parsed map. This ensures Wang terrain transitions at room edges render correctly (outer walls have proper neighbor context).

```
For x in range(-1, width + 1):
  For y in range(-1, height + 1):
    if (x, y) is outside the parsed map bounds:
      wall_cells.append(Vector2i(x, y))
```

### Step 4: Paint Terrain
Use Godot's `set_cells_terrain_connect()` for automatic Wang tile selection:

```gdscript
# Paint walls first (terrain 1) — fills border + interior walls
tile_layer.set_cells_terrain_connect(wall_cells, 0, TERRAIN_WALL, false)

# Paint floors second (terrain 0) — overwrites walls where floor exists
tile_layer.set_cells_terrain_connect(floor_cells, 0, TERRAIN_FLOOR, false)
```

The Wang terrain system automatically selects the correct tile variant for each cell based on its neighbors (corners, edges, transitions). This produces clean wall-to-floor transitions without manual tile selection.

### Step 5: Convert Positions to World Coordinates
Entity positions stored as `Vector2i` tile coordinates are converted to world pixel coordinates using TileMapLayer's built-in conversion:

```gdscript
var world_pos: Vector2 = tile_layer.map_to_local(tile_coord)
```

This returns the center of the tile cell in world space (e.g., tile (7, 5) at 32px tiles → Vector2(240, 176)).

## Room Blueprints Data Structure

```gdscript
class_name RoomBlueprints

# Room configuration structure
# Each room entry contains:
#   map: String — ASCII layout
#   type: String — "combat", "heal", "boss"
#   waves: Array[Dictionary] — enemy wave configs
#   tileset: String — resource path to TileSet

static var ROOMS: Dictionary = {
    0: {
        "map": ROOM_1_MAP,
        "type": "combat",
        "tileset": "res://assets/tilesets/jungle_ruins.tres",
        "waves": [
            { "enemy_type": &"shadow_wisp", "count": 3, "spawn_delay": 0.5, "wave_delay": 0.0 }
        ]
    },
    # ... rooms 1-6
}
```

## Room Designs (Stage 1)

All rooms follow the GDD room configuration (§ Room Configuration).

### Sizing Strategy

| Room | Tiles (WxH) | Pixels | Rationale |
|------|-------------|--------|-----------|
| 1 (Combat) | 15x11 | 480x352 | Viewport-width, simple tutorial |
| 2 (Combat) | 17x11 | 544x352 | Slightly wider for mixed combat |
| 3 (Heal) | 15x9 | 480x288 | Compact, peaceful |
| 4 (Combat) | 17x13 | 544x416 | Taller for stalker teleport space |
| 5 (Combat) | 19x13 | 608x416 | Wide arena for all enemy types |
| 6 (Heal) | 15x9 | 480x288 | Compact, pre-boss rest |
| 7 (Boss) | 21x15 | 672x480 | Large arena for charge attacks |

Viewport is 480x270 (15x8.4 tiles). Rooms 1/3/6 fit within one viewport width. Larger rooms scroll with the camera.

### Design Principles

1. **Player spawn at bottom, portal at top** — consistent spatial flow, player progresses "upward"
2. **Interior wall blocks as cover** — `####` segments create pillars/walls for dodging
3. **Obstacles near spawn** — `O` markers for target practice before enemies engage
4. **Symmetric or near-symmetric layouts** — fair from all approach angles
5. **Choke points in later rooms** — narrow passages force careful aim
6. **Large boss arena** — open space for Shadow Boar charge patterns
7. **Escalating complexity** — Room 1 is empty, Room 5 has pillars and scattered spawns

## @tool Editor Preview

The builder script is `@tool`-compatible for in-editor visualization:

```gdscript
@tool
extends Node2D

@export var room_index: int = 0
@export var tileset: TileSet

@export var build_room: bool = false:
    set(value):
        if value and Engine.is_editor_hint():
            _preview_room()
            build_room = false
```

When the developer toggles "Build Room" in the inspector:
1. Clears existing TileMapLayer children
2. Parses the ASCII map for the selected room_index
3. Creates a TileMapLayer with terrain tiles
4. Adds Marker2D nodes at entity positions (color-coded)
5. Room is visible in the editor viewport without running the game

This is a preview-only feature. At runtime, `RoomManager` calls the builder directly.

## Integration with Existing Systems

### RoomManager Changes

Current flow:
```
RoomManager.load_room(index)
  → room_data.room_scene.instantiate()  (loads pre-built .tscn)
  → _setup_combat_room() / _setup_heal_room() / _setup_boss_room()
```

New flow:
```
RoomManager.load_room(index)
  → AsciiRoomBuilder.build_room(blueprint)  (generates from ASCII)
  → Returns TileMapLayer + positions
  → _setup_combat_room() / _setup_heal_room() / _setup_boss_room()
  → Uses returned spawn positions instead of hardcoded ones
```

Key change: spawn positions come from the ASCII map (`E`, `P`, `X`, `S`, `B` markers) instead of being hardcoded in `_get_spawn_positions_for_room()` or stored in Marker2D nodes.

### Enemy Wave System (Unchanged)

The existing wave system in `RoomManager` (`_get_enemy_waves_for_room()`) remains. It defines WHAT spawns and WHEN. The ASCII map `E` markers define WHERE. The wave system cycles through spawn positions in order:

```
Wave: 3x shadow_wisp, spawn_delay=0.5
Positions from ASCII: [E1, E2, E3]
Result: wisp at E1 (0s), wisp at E2 (0.5s), wisp at E3 (1.0s)
```

This separation of concerns (positions in map, waves in config) keeps the system flexible.

## BSP Cleanup

The following files from the procedural generation system will be removed:

| File | Reason |
|------|--------|
| `stage_generator.gd` | BSP algorithm, replaced by ASCII builder |
| `stage_config.gd` | Procedural config, not needed for linear |
| `stage_data.gd` | Generated data container, replaced by builder output |
| `room_data.gd` | BSP partition tree node, not related to room content |
| `run_manager.gd` | Roguelite run management, not needed for linear MVP |
| `base_stage.tscn` | Procedural stage scene, replaced by game.tscn |
| `default_stage.tres` | Procedural config resource |
| `room_*.tscn` (1-7) | Pre-built room scenes, replaced by ASCII |
| `room_template.tscn` | Room template, no longer needed |
| `room_*.tres` (1-7) | Room config resources, data moves to blueprints |
| `test_stage_generator.*` | Tests for BSP system |
| `test_stage_headless.gd` | Headless BSP test |

**Kept files**: `linear_stage_config.gd`, `room_data_resource.gd`, `enemy_wave_data.gd`, `enemy_spawn_data.gd`, `pixellab_tileset_converter.gd`, all tilesets.
