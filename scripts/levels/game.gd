extends Node2D
## Main game scene with linear room-based stage progression.
## Manages player, rooms, and game flow. HUD is delegated to hud.tscn.

# Scene references
@export var player_scene: PackedScene = preload("res://scenes/player/player.tscn")
var hud_scene: PackedScene = preload("res://scenes/ui/hud.tscn")
var sun_shard_scene: PackedScene = preload("res://scenes/pickups/sun_shard.tscn")

# Node references
@onready var room_manager: RoomManager = $RoomManager
@onready var entities: Node2D = $Entities
@onready var interactables: Node2D = $Interactables
@onready var damage_number_layer: Node2D = $DamageNumberLayer
@onready var camera: Camera2D = $Camera2D

# HUD (instanced at runtime)
var hud: CanvasLayer = null

# Runtime state
var player: CharacterBody2D = null
var persistent_player_hp: int = 100  # HP persists across rooms


func _ready() -> void:
	_setup_hud()
	_setup_room_manager()
	_connect_signals()
	_spawn_player()
	_load_first_room()
	GameManager.start_game()


func _setup_hud() -> void:
	hud = hud_scene.instantiate() as CanvasLayer
	add_child(hud)
	# Give the HUD access to the damage number layer
	hud.set_damage_number_layer(damage_number_layer)


func _setup_room_manager() -> void:
	room_manager.set_entities_node(entities)
	room_manager.set_interactables_node(interactables)

	GameManager.set_total_rooms(RoomBlueprints.get_total_rooms())


func _connect_signals() -> void:
	# Room signals
	room_manager.room_loaded.connect(_on_room_loaded)
	room_manager.room_cleared.connect(_on_room_cleared)
	room_manager.all_rooms_cleared.connect(_on_all_rooms_cleared)
	EventBus.room_transition_requested.connect(_on_room_transition_requested)

	# Player signals
	EventBus.player_died.connect(_on_player_died)

	# Combat Economy signals
	EventBus.shard_dropped.connect(_on_shard_dropped)


func _spawn_player() -> void:
	var spawn_pos := room_manager.get_player_spawn_position()

	player = player_scene.instantiate() as CharacterBody2D
	player.global_position = spawn_pos
	player.hp = persistent_player_hp  # Restore HP

	entities.add_child(player)

	if camera:
		camera.target = player

	# Update HUD
	EventBus.health_changed.emit(player.hp, player.MAX_HP)
	print("Player spawned at: %s with HP: %d" % [str(spawn_pos), persistent_player_hp])


func _load_first_room() -> void:
	room_manager.load_room(0)
	_spawn_ambient_dust()


func _spawn_ambient_dust() -> void:
	var dust := VFXManager.spawn("ambient_dust", Vector2.ZERO, camera)
	if dust:
		dust.position = Vector2.ZERO  # Centered on camera


func _on_room_loaded(room_index: int) -> void:
	print("Room %d loaded" % (room_index + 1))

	# Move player to spawn position
	if player:
		player.global_position = room_manager.get_player_spawn_position()
		player.velocity = Vector2.ZERO


func _on_room_cleared(room_index: int) -> void:
	print("Room %d cleared!" % (room_index + 1))


func _on_all_rooms_cleared() -> void:
	print("All rooms cleared!")

	# Dramatic victory sequence - wait for boss death animation
	# Boss death: 2.5s wait + 1.0s dissolve = ~3.5s total
	# Add extra time for dramatic effect

	# Freeze frame for impact
	HitstopManager.freeze(0.15)

	# Wait for initial freeze to complete
	await get_tree().create_timer(0.2).timeout

	# Screen flash white for victory moment
	EventBus.screen_flash_requested.emit(Color.WHITE, 0.7, 0.3)

	# Add camera trauma for dramatic effect
	EventBus.camera_trauma.emit(0.4)

	# Slow-mo effect during boss dissolution
	Engine.time_scale = 0.3
	await get_tree().create_timer(1.0, true, false, true).timeout  # Process even during slow-mo

	# Gradually return to normal speed
	var tween := create_tween()
	tween.tween_method(func(val): Engine.time_scale = val, 0.3, 1.0, 0.5)
	await tween.finished

	# Final pause before victory screen
	await get_tree().create_timer(0.5).timeout

	GameManager.trigger_victory()


func _on_room_transition_requested(next_room_index: int) -> void:
	print("Transitioning to room %d" % (next_room_index + 1))

	# Save player HP before transition
	if player:
		persistent_player_hp = player.hp

	# Fade transition via HUD
	await hud.fade_to_black()

	# Load next room
	GameManager.advance_room()
	room_manager.load_room(next_room_index)

	# Fade back in
	await hud.fade_from_black()


func _on_player_died() -> void:
	await get_tree().create_timer(1.5).timeout
	GameManager.trigger_game_over()


func _on_shard_dropped(pos: Vector2) -> void:
	# Spawn Sun Shard at the drop position (deferred to avoid physics flush error)
	var shard := sun_shard_scene.instantiate()
	shard.global_position = pos
	entities.call_deferred("add_child", shard)
