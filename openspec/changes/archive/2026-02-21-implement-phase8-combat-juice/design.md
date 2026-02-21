# Design: Combat Juice Systems

## Key Decisions

### 1. Screen flash as HUD CanvasLayer child, not camera effect

Screen flashes are `ColorRect` nodes on the HUD `CanvasLayer` (process_mode = ALWAYS). This ensures flashes work during hitstop (time_scale=0) and don't interact with the pixel-perfect viewport scaling. A single `screen_flash.gd` script manages all flash types via signals.

### 2. Impulse knockback replaces tween knockback

The current `_knockback()` uses `create_tween().tween_property(position)` which fights the physics system. Instead, we'll set `velocity` directly and let `move_and_slide()` handle it naturally. A `knockback_velocity` vector is added and decayed via friction in `_physics_process()`.

### 3. Squash/stretch applied to sprite, not root node

Scale deformation targets the `Sprite2D` (or `AnimatedSprite2D`) child, not the `CharacterBody2D` root. This avoids distorting collision shapes. A helper method `_squash_stretch(target_scale, duration)` tweens the sprite's scale.

### 4. Single hit_flash.gdshader file shared by player and enemies

Extract the inline shader to `shaders/hit_flash.gdshader`. Both player and enemy sprites reference this shared resource. Each entity gets its own `ShaderMaterial` instance with independent `flash_intensity` and `flash_color` uniforms.

### 5. Enemy glow as separate Sprite2D with additive blend

Rather than a shader overlay, each enemy has a child `Sprite2D` node named `GlowSprite` with a `CanvasItemMaterial` set to `blend_mode = Add`. This sprite uses a simplified glow texture (just eyes/aura region) and is always-on. This approach is simpler than shader-based glow and works with animated sprites.

## Screen Flash Values (from GDD Feedback Matrix)

| Event | Color | Opacity | Duration | Extra |
|-------|-------|---------|----------|-------|
| Enemy → Player | Red (#ee4540) | 20% | 0.15s fade out | — |
| Boss → Player | Red (#ee4540) | 35% | 0.2s fade out | Chromatic aberration pulse |
| Boss Phase Transition | White (#ffffff) | 60% | 0.15s flash | — |
| Player Death | Black (#000000) | 100% | 1.5s total | Desaturate then fade to black |
| Heal Shrine Use | Green (#70c1b3) | 15% | 0.4s pulse | — |

## Knockback Distances (from GDD Feedback Matrix)

| Event | Distance | Direction |
|-------|----------|-----------|
| Arrow → Enemy | 80px | Arrow direction |
| Arrow → Enemy (kill) | 120px | Arrow direction |
| Melee → Enemy | 150px | Away from player |
| Melee → Enemy (kill) | 200px | Away from player |
| Enemy → Player | 60px | Away from enemy |
| Boss → Player | 100px | Away from boss |
| Arrow → Boss | 20px | Arrow direction |
| Melee → Boss | 40px | Away from player |
