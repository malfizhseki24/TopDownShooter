# Tasks: Create Jungle Tileset

## 1. PixelLab Generation

- [x] 1.1 Queue top-down tileset generation via `create_topdown_tileset`
- [x] 1.2 Configure parameters (lower: jungle floor, upper: stone ruins, 32x32)
- [x] 1.3 Poll status with `get_topdown_tileset` until complete
- [x] 1.4 Download tileset PNG to `assets/sprites/tiles/jungle_tileset.png`

**Tileset ID:** `7eb89610-ca96-45d9-bea8-cd135cd08175`
**Downloaded:** 16 tiles (128x128 PNG)

## 2. Godot Import

- [x] 2.1 Create `assets/sprites/tiles/` folder if not exists
- [ ] 2.2 Import tileset PNG to Godot
- [ ] 2.3 Set texture filter to Nearest
- [ ] 2.4 Disable mipmaps

**Status:** Folder created, Godot scanned file (.import exists)

## 3. TileSet Resource Creation

- [ ] 3.1 Create new TileSet resource (`jungle_tileset.tres`)
- [ ] 3.2 Set tile size to 32x32
- [ ] 3.3 Define tiles from spritesheet (identify ground vs wall tiles)
- [ ] 3.4 Add collision polygons to wall tiles only
- [ ] 3.5 Set wall collision to physics layer 4
- [ ] 3.6 Leave ground tiles without collision

**Status:** Not started (requires Godot editor)

## 4. Test Level TileMap

- [ ] 4.1 Open or create `TestLevel.tscn`
- [ ] 4.2 Add TileMap node with jungle_tileset
- [ ] 4.3 Paint ground tiles (fill level area)
- [ ] 4.4 Paint wall tiles (perimeter + internal walls)
- [ ] 4.5 Verify collision works with player placeholder

**Status:** Not started

## 5. Verification

- [ ] 5.1 Tiles render at correct size (32x32)
- [ ] 5.2 No visible seams between tiles
- [ ] 5.3 Ground tiles are walkable
- [ ] 5.4 Wall tiles block movement
- [ ] 5.5 Pixel-perfect rendering at 4x scale

**Status:** Not started
