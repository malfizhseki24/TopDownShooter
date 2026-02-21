## PixelCamera - Smooth follow camera with pixel snapping, trauma shake, and look-ahead
## Follows a target with lerp-based smoothing and snaps to pixel boundaries.
## Trauma system: noise-based shake with quadratic falloff (Squirrel Eiserloh method).
## Look-ahead: offsets camera toward player aim direction.
class_name PixelCamera
extends Camera2D

## The node to follow (usually the player)
@export var target: Node2D

## How fast the camera follows (higher = snappier)
@export var follow_speed: float = 5.0

## Enable/disable pixel snapping
@export var pixel_snap: bool = true

# --- Trauma shake ---
var _trauma: float = 0.0
const TRAUMA_DECAY: float = 3.0
const MAX_OFFSET_X: float = 8.0
const MAX_OFFSET_Y: float = 6.0
const MAX_ROTATION_DEG: float = 2.0

var _noise: FastNoiseLite
var _noise_y: float = 0.0  # Scrolling sample position for organic movement

# --- Look-ahead ---
var _aim_offset: Vector2 = Vector2.ZERO
const LOOK_AHEAD_DISTANCE: float = 40.0
const LOOK_AHEAD_WEIGHT: float = 4.0


func _ready() -> void:
	# Set up noise for organic shake
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 4.0
	_noise.seed = randi()

	# Connect to EventBus trauma signal
	EventBus.camera_trauma.connect(add_trauma)


func _process(delta: float) -> void:
	if not target:
		return

	# --- Look-ahead: lerp toward aim direction ---
	var aim_target := Vector2.ZERO
	if target.has_method("_handle_aiming") and "aim_direction" in target:
		aim_target = target.aim_direction * LOOK_AHEAD_DISTANCE
	_aim_offset = _aim_offset.lerp(aim_target, LOOK_AHEAD_WEIGHT * delta)

	# --- Smooth follow with look-ahead ---
	var target_position: Vector2 = target.global_position + _aim_offset
	global_position = global_position.lerp(target_position, follow_speed * delta)

	# --- Trauma shake ---
	if _trauma > 0.0:
		_trauma = maxf(_trauma - TRAUMA_DECAY * delta, 0.0)
		var shake_intensity: float = _trauma * _trauma  # Quadratic falloff

		# Sample noise at different offsets for x, y, rotation
		_noise_y += delta * 100.0
		var noise_x: float = _noise.get_noise_2d(0.0, _noise_y)
		var noise_y_val: float = _noise.get_noise_2d(100.0, _noise_y)
		var noise_rot: float = _noise.get_noise_2d(200.0, _noise_y)

		offset = Vector2(
			noise_x * MAX_OFFSET_X * shake_intensity,
			noise_y_val * MAX_OFFSET_Y * shake_intensity
		)
		rotation_degrees = noise_rot * MAX_ROTATION_DEG * shake_intensity
	else:
		offset = Vector2.ZERO
		rotation_degrees = 0.0

	# --- Pixel snap ---
	if pixel_snap:
		global_position = global_position.round()


## Add trauma to the camera (clamped to 1.0)
func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)
