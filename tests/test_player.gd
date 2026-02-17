## TestPlayer - Unit tests for Player movement and mechanics
extends GutTest

var player: CharacterBody2D


func before_each() -> void:
	# Load and instantiate player
	var player_scene = load("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(240, 135)
	await wait_frames(1)


func after_each() -> void:
	if player:
		player.queue_free()


## Test: Player moves at correct speed
func test_player_move_speed() -> void:
	# Simulate input
	Input.action_press("move_right")
	await wait_seconds(0.1)

	# Check velocity magnitude
	var speed = player.velocity.length()
	assert_almost_eq(speed, 200.0, 10.0, "Player should move at 200 px/sec")

	Input.action_release("move_right")


## Test: Diagonal movement is normalized
func test_diagonal_movement_normalized() -> void:
	# Simulate diagonal input
	Input.action_press("move_right")
	Input.action_press("move_down")
	await wait_seconds(0.1)

	# Diagonal speed should equal cardinal speed
	var speed = player.velocity.length()
	assert_almost_eq(speed, 200.0, 10.0, "Diagonal movement should be normalized")

	Input.action_release("move_right")
	Input.action_release("move_down")


## Test: Player stops when no input
func test_player_stops_no_input() -> void:
	# First, get player moving
	Input.action_press("move_right")
	await wait_seconds(0.1)
	Input.action_release("move_right")

	# Wait for physics to settle
	await wait_physics_frames(5)

	# Velocity should be zero or near zero
	assert_almost_eq(player.velocity.length(), 0.0, 5.0, "Player should stop when no input")


## Test: Aim direction is calculated correctly
func test_aim_direction_calculated() -> void:
	# Simulate mouse position to the right of player
	var mouse_pos = player.global_position + Vector2(100, 0)
	Input.warp_mouse(mouse_pos)
	await wait_frames(1)

	# Get aim direction
	var aim_dir = player.aim_direction

	# Should point right
	assert_almost_eq(aim_dir.x, 1.0, 0.1, "Aim should point right")
	assert_almost_eq(aim_dir.y, 0.0, 0.1, "Aim Y should be ~0")


## Test: Aim direction is normalized
func test_aim_direction_normalized() -> void:
	# Simulate mouse at diagonal
	var mouse_pos = player.global_position + Vector2(100, 100)
	Input.warp_mouse(mouse_pos)
	await wait_frames(1)

	var aim_dir = player.aim_direction
	assert_almost_eq(aim_dir.length(), 1.0, 0.1, "Aim direction should be normalized")


## Test: Player has correct collision layer
func test_player_collision_layer() -> void:
	# Player should be on layer 1 (player)
	assert_eq(player.collision_layer, 1, "Player should be on layer 1")


## Test: Player collides with wall layer
func test_player_collision_mask() -> void:
	# Player should detect layer 16 (wall = layer 4 in binary = 16)
	assert_eq(player.collision_mask, 16, "Player should collide with walls (layer 4)")


## Test: Player starts with full health
func test_player_full_health() -> void:
	assert_eq(player.hp, 100, "Player should start with 100 HP")


## Test: Player can shoot initially
func test_player_can_shoot() -> void:
	assert_true(player.can_shoot, "Player should be able to shoot initially")


## Test: Player can dash initially
func test_player_can_dash() -> void:
	assert_true(player.can_dash, "Player should be able to dash initially")
