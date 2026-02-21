extends Node
## HitstopManager: Global freeze frame and slow-motion effects for combat impact.
## Provides freeze(duration) and slow_mo(scale, duration) with no-stack guard.

var _is_frozen: bool = false
var _is_slow_mo: bool = false

# SFX
var _sfx_hitstop_thump: AudioStream = preload("res://assets/audio/sfx/hitstop_thump.wav")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.room_cleared.connect(_on_room_cleared)


## Freeze the game for a brief duration (time_scale = 0).
## Uses a timer that processes during time_scale=0 (4th arg = true).
## Ignores calls if a freeze is already active (no stacking).
func freeze(duration: float) -> void:
	if _is_frozen:
		return
	_is_frozen = true
	AudioManager.play_sfx_global(_sfx_hitstop_thump, -6.0)
	Engine.time_scale = 0.0

	# Timer processes during pause (process_always = true)
	await get_tree().create_timer(duration, true, false, true).timeout

	if _is_frozen:
		Engine.time_scale = 1.0
		_is_frozen = false


## Slow-motion effect: sets time_scale to a low value, then lerps back to 1.0.
## Ignores calls if a freeze or slow-mo is already active.
func slow_mo(scale: float, duration: float) -> void:
	if _is_frozen or _is_slow_mo:
		return
	_is_slow_mo = true
	Engine.time_scale = scale

	# Wait for slow-mo duration (real time)
	await get_tree().create_timer(duration, true, false, true).timeout

	if _is_slow_mo:
		# Lerp back to 1.0 over 0.1 seconds (real time)
		var restore_tween := create_tween()
		restore_tween.set_speed_scale(1.0 / maxf(Engine.time_scale, 0.01))
		restore_tween.tween_method(_set_time_scale, Engine.time_scale, 1.0, 0.1)
		await restore_tween.finished
		_is_slow_mo = false


func _set_time_scale(value: float) -> void:
	Engine.time_scale = value


## Kill slow-mo on last enemy killed in room (skip boss room)
func _on_room_cleared(_room_index: int) -> void:
	# Skip slow-mo for boss room (final room)
	if GameManager.is_final_room():
		return
	slow_mo(0.15, 0.12)
	EventBus.camera_trauma.emit(0.25)
