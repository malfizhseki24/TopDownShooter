## TestCollision - Tests for physics collision between player/arrows and walls
extends GutTest

var player: CharacterBody2D
var wall: StaticBody2D


func before_each() -> void:
	# Create wall
	wall = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 100)
	collision.shape = shape
	wall.add_child(collision)
	wall.collision_layer = 16  # Wall layer
	wall.collision_mask = 0
	wall.position = Vector2(300, 135)  # Right of center
	add_child(wall)

	# Create player
	var player_scene = load("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(200, 135)  # Left of wall

	await wait_physics_frames(2)


func after_each() -> void:
	if player:
		player.queue_free()
	if wall:
		wall.queue_free()


## Test: Player cannot pass through wall
func test_player_wall_collision() -> void:
	var initial_x = player.global_position.x

	# Move player toward wall
	Input.action_press("move_right")

	# Wait for physics
	await wait_seconds(0.5)

	Input.action_release("move_right")

	# Player should not have passed the wall
	# Wall is at x=300, wall is 32 wide, so edge is at 284
	# Player has radius 16, so max x should be ~268
	assert_lt(player.global_position.x, 280, "Player should not pass through wall")


## Test: Player collides with wall from different angles
func test_player_wall_collision_diagonal() -> void:
	# Reset position
	player.global_position = Vector2(200, 100)  # Above and left

	# Move diagonally toward wall
	Input.action_press("move_right")
	Input.action_press("move_down")

	await wait_seconds(0.5)

	Input.action_release("move_right")
	Input.action_release("move_down")

	# Should still be blocked by wall
	assert_lt(player.global_position.x, 280, "Player should not pass through wall diagonally")
