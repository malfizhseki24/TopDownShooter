# game-state Specification

## Purpose

Defines the global game state management systems: GameManager singleton for state tracking and spawn coordination, and EventBus singleton for decoupled signal-based communication between game systems.
## Requirements
### Requirement: EventBus Signals

The EventBus autoload SHALL include signals for player lifecycle events.

#### Scenario: Player respawned signal exists

- **WHEN** EventBus is accessed
- **THEN** `player_respawned` signal is available
- **AND** signal has no parameters

#### Scenario: Player damage signals exist

- **WHEN** EventBus is accessed
- **THEN** `player_damaged(damage: int)` signal is available
- **AND** `player_died` signal is available
- **AND** `player_healed(amount: int)` signal is available

#### Scenario: Player dash signals exist

- **WHEN** EventBus is accessed
- **THEN** `player_dash_started(cooldown_duration: float)` signal is available
- **AND** `player_dash_ready` signal is available

#### Scenario: Health changed signal exists

- **WHEN** EventBus is accessed
- **THEN** `health_changed(current: int, maximum: int)` signal is available

### Requirement: Spawn Point Reference

The GameManager SHALL store a reference to the player spawn point for respawning.

#### Scenario: Spawn point is stored

- **WHEN** level loads
- **THEN** GameManager stores reference to PlayerSpawn position
- **AND** spawn point is used for player respawn positioning

### Requirement: Game State Tracking

The GameManager SHALL track the current game state for gating player input and systems.

#### Scenario: Game states defined

- **WHEN** GameManager is accessed
- **THEN** GameState enum includes at minimum: PLAYING, PAUSED, GAME_OVER
- **AND** `current_state` is accessible globally

### Requirement: Global Enemy Count

GameManager SHALL track the current number of active enemies.

#### Scenario: Enemy count tracking

- **WHEN** enemy is spawned
- **THEN** GameManager.enemy_count increments by 1

#### Scenario: Enemy count decrement

- **WHEN** enemy dies and is removed
- **THEN** GameManager.enemy_count decrements by 1

#### Scenario: Maximum enemy limit

- **WHEN** enemy_count >= 10
- **THEN** spawn pools SHALL NOT spawn new enemies
- **AND** spawn attempt is deferred

### Requirement: Spawn Control by Game State

Enemy spawning SHALL be controlled by game state.

#### Scenario: Spawning during gameplay

- **WHEN** GameManager.current_state is PLAYING
- **THEN** Shadow Pools are active and can spawn

#### Scenario: No spawning when paused

- **WHEN** GameManager.current_state is PAUSED
- **THEN** Shadow Pools stop spawning
- **AND** existing enemies freeze in place

