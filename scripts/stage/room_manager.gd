class_name RoomManager
extends Node
## Manages linear room progression using ASCII-defined room blueprints.
## Builds rooms from text at runtime using AsciiRoomBuilder.

## TileSet for terrain painting
@export var tileset: TileSet

## Signals
signal room_loaded(room_index: int)
signal room_cleared(room_index: int)
signal all_rooms_cleared

## Runtime state
var current_room_index: int = -1
var current_room_type: String = ""
var is_room_cleared: bool = false
var enemies_in_room: int = 0
var _room_generation: int = 0  ## Incremented each load_room; stale coroutines check this

## Wave tracking
var _waves: Array[Dictionary] = []
var _wave_spawn_positions: Array[Vector2] = []
var _current_wave_index: int = 0
var _all_waves_spawned: bool = true
var _spawn_generation: int = 0  ## Cancels stale spawn coroutines when a new wave starts

## Current room tile layer (generated from ASCII)
var _current_tile_layer: TileMapLayer = null

## Positions from the current room build
var _player_spawn: Vector2 = Vector2(320, 533)
var _portal_position: Vector2 = Vector2.ZERO
var _shrine_position: Vector2 = Vector2.ZERO
var _boss_spawn: Vector2 = Vector2.ZERO
var _enemy_spawns: Array[Vector2] = []
var _obstacle_positions: Array[Vector2] = []

## Node references (set by parent via set_entities_node / set_interactables_node)
var entities_node: Node2D = null
var interactables_node: Node2D = null
var navigation_region: NavigationRegion2D = null

## Enemy scenes
var enemy_scenes: Dictionary = {}

## Portal scene reference
var portal_scene: PackedScene = null

## Heal shrine scene reference
var heal_shrine_scene: PackedScene = null

## Obstacle pillar scene reference (legacy fallback)
var obstacle_scene: PackedScene = null

## Destructible scenes by type
var destructible_scenes: Dictionary = {}

## Vegetation scenes (decorative, no collision)
var vegetation_scenes: Dictionary = {}


func _ready() -> void:
	_load_scenes()
	_connect_signals()


func _load_scenes() -> void:
	enemy_scenes = {
		&"shadow_wisp": preload("res://scenes/enemies/shadow_wisp.tscn"),
		&"shadow_crawler": preload("res://scenes/enemies/shadow_crawler.tscn"),
		&"shadow_stalker": preload("res://scenes/enemies/shadow_stalker.tscn"),
		&"shadow_brute": preload("res://scenes/enemies/shadow_brute.tscn"),
		&"shadow_boar": preload("res://scenes/boss/shadow_boar.tscn"),
	}

	var portal_path := "res://scenes/interactables/room_portal.tscn"
	var shrine_path := "res://scenes/interactables/heal_shrine.tscn"

	if ResourceLoader.exists(portal_path):
		portal_scene = load(portal_path)
	if ResourceLoader.exists(shrine_path):
		heal_shrine_scene = load(shrine_path)

	var obstacle_path := "res://scenes/interactables/obstacle_pillar.tscn"
	if ResourceLoader.exists(obstacle_path):
		obstacle_scene = load(obstacle_path)

	# Load destructible scenes
	var _destructible_paths := {
		"ancient_pot": "res://scenes/interactables/ancient_pot.tscn",
		"shadow_pillar": "res://scenes/interactables/shadow_pillar.tscn",
		"corrupted_root": "res://scenes/interactables/corrupted_root.tscn",
		"bone_totem": "res://scenes/interactables/bone_totem.tscn",
	}
	for key in _destructible_paths:
		var path: String = _destructible_paths[key]
		if ResourceLoader.exists(path):
			destructible_scenes[key] = load(path)

	# Load vegetation scenes (decorative trees and bushes)
	var _vegetation_paths := {
		"sago_palm": "res://scenes/interactables/sago_palm.tscn",
		"rainforest_tree": "res://scenes/interactables/rainforest_tree.tscn",
		"mangrove": "res://scenes/interactables/mangrove.tscn",
		"fern_bush": "res://scenes/interactables/fern_bush.tscn",
	}
	for key in _vegetation_paths:
		var path: String = _vegetation_paths[key]
		if ResourceLoader.exists(path):
			vegetation_scenes[key] = load(path)


func _connect_signals() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.boss_died.connect(_on_boss_died)


