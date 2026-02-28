class_name ShadowStalker
extends BaseEnemy
## Shadow Stalker: Stealthy assassin that teleports near the player.
## Stats: 60 HP, 20 contact damage, 100 px/sec movement.
## Behavior: Teleport to random position near player every 2 seconds,
## visible for 0.5s after teleport, then chase and attack.

# Preload VFX
const TELEPORT_SMOKE := preload("res://assets/vfx/scenes/teleport_smoke.tscn")

# Teleport settings
const TELEPORT_INTERVAL: float = 2.0
const TELEPORT_MIN_DISTANCE: float = 80.0
const TELEPORT_MAX_DISTANCE: float = 120.0
const VISIBLE_AFTER_TELEPORT: float = 0.5

# State tracking
var _teleport_timer: float = 0.0
var _is_teleporting: bool = false
var _post_teleport_visible: bool = false
var _visible_timer: float = 0.0


func _ready() -> void:
	max_hp = 60
	contact_damage = 20
	move_speed = 100.0
	glow_color = Color(0.8, 0.3, 0.5, 0.4)  # Dark magenta glow
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

	# Normal chase behavior (uses pathfinding if available)
	if current_state != State.MOVING:
		current_state = State.MOVING

	var direction := _get_movement_direction()
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO


func _do_teleport() -> void:
	_is_teleporting = true
	current_state = State.ATTACKING
	velocity = Vector2.ZERO

	# Spawn smoke at old position (disappearing)
	_spawn_teleport_smoke()

	# Hide enemy during teleport (for effect)
	hide()

	# Play teleport animation (disappearing)
	_play_teleport_animation()

	# Calculate teleport position (random distance from player, random angle)
	var teleport_distance := randf_range(TELEPORT_MIN_DISTANCE, TELEPORT_MAX_DISTANCE)
	var teleport_angle := randf() * TAU
	var offset := Vector2(cos(teleport_angle), sin(teleport_angle)) * teleport_distance

	if _player:
		global_position = _player.global_position + offset
	else:
		_find_player()
		if _player:
			global_position = _player.global_position + offset

	# Show enemy at new position
	show()

	# Spawn smoke at new position (appearing)
	_spawn_teleport_smoke()

	# Play teleport animation (appearing)
	_play_teleport_animation()

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
		elif dir == "west" and sprite.sprite_frames.has_animation("idle_east"):
			sprite.flip_h = true
			sprite.play("idle_east")


func _spawn_teleport_smoke() -> void:
	var smoke := TELEPORT_SMOKE.instantiate()
	smoke.global_position = global_position
	get_tree().current_scene.add_child(smoke)
	smoke.emitting = true  # Trigger the particle burst
	# Auto-cleanup after particles finish
	smoke.finished.connect(smoke.queue_free)


func _play_teleport_animation() -> void:
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		var dir := _get_animation_direction()
		var teleport_anim := "teleport_" + dir

		# Check if animation exists, fallback to east with flip for west
		if sprite.sprite_frames.has_animation(teleport_anim):
			sprite.flip_h = false
			sprite.play(teleport_anim)
			await sprite.animation_finished
		elif dir == "west" and sprite.sprite_frames.has_animation("teleport_east"):
			sprite.flip_h = true
			sprite.play("teleport_east")
			await sprite.animation_finished
		elif sprite.sprite_frames.has_animation("teleport_south"):
			# Fallback to south
			sprite.flip_h = false
			sprite.play("teleport_south")
			await sprite.animation_finished


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


func die() -> void:
	# Disable collision before base die() (deferred to avoid physics flush error)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	super.die()
