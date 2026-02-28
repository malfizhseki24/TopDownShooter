## Why

The current 480x270 viewport limits visual detail in pixel art assets. Scaling to 720p (1280x720) allows for larger, more detailed sprites and tiles while maintaining the 16:9 aspect ratio and pixel art aesthetic. This improves visual quality without changing gameplay.

## What Changes

- **BREAKING**: Viewport resolution changes from 480x270 to 1280x720 (~2.67x scale factor)
- Tile size increases from 32x32 to 64x64 (2x scale, with additional viewport padding)
- Room blueprints expand proportionally (more tiles visible, same room layout)
- All hardcoded world positions scale up (spawn points, vegetation, portals)
- UI elements reposition for larger viewport
- Collision shapes scale proportionally
- Camera bounds and limits adjust to new dimensions
- Asset generation parameters update for larger sprite sizes

## Capabilities

### New Capabilities
None — this is a scaling change, not new functionality.

### Modified Capabilities
- `project-structure`: Update rendering configuration for 720p viewport
- `stage-rooms`: Scale ASCII room dimensions and world positions
- `hud`: Reposition UI elements for larger viewport
- `player`: Scale sprite and collision shapes
- `enemies`: Scale sprites and collision shapes
- `boss`: Scale sprite and collision shapes
- `camera-system`: Adjust bounds and limits for new viewport

## Impact

**Files Modified:**
- `project.godot` — viewport width/height settings
- `scripts/stage/room_manager.gd` — hardcoded spawn positions
- `scripts/stage/room_blueprints.gd` — may need larger room maps
- `scripts/stage/ascii_room_builder.gd` — tile size constant
- `scripts/ui/hud.gd` — UI positioning
- `scripts/ui/boss_health_bar.gd` — UI positioning
- `scripts/player/*.gd` — collision shapes, sprite sizes
- `scripts/enemies/*.gd` — collision shapes, sprite sizes
- `scenes/**/*.tscn` — all entity scenes with sprites/collisions

**Assets Regenerated:**
- Player sprite (48x48 → 96x96 or larger)
- Enemy sprites (64x64 → 128x128 or larger)
- Boss sprite (96x96 → 192x192 or larger)
- Tileset (32x32 → 64x64)
- Vegetation and destructibles (scale proportionally)

**Dependencies:**
- PixelLab MCP for regenerating pixel art at larger sizes
- Existing collision/physics logic remains unchanged (only sizes change)

**Risks:**
- Hardcoded positions may be missed during migration
- Visual consistency between old and new assets
- Performance impact from larger textures (minimal for 2D)
