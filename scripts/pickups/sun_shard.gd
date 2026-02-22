class_name SunShard
extends Area2D
## Energy pickup dropped by defeated enemies.
## Features physics bounce on spawn, idle bob animation, and magnetic pull to player.

## Emitted when collected by player
signal collected

# Physics constants
const SPAWN_UPWARD_VELOCITY_MIN: float = 80.0
const SPAWN_UPWARD_VELOCITY_MAX: float = 120.0
const SPAWN_HORIZONTAL_RANGE: float = 30.0
const BOUNCE_DAMPENING: float = 0.5
const FRICTION: float = 0.8
const GRAVITY: float = 400.0
const SETTLE_THRESHOLD: float = 10.0

# Magnetic pull constants
const MAGNETIC_RANGE: float = 80.0
const MAGNETIC_ACCELERATION: float = 400.0
const MAX_MAGNETIC_SPEED: float = 500.0

# Animation constants
const BOB_AMPLITUDE: float = 2.0
const BOB_PERIOD: float = 1.5
const COLLECT_TWEEN_DURATION: float = 0.2

# Timing
const AUTO_COLLECT_TIMEOUT: float = 5.0
const PHYSICS_DURATION: float = 0.3

# State
enum State { PHYSICS, IDLE, MAGNETIC, COLLECTING }
var current_state: State = State.PHYSICS

# Physics velocity (used during PHYSICS state)
var _velocity: Vector2 = Vector2.ZERO

# References
@onready var visual: Node2D = $Visual
@onready var glow: PointLight2D = $Glow

# Base scale (set in scene)
const BASE_SCALE: float = 0.25

# Player reference for magnetic pull
var _player: Node2D = null

# Time tracking
var _spawn_time: float = 0.0
var _physics_start_time: float = 0.0
var _bob_time: float = 0.0
var _base_y: float = 0.0

# SFX - subtle magical energy collection
var _sfx_collect: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")


func _ready() -> void:
	# Configure collision
	collision_layer = 0  # No layer
	collision_mask = 1   # Player layer only

	# Connect signals
	body_entered.connect(_on_body_entered)

	# Find player
	_find_player()

	# Initialize spawn time
	_spawn_time = Time.get_ticks_msec() / 1000.0
	_physics_start_time = _spawn_time

	# Initialize with random upward velocity
	_initialize_spawn_velocity()

	# Spawn particle burst
	VFXManager.spawn("shard_spawn_burst", global_position)


func _physics_process(delta: float) -> void:
	match current_state:
		State.PHYSICS:
			_update_physics(delta)
		State.IDLE:
			_update_idle(delta)
			_check_magnetic_range()
		State.MAGNETIC:
			_update_magnetic(delta)
		State.COLLECTING:
			pass  # Handled by tween

	# Check auto-collect timeout
	var elapsed := Time.get_ticks_msec() / 1000.0 - _spawn_time
	if elapsed >= AUTO_COLLECT_TIMEOUT and current_state != State.COLLECTING:
		_auto_collect()


func _initialize_spawn_velocity() -> void:
	_velocity = Vector2(
		randf_range(-SPAWN_HORIZONTAL_RANGE, SPAWN_HORIZONTAL_RANGE),
		randf_range(-SPAWN_UPWARD_VELOCITY_MAX, -SPAWN_UPWARD_VELOCITY_MIN)
	)


func _update_physics(delta: float) -> void:
	# Apply gravity
	_velocity.y += GRAVITY * delta

	# Apply velocity
	position += _velocity * delta

	# Check for ground collision (simple Y threshold - adjust as needed)
	# For now, just check time-based physics duration
	var physics_elapsed := Time.get_ticks_msec() / 1000.0 - _physics_start_time
	if physics_elapsed >= PHYSICS_DURATION and _velocity.y > 0:
		# Simulate bounce dampening
		_velocity.y *= -BOUNCE_DAMPENING
		_velocity.x *= FRICTION

		# Check if settled
		if _velocity.length() < SETTLE_THRESHOLD:
			_settle_to_idle()


func _settle_to_idle() -> void:
	current_state = State.IDLE
	_velocity = Vector2.ZERO
	_base_y = position.y
	_bob_time = 0.0


func _update_idle(delta: float) -> void:
	_bob_time += delta
	var bob_offset := sin(_bob_time * TAU / BOB_PERIOD) * BOB_AMPLITUDE
	position.y = _base_y + bob_offset


func _check_magnetic_range() -> void:
	if not _player:
		_find_player()
		return

	var dist := global_position.distance_to(_player.global_position)
	if dist <= MAGNETIC_RANGE:
		current_state = State.MAGNETIC


func _update_magnetic(delta: float) -> void:
	if not _player:
		_find_player()
		if not _player:
			current_state = State.IDLE
			return

	var to_player := (_player.global_position - global_position)
	var dist := to_player.length()

	if dist < 5.0:
		# Close enough to collect
		return

	# Accelerate towards player
	var direction := to_player.normalized()
	_velocity += direction * MAGNETIC_ACCELERATION * delta
	_velocity = _velocity.limit_length(MAX_MAGNETIC_SPEED)

	# Apply velocity
	position += _velocity * delta

	# Shrink and stretch visual in movement direction
	if _velocity.length() > 10.0:
		var stretch := _velocity.normalized()
		visual.scale = Vector2(BASE_SCALE * (1.0 + abs(stretch.x) * 0.3), BASE_SCALE * (1.0 + abs(stretch.y) * 0.3))
	else:
		visual.scale = Vector2(BASE_SCALE, BASE_SCALE)


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state != State.COLLECTING:
		_collect()


func _collect() -> void:
	current_state = State.COLLECTING

	# Emit signal
	EventBus.shard_collected.emit()
	collected.emit()

	# Play SFX (if available)
	if _sfx_collect:
		AudioManager.play_sfx(_sfx_collect, global_position)

	# Spawn collection particles
	VFXManager.spawn("shard_collect_burst", global_position)

	# Play collection tween (scale up then down)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(BASE_SCALE * 1.5, BASE_SCALE * 1.5), COLLECT_TWEEN_DURATION * 0.5)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, COLLECT_TWEEN_DURATION)
	tween.tween_callback(queue_free)


func _auto_collect() -> void:
	# Emit signal without animation
	EventBus.shard_collected.emit()
	queue_free()
