class_name Arrow
extends Area2D
## Projectile fired by the player.

const LIFETIME: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 600.0
var damage: int = 25

var _lifetime_timer: float = 0.0


func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	_lifetime_timer += delta
	if _lifetime_timer >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		EventBus.enemy_hit.emit(body, damage)
		_hit_effect()
		queue_free()
	elif body.is_in_group("wall"):
		_hit_effect()
		queue_free()


func _hit_effect() -> void:
	# TODO: Spawn hit particles
	# TODO: Play hit sound
	pass
