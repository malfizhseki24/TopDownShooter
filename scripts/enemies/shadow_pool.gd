class_name ShadowPool
extends Area2D
## Spawn point for shadow enemies. Detects player proximity and spawns enemies
## from a random pool at regular intervals.
##
## Usage: Place in level, configure enemy_scenes with enemy types to spawn.
## Enemies spawn when player enters detection area, respecting global MAX_ENEMIES.

## Emitted when an enemy is spawned from this pool
signal enemy_spawned(enemy: Node)

@export_group("Spawn Settings")
## Enemy scenes to randomly spawn from this pool
@export var enemy_scenes: Array[PackedScene] = []
## Maximum enemies this pool can have active at once
@export var max_local_spawn: int = 3
## Seconds between spawn attempts
@export var spawn_interval: float = 3.0
## How close player must be to trigger spawning (set collision shape radius in scene)
@export var detection_radius: float = 300.0

## Random offset range for spawn position
@export var spawn_offset_range: float = 50.0

# State
var _is_player_nearby: bool = false
var _spawn_timer: float = 0.0
var _active_enemies: Array[Node] = []


func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Clean up dead enemies from tracking
	EventBus.enemy_died.connect(_on_enemy_died)


func _process(delta: float) -> void:
	if not _is_player_nearby:
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_try_spawn()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_is_player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_is_player_nearby = false


func _on_enemy_died(enemy: Node) -> void:
	if enemy in _active_enemies:
		_active_enemies.erase(enemy)


func _try_spawn() -> void:
	# Check global limit
	if not GameManager.can_spawn_enemy():
		return

	# Check local limit (remove null references first)
	_active_enemies = _active_enemies.filter(func(e): return is_instance_valid(e))
	if _active_enemies.size() >= max_local_spawn:
		return

	# Check if we have scenes to spawn
	if enemy_scenes.is_empty():
		return

	# Pick random enemy
	var enemy_scene: PackedScene = enemy_scenes.pick_random()
	if enemy_scene == null:
		return

	# Spawn enemy with random offset
	var enemy := enemy_scene.instantiate()
	enemy.hide()  # Hide first to prevent flash
	var offset := Vector2(
		randf_range(-spawn_offset_range, spawn_offset_range),
		randf_range(-spawn_offset_range, spawn_offset_range)
	)
	enemy.global_position = global_position + offset

	# Add to scene tree
	get_tree().current_scene.add_child(enemy)

	# Show after spawn is complete (deferred to ensure animation is ready)
	enemy.call_deferred(&"show")
	_active_enemies.append(enemy)

	# Emit local signal (enemy emits global enemy_spawned in its _ready)
	enemy_spawned.emit(enemy)


## Force spawn an enemy immediately (ignores timers, respects limits)
func force_spawn() -> Node:
	if not GameManager.can_spawn_enemy():
		return null

	_active_enemies = _active_enemies.filter(func(e): return is_instance_valid(e))
	if _active_enemies.size() >= max_local_spawn:
		return null

	if enemy_scenes.is_empty():
		return null

	var enemy_scene: PackedScene = enemy_scenes.pick_random()
	if enemy_scene == null:
		return null

	var enemy := enemy_scene.instantiate()
	enemy.hide()  # Hide first to prevent flash
	var offset := Vector2(
		randf_range(-spawn_offset_range, spawn_offset_range),
		randf_range(-spawn_offset_range, spawn_offset_range)
	)
	enemy.global_position = global_position + offset

	get_tree().current_scene.add_child(enemy)

	# Show after spawn is complete (deferred to ensure animation is ready)
	enemy.call_deferred(&"show")
	_active_enemies.append(enemy)

	# Emit local signal (enemy emits global enemy_spawned in its _ready)
	enemy_spawned.emit(enemy)

	return enemy
