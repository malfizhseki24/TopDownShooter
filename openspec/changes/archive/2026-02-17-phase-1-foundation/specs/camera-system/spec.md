# Camera System Specification

## ADDED Requirements

### Requirement: Pixel Perfect Viewport

The game SHALL render at 480x270 base resolution scaled 4x to 1920x1080 for pixel-perfect rendering.

#### Scenario: Viewport dimensions correct

- **WHEN** game launches
- **THEN** viewport base resolution is 480x270 pixels
- **AND** window size is 1920x1080 pixels

#### Scenario: Pixel perfect stretch mode

- **WHEN** game renders
- **THEN** stretch mode is set to `viewport`
- **AND** stretch aspect is set to `keep`
- **AND** no pixel blur or interpolation occurs

### Requirement: Smooth Follow Camera

The camera SHALL smoothly follow the player using lerp-based interpolation.

#### Scenario: Camera follows player

- **WHEN** player moves
- **THEN** camera position lerps toward player position
- **AND** lerp speed is 5.0

#### Scenario: Camera stays centered on player

- **WHEN** player is stationary
- **THEN** camera gradually centers on player position
- **AND** camera has no offset from player

### Requirement: Camera Pixel Snap

The camera SHALL snap to pixel boundaries to prevent subpixel rendering artifacts.

#### Scenario: Camera position pixel-aligned

- **WHEN** camera moves
- **THEN** camera global position is rounded to nearest integer
- **AND** no subpixel jitter is visible

### Requirement: Texture Import Settings

All texture assets SHALL use Nearest filter mode for pixel-perfect rendering.

#### Scenario: Sprites import with correct settings

- **WHEN** a sprite is imported into the project
- **THEN** texture filter mode is set to `Nearest`
- **AND** mipmaps are disabled
