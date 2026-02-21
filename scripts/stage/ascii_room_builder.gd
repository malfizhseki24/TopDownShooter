class_name AsciiRoomBuilder
## Parses ASCII map strings into TileMapLayer terrain + entity positions.
## Uses Godot's Wang terrain auto-tiling for automatic wall/floor transitions.
##
## Usage:
##   var result := AsciiRoomBuilder.build_room(ascii_map, tileset)
##   parent.add_child(result.tile_layer)
##   player.global_position = result.player_spawn

## Terrain indices matching the TileSet terrain setup (floor=0, wall=1)
const TERRAIN_FLOOR: int = 0
const TERRAIN_WALL: int = 1

## ASCII legend characters
const CHAR_WALL := "#"
const CHAR_FLOOR := "."
const CHAR_PLAYER := "P"
const CHAR_ENEMY := "E"
const CHAR_BOSS := "B"
const CHAR_SHRINE := "S"
const CHAR_PORTAL := "X"
const CHAR_OBSTACLE := "O"

## Characters that produce floor terrain underneath
const FLOOR_CHARS := [CHAR_FLOOR, CHAR_PLAYER, CHAR_ENEMY, CHAR_BOSS, CHAR_SHRINE, CHAR_PORTAL, CHAR_OBSTACLE]


## Build a room from an ASCII map string and a TileSet resource.
## Returns a Dictionary with:
##   tile_layer: TileMapLayer — painted terrain node (add to scene tree)
##   player_spawn: Vector2 — world position of P marker
##   enemy_spawns: Array[Vector2] — world positions of E markers
##   portal_position: Vector2 — world position of X marker
##   shrine_position: Vector2 — world position of S marker (Vector2.ZERO if none)
##   boss_spawn: Vector2 — world position of B marker (Vector2.ZERO if none)
##   obstacle_positions: Array[Vector2] — world positions of O markers
##   width: int — map width in tiles
##   height: int — map height in tiles
static func build_room(map_string: String, tileset: TileSet) -> Dictionary:
	# Step 1: Parse ASCII to grid
	var parsed := _parse_ascii(map_string)
	var grid: Array = parsed.grid
	var width: int = parsed.width
	var height: int = parsed.height

	# Step 2: Classify cells
	var classified := _classify_cells(grid, width, height)
	var wall_cells: Array[Vector2i] = classified.wall_cells
	var floor_cells: Array[Vector2i] = classified.floor_cells

	# Step 3: Add border padding for clean Wang edges
	_add_border_padding(wall_cells, width, height)

	# Step 4: Create TileMapLayer and paint terrain
	var tile_layer := TileMapLayer.new()
	tile_layer.name = "TileLayer"
	tile_layer.tile_set = tileset
	_paint_terrain(tile_layer, wall_cells, floor_cells)

	# Step 5: Convert entity positions to world coordinates
	var result := {
		"tile_layer": tile_layer,
		"player_spawn": _tile_to_world(classified.player_spawn, tile_layer),
		"enemy_spawns": _tiles_to_world(classified.enemy_spawns, tile_layer),
		"portal_position": _tile_to_world(classified.portal_position, tile_layer),
		"shrine_position": _tile_to_world(classified.shrine_position, tile_layer),
		"boss_spawn": _tile_to_world(classified.boss_spawn, tile_layer),
		"obstacle_positions": _tiles_to_world(classified.obstacle_positions, tile_layer),
		"width": width,
		"height": height,
	}

	return result


