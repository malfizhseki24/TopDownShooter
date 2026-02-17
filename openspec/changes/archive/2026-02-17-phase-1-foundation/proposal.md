# Proposal: Phase 1 - Foundation

## Why

This is the first development phase for "Warrior of the Sunrise". We need to establish the core technical foundation before building gameplay features. This phase sets up the project structure, rendering system, and basic player controls that all subsequent features will depend on.

## What Changes

### Project Infrastructure
- Create standard Godot 4 folder structure (`scenes/`, `scripts/`, `assets/`, `resources/`)
- Configure autoload singletons (`GameManager`, `EventManager`)
- Set up input map actions for movement, shooting, and interaction

### Rendering System
- Implement pixel-perfect viewport (480x270 base resolution, 4x scale to 1920x1080)
- Configure texture import settings (Filter: Nearest, no mipmaps)
- Create smooth-follow camera that tracks the player

### Player Core Systems
- 8-directional movement at 200 px/sec
- Mouse-based aiming system
- Bow & arrow shooting with 0.5 sec fire rate (infinite ammo)

## Capabilities

### New Capabilities

- `project-structure`: Standard Godot 4 folder organization, autoload configuration, and input map setup
- `camera-system`: Pixel-perfect viewport (480x270) with smooth player-following camera
- `player-movement`: 8-directional top-down movement with configurable speed
- `player-aiming`: Mouse direction tracking for aiming system
- `bow-arrow`: Ranged weapon system with arrow physics, fire rate limiting, and infinite ammo

### Modified Capabilities

_None - This is the foundation phase with no existing systems to modify._

## Impact

### New Files
```
scenes/
  player/
    Player.tscn
  levels/
    TestLevel.tscn

scripts/
  player/
    player.gd
    bow.gd
    arrow.gd
  autoload/
    game_manager.gd
    event_manager.gd
  camera/
    pixel_camera.gd

assets/
  (existing sprite assets)

resources/
  player_stats.tres
```

### Project Settings
- Viewport: 480x270 (pixel perfect base)
- Window: 1920x1080 (4x scale)
- Stretch Mode: viewport
- Texture Filter: Nearest

### Input Actions
- `move_up`, `move_down`, `move_left`, `move_right`
- `shoot`
- `interact`

### Physics Layers
- Player (layer 1)
- Enemy (layer 2)
- Arrow (layer 3)
- Wall (layer 4)

## Dependencies

- Godot 4.6
- Kasuari player sprites (from `add-character-sprites` change)
- Arrow sprite asset (simple pixel art arrow)

## Success Criteria

- [ ] Player moves smoothly in 8 directions at 200 px/sec
- [ ] Camera follows player with smooth lerp
- [ ] Pixel art renders crisp at 4x scale (no blur)
- [ ] Arrows fire at correct rate (0.5 sec cooldown)
- [ ] Arrows travel at 600 px/sec in mouse direction
- [ ] Arrows despawn after 3 seconds if no hit
