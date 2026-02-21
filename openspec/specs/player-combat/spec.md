# player-combat Specification

## Purpose

Defines the player's combat forgiveness mechanics: damage i-frames (0.8s with sprite flicker), input buffering (0.15s window), dash forgiveness window (0.12s post-hit), and hitbox manipulation (hurtbox r=10 separated from physics body r=12).
## Requirements
### Requirement: Damage I-Frames

The player SHALL become invincible for 0.8 seconds after taking damage, with a visible flicker effect.

#### Scenario: Invincibility activates on damage

- **WHEN** player takes damage from any source
- **AND** player is not already invincible
- **THEN** player becomes invincible for 0.8 seconds
- **AND** further damage is ignored during this window

#### Scenario: Sprite flickers during i-frames

- **WHEN** damage i-frames are active
- **THEN** player sprite toggles visibility every 0.08 seconds
- **AND** flicker stops and sprite becomes fully visible when i-frames end

#### Scenario: Dash i-frames override damage i-frames

- **WHEN** player dashes during damage i-frames
- **THEN** dash i-frames take priority (full dash duration)
- **AND** the longer remaining duration wins when dash ends

#### Scenario: I-frames do not activate on death

- **WHEN** player HP reaches 0 from damage
- **THEN** damage i-frames do NOT activate
- **AND** death sequence proceeds normally

### Requirement: Input Buffering

The player SHALL queue the most recent action input during animations or cooldowns and execute it at the earliest available frame.

#### Scenario: Dash buffered during shoot animation

- **WHEN** player presses dash while shoot animation is playing
- **AND** dash is not on cooldown
- **THEN** dash executes on the first frame after shoot animation ends
- **AND** the buffered input is consumed

#### Scenario: Shoot buffered during dash cooldown

- **WHEN** player presses shoot while fire rate cooldown is active
- **THEN** shoot executes on the first frame after cooldown expires
- **AND** the buffered input is consumed

#### Scenario: Buffer expires after window

- **WHEN** a buffered input is older than 0.15 seconds
- **THEN** the buffered input is discarded
- **AND** the action does not execute

#### Scenario: Only most recent input is buffered

- **WHEN** player presses dash then immediately presses shoot within the buffer window
- **THEN** only shoot is buffered (most recent wins)
- **AND** dash input is discarded

#### Scenario: Buffer cleared on death

- **WHEN** player dies
- **THEN** all buffered inputs are cleared
- **AND** no buffered actions execute during death or respawn

### Requirement: Dash Forgiveness Window

The player SHALL be able to dash within 0.12 seconds after taking damage, bypassing any damage animation lock.

#### Scenario: Dash during forgiveness window

- **WHEN** player takes damage
- **AND** player presses dash within 0.12 seconds of the hit
- **AND** dash is not on cooldown
- **THEN** dash executes immediately
- **AND** player receives dash i-frames

#### Scenario: Dash outside forgiveness window

- **WHEN** player takes damage
- **AND** player presses dash after 0.12 seconds have elapsed
- **THEN** dash follows normal input rules (buffered or immediate if available)

### Requirement: Hitbox Manipulation

The player's damage hurtbox SHALL be smaller than the visual sprite, and separated from the physics collision body.

#### Scenario: Player hurtbox is smaller than sprite

- **WHEN** player is in the game world
- **THEN** HurtboxArea collision shape is Circle with radius 10 px
- **AND** this is ~42% of the 48x48 sprite size
- **AND** hurtbox is centered on the player's feet position

#### Scenario: Player physics body is separate from hurtbox

- **WHEN** player collides with walls
- **THEN** CharacterBody2D collision shape is Circle with radius 12 px
- **AND** this is used for wall/obstacle collision only
- **AND** it does NOT receive damage — only HurtboxArea does

#### Scenario: Enemy contact damage uses hurtbox

- **WHEN** an enemy overlaps the player
- **THEN** damage is detected via HurtboxArea (r=10), not the physics body (r=12)
- **AND** enemies must get closer than the visual sprite edge to deal damage

