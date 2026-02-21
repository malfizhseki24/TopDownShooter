# Design: Stage Generator Engine

## Context

For "WARRIOR OF THE SUNRISE", a top-down action shooter with stage-based progression, we need a procedural stage generator that creates varied but playable maps. The generator should support:
- Linear progression toward boss arena (per GDD)
- Enemy encounter areas
- Consistent collision and navigation
- Seed-based reproducibility

---

## Gameplay Concept: Roguelite Structure

### Core Loop
```
┌─────────────────────────────────────────────────────────────┐
│                     GAME FLOW                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Main Menu ────> Generate Stage ────> Fight Through Rooms  │
│        ▲                           │              │         │
│        │                           ▼              ▼         │
│        │                    ┌──────────┐   ┌──────────┐    │
│        │                    │ Die!     │   │ Boss     │    │
│        │                    │ New Seed │   │ Fight!   │    │
│        │                    └──────────┘   └────┬─────┘    │
│        │                                        │          │
│        └────────────────────────────────────────┤          │
│                               ┌─────────────────┴─────┐    │
│                               │ Victory!              │    │
│                               │ New Game+ (harder)    │    │
│                               └───────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Roguelite?
- **Replayability**: Every run is different (new layout, enemy positions)
- **Fits Theme**: Kasuari's "redemption journey" - try again after failure
- **Modern Appeal**: Popular genre (Hades, Dead Cells, Enter the Gungeon)
- **Development Efficiency**: One procedural stage = infinite content

### Difficulty Progression
| Run Count | Enemy Density | Room Count | Notes |
|-----------|---------------|------------|-------|
| 1-2 | 0.2 | 4-6 | Easy, tutorial-like |
| 3-5 | 0.3 | 5-8 | Normal difficulty |
| 6+ | 0.4 | 6-10 | Hard mode |

### Daily Challenge Mode (Optional)
```gdscript
# Same seed for all players on same day
var date = Time.get_date_dict_from_system()
var daily_seed = hash(str(date.year) + str(date.month) + str(date.day))
```
- Players compete for best time/score
- Leaderboard integration possible

---

## Goals / Non-Goals

### Goals
- Generate procedural top-down maps with rooms and corridors
- Place enemy spawn points based on room types
- Create proper TileMapLayer structures for collision
- Support seed-based generation for reproducibility
- Allow runtime regeneration

### Non-Goals
- 3D map generation
- Infinite/open world generation
- Real-time chunk streaming (map fits in memory)
- Save/load of generated maps (regenerate from seed)
- Complex WFC implementation (initial MVP uses simpler BSP)

---

## Technical Decisions

### Decision 1: BSP Tree Algorithm for Room Layout

**Choice**: Binary Space Partitioning (BSP)

**Rationale**:
- Well-suited for dungeon/room layouts
- Creates non-overlapping rooms with natural corridors
- Predictable and controllable output
- Easier to implement than WFC for MVP
- Good balance between variety and structure

**Alternatives Considered**:
| Algorithm | Pros | Cons |
|-----------|------|------|
| **BSP Tree** | Clean room separation, easy corridors | Can feel formulaic |
| **Cellular Automata** | Natural cave-like shapes | Hard to control room placement |
| **Wave Function Collapse** | Very coherent outputs | Complex to implement, slower |
| **Drunkard's Walk** | Simple, organic shapes | Unpredictable room sizes |

### Decision 2: TileMapLayer Architecture

**Choice**: Separate TileMapLayer nodes per layer type

**Rationale**:
- Godot 4.x deprecated single `TileMap` in favor of `TileMapLayer`
- Each layer gets its own node for:
  - **GroundLayer**: Floor tiles (no collision)
  - **WallLayer**: Wall tiles (with collision)
  - **DecorationLayer**: Props, details (no collision)

**Implementation**:
```
Stage
├── TileMapLayer (Ground)    # Z-index: 0
├── TileMapLayer (Walls)     # Z-index: 1, Physics layer 1
├── TileMapLayer (Decorations) # Z-index: 2
├── Entities
│   ├── Player
│   └── Enemies
└── StageGenerator (script)
```

### Decision 3: Generator as Scene Script (not Autoload)

**Choice**: Generator attached to Stage scene

**Rationale**:
- Each stage instance can have its own configuration
- No global state pollution
- Easier to test in isolation
- Can have multiple stage scenes with different configs

**API Design**:
```gdscript
class_name StageGenerator extends Node

## Configuration
@export var config: StageConfig

## Generated data (available after generation)
var generated_data: StageData

## Generate the stage map
func generate(seed_value: int = -1) -> void

## Clear and regenerate
func regenerate() -> void

