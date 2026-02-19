class_name ShadowWisp
extends BaseEnemy
## Shadow Wisp: Slow floating orb with aggressive homing behavior.
## Stats: 25 HP, 10 contact damage, 80 px/sec movement.
## Behavior: Chase player → Bounce back on contact → Chase again
## Respawns after 5 seconds at random spawn point.

# Bounce settings
const BOUNCE_DISTANCE: float = 100.0
const BOUNCE_DURATION: float = 0.3
const ATTACK_COOLDOWN: float = 0.5
const RESPAWN_DELAY: float = 5.0

# State tracking
var _is_bouncing: bool = false
var _bounce_timer: float = 0.0
var _attack_on_cooldown: bool = false


func _ready() -> void:
	max_hp = 25
	contact_damage = 10
	move_speed = 80.0
	super._ready()


func _update_behavior(delta: float) -> void:
	# Handle dying state
	if current_state == State.DYING:
		return

	# Handle bouncing state - use velocity-based movement (respects walls)
	if _is_bouncing:
		_bounce_timer -= delta
		if _bounce_timer <= 0:
			# Bounce complete, resume chasing
			_is_bouncing = false
			current_state = State.IDLE
			velocity = Vector2.ZERO
		return  # Keep bounce velocity, let move_and_slide() handle collision

	if current_state != State.MOVING:
		current_state = State.MOVING

	# Aggressively home toward player
	var direction := _get_direction_to_player()
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO


## Override hitbox collision to add bounce effect
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		# Check cooldown
		if _attack_on_cooldown:
			return

		# Deal damage to player
		body.take_damage(contact_damage)

		# Start cooldown
		_attack_on_cooldown = true
		get_tree().create_timer(ATTACK_COOLDOWN).timeout.connect(_reset_attack_cooldown)

		# Bounce back from player
		_bounce_back()


func _bounce_back() -> void:
	_is_bouncing = true
	current_state = State.ATTACKING
	_bounce_timer = BOUNCE_DURATION

	# Calculate bounce direction (away from player)
	var bounce_dir := Vector2.RIGHT
	if _player:
		bounce_dir = (global_position - _player.global_position).normalized()

	# Set bounce velocity - will be processed by move_and_slide()
	# This respects wall collision automatically
	var bounce_speed := BOUNCE_DISTANCE / BOUNCE_DURATION
	velocity = bounce_dir * bounce_speed


func _reset_attack_cooldown() -> void:
	_attack_on_cooldown = false


func _update_animation() -> void:
	if current_state == State.DYING:
		return

	# Determine animation based on velocity direction
	var anim_name := "walk"

	if velocity.length() < 10.0:
		anim_name = "idle"

	# Get direction suffix
	var dir := _get_animation_direction()
	var full_anim := anim_name + "_" + dir

	# Handle flip for west direction (no west sprites)
	if sprite is AnimatedSprite2D:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(full_anim):
			sprite.flip_h = false
			if sprite.animation != full_anim:
				sprite.play(full_anim)
		else:
			# Fall back to east with flip for west
			var east_anim := anim_name + "_east"
			sprite.flip_h = dir == "west"
			if sprite.animation != east_anim:
				sprite.play(east_anim)


func _get_animation_direction() -> String:
	if velocity.y < -0.5:
		return "north"
	elif velocity.y > 0.5:
		return "south"
	elif velocity.x < 0:
		return "west"
	else:
		return "east"


func _play_death_animation() -> void:
	# Play death animation if available
	if sprite is AnimatedSprite2D:
		var death_anim := "death_south"
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("death_south"):
			# Determine death direction
			var dir := _get_animation_direction()
			var dir_anim := "death_" + dir
			if sprite.sprite_frames.has_animation(dir_anim):
				death_anim = dir_anim
			elif dir == "west" and sprite.sprite_frames.has_animation("death_east"):
				death_anim = "death_east"
				sprite.flip_h = true

			sprite.play(death_anim)
			await sprite.animation_finished

	# Then dissolve
	super._play_death_animation()


## Override die() to respawn instead of queue_free
func die() -> void:
	current_state = State.DYING
	velocity = Vector2.ZERO

	# Disable collision during death/respawn
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	# Play death animation
	_play_death_animation()

	# Emit signals
	died.emit()
	EventBus.enemy_died.emit(self)

	# Hide enemy (keep in scene for respawn)
	hide()

	# Wait for respawn delay
	await get_tree().create_timer(RESPAWN_DELAY).timeout

	# Respawn at random spawn point
	_respawn()


func _respawn() -> void:
	# Find spawn points in level
	var spawn_points := get_tree().get_nodes_in_group("enemy_spawn")
	if spawn_points.is_empty():
		# Fallback: try to find EnemySpawns node
		var spawns_node := get_tree().current_scene.get_node_or_null("EnemySpawns")
		if spawns_node:
			spawn_points = spawns_node.get_children()

	# Pick random spawn point
	if spawn_points.size() > 0:
		var spawn: Node2D = spawn_points.pick_random()
		global_position = spawn.global_position

	# Reset HP
	hp = max_hp

	# Reset state
	current_state = State.IDLE
	_is_bouncing = false
	_bounce_timer = 0.0
	_attack_on_cooldown = false
	velocity = Vector2.ZERO

	# Re-enable collision
	if hitbox:
		hitbox.set_deferred("monitoring", true)
	$CollisionShape2D.set_deferred("disabled", false)

	# Reset sprite visibility
	sprite.modulate = Color.WHITE

	# Show enemy
	show()

	# Re-find player reference
	_find_player()
