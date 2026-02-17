# Design: Phase 1 - Foundation

## Context

This is the foundational phase for "Warrior of the Sunrise", a 2D top-down action shooter built in Godot 4.6. The game features:
- Pixel art aesthetic requiring precise rendering at 4x scale
- Methodical combat with bow & arrow mechanics
- Papuan folklore theme with tribal aesthetics

**Current State:** Empty project with sprite assets being generated in parallel (`add-character-sprites` change).

**Constraints:**
- Target: 60 FPS stable
- Viewport: 480x270 (pixel perfect base)
- Window: 1920x1080 (4x scale)
- Max enemies on screen: 10

## Goals / Non-Goals

**Goals:**
- Establish clean, extensible project structure following Godot 4 best practices
- Implement pixel-perfect rendering with smooth camera follow
- Create responsive player movement (8-directional)
- Build functional bow & arrow system with proper physics

**Non-Goals:**
- Enemy implementation (Phase 3)
- Boss implementation (Phase 4)
- UI/HUD (Phase 5)
- Audio/VFX polish (Phase 6)
- Dash/dodge mechanics (Phase 2)
- Melee combat (Phase 2)

## Decisions

### Decision 1: Pixel Perfect Rendering Strategy

**Chosen:** Viewport stretch mode with 480x270 base resolution

**Rationale:**
- Godot's `viewport` stretch mode ensures 1:1 pixel rendering
- 480x270 divides evenly into 1920x1080 (4x scale)
- Avoids subpixel rendering artifacts
- All sprites designed for 32px tile size will render cleanly

**Configuration:**
```
viewport_width = 480
viewport_height = 270
window_width = 1920
window_height = 1080
stretch_mode = viewport
stretch_aspect = keep
```

**Alternatives Considered:**
- `canvas_items` stretch mode: Blurry at non-integer scales, rejected
- 2D stretch mode: Doesn't guarantee pixel-perfect rendering, rejected

### Decision 2: Camera Implementation

**Chosen:** Custom Camera2D with lerp-based smooth follow

**Rationale:**
- GDD specifies smooth follow camera with lerp speed 5.0
- Custom script allows easy tuning and future features (screen shake, look-ahead)
- Centered on player with no offset for MVP simplicity

**Implementation:**
```gdscript
# Smooth follow in _process
global_position = lerp(global_position, target.global_position, 5.0 * delta)
```

**Alternatives Considered:**
- Instant follow: Too jarring for pixel art, rejected
- Godot's built-in smoothing: Less control, may not handle pixel snap correctly

### Decision 3: Player Movement Architecture

**Chosen:** CharacterBody2D with velocity-based movement

**Rationale:**
- Godot 4's recommended approach for player controllers
- Built-in collision handling
- Easy to extend for dash mechanics in Phase 2
- Supports 8-directional normalization

**Implementation:**
```gdscript
# Get input direction
var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
velocity = input_dir * move_speed
move_and_slide()
```

### Decision 4: Arrow Physics

**Chosen:** RigidBody2D for arrows with linear velocity

**Rationale:**
- Physics-based travel matches GDD spec (600 px/sec)
- Built-in collision detection
- Easy to add rotation based on velocity
- Can extend for arrow trails in Phase 6

**Arrow Lifecycle:**
1. Spawn at player position, aimed at mouse
2. Set linear_velocity = direction * 600
3. Despawn after 3 seconds (Timer)
4. On collision: deal damage, spawn hit effect, queue_free()

**Alternatives Considered:**
- Area2D with manual movement: More code, no physics benefits
- CharacterBody2D: Overkill for simple projectile

### Decision 5: Fire Rate Control

**Chosen:** Timer node with 0.5 sec wait time

**Rationale:**
- Simple, reliable cooldown mechanism
- Can easily visualize with progress bar in Phase 5
- Matches GDD spec exactly (0.5 sec between shots)

### Decision 6: Autoload Singletons

**Chosen:** Minimal autoload setup for MVP

| Singleton | Purpose |
|-----------|---------|
| `GameManager` | Game state, pause handling |
| `EventManager` | Global signals for decoupled communication |

**Rationale:**
- Start minimal, add more singletons as needed
- EventManager enables enemy spawning without direct references
- GameManager handles game flow (pause, game over)

**Deferred to Later Phases:**
- `AudioManager` (Phase 6)
- `PoolManager` (Phase 3 - for object pooling)

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Pixel perfect breaks at non-16:9 resolutions | Document supported resolutions; consider letterboxing |
| Arrow collision detection edge cases | Use continuous collision detection (CCD) for fast-moving arrows |
| Input lag on movement | Use `_physics_process` for movement, `_process` for aiming |
| Camera judder at low frame rates | Use fixed timestep physics; cap delta in lerp |
| Too many arrows causing performance issues | Implement object pooling in Phase 3; limit max arrows |

## Migration Plan

**Phase 1 Deployment:**
1. Create project structure
2. Configure project settings (viewport, input map, physics layers)
3. Implement autoloads
4. Create Player scene and script
5. Create Bow and Arrow scenes
6. Create test level for validation
7. Manual testing of all systems

**Rollback:** N/A (initial implementation)

## Open Questions

1. **Arrow sprite:** Should we create a simple placeholder arrow or wait for asset pipeline?
   - Recommendation: Create placeholder arrow sprite (8x32 px) for testing

2. **Player sprite integration:** Import Kasuari sprites now or use placeholder?
   - Recommendation: Import Kasuari sprites from completed `add-character-sprites` change

3. **Collision shapes:** Precise pixel collision or simplified shapes?
   - Recommendation: Use capsule/rectangle shapes for performance; pixel collision not needed for MVP
