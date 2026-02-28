# Design: Simplify UI to Linear Stage Game

## Architecture Overview

The UI simplification affects three main scenes and their associated scripts:

```
Current State (Roguelite):
┌─────────────────────────────────────────────────────────┐
│ MainMenu.tscn                                          │
│ ├── NEW RUN → GameManager.new_run()                    │
│ ├── DAILY CHALLENGE → GameManager.start_run(daily=true)│
│ ├── Seed Input → GameManager.load_seed()               │
│ └── QUIT                                               │
├─────────────────────────────────────────────────────────┤
│ GameOver.tscn                                          │
│ ├── RETRY (Same Seed) → GameManager.retry_run()        │
│ ├── NEW RUN → GameManager.new_run()                    │
│ └── QUIT TO MENU → GameManager.return_to_menu()        │
└─────────────────────────────────────────────────────────┘

Target State (Linear):
┌─────────────────────────────────────────────────────────┐
│ MainMenu.tscn                                          │
│ ├── NEW GAME → GameManager.new_run() (same func)       │
│ ├── OPTIONS → (placeholder, future)                    │
│ └── QUIT                                               │
├─────────────────────────────────────────────────────────┤
│ GameOver.tscn                                          │
│ ├── RESTART → GameManager.new_run()                    │
│ └── QUIT TO TITLE → GameManager.return_to_menu()       │
├─────────────────────────────────────────────────────────┤
│ PauseMenu.tscn                                         │
│ ├── RESUME                                             │
│ ├── RESTART → GameManager.new_run()                    │
│ └── QUIT TO MENU → GameManager.return_to_menu()        │
└─────────────────────────────────────────────────────────┘
```

## GameManager Functions

The `GameManager.gd` already supports linear progression. The existing functions work as-is:

| Function | Current Usage | Linear Usage |
|----------|--------------|--------------|
| `new_run()` | Starts new run with random seed | **NEW GAME** button |
| `retry_run()` | Retry with same seed | **REMOVE** - not needed |
| `load_seed()` | Load specific seed | **REMOVE** - not needed |
| `return_to_menu()` | Return to main menu | **QUIT TO TITLE** button |
| `start_run(daily=true)` | Daily challenge | **REMOVE** - not needed |

## Button State Asset Design

Using Pixellab MCP to generate a 9-patch friendly button texture:

```
┌────────────────────────────────────────┐
│  Ancient cracked stone button          │
│  - Base: Muted gray/brown (#4a4a4a)    │
│  - Cracks: Dark brown (#3d2914)        │
│  - Accents: Cyan tribal (#70c1b3)      │
│  - Size: 128x32 pixels (wide rect)     │
│                                        │
│  States:                               │
│  1. Normal - Subtle cyan edge glow     │
│  2. Hover - Brighter + stronger glow   │
│  3. Pressed - Darker + pressed down    │
└────────────────────────────────────────┘
```

## Script Changes

### main_menu.gd
```gdscript
# REMOVE:
# - _on_daily_pressed()
# - _on_load_seed_pressed()
# - seed_input reference

# CHANGE:
# - _on_new_run_pressed() → _on_new_game_pressed()
# - Button text references
```

### game_over.gd
```gdscript
# REMOVE:
# - _on_retry_pressed() (same seed retry)
# - seed_label reference
# - _update_stats() seed display

# CHANGE:
# - _on_new_run_pressed() → _on_restart_pressed()
# - Simplify stats display
```

### pause_menu.gd
```gdscript
# ADD:
# - _on_restart_pressed() → GameManager.new_run()
# - RestartButton node
```

## Migration Path

1. Generate button assets via Pixellab MCP
2. Update scene files to remove roguelite nodes
3. Update scripts to remove roguelite functions
4. Update GDD.md to reflect changes
5. Test complete game flow: Menu → Game → Game Over → Restart
