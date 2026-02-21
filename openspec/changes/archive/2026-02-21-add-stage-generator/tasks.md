# Tasks: Stage Generator Engine

## 0. Asset Generation (Pixellab MCP)
- [x] 0.1 Generate ground→wall topdown tileset (jungle floor → stone ruins)
- [ ] 0.2 Generate shadow pool spawn point sprite (tool issue - skipped)
- [ ] 0.3 Generate decoration sprites (tool issue - skipped)
- [x] 0.4 Download tileset metadata and image files
- [x] 0.5 Create TileSet resource using converter script
- [x] 0.6 Import sprites to `assets/tilesets/`

## 1. Core Data Structures
- [x] 1.1 Create `scripts/stage/` directory
- [x] 1.2 Create `stage_config.gd` - Configuration resource with export vars
- [x] 1.3 Create `stage_data.gd` - Generated data container
- [x] 1.4 Create `enemy_spawn_data.gd` - Spawn point data class
- [x] 1.5 Create `room_data.gd` - Room partition data structure

## 2. BSP Generator Module
- [x] 2.1 BSP logic integrated into `room_data.gd`
- [x] 2.2 Implement `split()` - Split rectangle into two children
- [x] 2.3 Implement `get_leaves()` - Get all leaf nodes (rooms)
- [x] 2.4 Add partition depth and size constraints

## 3. Stage Generator Core
- [x] 3.1 Create `stage_generator.gd` - Main orchestrator class
- [x] 3.2 Implement `_ready()` - Initialize RNG and references
- [x] 3.3 Implement `generate(seed_value)` - Main generation entry point
- [x] 3.4 Implement `_generate_rooms()` - Create rooms from BSP leaves
- [x] 3.5 Implement `_generate_corridors()` - Connect rooms with corridors
- [x] 3.6 Implement `_place_tiles()` - Set tiles on TileMapLayers using terrain painting
- [x] 3.7 Implement `_place_spawn_points()` - Add player and enemy spawns

## 4. TileMap Integration
- [x] 4.1 Create `scenes/stage/base_stage.tscn` with TileMapLayer nodes
- [x] 4.2 Set up layer Z-index ordering (Ground < Walls < Decorations)
- [x] 4.3 Configure physics layer on Wall TileMapLayer
- [x] 4.4 Import Pixellab TileSet resource
- [x] 4.5 Implement terrain-based tile placement using `set_cells_terrain_connect()`

## 5. Collision Setup
- [ ] 5.1 Configure collision on wall terrain in TileSet
- [ ] 5.2 Verify player collision with walls
- [ ] 5.3 Verify enemy collision with walls
- [ ] 5.4 Verify arrow collision with walls

## 6. Spawn System Integration
- [x] 6.1 Calculate valid spawn positions in rooms
- [x] 6.2 Place player spawn in first room
- [x] 6.3 Place enemy spawns based on enemy_density config
- [x] 6.4 Place boss spawn in boss room (if enabled)
- [x] 6.5 Create enemy type selection logic (based on room size/type)

## 7. Decoration System
- [ ] 7.1 Create decoration sprites (skipped - Pixellab tool issue)
- [ ] 7.2 Place decorations randomly in rooms and corridors
- [ ] 7.3 Place shadow pool sprites at enemy spawn points
- [ ] 7.4 Add variation to decoration placement

## 8. Testing & Validation
- [x] 8.1 Create test scene for generator (`tests/test_stage_generator.tscn`)
- [ ] 8.2 Test seed reproducibility (same seed = same map)
- [ ] 8.3 Test all rooms are connected
- [ ] 8.4 Test collision works correctly
- [ ] 8.5 Test spawn points are in valid positions
- [ ] 8.6 Performance test (generation should be < 100ms)

## 9. Integration
- [ ] 9.1 Update game flow to use generated stage
- [ ] 9.2 Connect player spawn to generated position
- [ ] 9.3 Connect enemy spawn system to StageData
- [ ] 9.4 Add regenerate option for testing
- [x] 9.5 Create default StageConfig resource

## 10. Polish
- [ ] 10.1 Add debug visualization (room bounds, corridors)
- [ ] 10.2 Add editor "Generate Preview" button (optional)
- [ ] 10.3 Balance enemy density values
- [ ] 10.4 Documentation comments in code
