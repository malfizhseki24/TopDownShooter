# Proposal: Create Jungle Tileset

## Why

Before implementing Phase 1 (Foundation), we need a minimal playable environment. The player needs ground to walk on and walls to collide with. Without tiles, we cannot properly test collision detection, arrow wall impacts, or camera boundaries.

Generating tiles first ensures the test level is ready when we implement player mechanics.

## What Changes

### Tile Generation via PixelLab MCP
- Generate top-down Wang tileset (ground + wall transition)
- 32x32 tile size (matches GDD spec)
- Dark jungle aesthetic matching Papuan folklore theme

### Godot Integration
- Import tileset to Godot project
- Configure TileMap layer for test level
- Set up collision for wall tiles

## Capabilities

### New Capabilities

- `ground-tiles`: Walkable jungle floor tiles (32x32, no collision)
- `wall-tiles`: Ancient stone ruin wall tiles (32x32, with collision)

### Modified Capabilities

_None - New tileset, no existing tiles to modify._

## Impact

### New Files
```
assets/sprites/tiles/
├── jungle_tileset.png      # Generated tileset image
└── jungle_tileset.tres     # Godot TileSet resource

scenes/levels/
└── TestLevel.tscn          # Updated with TileMap
```

### Dependencies
- PixelLab MCP subscription (Tier 1+)
- Godot 4.6 TileMap system

## Success Criteria

- [ ] Tileset generates with clean ground/wall transitions
- [ ] Tiles import correctly at 32x32 with Nearest filter
- [ ] Wall tiles have collision shapes
- [ ] Ground tiles are walkable (no collision)
- [ ] Test level renders tiles correctly
