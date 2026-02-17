## Pixel-perfect camera that snaps to pixel grid.
## Attach to a Camera2D node.
class_name PixelCamera2D
extends Camera2D

## Target to follow (set in _ready or externally)
@export var target: Node2D

## Smoothing speed (0 = instant, higher = smoother)
@export var smoothing_speed: float = 5.0

## Pixel size for snapping (should match your art scale)
@export var pixel_size: int = 4

## Enable/disable pixel snapping
@export var snap_enabled: bool = true


func _ready() -> void:
	# Disable built-in smoothing, we'll do our own
	position_smoothing_enabled = false


func _physics_process(delta: float) -> void:
	if target == null:
		return

	# Smooth follow
	var target_position := target.global_position
	global_position = global_position.lerp(target_position, smoothing_speed * delta)

	# Snap to pixel grid
	if snap_enabled:
		global_position = global_position.snapped(Vector2(pixel_size, pixel_size))
