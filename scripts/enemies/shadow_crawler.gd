class_name ShadowCrawler
extends BaseEnemy
## Shadow Crawler: Fast quadruped creature with aggressive chase behavior.
## Stats: 35 HP, 15 contact damage, 120 px/sec movement.
## Behavior: Chase player → Attack on contact → Bounce back → Chase again

# Bounce settings
const BOUNCE_DISTANCE: float = 80.0
const BOUNCE_DURATION: float = 0.25
const ATTACK_COOLDOWN: float = 0.6

# State tracking
var _is_bouncing: bool = false
var _bounce_timer: float = 0.0
var _attack_on_cooldown: bool = false
var _is_attacking: bool = false


func _ready() -> void:
	max_hp = 35
	contact_damage = 15
	move_speed = 120.0
	super._ready()


func _update_behavior(delta: float) -> void:
	# Handle dying state
	if current_state == State.DYING:
		return

	# Handle bouncing state
	if _is_bouncing:
		_bounce_timer -= delta
		if _bounce_timer <= 0:
			_is_bouncing = false
			current_state = State.IDLE
			velocity = Vector2.ZERO
		return

	# Handle attacking state (wait for animation)
	if _is_attacking:
		velocity = Vector2.ZERO
		return

	if current_state != State.MOVING:
		current_state = State.MOVING

	# Aggressively home toward player (uses pathfinding if available)
	var direction := _get_movement_direction()
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO


## Override hitbox collision to add attack and bounce effect
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

		# Play attack animation then bounce
		_attack()


func _attack() -> void:
	_is_attacking = true
	current_state = State.ATTACKING

	# Get direction BEFORE zeroing velocity (fixes direction bug)
	var dir := _get_animation_direction()
	velocity = Vector2.ZERO

	# Play attack animation
	var attack_anim := "attack_" + dir
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(attack_anim):
			sprite.play(attack_anim)
			await sprite.animation_finished

	_is_attacking = false

	# Bounce back after attack
	_bounce_back()


func _bounce_back() -> void:
	_is_bouncing = true
	current_state = State.ATTACKING
	_bounce_timer = BOUNCE_DURATION

	# Calculate bounce direction (away from player)
	var bounce_dir := Vector2.RIGHT
	if _player:
		bounce_dir = (global_position - _player.global_position).normalized()

	# Set bounce velocity
	var bounce_speed := BOUNCE_DISTANCE / BOUNCE_DURATION
	velocity = bounce_dir * bounce_speed


func _reset_attack_cooldown() -> void:
	_attack_on_cooldown = false


func _update_animation() -> void:
	if current_state == State.DYING or _is_attacking:
		return

	# Determine animation based on state
	var anim_name := "idle"

	if _is_bouncing:
		anim_name = "walk"  # Use walk for bounce
	elif velocity.length() > 10.0:
		anim_name = "walk"

	# Get direction suffix
	var dir := _get_animation_direction()
	var full_anim := anim_name + "_" + dir

	# Shadow Crawler has all 4 directions, no flip needed
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
