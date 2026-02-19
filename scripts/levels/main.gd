extends Node2D
## Main game level scene.

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var camera: Camera2D = $Camera2D
@onready var enemies_container: Node2D = $Enemies
@onready var health_bar: ProgressBar = $CanvasLayer/HUD/HealthBar
@onready var player_node: Node2D = $Player
@onready var walls: Node2D = $Walls
@onready var enemy_spawns: Node2D = $EnemySpawns


func _ready() -> void:
	_setup_walls()
	_setup_enemy_spawns()
	_setup_camera()
	_setup_spawn_position()
	_connect_signals()
	GameManager.start_game()


func _setup_spawn_position() -> void:
	# Set the global spawn position for player respawn
	GameManager.player_spawn_position = player_spawn.global_position


func _setup_walls() -> void:
	# Add all walls to "wall" group for collision detection
	for wall in walls.get_children():
		wall.add_to_group("wall")


func _setup_enemy_spawns() -> void:
	# Add all enemy spawn points to "enemy_spawn" group
	for spawn in enemy_spawns.get_children():
		spawn.add_to_group("enemy_spawn")


func _setup_camera() -> void:
	# Set camera to follow existing player in scene
	if player_node and camera:
		camera.target = player_node


func _connect_signals() -> void:
	EventBus.health_changed.connect(_on_health_changed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.victory.connect(_on_victory)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.value = (float(current) / float(maximum)) * 100.0


func _on_player_died() -> void:
	# Player handles respawn internally - no game over trigger needed
	# Game over will be triggered by other conditions (boss defeat, no lives, etc.)
	pass


func _on_victory() -> void:
	await get_tree().create_timer(2.0).timeout
	GameManager.trigger_victory()
