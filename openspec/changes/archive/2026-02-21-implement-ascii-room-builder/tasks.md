# Tasks: Implement ASCII Room Builder

## 0. Preparation

- [x] 0.1 Archive `add-stage-generator` change with `--skip-specs` (BSP specs are obsolete)
- [x] 0.2 Archive `create-jungle-tileset` change with `--skip-specs` (tilesets already generated)

## 1. BSP System Cleanup

- [x] 1.1 Remove `scripts/stage/stage_generator.gd` and its `.uid` file
- [x] 1.2 Remove `scripts/stage/stage_config.gd` and its `.uid` file
- [x] 1.3 Remove `scripts/stage/stage_data.gd` and its `.uid` file
- [x] 1.4 Remove `scripts/stage/room_data.gd` (BSP partition tree) and its `.uid` file
- [x] 1.5 Remove `scripts/stage/run_manager.gd` and its `.uid` file
- [x] 1.6 Remove `scenes/stage/base_stage.tscn`
- [x] 1.7 Remove `resources/stage_configs/default_stage.tres`
- [x] 1.8 Remove pre-built room scenes (`scenes/rooms/room_1.tscn` through `room_7.tscn`, `room_template.tscn`)
- [x] 1.9 Remove room config resources (`resources/rooms/room_1.tres` through `room_7.tres`)
- [x] 1.10 Remove BSP test files (`tests/test_stage_generator.*`, `tests/test_stage_headless.gd`)
- [x] 1.11 Verify no remaining imports reference removed files — also removed `linear_stage_config.gd`, `room_data_resource.gd`, `enemy_wave_data.gd`, `enemy_spawn_data.gd`, `stage_1.tres`

## 2. Room Blueprints Data

- [x] 2.1 Create `scripts/stage/room_blueprints.gd` with `class_name RoomBlueprints`
- [x] 2.2 Define ASCII legend constants (WALL='#', FLOOR='.', PLAYER='P', ENEMY='E', BOSS='B', SHRINE='S', PORTAL='X', OBSTACLE='O')
- [x] 2.3 Define Room 1 ASCII map (15x11, tutorial: 3x Wisp, open layout with obstacles)
- [x] 2.4 Define Room 2 ASCII map (17x11, mixed: 2x Wisp + 2x Crawler, interior wall cover)
- [x] 2.5 Define Room 3 ASCII map (15x9, heal shrine, peaceful with decorations)
- [x] 2.6 Define Room 4 ASCII map (17x13, stalker: 2x Wisp + 2x Crawler + 1x Stalker, pillar pairs)
- [x] 2.7 Define Room 5 ASCII map (19x13, all types: 3x Crawler + 2x Stalker + 1x Brute, arena)
- [x] 2.8 Define Room 6 ASCII map (15x9, pre-boss heal shrine)
- [x] 2.9 Define Room 7 ASCII map (21x15, boss arena: Shadow Boar, corner pillars)
- [x] 2.10 Define ROOMS dictionary with per-room metadata (type, tileset path, wave configs)

## 3. ASCII Room Builder Core

- [x] 3.1 Create `scripts/stage/ascii_room_builder.gd` with `class_name AsciiRoomBuilder`
- [x] 3.2 Implement `_parse_ascii(map_string: String) -> Dictionary` — returns grid, width, height
- [x] 3.3 Implement `_classify_cells(grid) -> Dictionary` — returns wall_cells, floor_cells, entity positions
- [x] 3.4 Implement `_add_border_padding(wall_cells, width, height) -> Array[Vector2i]` — 1-tile wall border for clean Wang edges
- [x] 3.5 Implement `_paint_terrain(tile_layer, wall_cells, floor_cells)` — uses `set_cells_terrain_connect()` with TERRAIN_WALL=1 and TERRAIN_FLOOR=0
- [x] 3.6 Implement `_convert_to_world_positions(tile_positions, tile_layer) -> Array[Vector2]` — `map_to_local()` conversion
- [x] 3.7 Implement main `build_room(map_string: String, tileset: TileSet) -> Dictionary` — orchestrates parsing, painting, returns all positions + TileMapLayer node

## 4. @tool Editor Preview

- [x] 4.1 Create `scenes/stage/room_preview.tscn` with a Node2D root
- [x] 4.2 Create `scripts/stage/room_preview.gd` as @tool script
- [x] 4.3 Add `@export var room_index: int` and `@export var tileset: TileSet` properties
- [x] 4.4 Add `@export var build_room: bool` setter that triggers `_preview_room()` in editor
- [x] 4.5 Implement `_preview_room()` — clears children, calls builder, adds Marker2D nodes for entities
- [x] 4.6 Test: Open room_preview.tscn in editor, select room_index, click build_room checkbox, verify room appears in viewport

## 5. RoomManager Integration

