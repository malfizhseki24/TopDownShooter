# Feature: Phase 2 - Player Polish

## Why

The player character (Kasuari) has core mechanics implemented (movement, shooting, dash, melee, health, death) but lacks visual polish and a proper respawn system. This phase adds fluid 4-directional animations that respond to gameplay state, and implements a respawn system for the game loop to function properly.

## What Changes

### Animations
- Replace static `Sprite2D` with `AnimatedSprite2D` for frame-based animations
- Implement 4-directional animation system (south, east, north, west) based on aim direction
- Create animation state machine with proper transitions:
  - **Idle** - When velocity is near zero
  - **Walk** - When moving with normalized velocity
  - **Shoot** - When firing arrow (plays once, returns to previous state)
  - **Dash** - When dashing (plays once, returns to previous state)
  - **Death** - When player dies (plays once, triggers respawn)
- Create SpriteFrames resource with all animation frames organized by direction

### Respawn System
- Add respawn functionality after death animation completes
- Reset player state (HP, position, flags) on respawn
- Add brief invincibility period after respawn
- Integrate with GameManager for game state management

## Impact

- **Affected systems**: player, game-state
- **Affected files**:
  - `scenes/player/player.tscn` - Replace Sprite2D with AnimatedSprite2D
  - `scripts/player/player.gd` - Add animation state machine + respawn logic
  - `scripts/autoload/game_manager.gd` - Add respawn state handling
  - `assets/sprites/characters/player/kasuari/` - SpriteFrames resource (new)

## Already Implemented (Phase 2 Core)

| Feature | Status | Location |
|---------|--------|----------|
| Dash/dodge (400 px/sec, 0.2 sec, 1.0 sec cooldown) | ✅ Done | `player.gd:112-130` |
| I-frames system (0.15 sec) | ✅ Done | `player.gd:123-124` |
| Melee attack (35 damage, 64 px range) | ✅ Done | `player.gd:104-109` |
| Player health system (100 HP) | ✅ Done | `player.gd:133-148` |
| Player death trigger | ✅ Done | `player.gd:151-154` |
| Player hit feedback (flash red, shake) | ✅ Done | `player.gd:158-170` |

## Asset Inventory

| Animation | Frames | Directions | Status |
|-----------|--------|------------|--------|
| breathing-idle | 4 | 4 | Ready |
| walking-4-frames | 4 | 4 | Ready |
| lead-jab (shoot) | 3 | 4 | Ready |
| running-slide (dash) | 6 | 4 | Ready |
| falling-back-death | 7 | 4 | Ready |

## Animation Mapping

```
aim_direction.y < -0.5 → NORTH
aim_direction.y > 0.5  → SOUTH
aim_direction.x < 0    → WEST (flip east animation)
aim_direction.x >= 0   → EAST
```

## Technical Notes

- Use `AnimatedSprite2D` instead of `AnimationPlayer` for simpler frame-based animations
- Direction determined by `aim_direction` (mouse position), not velocity
- West animations use East sprites with `flip_h = true` to save memory
- Animation speed: 10 FPS for idle/walk, 12 FPS for actions
- Respawn delay: 2 seconds after death animation completes
