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
const MAX_ENERGY: int = 10
const SUN_PIERCER_DAMAGE: int = 80
const SUN_PIERCER_SPEED: float = 400.0
const SUN_PIERCER_WINDUP: float = 0.25

# Forgiveness constants (tunable)
const DAMAGE_IFRAME_DURATION: float = 0.8
const IFRAME_FLICKER_INTERVAL: float = 0.08
const INPUT_BUFFER_WINDOW: float = 0.15
const DASH_FORGIVENESS_WINDOW: float = 0.12
const AIM_CONE_HALF_ANGLE: float = deg_to_rad(12.0)
const AIM_MAX_CORRECTION: float = deg_to_rad(8.0)
const AIM_ASSIST_RANGE: float = 300.0

# Hit flash constants
const HIT_FLASH_RED_DURATION: float = 0.12

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var arrow_spawn: Marker2D = $ArrowSpawn
@onready var hurtbox_area: Area2D = $HurtboxArea
@onready var melee_area: Area2D = $MeleeArea
@onready var iframe_timer: Timer = $IFrameTimer
@onready var flicker_timer: Timer = $FlickerTimer

var hp: int = MAX_HP
var is_dashing: bool = false
var can_dash: bool = true
var can_shoot: bool = true
var is_invincible: bool = false
var is_dead: bool = false

# Combat Economy state
var current_energy: int = 0
var is_energy_full: bool = false
var is_windup: bool = false

var aim_direction: Vector2 = Vector2.RIGHT

# Animation state
var _current_anim: String = "idle"
var _is_playing_action: bool = false

# Input buffer state
var _buffered_action: StringName = &""
var _buffer_timestamp: float = 0.0

# Dash forgiveness state
var _last_damage_time: float = 0.0

# Flash tween reference (to kill previous tweens)
var _flash_tween: Tween = null

# Dash afterimage
var _afterimage_scene: PackedScene = preload("res://scenes/vfx/dash_afterimage.tscn")

# Knockback impulse velocity (decays via friction)
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_FRICTION: float = 600.0

# SFX
var _sfx_bow_shoot: AudioStream = preload("res://assets/audio/sfx/bow_shoot.wav")
var _sfx_dash_whoosh: AudioStream = preload("res://assets/audio/sfx/dash_whoosh.wav")
var _sfx_player_hurt: AudioStream = preload("res://assets/audio/sfx/player_hurt.wav")
var _sfx_player_death: AudioStream = preload("res://assets/audio/sfx/player_death.wav")
# SFX for Sun-Piercer
var _sfx_sun_piercer_windup: AudioStream = preload("res://assets/audio/sfx/boss_charge.wav")
var _sfx_sun_piercer_fire: AudioStream = preload("res://assets/audio/sfx/dash_whoosh.wav")

# Scene references
var sun_piercer_scene: PackedScene = preload("res://scenes/player/sun_piercer.tscn")


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

	# Layer 2: Entities (above objects, below VFX)
	z_index = 2

	add_to_group("player")
	_connect_signals()
	sprite.animation_finished.connect(_on_animation_finished)

	# Connect i-frame timers
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)

	# Connect to shard collection signal
	EventBus.shard_collected.connect(_on_shard_collected)

	# Initialize energy meter display
	EventBus.energy_meter_changed.emit(current_energy, MAX_ENERGY)


func _physics_process(delta: float) -> void:
	if is_dead or GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Decay knockback velocity via friction
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	else:
		knockback_velocity = Vector2.ZERO

	_handle_movement(delta)
	_handle_aiming()
	_handle_actions(delta)
	velocity += knockback_velocity
	move_and_slide()
	velocity -= knockback_velocity
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
	var current_time := Time.get_ticks_msec() / 1000.0

	# Don't allow actions during windup
	if is_windup:
		return

	# Try consuming buffered actions first
	if _consume_buffered_action(&"shoot") and can_shoot:
		_shoot()
	elif _consume_buffered_action(&"dash") and can_dash and not is_dashing:
		_dash()
	elif _consume_buffered_action(&"melee"):
		_melee_attack()

	# Normal input checks
	if Input.is_action_pressed("shoot"):
		if can_shoot:
			_shoot()
		else:
			_buffer_action(&"shoot")

	if Input.is_action_just_pressed("melee"):
		_melee_attack()

	if Input.is_action_just_pressed("dash"):
		# Dash forgiveness: allow dash within window after taking damage
		var within_forgiveness := (current_time - _last_damage_time) <= DASH_FORGIVENESS_WINDOW
		if can_dash and not is_dashing:
			_dash()
		elif within_forgiveness and not is_dashing:
			# Forgiveness window bypasses normal blocking
			_dash()
		else:
			_buffer_action(&"dash")

	# Special attack (Sun-Piercer)
	if Input.is_action_just_pressed("special_attack") and is_energy_full and not is_dashing:
		_fire_sun_piercer()


