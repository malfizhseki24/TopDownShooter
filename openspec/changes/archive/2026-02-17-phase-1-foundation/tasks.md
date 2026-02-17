# Tasks: Phase 1 - Foundation

## 1. Project Structure Setup

- [x] 1.1 Create folder structure (`scenes/`, `scripts/`, `assets/`, `resources/`)
- [x] 1.2 Create subfolders (`scenes/player/`, `scenes/levels/`, `scripts/player/`, `scripts/autoload/`, `scripts/camera/`)
- [x] 1.3 Create `GameManager` autoload script (`scripts/autoload/game_manager.gd`)
- [x] 1.4 Create `EventManager` autoload script (`scripts/autoload/event_bus.gd`)
- [x] 1.5 Register autoloads in Project Settings
- [x] 1.6 Configure input map actions (`move_up`, `move_down`, `move_left`, `move_right`, `shoot`, `interact`)
- [x] 1.7 Name physics layers in Project Settings (player, enemy, arrow, wall)

**Status:** ✅ Complete

## 2. Project Settings Configuration

- [x] 2.1 Set viewport dimensions (480x270)
- [x] 2.2 Set window size (1920x1080)
- [x] 2.3 Configure stretch mode (`viewport`) and aspect (`keep`)
- [x] 2.4 Set default texture filter to Nearest
- [x] 2.5 Disable mipmaps by default

**Status:** ✅ Complete

## 3. Camera System

- [x] 3.1 Create `PixelCamera` script (`scripts/camera/pixel_camera.gd`)
- [x] 3.2 Implement smooth lerp follow (speed: 5.0)
- [x] 3.3 Add pixel snap to camera position
- [x] 3.4 Create Camera2D node in test level
- [x] 3.5 Assign PixelCamera script and set as current

**Status:** ✅ Complete (using `scripts/utils/pixel_camera_2d.gd`)

## 4. Player Scene

- [x] 4.1 Create Player scene (`scenes/player/Player.tscn`) with CharacterBody2D root
- [x] 4.2 Add Sprite2D with Kasuari south-facing sprite
- [x] 4.3 Add CollisionShape2D (capsule or rectangle)
- [x] 4.4 Set collision layer to `player` (layer 1)
- [x] 4.5 Set collision mask to `wall` (layer 4)

**Status:** ✅ Complete

## 5. Player Movement Script

- [x] 5.1 Create player script (`scripts/player/player.gd`)
- [x] 5.2 Implement 8-directional input using `Input.get_vector()`
- [x] 5.3 Set move speed to 200 px/sec
- [x] 5.4 Implement `move_and_slide()` in `_physics_process`
- [x] 5.5 Attach script to Player scene

**Status:** ✅ Complete

## 6. Player Aiming

- [x] 6.1 Add `get_aim_direction()` function to player script
- [x] 6.2 Calculate direction from player to `get_global_mouse_position()`
- [x] 6.3 Normalize and return as Vector2

**Status:** ✅ Complete (as `aim_direction` property)

## 7. Arrow Scene

- [x] 7.1 Create Arrow scene (`scenes/player/Arrow.tscn`) with Area2D root
- [x] 7.2 Add Sprite2D with arrow sprite (placeholder or asset)
- [x] 7.3 Add CollisionShape2D
- [x] 7.4 Set collision layer to `arrow` (layer 3)
- [x] 7.5 Set collision mask to `enemy` (layer 2) and `wall` (layer 4)
- [x] 7.6 Create arrow script (`scripts/player/arrow.gd`)
- [x] 7.7 Set velocity in `_physics_process()` based on direction (600 px/sec)
- [x] 7.8 Add 3-second lifetime via timer variable
- [x] 7.9 Implement `queue_free()` on lifetime expiry
- [x] 7.10 Implement collision handling (queue_free on hit)

**Status:** ✅ Complete

## 8. Bow System

- [x] 8.1 Add fire rate handling via `can_shoot` flag (0.5 sec)
- [x] 8.2 Add `shoot()` function to player script
- [x] 8.3 Check if can shoot before shooting
- [x] 8.4 Instantiate Arrow scene at player position
- [x] 8.5 Set arrow direction from `aim_direction`
- [x] 8.6 Start fire rate cooldown after shooting
- [x] 8.7 Connect shoot input (`"shoot"`) to `shoot()` function

**Status:** ✅ Complete

## 9. Test Level

- [x] 9.1 Create test level scene (`scenes/levels/main.tscn`)
- [x] 9.2 Add StaticBody2D walls for collision testing
- [x] 9.3 Set wall collision layer to `wall` (layer 4)
- [x] 9.4 Instantiate Player in level
- [x] 9.5 Position camera as child of level (not player)

**Status:** ✅ Complete

## 10. Verification

- [x] 10.1 Verify player moves at 200 px/sec in all 8 directions
- [x] 10.2 Verify diagonal movement is normalized
- [x] 10.3 Verify camera follows player smoothly
- [x] 10.4 Verify pixel-perfect rendering (no blur)
- [x] 10.5 Verify arrows fire at mouse direction
- [x] 10.6 Verify arrows travel at correct speed
- [x] 10.7 Verify 0.5 sec fire rate is enforced
- [x] 10.8 Verify arrows despawn after 3 seconds
- [x] 10.9 Verify arrows collide with walls
- [x] 10.10 Verify player collides with walls

**Status:** ✅ Complete (physics interpolation fix applied)

## 11. Unit Tests (Automated)

- [x] 11.1 Create test folder structure
- [x] 11.2 Create test_runner.gd and test_runner.tscn
- [x] 11.3 Create player movement tests
- [x] 11.4 Create arrow property tests
- [x] 11.5 Create physics layer tests
- [x] 11.6 Run tests and verify all pass ✅

**Status:** ✅ All 14 tests passed

**Files Created:**
- `tests/test_runner.gd` - Main test runner (14 tests)
- `tests/test_runner.tscn` - Test runner scene
- `tests/test_player.gd` - GUT-compatible player tests
- `tests/test_arrow.gd` - GUT-compatible arrow tests
- `tests/test_combat.gd` - GUT-compatible combat tests
- `tests/test_collision.gd` - GUT-compatible collision tests
- `tests/README.md` - Test documentation

**Run Tests:** `godot4 res://tests/test_runner.tscn`
