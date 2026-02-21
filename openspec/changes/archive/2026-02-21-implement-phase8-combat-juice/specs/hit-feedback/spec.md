## MODIFIED Requirements

### Requirement: Hit Flash Shader (All Entities)

The hit flash shader SHALL be applied to all damageable entity sprites (player and all enemies), replacing any modulate-based flash.

#### Scenario: Enemy white flash on hit

- **WHEN** an enemy takes damage
- **THEN** the enemy's sprite `ShaderMaterial` `flash_intensity` is set to 1.0 with `flash_color = vec4(1.0, 1.0, 1.0, 1.0)`
- **AND** `flash_intensity` tweens from 1.0 to 0.0 over 0.08 seconds

#### Scenario: Shared shader file

- **WHEN** hit flash is applied to any entity
- **THEN** the shader is loaded from `shaders/hit_flash.gdshader`
- **AND** each entity has its own `ShaderMaterial` instance with independent uniforms

### Requirement: Screen Flash Effects

The game SHALL display full-screen color overlays for specific combat and interaction events.

#### Scenario: Player damage red flash

- **WHEN** the player takes damage from a regular enemy
- **THEN** a red overlay (Color `#ee4540`, 20% opacity) appears and fades out over 0.15 seconds
- **AND** the overlay is a `ColorRect` on the HUD `CanvasLayer` with `process_mode = ALWAYS`

#### Scenario: Boss damage intense red flash

- **WHEN** the player takes damage from the boss
- **THEN** a red overlay (Color `#ee4540`, 35% opacity) appears and fades out over 0.2 seconds

#### Scenario: Boss phase transition white flash

- **WHEN** the boss enters phase 2
- **THEN** a white overlay (Color `#ffffff`, 60% opacity) flashes for 0.15 seconds

#### Scenario: Heal shrine green pulse

- **WHEN** the player uses a heal shrine
- **THEN** a green overlay (Color `#70c1b3`, 15% opacity) pulses and fades over 0.4 seconds

#### Scenario: Player death screen fade

- **WHEN** the player dies
- **THEN** the screen desaturates over 0.5 seconds
- **AND** a black overlay fades in to full opacity over the next 1.0 seconds (1.5 seconds total)

### Requirement: Knockback Polish

Enemy and player knockback SHALL use impulse-based velocity with friction decay instead of position tweens.

#### Scenario: Arrow knockback on enemy

- **WHEN** an arrow hits an enemy (non-kill)
- **THEN** a knockback impulse of 80px magnitude is applied in the arrow's direction
- **AND** the velocity decays via `move_toward(Vector2.ZERO, 600.0 * delta)` each physics frame

#### Scenario: Melee knockback on enemy

- **WHEN** a melee attack hits an enemy (non-kill)
- **THEN** a knockback impulse of 150px magnitude is applied away from the player

#### Scenario: Kill knockback amplification

- **WHEN** an enemy is killed by an arrow
- **THEN** a knockback impulse of 120px is applied (instead of 80px)
- **AND** a melee kill applies 200px (instead of 150px)

#### Scenario: Boss knockback resistance

- **WHEN** the boss takes damage from an arrow
- **THEN** a knockback impulse of only 20px is applied
- **AND** melee attacks apply only 40px knockback

#### Scenario: Player knockback on hit

- **WHEN** the player takes damage from an enemy
- **THEN** a knockback impulse of 60px is applied away from the enemy
- **AND** boss damage applies 100px knockback

### Requirement: Squash/Stretch Deformation

Sprites SHALL use scale deformation to convey weight and impact.

#### Scenario: Enemy hit squash

- **WHEN** an enemy takes damage
- **THEN** the enemy sprite scales to `(1.3, 0.7)` instantly
- **AND** tweens back to `(1.0, 1.0)` over 0.1 seconds

#### Scenario: Enemy death stretch

- **WHEN** an enemy dies
- **THEN** the enemy sprite scales to `(0.6, 1.4)`
- **AND** the dissolve/fade animation plays from this stretched state

#### Scenario: Player dash landing squash

- **WHEN** the player's dash ends
- **THEN** the player sprite scales to `(1.2, 0.8)` instantly
- **AND** tweens back to `(1.0, 1.0)` over 0.08 seconds

#### Scenario: Arrow speed stretch

- **WHEN** an arrow is spawned
- **THEN** the arrow sprite scale is set to `(0.8, 1.2)` along its travel axis
