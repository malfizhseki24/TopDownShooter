@tool
extends SceneTree
## PixelLab to Godot Tileset Converter
## Converts PixelLab metadata JSON + PNG sprite sheets to Godot terrain system
## Usage: godot --headless -s pixellab_tileset_converter.gd metadata.json image.png [output_name]

var output_path := "res://assets/tilesets/converted_tileset.tres"
const TILE_SIZE := 32

# Corner-based tile layout for Godot terrain painting
# Format: "nw,ne/sw,se" where w=wall(upper), f=floor(lower)
var corner_layout := [
	# Row 0
	"ff/fw", "ff/ww", "ff/wf", "ww/wf", "ww/fw",
	# Row 1
	"fw/fw", "ww/ww", "wf/wf", "wf/ww", "fw/ww",
	# Row 2
	"fw/ff", "ww/ff", "wf/ff", "wf/fw", "fw/wf",
	# Row 3
	"ww/ww", "ff/ff", "", "", ""
]

var terrains := {}
var tiles := []

func _init():
	print("\n🎨 PixelLab to Godot Converter")
	print("================================")

	var args := OS.get_cmdline_args()
	var json_path := ""
	var png_path := ""
	var output_name := ""

	# Find JSON and PNG files in arguments
	for i in range(args.size()):
		if args[i].ends_with("_metadata.json") or args[i].ends_with(".json"):
			json_path = args[i]
		elif args[i].ends_with(".png"):
			png_path = args[i]
		elif not args[i].contains(".") and not args[i].begins_with("--"):
			output_name = args[i]

	# Default paths if not provided
	if json_path == "":
		json_path = "res://assets/tilesets/jungle_ruins_metadata.json"
	if png_path == "":
		png_path = "res://assets/tilesets/jungle_ruins_tileset.png"

	# Set output path based on output_name or derive from json filename
	if output_name != "":
		output_path = "res://assets/tilesets/%s.tres" % output_name
	else:
		# Derive from json filename (e.g., swamp_water_metadata.json -> swamp_water.tres)
		var basename := json_path.get_file().replace("_metadata.json", "").replace(".json", "")
		output_path = "res://assets/tilesets/%s.tres" % basename

	print("📁 Loading: %s + %s" % [json_path, png_path])

	load_tileset(json_path, png_path)

	if tiles.is_empty():
		print("❌ No tiles loaded")
		quit()
		return

	create_tileset()
	print("\n✅ Created: %s" % output_path)
	quit()


func load_tileset(json_path: String, png_path: String):
	# Read metadata JSON
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("❌ Cannot open JSON: %s" % json_path)
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("❌ Invalid JSON")
		return
	file.close()

	var metadata = json.data

	# Load PNG sprite sheet
	var image := Image.new()
	var err := image.load(png_path)
	if err != OK:
		print("❌ Cannot load PNG: %s (error %d)" % [png_path, err])
		return

	print("  Image size: %dx%d" % [image.get_width(), image.get_height()])

	# Get terrain names
	var lower_name_raw: Variant = metadata.get("lower_description", "floor")
	var upper_name_raw: Variant = metadata.get("upper_description", "wall")
	var lower_name: String = simplify_name(str(lower_name_raw))
	var upper_name: String = simplify_name(str(upper_name_raw))

	var lower_id := get_terrain_id(lower_name)
	var upper_id := get_terrain_id(upper_name)

	print("  Terrains: %s (0), %s (1)" % [lower_name, upper_name])

	# Index tiles by Wang corners
	var wang_tiles := {}
	var tiles_data = metadata.get("tileset_data", {}).get("tiles", [])

	for tile in tiles_data:
		var corners = tile.get("corners", {})
		var bbox = tile.get("bounding_box", {})

		var x: int = bbox.get("x", 0)
		var y: int = bbox.get("y", 0)
		var width: int = bbox.get("width", TILE_SIZE)
		var height: int = bbox.get("height", TILE_SIZE)

		# Extract tile image
		var tile_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
		tile_image.blit_rect(image, Rect2i(x, y, width, height), Vector2i.ZERO)

		# Calculate Wang index from corners
		var nw := 1 if corners.get("NW", "lower") == "upper" else 0
		var ne := 1 if corners.get("NE", "lower") == "upper" else 0
		var sw := 1 if corners.get("SW", "lower") == "upper" else 0
		var se := 1 if corners.get("SE", "lower") == "upper" else 0
		var wang_idx := nw * 8 + ne * 4 + sw * 2 + se

		wang_tiles[wang_idx] = {
			"image": tile_image,
			"corners": [
				upper_id if nw == 1 else lower_id,
				upper_id if ne == 1 else lower_id,
				upper_id if sw == 1 else lower_id,
				upper_id if se == 1 else lower_id
			]
		}

	print("  Loaded %d Wang tiles" % wang_tiles.size())

	# Arrange tiles in corner pattern layout
	for pattern in corner_layout:
		if pattern == "":
			tiles.append(null)
			continue

		var parts: Array = pattern.split("/")
		var top: String = parts[0]
		var bottom: String = parts[1]

		# Convert to Wang index (w=wall/upper=1, f=floor/lower=0)
		var nw := 1 if top[0] == "w" else 0
		var ne := 1 if top[1] == "w" else 0
		var sw := 1 if bottom[0] == "w" else 0
		var se := 1 if bottom[1] == "w" else 0
		var wang_idx := nw * 8 + ne * 4 + sw * 2 + se

		if wang_tiles.has(wang_idx):
			tiles.append(wang_tiles[wang_idx])
		else:
			tiles.append(null)


