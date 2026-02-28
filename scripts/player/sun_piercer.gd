class_name SunPiercer
extends Area2D
## Ultimate attack projectile that pierces through enemies and obstacles.
## High damage, triggers hitstop and screen shake on impact.

# Constants
const LIFETIME: float = 2.0
const MAX_OBSTACLE_PIERCE: int = 3
const HIT_COOLDOWN: float = 0.1

# Stats (set by player)
var damage: int = 80
var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

# State
var _lifetime_timer: float = 0.0
var _obstacles_pierced: int = 0
var _hit_enemies: Dictionary = {}  # enemy -> time of hit

# References
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var glow: PointLight2D = $Glow
@onready var trail: GPUParticles2D = $TrailParticles
@onready var hit_cooldown_timer: Timer = $HitCooldownTimer

# SFX
var _sfx_impact: AudioStream = preload("res://assets/audio/sfx/arrow_hit.wav")


func _ready() -> void:
	# Configure collision
	collision_layer = 4  # arrow layer
	collision_mask = 2 | 8  # enemy + wall layers

	# Connect signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Set direction
	rotation = direction.angle()

	# Start trail
	if trail:
		trail.emitting = true


func _physics_process(delta: float) -> void:
	# Move
	position += direction * speed * delta

	# Update lifetime
	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		_die()

	# Check if off-screen (simple check)
	var viewport_rect := get_viewport_rect()
	var margin := 100.0
	if global_position.x < -margin or global_position.x > viewport_rect.size.x + margin:
		_die()
	if global_position.y < -margin or global_position.y > viewport_rect.size.y + margin:
		_die()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		_handle_enemy_hit(body)
	elif body.is_in_group("wall") or body.is_in_group("obstacle"):
		_handle_obstacle_hit(body)


func _on_area_entered(area: Area2D) -> void:
	# Check for destructible areas
	var parent := area.get_parent()
	if parent and parent.is_in_group("destructible"):
		_handle_destructible_hit(parent)


func _handle_enemy_hit(enemy: Node2D) -> void:
	# Check hit cooldown
	var current_time := Time.get_ticks_msec() / 1000.0
	if _hit_enemies.has(enemy):
		var last_hit_time: float = _hit_enemies[enemy]
		if current_time - last_hit_time < HIT_COOLDOWN:
			return  # Still on cooldown

	# Record hit time
	_hit_enemies[enemy] = current_time

	# Apply damage
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, &"special_attack")

	# Emit signal
	EventBus.special_attack_hit.emit(enemy, damage)

	# Spawn damage number (gold color)
	EventBus.damage_dealt.emit(enemy.global_position, damage, &"special_attack")

	# Hitstop
	HitstopManager.freeze(0.15)

	# Screen shake
	EventBus.camera_trauma.emit(0.1)

	# Impact particles
	VFXManager.spawn("sun_piercer_impact", enemy.global_position)

	# Impact SFX (if available)
	if _sfx_impact:
		AudioManager.play_sfx(_sfx_impact, enemy.global_position)


func _handle_obstacle_hit(_obstacle: Node2D) -> void:
	_obstacles_pierced += 1

	# Small impact effect
	EventBus.camera_trauma.emit(0.05)

	if _obstacles_pierced >= MAX_OBSTACLE_PIERCE:
		_die()


func _handle_destructible_hit(destructible: Node2D) -> void:
	if destructible.has_method("take_damage"):
		destructible.take_damage(damage)

	_obstacles_pierced += 1

	if _obstacles_pierced >= MAX_OBSTACLE_PIERCE:
		_die()


func _die() -> void:
	# Stop trail
	if trail:
		trail.emitting = false

	# Fade out effect
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(glow, "energy", 0.0, 0.2)
	tween.tween_callback(queue_free)
