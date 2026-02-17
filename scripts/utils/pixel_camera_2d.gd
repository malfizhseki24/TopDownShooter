## Smooth follow camera for modern top-down shooters.
## Attach to a Camera2D node.
## Uses Godot's built-in smoothing with physics interpolation for sub-pixel precision.
## Pixel art visuals are preserved via Nearest texture filtering, not position snapping.
class_name SmoothCamera2D
extends Camera2D

## Target to follow (set in _ready or externally)
@export var target: Node2D

## Smoothing speed (0 = instant, higher = smoother)
## Range: 1.0 (very smooth) to 20.0 (snappy)
@export var smoothing_speed: float = 8.0


func _ready() -> void:
	# Enable physics interpolation for smooth camera rendering
	# This interpolates camera position between physics ticks
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

	# Enable built-in smoothing - this is the Godot 4 best practice
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed

	# CRITICAL: Use physics callback to sync with CharacterBody2D movement
	# This ensures camera updates align with physics ticks when following
	# a physics-driven target (like CharacterBody2D using move_and_slide)
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS


func _physics_process(_delta: float) -> void:
	if target == null:
		return

	# Follow target - Godot's built-in smoothing handles interpolation
	# Physics interpolation (project setting) handles sub-pixel rendering
	global_position = target.global_position
