extends Node2D
## Main game level scene.

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var camera: Camera2D = $Camera2D
@onready var enemies_container: Node2D = $Enemies
@onready var health_bar: ProgressBar = $CanvasLayer/HUD/HealthBar

var player: Node2D


func _ready() -> void:
	_setup_player()
	_connect_signals()
	GameManager.start_game()


func _setup_player() -> void:
	# Load and instantiate player
	var player_scene := preload("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)

	# Set camera to follow player
	camera.script.target = player


func _connect_signals() -> void:
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.victory.connect(_on_victory)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.value = (float(current) / float(maximum)) * 100.0


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	GameManager.trigger_game_over()


func _on_victory() -> void:
	await get_tree().create_timer(2.0).timeout
	GameManager.trigger_victory()
