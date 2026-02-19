## MODIFIED Requirements

### Requirement: Player Hitbox Detection

The player Hitbox SHALL detect enemy collisions and trigger damage.

#### Scenario: Enemy contact damage

- **WHEN** enemy body enters player Hitbox area
- **THEN** player.take_damage(enemy.contact_damage) is called
- **AND** damage value is retrieved from enemy.get_contact_damage()

#### Scenario: Hitbox collision layers

- **WHEN** player is in game
- **THEN** player Hitbox is on "player" collision layer
- **AND** Hitbox detects "enemy" collision layer
