class_name Arrow
extends Area2D
## Projectile fired by the player.

const LIFETIME: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var wall_cast: RayCast2D = $WallCast
@onready var trail_particles: GPUParticles2D = $TrailParticles

var direction: Vector2 = Vector2.RIGHT
var speed: float = 600.0
var damage: int = 25

var _lifetime_timer: float = 0.0

# SFX
var _sfx_arrow_hit: AudioStream = preload("res://assets/audio/sfx/arrow_hit.wav")
var _sfx_arrow_hit_destructible: AudioStream = preload("res://assets/audio/sfx/arrow_hit_destructible.wav")


func _ready() -> void:
	rotation = direction.angle()

	# Stretch sprite for speed feel (0.8x wide, 1.2x tall along flight direction)
	if sprite:
		sprite.scale = Vector2(0.8, 1.2)

	# Setup wall raycast
	if wall_cast:
		wall_cast.target_position = direction * 20.0
		wall_cast.collision_mask = 8  # Layer 4 (walls)


func _physics_process(delta: float) -> void:
	# Check wall collision with raycast BEFORE moving
	if wall_cast and wall_cast.is_colliding():
		_hit_effect(global_position)
		_stop_trail_and_free()
		return

	position += direction * speed * delta

	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		_stop_trail_and_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		EventBus.enemy_hit.emit(body, damage)
		AudioManager.play_sfx(_sfx_arrow_hit, body.global_position)
		_hit_effect(body.global_position)
		_stop_trail_and_free()
	elif body.is_in_group("destructible"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		AudioManager.play_sfx(_sfx_arrow_hit_destructible, body.global_position)
		_hit_effect(body.global_position)
		_stop_trail_and_free()


func _stop_trail_and_free() -> void:
	if trail_particles:
		trail_particles.emitting = false
		# Reparent trail so it can fade after arrow is freed
		var trail_pos := trail_particles.global_position
		var trail_rot := trail_particles.global_rotation
		trail_particles.reparent(get_tree().current_scene)
		trail_particles.global_position = trail_pos
		trail_particles.global_rotation = trail_rot
		# Auto-free after particles fade (lifetime is 0.35s)
		get_tree().create_timer(0.5).timeout.connect(trail_particles.queue_free)
	queue_free()


func _hit_effect(hit_position: Vector2) -> void:
	# Spawn hit particles at the hit position
	VFXManager.spawn("hit_spark", hit_position)
