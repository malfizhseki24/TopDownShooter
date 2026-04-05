## ADDED Requirements

### Requirement: Skill Bar Display

The HUD SHALL display a horizontal row of 3 skill slots (below the energy meter, in the left panel) showing each skill's icon, key label, and cooldown state.

#### Scenario: Skill bar is always visible during play

- **WHEN** the game is in PLAYING state
- **THEN** the skill bar shows all 3 slots at full opacity
- **AND** each slot displays the skill icon and its key label (1, 2, or 3)

#### Scenario: Slot layout and sizing

- **WHEN** skill bar is rendered
- **THEN** each slot is 20×20 viewport pixels with 4px gap between slots
- **AND** slot 1 (Talon Kick) is leftmost, slot 3 (Ancestor's Ward) is rightmost
- **AND** key label is a 5px pixel font in the bottom-right corner of each slot

#### Scenario: Skill bar processes during hitstop

- **WHEN** `Engine.time_scale` is 0 (hitstop active)
- **THEN** skill bar animations and tweens continue uninterrupted
- **AND** `process_mode` is set to `ALWAYS`

---

### Requirement: Skill Slot Cooldown Overlay

Each skill slot SHALL display a greyscale overlay that fills the slot when cooldown starts and drains away as the cooldown progresses.

#### Scenario: Overlay appears on skill use

- **WHEN** `EventBus.skill_cooldown_started(skill_index, duration)` is received
- **THEN** the corresponding slot's overlay becomes visible at 100% cover
- **AND** the overlay alpha tweens from full (0.7 opacity dark cover) to 0 over `duration` seconds

#### Scenario: Overlay disappears when skill is ready

- **WHEN** `EventBus.skill_cooldown_ready(skill_index)` is received
- **THEN** the overlay becomes invisible (0% opacity)

#### Scenario: Overlay color matches HUD dark palette

- **WHEN** cooldown overlay is active
- **THEN** overlay color is `#1a1a2e` at 70% opacity

---

### Requirement: Skill Slot Ready Feedback

Each skill slot SHALL flash when its cooldown completes to notify the player.

#### Scenario: Ready flash on cooldown completion

- **WHEN** `EventBus.skill_cooldown_ready(skill_index)` is received
- **THEN** the slot border briefly flashes `#f1f1f1` (white) for 0.15 seconds
- **AND** slot icon opacity tweens from 50% back to 100%

#### Scenario: Ward active state shown on slot 3

- **WHEN** `EventBus.skill_activated(2)` is received (Ancestor's Ward activated)
- **THEN** slot 3 shows a pulsing cyan border (`#70c1b3`, 0.5s cycle, opacity 0.5–1.0)
- **AND** pulse stops when `EventBus.skill_cooldown_started(2, duration)` is received (ward consumed or expired)
