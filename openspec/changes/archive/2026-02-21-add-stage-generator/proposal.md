# Feature: Stage Generator Engine

## Why

The game needs a procedural stage generation system to create varied, replayable maps with proper TileMap, collision, and enemy spawn configurations. Instead of hand-crafting each stage, a generator engine will produce stages dynamically based on configurable parameters, enabling:
- Replayability through varied layouts
- Consistent map structure (borders, rooms, corridors)
- Automatic enemy spawn point placement
- Scalable difficulty through generator parameters

## What Changes

### Core Generator System
- **StageGenerator** autoload/singleton that orchestrates map generation
- **RoomGenerator** module for creating individual rooms
- **CorridorGenerator** module for connecting rooms
- **BorderGenerator** module for creating map boundaries

### TileMap Integration
- Uses Godot 4.x `TileMapLayer` nodes (replaces deprecated `TileMap`)
- Auto-tiling support for seamless terrain transitions
- Separate layers: Ground, Walls, Decorations

### Stage Data Structure
- **StageConfig** resource for generator parameters (seed, room count, enemy density)
- **StageData** containing generated map data for runtime use
- Enemy spawn point data with type and position information

### Editor Integration
- Generator preview in editor (optional)
- Seed-based reproducibility for debugging

## Impact

### Affected Systems
- **level** - New game system for stage/map management
- **enemies** - Spawn point integration
- **game-state** - Stage progression triggers

### Affected Files
- `scripts/stage/` - New directory for generator scripts
- `scenes/stage/` - Stage scene templates
- `resources/stage_configs/` - Stage configuration resources

### Dependencies
- TileSet assets (can use placeholder tiles initially)
- Existing enemy prefabs for spawn system

## Research Sources

Based on 2025-2026 Godot 4.x best practices:
- [TileMap Guide - CSDN](https://m.blog.csdn.net/sheepForTest/article/details/156764792)
- [Procedural Level Generator - Bilibili](https://m.bilibili.com/video/BV1yG3WzQEnH/)
- [Godot Procedural Generation - GitCode](https://gitcode.com/gh_mirrors/go/godot-procedural-generation)
- [WFC Algorithm Guide](https://blog.csdn.net/gitblog_00183/article/details/152700411)
