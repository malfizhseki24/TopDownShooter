@tool
class_name RoomPreview
extends Node2D
## @tool script for previewing ASCII room layouts in the Godot editor.
## Attach to a Node2D, set room_index and tileset, then toggle build_room.

## Which room to preview (0-6)
@export_range(0, 6) var room_index: int = 0

## TileSet resource for terrain painting
@export var tileset: TileSet

## Toggle this to generate the room in the editor viewport
@export var build_room: bool = false:
	set(value):
		if value:
			if Engine.is_editor_hint():
				_preview_room()
			build_room = false


func _preview_room() -> void:
	if tileset == null:
		push_warning("RoomPreview: No tileset assigned!")
		return

	# Clear previous preview
	for child in get_children():
		child.queue_free()

	# Get room blueprint
	var blueprint := RoomBlueprints.get_room(room_index)
	if blueprint.is_empty():
		push_warning("RoomPreview: No blueprint for room %d" % room_index)
		return

	# Build room using ASCII builder
	var result := AsciiRoomBuilder.build_room(blueprint.map, tileset)

	# Add the TileMapLayer
	add_child(result.tile_layer)
	result.tile_layer.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self

	# Add marker nodes for entity positions (visual reference in editor)
	_add_marker("PlayerSpawn", result.player_spawn, Color.GREEN)
	_add_marker("PortalSpawn", result.portal_position, Color.CYAN)
	_add_marker("BossSpawn", result.boss_spawn, Color.RED)
	_add_marker("ShrinePosition", result.shrine_position, Color.YELLOW)

	for i in range(result.enemy_spawns.size()):
		_add_marker("EnemySpawn%d" % (i + 1), result.enemy_spawns[i], Color.ORANGE_RED)

	for i in range(result.obstacle_positions.size()):
		_add_marker("Obstacle%d" % (i + 1), result.obstacle_positions[i], Color.SADDLE_BROWN)

	print("RoomPreview: Built room %d (%dx%d tiles)" % [room_index, result.width, result.height])


func _add_marker(marker_name: String, pos: Vector2, color: Color) -> void:
	if pos == Vector2.ZERO:
		return

	var marker := Marker2D.new()
	marker.name = marker_name
	marker.position = pos
	marker.modulate = color
	add_child(marker)
	marker.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
