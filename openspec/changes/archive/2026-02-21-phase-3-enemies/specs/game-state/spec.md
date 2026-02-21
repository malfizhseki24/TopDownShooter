## ADDED Requirements

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
