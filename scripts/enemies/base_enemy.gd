class_name BaseEnemy
extends CharacterBody2D
## Base class for all shadow enemy types.

@export var hp: int = 40
@export var damage: int = 15
@export var move_speed: float = 100.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

var is_dead: bool = false
var player: Node2D


func _ready() -> void:
	add_to_group("enemy")
	_find_player()
	_connect_signals()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_ai_behavior(delta)
	move_and_slide()


func _ai_behavior(_delta: float) -> void:
	# Override in subclasses
	pass


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]


func take_damage(amount: int) -> void:
	if is_dead:
		return

	hp -= amount

	_hit_feedback()

	if hp <= 0:
		die()


func die() -> void:
	is_dead = true
	EventBus.enemy_died.emit(self)

	# Death effect
	_death_effect()
	queue_free()


func get_contact_damage() -> int:
	return damage


func _hit_feedback() -> void:
	# Flash white
	sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(0.1, 0.1, 0.1)  # Back to shadow color


func _death_effect() -> void:
	# TODO: Spawn death particles
	# TODO: Play death sound
	pass


func _connect_signals() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
