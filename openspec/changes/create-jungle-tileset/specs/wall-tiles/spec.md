# Wall Tiles Specification

## ADDED Requirements

### Requirement: 32x32 Pixel Wall Tiles

Wall tiles SHALL be 32x32 pixels with an ancient stone ruins appearance.

#### Scenario: Tile dimensions correct

- **WHEN** tileset is generated
- **THEN** each wall tile is exactly 32x32 pixels
- **AND** tiles align perfectly with ground tiles

#### Scenario: Stone ruins aesthetic

- **WHEN** wall tiles are rendered
- **THEN** they display ancient stone ruin texture
- **AND** colors include weathered gray and dark green moss patches
- **AND** tribal carving details may be visible

### Requirement: Solid Collision

Wall tiles SHALL have collision that blocks player and arrow movement.

#### Scenario: Player blocked by walls

- **WHEN** player attempts to move into a wall tile
- **THEN** player stops at wall boundary
- **AND** player does not pass through

#### Scenario: Arrows stopped by walls

- **WHEN** arrow projectile hits a wall tile
- **THEN** arrow is destroyed
- **AND** arrow does not pass through

### Requirement: Collision Shape

Wall tiles SHALL have rectangular collision shapes covering the full tile.

#### Scenario: Full tile collision

- **WHEN** wall tile is configured in TileSet
- **THEN** collision polygon covers entire 32x32 area
- **AND** collision is on physics layer 4 (wall)

### Requirement: Ground-to-Wall Transition

Wall tiles SHALL visually transition from ground tiles with no harsh edges.

#### Scenario: Transition tiles exist

- **WHEN** placing wall adjacent to ground
- **THEN** transition tiles are available
- **AND** edges blend naturally between terrains

#### Scenario: Wang tile corner matching

- **WHEN** tiles are placed in TileMap
- **THEN** corners match adjacent terrain types
- **AND** no visual discontinuity at tile boundaries
