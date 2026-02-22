extends CanvasLayer
## Main HUD controller — connects to EventBus signals and delegates to child elements.
## Never polls or references game nodes directly.

# Child node references
@onready var player_health_bar: Control = $LeftPanel/HealthRow/PlayerHealthBar
@onready var bar_fill: ColorRect = $LeftPanel/HealthRow/PlayerHealthBar/BarFill
@onready var damage_trail: ColorRect = $LeftPanel/HealthRow/PlayerHealthBar/DamageTrail
@onready var hp_text: Label = $LeftPanel/HPText
@onready var dash_cooldown: Control = $LeftPanel/DashCooldown
@onready var dash_bar_fill: ColorRect = $LeftPanel/DashCooldown/DashBarFill
@onready var energy_meter: Control = $LeftPanel/HealthRow/EnergyMeter
@onready var room_progress: HBoxContainer = $RoomProgress
@onready var fade_rect: ColorRect = $FadeRect

# Health bar state
const LOW_HP_THRESHOLD: int = 25
var _current_hp: int = 100
var _max_hp: int = 100
var _is_low_hp: bool = false
var _hp_text_tween: Tween = null
var _trail_tween: Tween = null
var _heal_tween: Tween = null

# Dash bar state
var _dash_tween: Tween = null
var _dash_fade_tween: Tween = null

# Room progress state
var _room_dots: Array[ColorRect] = []
const HEAL_ROOMS: Array[int] = [2, 5]  # 0-indexed rooms 3 and 6
const BOSS_ROOM: int = 6  # 0-indexed room 7

# Damage number scene
var _damage_number_scene: PackedScene = null
var _damage_number_layer: Node2D = null

# Colors
const COLOR_HEALTH_FILL := Color("#e94560")
const COLOR_HEALTH_LOW := Color("#ff2040")
const COLOR_HEALTH_TRAIL := Color("#f1f1f1")
const COLOR_HEAL_TINT := Color("#70c1b3")
const COLOR_DASH_CHARGE := Color("#16213e")
const COLOR_DASH_READY := Color("#70c1b3")
const COLOR_DOT_COMPLETED := Color("#f1f1f1")
const COLOR_DOT_CURRENT := Color("#e94560")
const COLOR_DOT_FUTURE := Color(0.945, 0.945, 0.945, 0.3)
const COLOR_DOT_HEAL := Color("#70c1b3")
const COLOR_DOT_BOSS := Color("#ee4540")

# Damage number colors
const COLOR_DMG_ARROW := Color("#f1f1f1")
const COLOR_DMG_MELEE := Color("#f0e68c")
const COLOR_DMG_SPECIAL := Color("#ffdd44")  # Gold for Sun-Piercer
const COLOR_DMG_PLAYER_HURT := Color("#e94560")
const COLOR_DMG_BOSS_HURT := Color("#ff2040")
const COLOR_DMG_HEAL := Color("#70c1b3")


func _ready() -> void:
	_connect_signals()
	_create_room_dots()
	_load_damage_number_scene()

	# Initialize dash bar as invisible
	dash_cooldown.modulate.a = 0.0

	# Initialize HP text as invisible
	hp_text.modulate.a = 0.0

	# Set up pivot for scale-based fill animations
	bar_fill.pivot_offset = Vector2(0, 0)
	damage_trail.pivot_offset = Vector2(0, 0)
	dash_bar_fill.pivot_offset = Vector2(0, 0)


func _process(_delta: float) -> void:
	# Low HP pulse effect
	if _is_low_hp:
		var pulse := 0.6 + 0.4 * sin(Time.get_ticks_msec() / 1000.0 * 6.0)
		bar_fill.modulate.a = pulse


func _connect_signals() -> void:
	# Health
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.player_healed.connect(_on_player_healed)

	# Dash
	EventBus.player_dash_started.connect(_on_dash_started)
	EventBus.player_dash_ready.connect(_on_dash_ready)

	# Room progress
	EventBus.room_loaded.connect(_on_room_loaded)

	# Damage numbers
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.damage_taken.connect(_on_damage_taken)


# --- Health Bar ---

func _on_health_changed(current: int, maximum: int) -> void:
	var prev_hp := _current_hp
	_current_hp = current
	_max_hp = maximum

	var fill_ratio := float(current) / float(maximum)

	# Instant fill update using scale (anchored layout)
	bar_fill.scale.x = fill_ratio

	# Low HP state
	_is_low_hp = current <= LOW_HP_THRESHOLD
	if _is_low_hp:
		bar_fill.color = COLOR_HEALTH_LOW
	else:
		bar_fill.color = COLOR_HEALTH_FILL
		bar_fill.modulate.a = 1.0

	# Damage trail (only on damage, not heal)
	if current < prev_hp:
		_show_damage_trail(fill_ratio)

	# Show HP text briefly
	_show_hp_text(current, maximum)


func _show_damage_trail(target_ratio: float) -> void:
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_property(damage_trail, "scale:x", target_ratio, 0.4)


func _on_player_healed(_amount: int) -> void:
	# Green tint flash on heal
	if _heal_tween:
		_heal_tween.kill()
	bar_fill.color = COLOR_HEAL_TINT
	_heal_tween = create_tween()
	_heal_tween.tween_property(bar_fill, "color", COLOR_HEALTH_FILL, 0.2)

	# Also update the damage trail to match new HP (no trailing on heal)
	var fill_ratio := float(_current_hp) / float(_max_hp)
	damage_trail.scale.x = fill_ratio


