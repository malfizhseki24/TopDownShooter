## 1. Input & EventBus Setup

- [x] 1.1 Add `skill_1` (Key 1), `skill_2` (Key 2), `skill_3` (Key 3) input actions to `project.godot`
- [x] 1.2 Add signals to `scripts/autoload/event_bus.gd`:
  - `skill_activated(skill_index: int)`
  - `skill_cooldown_started(skill_index: int, duration: float)`
  - `skill_cooldown_ready(skill_index: int)`

## 2. Player — Skill State & Cooldown Timers

- [x] 2.1 Add 3 `Timer` children to `scenes/player/player.tscn`: `SkillTimer1` (5s), `SkillTimer2` (9s), `SkillTimer3` (14s), one-shot
- [x] 2.2 In `scripts/player/player.gd`, add:
  - `var is_warded: bool = false`
  - `@onready var skill_timers: Array[Timer]` referencing the 3 timers
  - `_on_skill_timer_timeout(index: int)` callback that emits `skill_cooldown_ready`
- [x] 2.3 Add `_handle_skills()` call inside `_handle_actions()` (after existing action checks), guarded by `is_windup` and `is_dead`
- [x] 2.4 Reset all skill timers and `is_warded` in the respawn path

## 3. Talon Kick Implementation

- [x] 3.1 In `_handle_skills()`, detect `Input.is_action_just_pressed("skill_1")` and `skill_timers[0].is_stopped()`
- [x] 3.2 Implement `_talon_kick()`:
  - Distance-check all enemies in group within 100px radius
  - Apply 45 damage to each hit enemy via existing `take_damage()` pattern
  - Emit `EventBus.camera_trauma(0.3)`, `EventBus.skill_activated.emit(0)`
  - Start `skill_timer_1` and emit `skill_cooldown_started(0, 5.0)`
- [x] 3.3 Spawn ground shockwave ring VFX via `VFXManager.spawn("explosion")` at player position
- [x] 3.4 Play `boss_slam.wav` placeholder via `AudioManager.play_sfx()`

## 4. Feather Volley Implementation

- [x] 4.1 In `_handle_skills()`, detect `Input.is_action_just_pressed("skill_2")` and `skill_timer_2.is_stopped()`
- [x] 4.2 Implement `_feather_volley()`:
  - Loop over 5 angle offsets: `[-45, -22.5, 0, 22.5, 45]` degrees
  - Instantiate arrow scene for each, set `direction = aim_direction.rotated(deg_to_rad(offset))`
  - Set `arrow.damage = 20` (override base ARROW_DAMAGE)
  - Add each arrow to the scene tree at `arrow_spawn.global_position`
  - Emit `EventBus.skill_activated.emit(1)`
  - Start `skill_timer_2` and emit `skill_cooldown_started(1, 9.0)`
- [x] 4.3 Spawn `hit_spark` VFX at player position
- [x] 4.4 Play `bow_shoot.wav` placeholder SFX

## 5. Ancestor's Ward Implementation

- [x] 5.1 In `_handle_skills()`, detect `Input.is_action_just_pressed("skill_3")`, `skill_timer_3.is_stopped()`, and `not is_warded`
- [x] 5.2 Implement `_activate_ward()`:
  - Set `is_warded = true`, start `ward_timer` (3s)
  - Tint player sprite cyan as ward-active visual indicator
  - Emit `EventBus.skill_activated.emit(2)`
  - Play `pickup_chime.wav` placeholder SFX
  - Note: skill cooldown timer starts only when ward is consumed or expires
- [x] 5.3 In `take_damage()`, add ward absorption check via `_consume_ward()`
- [x] 5.4 On `WardTimer` timeout: `_on_ward_timer_timeout()` clears ward and starts `skill_timer_3`

## 6. Skill Bar HUD

- [x] 6.1 Create `scenes/ui/skill_bar.tscn` with structure:
  - `HBoxContainer` (SkillBar) containing 3 `PanelContainer` (SkillSlot) children
  - Each slot has: background `ColorRect`, icon `ColorRect` (placeholder icon), key `Label`, cooldown overlay `ColorRect`
- [x] 6.2 Create `scripts/ui/skill_bar.gd`:
  - Connect to `EventBus.skill_cooldown_started` and `EventBus.skill_cooldown_ready`
  - Connect to `EventBus.skill_activated` (for ward active pulse on slot 3)
  - On `skill_cooldown_started(index, duration)`: show overlay, tween from full cover to 0 over duration
  - On `skill_cooldown_ready(index)`: hide overlay, flash slot border white for 0.15s
  - For Ward (index 2): show cyan pulse on `skill_activated`; stop pulse on `skill_cooldown_started`
  - Set `process_mode = ALWAYS` to continue during hitstop
- [x] 6.3 Add SkillBar as child of `$LeftPanel` in `scenes/ui/hud.tscn`, positioned below energy meter
- [x] 6.4 Reference SkillBar in `scripts/ui/hud.gd` via `@onready`

## 7. Assets

- [x] 7.1 Source or create SFX: using existing files as placeholders — `boss_slam.wav` (Talon Kick), `bow_shoot.wav` (Feather Volley), `pickup_chime.wav` (Ward activate), `player_hurt.wav` (Ward break)
- [x] 7.2 Create or reuse VFX particles: `explosion` (Talon Kick), `hit_spark` (Feather Volley), sprite modulate tint (Ward aura)

## 8. Playtesting & Polish

- [ ] 8.1 Open Godot editor and run the game — verify all 3 skills activate and cooldowns show on HUD
- [ ] 8.2 Verify Ancestor's Ward absorbs exactly 1 hit and cooldown only starts after absorption/expiry
- [ ] 8.3 Verify Feather Volley does not affect regular bow fire rate
- [ ] 8.4 Verify Talon Kick AoE radius feels correct at 100px (adjust if needed)
- [ ] 8.5 Verify all skill timers reset on respawn
- [ ] 8.6 Check no console errors; verify hitstop does not freeze HUD cooldown animations

<!-- Tasks 8.1–8.6 require manual playtesting in Godot editor -->