- [x] 5.1 RoomManager rewritten with `@export var tileset: TileSet` (no more builder instance — all methods are static)
- [x] 5.2 `load_room()` calls `AsciiRoomBuilder.build_room()` with blueprint from `RoomBlueprints.get_room()`
- [x] 5.3 Store returned spawn positions (player, enemies, portal, shrine, boss) from builder output
- [x] 5.4 `_setup_combat_room()` uses blueprint waves and builder enemy spawn positions
- [x] 5.5 `_setup_heal_room()` uses builder-returned shrine position
- [x] 5.6 `_setup_boss_room()` uses builder-returned boss spawn position
- [x] 5.7 Wave configs come from `RoomBlueprints.ROOMS` dictionary
- [x] 5.8 Removed old `_get_spawn_positions_for_room()` method
- [x] 5.9 Removed old `_get_enemy_waves_for_room()` method

## 6. Game Scene Updates

- [x] 6.1 Update `game.gd` to remove `LinearStageConfig` dependency, use `RoomBlueprints.get_total_rooms()`
- [x] 6.2 Update `game.tscn` with tileset reference on RoomManager node
- [x] 6.3 Camera follows player correctly (PixelCamera targets player node, unchanged)
- [x] 6.4 HUD updates verified (room label, health bar, enemies count — all use RoomManager properties)
- [x] 6.5 Fixed `_on_all_rooms_cleared()` to call `GameManager.trigger_victory()` (was missing)
- [x] 6.6 Removed orphaned files: `linear_stage_config.gd`, `room_data_resource.gd`, `enemy_wave_data.gd`, `enemy_spawn_data.gd`, `stage_1.tres`

## 7. Room-by-Room Verification

- [x] 7.1 Room 1: 15x11, 3 E markers, P at bottom center, X at top center, 2 O obstacles, waves: 3x wisp
- [x] 7.2 Room 2: 17x11, 4 E markers, interior ## blocks for cover, waves: 2x wisp + 2x crawler
- [x] 7.3 Room 3: 15x9, S shrine, 4 O decorations, type: heal, no enemies
- [x] 7.4 Room 4: 17x13, 5 E markers, ## pillar pairs, waves: 2x wisp + 2x crawler + 1x stalker
- [x] 7.5 Room 5: 19x13, 6 E markers, arena with cover, waves: 3x crawler + 2x stalker + 1x brute
- [x] 7.6 Room 6: 15x9, S shrine, 4 O decorations, type: heal (matches Room 3 structure)
- [x] 7.7 Room 7: 21x15, B boss spawn, 4 O corner pillars, type: boss

## 8. Integration Testing (Static Analysis)

- [x] 8.1 Signal flow: room_loaded/room_cleared/all_rooms_cleared chain verified end-to-end
- [x] 8.2 Enemy wave spawning: RoomManager reads waves from blueprints, spawns at E positions
- [x] 8.3 Wall collision: TileMapLayer with TERRAIN_WALL gets collision from TileSet physics layer
- [x] 8.4 Arrow collision: arrows use wall physics layer (unchanged from pre-ASCII system)
- [x] 8.5 Room clearing: _on_enemy_died decrements counter → spawns portal when 0
- [x] 8.6 Heal shrine: loads at S position, _on_room_cleared immediate, portal spawns
- [x] 8.7 Boss room: triggers victory via all_rooms_cleared → GameManager.trigger_victory() (fixed)
- [x] 8.8 No dangling references to removed BSP files (grep verified)

## 9. Runtime Bug Fixes (Playtesting)

- [x] 9.1 Fix `RoomBlueprints` @tool initialization: changed `static var ROOMS` to `const ROOMS` (editor preview crash)
- [x] 9.2 Fix invisible heal shrine: replaced empty Sprite2D with Polygon2D-based visual (ShrineVisual node)
- [x] 9.3 Fix enemies leaking into heal rooms: added `_room_generation` counter to cancel stale wave coroutines on room transition
- [x] 9.4 Fix portal not spawning after clearing Room 1: added wave-clear check after advancing `_current_wave_index`
- [x] 9.5 Fix infinite respawn in rooms 4/5: added `_spawn_generation` counter to cancel stale spawn coroutines within same room
- [x] 9.6 Remove enemy self-respawn system: stripped `SCENE` preload, `RESPAWN_DELAY`, respawn lambda, and `_get_respawn_position()` from all 4 enemy scripts (crawler, stalker, brute, wisp); all now call `super.die()`

## Known Pre-existing Issues (Not in scope)

- `EventBus.boss_died` is never emitted (BaseEnemy.die() only emits `enemy_died`) — boss room clearing works via `_on_enemy_died` path
- Player death/respawn race condition: player auto-respawns after 1s, game_over fires after 1.5s

## Dependencies

- Tilesets: jungle_ruins.tres (ready)
- Enemy scenes: shadow_wisp, shadow_crawler, shadow_stalker, shadow_brute (all ready)
- Boss scene: Not yet implemented (Phase 4) — Room 7 uses shadow_brute as placeholder
- Portal scene: `scenes/interactables/room_portal.tscn` (ready)
- Heal shrine scene: `scenes/interactables/heal_shrine.tscn` (ready)
