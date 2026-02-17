# Phase 1 Foundation - Unit Tests

## Running Tests

### Option 1: Test Runner Scene (Recommended)
1. Open Godot Editor
2. Open scene: `res://tests/test_runner.tscn`
3. Press F6 (Run Current Scene) or click Play
4. View results in Output console

### Option 2: Command Line
```bash
godot4 --headless --path /Users/gitsmha/godot/TopDownShooter res://tests/test_runner.tscn
```

### Option 3: With GUT Addon (Advanced)
If you install the [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) addon:
1. Install GUT from Asset Library
2. Run individual test files:
   - `test_player.gd` - Player movement and state tests
   - `test_arrow.gd` - Arrow projectile tests
   - `test_combat.gd` - Combat and fire rate tests
   - `test_collision.gd` - Physics collision tests

## Test Coverage

| Category | Tests |
|----------|-------|
| **Player Movement** | Speed (200 px/sec), Diagonal normalization, Stop on no input |
| **Player Aiming** | Direction calculation, Normalization |
| **Player State** | HP (100), Can shoot, Can dash |
| **Arrow Properties** | Layer (3), Mask (enemy+wall), Damage (25), Speed (600) |
| **Physics Layers** | Player layer (1), Player mask (wall) |

## Expected Output

```
========================================
PHASE 1 FOUNDATION - UNIT TESTS
========================================

  ✅ PASS: Player: Move speed is 200 px/sec
  ✅ PASS: Player: Diagonal movement normalized
  ✅ PASS: Player: Stops on no input
  ...

========================================
RESULTS: 14/14 tests passed
========================================

✅ All tests passed!
```

## Adding New Tests

1. Add test function to `test_runner.gd`:
```gdscript
func _test_new_feature() -> bool:
    # Test logic
    return true
```

2. Register in `_run_all_tests()`:
```gdscript
await _run_test("New: Feature description", _test_new_feature)
```