## Parse a multiline ASCII string into a 2D grid of characters.
static func _parse_ascii(map_string: String) -> Dictionary:
	var lines := map_string.split("\n")

	# Remove empty leading/trailing lines
	while lines.size() > 0 and lines[0].strip_edges().is_empty():
		lines.remove_at(0)
	while lines.size() > 0 and lines[lines.size() - 1].strip_edges().is_empty():
		lines.remove_at(lines.size() - 1)

	# Determine dimensions
	var height := lines.size()
	var width := 0
	for line in lines:
		width = maxi(width, line.length())

	# Build 2D grid (pad shorter lines with spaces)
	var grid: Array = []
	for y in range(height):
		var row: Array = []
		var line: String = lines[y] if y < lines.size() else ""
		for x in range(width):
			if x < line.length():
				row.append(line[x])
			else:
				row.append(" ")
		grid.append(row)

	return {"grid": grid, "width": width, "height": height}


## Classify each cell in the grid into walls, floors, and entity positions.
static func _classify_cells(grid: Array, width: int, height: int) -> Dictionary:
	var wall_cells: Array[Vector2i] = []
	var floor_cells: Array[Vector2i] = []
	var player_spawn := Vector2i(-1, -1)
	var enemy_spawns: Array[Vector2i] = []
	var boss_spawn := Vector2i(-1, -1)
	var shrine_position := Vector2i(-1, -1)
	var portal_position := Vector2i(-1, -1)
	var obstacle_positions: Array[Vector2i] = []

	for y in range(height):
		for x in range(width):
			var ch: String = grid[y][x]
			var cell := Vector2i(x, y)

			if ch == CHAR_WALL:
				wall_cells.append(cell)
			elif ch in FLOOR_CHARS:
				floor_cells.append(cell)

				# Also store entity positions
				match ch:
					CHAR_PLAYER:
						player_spawn = cell
					CHAR_ENEMY:
						enemy_spawns.append(cell)
					CHAR_BOSS:
						boss_spawn = cell
					CHAR_SHRINE:
						shrine_position = cell
					CHAR_PORTAL:
						portal_position = cell
					CHAR_OBSTACLE:
						obstacle_positions.append(cell)
			# Space = void, skip

	return {
		"wall_cells": wall_cells,
		"floor_cells": floor_cells,
		"player_spawn": player_spawn,
		"enemy_spawns": enemy_spawns,
		"boss_spawn": boss_spawn,
		"shrine_position": shrine_position,
		"portal_position": portal_position,
		"obstacle_positions": obstacle_positions,
	}


## Add a 1-tile border of wall cells around the map for clean Wang terrain edges.
static func _add_border_padding(wall_cells: Array[Vector2i], width: int, height: int) -> void:
	# Top and bottom borders (including corners)
	for x in range(-1, width + 1):
		wall_cells.append(Vector2i(x, -1))
		wall_cells.append(Vector2i(x, height))

	# Left and right borders (excluding corners already added)
	for y in range(0, height):
		wall_cells.append(Vector2i(-1, y))
		wall_cells.append(Vector2i(width, y))


## Paint terrain onto a TileMapLayer using Wang auto-tiling.
static func _paint_terrain(layer: TileMapLayer, wall_cells: Array[Vector2i], floor_cells: Array[Vector2i]) -> void:
	# Paint walls first (all borders + interior walls)
	if wall_cells.size() > 0:
		layer.set_cells_terrain_connect(wall_cells, 0, TERRAIN_WALL, false)

	# Paint floors second (overwrites walls where floor exists)
	if floor_cells.size() > 0:
		layer.set_cells_terrain_connect(floor_cells, 0, TERRAIN_FLOOR, false)


## Convert a single tile coordinate to world position via the TileMapLayer.
static func _tile_to_world(tile_pos: Vector2i, layer: TileMapLayer) -> Vector2:
	if tile_pos.x < 0 or tile_pos.y < 0:
		return Vector2.ZERO
	return layer.map_to_local(tile_pos)


## Convert an array of tile coordinates to world positions.
static func _tiles_to_world(tile_positions: Array[Vector2i], layer: TileMapLayer) -> Array[Vector2]:
	var world_positions: Array[Vector2] = []
	for tile_pos in tile_positions:
		world_positions.append(layer.map_to_local(tile_pos))
	return world_positions
