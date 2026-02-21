# hit-feedback Specification

## Purpose

Defines the shader-based hit flash system that replaces the placeholder `modulate` approach, providing proper visual feedback for damage events.

## ADDED Requirements

### Requirement: Hit Flash Shader

All damageable entities SHALL use a `hit_flash.gdshader` for visual damage feedback instead of modulate-based color changes.

#### Scenario: Shader file exists

- **WHEN** the project is loaded
- **THEN** `shaders/hit_flash.gdshader` exists
- **AND** it has `flash_intensity` (float 0.0–1.0) and `flash_color` (vec4) uniforms

#### Scenario: White flash on enemy hit

- **WHEN** an enemy takes damage
- **THEN** the enemy sprite's `flash_intensity` is set to 1.0
- **AND** it tweens to 0.0 over 0.08 seconds
- **AND** `flash_color` is white (1.0, 1.0, 1.0, 1.0)

#### Scenario: Red flash on player hit

- **WHEN** player takes damage
- **THEN** the player sprite's `flash_color` is set to red (1.0, 0.2, 0.2, 1.0)
- **AND** `flash_intensity` is set to 1.0
- **AND** it tweens to 0.0 over 0.12 seconds

#### Scenario: White flash on player respawn

- **WHEN** player respawns
- **THEN** player sprite flashes white using the same shader
- **AND** `flash_color` is white, `flash_intensity` pulses 3 times over 0.6 seconds

### Requirement: Player Hit Feedback

Player damage feedback SHALL use the hit flash shader instead of modulate-based color changes.

#### Scenario: Flash replaces modulate

- **WHEN** player takes damage
- **THEN** `_flash_red()` uses ShaderMaterial `flash_intensity` tween
- **AND** `sprite.modulate` is NOT changed (remains Color.WHITE)
- **AND** the shader handles the visual flash effect

### Requirement: Player Respawn Feedback

Player respawn feedback SHALL use the hit flash shader instead of modulate-based flashing.

#### Scenario: Respawn flash replaces modulate

- **WHEN** player respawns and invincibility starts
- **THEN** `_flash_white()` uses ShaderMaterial `flash_intensity` pulses
- **AND** `sprite.modulate` is NOT changed
