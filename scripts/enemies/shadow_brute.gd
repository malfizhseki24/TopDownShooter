class_name ShadowBrute
extends BaseEnemy
## Shadow Brute: Tanky enemy with powerful charge attack.
## Stats: 150 HP, 30 contact damage, 60 px/sec movement.
## Behavior: Slow chase → Telegraph charge → Charge at high speed → Cooldown
## Respawns after 5 seconds at random spawn point.

# Preload scene for respawning
const SCENE := preload("res://scenes/enemies/shadow_brute.tscn")

# Charge settings
const CHARGE_RANGE: float = 150.0
const CHARGE_SPEED: float = 300.0
const CHARGE_DURATION: float = 0.5
const CHARGE_COOLDOWN: float = 3.0
const TELEGRAPH_DURATION: float = 0.3
const RESPAWN_DELAY: float = 5.0
const ATTACK_COOLDOWN: float = 0.8

# State tracking
var _charge_cooldown_timer: float = 0.0
var _is_charging: bool = false
var _is_telegraphing: bool = false
var _charge_timer: float = 0.0
var _charge_direction: Vector2 = Vector2.ZERO
var _attack_on_cooldown: bool = false


func _ready() -> void:
	max_hp = 150
	contact_damage = 30
	move_speed = 60.0
	super._ready()


func _update_behavior(delta: float) -> void:
	# Handle dying state
	if current_state == State.DYING:
		return

	# Update charge cooldown
	if _charge_cooldown_timer > 0:
		_charge_cooldown_timer -= delta

	# Handle telegraphing (flash warning before charge)
	if _is_telegraphing:
		_telegraph_timer -= delta
		# Flash effect
		sprite.modulate = Color.RED if int(_telegraph_timer * 10) % 2 == 0 else Color.WHITE

		if _telegraph_timer <= 0:
			_start_charge()
		return

	# Handle charging
	if _is_charging:
		_charge_timer -= delta
		velocity = _charge_direction * CHARGE_SPEED

		if _charge_timer <= 0:
			_end_charge()
		return

	# Check if player is in charge range
	if _player and _charge_cooldown_timer <= 0:
		var distance_to_player := global_position.distance_to(_player.global_position)
		if distance_to_player <= CHARGE_RANGE:
			_start_telegraph()
			return

	# Normal chase behavior
	if current_state != State.MOVING:
		current_state = State.MOVING

	var direction := _get_direction_to_player()
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO


var _telegraph_timer: float = 0.0


func _start_telegraph() -> void:
	"""Start telegraph animation before charging."""
	_is_telegraphing = true
	_telegraph_timer = TELEGRAPH_DURATION
	current_state = State.ATTACKING
	velocity = Vector2.ZERO

	# Calculate charge direction
	_charge_direction = _get_direction_to_player()

	# Play charge windup animation
	_update_animation()


func _start_charge() -> void:
	"""Execute the charge attack."""
	_is_telegraphing = false
	_is_charging = true
	_charge_timer = CHARGE_DURATION
	sprite.modulate = Color.WHITE

	# Recalculate direction in case player moved
	_charge_direction = _get_direction_to_player()

	# Update animation for charge
	_update_animation()


func _end_charge() -> void:
	"""End the charge and start cooldown."""
	_is_charging = false
	_charge_cooldown_timer = CHARGE_COOLDOWN
	current_state = State.IDLE
	velocity = Vector2.ZERO

	# Update animation back to idle/walk
	_update_animation()


