## ADDED Requirements

### Requirement: Active Skill Slot System

The player SHALL have three activatable skill slots mapped to keyboard keys 1, 2, and 3, each with an independent cooldown timer that starts after use.

#### Scenario: Skill activates on key press when ready

- **WHEN** player presses skill key (1, 2, or 3)
- **AND** the corresponding skill cooldown is not active
- **AND** player is alive and not dead
- **THEN** the skill executes immediately
- **AND** its cooldown timer starts

#### Scenario: Skill is blocked during cooldown

- **WHEN** player presses a skill key
- **AND** that skill's cooldown timer is still running
- **THEN** the skill does not execute
- **AND** no visual or audio feedback plays

#### Scenario: Skills are blocked during Sun-Piercer windup

- **WHEN** `is_windup` is true (Sun-Piercer charge active)
- **THEN** all skill key presses are ignored
- **AND** cooldowns are not started

#### Scenario: Cooldowns reset on player respawn

- **WHEN** player respawns after death
- **THEN** all three skill cooldown timers are stopped and reset
- **AND** all three skills become immediately available

---

### Requirement: Talon Kick (Skill 1)

The player SHALL activate a close-range AoE burst dealing 45 damage to all enemies within 100px, referencing the cassowary's iconic deadly kick.

#### Scenario: Talon Kick damages nearby enemies

- **WHEN** player presses key 1 while skill is ready
- **THEN** all enemies within 100px radius receive 45 damage
- **AND** each hit enemy receives 200px knockback away from player
- **AND** hit feedback fires for each enemy (white flash, hitstop 0.06s, screen trauma 0.3)

#### Scenario: Talon Kick hits all overlapping enemies simultaneously

- **WHEN** multiple enemies are within 100px
- **THEN** all of them are damaged in the same frame
- **AND** no enemy is hit more than once per activation

#### Scenario: Talon Kick with no nearby enemies still commits

- **WHEN** player activates Talon Kick with no enemies within 100px
- **THEN** the cooldown still starts
- **AND** VFX and SFX still play

#### Scenario: Talon Kick emits feedback signals

- **WHEN** Talon Kick fires
- **THEN** a ground shockwave ring VFX spawns at player position
- **AND** `talon_kick.wav` SFX plays
- **AND** `EventBus.skill_activated.emit(0)` fires

---

### Requirement: Feather Volley (Skill 2)

The player SHALL fire 5 arrows simultaneously in a 90° fan spread, each dealing 20 damage, referencing Kasuari's lost wings.

#### Scenario: Feather Volley fires 5 arrows in fan

- **WHEN** player presses key 2 while skill is ready
- **THEN** 5 arrows spawn from `arrow_spawn` position
- **AND** arrows are spread at angle offsets −45°, −22.5°, 0°, +22.5°, +45° relative to `aim_direction`
- **AND** each arrow deals 20 damage
- **AND** arrows use standard ARROW_SPEED (800 px/s) and lifetime (3s)

#### Scenario: Feather Volley does not affect regular fire rate

- **WHEN** Feather Volley fires
- **THEN** `can_shoot` and the regular fire rate timer are NOT affected
- **AND** player can immediately fire a regular arrow after the volley

#### Scenario: Feather Volley emits feedback signals

- **WHEN** Feather Volley fires
- **THEN** a feather particle burst VFX plays at player position
- **AND** `feather_volley.wav` SFX plays
- **AND** `EventBus.skill_activated.emit(1)` fires

---

### Requirement: Ancestor's Ward (Skill 3)

The player SHALL activate a spirit shield that fully absorbs the next incoming hit, lasting up to 3 seconds before expiring, referencing ancestral spirit protection.

#### Scenario: Ward activates on key press

- **WHEN** player presses key 3 while skill is ready and not already warded
- **THEN** `is_warded` becomes true
- **AND** a ward duration timer (3s) starts
- **AND** spirit aura VFX appears around the player
- **AND** `ancestor_ward_activate.wav` SFX plays
- **AND** `EventBus.skill_activated.emit(2)` fires

#### Scenario: Ward absorbs one hit

- **WHEN** player takes damage while `is_warded` is true
- **THEN** damage is fully negated (0 damage dealt to player)
- **AND** `is_warded` becomes false
- **AND** ward duration timer stops
- **AND** spirit aura VFX ends
- **AND** `ancestor_ward_break.wav` SFX plays
- **AND** skill cooldown timer (14s) starts

#### Scenario: Ward expires without being hit

- **WHEN** ward duration timer (3s) reaches zero while `is_warded` is still true
- **THEN** `is_warded` becomes false
- **AND** spirit aura VFX fades out
- **AND** skill cooldown timer (14s) starts

#### Scenario: Ward does not stack

- **WHEN** player presses key 3 while already warded
- **THEN** nothing happens
- **AND** the existing ward continues unchanged

---

### Requirement: Skill Cooldown Signals

The player SHALL emit EventBus signals when each skill's cooldown starts and when it completes.

#### Scenario: Cooldown started signal fires on skill use

- **WHEN** any skill activates
- **THEN** `EventBus.skill_cooldown_started.emit(skill_index, duration)` fires
- **AND** `skill_index` is 0 for Talon Kick, 1 for Feather Volley, 2 for Ancestor's Ward

#### Scenario: Cooldown ready signal fires on timer completion

- **WHEN** a skill cooldown Timer times out
- **THEN** `EventBus.skill_cooldown_ready.emit(skill_index)` fires
- **AND** that skill becomes available again
