## MODIFIED Requirements

### Requirement: Base Enemy Class

All enemies SHALL extend a BaseEnemy class with common functionality. The Shadow Boar boss also extends BaseEnemy.

#### Scenario: Base enemy has required properties

- **WHEN** any enemy is instantiated
- **THEN** enemy has hp, max_hp, contact_damage, move_speed properties
- **AND** enemy has take_damage(damage: int) method
- **AND** enemy has die() method
- **AND** enemy extends CharacterBody2D

#### Scenario: Enemy takes damage

- **WHEN** take_damage(damage) is called on an enemy
- **AND** enemy hp is greater than 0 after reduction
- **THEN** enemy hp is reduced by damage amount
- **AND** enemy flashes white briefly (0.1 sec)

#### Scenario: Enemy dies when HP reaches zero

- **WHEN** take_damage reduces enemy hp to 0 or below
- **THEN** die() method is called
- **AND** enemy enters DYING state
- **AND** enemy stops all movement
- **AND** enemy plays death animation (dissolve fade)
- **AND** enemy is removed from scene after animation
- **AND** EventBus.enemy_died signal is emitted

#### Scenario: Boss enemy uses base class

- **WHEN** Shadow Boar boss is instantiated
- **THEN** boss extends BaseEnemy
- **AND** boss is in "enemy" group AND "boss" group
- **AND** boss take_damage and hit feedback work identically to regular enemies
