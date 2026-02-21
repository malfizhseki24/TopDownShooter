## MODIFIED Requirements

### Requirement: Camera Trauma System

The camera SHALL use a noise-based trauma system with quadratic falloff for screen shake, replacing the current hardcoded offset shake.

#### Scenario: Trauma adds shake intensity

- **WHEN** `EventBus.camera_trauma(amount)` is emitted
- **THEN** trauma increases by `amount`, clamped to 1.0
- **AND** shake intensity is `trauma * trauma` (quadratic)
- **AND** camera offset uses `FastNoiseLite` (OpenSimplex2, frequency 4.0) for organic movement
- **AND** max offset is 8px horizontal, 6px vertical, 2 degrees rotation

#### Scenario: Trauma decays over time

- **WHEN** trauma is greater than 0
- **THEN** trauma decreases by `3.0 * delta` each frame
- **AND** when trauma reaches 0, camera offset and rotation reset to zero

#### Scenario: Arrow hit adds micro-trauma

- **WHEN** an arrow hits an enemy (non-kill)
- **THEN** `EventBus.camera_trauma.emit(0.08)` is called

#### Scenario: Player damage adds major trauma

- **WHEN** the player takes damage
- **THEN** `EventBus.camera_trauma.emit(0.35)` is called

#### Scenario: Boss events add scaled trauma

- **WHEN** boss phase transition occurs
- **THEN** `EventBus.camera_trauma.emit(0.60)` is called
- **AND** boss wall charge impact emits 0.40
- **AND** boss ground slam emits 0.50

### Requirement: Camera Look-Ahead

The camera SHALL offset its target position in the player's aim direction to provide visibility in the direction of fire.

#### Scenario: Camera leads toward aim direction

- **WHEN** the player is aiming
- **THEN** camera target is `player_position + aim_direction * 40` pixels
- **AND** the look-ahead offset lerps at weight 4.0 (slower than the main follow weight of 8.0)

#### Scenario: Look-ahead combines with trauma

- **WHEN** both look-ahead offset and trauma shake are active
- **THEN** the look-ahead offset is applied first as the target position
- **AND** trauma shake offset is layered on top additively
