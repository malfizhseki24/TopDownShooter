class_name Player
extends CharacterBody2D
## Player controller for Kasuari character.

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

@onready var sprite: Sprite2D = $Sprite2D
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


func _ready() -> void:
	# Enable physics interpolation for smooth visual rendering
	# This allows sub-pixel positions while physics remains discrete
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	add_to_group("player")
	_connect_signals()


func _physics_process(delta: float) -> void:
	if is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_handle_movement(delta)
	_handle_aiming()
	_handle_actions(delta)
	move_and_slide()


func _handle_movement(_delta: float) -> void:
	if is_dashing:
		return

	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()

	velocity = input_dir * MOVE_SPEED


func _handle_aiming() -> void:
	# Aim toward mouse position
	aim_direction = (get_global_mouse_position() - global_position).normalized()

	# Flip sprite based on aim direction
	if aim_direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _handle_actions(_delta: float) -> void:
	# Shoot
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

	# Melee
	if Input.is_action_just_pressed("melee"):
		_melee_attack()

	# Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		_dash()


func _shoot() -> void:
	can_shoot = false

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
	# Check for enemies in melee range
	var bodies := melee_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(MELEE_DAMAGE)


func _dash() -> void:
	is_dashing = true
	can_dash = false
	is_invincible = true

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

	# Hit feedback
	_flash_red()
	_screen_shake()

	if hp <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	EventBus.player_died.emit()
	# TODO: Play death animation


func _flash_red() -> void:
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE


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
