## Tasks: Scale to 720p Resolution

### Phase 1: Viewport & Tiles

- [x] **T1.1** Update project.godot viewport to 1280x720
  - Change `window/size/viewport_width=1280`
  - Change `window/size/viewport_height=720`
  - Verify stretch mode remains "viewport"

- [x] **T1.2** Regenerate tileset using PixelLab (32x32, scaled for 720p)
  - Generated new jungle_ruins_new tileset with create_topdown_tileset
  - Downloaded and converted to Godot format using pixellab_tileset_converter.gd
  - Updated room_blueprints.gd and game.tscn to use new tileset

- [x] **T1.3** Update TILE_SIZE constant in pixellab_tileset_converter.gd
  - Change from `32` to `64`
  - Verify room building still works

### Phase 2: Room Blueprints

- [x] **T2.1** Expand room blueprints to 20-22 tiles wide
  - Update ROOM_1_MAP through ROOM_7_MAP in room_blueprints.gd
  - Maintain same layout, just add more floor tiles
  - Keep entity positions (P, E, B, S, X, O) in same relative positions

- [x] **T2.2** Update hardcoded positions in room_manager.gd
  - `_player_spawn`: Vector2(640, 600)
  - Default boss spawn: Vector2(640, 320)
  - Default portal pos: Vector2(640, 200)
  - Vegetation center: Vector2(640, 400)

### Phase 3: Entity Sprites

- [x] **T3.1** Scale player sprite and collision shapes for 720p
  - AnimatedSprite2D scale: 0.5 → 1.3
  - Collision radius: 12 → 32
  - Hurtbox radius: 10 → 26
  - Melee radius: 14 → 36
  - Shadow polygon enlarged

- [x] **T3.2** Scale enemy sprites and collision shapes for 720p
  - Shadow Wisp: scale 0.5 → 1.3, collision 6.65 → 17, hitbox 13.8 → 36
  - Shadow Crawler: scale 0.5 → 1.3, collision 10.4 → 27, hitbox 14.65 → 38
  - Shadow Stalker: scale 0.5 → 1.3, collision 12 → 31, hitbox 18 → 47
  - Shadow Brute: scale 0.5 → 1.3, collision 16 → 42, hitbox 20 → 52

- [x] **T3.3** Scale boss sprite and collision shapes for 720p
  - Shadow Boar: scale 0.5 → 1.5, collision 24 → 72, hitbox 32 → 96
  - Shadow polygon enlarged

### Phase 4: Props & Interactables

- [x] **T4.1** Scale arrow projectile for 720p
  - Arrow scale: 1.3
  - Collision radius: 7 → 18
  - WallCast distance: 20 → 52

- [x] **T4.2** Scale destructibles for 720p
  - Ancient Pot: scale 0.25 → 0.65, collision 8x8 → 21x21
  - Bone Totem: scale 0.25 → 0.65, collision 8x10 → 21x26
  - Corrupted Root: scale 0.25 → 0.65, collision 8x6 → 21x16
  - Shadow Pillar: scale 0.25 → 0.65, collision 8x10 → 21x26

- [x] **T4.3** Scale interactables for 720p
  - Heal Shrine: collision 25 → 65, all polygon visuals scaled 2.6x
  - Room Portal: collision 30 → 78, all polygon visuals scaled 2.6x
  - Spirit Ember: collision 8 → 21, visuals scaled 2.6x
  - Shadow Fragment: collision 8 → 21, visuals scaled 2.6x

### Phase 5: UI & Camera

- [x] **T5.1** Reposition HUD elements for 1280x720
  - Health bar position
  - Dash cooldown position
  - Energy meter position
  - Boss HP bar position

- [x] **T5.2** Update camera bounds (no hardcoded limits - camera follows player)
  - Verify camera follows player correctly
  - Adjust limits if hardcoded

### Phase 6: Verification

- [ ] **T6.1** Playtest all 7 rooms (manual verification required)
  - Verify player movement
  - Verify enemy spawning and AI
  - Verify boss fight
  - Verify portal transitions
  - Verify heal shrine interaction

- [ ] **T6.2** Verify collision shapes (manual verification required)
  - Player vs walls
  - Player vs enemies
  - Arrows vs enemies
  - All hitboxes/hurtboxes

- [ ] **T6.3** Visual verification (manual verification required)
  - No overlapping sprites
  - Vegetation looks natural
  - UI is readable
  - No visual artifacts

---

## Dependencies

```
T1.1 ─┬─> T2.1 ─> T2.2 ─> T6.x
      │
      └─> T1.2 ─> T1.3 ─┐
                        │
T3.1 ──────────────────┼─> T6.x
T3.2 ──────────────────┤
T3.3 ──────────────────┘
                        │
T4.1 ─┬────────────────┼─> T6.x
T4.2 ─┤                │
T4.3 ─┘                │
                        │
T5.1 ─┬────────────────┼─> T6.x
T5.2 ─┘                │
```

## Parallelizable Work

- T3.1, T3.2, T3.3 can run in parallel (different entities)
- T4.1, T4.2 can run in parallel (different props)
- T5.1, T5.2 can run in parallel (different UI elements)
