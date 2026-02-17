<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Primary Documentation

**The Game Design Document (GDD) is the authoritative source for game design decisions.**

See: [`docs/GDD.md`](docs/GDD.md) - Living document containing lore, mechanics, and development roadmap.

## Project Overview

**"WARRIOR OF THE SUNRISE"** - 2D Top-Down Action Shooter based on Papuan folklore. The project uses:
- **Dimension**: 2D
- **Art Style**: Pixel Art
- **Physics**: Godot Physics 2D
- **Language**: GDScript

## Development Commands

### Running the Game
```bash
# Open in Godot Editor
godot4 .

# Run the game directly
godot4 .
```

### Exporting Builds
```bash
# Export from command line (requires export templates installed)
godot4 --headless --export-release "Windows Desktop" build/game.exe
godot4 --headless --export-release "macOS" build/game.dmg
godot4 --headless --export-release "Linux/X11" build/game.x86_64
```

## Godot Project Structure

Key directories (to be created as development progresses):
- `scenes/` - Scene files (.tscn)
- `scripts/` - GDScript files (.gd)
- `assets/` - Sprites, audio, fonts, etc.
- `resources/` - Resource files (.tres)

## Architecture Notes

### Autoloads (Singletons)
Configure in Project Settings > Autoload. Common patterns for TopDownShooter:
- GameManager - Global game state
- AudioManager - Sound/music control
- EventManager - Global signals

### Input Maps
Configure input actions in Project Settings > Input Map. Typical TopDownShooter inputs:
- move_up, move_down, move_left, move_right
- shoot, interact
- pause

### Physics Layers
Configure in Project Settings > Layer Names > 2D Physics:
- player, enemy, arrow, wall, pickup
