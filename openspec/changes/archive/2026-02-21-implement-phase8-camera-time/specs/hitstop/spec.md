## ADDED Requirements

### Requirement: Hitstop Manager

The game SHALL have a HitstopManager autoload that provides global freeze frame and slow-motion effects for combat impact.

#### Scenario: Freeze frame on hit

- **WHEN** `HitstopManager.freeze(duration)` is called
- **THEN** `Engine.time_scale` is set to 0.0
- **AND** after `duration` seconds (real time), `Engine.time_scale` is restored to 1.0
- **AND** the timer uses `create_timer(duration, true, false, true)` to process during time_scale=0

#### Scenario: Hitstops do not stack

- **WHEN** `freeze()` is called while a freeze is already active
- **THEN** the new freeze is ignored (current freeze completes normally)

#### Scenario: Slow-motion effect

- **WHEN** `HitstopManager.slow_mo(scale, duration)` is called
- **THEN** `Engine.time_scale` is set to `scale` (e.g., 0.15)
- **AND** after `duration` seconds, `Engine.time_scale` lerps back to 1.0 over 0.1 seconds

#### Scenario: Kill slow-mo on last enemy

- **WHEN** the last enemy in a room is killed (not boss room)
- **THEN** `HitstopManager.slow_mo(0.15, 0.12)` is triggered
- **AND** camera trauma of +0.25 is added simultaneously

### Requirement: Hitstop Integration with Combat

The game SHALL trigger appropriate hitstop durations for each combat event per the Feedback Matrix.

#### Scenario: Arrow hit hitstop

- **WHEN** an arrow hits an enemy
- **THEN** a 0.04 second freeze is triggered
- **AND** on kill, a 0.07 second freeze is triggered instead

#### Scenario: Melee hit hitstop

- **WHEN** a melee attack hits an enemy
- **THEN** a 0.08 second freeze is triggered
- **AND** on kill, a 0.12 second freeze is triggered instead

#### Scenario: Player damage hitstop

- **WHEN** the player takes damage from a regular enemy
- **THEN** a 0.06 second freeze is triggered
- **AND** damage from boss triggers 0.08 second freeze

#### Scenario: Boss phase transition hitstop

- **WHEN** boss enters phase 2
- **THEN** a 0.20 second freeze is triggered
