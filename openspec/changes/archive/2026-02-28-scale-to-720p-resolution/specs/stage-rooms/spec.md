# Spec Delta: stage-rooms

## MODIFIED Requirements

### Requirement: Room Dimensions

Rooms MUST be standardized to 20 tiles wide, 11-14 tiles tall.

**Change:** Rooms expanded from 15-19 tiles wide to standardized 20 tiles wide.

#### Scenario: Room blueprint sizes in room_blueprints.gd
```
Room 1 (Tutorial): 20x12 tiles
Room 2 (Combat): 20x12 tiles
Room 3 (Heal): 20x11 tiles
Room 4 (Combat): 20x14 tiles
Room 5 (Combat): 20x14 tiles
Room 6 (Heal): 20x11 tiles
Room 7 (Boss): 20x14 tiles
```

### Requirement: World Position Scaling

Hardcoded positions MUST use 1280x720 coordinate space.

**Change:** All hardcoded positions scaled from 480x270 to 1280x720 coordinate space.

#### Scenario: Player spawn default position in room_manager.gd
```gdscript
# Before: Vector2(240, 400) in 480x270 space
# After: Vector2(640, 600) in 1280x720 space
var _player_spawn: Vector2 = Vector2(640, 600)
```

#### Scenario: Vegetation spawn center in room_manager.gd
```gdscript
# Before: Vector2(240, 200) + offset
# After: Vector2(640, 400) + offset
var pos := Vector2(640, 400) + Vector2(cos(angle), sin(angle)) * dist
```

### Requirement: Vegetation Scale

Trees MUST spawn at scale 0.3, fern bushes MUST spawn at scale 0.08.

**Change:** Vegetation scales adjusted for 64px assets.

#### Scenario: Vegetation scaling in room_manager.gd
```gdscript
# Trees
obj.scale = Vector2(0.3, 0.3) * randf_range(0.8, 1.2)
# Fern bushes (smaller)
obj.scale = Vector2(0.08, 0.08) * randf_range(0.8, 1.2)
```

### Requirement: Destructible Scale

Destructible objects MUST spawn at scale 0.4.

**Change:** Destructible scale adjusted for 64px assets.

#### Scenario: Destructible scaling in scene files
```gdscript
# In destructible scene files, base scale assumes 64px sprites
obj.scale = Vector2(0.4, 0.4)
```
