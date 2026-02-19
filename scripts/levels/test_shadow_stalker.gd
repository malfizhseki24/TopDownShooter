extends Node2D
## Test scene for Shadow Stalker enemy.

@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var stalker: Node2D = $ShadowStalker


func _ready() -> void:
	# Add walls to wall group
	for wall in $Walls.get_children():
		wall.add_to_group("wall")

	# Setup camera
	if player and camera:
		camera.target = player

	# Start game (enable enemy AI)
	print("[TestScene] Starting game...")
	GameManager.start_game()
	print("[TestScene] Game state: ", GameManager.current_state)
