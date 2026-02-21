## ADDED Requirements

### Requirement: Player Health Bar

The HUD SHALL display a custom health bar (80x8 viewport pixels, top-left at 8px from edges) using ColorRect nodes with damage trail, low-HP pulse, and heal flash effects.

#### Scenario: Health bar reflects current HP

- **WHEN** `EventBus.health_changed(current, maximum)` is emitted
- **THEN** the BarFill width updates to `(current / maximum) * 80` pixels
- **AND** the fill color is `#e94560` (blood red)

#### Scenario: Damage trail ghost bar on HP loss

- **WHEN** player takes damage and HP decreases
- **THEN** a white ghost bar (`#f1f1f1`) appears at the previous HP width
- **AND** the ghost bar shrinks to match new HP over 0.4 seconds
- **AND** the actual fill updates immediately

#### Scenario: Low HP pulse when health critical

- **WHEN** player HP is at or below 25
- **THEN** the health bar fill alpha oscillates between 0.6 and 1.0 using `sin(time * 6.0)`
- **AND** the fill color shifts to `#ff2040` (brighter red)

#### Scenario: Heal flash on HP gain

- **WHEN** `EventBus.player_healed` is emitted
- **THEN** the fill bar expands instantly to new HP width
- **AND** the fill shows a green tint (`#70c1b3`) for 0.2 seconds before returning to red

#### Scenario: HP text appears briefly on change

- **WHEN** player HP changes (damage or heal)
- **THEN** a small label showing "72/100" format appears for 1.5 seconds
- **AND** the label fades in over 0.15 seconds and fades out over 0.15 seconds
- **AND** the text color is `#f1f1f1` at 5px viewport-scale pixel font

### Requirement: Dash Cooldown Indicator

The HUD SHALL display a dash cooldown bar (48x4 viewport pixels, below health bar) that is only visible during cooldown and vanishes when ready.

#### Scenario: Dash cooldown begins

- **WHEN** `EventBus.player_dash_started(cooldown_duration)` is emitted
- **THEN** the dash bar fades in to 40% opacity
- **AND** the fill color is `#16213e` (dark navy)
- **AND** the fill width tweens from 0 to full (left-to-right) over `cooldown_duration` seconds

#### Scenario: Dash becomes ready

- **WHEN** `EventBus.player_dash_ready` is emitted
- **THEN** the fill flashes `#70c1b3` (cyan) for 0.15 seconds
- **AND** the entire bar fades to 0% opacity over 0.3 seconds

#### Scenario: Dash bar invisible when ready

- **WHEN** dash cooldown is not active
- **THEN** the dash bar and icon are invisible (0% opacity)
- **AND** no screen space is occupied

#### Scenario: Dash icon displayed

- **WHEN** dash bar is visible
- **THEN** a 5x5 diamond glyph is displayed to the left of the bar
- **AND** the glyph color is `#f1f1f1` at 50% opacity

### Requirement: Room Progress Indicator

The HUD SHALL display a 7-dot horizontal row (top-right, 8px from edges) representing room progression through the stage.

#### Scenario: Dots reflect room state

- **WHEN** room state updates via `EventBus.room_loaded`
- **THEN** completed rooms show filled dots in `#f1f1f1` (white)
- **AND** the current room shows a filled dot in `#e94560` (red) with slow alpha pulse (0.7–1.0)
- **AND** future rooms show hollow dots in `#f1f1f1` at 30% opacity

#### Scenario: Boss room dot is distinctive

- **WHEN** the 7th dot (boss room) is rendered
- **THEN** it is 7x7 pixels (larger than the standard 5x5)
- **AND** it uses `#ee4540` (red glow) color when it is the current room

#### Scenario: Heal room dots have green tint

- **WHEN** rooms 3 and 6 (heal rooms) are completed
- **THEN** their dots show a subtle green tint `#70c1b3`

#### Scenario: Room transition dot pulse

- **WHEN** the player advances to a new room
- **THEN** the new current room dot scales to 150% then back to 100% over 0.2 seconds

### Requirement: HUD Signal-Driven Architecture

The HUD SHALL connect exclusively to EventBus signals and SHALL NOT hold direct references to game nodes.

#### Scenario: HUD connects to EventBus on ready

- **WHEN** HUD scene enters the tree
- **THEN** it connects to all relevant EventBus signals (health_changed, player_dash_started, player_dash_ready, room_loaded, boss_spawned, enemy_hit, boss_phase_changed, boss_died, player_healed, damage_dealt, damage_taken)
- **AND** delegates updates to the appropriate child HUD element

#### Scenario: HUD processes during hitstop

- **WHEN** `Engine.time_scale` is set to 0 (hitstop) or below 1.0 (slow-mo)
- **THEN** the HUD CanvasLayer continues processing (`process_mode = ALWAYS`)
- **AND** animations and tweens on the HUD remain responsive
