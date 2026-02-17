## TestArrow - Unit tests for Arrow projectile mechanics
extends GutTest

var arrow: Area2D


func before_each() -> void:
	# Load arrow scene
	var arrow_scene = load("res://scenes/player/arrow.tscn")
	arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.global_position = Vector2(240, 135)
	arrow.direction = Vector2.RIGHT
	arrow.speed = 600.0
	await wait_frames(1)


func after_each() -> void:
	if arrow and is_instance_valid(arrow):
		arrow.queue_free()


## Test: Arrow has correct collision layer (layer 3 = 4)
func test_arrow_collision_layer() -> void:
	assert_eq(arrow.collision_layer, 4, "Arrow should be on layer 3 (value 4)")


## Test: Arrow has correct collision mask (enemy + wall)
func test_arrow_collision_mask() -> void:
	# Layer 2 (enemy) = 2, Layer 4 (wall) = 16, combined = 18
	assert_eq(arrow.collision_mask, 6, "Arrow should collide with enemies and walls")


## Test: Arrow rotates to face direction
func test_arrow_rotation() -> void:
	arrow.direction = Vector2.RIGHT
	arrow._ready()
	assert_almost_eq(arrow.rotation, 0.0, 0.1, "Arrow should face right")

	arrow.direction = Vector2.DOWN
	arrow._ready()
	assert_almost_eq(arrow.rotation, PI/2, 0.1, "Arrow should face down")


## Test: Arrow default damage is 25
func test_arrow_damage() -> void:
	assert_eq(arrow.damage, 25, "Arrow should deal 25 damage")


## Test: Arrow default speed is 600
func test_arrow_speed() -> void:
	assert_eq(arrow.speed, 600.0, "Arrow should travel at 600 px/sec")


## Test: Arrow despawns after lifetime
func test_arrow_lifetime_despawn() -> void:
	# Track initial position
	var initial_pos = arrow.global_position

	# Wait for lifetime + buffer
	await wait_seconds(3.2)

	# Arrow should be freed
	assert_freed(arrow, "Arrow should despawn after 3 seconds")


## Test: Arrow moves in direction at speed
func test_arrow_movement() -> void:
	arrow.direction = Vector2.RIGHT
	arrow.speed = 600.0

	var initial_pos = arrow.global_position.x

	# Wait 0.1 seconds
	await wait_seconds(0.1)

	# Should have moved ~60 pixels (600 * 0.1)
	var distance_moved = arrow.global_position.x - initial_pos
	assert_almost_eq(distance_moved, 60.0, 10.0, "Arrow should move ~60px in 0.1s at 600px/s")


## Test: Arrow moves in correct direction
func test_arrow_moves_up() -> void:
	arrow.direction = Vector2.UP
	var initial_y = arrow.global_position.y

	await wait_seconds(0.1)

	# Y should decrease (moving up)
	assert_lt(arrow.global_position.y, initial_y, "Arrow should move up when direction is UP")