## Load a specific room by index using ASCII blueprints
func load_room(room_index: int) -> void:
	if room_index >= RoomBlueprints.get_total_rooms():
		all_rooms_cleared.emit()
		return

	current_room_index = room_index
	is_room_cleared = false
	enemies_in_room = 0
	_room_generation += 1
	_waves.clear()
	_all_waves_spawned = true
	_current_wave_index = 0

	# Clear previous room
	_clear_room()

	# Get blueprint and build room from ASCII
	var blueprint := RoomBlueprints.get_room(room_index)
	if blueprint.is_empty():
		push_error("RoomManager: No blueprint for room %d" % room_index)
		return

	current_room_type = blueprint.get("type", "combat")

	# Use room-specific tileset or fall back to exported tileset
	var room_tileset := tileset
	var tileset_path: String = blueprint.get("tileset", "")
	if not tileset_path.is_empty() and ResourceLoader.exists(tileset_path):
		room_tileset = load(tileset_path)

	if room_tileset == null:
		push_error("RoomManager: No tileset available for room %d" % room_index)
		return

	# Build the room from ASCII
	var result := AsciiRoomBuilder.build_room(blueprint.map, room_tileset)

	# Store the tile layer
	_current_tile_layer = result.tile_layer
	_current_tile_layer.z_index = 0
	get_parent().add_child(_current_tile_layer)

	# Store positions from the build result
	_player_spawn = result.player_spawn
	_portal_position = result.portal_position
	_shrine_position = result.shrine_position
	_boss_spawn = result.boss_spawn
	_enemy_spawns = result.enemy_spawns
	_obstacle_positions = result.obstacle_positions

	# Setup navigation polygon for pathfinding
	_setup_navigation(result.navigation_polygon)

	# Spawn obstacles at O marker positions (all room types)
	_spawn_obstacles()

	# Spawn decorative vegetation (all room types)
	_spawn_vegetation()

	# Setup room based on type
	match current_room_type:
		"combat":
			_setup_combat_room(blueprint)
		"heal":
			_setup_heal_room()
		"boss":
			_setup_boss_room()

	room_loaded.emit(room_index)
	EventBus.room_loaded.emit(room_index)
	print("RoomManager: Loaded room %d (type: %s, %dx%d)" % [room_index, current_room_type, result.width, result.height])


## Clear all entities and interactables from current room
func _clear_room() -> void:
	# Clear enemies
	if entities_node:
		for child in entities_node.get_children():
			if child.is_in_group("enemy") or child.is_in_group("boss"):
				child.queue_free()

	# Clear interactables (portals, shrines)
	if interactables_node:
		for child in interactables_node.get_children():
			child.queue_free()

	# Clear tile layer
	if _current_tile_layer:
		_current_tile_layer.queue_free()
		_current_tile_layer = null


## Setup combat room - spawn enemy waves from blueprint
func _setup_combat_room(blueprint: Dictionary) -> void:
	var waves: Array = blueprint.get("waves", [])

	if waves.is_empty():
		_on_room_cleared()
		return

	# Store waves for sequential spawning
	_waves.clear()
	for w in waves:
		_waves.append(w)
	_wave_spawn_positions = _enemy_spawns
	_current_wave_index = 0
	_all_waves_spawned = false

	# Spawn the first wave
	_spawn_current_wave()


## Setup heal shrine room
func _setup_heal_room() -> void:
	if heal_shrine_scene == null:
		push_warning("RoomManager: Heal shrine scene not found!")
		_on_room_cleared()
		return

	if _shrine_position != Vector2.ZERO:
		var shrine := heal_shrine_scene.instantiate() as Node2D
		shrine.global_position = _shrine_position

		if interactables_node:
			interactables_node.add_child(shrine)

		print("RoomManager: Spawned heal shrine at %s" % str(_shrine_position))

	# Heal rooms are auto-cleared (no enemies to defeat)
	_on_room_cleared()


## Setup boss room
func _setup_boss_room() -> void:
	var boss_type := &"shadow_boar"

	var spawn_pos := _boss_spawn if _boss_spawn != Vector2.ZERO else Vector2(320, 160)
	_spawn_boss(boss_type, spawn_pos)