func simplify_name(name: String) -> String:
	# Extract first few words for cleaner terrain names
	var words := name.split(" ")
	if words.size() >= 2:
		return words[0] + "_" + words[1]
	return name.replace(" ", "_")


func get_terrain_id(name: String) -> int:
	for id in terrains:
		if terrains[id] == name:
			return id
	var id := terrains.size()
	terrains[id] = name
	return id


func create_tileset():
	print("\n🔨 Creating tileset...")

	const COLS := 5
	var rows := (tiles.size() + COLS - 1) / COLS

	# Create atlas image
	var atlas := Image.create(COLS * TILE_SIZE, rows * TILE_SIZE, false, Image.FORMAT_RGBA8)

	# Place tiles in atlas
	for i in range(tiles.size()):
		if tiles[i] == null:
			continue

		var img: Image = tiles[i].image
		var x := (i % COLS) * TILE_SIZE
		var y := (i / COLS) * TILE_SIZE
		atlas.blit_rect(img, Rect2i(0, 0, TILE_SIZE, TILE_SIZE), Vector2i(x, y))

	# Save preview PNG
	var preview_path := output_path.replace(".tres", "_atlas.png")
	atlas.save_png(preview_path)
	print("  Preview: %s" % preview_path)

	# Build terrain color definitions
	var terrain_colors := {}

	# Find base tiles and extract colors
	for i in range(tiles.size()):
		if tiles[i] == null:
			continue
		var corners: Array = tiles[i].corners
		# Check if all corners same (base tile)
		if corners[0] == corners[1] and corners[1] == corners[2] and corners[2] == corners[3]:
			var terrain_id: int = corners[0]
			if not terrain_colors.has(terrain_id):
				var img: Image = tiles[i].image
				var center := Vector2i(img.get_width() / 2, img.get_height() / 2)
				terrain_colors[terrain_id] = img.get_pixel(center.x, center.y)

	# Generate tile definitions with collision for wall tiles
	# WALL_TERRAIN_ID = 1 (upper/stone)
	const WALL_TERRAIN_ID := 1

	var tile_defs := []
	for i in range(tiles.size()):
		if tiles[i] == null:
			continue

		var x := i % COLS
		var y := i / COLS
		var corners: Array = tiles[i].corners

		tile_defs.append("%d:%d/0 = 0" % [x, y])
		tile_defs.append("%d:%d/0/terrain_set = 0" % [x, y])
		tile_defs.append("%d:%d/0/terrains_peering_bit/top_left_corner = %d" % [x, y, corners[0]])
		tile_defs.append("%d:%d/0/terrains_peering_bit/top_right_corner = %d" % [x, y, corners[1]])
		tile_defs.append("%d:%d/0/terrains_peering_bit/bottom_left_corner = %d" % [x, y, corners[2]])
		tile_defs.append("%d:%d/0/terrains_peering_bit/bottom_right_corner = %d" % [x, y, corners[3]])

		# Add collision if ANY corner is wall (terrain 1)
		# This creates collision where walls exist
		var has_wall: bool = false
		for corner in corners:
			if corner == WALL_TERRAIN_ID:
				has_wall = true
				break

		if has_wall:
			# Add full tile collision polygon (physics layer 0)
			tile_defs.append("%d:%d/0/physics_layer_0/polygon_0/points = PackedVector2Array(0, 0, 32, 0, 32, 32, 0, 32)" % [x, y])

	# Generate terrain definitions
	var terrain_defs := []
	for id in terrains:
		var name: String = terrains[id]
		var color: Color = terrain_colors.get(id, Color(0.5, 0.5, 0.5))
		terrain_defs.append('terrain_set_0/terrain_%d/name = "%s"' % [id, name])
		terrain_defs.append("terrain_set_0/terrain_%d/color = Color(%f, %f, %f, 1)" % [id, color.r, color.g, color.b])

	# Convert atlas to bytes
	var bytes := PackedByteArray()
	for b in atlas.get_data():
		bytes.append(b)

	var bytes_str := ""
	for i in range(bytes.size()):
		if i > 0:
			bytes_str += ", "
		bytes_str += str(bytes[i])

	# Write .tres file
	var tres := '[gd_resource type="TileSet" load_steps=4 format=3 uid="uid://c8jungleruins001"]\n\n'
	tres += '[sub_resource type="Image" id="Image_1"]\n'
	tres += "data = {\n"
	tres += '"data": PackedByteArray(%s),\n' % bytes_str
	tres += '"format": "RGBA8",\n'
	tres += '"height": %d,\n' % atlas.get_height()
	tres += '"mipmaps": false,\n'
	tres += '"width": %d\n' % atlas.get_width()
	tres += "}\n\n"
	tres += '[sub_resource type="ImageTexture" id="ImageTexture_1"]\n'
	tres += 'image = SubResource("Image_1")\n\n'
	tres += '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_1"]\n'
	tres += 'texture = SubResource("ImageTexture_1")\n'
	tres += "texture_region_size = Vector2i(%d, %d)\n" % [TILE_SIZE, TILE_SIZE]
	tres += "\n".join(tile_defs) + "\n\n"
	tres += "[resource]\n"
	tres += "tile_size = Vector2i(%d, %d)\n" % [TILE_SIZE, TILE_SIZE]
	# Add physics layer for collision - Layer 4 = wall (value 8)
	tres += "physics_layer_0/collision_layer = 8\n"
	tres += "terrain_set_0/mode = 0\n"
	tres += "\n".join(terrain_defs) + "\n"
	tres += 'sources/0 = SubResource("TileSetAtlasSource_1")\n'

	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string(tres)
		file.close()
		print("  TileSet: %s" % output_path)
	else:
		print("❌ Cannot write to: %s" % output_path)
