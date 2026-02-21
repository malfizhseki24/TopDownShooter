# Proposal: Complete Phase 5 Polish

## Why

Phase 5 (Linear Room System) has two remaining items from the GDD:
1. **Room transition VFX** — Currently `_fade_to_black()` and `_fade_from_black()` in `game.gd` are placeholder 0.2s timer delays with no visual effect. Players see an instant scene swap with no feedback.
2. **Destructible prop placement** — The ASCII room builder parses `O` markers and collects `obstacle_positions`, but RoomManager never instantiates anything at those positions. Rooms feel empty without cover objects.

## What Changes

### Room Transition VFX
- Replace the placeholder timer in `game.gd` with a ColorRect fade (black overlay, tween alpha 0→1→0)
- The ColorRect lives in the HUD CanvasLayer (persists across room loads)
- Simple and reliable — no shader or particle effects needed

### Destructible Props (Static Obstacles)
- Create a simple `obstacle_pillar` scene: StaticBody2D with collision on layer 4 (wall), a Sprite2D visual, and shadow
- RoomManager spawns obstacles at `O` positions when building a room
- Obstacles are **static** for MVP (design.md from boss change says "pillars are static obstacles for now")
- Destructible behavior is a future enhancement (not in scope for this change)

## Impact

- `scripts/levels/game.gd` — replace `_fade_to_black` / `_fade_from_black`
- `scenes/levels/game.tscn` — add FadeRect ColorRect to HUD
- `scripts/stage/room_manager.gd` — add obstacle spawning in room setup
- NEW: `scenes/interactables/obstacle_pillar.tscn` — static pillar scene
- NEW: `scripts/interactables/obstacle_pillar.gd` — minimal script (optional)
