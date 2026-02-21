# implement-ascii-room-builder

## Summary

Replace the BSP procedural stage generator with an ASCII/text-based room builder system. All 7 rooms are defined as human-readable ASCII strings in GDScript, parsed at runtime into TileMapLayer cells and entity placements. Includes a @tool editor preview so rooms can be visualized without running the game.

## Why

The project has pivoted from seed-based procedural generation to linear 7-room progression (per GDD). The current BSP system (`stage_generator.gd`) generates random layouts which conflicts with the handcrafted room pacing the game needs. The existing pre-built room `.tscn` files use opaque `PackedByteArray` tile data that cannot be read or edited as text.

As a vibe coder, the developer refuses to manually click-and-draw TileMaps in the Godot Editor. The ASCII system solves this: rooms are designed as text strings, reviewed in code, and generated programmatically. AI can design and iterate on room layouts by editing strings.

## What

1. **Room Blueprints** (`room_blueprints.gd`): Static GDScript class containing all 7 room ASCII maps with enemy wave configs and metadata.
2. **ASCII Room Builder** (`ascii_room_builder.gd`): @tool-capable parser that converts ASCII strings into TileMapLayer terrain + entity spawn positions using Godot's Wang terrain auto-tiling.
3. **Room Manager Integration**: Modified `room_manager.gd` to build rooms from blueprints instead of loading pre-built `.tscn` files.
4. **BSP Cleanup**: Remove the unused procedural generation system (`stage_generator.gd`, `stage_config.gd`, `stage_data.gd`, `room_data.gd`, `run_manager.gd`, `base_stage.tscn`).

## Supersedes

- `add-stage-generator` (32/55 tasks) — BSP procedural system no longer needed for linear room progression. Will be archived with `--skip-specs` before implementation.
- Pre-built room scenes (`room_1.tscn` through `room_7.tscn`) — Replaced by ASCII-generated rooms at runtime.

## Legend

| Char | Meaning | Tile | Entity |
|------|---------|------|--------|
| `#` | Wall | TERRAIN_WALL (collision) | — |
| `.` | Floor | TERRAIN_FLOOR (walkable) | — |
| `P` | Player Spawn | TERRAIN_FLOOR | Store position |
| `E` | Enemy Spawn | TERRAIN_FLOOR | Store position |
| `B` | Boss Spawn | TERRAIN_FLOOR | Store position |
| `S` | Heal Shrine | TERRAIN_FLOOR | Instantiate shrine |
| `X` | Exit Portal | TERRAIN_FLOOR | Store position |
| `O` | Obstacle/Decor | TERRAIN_FLOOR | Instantiate destructible |
| ` ` | Void | No tile | — |

## Affected Specs

- NEW `ascii-room-builder` — Parser/builder system requirements
- NEW `stage-rooms` — Stage 1 room definitions and progression requirements

## Affected Files

### New
- `scripts/stage/room_blueprints.gd`
- `scripts/stage/ascii_room_builder.gd`

### Modified
- `scripts/stage/room_manager.gd` — Use builder instead of pre-built scenes
- `scripts/levels/game.gd` — Simplified room loading
- `scenes/levels/game.tscn` — Updated node structure

### Removed (BSP cleanup)
- `scripts/stage/stage_generator.gd`
- `scripts/stage/stage_config.gd`
- `scripts/stage/stage_data.gd`
- `scripts/stage/room_data.gd` (BSP partition tree)
- `scripts/stage/run_manager.gd`
- `scenes/stage/base_stage.tscn`
- `resources/stage_configs/default_stage.tres`
- `tests/test_stage_generator.gd`
- `tests/test_stage_generator.tscn`
- `tests/test_stage_headless.gd`
- `scenes/rooms/room_1.tscn` through `room_7.tscn` (replaced by ASCII)
- `scenes/rooms/room_template.tscn`
- `resources/rooms/room_1.tres` through `room_7.tres`

### Kept (still useful)
- `scripts/stage/linear_stage_config.gd`
- `scripts/stage/room_data_resource.gd`
- `scripts/stage/enemy_wave_data.gd`
- `scripts/stage/enemy_spawn_data.gd`
- `scripts/stage/pixellab_tileset_converter.gd`
- `assets/tilesets/*.tres` (all tilesets)
