# Tasks: Simplify UI to Linear Stage Game

## Phase 1: Update GDD.md

### 1.1 GDD Content Updates
- [x] Change genre from "Top-Down Action Roguelite" to "Top-Down Action"
- [x] Remove "Roguelite Top-Down Shooter" subtitle reference
- [x] Update menu descriptions to remove roguelite terminology
- [x] Update "MVP Scope" section to reflect linear game (no seeds/daily)

---

## Phase 2: Generate UI Assets (Pixellab MCP) - DEFERRED

### 2.1 Button Sprite Generation
- [x] ~~Generate button_normal.png~~ **SKIPPED** - Pixellab MCP parameter validation issues
- [x] ~~Generate button_hover.png~~ **SKIPPED** - Using standard Godot buttons
- [x] ~~Generate button_pressed.png~~ **SKIPPED** - Custom textures deferred to future update
- [x] ~~Save assets to `res://assets/ui/`~~ **SKIPPED** - Standard buttons work correctly

> **Note**: Pixellab MCP tool had parameter validation issues. Using standard Godot buttons. Custom textures can be added in a future update when the MCP tool is fixed.

---

## Phase 3: Main Menu Simplification

### 3.1 Scene Updates
- [x] Remove "Daily Challenge" button node
- [x] Remove "SeedLabel" (Enter Seed:) node
- [x] Remove "SeedInput" (LineEdit) node
- [x] Remove "LoadSeedButton" node
- [x] Remove "HSeparator" nodes related to seed input
- [x] Change "NewRunButton" text to "NEW GAME"
- [x] Add "OptionsButton" (placeholder, disabled)

### 3.2 Script Updates
- [x] Remove `_on_daily_pressed()` function
- [x] Remove `_on_load_seed_pressed()` function
- [x] Remove `seed_input` reference
- [x] Remove daily/seed button signal connections
- [x] Rename `_on_new_run_pressed()` to `_on_new_game_pressed()`

### 3.3 Update Subtitle
- [x] Change subtitle from "Roguelite Top-Down Shooter" to "Linear Stage Action"

---

## Phase 4: Game Over Screen Simplification

### 4.1 Scene Updates
- [x] Remove "SeedLabel" (Seed: -) node
- [x] Remove "RetryButton" (RETRY Same Seed) node
- [x] Remove "NewRunButton" (NEW RUN) node
- [x] Add "RestartButton" with text "RESTART"
- [x] Add "QuitButton" with text "QUIT TO TITLE"

### 4.2 Script Updates
- [x] Remove `_on_retry_pressed()` function
- [x] Remove `_on_new_run_pressed()` function
- [x] Add `_on_restart_pressed()` → calls `GameManager.new_run()`
- [x] Remove seed display from `_update_stats()`
- [x] Update button signal connections

---

## Phase 5: Pause Menu Enhancement

### 5.1 Scene Updates
- [x] Add "RestartButton" between Resume and Quit

### 5.2 Script Updates
- [x] Add `_on_restart_pressed()` function
- [x] Connect RestartButton signal
- [x] Unpause game before restart

---

## Phase 6: Victory Screen Simplification

### 6.1 Scene Updates
- [x] Remove "SeedLabel" node
- [x] Remove "CopySeedButton" node
- [x] Change "NewRunButton" to "RestartButton" with text "PLAY AGAIN"

### 6.2 Script Updates
- [x] Remove `seed_label` reference
- [x] Remove `copy_seed_button` reference
- [x] Remove `_on_copy_seed_pressed()` function
- [x] Update `_update_stats()` to remove seed display
- [x] Rename `_on_new_run_pressed()` to `_on_restart_pressed()`

---

## Phase 7: GameManager Cleanup

### 7.1 Remove Roguelite Variables
- [x] Remove `current_seed` variable
- [x] Remove `is_daily_run` variable
- [x] Update `start_run()` to remove seed/daily logic
- [x] Update `get_run_stats()` to remove seed/is_daily
- [x] Update `end_run()` to remove seed display
- [x] Simplify `new_run()` and `retry_run()` (retry = new for linear game)
- [x] Remove `load_seed()` function
- [x] Remove `get_seed_string()` function

---

## Phase 8: Apply New Button Theme - DEFERRED

### 8.1 Theme Integration
- [x] ~~Create Theme resource~~ **SKIPPED** - Standard Godot buttons sufficient for MVP
- [x] ~~Apply Button theme overrides~~ **SKIPPED** - Custom styling deferred
- [x] ~~Test button states~~ **VERIFIED** - Standard buttons work correctly

> **Deferred**: Custom button textures and theme can be added in a future update.

---

## Validation

- [x] Main Menu: Only "NEW GAME", "OPTIONS" (disabled), "QUIT" visible
- [x] Main Menu: "NEW GAME" starts game from Room 1
- [x] Game Over: "RESTART" works (starts from Room 1)
- [x] Game Over: "QUIT TO TITLE" returns to main menu
- [x] Pause Menu: "RESTART" works (restarts from Room 1)
- [x] Victory Screen: No seed display, "PLAY AGAIN" works
- [x] No seed/daily/roguelite text visible anywhere
- [x] Button hover/press states work correctly (standard Godot buttons verified)

---

## Summary

All core tasks completed. Custom button textures (Phase 2 and Phase 8) deferred due to Pixellab MCP issues - standard Godot buttons are functional and the game is fully playable without custom textures.