func _update_animation() -> void:
	if current_state == State.DYING:
		return

	var dir := _get_animation_direction()
	var anim_prefix := _get_anim_prefix()

	if _is_telegraphing:
		# Use charge animation during telegraph
		var charge_anim := "crouched-walking_" + dir
		if sprite is AnimatedSprite2D and sprite.sprite_frames:
			if sprite.sprite_frames.has_animation(charge_anim):
				sprite.flip_h = false
				sprite.play(charge_anim)
			elif dir == "west" and sprite.sprite_frames.has_animation("crouched-walking_east"):
				sprite.flip_h = true
				sprite.play("crouched-walking_east")
	elif _is_charging:
		# Use charge animation during charge
		var charge_anim := "crouched-walking_" + dir
		if sprite is AnimatedSprite2D and sprite.sprite_frames:
			if sprite.sprite_frames.has_animation(charge_anim):
				sprite.flip_h = false
				sprite.play(charge_anim)
			elif dir == "west" and sprite.sprite_frames.has_animation("crouched-walking_east"):
				sprite.flip_h = true
				sprite.play("crouched-walking_east")
	elif velocity.length() > 10.0:
		var walk_anim := "walking-6_" + dir
		if sprite is AnimatedSprite2D and sprite.sprite_frames:
			if sprite.sprite_frames.has_animation(walk_anim):
				sprite.flip_h = false
				sprite.play(walk_anim)
			elif dir == "west" and sprite.sprite_frames.has_animation("walking-6_east"):
				sprite.flip_h = true
				sprite.play("walking-6_east")
	else:
		var idle_anim := "breathing-idle_" + dir
		if sprite is AnimatedSprite2D and sprite.sprite_frames:
			if sprite.sprite_frames.has_animation(idle_anim):
				sprite.flip_h = false
				sprite.play(idle_anim)
			elif dir == "west" and sprite.sprite_frames.has_animation("breathing-idle_east"):
				sprite.flip_h = true
				sprite.play("breathing-idle_east")


func _get_anim_prefix() -> String:
	if _is_charging or _is_telegraphing:
		return "crouched-walking"
	elif velocity.length() > 10.0:
		return "walking-6"
	return "breathing-idle"


## Override hitbox collision for charge damage boost
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		# Check cooldown
		if _attack_on_cooldown:
			return

		# Deal damage (bonus damage during charge)
		var damage := contact_damage
		if _is_charging:
			damage = int(contact_damage * 1.5)  # 50% bonus during charge

		body.take_damage(damage)

		# Start cooldown
		_attack_on_cooldown = true
		get_tree().create_timer(ATTACK_COOLDOWN).timeout.connect(_reset_attack_cooldown)


## Override die() to respawn by spawning NEW instance
func die() -> void:
	current_state = State.DYING
	velocity = Vector2.ZERO
	_is_charging = false
	_is_telegraphing = false

	# Disable collision
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	# Reset sprite color
	sprite.modulate = Color.WHITE

	# Emit signals
	died.emit()
	EventBus.enemy_died.emit(self)

	# Play death animation and wait for it to complete
	await _play_death_animation()

	# Get spawn position BEFORE queue_free
	var spawn_pos := _get_respawn_position()

	# Get reference to scene tree (survives after queue_free)
	var tree := get_tree()
	var current_scene := tree.current_scene

	# Schedule respawn
	tree.create_timer(RESPAWN_DELAY).timeout.connect(
		func():
			var new_enemy := SCENE.instantiate()
			new_enemy.global_position = spawn_pos
			current_scene.add_child(new_enemy)
	)

	# Remove this instance completely
	queue_free()


func _play_death_animation() -> void:
	# Play direction-specific death animation
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		var dir := _get_animation_direction()
		var death_anim := "falling-back-death_" + dir
		if sprite.sprite_frames.has_animation(death_anim):
			sprite.flip_h = false
			sprite.play(death_anim)
			await sprite.animation_finished
		elif dir == "west" and sprite.sprite_frames.has_animation("falling-back-death_east"):
			sprite.flip_h = true
			sprite.play("falling-back-death_east")
			await sprite.animation_finished

	# Then dissolve (with wait before fading)
	await super._play_death_animation()


func _get_respawn_position() -> Vector2:
	# Find spawn points in level
	var spawn_points := get_tree().get_nodes_in_group("enemy_spawn")
	if spawn_points.is_empty():
		# Fallback: try to find EnemySpawns node
		var spawns_node := get_tree().current_scene.get_node_or_null("EnemySpawns")
		if spawns_node:
			spawn_points = spawns_node.get_children()

	if spawn_points.size() > 0:
		var spawn: Node2D = spawn_points.pick_random()
		return spawn.global_position

	return global_position  # fallback


func _reset_attack_cooldown() -> void:
	_attack_on_cooldown = false
