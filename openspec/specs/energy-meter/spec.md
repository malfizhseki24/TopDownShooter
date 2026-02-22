# energy-meter Specification

## Purpose
TBD - created by archiving change add-combat-economy. Update Purpose after archive.
## Requirements
### Requirement: Energy Meter Display

The HUD SHALL display an Energy Meter as a circular gauge that fills as shards are collected.

#### Scenario: Meter positioned below health bar

- **WHEN** HUD is loaded
- **THEN** Energy Meter is positioned 8px below the dash cooldown bar
- **AND** meter size is 24x24 viewport pixels

#### Scenario: Meter shows fill progress

- **WHEN** `energy_meter_changed(current, maximum)` signal is received
- **THEN** fill percentage is calculated as `current / maximum`
- **AND** radial fill mask updates to show fill amount
- **AND** fill color interpolates from #ffdd44 (empty) to #ff8800 (full)

#### Scenario: Shard icon displayed in center

- **WHEN** meter is rendered
- **THEN** a shard icon (12x12 viewport pixels, diamond shape) is centered in the gauge
- **AND** icon color is white (#f1f1f1) at 70% opacity when not full
- **AND** icon color brightens to 100% opacity when full

### Requirement: Energy Meter Fill Animation

The Energy Meter SHALL animate fill changes smoothly rather than instantly.

#### Scenario: Fill animates on collection

- **WHEN** `energy_meter_changed` signal is received with new fill value
- **THEN** fill tweens from previous value to new value over 0.15 seconds
- **AND** tween uses ease-out curve

#### Scenario: Meter caps at maximum

- **WHEN** current energy would exceed maximum (10)
- **THEN** fill is clamped to 100%
- **AND** no visual overflow occurs

### Requirement: Energy Meter Ready State

The Energy Meter SHALL display a distinctive "ready" state when full.

#### Scenario: Ready glow activates

- **WHEN** `energy_meter_full` signal is received
- **THEN** ReadyGlow overlay becomes visible
- **AND** glow pulses with 0.5s cycle (opacity 0.3 to 0.8)
- **AND** glow color is #ffaa00 (orange glow)
- **AND** "ready" SFX plays (ascending tone)

#### Scenario: Ready state persists

- **WHEN** meter is full and ready
- **AND** no special attack has been fired
- **THEN** ready glow continues pulsing
- **AND** meter accepts no additional energy (already full)

### Requirement: Energy Meter Firing State

The Energy Meter SHALL visually respond when the special attack is fired.

#### Scenario: Meter drains on fire

- **WHEN** `energy_meter_emptied` signal is received
- **THEN** fill flashes white (#ffffff) for 0.1 seconds
- **AND** fill tweens from 100% to 0% over 0.3 seconds
- **AND** ReadyGlow fades out over 0.2 seconds

#### Scenario: Meter accepts energy after firing

- **WHEN** meter has been emptied
- **AND** a shard is collected
- **THEN** meter begins filling again from 0%
- **AND** ready glow is hidden until full

### Requirement: Energy Meter Signal Architecture

The Energy Meter SHALL connect to EventBus signals and not hold references to game nodes.

#### Scenario: Meter connects on ready

- **WHEN** Energy Meter enters the scene tree
- **THEN** it connects to `energy_meter_changed` signal
- **AND** it connects to `energy_meter_full` signal
- **AND** it connects to `energy_meter_emptied` signal

#### Scenario: Meter processes during hitstop

- **WHEN** `Engine.time_scale` is 0 (hitstop active)
- **THEN** meter animations continue (not affected by time scale)
- **AND** fill tweens complete normally

### Requirement: Energy Capacity

The Energy Meter SHALL have a fixed maximum capacity.

#### Scenario: Maximum energy is 10

- **WHEN** meter is initialized
- **THEN** maximum energy is set to 10
- **AND** each shard contributes exactly 1 energy unit
- **AND** approximately 6-8 enemy kills fill the meter (accounting for drop chance)