## Get spawn point for player
func get_player_spawn() -> Vector2i

## Get all enemy spawn points
func get_enemy_spawns() -> Array[EnemySpawnData]
```

### Decision 4: Resource-Based Configuration

**Choice**: `StageConfig` Resource for all generator parameters

**Rationale**:
- Easy to create multiple stage presets
- Editable in Godot inspector
- Can be saved as `.tres` files
- Designer-friendly (no code changes)

**StageConfig Structure**:
```gdscript
class_name StageConfig extends Resource

@export var seed_value: int = -1  # -1 = random
@export var map_size: Vector2i = Vector2i(50, 50)
@export var min_room_size: Vector2i = Vector2i(6, 6)
@export var max_room_size: Vector2i = Vector2i(12, 12)
@export var room_count_range: Vector2i = Vector2i(5, 8)
@export var corridor_width: int = 2
@export var enemy_density: float = 0.3  # enemies per room tile
@export var boss_room_enabled: bool = true
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Stage Scene                              │
├─────────────────────────────────────────────────────────────┤
│  StageGenerator.gd                                          │
│  ├── BSPGenerator (room partitioning)                       │
│  ├── RoomPlacer (room creation)                             │
│  ├── CorridorBuilder (room connections)                     │
│  ├── TileMapper (tile placement)                            │
│  └── SpawnPlacer (enemy spawn points)                       │
├─────────────────────────────────────────────────────────────┤
│  Output:                                                    │
│  ├── TileMapLayer (Ground) - populated                      │
│  ├── TileMapLayer (Walls) - populated with collision        │
│  ├── TileMapLayer (Decorations) - optional details          │
│  └── StageData (runtime info)                               │
└─────────────────────────────────────────────────────────────┘
```

### Generation Pipeline

```
1. Initialize RNG with seed
2. BSP Partition map area
3. Create rooms in partitions
4. Connect rooms with corridors
5. Place tiles on TileMapLayers
6. Add collision to wall tiles
7. Place enemy spawn points
8. Place player spawn point
9. (Optional) Place boss room at far end
```

---

## Data Structures

### StageData
```gdscript
class_name StageData extends RefCounted

var rooms: Array[Rect2i]           # All generated rooms
var corridors: Array[Rect2i]       # Corridor rectangles
var player_spawn: Vector2i         # Starting position
var enemy_spawns: Array[EnemySpawnData]  # Enemy spawn points
var boss_room: Rect2i              # Boss arena (if enabled)
```

### EnemySpawnData
```gdscript
class_name EnemySpawnData extends RefCounted

var position: Vector2i
var enemy_type: StringName  # "shadow_wisp", "shadow_crawler", etc.
var spawn_delay: float = 0.0
```

---

## Tile Set Requirements

The generator expects a TileSet with:

| Tile Type | Purpose | Collision |
|-----------|---------|-----------|
| Ground | Floor tiles | None |
| Wall | Boundary walls | Full rect |
| Corridor | Corridor floor | None |
| Door | Room entrances | None |

**Auto-tiling**: Configure terrain sets for wall corners and edges.

---

## Balance Values

| Property | Value | Notes |
|----------|-------|-------|
| Default Map Size | 50x50 tiles | 1600x1600 pixels |
| Room Count | 5-8 | Random within range |
| Min Room Size | 6x6 tiles | Small room |
| Max Room Size | 12x12 tiles | Large room |
| Corridor Width | 2 tiles | Wide enough for combat |
| Enemy Density | 0.3 | 30% of room tiles spawn enemies |

---

## Open Questions

1. **Should we pre-generate or generate at runtime?**
   - Recommendation: Runtime generation on scene load (fast enough for 50x50)
   - Can add editor preview button for debugging

2. **How to handle TileSet during development?**
   - Start with colored placeholder tiles
   - Replace with final tiles later
   - TileSet reference stored in StageConfig

3. **Navigation mesh for enemies?**
   - Godot 4.x can auto-generate navigation from TileMap
   - Add NavigationRegion2D after tile placement
   - Enemies use NavigationAgent2D for pathfinding

---

## File Structure

```
scripts/
└── stage/
    ├── stage_generator.gd      # Main generator orchestrator
    ├── bsp_generator.gd        # BSP partitioning logic
    ├── room_data.gd            # Room data structure
    ├── stage_config.gd         # Configuration resource
    ├── stage_data.gd           # Generated data container
    └── enemy_spawn_data.gd     # Spawn point data

scenes/
└── stage/
    └── base_stage.tscn         # Base stage scene template

resources/
└── stage_configs/
    └── default_stage.tres      # Default configuration
```
