# Proposal: Simplify UI to Linear Stage Game

## Why

The game "WARRIOR OF THE SUNRISE" is pivoting away from complex roguelite mechanics. The current UI contains unnecessary complexity:
- Daily Challenge mode (not needed for linear progression)
- Seed input system (no procedural generation)
- "Run" terminology (confusing for linear game)
- Seed display in game over screen

Removing these simplifies the codebase, reduces maintenance burden, and creates a cleaner player experience focused on linear room progression (Room 1 → Room 7).

## What Changes

### Main Menu
**REMOVE:**
- "Daily Challenge" button
- "Enter Seed:" label
- SeedInput text field
- "Load Seed" button
- "Roguelite Top-Down Shooter" subtitle

**CHANGE:**
- "NEW RUN" → "NEW GAME"
- Add "OPTIONS" button (placeholder for future)

### Game Over Screen
**REMOVE:**
- "Seed: -" label
- "RETRY (Same Seed)" button
- "NEW RUN" button

**CHANGE:**
- Add "RESTART" button (starts from Room 1)
- Add "QUIT TO TITLE" button

### Pause Menu
**ADD:**
- "RESTART" button (restart current game from Room 1)

### GDD.md Updates
- Update subtitle from "Roguelite Top-Down Shooter" to "Linear Stage Action Game"
- Update genre from "Top-Down Action Roguelite" to "Top-Down Action"
- Remove roguelite-specific menu descriptions
- Simplify game flow documentation

### UI Assets (Pixellab)
Generate new button sprites:
- Normal state: Ancient cracked stone, muted gray/brown, cyan tribal accents
- Hover state: Slightly brighter with cyan glow
- Pressed state: Pushed down appearance

## Scope

**In Scope:**
- Main menu scene and script simplification
- Game over scene and script simplification
- Pause menu update
- GDD.md updates
- UI button asset generation via Pixellab MCP

**Out of Scope:**
- Options menu implementation (placeholder button only)
- New game mechanics
- Victory screen changes (already simple)
- GameManager changes (already works for linear progression)
