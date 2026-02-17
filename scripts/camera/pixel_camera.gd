## PixelCamera - Smooth follow camera with pixel snapping
## Follows a target with lerp-based smoothing and snaps to pixel boundaries
class_name PixelCamera
extends Camera2D

## The node to follow (usually the player)
@export var target: Node2D

## How fast the camera follows (higher = snappier)
@export var follow_speed: float = 5.0

## Enable/disable pixel snapping
@export var pixel_snap: bool = true


func _process(delta: float) -> void:
	if not target:
		return

	# Smooth follow using lerp
	var target_position = target.global_position
	global_position = global_position.lerp(target_position, follow_speed * delta)

	# Snap to pixel boundaries to prevent subpixel jitter
	if pixel_snap:
		global_position = global_position.round()
