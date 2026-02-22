class_name EnergyMeter
extends Control
## HUD element displaying accumulated energy from collected Sun Shards.
## Shows fill progress and "ready" state when full.

# Constants
const MAX_ENERGY: int = 10
const METER_SIZE: float = 24.0
const ICON_SIZE: float = 12.0
const FILL_TWEEN_DURATION: float = 0.15
const READY_PULSE_PERIOD: float = 0.5
const FLASH_DURATION: float = 0.1
const DRAIN_DURATION: float = 0.3

# Colors
const COLOR_EMPTY: Color = Color(1.0, 0.87, 0.27, 1.0)  # #ffdd44
const COLOR_FULL: Color = Color(1.0, 0.53, 0.0, 1.0)    # #ff8800
const COLOR_ICON_DIM: Color = Color(0.945, 0.945, 0.945, 0.7)  # #f1f1f1 at 70%
const COLOR_ICON_BRIGHT: Color = Color(0.945, 0.945, 0.945, 1.0)  # #f1f1f1 at 100%
const COLOR_GLOW: Color = Color(1.0, 0.67, 0.0, 1.0)    # #ffaa00
const COLOR_FLASH: Color = Color(1.0, 1.0, 1.0, 1.0)    # White

# State
var current_energy: int = 0
var is_ready: bool = false
var _current_fill: float = 0.0

# Node references
@onready var background: ColorRect = $BackgroundCircle
@onready var fill: ColorRect = $FillCircle
@onready var icon: ColorRect = $ShardIcon
@onready var ready_glow: ColorRect = $ReadyGlow

# Tween references
var _fill_tween: Tween = null
var _glow_tween: Tween = null

# SFX
var _sfx_ready: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")


func _ready() -> void:
	# Connect to EventBus signals
	EventBus.shard_collected.connect(_on_shard_collected)
	EventBus.energy_meter_changed.connect(_on_energy_meter_changed)
	EventBus.energy_meter_full.connect(_on_energy_meter_full)
	EventBus.energy_meter_emptied.connect(_on_energy_meter_emptied)

	# Initialize visual state
	_update_fill(0.0)
	_hide_ready_glow()


func _process(_delta: float) -> void:
	# Handle ready glow pulsing
	if is_ready and ready_glow.visible:
		var pulse := 0.3 + 0.5 * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU / READY_PULSE_PERIOD))
		ready_glow.modulate.a = pulse


func _on_shard_collected() -> void:
	# This is handled by player.gd which emits energy_meter_changed
	pass


func _on_energy_meter_changed(current: int, maximum: int) -> void:
	current_energy = current

	# Calculate fill percentage
	var fill_percent := float(current) / float(maximum)

	# Animate fill change
	_animate_fill(fill_percent)

	# Update icon brightness
	_update_icon_brightness(fill_percent)


func _on_energy_meter_full() -> void:
	is_ready = true
	_show_ready_glow()

	# Play ready SFX (if available)
	if _sfx_ready:
		AudioManager.play_sfx(_sfx_ready)


func _on_energy_meter_emptied() -> void:
	is_ready = false

	# Flash white then drain
	_flash_and_drain()


func _animate_fill(target_percent: float) -> void:
	# Kill existing tween
	if _fill_tween:
		_fill_tween.kill()

	# Create fill tween
	_fill_tween = create_tween()
	_fill_tween.tween_method(_update_fill, _current_fill, target_percent, FILL_TWEEN_DURATION)


func _update_fill(percent: float) -> void:
	_current_fill = percent

	# Update fill size (scale from left-bottom corner)
	if fill:
		fill.scale = Vector2(percent, 1.0)
		fill.pivot_offset = Vector2(0, METER_SIZE)  # Pivot at bottom-left

	# Interpolate color
	var color := COLOR_EMPTY.lerp(COLOR_FULL, percent)
	fill.color = color


func _update_icon_brightness(fill_percent: float) -> void:
	if not icon:
		return

	if fill_percent >= 1.0:
		icon.color = COLOR_ICON_BRIGHT
	else:
		icon.color = COLOR_ICON_DIM


func _show_ready_glow() -> void:
	if ready_glow:
		ready_glow.visible = true
		ready_glow.color = COLOR_GLOW
		ready_glow.modulate.a = 0.5


func _hide_ready_glow() -> void:
	if ready_glow:
		ready_glow.visible = false


func _flash_and_drain() -> void:
	# Hide glow
	if _glow_tween:
		_glow_tween.kill()
	_glow_tween = create_tween()
	_glow_tween.tween_property(ready_glow, "modulate:a", 0.0, 0.2)
	_glow_tween.tween_callback(_hide_ready_glow)

	# Flash white
	if fill:
		var original_color: Color = COLOR_EMPTY.lerp(COLOR_FULL, _current_fill)
		fill.color = COLOR_FLASH

		# Create drain tween
		if _fill_tween:
			_fill_tween.kill()
		_fill_tween = create_tween()
		_fill_tween.tween_interval(FLASH_DURATION)
		_fill_tween.tween_property(fill, "color", original_color, 0.1)
		_fill_tween.tween_method(_update_fill, 1.0, 0.0, DRAIN_DURATION)

	# Reset icon
	if icon:
		icon.color = COLOR_ICON_DIM