## Spawn the current wave's enemies. Called for wave 0 at room start,
## then for subsequent waves when the previous wave is defeated.
func _spawn_current_wave() -> void:
	if _current_wave_index >= _waves.size():
		_all_waves_spawned = true
		return

	# Increment spawn generation so any old coroutine from a previous wave stops
	_spawn_generation += 1
	var my_gen := _spawn_generation
	var room_gen := _room_generation
	var wave := _waves[_current_wave_index]

	# Brief pause before non-first waves for pacing
	if _current_wave_index > 0:
		await get_tree().create_timer(1.0).timeout
		if my_gen != _spawn_generation or room_gen != _room_generation:
			return

	var enemy_type: StringName = wave.get("enemy_type", &"shadow_wisp")
	var count: int = wave.get("count", 1)
	var spawn_delay: float = wave.get("spawn_delay", 0.5)

	for i in range(count):
		if my_gen != _spawn_generation or room_gen != _room_generation:
			return
		if _wave_spawn_positions.is_empty():
			push_warning("RoomManager: No spawn positions defined!")
			break

		var spawn_index := wrapi(i, 0, _wave_spawn_positions.size())
		var spawn_pos := _wave_spawn_positions[spawn_index]

		_spawn_enemy(enemy_type, spawn_pos)

		if i < count - 1 and spawn_delay > 0:
			await get_tree().create_timer(spawn_delay).timeout
			if my_gen != _spawn_generation or room_gen != _room_generation:
				return


## Spawn a single enemy
func _spawn_enemy(enemy_type: StringName, position: Vector2) -> void:
	if not enemy_scenes.has(enemy_type):
		push_warning("RoomManager: Unknown enemy type: %s" % enemy_type)
		return

	var enemy_scene: PackedScene = enemy_scenes[enemy_type]
	var enemy := enemy_scene.instantiate() as Node2D
	enemy.global_position = position

	if entities_node:
		entities_node.add_child(enemy)
		enemies_in_room += 1


## Spawn a boss enemy
func _spawn_boss(boss_type: StringName, position: Vector2) -> void:
	if not enemy_scenes.has(boss_type):
		push_warning("RoomManager: Unknown boss type: %s" % boss_type)
		return

	var boss_scene: PackedScene = enemy_scenes[boss_type]
	var boss := boss_scene.instantiate() as Node2D
	boss.global_position = position
	boss.add_to_group("boss")

	if entities_node:
		entities_node.add_child(boss)
		enemies_in_room += 1
		print("RoomManager: Spawned boss %s at %s" % [boss_type, str(position)])


## Spawn destructible props at O marker positions (type depends on room)
func _spawn_obstacles() -> void:
	if _obstacle_positions.is_empty():
		return

	for pos in _obstacle_positions:
		var scene: PackedScene = _get_destructible_scene_for_room()
		if scene == null:
			if obstacle_scene == null:
				continue
			scene = obstacle_scene
		var obj := scene.instantiate() as Node2D
		obj.global_position = pos
		if interactables_node:
			interactables_node.add_child(obj)

	print("RoomManager: Spawned %d destructibles" % _obstacle_positions.size())


## Get the appropriate destructible scene for the current room
func _get_destructible_scene_for_room() -> PackedScene:
	match current_room_type:
		"boss":
			return destructible_scenes.get("shadow_pillar")
		"heal":
			return destructible_scenes.get("bone_totem")
		"combat":
			# Tutorial room (index 0): pots for target practice
			if current_room_index == 0:
				return destructible_scenes.get("ancient_pot")
			# Later combat rooms: randomly pick between types
			var types := ["ancient_pot", "corrupted_root", "bone_totem"]
			var pick: String = types[randi() % types.size()]
			return destructible_scenes.get(pick)
	return null


## Called when a room is cleared
func _on_room_cleared() -> void:
	if is_room_cleared:
		return

	is_room_cleared = true
	room_cleared.emit(current_room_index)
	EventBus.room_cleared.emit(current_room_index)
	print("RoomManager: Room %d cleared!" % current_room_index)

	# Spawn portal to next room (if not final room)
	if current_room_index < RoomBlueprints.get_total_rooms() - 1:
		_spawn_portal()
	else:
		all_rooms_cleared.emit()


## Spawn portal to next room
func _spawn_portal() -> void:
	if portal_scene == null:
		push_warning("RoomManager: Portal scene not found!")
		return

	var portal_pos := _portal_position if _portal_position != Vector2.ZERO else Vector2(320, 107)

	# Check if portal_scene has RoomPortal class
	var portal := portal_scene.instantiate()
	portal.global_position = portal_pos

	if portal.has_method("set") and "next_room_index" in portal:
		portal.next_room_index = current_room_index + 1

	if interactables_node:
		_spawn_portal_deferred.call_deferred(portal)


