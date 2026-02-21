## ADDED Requirements

### Requirement: Boss Room Setup

Room 7 SHALL spawn the Shadow Boar boss instead of a placeholder enemy.

#### Scenario: Boss room loads Shadow Boar

- **WHEN** RoomManager loads Room 7 (type: boss)
- **THEN** Shadow Boar scene is instantiated at B marker position
- **AND** boss is added to entities node
- **AND** boss is tracked in enemies_in_room count
- **AND** boss_spawned signal is emitted via EventBus

#### Scenario: Boss room clears on boss death

- **WHEN** Shadow Boar dies in Room 7
- **THEN** enemies_in_room reaches 0
- **AND** room is marked as cleared
- **AND** all_rooms_cleared signal triggers victory flow
