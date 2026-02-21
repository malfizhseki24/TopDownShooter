## ADDED Requirements

### Requirement: SFX System

The game SHALL play spatial and non-spatial sound effects for all combat, interaction, and UI events.

#### Scenario: Combat SFX plays at hit position

- **WHEN** an arrow hits an enemy
- **THEN** an impact SFX plays at the hit position using `AudioStreamPlayer2D`
- **AND** the SFX uses a pooled player (8 max simultaneous) to avoid allocation

#### Scenario: Bow shoot SFX

- **WHEN** the player shoots an arrow
- **THEN** a "twang" SFX plays at the player's position

#### Scenario: Dash SFX

- **WHEN** the player dashes
- **THEN** a "whoosh" SFX plays at the player's position

#### Scenario: Enemy death SFX

- **WHEN** an enemy dies
- **THEN** a dissolve/death SFX plays at the enemy's position

#### Scenario: Boss telegraph SFX

- **WHEN** the boss begins a charge telegraph
- **THEN** a charge-up SFX plays at the boss position to warn the player

#### Scenario: Destructible break SFX

- **WHEN** a destructible object breaks
- **THEN** a type-specific break SFX plays (pottery shatter, crystal crack, wood snap, bone rattle)

#### Scenario: Hitstop bass thump

- **WHEN** `HitstopManager.freeze()` is called
- **THEN** a low-frequency impact thump plays globally (non-positional)

#### Scenario: UI SFX

- **WHEN** a UI button is pressed
- **THEN** a confirm or deny SFX plays globally

#### Scenario: Pickup SFX

- **WHEN** the player collects a Spirit Ember
- **THEN** a chime SFX plays at the pickup position

### Requirement: Music System

The game SHALL play background music that transitions based on game state with smooth crossfade.

#### Scenario: Music crossfade on state change

- **WHEN** the game state changes (exploration → combat → boss → victory → death)
- **THEN** the current music track fades out over 1.0 seconds
- **AND** the new track fades in over 1.0 seconds simultaneously

#### Scenario: Exploration music

- **WHEN** a room is loaded with no enemies or all enemies are cleared
- **THEN** the exploration track plays (slow tribal drums, ambient nature, soft bamboo flute)

#### Scenario: Combat music

- **WHEN** the first enemy spawns in a room
- **THEN** the combat track plays (intense beat, synth bass, faster drum patterns)

#### Scenario: Boss music

- **WHEN** the boss spawns
- **THEN** the boss track plays (full fusion — heavy drums + synth + vocal chants)

#### Scenario: Victory music

- **WHEN** the player wins
- **THEN** the victory track plays (triumphant traditional melody)

#### Scenario: Death music

- **WHEN** the player dies or game over occurs
- **THEN** the death track plays (somber, fading drums)

### Requirement: Balancing Pass

All combat values SHALL be tested and tuned with all Phase 8 systems active simultaneously.

#### Scenario: Player survivability

- **WHEN** all systems are active
- **THEN** the player should survive 3-4 hits from regular enemies
- **AND** the boss fight should last approximately 60-90 seconds

#### Scenario: Feedback intensity

- **WHEN** all feedback systems are active simultaneously (hitstop + trauma + knockback + screen flash + SFX)
- **THEN** the combined effect feels impactful but not overwhelming or nauseating
- **AND** no feedback channel dominates or obscures gameplay visibility
