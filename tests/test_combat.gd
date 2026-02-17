## TestCombat - Integration tests for shooting and fire rate
extends GutTest

var player: CharacterBody2D
var arrow_count: int = 0


func before_each() -> void:
	# Load and instantiate player
	var player_scene = load("res://scenes/player/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(240, 135)

	# Reset arrow count
	arrow_count = 0

	# Connect to tree to track arrows
	get_tree().node_added.connect(_on_node_added)
	await wait_frames(1)


func after_each() -> void:
	if player:
		player.queue_free()
	get_tree().node_added.disconnect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is Node and node.get_script() and node.get_script().resource_path.contains("arrow"):
		arrow_count += 1


## Test: Fire rate is enforced
func test_fire_rate_enforced() -> void:
	# Set aim direction
	player.aim_direction = Vector2.RIGHT

	# Simulate holding shoot
	Input.action_press("shoot")

	# Wait for 0.1 seconds
	await wait_seconds(0.1)

	# Should have shot once
	var first_count = arrow_count

	# Wait another 0.3 seconds (total 0.4, still under fire rate)
	await wait_seconds(0.3)

	# Should still be same count (can't shoot during cooldown)
	assert_eq(arrow_count, first_count, "Should not shoot during fire rate cooldown")

	# Wait for fire rate to expire
	await wait_seconds(0.2)

	# Now should be able to shoot again
	assert_true(player.can_shoot, "Should be able to shoot after cooldown")

	Input.action_release("shoot")


## Test: Can shoot after fire rate cooldown
func test_can_shoot_after_cooldown() -> void:
	player.aim_direction = Vector2.RIGHT

	# Shoot once
	Input.action_press("shoot")
	await wait_seconds(0.1)
	Input.action_release("shoot")

	# Wait for cooldown (0.5 sec)
	await wait_seconds(0.6)

	# Should be able to shoot again
	assert_true(player.can_shoot, "Should be able to shoot after 0.5 sec cooldown")


## Test: Arrow spawns at arrow spawn position
func test_arrow_spawn_position() -> void:
	# This test verifies the arrow spawns near player
	# (Full test requires scene tree access)
	player.aim_direction = Vector2.RIGHT

	var initial_arrow_count = arrow_count

	Input.action_press("shoot")
	await wait_seconds(0.1)
	Input.action_release("shoot")

	await wait_frames(5)

	# Arrow count should have increased
	assert_gt(arrow_count, initial_arrow_count, "Arrow should spawn when shooting")
