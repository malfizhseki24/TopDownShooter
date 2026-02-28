# Tasks: Add Enemy Pathfinding

## Implementation Tasks

### Phase 1: Infrastructure Setup

- [x] **T1.1** Add NavigationRegion2D node to game.tscn
  - Add as child of Game node
  - Position at origin
  - Leave navigation_polygon empty (will be generated)

- [x] **T1.2** Add navigation_region reference to RoomManager
  - Export variable for NavigationRegion2D
  - Connect in game.gd _ready()

- [x] **T1.3** Create navigation polygon generation in AsciiRoomBuilder
  - Add `create_navigation_polygon()` static function
  - Generate polygon from floor_cells bounds
  - Account for 3-tile border padding
  - Return NavigationPolygon resource

- [x] **T1.4** Integrate navigation generation into room loading
  - Call polygon generation in `build_room()`
  - Store polygon in result dictionary
  - Apply to NavigationRegion2D in RoomManager

### Phase 2: Enemy Scene Updates

- [x] **T2.1** Add NavigationAgent2D to shadow_wisp.tscn
  - Add as child node
  - Set path_desired_distance = 8.0
  - Set target_desired_distance = 10.0

- [x] **T2.2** Add NavigationAgent2D to shadow_crawler.tscn
  - Same configuration as T2.1

- [x] **T2.3** Add NavigationAgent2D to shadow_stalker.tscn
  - Same configuration as T2.1

- [x] **T2.4** Add NavigationAgent2D to shadow_brute.tscn
  - Same configuration as T2.1

### Phase 3: BaseEnemy Integration

- [x] **T3.1** Add pathfinding properties to BaseEnemy
  - Add `@onready var navigation_agent: NavigationAgent2D`
  - Add `_path_update_timer: float = 0.0`
  - Add `const PATH_UPDATE_INTERVAL: float = 0.25`
  - Add `@export var use_pathfinding: bool = true`

- [x] **T3.2** Add pathfinding methods to BaseEnemy
  - `_update_path_to_player()` - requests new path
  - `_get_path_direction()` - returns direction to next waypoint
  - `_get_movement_direction()` - main method that uses pathfinding or falls back

- [x] **T3.3** Modify _physics_process() in BaseEnemy
  - Add path update timer logic
  - Call `_update_path_to_player()` periodically

- [x] **T3.4** Add _ready() setup for NavigationAgent2D
  - Add `_setup_pathfinding()` method
  - Initial path calculation (deferred)
  - Warning if NavigationAgent2D missing but use_pathfinding is true

### Phase 4: Enemy-Specific Adjustments

- [x] **T4.1** Test Shadow Wisp pathfinding
  - Verify navigation around walls
  - Ensure bounce behavior still works
  - Check L-corner navigation

- [x] **T4.2** Test Shadow Crawler pathfinding
  - Verify fast movement with pathfinding
  - Check wall avoidance

- [x] **T4.3** Test Shadow Stalker pathfinding
  - Verify teleport + pathfinding combination
  - Check post-teleport navigation

- [x] **T4.4** Test Shadow Brute pathfinding
  - Verify approach uses pathfinding
  - Ensure charge attack uses direct line (not path)

### Phase 5: Testing & Polish

- [x] **T5.1** Test all 7 room layouts
  - Room 1: Cave with central pillars
  - Room 2: Central diamond pillars
  - Room 3: Heal shrine (no enemies)
  - Room 4: Complex cave with pillars
  - Room 5: Arena with obstacles
  - Room 6: Heal shrine (no enemies)
  - Room 7: Boss arena

- [x] **T5.2** Performance test with 6 enemies
  - Verify frame rate > 55 FPS
  - Check path update timing

- [x] **T5.3** Edge case testing
  - Enemy stuck in wall (spawn position)
  - Player unreachable (should not crash)
  - Room transition while enemy pathfinding

- [x] **T5.4** Final integration test
  - Full playthrough of all 7 rooms
  - Verify game feel maintained
  - No enemies getting stuck

## Validation Checklist

- [x] No enemy gets permanently stuck on walls
- [x] All room layouts work correctly
- [x] Frame rate impact < 5%
- [x] Existing enemy behaviors preserved
- [x] No console errors or warnings

## Dependencies

- T1.x tasks must complete before T3.x
- T2.x tasks can run in parallel with T1.x
- T3.x requires T1.3 and T2.x complete
- T4.x requires T3.x complete
- T5.x requires all previous tasks

## Estimated Effort

| Phase | Tasks | Complexity |
|-------|-------|------------|
| Phase 1 | 4 | Medium |
| Phase 2 | 4 | Low |
| Phase 3 | 4 | Medium |
| Phase 4 | 4 | Low |
| Phase 5 | 4 | Medium |
| **Total** | **20** | - |
