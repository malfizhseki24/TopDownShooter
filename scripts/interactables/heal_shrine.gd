class_name HealShrine
extends Area2D
## Interactable shrine that heals the player.
## One-time use per room visit.

## Amount of HP to restore
@export var heal_amount: int = 50

## Whether this shrine can only be used once
@export var one_time_use: bool = true

@onready var shrine_visual: Node2D = $ShrineVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var interact_prompt: InteractPrompt = $InteractPrompt
@onready var idle_glow: GPUParticles2D = $IdleGlow
@onready var idle_floaty: GPUParticles2D = $IdleFloaty

var is_used: bool = false
var player_in_range: bool = false


func _ready() -> void:
	# Layer 1: Objects (above map, below entities)
	z_index = 1

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Start in available state
	_set_available()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and not is_used:
		_heal_player()


func _set_available() -> void:
	is_used = false
	if shrine_visual:
		shrine_visual.modulate = Color(1, 1, 1, 1)
	if point_light:
		point_light.enabled = true


func _set_used() -> void:
	is_used = true
	if shrine_visual:
		shrine_visual.modulate = Color(0.4, 0.4, 0.4, 0.6)
	if point_light:
		point_light.enabled = false
	# Stop idle particles
	if idle_glow:
		idle_glow.emitting = false
	if idle_floaty:
		idle_floaty.emitting = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_in_range = true

	if not is_used:
		EventBus.show_interact_prompt.emit("Press E to heal (%d HP)" % heal_amount)
		if interact_prompt:
			interact_prompt.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		EventBus.hide_interact_prompt.emit()
		if interact_prompt:
			interact_prompt.hide_prompt()


func _heal_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player := players[0]
	if player == null:
		return

	# Get current HP
	var old_hp: int = player.hp
	var max_hp: int = player.MAX_HP

	# Heal the player (capped at max HP)
	player.hp = mini(player.hp + heal_amount, max_hp)
	var actual_heal: int = player.hp - old_hp

	if actual_heal > 0:
		# Emit heal signal
		EventBus.player_healed.emit(actual_heal)
		EventBus.health_changed.emit(player.hp, max_hp)
		EventBus.damage_dealt.emit(player.global_position, actual_heal, &"heal")

		# Play heal VFX on player
		VFXManager.spawn("heal_burst", player.global_position)
		# Play shrine spiral VFX at shrine position
		VFXManager.spawn("heal_shrine_spiral", global_position)

		# Green screen flash
		EventBus.screen_flash_requested.emit(Color(0.44, 0.76, 0.70), 0.15, 0.4)

		print("Healed player for %d HP (now %d/%d)" % [actual_heal, player.hp, max_hp])

		# Mark as used
		if one_time_use:
			_set_used()
			EventBus.hide_interact_prompt.emit()
			if interact_prompt:
				interact_prompt.hide_prompt()
	else:
		print("Player already at full HP")
