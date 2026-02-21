# Design: VFX & Particles

## Key Decisions

### 1. Dash afterimages as snapshot sprites, not shader duplicates

Each afterimage is a `Sprite2D` spawned at the player's position with the current animation frame's texture. This is simpler than a shader approach and gives more control over color/opacity per ghost. The player script spawns one every 0.05s during dash (4 total for a 0.2s dash).

### 2. Arrow trail uses GPUParticles2D (not CPUParticles2D)

GPUParticles2D is more performant for many small particles. The trail emits from the arrow's position with a small spread, lifetime 0.2s, and fades to transparent. Since arrows are short-lived (3s max), particle count stays within the 200 max budget.

### 3. Portal VFX as child scene, not VFXManager spawn

Portal effects need persistent state (idle → activated → travel). A child `portal_vfx.tscn` node is added to the portal scene, and the script manages state transitions. This is different from one-shot VFX (hit sparks) which use VFXManager.

### 4. Spawn emerge is an AnimationPlayer track, not code tween

The spawn animation (`scale (0,0) → (1.1, 0.9) → (1.0, 1.0)` over 0.3s) is best expressed as an `AnimationPlayer` track on the enemy's sprite. This keeps timing precise and reusable. A smoke puff VFX is spawned via VFXManager at the spawn point simultaneously.

### 5. Performance budget

- Max simultaneous afterimage sprites: 4 (one dash at a time)
- Arrow trail particles: ~6 per arrow (30/s emission, 0.2s lifetime)
- Max arrows in flight: ~3 (0.5s fire rate, 3s lifetime) = ~18 trail particles
- Portal particles: ~20 (idle), ~40 (activation burst, brief)
- Total particle budget: well within the 200 max from GDD
