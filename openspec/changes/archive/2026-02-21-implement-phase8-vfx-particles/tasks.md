## 1. Dash Afterimages

- [x] 1.1 Create `scripts/vfx/dash_afterimage.gd` — captures current sprite frame, fades from 60% to 0% alpha over 0.15s, self-frees
- [x] 1.2 Create `scenes/vfx/dash_afterimage.tscn` — Sprite2D with modulate fade
- [x] 1.3 Spawn afterimages in `scripts/player/player.gd` `_dash()` — 1 every 0.05s during the 0.2s dash (4 total), at player position with current frame texture
- [x] 1.4 Playtest: verify 3-4 ghost sprites trail behind player during dash, fade cleanly

## 2. Arrow Trail

- [x] 2.1 Add `GPUParticles2D` child node to `scenes/player/arrow.tscn` — emission rate 30/s, lifetime 0.2s, small circle shape, fade to transparent
- [x] 2.2 Configure particle material: 2-3px dots, color matching arrow palette, gravity 0, initial velocity 0 (trail behind via movement)
- [x] 2.3 Set `GPUParticles2D.emitting = false` on arrow hit/destroy so trail fades naturally
- [x] 2.4 Playtest: verify subtle dot trail behind arrows, no particle overflow

## 3. Portal VFX

- [x] 3.1 Create `scripts/vfx/portal_vfx.gd` — manages idle/activated/travel states, connects to room_cleared signal
- [x] 3.2 Create `scenes/vfx/portal_vfx.tscn` — `GPUParticles2D` for idle shimmer (subtle floating particles), burst particles for activation
- [x] 3.3 Integrate portal VFX into portal scene — add as child, idle state on ready, switch to activated when room clears
- [x] 3.4 Add travel warp effect: brief screen distortion or particle burst when player enters portal
- [x] 3.5 Playtest: verify idle shimmer on locked portal, burst on unlock, warp on travel

## 4. Heal Shrine VFX

- [x] 4.1 Create `scenes/vfx/heal_shrine_vfx.tscn` — `GPUParticles2D` with green spiral upward motion, 0.8s one-shot
- [x] 4.2 Add idle glow particles to heal shrine (subtle green float, stops after use)
- [x] 4.3 Trigger heal VFX from `scripts/interactables/heal_shrine.gd` on use
- [x] 4.4 Playtest: verify green spiral on heal, idle glow when available

## 5. Spawn Emerge VFX

- [x] 5.1 Add spawn animation to `base_enemy.gd` — scale `(0, 0)` → `(1.1, 0.9)` → `(1.0, 1.0)` over 0.3s on sprite child
- [x] 5.2 Create `scenes/vfx/spawn_emerge.tscn` — dark smoke puff particle effect, one-shot
- [x] 5.3 Spawn smoke puff via VFXManager at enemy spawn position simultaneously with scale animation
- [x] 5.4 Playtest: verify enemies emerge with squash/stretch + smoke puff, no visual glitch at (0,0) scale

## 6. GDD Update

- [x] 6.1 Update GDD Phase 8 checkboxes for Dash Afterimages, Arrow Trail, Portal VFX, Heal Shrine VFX, Spawn Emerge VFX
