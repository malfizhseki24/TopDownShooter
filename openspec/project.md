# Project Context

## Purpose

**WARRIOR OF THE SUNRISE** — A 2D top-down action roguelite based on Papuan folklore. The player controls Kasuari, a fallen war chief fighting through a forbidden forest of shadow creatures to seek redemption. Built with pixel art chibi/SD art style (Octopath Traveler-inspired).

The authoritative game design reference is `docs/GDD.md`.

## Tech Stack

- **Engine**: Godot 4.6 (2D)
- **Language**: GDScript
- **Physics**: Godot Physics 2D
- **Rendering**: 480x270 viewport scaled 4x to 1920x1080, nearest-neighbor filtering
- **Art Pipeline**: PixelLab AI for pixel art generation (characters, tilesets, map objects)
- **Art Style**: Pixel Art — Chibi/SD, 32x32 tiles, 48x48 player, 64x64 enemies, 96x96 boss

## Project Conventions

### Code Style

- GDScript with static typing where practical (`var x: int = 0`, `func foo() -> void:`)
- Class names use PascalCase (`class_name Player`)
- Constants use UPPER_SNAKE_CASE
- Private variables/functions prefixed with underscore (`_buffered_action`, `_handle_movement()`)
- Signals use snake_case (`player_damaged`, `room_cleared`)
- Tabs for indentation (Godot default)

### Architecture Patterns

- **Autoload singletons** for global systems:
  - `GameManager` — Game state tracking (PLAYING, PAUSED, GAME_OVER), spawn position
  - `EventBus` — Decoupled signal bus (player, enemy, boss, room, UI signals)
  - `AudioManager` — Sound/music control
  - `VFXManager` — Particle effect spawning (`spawn()`, `spawn_attached()`)
- **CharacterBody2D** for player and enemies (physics-based movement with `move_and_slide()`)
- **Area2D** for projectiles (arrows), hitboxes, hurtboxes, and detection zones
- **AnimatedSprite2D** for player (state-based 4-directional animation system)
- **Sprite2D** for enemies (simple sprite with shader-based flash)
- **ShaderMaterial** with `hit_flash.gdshader` for damage feedback on all damageable entities
- Scene composition: each entity is a self-contained `.tscn` with its own script

### Physics Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | player | Player CharacterBody2D |
| 2 | enemy | Enemy CharacterBody2D + Hitbox Area2D |
| 3 | arrow | Arrow Area2D |
| 4 | wall | TileMap collision, StaticBody2D obstacles |

### Testing Strategy

- Manual playtesting in Godot editor (`godot4 .`)
- Headless test scripts in `tests/` directory for systems that can be verified programmatically
- Visual verification for VFX, animations, and hitbox sizes

### Git Workflow

- Single `main` branch (solo developer)
- Commit per feature or fix
- OpenSpec for structured planning before implementation

## Domain Context

- **Setting**: Papuan folklore — forbidden forest, shadow creatures, tribal warrior protagonist
- **Combat Style**: Methodical (aim carefully, fewer but deadlier enemies) — not bullet hell
- **Progression**: Linear 7-room stages (combat → heal → combat → boss)
- **Forgiveness Systems**: Aim assist, input buffering, hitbox manipulation, dash forgiveness, damage i-frames — all invisible to the player
- **Game Feel Priority**: Every action produces layered feedback (visual flash + shake + hitstop + SFX)

## Important Constraints

- **PixelLab limits**: Character sprites max 128x128, tilesets 16x16 or 32x32
- **Solo developer**: AI-assisted ("vibe coding") — prefer simple, readable implementations over complex abstractions
- **Scope**: MVP is 1 stage (7 rooms), 4 enemy types, 1 boss, basic UI — no meta-progression yet

## External Dependencies

- **PixelLab MCP**: AI pixel art generation for characters, tilesets, and map objects
- **Freesound.org / Pixabay**: SFX and music assets
- No server-side dependencies — fully offline single-player game
