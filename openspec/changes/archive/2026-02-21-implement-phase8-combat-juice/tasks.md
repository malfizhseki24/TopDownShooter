## 1. Screen Flash Effects

- [x] 1.1 Add `screen_flash_requested(color: Color, opacity: float, duration: float)` signal to `scripts/autoload/event_bus.gd`
- [x] 1.2 Create `scripts/ui/screen_flash.gd` + `scenes/ui/screen_flash.tscn` — ColorRect overlay on HUD CanvasLayer, connects to EventBus signal, tweens modulate alpha
- [x] 1.3 Integrate screen flash into `scenes/levels/game.tscn` HUD layer
- [x] 1.4 Emit red flash from `scripts/player/player.gd` `take_damage()` — Color(0.93, 0.27, 0.25), 20% opacity, 0.15s (35% + 0.2s for boss damage type)
- [x] 1.5 Emit white flash from `scripts/boss/shadow_boar.gd` `_do_phase_transition()` — Color.WHITE, 60% opacity, 0.15s
- [x] 1.6 Emit green pulse from heal shrine interaction — Color(0.44, 0.76, 0.70), 15% opacity, 0.4s
- [x] 1.7 Add player death desaturation: screen fades to black over 1.5s on `player_died` signal

## 2. Knockback Polish

- [x] 2.1 Replace `base_enemy._knockback()` tween with impulse velocity — set `knockback_velocity` vector, decay via `move_toward(Vector2.ZERO, 600.0 * delta)` in `_physics_process()`
- [x] 2.2 Add knockback distance parameter to `take_damage()` — 80px arrow, 150px melee; 120px arrow kill, 200px melee kill
- [x] 2.3 Add boss knockback resistance in `shadow_boar.take_damage()` — 20px arrow, 40px melee
- [x] 2.4 Update player knockback in `take_damage()` — 60px from enemy, 100px from boss (use velocity impulse, same friction model)

## 3. Hit Flash Shader (Enemies)

- [x] 3.1 Extract inline shader to `shaders/hit_flash.gdshader` file, update player ShaderMaterial reference
- [x] 3.2 Apply ShaderMaterial with `hit_flash.gdshader` to all enemy sprite nodes in `base_enemy._ready()` or scene files
- [x] 3.3 Replace `base_enemy._flash_white()` red modulate with shader-based white flash — `flash_intensity` 1.0→0.0 over 0.08s
- [x] 3.4 Verify hit flash works on all 4 enemy types + boss

## 4. Squash/Stretch

- [x] 4.1 Add `_squash_stretch(target_scale: Vector2, duration: float)` helper to `base_enemy.gd` targeting sprite child
- [x] 4.2 Add enemy hit squash: `(1.3, 0.7)` → `(1.0, 1.0)` over 0.1s in `take_damage()`
- [x] 4.3 Add enemy death stretch: `(0.6, 1.4)` then dissolve in `die()`
- [x] 4.4 Add player dash landing squash: `(1.2, 0.8)` → `(1.0, 1.0)` over 0.08s at end of dash
- [x] 4.5 Set arrow sprite scale to `(0.8, 1.2)` in `arrow.gd` `_ready()` for speed feel

## 5. Enemy Glow Layer

- [x] 5.1 Create glow sprite textures for each enemy type (eyes/aura region, additive blend)
- [x] 5.2 Add `GlowSprite` child node with `CanvasItemMaterial(blend_mode=Add)` to all enemy scenes
- [x] 5.3 Add boss aura glow sprite (4-8px shadow glow around body) to `shadow_boar.tscn`
- [x] 5.4 Ensure glow intensity matches readability rules (≥40% brighter than background)

## 6. GDD Update

- [x] 6.1 Update GDD Phase 8 checkboxes for Screen Flash Effects, Knockback Polish, Squash/Stretch, Hit Flash Shader (enemy), Enemy Glow Layer
