## MODIFIED Requirements

### Requirement: EventBus Signals

The EventBus autoload SHALL include a signal for player respawn events.

#### Scenario: Player respawned signal exists

- **WHEN** EventBus is accessed
- **THEN** `player_respawned` signal is available
- **AND** signal has no parameters

## ADDED Requirements

### Requirement: Spawn Point Reference

The GameManager SHALL store a reference to the player spawn point for respawning.

#### Scenario: Spawn point is stored

- **WHEN** level loads
- **THEN** GameManager stores reference to PlayerSpawn position
- **AND** spawn point is used for player respawn positioning