func _spawn_portal_deferred(portal: Node2D) -> void:
	interactables_node.add_child(portal)
	if portal.has_method("activate"):
		portal.activate()
	print("RoomManager: Spawned portal at %s" % str(portal.global_position))


## Handle enemy death
func _on_enemy_died(enemy: Node) -> void:
	# Boss death is handled by _on_boss_died to avoid double-decrement
	if enemy.is_in_group("boss"):
		return

	enemies_in_room -= 1
	enemies_in_room = maxi(enemies_in_room, 0)

	if enemies_in_room == 0 and not is_room_cleared:
		# In boss rooms, only the boss dying clears the room (wisps don't count)
		if current_room_type == "boss":
			return
		if current_room_type == "combat":
			if _all_waves_spawned:
				# All waves done and all enemies dead — room clear
				_on_room_cleared()
			else:
				# Current wave defeated — advance to next wave
				_current_wave_index += 1
				_spawn_current_wave()
				# If that was the last wave, clear now
				if _all_waves_spawned and enemies_in_room == 0:
					_on_room_cleared()


## Handle boss death — only handler that clears boss rooms
func _on_boss_died(_boss: Node) -> void:
	enemies_in_room -= 1
	enemies_in_room = maxi(enemies_in_room, 0)

	if not is_room_cleared:
		_on_room_cleared()


## Get player spawn position for current room
func get_player_spawn_position() -> Vector2:
	return _player_spawn


## Get total rooms
func get_total_rooms() -> int:
	return RoomBlueprints.get_total_rooms()


## Check if current room is cleared
func is_current_room_cleared() -> bool:
	return is_room_cleared


## Set node references (called by game.gd)
func set_entities_node(node: Node2D) -> void:
	entities_node = node


func set_interactables_node(node: Node2D) -> void:
	interactables_node = node


func set_navigation_region(node: NavigationRegion2D) -> void:
	navigation_region = node


## Setup navigation polygon for the current room
func _setup_navigation(nav_polygon: NavigationPolygon) -> void:
	if navigation_region == null:
		push_warning("RoomManager: NavigationRegion2D not set, pathfinding disabled")
		return

	if nav_polygon == null:
		push_warning("RoomManager: No navigation polygon generated")
		return

	navigation_region.navigation_polygon = nav_polygon
	navigation_region.bake_navigation_polygon()
	print("RoomManager: Navigation polygon baked successfully")


## Spawn decorative vegetation in rooms to create jungle atmosphere
func _spawn_vegetation() -> void:
	if vegetation_scenes.is_empty():
		return

	# Tree types (no mangrove - stage 1 is deep forest, not near water)
	var tree_types := ["sago_palm", "rainforest_tree"]

	# Spawn 2-3 trees per room
	var tree_count := 2 + (randi() % 2)
	for i in range(tree_count):
		var pick: String = tree_types[randi() % tree_types.size()]
		var scene: PackedScene = vegetation_scenes.get(pick)
		if scene == null:
			continue

		var pos := _get_random_vegetation_position()
		var obj := scene.instantiate() as Node2D
		obj.global_position = pos
		obj.scale = Vector2(0.27, 0.27) * randf_range(0.8, 1.2)

		if interactables_node:
			interactables_node.add_child(obj)

	# Spawn 4-6 fern bushes (smaller but more numerous)
	var fern_scene: PackedScene = vegetation_scenes.get("fern_bush")
	if fern_scene:
		var fern_count := 4 + (randi() % 3)
		for i in range(fern_count):
			var pos := _get_random_vegetation_position()
			var obj := fern_scene.instantiate() as Node2D
			obj.global_position = pos
			# Fern bushes are 80% smaller than trees
			obj.scale = Vector2(0.05, 0.05) * randf_range(0.8, 1.2)

			if interactables_node:
				interactables_node.add_child(obj)

		print("RoomManager: Spawned %d trees and %d fern bushes" % [tree_count, 4 + (randi() % 3)])


## Get random position for vegetation (avoid center combat area)
func _get_random_vegetation_position() -> Vector2:
	var angle := randf() * TAU
	var dist := 107.0 + randf() * 80.0  # 107-187 pixels from center
	var pos := Vector2(320, 267) + Vector2(cos(angle), sin(angle)) * dist
	pos += Vector2(randf_range(-27, 27), randf_range(-27, 27))
	return pos
