## ADDED Requirements

### Requirement: Shadow Pool Spawner

Shadow Pool SHALL spawn enemies at configured intervals.

#### Scenario: Shadow Pool configuration

- **WHEN** Shadow Pool is placed in a level
- **THEN** inspector shows: enemy_scene (PackedScene), max_spawn (int), spawn_interval (float)
- **AND** default values are: max_spawn=3, spawn_interval=5.0

#### Scenario: Shadow Pool activates when player approaches

- **WHEN** player enters Shadow Pool detection area (200 px radius)
- **THEN** Shadow Pool begins spawning
- **AND** spawn timer starts

#### Scenario: Shadow Pool spawns enemy

- **WHEN** spawn timer reaches spawn_interval
- **AND** spawned_count < max_spawn
- **AND** global enemy count < GameManager.max_enemies (10)
- **THEN** enemy scene is instantiated at pool position
- **AND** spawned_count increments
- **AND** spawn timer resets

#### Scenario: Shadow Pool respects global enemy limit

- **WHEN** spawn timer triggers
- **AND** global enemy count >= 10
- **THEN** no enemy is spawned
- **AND** spawn timer resets to try again later

#### Scenario: Shadow Pool stops when max reached

- **WHEN** spawned_count reaches max_spawn
- **THEN** Shadow Pool stops spawning
- **AND** pool remains inactive until enemies are killed

### Requirement: Multiple Enemy Types Per Pool

Shadow Pool SHALL support spawning different enemy types.

#### Scenario: Random enemy type selection

- **WHEN** Shadow Pool has multiple enemy scenes configured
- **THEN** each spawn randomly selects from available types
- **AND** selection is weighted equally

### Requirement: Shadow Pool Visual

Shadow Pool SHALL have a visual indicator.

#### Scenario: Shadow Pool appearance

- **WHEN** Shadow Pool is in level
- **THEN** pool displays as dark swirling shadow on ground
- **AND** pool has subtle animation (pulsing glow)
