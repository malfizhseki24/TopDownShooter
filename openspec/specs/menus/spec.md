# menus Specification

## Purpose
Boss health bar display with damage trail, phase transition effects, and defeat animations.

## Requirements
### Requirement: Boss Health Bar Display

The boss health bar SHALL be upgraded with a damage trail ghost bar, GDD-spec sizing (240x10 viewport pixels), and enhanced phase transition and defeat animations.

#### Scenario: Boss health bar appears on boss spawn

- **WHEN** `EventBus.boss_spawned` is emitted
- **THEN** the boss health bar slides up from below the viewport over 0.5 seconds (ease-out)
- **AND** the bar is 240x10 viewport pixels, centered at bottom, 12px from bottom edge
- **AND** the fill color is `#ee4540` (red)
- **AND** the background color is `#1a1a2e` at 80% opacity
- **AND** the border is 2px `#0f0f0f` outline
- **AND** the boss name label "SHADOW BOAR" fades in 0.3 seconds after the bar arrives

#### Scenario: Boss health bar shows damage trail

- **WHEN** the boss takes damage
- **THEN** a white ghost bar (`#f1f1f1`) appears at the previous HP width
- **AND** the ghost bar drains to match new HP over 0.6 seconds
- **AND** the actual fill updates immediately

#### Scenario: Boss health bar phase 2 transition

- **WHEN** `EventBus.boss_phase_changed(2)` is emitted
- **THEN** the bar fill flashes white for 0.15 seconds
- **AND** the fill color transitions from `#ee4540` (red) to `#2d132c` (dark purple) over 0.3 seconds

#### Scenario: Boss health bar defeat animation

- **WHEN** `EventBus.boss_died` is emitted
- **THEN** the boss health bar fades out over 0.5 seconds
