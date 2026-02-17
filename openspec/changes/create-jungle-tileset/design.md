# Design: Create Jungle Tileset

## Context

We need a minimal tileset for the test level before implementing player mechanics. The tileset uses PixelLab's `create_topdown_tileset` tool which generates Wang tiles - a system where tile selection is based on corner values, enabling automatic terrain transitions.

## Goals / Non-Goals

**Goals:**
- Generate minimal 2-terrain tileset (ground + wall)
- Clean transitions between terrain types
- Dark jungle aesthetic matching game theme
- Ready for Godot TileMap import

**Non-Goals:**
- Multiple biome variations
- Decorative overlay tiles
- Animated tiles
- Multiple wall types

## Decisions

### Decision 1: Tile Size

**Chosen:** 32x32 pixels

**Rationale:**
- Matches GDD specification
- Standard size for pixel art games
- Works well with 480x270 viewport (15x8.5 tiles visible)
- Compatible with character sprites (128x128 = 4x4 tiles)

### Decision 2: Top-Down Wang Tileset

**Chosen:** `create_topdown_tileset` with 2 terrains

**Rationale:**
- Wang tiles auto-handle all 46 edge/corner combinations
- Returns 16 tiles (transition_size < 1.0) or 23 tiles (transition_size = 1.0)
- Perfect for ground-to-wall transitions
- Single generation creates complete tileset

**PixelLab Parameters:**
```json
{
  "lower_description": "dark jungle floor with dirt and roots, dark green and brown earth tones",
  "upper_description": "ancient stone ruins with moss, weathered gray rocks with dark green patches",
  "transition_size": 0.5,
  "tile_size": {"width": 32, "height": 32},
  "view": "low top-down",
  "shading": "medium shading",
  "detail": "medium detail",
  "outline": "selective outline"
}
```

### Decision 3: Transition Size

**Chosen:** 0.5 (medium transition)

**Rationale:**
- Creates visible blend zone between ground and wall
- Not too subtle (0.25) or too dominant (1.0)
- Returns 23 tiles for full transition coverage

### Decision 4: Godot TileSet Configuration

**Chosen:** Single TileSet resource with 2 physics layers

**Tile Setup:**
| Tile Type | Physics Layer | Collision |
|-----------|---------------|-----------|
| Ground (lower) | None | Walkable |
| Wall (upper) | Layer 4 (wall) | Solid |

**Implementation:**
1. Import tileset PNG to Godot
2. Create new TileSet resource
3. Define tiles from spritesheet
4. Add collision polygon to wall tiles only
5. Leave ground tiles without collision

## PixelLab Generation

### Parameters Table

| Parameter | Value | Reason |
|-----------|-------|--------|
| `lower_description` | Dark jungle floor | Walkable terrain |
| `upper_description` | Ancient stone ruins | Wall terrain |
| `transition_size` | 0.5 | Medium blend zone |
| `tile_size` | 32x32 | GDD spec |
| `view` | low top-down | Matches camera angle |
| `shading` | medium shading | Balance detail/performance |
| `detail` | medium detail | Readable at game scale |
| `outline` | selective outline | Clean edges |

### Generation Flow

```
1. create_topdown_tileset() → Returns tileset_id
2. get_topdown_tileset(tileset_id) → Check status
3. Download PNG when complete (~100 seconds)
4. Import to Godot, create TileSet resource
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Tiles don't match character style | Use similar style params (medium shading, medium detail) |
| Transition looks awkward | Adjust transition_size (try 0.25 or 0.5) |
| Generation takes too long | ~100 sec is acceptable for single tileset |
| Wall collision not pixel-perfect | Use simplified collision shapes (rectangle per tile) |

## Migration Plan

1. Queue tileset generation via PixelLab MCP
2. Poll until complete (~2 min)
3. Download PNG to `assets/sprites/tiles/`
4. Import to Godot with Nearest filter
5. Create TileSet resource manually or via script
6. Add collision to wall tiles
7. Create TileMap in test level
8. Paint sample ground + wall layout

## Open Questions

1. **Transition size:** Start with 0.5, adjust if transitions look off
2. **Tile naming:** Use default PixelLab naming or rename for clarity?
   - Recommendation: Keep default, document in design
3. **Multiple wall heights:** Single wall layer for MVP?
   - Recommendation: Yes, add variations in later phase
