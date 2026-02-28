# Design: Enemy Pathfinding Architecture

## Overview

This document describes the architecture for integrating NavigationAgent2D pathfinding into the existing enemy system.

## Current Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Game Scene                           │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ RoomManager │  │    Entities  │  │ TileMapLayer     │   │
│  │             │  │    (Node2D)  │  │ (from ASCII)     │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
│                           │                                 │
│                    ┌──────┴──────┐                         │
│                    │   Enemies   │                         │
│                    │ (BaseEnemy) │                         │
│                    └──────┬──────┘                         │
│                           │                                 │
│         ┌─────────────────┼─────────────────┐              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ ShadowWisp  │  │ShadowCrawler│  │ShadowStalker│ ...    │
│  │             │  │             │  │             │        │
│  │ direction_to│  │ direction_to│  │ teleport +  │        │
│  │ (no nav)    │  │ (no nav)    │  │ direction_to│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

**Problem**: Enemies use `_get_direction_to_player()` which returns a straight-line direction, causing wall collisions.

## Proposed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Game Scene                           │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ RoomManager │  │    Entities  │  │ TileMapLayer     │   │
│  │             │  │    (Node2D)  │  │ (from ASCII)     │   │
│  └──────┬──────┘  └──────────────┘  └────────┬─────────┘   │
│         │                                      │             │
│         │            ┌─────────────────────────┘            │
│         │            │                                      │
│         ▼            ▼                                      │
│  ┌────────────────────────────────────────┐                │
│  │        NavigationRegion2D              │ ◄── NEW        │
│  │   (Generated from TileMapLayer)        │                │
│  └────────────────────────┬───────────────┘                │
│                           │                                 │
│                    ┌──────┴──────┐                         │
│                    │   Enemies   │                         │
│                    │ (BaseEnemy) │                         │
│                    └──────┬──────┘                         │
│                           │                                 │
│         ┌─────────────────┼─────────────────┐              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ ShadowWisp  │  │ShadowCrawler│  │ShadowStalker│ ...    │
│  │             │  │             │  │             │        │
│  │+NavAgent2D  │  │+NavAgent2D  │  │+NavAgent2D  │        │
│  │ path-based  │  │ path-based  │  │ teleport +  │        │
│  │ movement    │  │ movement    │  │ path-based  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## Component Design

### 1. NavigationRegion2D (Game Scene)

**Purpose**: Defines the walkable navigation mesh for the current room.

**Setup**:
- Added as child of Game node
- Navigation polygon generated from TileMapLayer floor cells
- Updated when room changes

**Integration Point**: `RoomManager._setup_navigation()`

```gdscript
# In RoomManager
func _setup_navigation(tile_layer: TileMapLayer) -> void:
    var nav_polygon := NavigationPolygon.new()
    # Generate polygon from floor cells
    # ...
    navigation_region.navigation_polygon = nav_polygon
    navigation_region.bake_navigation_polygon()
```

### 2. NavigationAgent2D (Enemy Scene)

**Purpose**: Calculates path and provides next waypoint for enemy movement.

**Node Structure**:
```
Enemy (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D
├── Hitbox (Area2D)
├── NavigationAgent2D  ◄── NEW
└── GlowSprite
```

**Configuration**:
| Property | Value | Notes |
|----------|-------|-------|
| Path Desired Distance | 8.0 | Close enough to waypoint |
| Target Desired Distance | 10.0 | Reached target threshold |
| Radius | (from collision) | For path calculation |
| Avoidance Enabled | false | Keep simple initially |

### 3. BaseEnemy Modifications

**New Properties**:
```gdscript
# Pathfinding
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var _path_update_timer: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.25  # seconds
```

**New Methods**:
```gdscript
func _update_path_to_player() -> void:
    """Request new path to player position"""
    if _player and navigation_agent:
        navigation_agent.target_position = _player.global_position

func _get_path_direction() -> Vector2:
    """Get direction toward next path waypoint"""
    if navigation_agent.is_navigation_finished():
        return Vector2.ZERO
    var next_pos := navigation_agent.get_next_path_position()
    return global_position.direction_to(next_pos)
```

**Modified Methods**:
```gdscript
func _update_behavior(delta: float) -> void:
    # Update path periodically
    _path_update_timer += delta
    if _path_update_timer >= PATH_UPDATE_INTERVAL:
        _path_update_timer = 0.0
        _update_path_to_player()

    # Use path direction instead of direct direction
    var direction := _get_path_direction()
    velocity = direction * move_speed
```

### 4. Navigation Polygon Generation

**Location**: `AsciiRoomBuilder` or `RoomManager`

**Algorithm**:
1. Get all floor cell positions from TileMapLayer
2. Calculate bounding rectangle
3. Create outline polygon
4. Subtract wall interiors (optional for better precision)

**Simplified Approach** (recommended for MVP):
```gdscript
# Create navigation polygon from room bounds minus border
func _create_navigation_polygon(floor_cells: Array[Vector2i], tile_size: int) -> NavigationPolygon:
    var polygon := NavigationPolygon.new()

    # Find bounds
    var min_x := INF; var max_x := -INF
    var min_y := INF; var max_y := -INF
    for cell in floor_cells:
        min_x = min(min_x, cell.x)
        max_x = max(max_x, cell.x)
        min_y = min(min_y, cell.y)
        max_y = max(max_y, cell.y)

    # Create outline (with border offset for walls)
    var padding := tile_size * 3  # 3-tile border
    var outline: PackedVector2Array = [
        Vector2(min_x * tile_size + padding, min_y * tile_size + padding),
        Vector2(max_x * tile_size + tile_size - padding, min_y * tile_size + padding),
        Vector2(max_x * tile_size + tile_size - padding, max_y * tile_size + tile_size - padding),
        Vector2(min_x * tile_size + padding, max_y * tile_size + tile_size - padding),
    ]

    polygon.add_outline(outline)
    polygon.make_polygons_from_outlines()
    return polygon
```

## Enemy-Specific Behavior

### Shadow Wisp
- Full pathfinding for chase
- Bounce back behavior unchanged

### Shadow Crawler
- Full pathfinding for chase
- Fast movement uses path waypoints

### Shadow Stalker
- Pathfinding used after teleport
- Teleport target selection considers path distance

### Shadow Brute
- Pathfinding for approach
- Charge attack uses direct line (intended behavior)

## Performance Considerations

### Timer-Based Updates
Path recalculation happens every 0.25 seconds, not every frame:
- Reduces CPU usage significantly
- Acceptable lag for enemy AI
- Player won't notice the delay

### Navigation Polygon Size
- Keep polygon simple (single outline)
- Avoid complex holes unless necessary
- Bake once per room load

### Enemy Count
- Current max: ~6 enemies per room
- NavigationAgent2D handles this well
- Monitor if adding more enemies

## Testing Strategy

1. **Unit Tests**:
   - Path direction returns valid vector
   - Timer updates correctly
   - Navigation agent found

2. **Integration Tests**:
   - Enemies navigate around single wall
   - Enemies navigate L-shaped corners
   - All room layouts tested

3. **Visual Tests**:
   - Debug draw path lines
   - Verify no enemies stuck
   - Check all enemy types

## Migration Path

1. Add NavigationAgent2D to enemy scenes (no code changes)
2. Add navigation code to BaseEnemy (disabled by default)
3. Enable per enemy type after testing
4. Add NavigationRegion2D to game scene
5. Generate navigation in RoomManager

## Rollback Plan

If pathfinding causes issues:
1. Disable via flag: `use_pathfinding = false`
2. Enemies fall back to direct movement
3. No scene structure changes needed
