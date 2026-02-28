# Proposal: Add Enemy Pathfinding

## Summary

Implement NavigationAgent2D-based pathfinding for enemy AI to navigate around walls and corners in complex dungeon maps. Currently, enemies use simple straight-line movement (`direction_to`) which causes them to get stuck on walls and L-shaped corners.

## Motivation

### Problem Statement

The current enemy AI implementation uses direct vector movement toward the player:

```gdscript
var direction := _get_direction_to_player()
velocity = direction * move_speed
```

This causes several issues:
1. **Enemies get stuck on walls** - When a wall is between enemy and player, the enemy moves directly into the wall
2. **Poor navigation around corners** - L-shaped corridors block enemy movement entirely
3. **Frustrating gameplay** - Player can easily exploit corners to avoid enemies
4. **Inconsistent difficulty** - Some room layouts make enemies trivial to avoid

### Current Impact

- Shadow Wisp: Gets stuck on interior pillars in Room 4 and Room 5
- Shadow Crawler: Cannot navigate around central pillars
- Shadow Stalker: Teleport helps but still has pathing issues after teleport
- Shadow Brute: Charge attack often blocked by walls

### Desired Outcome

Enemies should intelligently navigate around obstacles:
- Follow the shortest walkable path to player
- Navigate L-shaped corners smoothly
- Maintain threat level in complex room layouts
- Preserve current game feel and difficulty

## Proposed Solution

Use Godot 4's built-in `NavigationAgent2D` for pathfinding with:

1. **NavigationRegion2D** in game scene - Defines walkable area
2. **NavigationAgent2D** per enemy - Calculates path to target
3. **Path updates via timer** - Performance optimization (not every frame)
4. **Integration with existing BaseEnemy** - Minimal code changes

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Pathfinding system | NavigationAgent2D | Built-in, optimized, integrates with TileMap |
| Navigation source | Generate from TileMapLayer | Works with ASCII room generation |
| Update frequency | Timer-based (0.25s) | Performance over accuracy |
| Avoidance | Disabled initially | Simpler implementation, can add later |
| Fallback | Direct movement if no path | Graceful degradation |

### Scope

**In Scope:**
- NavigationRegion2D setup in game scene
- Navigation polygon generation from TileMapLayer
- NavigationAgent2D addition to enemy scenes
- BaseEnemy integration with pathfinding
- All 4 enemy types (Wisp, Crawler, Stalker, Brute)

**Out of Scope:**
- Boss pathfinding (Shadow Boar uses charge patterns)
- Avoidance between enemies
- Dynamic obstacle avoidance (destructibles)
- Pathfinding visualization/debug tools

## Success Criteria

1. Enemies navigate around walls in all 7 room layouts
2. No enemy gets permanently stuck on corners
3. Frame rate impact < 5% with 6 enemies on screen
4. Existing enemy behaviors (bounce, teleport, charge) still work
5. Game feel remains methodical, not chaotic

## Alternatives Considered

### Alternative 1: AStar2D Grid
- **Pros**: More control, no scene setup needed
- **Cons**: Manual grid management, more code, less integrated
- **Verdict**: Rejected - NavigationAgent2D is simpler

### Alternative 2: Raycast-based Wall Avoidance
- **Pros**: Simple, no navigation setup
- **Cons**: Poor corner navigation, "bouncing off walls" feel
- **Verdict**: Rejected - Doesn't solve L-corner problem

### Alternative 3: Keep Direct Movement
- **Pros**: No changes needed
- **Cons**: Poor player experience, exploitable AI
- **Verdict**: Rejected - Core gameplay issue

## Dependencies

- Existing `BaseEnemy` class
- Existing `AsciiRoomBuilder` for room generation
- TileSet with floor/wall terrain
- RoomManager for scene setup

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Performance with many enemies | Medium | Timer-based updates, limit active enemies |
| Navigation polygon gaps | Medium | Test all room layouts, add validation |
| Breaking existing behaviors | High | Keep pathfinding optional, test thoroughly |
| Complex room shapes | Low | NavigationRegion2D handles arbitrary polygons |

## Timeline Estimate

- Design: 1 session
- Implementation: 1-2 sessions
- Testing: 1 session
- Polish: 1 session

## Related Changes

- None (standalone improvement)