func _show_hp_text(current: int, maximum: int) -> void:
	hp_text.text = "%d/%d" % [current, maximum]
	if _hp_text_tween:
		_hp_text_tween.kill()
	_hp_text_tween = create_tween()
	_hp_text_tween.tween_property(hp_text, "modulate:a", 1.0, 0.15)
	_hp_text_tween.tween_interval(1.2)
	_hp_text_tween.tween_property(hp_text, "modulate:a", 0.0, 0.15)


# --- Dash Cooldown ---

func _on_dash_started(cooldown_duration: float) -> void:
	# Kill any existing tweens
	if _dash_tween:
		_dash_tween.kill()
	if _dash_fade_tween:
		_dash_fade_tween.kill()

	# Fade in the bar
	dash_cooldown.modulate.a = 0.6

	# Reset fill scale to 0 and tween to full
	dash_bar_fill.scale.x = 0.0
	_dash_tween = create_tween()
	_dash_tween.tween_property(dash_bar_fill, "scale:x", 1.0, cooldown_duration)


func _on_dash_ready() -> void:
	if _dash_tween:
		_dash_tween.kill()

	# Flash cyan
	dash_bar_fill.color = COLOR_DASH_READY
	dash_bar_fill.scale.x = 1.0

	if _dash_fade_tween:
		_dash_fade_tween.kill()
	_dash_fade_tween = create_tween()
	# Brief cyan flash then fade out
	_dash_fade_tween.tween_interval(0.15)
	_dash_fade_tween.tween_property(dash_cooldown, "modulate:a", 0.0, 0.3)
	_dash_fade_tween.tween_callback(func():
		dash_bar_fill.color = COLOR_DASH_CHARGE
		dash_bar_fill.scale.x = 0.0
	)


# --- Room Progress ---

func _create_room_dots() -> void:
	# Clear existing children
	for child in room_progress.get_children():
		child.queue_free()
	_room_dots.clear()

	for i in range(7):
		var dot := ColorRect.new()
		var dot_size := 7.0 if i == BOSS_ROOM else 5.0
		dot.custom_minimum_size = Vector2(dot_size, dot_size)
		dot.size = Vector2(dot_size, dot_size)
		dot.color = COLOR_DOT_FUTURE
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		room_progress.add_child(dot)
		_room_dots.append(dot)


func _on_room_loaded(room_index: int) -> void:
	_update_room_dots(room_index)
	_pulse_current_dot(room_index)


func _update_room_dots(current_room: int) -> void:
	for i in range(_room_dots.size()):
		var dot := _room_dots[i]
		if i < current_room:
			# Completed
			if i in HEAL_ROOMS:
				dot.color = COLOR_DOT_HEAL
			else:
				dot.color = COLOR_DOT_COMPLETED
		elif i == current_room:
			# Current room
			if i == BOSS_ROOM:
				dot.color = COLOR_DOT_BOSS
			else:
				dot.color = COLOR_DOT_CURRENT
		else:
			# Future
			dot.color = COLOR_DOT_FUTURE


func _pulse_current_dot(room_index: int) -> void:
	if room_index < 0 or room_index >= _room_dots.size():
		return
	var dot := _room_dots[room_index]
	var tween := create_tween()
	tween.tween_property(dot, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(dot, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)


# --- Damage Numbers ---

func _load_damage_number_scene() -> void:
	var path := "res://scenes/ui/damage_number.tscn"
	if ResourceLoader.exists(path):
		_damage_number_scene = load(path)


func set_damage_number_layer(layer_node: Node2D) -> void:
	_damage_number_layer = layer_node


func _on_damage_dealt(pos: Vector2, amount: int, type: StringName) -> void:
	match type:
		&"arrow_hit":
			_spawn_damage_number(pos, amount, COLOR_DMG_ARROW, 6, false, true)
		&"melee_hit":
			_spawn_damage_number(pos, amount, COLOR_DMG_MELEE, 7, false, true)
		&"special_attack":
			_spawn_damage_number(pos, amount, COLOR_DMG_SPECIAL, 9, false, true)
		&"heal":
			_spawn_damage_number(pos, amount, COLOR_DMG_HEAL, 8, true, true)


func _on_damage_taken(pos: Vector2, amount: int, type: StringName) -> void:
	match type:
		&"player_hurt":
			_spawn_damage_number(pos, amount, COLOR_DMG_PLAYER_HURT, 7, false, false)
		&"boss_hurt_player":
			_spawn_damage_number(pos, amount, COLOR_DMG_BOSS_HURT, 8, false, false)


func _spawn_damage_number(pos: Vector2, amount: int, color: Color, font_size: int, is_heal: bool, float_up: bool) -> void:
	if not _damage_number_scene or not _damage_number_layer:
		return
	var instance := _damage_number_scene.instantiate() as Node2D
	_damage_number_layer.add_child(instance)
	instance.global_position = pos
	instance.setup(amount, color, font_size, is_heal, float_up)


# --- Fade Transitions ---

func fade_to_black() -> void:
	fade_rect.color.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	await tween.finished


func fade_from_black() -> void:
	fade_rect.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.3)
	await tween.finished
