# Tasks: Phase 2 - Player Polish

## 1. SpriteFrames Resource Setup

- [x] 1.1 Create `kasuari_frames.tres` SpriteFrames resource
- [x] 1.2 Create animation entries: idle, walk, shoot, dash, death
- [x] 1.3 Import all frame PNGs for each animation (4 directions × N frames)
- [x] 1.4 Configure animation speeds (idle/walk: 10 FPS, actions: 12 FPS)
- [x] 1.5 Set all animations to loop OFF except idle and walk

## 2. Scene Updates

- [x] 2.1 Replace `Sprite2D` with `AnimatedSprite2D` in player.tscn
- [x] 2.2 Assign SpriteFrames resource to AnimatedSprite2D
- [x] 2.3 Adjust scale/offset if needed for proper alignment
- [x] 2.4 Ensure AnimatedSprite2D is centered properly

## 3. Animation State Machine

- [x] 3.1 Add `_get_animation_direction()` function to determine facing
- [x] 3.2 Add `_update_animation()` function called every physics process
- [x] 3.3 Implement state tracking: current animation, direction, playing
- [x] 3.4 Add `_play_animation(name, direction)` helper function

## 4. Movement Animations

- [x] 4.1 Play "walk" when velocity.length() > 10
- [x] 4.2 Play "idle" when velocity.length() <= 10
- [x] 4.3 Handle direction changes smoothly (no abrupt cuts)
- [x] 4.4 Test all 4 directions while moving and aiming

## 5. Action Animations

- [x] 5.1 Play "shoot" when arrow fired (plays once, then returns)
- [x] 5.2 Play "dash" when dash starts (plays once, then returns)
- [x] 5.3 Block movement animation changes during action animations
- [x] 5.4 Use `animation_finished` signal to return to idle/walk

## 6. Death Animation & Respawn Trigger

- [x] 6.1 Play "death" when player dies
- [x] 6.2 Wait for death animation to complete (~0.58 sec at 12 FPS)
- [x] 6.3 Trigger respawn after animation completes
- [x] 6.4 Disable all player input during death animation

## 7. Respawn System

- [x] 7.1 Add `respawn()` function to player script
- [x] 7.2 Reset HP to MAX_HP on respawn
- [x] 7.3 Reset position to spawn point
- [x] 7.4 Reset all flags (is_dead, is_dashing, can_dash, can_shoot)
- [x] 7.5 Add post-respawn invincibility (1.0 sec)
- [x] 7.6 Play spawn effect (optional: flash white briefly)
- [x] 7.7 Emit `player_respawned` signal via EventBus

## 8. GameManager Integration

- [x] 8.1 Add `RESPAWNING` state to GameState enum (optional) - SKIPPED (not needed)
- [x] 8.2 Add `respawn_player()` function to GameManager - SKIPPED (player handles internally)
- [x] 8.3 Store reference to player spawn point
- [x] 8.4 Handle game over flow (for now: infinite respawns)

## 9. EventBus Updates

- [x] 9.1 Add `player_respawned` signal (no params)
- [x] 9.2 Connect signal in main level script for any UI updates

## 10. Direction Optimization (Optional)

- [x] 10.1 Use East sprites + flip_h for West direction
- [x] 10.2 Test memory savings vs. visual quality
- [x] 10.3 Document decision in code comments

## 11. Verification

- [ ] 11.1 Idle plays when standing still, all 4 directions
- [ ] 11.2 Walk plays when moving, direction follows aim
- [ ] 11.3 Shoot plays and returns to previous state
- [ ] 11.4 Dash plays and returns to previous state
- [ ] 11.5 Death plays once then triggers respawn
- [ ] 11.6 Player respawns at spawn point with full HP
- [ ] 11.7 Post-respawn invincibility works
- [ ] 11.8 No animation jitter or incorrect frames
- [ ] 11.9 Performance is acceptable (60 FPS maintained)
