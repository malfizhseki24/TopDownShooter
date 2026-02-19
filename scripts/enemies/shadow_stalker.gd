class_name ShadowStalker
extends BaseEnemy
## Shadow Stalker: Stealthy assassin that teleports near the player.
## Stats: 60 HP, 20 contact damage, 100 px/sec movement.
## Behavior: Teleport to random position near player every 2 seconds,
## visible for 0.5s after teleport, then chase and attack.
## Respawns after 5 seconds at random spawn point.

# Preload scene for respawning
const SCENE := preload("res://scenes/enemies/shadow_stalker.tscn")

# Teleport settings
const TELEPORT_INTERVAL: float = 2.0
const TELEPORT_MIN_DISTANCE: float = 80.0
const TELEPORT_MAX_DISTANCE: float = 120.0
const VISIBLE_AFTER_TELEPORT: float = 0.5
const RESPAWN_DELAY: float = 5.0

# State tracking
var _teleport_timer: float = 0.0
var _is_teleporting: bool = false
var _post_teleport_visible: bool = false
var _visible_timer: float = 0.0


func _ready() -> void:
	max_hp = 60
	contact_damage = 20
	move_speed = 100.0
	super._ready()


func _update_behavior(delta: float) -> void:
	# Handle dying state
	if current_state == State.DYING:
		return

	# Handle post-teleport visible period
	if _post_teleport_visible:
		_visible_timer -= delta
		if _visible_timer <= 0:
			_post_teleport_visible = false
			# Start moving toward player
			current_state = State.MOVING
		return

	# Handle teleporting
	if _is_teleporting:
		return

	# Update teleport timer
	_teleport_timer += delta
	if _teleport_timer >= TELEPORT_INTERVAL:
		_teleport_timer = 0.0
		_do_teleport()
		return

	# Normal chase behavior
	if current_state != State.MOVING:
		current_state = State.MOVING

	var direction := _get_direction_to_player()
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO


func _do_teleport() -> void:
	_is_teleporting = true
	current_state = State.ATTACKING
	velocity = Vector2.ZERO

	# Play teleport animation (disappearing)
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation("teleport_south"):
			var dir := _get_animation_direction()
			var teleport_anim := "teleport_" + dir
			if sprite.sprite_frames.has_animation(teleport_anim):
				sprite.play(teleport_anim)
				await sprite.animation_finished

	# Calculate teleport position (random distance from player, random angle)
	var teleport_distance := randf_range(TELEPORT_MIN_DISTANCE, TELEPORT_MAX_DISTANCE)
	var teleport_angle := randf() * TAU  # Random angle in radians
	var offset := Vector2(cos(teleport_angle), sin(teleport_angle)) * teleport_distance

	if _player:
		global_position = _player.global_position + offset
	else:
		_find_player()
		if _player:
			global_position = _player.global_position + offset

	# Play teleport animation (appearing)
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation("teleport_south"):
			var dir := _get_animation_direction()
			var teleport_anim := "teleport_" + dir
			if sprite.sprite_frames.has_animation(teleport_anim):
				sprite.play(teleport_anim)
				await sprite.animation_finished

	# Set visible period after teleport
	_post_teleport_visible = true
	_visible_timer = VISIBLE_AFTER_TELEPORT
	_is_teleporting = false

	# Reset animation to idle
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		var dir := _get_animation_direction()
		var idle_anim := "idle_" + dir
		if sprite.sprite_frames.has_animation(idle_anim):
			sprite.play(idle_anim)


func _update_animation() -> void:
	if current_state == State.DYING or _is_teleporting:
		return

	# Determine animation based on state
	var anim_name := "idle"

	if _post_teleport_visible or velocity.length() > 10.0:
		anim_name = "walk"

	# Get direction suffix
	var dir := _get_animation_direction()
	var full_anim := anim_name + "_" + dir

	if sprite is AnimatedSprite2D:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(full_anim):
			sprite.flip_h = false
			if sprite.animation != full_anim:
				sprite.play(full_anim)


func _play_death_animation() -> void:
	# Play death animation
	if sprite is AnimatedSprite2D:
		var dir := _get_animation_direction()
		var death_anim := "death_" + dir
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(death_anim):
			sprite.play(death_anim)
			await sprite.animation_finished

	# Then dissolve (with wait before fading)
	await super._play_death_animation()


## Override die() to respawn by spawning NEW instance
func die() -> void:
	print("[DIE] START - pos: ", global_position)
	current_state = State.DYING
	velocity = Vector2.ZERO

	# Disable collision (deferred to avoid physics flush error)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	print("[DIE] Collisions disabled - pos: ", global_position)

	# Emit signals
	died.emit()
	EventBus.enemy_died.emit(self)

	# Play death animation and wait for it to complete
	await _play_death_animation()

	print("[DIE] Death animation done, scheduling respawn...")

	# Get spawn position BEFORE queue_free
	var spawn_pos := _get_respawn_position()
	print("[DIE] Respawn will be at: ", spawn_pos)

	# Get reference to scene tree (survives after queue_free)
	var tree := get_tree()
	var current_scene := tree.current_scene

	# Schedule respawn - lambda is STANDALONE (doesn't reference self)
	tree.create_timer(RESPAWN_DELAY).timeout.connect(
		func():
			print("[RESPAWN] Creating NEW ShadowStalker at: ", spawn_pos)
			var new_enemy := SCENE.instantiate()
			new_enemy.global_position = spawn_pos
			current_scene.add_child(new_enemy)
			print("[RESPAWN] NEW enemy spawned successfully")
	)

	# Remove this instance completely
	queue_free()


func _get_respawn_position() -> Vector2:
	# Find spawn points
	var spawn_points := get_tree().get_nodes_in_group("enemy_spawn")
	if spawn_points.is_empty():
		var spawns_node := get_tree().current_scene.get_node_or_null("EnemySpawns")
		if spawns_node:
			spawn_points = spawns_node.get_children()

	if spawn_points.size() > 0:
		var spawn: Node2D = spawn_points.pick_random()
		return spawn.global_position

	return global_position  # fallback
