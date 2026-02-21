## ADDED Requirements

### Requirement: Floating Damage Numbers

The game SHALL spawn floating damage number labels at hit positions that are color-coded by damage type, float directionally, and self-destruct after their lifetime.

#### Scenario: Arrow damage to enemy

- **WHEN** `EventBus.damage_dealt` is emitted with type `&"arrow_hit"`
- **THEN** a white (`#f1f1f1`) damage number spawns at the hit position
- **AND** text shows the damage value prefixed with "-" (e.g., "-25")
- **AND** font size is 6px viewport scale
- **AND** the number floats upward 40px over 0.6 seconds with ease-out

#### Scenario: Melee damage to enemy

- **WHEN** `EventBus.damage_dealt` is emitted with type `&"melee_hit"`
- **THEN** a warm yellow (`#f0e68c`) damage number spawns at the hit position
- **AND** font size is 7px (slightly larger — melee feels heavier)
- **AND** the number floats upward

#### Scenario: Enemy damages player

- **WHEN** `EventBus.damage_taken` is emitted with type `&"player_hurt"`
- **THEN** a blood red (`#e94560`) damage number spawns at the hit position
- **AND** font size is 7px
- **AND** the number floats DOWNWARD (opposite of dealt damage)

#### Scenario: Boss damages player

- **WHEN** `EventBus.damage_taken` is emitted with type `&"boss_hurt_player"`
- **THEN** a bright red (`#ff2040`) damage number spawns at the hit position
- **AND** font size is 8px (largest — boss hits feel devastating)
- **AND** the number floats downward

#### Scenario: Heal shrine healing

- **WHEN** `EventBus.damage_dealt` is emitted with type `&"heal"`
- **THEN** a cyan/green (`#70c1b3`) number spawns at the player position
- **AND** text shows "+50" format (positive prefix)
- **AND** font size is 8px
- **AND** the number floats upward

#### Scenario: Damage number scale pop on spawn

- **WHEN** any damage number spawns
- **THEN** it starts at 150% scale and tweens to 100% over 0.1 seconds (ease-out)
- **AND** a random horizontal offset of +/-8px is applied to prevent overlap on rapid hits

#### Scenario: Damage number fade and cleanup

- **WHEN** a damage number has lived for 0.3 seconds (half its 0.6 sec lifetime)
- **THEN** its alpha begins fading from 1.0 to 0.0 over the remaining 0.3 seconds
- **AND** the Node2D calls `queue_free()` after the total 0.6 second lifetime

#### Scenario: Damage numbers survive entity death

- **WHEN** a damage number is spawned
- **THEN** it is added as a child of a persistent DamageNumberLayer node (not the damaged entity)
- **AND** if the damaged entity is freed, the damage number continues floating normally

### Requirement: Damage Number EventBus Signals

The EventBus SHALL provide `damage_dealt` and `damage_taken` signals with position, amount, and type data for floating damage number spawning.

#### Scenario: damage_dealt signal carries hit data

- **WHEN** an enemy or boss takes damage from the player
- **THEN** `EventBus.damage_dealt.emit(position, amount, type)` is called
- **AND** `position` is the `Vector2` world-space hit location
- **AND** `amount` is the `int` damage value
- **AND** `type` is a `StringName` identifying the source (`&"arrow_hit"`, `&"melee_hit"`, `&"heal"`)

#### Scenario: damage_taken signal carries hit data

- **WHEN** the player takes damage from an enemy or boss
- **THEN** `EventBus.damage_taken.emit(position, amount, type)` is called
- **AND** `type` is `&"player_hurt"` for regular enemies or `&"boss_hurt_player"` for boss attacks
