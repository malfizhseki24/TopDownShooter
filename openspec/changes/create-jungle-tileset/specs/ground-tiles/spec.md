# Ground Tiles Specification

## ADDED Requirements

### Requirement: 32x32 Pixel Ground Tiles

Ground tiles SHALL be 32x32 pixels with a dark jungle floor appearance.

#### Scenario: Tile dimensions correct

- **WHEN** tileset is generated
- **THEN** each tile is exactly 32x32 pixels
- **AND** tiles align perfectly in a grid

#### Scenario: Jungle floor aesthetic

- **WHEN** ground tiles are rendered
- **THEN** they display dark jungle floor texture
- **AND** colors include dark green and brown earth tones
- **AND** roots and dirt details are visible

### Requirement: Walkable Surface

Ground tiles SHALL have no collision and allow free player movement.

#### Scenario: Player walks on ground

- **WHEN** player moves over ground tiles
- **THEN** player does not collide with ground
- **AND** player can move freely in all directions

#### Scenario: No collision shape

- **WHEN** ground tiles are placed in TileMap
- **THEN** no collision polygon is defined
- **AND** physics bodies pass through

### Requirement: Seamless Tiling

Ground tiles SHALL tile seamlessly without visible gaps or patterns.

#### Scenario: Adjacent ground tiles connect

- **WHEN** multiple ground tiles are placed adjacent
- **THEN** no visible seams or gaps appear
- **AND** texture pattern does not obviously repeat

### Requirement: Pixel Perfect Rendering

Ground tiles SHALL use Nearest filter mode for pixel-perfect rendering.

#### Scenario: No blur on ground tiles

- **WHEN** game renders at 4x scale
- **THEN** ground tiles display crisp pixels
- **AND** no interpolation or blur occurs
