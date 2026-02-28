## Design: Scale to 720p Resolution

### Scale Factor Decision

**Current:** 480x270 viewport with 32x32 tiles
**Target:** 1280x720 viewport (720p)

**Scale factor options:**

| Option | Tile Size | Viewport | Scale | Clean Math |
|--------|-----------|----------|-------|------------|
| A: 2x | 64x64 | 960x540 | 2.0 | Yes, but not 720p |
| B: 2.67x | 85x85 | 1280x720 | 2.67 | No, weird tile size |
| **C: 2x tiles + padding** | 64x64 | 1280x720 | 2.0 tiles | **Recommended** |

**Recommendation: Option C**
- Double tile size from 32px to 64px (clean 2x scale for assets)
- Increase room sizes in tiles to fill 720p viewport
- Rooms go from ~15x11 tiles to ~20x15 tiles (more play area)

### Room Size Mapping

| Room | Current (tiles) | Current (pixels) | New (tiles) | New (pixels @64px) |
|------|-----------------|------------------|-------------|---------------------|
| Tutorial | 15x11 | 480x352 | 20x12 | 1280x768 |
| Combat 2 | 17x11 | 544x352 | 20x12 | 1280x768 |
| Heal | 15x9 | 480x288 | 20x11 | 1280x704 |
| Combat 4 | 17x13 | 544x416 | 20x14 | 1280x896 |
| Combat 5 | 19x13 | 608x416 | 20x14 | 1280x896 |
| Boss | 19x13 | 608x416 | 20x14 | 1280x896 |

**Note:** All rooms standardized to 20 tiles wide for consistency.

### Position Scaling

Hardcoded positions in `room_manager.gd`:

| Variable | Current | New (×2.67) | New (rounded) |
|----------|---------|-------------|---------------|
| `_player_spawn` | (240, 400) | (640, 1067) | (640, 800)* |
| Default boss spawn | (240, 120) | (640, 320) | (640, 320) |
| Default portal pos | (240, 80) | (640, 213) | (640, 200) |
| Vegetation center | (240, 200) | (640, 533) | (640, 500) |

*Player spawn adjusted to fit within room bounds

**Better approach:** Use room-relative positioning instead of hardcoded values:
```gdscript
# Instead of Vector2(240, 400), calculate from room center
var room_center := Vector2(viewport_width / 2, viewport_height * 0.8)
```

### Asset Regeneration

| Asset Type | Current Size | New Size | PixelLab Tool |
|------------|--------------|----------|---------------|
| Player | 48x48 | 96x96 | create_character |
| Enemies | 64x64 | 128x128 | create_character |
| Boss | 96x96 | 192x192 | create_character |
| Tiles | 32x32 | 64x64 | create_topdown_tileset |
| Vegetation | varies | 2x | create_map_object |
| Destructibles | 32x32 | 64x64 | create_isometric_tile |

### UI Scaling

HUD elements positioned relative to viewport edges:
- Health bar: top-left corner with margin
- Boss HP: top-center
- Dash cooldown: below health bar
- Energy meter: inline with health

Use anchor-based positioning in Godot to auto-adapt to viewport size.

### Migration Strategy

1. **Phase 1: Viewport & Tiles**
   - Update project.godot viewport
   - Regenerate tileset at 64x64
   - Update ascii_room_builder.gd TILE_SIZE constant

2. **Phase 2: Entities**
   - Regenerate player sprite
   - Regenerate enemy sprites
   - Regenerate boss sprite
   - Update collision shapes in scenes

3. **Phase 3: World Positions**
   - Update room_manager.gd hardcoded positions
   - Update room blueprints (larger maps)
   - Update vegetation/destructible scales

4. **Phase 4: UI & Polish**
   - Reposition HUD elements
   - Adjust camera bounds
   - Playtest all rooms

### Trade-offs

| Decision | Pros | Cons |
|----------|------|------|
| 64px tiles (vs 85px) | Clean 2x scale, easy asset gen | Smaller view than max 720p |
| Standardize room width | Consistent gameplay | Lose some room variety |
| Regenerate vs scale existing | Crisp pixels at native res | More work, need PixelLab |
