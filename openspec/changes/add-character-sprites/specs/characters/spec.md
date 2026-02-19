# Character Sprites Specification

## ADDED Requirements

### Requirement: Character Sprite Art Style

All character sprites SHALL follow Octopath Traveler Heroes-inspired art style.

#### Scenario: Visual style consistency

- **WHEN** viewing any character sprite or animation
- **THEN** sprites SHALL have:
  - Chibi proportions (2-3 heads tall, large head 40% of height)
  - Clean dark outlines (not pure black, use dark navy/purple)
  - Muted color palette (dark navy, black, muted red, bone white)
  - Soft shading with 2-3 color shades per element
  - Clear readable silhouettes at small pixel sizes

#### Scenario: Octopath Traveler reference traits

- **WHEN** generating character sprites via PixelLab
- **THEN** prompt SHALL reference Octopath Traveler style for:
  - Proportion and head size
  - Outline style (dark color-matched, not pure black)
  - Shading approach (soft gradients, basic-medium detail)
  - Animation clarity (clear key poses, readable in motion)

### Requirement: Player Character Sprites (Kasuari)

The game SHALL include pixel art sprites for the player character Kasuari rendered at 48x48 canvas with 4-directional views (South, West, East, North) and all required animations.

#### Scenario: Player faces movement direction

- **WHEN** player moves in any direction
- **THEN** the appropriate directional sprite is displayed

#### Scenario: Player animation plays during movement

- **WHEN** player is walking
- **THEN** walk animation cycles at appropriate speed (10 FPS)
- **AND** sprite direction matches movement vector

#### Scenario: Player attack animation

- **WHEN** player shoots an arrow
- **THEN** shoot animation plays (3 frames, 12 FPS)
- **AND** player can still move during animation

#### Scenario: Player dash animation

- **WHEN** player performs dash
- **THEN** dash animation plays (6 frames, 12 FPS)
- **AND** sprite shows motion blur effect

#### Scenario: Player death animation

- **WHEN** player HP reaches 0
- **THEN** death animation plays (7 frames, 12 FPS)
- **AND** triggers respawn after animation completes

### Requirement: Shadow Wisp Enemy Sprites

The game SHALL include pixel art sprites for the Shadow Wisp enemy rendered at 64x64 canvas with 4-directional views and idle/move/death animations.

#### Scenario: Wisp idle animation

- **WHEN** wisp is not moving
- **THEN** floating bob animation plays continuously

#### Scenario: Wisp movement animation

- **WHEN** wisp moves toward player
- **THEN** drifting animation plays with wispy trail effect

#### Scenario: Wisp death animation

- **WHEN** wisp HP reaches 0
- **THEN** dissolve animation plays
- **AND** sprite fades to transparent

### Requirement: Shadow Crawler Enemy Sprites

The game SHALL include pixel art sprites for the Shadow Crawler enemy rendered at 64x64 canvas with 4-directional views as a quadruped creature with walk/attack/death animations.

#### Scenario: Crawler walk animation

- **WHEN** crawler moves
- **THEN** fast crawling animation plays with leg movement

#### Scenario: Crawler attack animation

- **WHEN** crawler attacks player
- **THEN** lunge animation plays
- **AND** hitbox extends during attack frame

### Requirement: Shadow Stalker Enemy Sprites

The game SHALL include pixel art sprites for the Shadow Stalker enemy rendered at 64x64 canvas with 4-directional views and walk/teleport/attack/death animations.

#### Scenario: Stalker teleport animation

- **WHEN** stalker teleports
- **THEN** fade-out animation plays at current position
- **AND** fade-in animation plays at new position

#### Scenario: Stalker attack animation

- **WHEN** stalker attacks after teleport
- **THEN** ambush strike animation plays

### Requirement: Shadow Brute Enemy Sprites

The game SHALL include pixel art sprites for the Shadow Brute enemy rendered at 64x64 canvas with 4-directional views and walk/charge/attack/death animations.

#### Scenario: Brute walk animation

- **WHEN** brute moves
- **THEN** slow heavy step animation plays

#### Scenario: Brute charge animation

- **WHEN** brute begins charge attack
- **THEN** charging animation plays with momentum buildup

#### Scenario: Brute attack animation

- **WHEN** brute performs ground slam
- **THEN** slam animation plays with impact frame

### Requirement: Shadow Boar Boss Sprites

The game SHALL include pixel art sprites for the Shadow Boar boss rendered at 96x96 canvas with 4-directional views and walk/charge/slam/death animations.

#### Scenario: Boss idle animation

- **WHEN** boss is not attacking
- **THEN** menacing idle animation plays with shadow aura effect

#### Scenario: Boss charge animation

- **WHEN** boss charges across arena
- **THEN** charging animation plays with shadow trail effect

#### Scenario: Boss slam animation

- **WHEN** boss performs ground slam (Phase 2)
- **THEN** slam animation plays with shockwave visual

#### Scenario: Boss death animation

- **WHEN** boss HP reaches 0
- **THEN** dramatic death animation plays
- **AND** triggers victory screen

### Requirement: Sprite Direction System

All characters SHALL support 4-directional sprite facing (South, West, East, North) with automatic direction selection based on movement or facing vector.

#### Scenario: Automatic direction selection

- **WHEN** character moves or faces a direction
- **THEN** the closest matching sprite direction is selected
- **AND** East/West sprites can be mirrored for efficiency

#### Scenario: Direction during attack

- **WHEN** character attacks
- **THEN** sprite faces the attack target direction
- **AND** animation plays for that direction

### Requirement: Animation Frame Timing

All character animations SHALL use consistent frame timings as specified in the design document.

#### Scenario: Animation playback speed

- **WHEN** any animation plays
- **THEN** frames advance at consistent rate:
  - Idle/Walk: 10 FPS
  - Actions (shoot, dash, death): 12 FPS
- **AND** animation loops seamlessly for cyclic animations
