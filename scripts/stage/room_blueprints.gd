class_name RoomBlueprints
## Central data store for all room ASCII maps, enemy wave configs, and metadata.
## Edit the ASCII strings below to redesign rooms without touching the Godot Editor.
##
## Legend:
##   # = Wall (TERRAIN_WALL, has collision)
##   . = Floor (TERRAIN_FLOOR, walkable)
##   P = Player Spawn (floor underneath, position stored)
##   E = Enemy Spawn (floor underneath, position stored)
##   B = Boss Spawn (floor underneath, position stored)
##   S = Heal Shrine (floor underneath, shrine instantiated)
##   X = Exit Portal (floor underneath, position stored)
##   O = Obstacle/Decoration (floor underneath, destructible instantiated)
##   (space) = Void (no tile placed)


# ──────────────────────────────────────────────────────────────────────────────
# Room 1: Tutorial Combat (15x11)
# 3x Shadow Wisp — open layout, obstacles near spawn for target practice
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_1_MAP := """
###############
#......X......#
#.............#
#...E.....E...#
#.............#
#.............#
#.O...........#
#..O..E...O...#
#.O.......O...#
#...O..P..O...#
###############"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 2: Mixed Combat (17x11)
# 2x Wisp + 2x Crawler — interior wall blocks create cover lanes
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_2_MAP := """
#################
#.......X.......#
#...............#
#..E.........O..#
#.....####......#
#...............#
#......####.....#
#.O..........E..#
#..E.........E..#
#..O.....P...O..#
#################"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 3: Heal Shrine (15x9)
# Rest point — peaceful room with decorations and shrine
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_3_MAP := """
###############
#......X......#
#.............#
#..O.......O..#
#......S......#
#..O.......O..#
#.............#
#......P......#
###############"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 4: Stalker Introduced (17x13)
# 2x Wisp + 2x Crawler + 1x Stalker — pillar pairs for cover from teleports
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_4_MAP := """
#################
#.......X.......#
#...............#
#..E.........E..#
#....##...##....#
#.O.............#
#.......E.......#
#.............O.#
#....##...##....#
#..E..O......E..#
#...............#
#.......P.......#
#################"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 5: All Enemy Types (19x13)
# 3x Crawler + 2x Stalker + 1x Brute — wide arena with scattered cover
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_5_MAP := """
###################
#........X........#
#.................#
#..E..O........E..#
#....##.....##....#
#.................#
#..E....O....E....#
#.................#
#....##.....##....#
#..E........O..E..#
#.................#
#........P........#
###################"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 6: Pre-Boss Heal (15x9)
# Rest before boss — same structure as Room 3
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_6_MAP := """
###############
#......X......#
#.............#
#..O.......O..#
#......S......#
#..O.......O..#
#.............#
#......P......#
###############"""


# ──────────────────────────────────────────────────────────────────────────────
# Room 7: Boss Arena (21x15)
# Shadow Boar — large open arena with corner pillars for charge attacks
# ──────────────────────────────────────────────────────────────────────────────
const ROOM_7_MAP := """
#####################
#.........X.........#
#...................#
#..O.............O..#
#...................#
#...................#
#.........B.........#
#...................#
#...................#
#...................#
#..O.............O..#
#...................#
#...................#
#.........P.........#
#####################"""


# ──────────────────────────────────────────────────────────────────────────────
# Room configuration dictionary
# Keys are room indices (0-6), values contain map, type, tileset, and waves
# ──────────────────────────────────────────────────────────────────────────────
const DEFAULT_TILESET := "res://assets/tilesets/jungle_ruins.tres"

const ROOMS: Dictionary = {
	0: {
		"map": ROOM_1_MAP,
		"type": "combat",
		"tileset": DEFAULT_TILESET,
		"waves": [
			{"enemy_type": &"shadow_wisp", "count": 3, "spawn_delay": 0.5, "wave_delay": 0.0}
		]
	},
	1: {
		"map": ROOM_2_MAP,
		"type": "combat",
		"tileset": DEFAULT_TILESET,
		"waves": [
			{"enemy_type": &"shadow_wisp", "count": 2, "spawn_delay": 0.5, "wave_delay": 0.0},
			{"enemy_type": &"shadow_crawler", "count": 2, "spawn_delay": 0.5, "wave_delay": 2.0}
		]
	},
	2: {
		"map": ROOM_3_MAP,
		"type": "heal",
		"tileset": DEFAULT_TILESET,
		"waves": []
	},
	3: {
		"map": ROOM_4_MAP,
		"type": "combat",
		"tileset": DEFAULT_TILESET,
		"waves": [
			{"enemy_type": &"shadow_wisp", "count": 2, "spawn_delay": 0.5, "wave_delay": 0.0},
			{"enemy_type": &"shadow_crawler", "count": 2, "spawn_delay": 0.5, "wave_delay": 1.5},
			{"enemy_type": &"shadow_stalker", "count": 1, "spawn_delay": 0.0, "wave_delay": 3.0}
		]
	},
	4: {
		"map": ROOM_5_MAP,
		"type": "combat",
		"tileset": DEFAULT_TILESET,
		"waves": [
			{"enemy_type": &"shadow_crawler", "count": 3, "spawn_delay": 0.5, "wave_delay": 0.0},
			{"enemy_type": &"shadow_stalker", "count": 2, "spawn_delay": 0.5, "wave_delay": 2.0},
			{"enemy_type": &"shadow_brute", "count": 1, "spawn_delay": 0.0, "wave_delay": 4.0}
		]
	},
	5: {
		"map": ROOM_6_MAP,
		"type": "heal",
		"tileset": DEFAULT_TILESET,
		"waves": []
	},
	6: {
		"map": ROOM_7_MAP,
		"type": "boss",
		"tileset": DEFAULT_TILESET,
		"waves": []
	}
}


## Get a room blueprint by index
static func get_room(index: int) -> Dictionary:
	if ROOMS.has(index):
		return ROOMS[index]
	push_error("RoomBlueprints: No room at index %d" % index)
	return {}


## Get total number of rooms
static func get_total_rooms() -> int:
	return ROOMS.size()
