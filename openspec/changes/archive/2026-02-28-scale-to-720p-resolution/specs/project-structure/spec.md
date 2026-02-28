# Spec Delta: project-structure

## MODIFIED Requirements

### Requirement: Viewport Resolution

The game MUST render at 1280x720 pixels (720p), scaled to fit display.

**Change:** Resolution increased from 480x270 to 1280x720.

#### Scenario: Viewport configuration in project.godot
```ini
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="viewport"
```

### Requirement: Tile Size

Tiles MUST be 64x64 pixels.

**Change:** Tile size doubled from 32x32 to 64x64.

#### Scenario: Tile size constant in ascii_room_builder.gd
```gdscript
const TILE_SIZE := 64
```

### Requirement: Asset Sizes

Player sprite MUST be 96x96 pixels, enemies MUST be 128x128 pixels, boss MUST be 192x192 pixels.

**Change:** All entity sprites scaled 2x from previous sizes.

#### Scenario: Asset size documentation in project.md
```markdown
- **Rendering**: 1280x720 viewport scaled to display, nearest-neighbor filtering
- **Art Style**: Pixel Art — Chibi/SD, 64x64 tiles, 96x96 player, 128x128 enemies, 192x192 boss
```
