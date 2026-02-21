# boss Specification

## Purpose
TBD - created by archiving change add-shadow-boar-boss. Update Purpose after archive.
## Requirements
### Requirement: Shadow Boar Boss

The game SHALL include a Shadow Boar boss encounter in Room 7 with 500 HP, two combat phases, and victory on defeat.

#### Scenario: Boss spawns in arena

- **WHEN** Room 7 (boss room) is loaded
- **THEN** Shadow Boar spawns at the B marker position
- **AND** boss has 500 HP
- **AND** EventBus.boss_spawned is emitted with boss reference
- **AND** boss health bar UI appears

#### Scenario: Boss chase behavior

- **WHEN** boss is in CHASE state
- **AND** no attack is ready
- **THEN** boss moves toward player at 80 px/sec
- **AND** boss plays walk animation in movement direction

#### Scenario: Boss charge attack telegraph

- **WHEN** player is within 200 px of boss
- **AND** charge cooldown is ready (4.0 sec Phase 1, 3.0 sec Phase 2)
- **THEN** boss stops moving and enters TELEGRAPH state
- **AND** boss flashes red/white alternating for 1.0 sec (Phase 1) or 0.7 sec (Phase 2)
- **AND** charge direction is locked toward player position at telegraph start

#### Scenario: Boss charge execution

- **WHEN** telegraph completes
- **THEN** boss charges in locked direction at 350 px/sec (Phase 1) or 455 px/sec (Phase 2)
- **AND** charge lasts 0.6 sec or until wall collision
- **AND** boss deals 40 damage on contact with player during charge

#### Scenario: Boss wall stun

- **WHEN** boss collides with wall during charge
- **THEN** boss enters STUNNED state for 2.0 sec (Phase 1) or 1.5 sec (Phase 2)
- **AND** boss is vulnerable to damage during stun
- **AND** boss velocity is zero during stun
- **AND** wall impact VFX plays

#### Scenario: Boss takes damage

- **WHEN** boss takes damage from arrow or other source
- **THEN** boss HP decreases
- **AND** boss flashes white (0.1 sec)
- **AND** EventBus.enemy_hit is emitted
- **AND** boss health bar updates

### Requirement: Shadow Boar Phase Transition

The Shadow Boar SHALL transition to Phase 2 at 50% HP with escalated attack patterns.

#### Scenario: Phase transition trigger

- **WHEN** boss HP drops to 250 or below for the first time
- **THEN** boss becomes invulnerable for 1.0 sec
- **AND** boss stops all movement
- **AND** screen flashes white
- **AND** camera trauma +0.60
- **AND** EventBus.boss_phase_changed emitted with phase=2
- **AND** boss health bar color changes from red to purple

#### Scenario: Phase 2 charge speed increase

- **WHEN** boss is in Phase 2
- **THEN** charge speed increases to 455 px/sec (30% faster)
- **AND** charge cooldown decreases to 3.0 sec
- **AND** telegraph duration decreases to 0.7 sec
- **AND** wall stun duration decreases to 1.5 sec

### Requirement: Shadow Boar Ground Slam

In Phase 2, the Shadow Boar SHALL perform a ground slam that creates an expanding shockwave.

#### Scenario: Ground slam attack

- **WHEN** boss is in Phase 2
- **AND** player is within 80 px (close range)
- **AND** slam cooldown is ready (5.0 sec)
- **THEN** boss plays slam animation (jump-attack)
- **AND** expanding shockwave ring appears from boss position
- **AND** shockwave expands to 120 px radius over 0.5 sec
- **AND** shockwave deals 20 damage to player if hit

### Requirement: Shadow Boar Wisp Summon

In Phase 2, the Shadow Boar SHALL periodically summon Shadow Wisps.

#### Scenario: Wisp summon cycle

- **WHEN** boss is in Phase 2
- **AND** 8 seconds have passed since last summon
- **THEN** boss pauses briefly and summons 2 Shadow Wisps
- **AND** wisps spawn at random positions near boss (80-120 px away)
- **AND** maximum 4 wisps alive at once from summons

### Requirement: Shadow Boar Death

The Shadow Boar defeat SHALL trigger the victory condition.

#### Scenario: Boss death sequence

- **WHEN** boss HP reaches 0
- **THEN** boss enters DYING state
- **AND** all summoned wisps are killed
- **AND** EventBus.boss_died is emitted
- **AND** EventBus.enemy_died is emitted (for room clear tracking)
- **AND** boss plays death animation
- **AND** boss health bar hides
- **AND** room is marked as cleared
- **AND** all_rooms_cleared triggers victory

### Requirement: Boss Health Bar UI

A dedicated health bar SHALL display during the boss fight.

#### Scenario: Boss health bar display

- **WHEN** EventBus.boss_spawned is emitted
- **THEN** boss health bar slides in from bottom of screen over 0.5 sec
- **AND** displays boss name "SHADOW BOAR" above bar
- **AND** bar fill represents current HP / max HP

#### Scenario: Boss health bar phase change

- **WHEN** EventBus.boss_phase_changed is emitted with phase=2
- **THEN** bar fill color transitions from red to dark purple

#### Scenario: Boss health bar on defeat

- **WHEN** EventBus.boss_died is emitted
- **THEN** boss health bar fades out over 0.5 sec

