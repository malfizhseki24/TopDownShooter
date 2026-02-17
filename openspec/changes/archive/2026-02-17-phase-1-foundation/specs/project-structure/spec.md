# Project Structure Specification

## ADDED Requirements

### Requirement: Standard Godot 4 Folder Structure

The project SHALL follow Godot 4 best practices with organized directories for scenes, scripts, assets, and resources.

#### Scenario: Folder structure exists

- **WHEN** project is opened in Godot editor
- **THEN** the following directories exist:
  - `scenes/` - Scene files (.tscn)
  - `scenes/player/` - Player-related scenes
  - `scenes/levels/` - Level/arena scenes
  - `scripts/` - GDScript files (.gd)
  - `scripts/player/` - Player scripts
  - `scripts/autoload/` - Singleton scripts
  - `scripts/camera/` - Camera scripts
  - `assets/` - Sprites, audio, fonts
  - `assets/sprites/` - Image assets
  - `resources/` - Resource files (.tres)

### Requirement: Autoload Singletons Configured

The project SHALL have GameManager and EventManager configured as autoload singletons.

#### Scenario: GameManager autoload exists

- **WHEN** game starts
- **THEN** GameManager singleton is accessible globally via `GameManager`

#### Scenario: EventManager autoload exists

- **WHEN** game starts
- **THEN** EventManager singleton is accessible globally via `EventManager`

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
