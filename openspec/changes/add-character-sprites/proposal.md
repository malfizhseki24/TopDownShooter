# Feature: Character Sprites via PixelLab MCP

## Why

Generate all character sprites (player + enemies + boss) for "Warrior of the Sunrise" using PixelLab MCP. This establishes the visual foundation for the game with consistent pixel art style matching the Papuan folklore theme.

## What Changes

- **ADDED**: Player character (Kasuari) with 4-directional sprites and animations
- **ADDED**: 4 enemy types (Shadow Wisp, Shadow Crawler, Shadow Stalker, Shadow Brute)
- **ADDED**: Boss character (Shadow Boar)
- **ADDED**: Asset folder structure for characters

### Characters to Generate

| Character | Size | Directions | Animations |
|-----------|------|------------|------------|
| **Kasuari (Player)** | 128x128 | 4 | idle, walk, shoot, dash, death |
| **Shadow Wisp** | 64x64 | 4 | idle, move, death |
| **Shadow Crawler** | 64x64 | 4 | idle, walk, attack, death |
| **Shadow Stalker** | 96x96 | 4 | idle, walk, teleport, attack, death |
| **Shadow Brute** | 128x128 | 4 | idle, walk, charge, attack, death |
| **Shadow Boar (Boss)** | 128x128* | 4 | idle, walk, charge, slam, death |

*Note: Boss rendered at 128x128 (PixelLab max), scaled 1.5x in-engine to achieve 192x128 visual size.

## Impact

- **Affected systems**: player, enemies, boss
- **Affected files**:
  - `assets/sprites/characters/player/` (new)
  - `assets/sprites/characters/enemies/` (new)
  - `assets/sprites/characters/boss/` (new)

## PixelLab MCP Workflow

All assets generated asynchronously via PixelLab MCP:
1. Queue character creation jobs (returns immediately)
2. Queue animation jobs for each character
3. Poll status with `get_character` until complete
4. Download and organize sprites into Godot project

## Estimated Generation Time

| Phase | Duration |
|-------|----------|
| Character base sprites | ~3 min each (4-dir) |
| Animations per character | ~3 min each |
| **Total (all characters + animations)** | ~45-60 min |

All jobs can run in parallel to reduce wall-clock time.