func _shoot() -> void:
	can_shoot = false
	_play_action_animation("shoot")
	AudioManager.play_sfx(_sfx_bow_shoot, global_position)

	var arrow_scene := preload("res://scenes/player/arrow.tscn")
	var arrow := arrow_scene.instantiate()
	arrow.global_position = arrow_spawn.global_position
	arrow.direction = _apply_aim_assist(aim_direction)
	arrow.damage = ARROW_DAMAGE
	arrow.speed = ARROW_SPEED
	get_tree().current_scene.add_child(arrow)

	await get_tree().create_timer(FIRE_RATE).timeout
	can_shoot = true


func _melee_attack() -> void:
	var bodies := melee_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(MELEE_DAMAGE, &"melee_hit")
		elif body.is_in_group("destructible") and body.has_method("take_damage"):
			body.take_damage(MELEE_DAMAGE)


func _dash() -> void:
	is_dashing = true
	can_dash = false
	is_invincible = true  # Invincible for entire dash
	_play_action_animation("dash")
	AudioManager.play_sfx(_sfx_dash_whoosh, global_position)

	var dash_direction := velocity.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = aim_direction

	velocity = dash_direction * DASH_SPEED

	# Emit dash started signal for HUD
	EventBus.player_dash_started.emit(DASH_COOLDOWN)

	# Spawn dash trail effect (returns GPUParticles2D)
	var dash_vfx: GPUParticles2D = VFXManager.spawn_attached("dash_trail", self)

	# Spawn afterimages during dash (4 total, every 0.05s)
	_spawn_dash_afterimages()

	# Wait for dash duration
	await get_tree().create_timer(DASH_DURATION).timeout

	# Dash finished - handle invincibility overlap with damage i-frames
	is_dashing = false
	if not iframe_timer.is_stopped():
		# Damage i-frames still active — keep invincible
		pass
	else:
		is_invincible = false

	# Dash landing squash effect
	_squash_stretch(Vector2(1.2, 0.8), 0.08)

	# Stop and remove dash trail (free the VFX, not the player!)
	if dash_vfx:
		dash_vfx.emitting = false
		dash_vfx.queue_free()

	# Wait for remaining cooldown
	await get_tree().create_timer(DASH_COOLDOWN - DASH_DURATION).timeout
	can_dash = true
	EventBus.player_dash_ready.emit()


func _spawn_dash_afterimages() -> void:
	for i in range(4):
		if not is_dashing:
			break
		var afterimage := _afterimage_scene.instantiate() as Sprite2D
		afterimage.global_position = global_position
		# Get current frame texture from AnimatedSprite2D
		var frame_tex: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		afterimage.setup(frame_tex, sprite.flip_h, sprite.scale)
		get_tree().current_scene.add_child(afterimage)
		await get_tree().create_timer(0.05).timeout


