## ADDED Requirements

### Requirement: Destructible Props

The game SHALL have breakable environmental objects that react to combat, provide visual feedback, and occasionally drop items.

#### Scenario: Destructible takes damage

- **WHEN** an arrow or melee attack hits a destructible object
- **THEN** the destructible's HP is reduced by the attack damage
- **AND** if HP reaches 0, the destructible breaks

#### Scenario: Ancient Clay Pot breaks

- **WHEN** an Ancient Clay Pot (1 HP) is destroyed
- **THEN** 4-6 shard pieces fly outward as particles
- **AND** a dust puff effect plays at the position
- **AND** camera trauma of +0.03 is emitted
- **AND** a hitstop of 0.02s is triggered

#### Scenario: Shadow Pillar breaks

- **WHEN** a Shadow Pillar (3 HP) is destroyed
- **THEN** dark crystal fragments scatter as particles
- **AND** a brief shadow burst effect plays
- **AND** camera trauma of +0.03 is emitted

#### Scenario: Corrupted Root breaks

- **WHEN** a Corrupted Root (1 HP) is destroyed
- **THEN** the root snaps apart with leaf particle effects

#### Scenario: Bone Totem breaks

- **WHEN** a Bone Totem (2 HP) is destroyed
- **THEN** the skull pops off and feathers scatter as particles

#### Scenario: Destructible drops

- **WHEN** a destructible is broken
- **THEN** a drop roll occurs: 80% nothing, 15% Spirit Ember (heal 5 HP), 5% Shadow Fragment (collectible)
- **AND** drops spawn at the break position with a small arc animation

### Requirement: Spirit Ember Pickup

Spirit Embers SHALL heal the player for 5 HP on collection.

#### Scenario: Player collects Spirit Ember

- **WHEN** the player walks over a Spirit Ember pickup
- **THEN** the player is healed for 5 HP
- **AND** a pickup VFX and chime SFX play
- **AND** the pickup is removed

### Requirement: Shadow Fragment Pickup

Shadow Fragments SHALL be collectible items that track a counter for future progression.

#### Scenario: Player collects Shadow Fragment

- **WHEN** the player walks over a Shadow Fragment pickup
- **THEN** a counter in GameManager is incremented
- **AND** a pickup VFX plays
- **AND** the pickup is removed

### Requirement: Boss Destructible Interaction

Shadow Pillars in the boss room SHALL interact with the boss charge attack.

#### Scenario: Boss charges into Shadow Pillar

- **WHEN** the boss charges into a Shadow Pillar
- **THEN** the pillar is instantly destroyed (takes full damage)
- **AND** the boss is stunned as if hitting a wall
- **AND** the pillar's break FX plays

### Requirement: Destructible Placement

Destructibles SHALL be placed in rooms according to design guidelines.

#### Scenario: Room 1 tutorial pots

- **WHEN** Room 1 is loaded
- **THEN** 5-6 Ancient Clay Pots are placed near the player spawn point
- **AND** they do not block the path between spawn and portal

#### Scenario: Combat room destructibles

- **WHEN** Rooms 2-5 are loaded
- **THEN** 3-5 mixed destructibles are placed at room edges and corners
- **AND** they never obstruct movement between spawn and portal

#### Scenario: Heal room decoration

- **WHEN** a heal room is loaded
- **THEN** 2-3 Bone Totems are placed as calm decorative objects

#### Scenario: Boss room pillars

- **WHEN** the boss room is loaded
- **THEN** 4 Shadow Pillars are placed at arena edges
- **AND** the boss can charge through and destroy them
