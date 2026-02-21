class_name DropSpawner
extends Node
## Handles drop table rolls and pickup spawning for destructibles.
## Registered as autoload for global access.

# Pickup scenes
static var _spirit_ember_scene: PackedScene = preload("res://scenes/interactables/spirit_ember.tscn")
static var _shadow_fragment_scene: PackedScene = preload("res://scenes/interactables/shadow_fragment.tscn")

# Drop table: 80% nothing, 15% Spirit Ember, 5% Shadow Fragment
const DROP_NOTHING_THRESHOLD: int = 80
const DROP_EMBER_THRESHOLD: int = 95  # 80-94 = ember


static func roll_drop(pos: Vector2) -> void:
	var roll := randi() % 100

	if roll < DROP_NOTHING_THRESHOLD:
		return  # Nothing drops

	var pickup: Node2D
	if roll < DROP_EMBER_THRESHOLD:
		pickup = _spirit_ember_scene.instantiate()
	else:
		pickup = _shadow_fragment_scene.instantiate()

	# Place at break position
	pickup.global_position = pos

	# Defer add_child to avoid "flushing queries" error when called from physics callbacks
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.current_scene.call_deferred("add_child", pickup)

		# Arc tween (deferred so pickup is in tree first)
		pickup.ready.connect(func():
			var start_y := pos.y
			pickup.global_position = pos
			var tween := pickup.create_tween()
			tween.tween_property(pickup, "global_position:y", start_y - 10.0, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(pickup, "global_position:y", start_y, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		)