func take_damage(damage: int, type: StringName = &"player_hurt") -> void:
	if is_invincible or is_dead:
		return

	hp -= damage
	hp = maxi(hp, 0)

	# Record damage time for dash forgiveness
	_last_damage_time = Time.get_ticks_msec() / 1000.0

	EventBus.health_changed.emit(hp, MAX_HP)
	EventBus.player_damaged.emit(damage)
	EventBus.damage_taken.emit(global_position, damage, type)

	_flash_red()
	AudioManager.play_sfx(_sfx_player_hurt, global_position)
	EventBus.camera_trauma.emit(0.35)

	# Knockback — away from nearest enemy/boss
	var is_boss_damage := type == &"boss_hurt_player"
	var kb_dist := 100.0 if is_boss_damage else 60.0
	_apply_knockback(kb_dist)

	# Screen flash — red overlay, stronger from boss
	if is_boss_damage:
		EventBus.screen_flash_requested.emit(Color(0.93, 0.27, 0.25), 0.35, 0.2)
	else:
		EventBus.screen_flash_requested.emit(Color(0.93, 0.27, 0.25), 0.20, 0.15)

	# Hitstop — 0.06s regular, 0.08s from boss
	HitstopManager.freeze(0.08 if is_boss_damage else 0.06)

	if hp <= 0:
		die()
		return

	# Start damage i-frames (only if alive)
	_start_damage_iframes()


func _start_damage_iframes() -> void:
	is_invincible = true
	iframe_timer.start(DAMAGE_IFRAME_DURATION)
	flicker_timer.start(IFRAME_FLICKER_INTERVAL)


func _on_iframe_timer_timeout() -> void:
	# End damage i-frames
	if not is_dashing:
		is_invincible = false
	flicker_timer.stop()
	sprite.visible = true


func _on_flicker_timer_timeout() -> void:
	sprite.visible = not sprite.visible


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_is_playing_action = true

	# Stop any active i-frames
	iframe_timer.stop()
	flicker_timer.stop()
	sprite.visible = true
	is_invincible = false

	# Clear input buffer
	_buffered_action = &""

	AudioManager.play_sfx(_sfx_player_death, global_position)

	# Play death animation (no west sprite - use flip_h on east)
	var direction := _get_action_animation_direction("death")
	sprite.flip_h = aim_direction.x < 0 and abs(aim_direction.y) <= 0.5
	sprite.play("death_" + direction)
	EventBus.player_died.emit()

	# Stay dead - game.gd will trigger game over screen


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

	# Clear buffer
	_buffered_action = &""

	# Post-respawn invincibility
	is_invincible = true
	_flash_white()
	await get_tree().create_timer(RESPAWN_INVINCIBILITY).timeout
	is_invincible = false

	# Emit signal
	EventBus.player_respawned.emit()


# --- Input Buffering ---

func _buffer_action(action: StringName) -> void:
	_buffered_action = action
	_buffer_timestamp = Time.get_ticks_msec() / 1000.0


func _consume_buffered_action(action: StringName) -> bool:
	if _buffered_action != action:
		return false
	var current_time := Time.get_ticks_msec() / 1000.0
	if (current_time - _buffer_timestamp) > INPUT_BUFFER_WINDOW:
		_buffered_action = &""
		return false
	_buffered_action = &""
	return true


# --- Aim Assist ---

func _apply_aim_assist(base_direction: Vector2) -> Vector2:
	var nearest_enemy: Node2D = null
	var nearest_dist := AIM_ASSIST_RANGE + 1.0

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy is Node2D:
			continue
		var to_enemy: Vector2 = (enemy as Node2D).global_position - global_position
		var dist := to_enemy.length()
		if dist > AIM_ASSIST_RANGE or dist < 1.0:
			continue

		# Check if enemy is within the aim cone
		var angle_to_enemy := base_direction.angle_to(to_enemy)
		if absf(angle_to_enemy) > AIM_CONE_HALF_ANGLE:
			continue

		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy as Node2D

	if nearest_enemy == null:
		return base_direction

	# Slerp toward enemy, capped at max correction
	var to_target: Vector2 = (nearest_enemy.global_position - global_position).normalized()
	var angle_diff := base_direction.angle_to(to_target)
	var correction := clampf(angle_diff, -AIM_MAX_CORRECTION, AIM_MAX_CORRECTION)
	return base_direction.rotated(correction)


# --- Squash/Stretch ---

var _squash_tween: Tween = null

