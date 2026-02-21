# Feature: Implement Player Forgiveness & Combat Feel Systems

## Why

The player character has core mechanics working (movement, shooting, dash, melee, health, death, animations) from Phase 1 and the archived Phase 2. However, the game currently lacks the **forgiveness systems** and **combat polish** defined in the GDD's "Game Feel & Juice" section. Specifically:

1. **Taking damage locks the player out** — there are no on-hit i-frames, so the player can be stun-locked by multiple enemies contacting simultaneously. Only dash provides i-frames (0.15 sec).
2. **Inputs are dropped** — pressing dash during a shoot animation does nothing. Players feel the game is unresponsive.
3. **Arrows require pixel-perfect aim** — with no aim assist, the methodical combat (0.5 sec fire rate) punishes misses harshly for non-hardcore players.
4. **Hit feedback is placeholder** — `modulate = Color.RED` for 0.1 sec and a hardcoded camera offset tween. No shader-based flash, no hitstop, no squash/stretch.
5. **Hitboxes are default** — player hurtbox matches sprite size; arrows have no generosity. Near-misses feel unfair on both ends.

These gaps make the game feel flat and punishing. This change implements the six forgiveness/juice systems from the GDD to bring the combat from functional to polished.

## What Changes

### 1. Damage I-Frames (0.8 sec with sprite flicker)
- After taking damage, player becomes invincible for 0.8 sec
- Sprite flickers (toggle visible every 0.08 sec) during i-frames
- Dash i-frames override damage i-frames; longer duration wins

### 2. Input Buffering (0.15 sec window)
- Queue the most recent dash/shoot/melee input during animations or cooldowns
- Execute buffered action on the first available frame
- Buffer expires after 0.15 sec or on execution

### 3. Dash Forgiveness Window (0.12 sec post-hit)
- If player presses dash within 0.12 sec after taking damage, dash executes immediately
- Bypasses any hitstun or damage animation lock

### 4. Aim Assist / Soft Magnetism
- On arrow spawn, check a 12° cone in aim direction
- If an enemy is within 300 px and inside the cone, bend arrow trajectory up to 8°
- One-time correction at spawn — arrow then flies straight
- Completely invisible to the player

### 5. Hit Flash Shader
- Replace `modulate = Color.RED` with a proper `hit_flash.gdshader`
- White flash on enemies (0.08 sec), red flash on player (0.12 sec)
- Driven by tween on `flash_intensity` shader parameter

### 6. Hitbox Manipulation
- Shrink player hurtbox from sprite-sized to Circle(r=10) — ~42% of 48x48 sprite
- Enlarge arrow hitbox to Circle(r=7) — ~175% of visual
- Separate player physics body (r=12 for wall collision) from hurtbox (r=10 for damage)

## Impact

- **Affected systems**: player-combat (new), aim-assist (new), hit-feedback (new), bow-arrow (modified), player (modified)
- **Affected files**:
  - `scripts/player/player.gd` — i-frames, input buffer, dash forgiveness, hitbox refs
  - `scenes/player/player.tscn` — restructure collision (separate HurtboxArea), add shader material
  - `scripts/player/arrow.gd` — aim assist cone check at spawn
  - `scenes/player/arrow.tscn` — enlarge collision shape to r=7
  - `shaders/hit_flash.gdshader` — new file
  - `scripts/autoload/event_bus.gd` — add `player_dash_started`, `player_dash_ready` signals

## Already Implemented (From Archived Phase 2)

These are NOT in scope — they already work:

| Feature | Status | Notes |
|---------|--------|-------|
| Dash/dodge mechanics | Done | 400 px/sec, 0.2 sec, 1.0 sec cooldown |
| Dash i-frames | Done | 0.15 sec during dash (to be expanded) |
| Melee attack | Done | 35 damage, 64 px range |
| Health system | Done | 100 HP, `take_damage()`, `die()` |
| Death & respawn | Done | Full reset, 1.0 sec post-respawn invincibility |
| 4-dir animations | Done | Idle, walk, shoot, dash, death |
| Basic hit feedback | Done | Red modulate + camera offset (to be replaced) |

## Dependencies

- **GDD sections**: "Game Feel & Juice" > "Forgiveness & Accessibility Systems", "Hit Feedback System", "Hitbox Manipulation"
- **No external dependencies** — all changes are to existing player/arrow scripts and scenes

## Risks

- **Aim assist tuning** — values (12° cone, 8° correction) may feel too strong or too weak. Ship with the GDD defaults and tune during Phase 8 balancing.
- **I-frame duration** — 0.8 sec is generous. May need reduction if it trivializes combat. Mark as tunable constant.
- **Input buffer edge cases** — buffered dash during death animation should be ignored. Must clear buffer on death.
