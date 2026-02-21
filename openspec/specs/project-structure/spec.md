# project-structure Specification

## Purpose

Defines the Godot 4 project structure: directory layout, autoload singletons, input map configuration, and physics layer naming conventions.

## Requirements

### Requirement: Standard Godot 4 Folder Structure

The project SHALL follow Godot 4 best practices with organized directories for scenes, scripts, assets, and resources.

#### Scenario: Folder structure exists

- **WHEN** project is opened in Godot editor
- **THEN** the following directories exist:
  - `scenes/` - Scene files (.tscn)
  - `scenes/player/` - Player and arrow scenes
  - `scenes/enemies/` - Enemy scenes
  - `scenes/boss/` - Boss scenes
  - `scenes/levels/` - Level/arena scenes
  - `scenes/rooms/` - Room template scenes
  - `scenes/stage/` - Stage management scenes
  - `scenes/ui/` - UI scenes (menus, HUD)
  - `scenes/interactables/` - Shrine, portal scenes
  - `scripts/` - GDScript files (.gd)
  - `scripts/player/` - Player and arrow scripts
  - `scripts/enemies/` - Enemy scripts
  - `scripts/boss/` - Boss scripts
  - `scripts/autoload/` - Singleton scripts
  - `scripts/camera/` - Camera scripts
  - `scripts/stage/` - Stage and room management scripts
  - `scripts/vfx/` - VFX manager and effect scripts
  - `scripts/ui/` - UI scripts
  - `scripts/interactables/` - Interactable scripts
  - `scripts/levels/` - Level scripts
  - `shaders/` - Shader files (.gdshader)
  - `assets/` - Sprites, audio, fonts
  - `assets/sprites/` - Image assets
  - `assets/tilesets/` - Tileset assets
  - `resources/` - Resource files (.tres)

### Requirement: Autoload Singletons Configured

The project SHALL have core singletons configured as autoloads.

#### Scenario: GameManager autoload exists

- **WHEN** game starts
- **THEN** GameManager singleton is accessible globally via `GameManager`
- **AND** it tracks game state (PLAYING, PAUSED, GAME_OVER)

#### Scenario: EventBus autoload exists

- **WHEN** game starts
- **THEN** EventBus singleton is accessible globally via `EventBus`
- **AND** it provides signals for player, enemy, boss, room, and UI events

#### Scenario: AudioManager autoload exists

- **WHEN** game starts
- **THEN** AudioManager singleton is accessible globally via `AudioManager`

#### Scenario: VFXManager autoload exists

- **WHEN** game starts
- **THEN** VFXManager singleton is accessible globally via `VFXManager`
- **AND** it provides `spawn(effect_name, position)` and `spawn_attached(effect_name, parent)` methods

### Requirement: Input Map Configured

The project SHALL have input actions configured for all player controls.

#### Scenario: Movement input actions exist

- **WHEN** checking input map in project settings
- **THEN** the following actions are defined:
  - `move_up`
  - `move_down`
  - `move_left`
  - `move_right`

#### Scenario: Combat input actions exist

- **WHEN** checking input map in project settings
- **THEN** the following actions are defined:
  - `shoot`
  - `melee`
  - `dash`

#### Scenario: Interaction input actions exist

- **WHEN** checking input map in project settings
- **THEN** the following actions are defined:
  - `interact`

### Requirement: Physics Layers Configured

The project SHALL have named 2D physics layers for collision detection.

#### Scenario: Physics layers named correctly

- **WHEN** checking layer names in project settings
- **THEN** the following layers are named:
  - Layer 1: `player`
  - Layer 2: `enemy`
  - Layer 3: `arrow`
  - Layer 4: `wall`
