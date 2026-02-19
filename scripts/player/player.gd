class_name Player
extends CharacterBody2D
## Player controller for Kasuari character with 4-directional animations.

# Stats (from GDD)
const MAX_HP: int = 100
const MOVE_SPEED: float = 200.0
const DASH_SPEED: float = 400.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.0
const DASH_IFRAMES: float = 0.15
const MELEE_DAMAGE: int = 35
const MELEE_RANGE: float = 64.0
const ARROW_DAMAGE: int = 25
const ARROW_SPEED: float = 600.0
const FIRE_RATE: float = 0.5
const RESPAWN_INVINCIBILITY: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var arrow_spawn: Marker2D = $ArrowSpawn
@onready var hitbox: Area2D = $Hitbox
@onready var melee_area: Area2D = $MeleeArea

var hp: int = MAX_HP
var is_dashing: bool = false
var can_dash: bool = true
var can_shoot: bool = true
var is_invincible: bool = false
var is_dead: bool = false

var aim_direction: Vector2 = Vector2.RIGHT

# Animation state
var _current_anim: String = "idle"
var _is_playing_action: bool = false


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	add_to_group("player")
	_connect_signals()
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_handle_movement(delta)
	_handle_aiming()
	_handle_actions(delta)
	move_and_slide()
	_update_animation()


func _handle_movement(_delta: float) -> void:
	if is_dashing:
		return

	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()

	velocity = input_dir * MOVE_SPEED


func _handle_aiming() -> void:
	aim_direction = (get_global_mouse_position() - global_position).normalized()
	# Note: flip_h is now handled in animation functions based on animation type


func _handle_actions(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

	if Input.is_action_just_pressed("melee"):
		_melee_attack()

	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		_dash()


func _shoot() -> void:
	can_shoot = false
	_play_action_animation("shoot")

	var arrow_scene := preload("res://scenes/player/arrow.tscn")
	var arrow := arrow_scene.instantiate()
	arrow.global_position = arrow_spawn.global_position
	arrow.direction = aim_direction
	arrow.damage = ARROW_DAMAGE
	arrow.speed = ARROW_SPEED
	get_tree().current_scene.add_child(arrow)

	await get_tree().create_timer(FIRE_RATE).timeout
	can_shoot = true


func _melee_attack() -> void:
	var bodies := melee_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(MELEE_DAMAGE)


func _dash() -> void:
	is_dashing = true
	can_dash = false
	is_invincible = true
	_play_action_animation("dash")

	var dash_direction := velocity.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = aim_direction

	velocity = dash_direction * DASH_SPEED

	await get_tree().create_timer(DASH_IFRAMES).timeout
	is_invincible = false

	await get_tree().create_timer(DASH_DURATION - DASH_IFRAMES).timeout
	is_dashing = false

	await get_tree().create_timer(DASH_COOLDOWN - DASH_DURATION).timeout
	can_dash = true


func take_damage(damage: int) -> void:
	if is_invincible or is_dead:
		return

	hp -= damage
	hp = maxi(hp, 0)

	EventBus.health_changed.emit(hp, MAX_HP)
	EventBus.player_damaged.emit(damage)

	_flash_red()
	_screen_shake()

	if hp <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_is_playing_action = true

	# Play death animation (no west sprite - use flip_h on east)
	var direction := _get_action_animation_direction("death")
	sprite.flip_h = aim_direction.x < 0 and abs(aim_direction.y) <= 0.5
	sprite.play("death_" + direction)
	EventBus.player_died.emit()

	# Wait for death animation, then respawn
	await sprite.animation_finished
	await get_tree().create_timer(1.0).timeout  # Brief pause before respawn
	respawn()


func respawn() -> void:
	# Reset position
	global_position = GameManager.player_spawn_position

	# Reset HP
	hp = MAX_HP
	EventBus.health_changed.emit(hp, MAX_HP)

	# Reset flags
	is_dead = false
	is_dashing = false
	can_dash = true
	can_shoot = true
	_is_playing_action = false

	# Post-respawn invincibility
	is_invincible = true
	_flash_white()
	await get_tree().create_timer(RESPAWN_INVINCIBILITY).timeout
	is_invincible = false

	# Emit signal
	EventBus.player_respawned.emit()


## Get animation direction suffix based on aim direction
## Note: idle/walk don't have west sprites - use flip_h on east
func _get_animation_direction() -> String:
	if aim_direction.y < -0.5:
		return "north"
	elif aim_direction.y > 0.5:
		return "south"
	else:
		return "east"  # west uses flip_h on east


## Get animation direction for actions (shoot, dash, death)
## Available sprites:
## - shoot: north, east, west, south (complete)
## - dash: south, east, north, west (complete)
## - death: south, east, north (no west - use flip_h on east)
func _get_action_animation_direction(action: String) -> String:
	if aim_direction.y < -0.5:
		return "north"
	elif aim_direction.y > 0.5:
		return "south"  # shoot and dash have south sprites
	elif action == "dash" and aim_direction.x < 0:
		return "west"  # dash has west sprites
	elif action == "shoot" and aim_direction.x < 0:
		return "west"  # shoot has west sprites
	else:
		return "east"  # west for death uses flip_h on east


## Update animation based on current state
func _update_animation() -> void:
	# Don't interrupt action animations
	if _is_playing_action or is_dead:
		return

	var direction := _get_animation_direction()
	var base_anim: String

	# Determine base animation (idle or walk)
	if velocity.length() > 10.0:
		base_anim = "walk"
	else:
		base_anim = "idle"

	var full_anim := base_anim + "_" + direction

	# Set flip_h for west direction (we don't have west sprites for idle/walk)
	sprite.flip_h = aim_direction.x < 0 and abs(aim_direction.y) <= 0.5

	# Only change if different
	if sprite.animation != full_anim:
		sprite.play(full_anim)
		_current_anim = base_anim


## Play a one-shot action animation
func _play_action_animation(action: String) -> void:
	_is_playing_action = true
	var direction := _get_action_animation_direction(action)

	# Set flip_h based on action and direction:
	# - shoot: has west sprites (no flip), no south (uses north, no flip)
	# - dash: has all 4 directions (no flip needed)
	# - death: no west sprite (use flip_h on east)
	match action:
		"shoot":
			sprite.flip_h = false  # shoot has west, no flip needed
		"dash":
			sprite.flip_h = false  # dash has all directions
		_:
			# death and others: flip for west
			sprite.flip_h = aim_direction.x < 0 and abs(aim_direction.y) <= 0.5

	sprite.play(action + "_" + direction)


## Called when action animation finishes
func _on_animation_finished() -> void:
	if _is_playing_action and not is_dead:
		_is_playing_action = false
		# Will update to idle/walk on next physics frame


func _flash_red() -> void:
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE


func _flash_white() -> void:
	# Quick flash effect for spawn/invincibility
	for i in range(3):
		sprite.modulate = Color(1.5, 1.5, 1.5)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout


func _screen_shake() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera:
		var tween := create_tween()
		tween.tween_property(camera, "offset", Vector2(4, 4), 0.05)
		tween.tween_property(camera, "offset", Vector2(-4, -4), 0.05)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)


func _connect_signals() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("get_contact_damage"):
		take_damage(body.get_contact_damage())
