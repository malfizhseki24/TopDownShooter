# player Specification

## Purpose

Defines the player character (Kasuari) visual style, animation system, rendering approach, respawn behavior, and frame rate conventions. This spec covers the player's presentation layer — combat mechanics are in `player-combat`, movement in `player-movement`, aiming in `player-aiming`.
## Requirements
### Requirement: Character Sprite Art Style

The player character sprites SHALL follow Octopath Traveler Heroes-inspired art style.

#### Scenario: Visual style consistency

- **WHEN** viewing any player sprite or animation
- **THEN** sprites SHALL have:
  - Chibi proportions (2-3 heads tall, large head 40% of height)
  - Clean dark outlines (not pure black, use dark navy/purple)
  - Muted color palette (dark navy, black, muted red, bone white)
  - Soft shading with 2-3 color shades per element
  - Clear readable silhouettes at 48x48 pixel size

#### Scenario: Octopath Traveler reference traits

- **WHEN** generating character sprites via PixelLab
- **THEN** prompt SHALL reference Octopath Traveler style for:
  - Proportion and head size
  - Outline style (dark color-matched, not pure black)
  - Shading approach (soft gradients, basic-medium detail)
  - Animation clarity (clear key poses, readable in motion)

### Requirement: Player Animation System

The player character SHALL have a 4-directional animation system with state-based playback.

#### Scenario: Idle animation plays when stationary

- **WHEN** player velocity magnitude is less than 10 px/sec
- **AND** no action animation is playing
- **THEN** "idle" animation plays in the direction of aim

#### Scenario: Walk animation plays when moving

- **WHEN** player velocity magnitude is 10 px/sec or greater
- **AND** no action animation is playing
- **THEN** "walk" animation plays in the direction of aim

#### Scenario: Animation direction follows aim

- **WHEN** player aims toward any direction
- **THEN** animation uses the appropriate directional sprites:
  - aim_direction.y < -0.5 → north
  - aim_direction.y > 0.5 → south
  - aim_direction.x < 0 → west (flip east sprites)
  - aim_direction.x >= 0 → east

#### Scenario: Shoot animation plays once

- **WHEN** player fires an arrow
- **THEN** "shoot" animation plays once (3 frames, 12 FPS)
- **AND** returns to previous state (idle or walk) after completion

#### Scenario: Dash animation plays once

- **WHEN** player initiates a dash
- **THEN** "dash" animation plays once (6 frames, 12 FPS)
- **AND** returns to previous state (idle or walk) after completion

#### Scenario: Action animations are uninterruptible

- **WHEN** an action animation (shoot, dash) is playing
- **THEN** movement animations (idle, walk) SHALL NOT interrupt it
- **AND** only death animation can interrupt action animations

#### Scenario: Death animation plays and triggers respawn

- **WHEN** player HP reaches 0
- **THEN** "death" animation plays once (7 frames, 12 FPS)
- **AND** player input is disabled
- **AND** respawn is triggered after animation completes

### Requirement: Player Respawn

The player character SHALL respawn after death with full health and brief invincibility.

#### Scenario: Player respawns after death

- **WHEN** death animation completes
- **THEN** player position is reset to spawn point
- **AND** HP is restored to MAX_HP (100)
- **AND** all state flags are reset (is_dead, is_dashing, can_dash, can_shoot)

#### Scenario: Post-respawn invincibility

- **WHEN** player respawns
- **THEN** player is invincible for 1.0 second
- **AND** visual feedback indicates invincibility (flash white)

#### Scenario: Player respawn signal

- **WHEN** player respawns
- **THEN** `player_respawned` signal is emitted via EventBus
- **AND** health UI is updated to show full health

### Requirement: Animation Frame Rates

The player animations SHALL use consistent frame rates.

#### Scenario: Movement animation speed

- **WHEN** idle or walk animation plays
- **THEN** frame rate is 10 FPS

#### Scenario: Action animation speed

- **WHEN** shoot, dash, or death animation plays
- **THEN** frame rate is 12 FPS

### Requirement: Player Rendering

The player character SHALL use AnimatedSprite2D instead of static Sprite2D.

#### Scenario: Sprite rendering

- **WHEN** player is visible in the game world
- **THEN** AnimatedSprite2D displays the current animation frame
- **AND** sprite is centered on the player's collision position
- **AND** scale is 0.5x (matching original Sprite2D scale)

### Requirement: Player Hitbox Detection

The player Hitbox SHALL detect enemy collisions and trigger damage.

#### Scenario: Enemy contact damage

- **WHEN** enemy body enters player Hitbox area
- **THEN** player.take_damage(enemy.contact_damage) is called
- **AND** damage value is retrieved from enemy.get_contact_damage()

#### Scenario: Hitbox collision layers

- **WHEN** player is in game
- **THEN** player Hitbox is on "player" collision layer
- **AND** Hitbox detects "enemy" collision layer

