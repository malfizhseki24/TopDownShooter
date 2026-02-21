# Tasks: Complete Phase 5 Polish

## 1. Room Transition VFX

- [x] 1.1 Add a ColorRect node (`FadeRect`) to game.tscn HUD CanvasLayer — full screen, black, starts transparent (alpha 0), mouse_filter ignore
- [x] 1.2 Implement `_fade_to_black()` in game.gd — tween FadeRect color alpha from 0 to 1 over 0.3 sec
- [x] 1.3 Implement `_fade_from_black()` in game.gd — tween FadeRect color alpha from 1 to 0 over 0.3 sec
- [x] 1.4 Test transition: enter portal → screen fades black → room loads → fades back in

## 2. Static Obstacle Props

- [x] 2.1 Create `scenes/interactables/obstacle_pillar.tscn` — StaticBody2D with CollisionShape2D (14x14 rect), ColorRect visuals (dark pillar), shadow Polygon2D
- [x] 2.2 Set collision layer 8 (layer 4 = bit 8) so player and enemies collide with obstacles
- [x] 2.3 Add obstacle spawning to RoomManager — load obstacle_scene, iterate `_obstacle_positions`, instantiate in interactables node
- [x] 2.4 Clear obstacles in `_clear_room()` — already clears all interactables_node children (verified)
- [x] 2.5 Test: obstacles appear at O markers, player/enemies/arrows collide with them

## 3. Playtesting (manual)

- [x] 3.1 Test full run Rooms 1-7: transitions smooth, obstacles placed correctly, gameplay unaffected
- [x] 3.2 Test boss room: corner pillars present, boss charge interacts with pillar collision

## Dependencies

- game.tscn HUD CanvasLayer — READY
- AsciiRoomBuilder obstacle_positions — READY
- RoomManager interactables_node — READY
- Physics layer 4 (wall) — READY