func _squash_stretch(target_scale: Vector2, duration: float) -> void:
	if _squash_tween:
		_squash_tween.kill()
	var base_scale := sprite.scale
	var actual_target := base_scale * target_scale
	_squash_tween = create_tween()
	_squash_tween.tween_property(sprite, "scale", actual_target, duration * 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_squash_tween.tween_property(sprite, "scale", base_scale, duration * 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


# --- Knockback ---

func _apply_knockback(distance: float) -> void:
	# Find nearest enemy/boss for direction
	var nearest: Node2D = null
	var nearest_dist := 999999.0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D:
			var d := global_position.distance_to(enemy.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = enemy as Node2D
	for boss in get_tree().get_nodes_in_group("boss"):
		if boss is Node2D:
			var d := global_position.distance_to(boss.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = boss as Node2D

	var kb_dir := Vector2.DOWN
	if nearest:
		kb_dir = (global_position - nearest.global_position).normalized()
	if kb_dir == Vector2.ZERO:
		kb_dir = Vector2.DOWN

	knockback_velocity = kb_dir * distance * 6.0


# --- Hit Flash Shader ---

func _flash_red() -> void:
	var mat: ShaderMaterial = sprite.material as ShaderMaterial
	if not mat:
		return
	if _flash_tween:
		_flash_tween.kill()
	mat.set_shader_parameter("flash_color", Color(1.0, 0.2, 0.2, 1.0))
	mat.set_shader_parameter("flash_intensity", 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(mat, "shader_parameter/flash_intensity", 0.0, HIT_FLASH_RED_DURATION)


func _flash_white() -> void:
	var mat: ShaderMaterial = sprite.material as ShaderMaterial
	if not mat:
		return
	if _flash_tween:
		_flash_tween.kill()
	mat.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	_flash_tween = create_tween()
	# Pulse 3 times over 0.6 sec (0.1 sec on, 0.1 sec off each)
	for i in range(3):
		_flash_tween.tween_property(mat, "shader_parameter/flash_intensity", 1.0, 0.05)
		_flash_tween.tween_property(mat, "shader_parameter/flash_intensity", 0.0, 0.15)


# --- Animation ---

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


# --- Signals ---

func _connect_signals() -> void:
	hurtbox_area.body_entered.connect(_on_hurtbox_body_entered)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("get_contact_damage"):
		take_damage(body.get_contact_damage())


# --- Combat Economy ---

func _on_shard_collected() -> void:
	if current_energy >= MAX_ENERGY:
		return  # Already full

	current_energy = mini(current_energy + 1, MAX_ENERGY)
	EventBus.energy_meter_changed.emit(current_energy, MAX_ENERGY)

	if current_energy >= MAX_ENERGY and not is_energy_full:
		is_energy_full = true
		EventBus.energy_meter_full.emit()


func _fire_sun_piercer() -> void:
	is_windup = true
	is_energy_full = false
	_is_playing_action = true

	# Consume energy
	current_energy = 0
	EventBus.energy_meter_emptied.emit()

	# Windup effects
	if _sfx_sun_piercer_windup:
		AudioManager.play_sfx(_sfx_sun_piercer_windup, global_position)
	EventBus.camera_trauma.emit(0.2)

	# Flash during windup
	var windup_flash_tween := create_tween()
	for i in range(5):
		windup_flash_tween.tween_callback(func(): sprite.modulate = Color(1.5, 1.5, 0.5))
		windup_flash_tween.tween_interval(SUN_PIERCER_WINDUP / 10.0)
		windup_flash_tween.tween_callback(func(): sprite.modulate = Color.WHITE)
		windup_flash_tween.tween_interval(SUN_PIERCER_WINDUP / 10.0)

	# Wait for windup
	await get_tree().create_timer(SUN_PIERCER_WINDUP).timeout

	# Fire!
	is_windup = false
	if _sfx_sun_piercer_fire:
		AudioManager.play_sfx(_sfx_sun_piercer_fire, global_position)
	EventBus.camera_trauma.emit(0.15)

	# Spawn Sun-Piercer projectile
	var sun_piercer := sun_piercer_scene.instantiate()
	sun_piercer.global_position = arrow_spawn.global_position
	sun_piercer.direction = aim_direction
	sun_piercer.damage = SUN_PIERCER_DAMAGE
	sun_piercer.speed = SUN_PIERCER_SPEED
	get_tree().current_scene.add_child(sun_piercer)

	# Emit signal
	EventBus.special_attack_fired.emit(aim_direction)

	# Reset playing action
	_is_playing_action = false
