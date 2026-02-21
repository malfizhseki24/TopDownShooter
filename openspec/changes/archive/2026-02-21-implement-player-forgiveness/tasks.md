# Tasks: Implement Player Forgiveness & Combat Feel Systems

## 1. Hit Flash Shader (Foundation — other tasks depend on this)

- [x] 1.1 Create `shaders/hit_flash.gdshader` with `flash_intensity` and `flash_color` uniforms
- [x] 1.2 Apply ShaderMaterial to player's AnimatedSprite2D in `player.tscn`
- [x] 1.3 Replace `_flash_red()` in `player.gd` — tween `flash_intensity` 1.0→0.0 over 0.12 sec with red `flash_color`
- [x] 1.4 Replace `_flash_white()` in `player.gd` — pulse `flash_intensity` 3 times over 0.6 sec with white `flash_color`
- [x] 1.5 Verify: player flashes red on damage, white on respawn, no `modulate` changes remain

## 2. Hitbox Restructure

- [x] 2.1 In `player.tscn`: resize CharacterBody2D's CollisionShape2D to Circle r=12 (physics/wall collision)
- [x] 2.2 In `player.tscn`: rename existing `Hitbox` Area2D to `HurtboxArea` (or create new if structure differs)
- [x] 2.3 Set HurtboxArea CollisionShape2D to Circle r=10 (damage reception, smaller than sprite)
- [x] 2.4 Update `_connect_signals()` in `player.gd` to use `HurtboxArea` instead of `hitbox`
- [x] 2.5 In `arrow.tscn`: resize arrow CollisionShape2D to Circle r=7 (generous hit detection)
- [x] 2.6 Verify: player can walk close to walls without getting stuck (r=12 body), enemies must overlap r=10 to deal damage, arrows hit enemies more generously

## 3. Damage I-Frames with Sprite Flicker

- [x] 3.1 Add constants: `DAMAGE_IFRAME_DURATION = 0.8`, `IFRAME_FLICKER_INTERVAL = 0.08`
- [x] 3.2 Add `IFrameTimer` (Timer, one_shot=true, 0.8 sec) and `FlickerTimer` (Timer, repeating, 0.08 sec) to `player.tscn`
- [x] 3.3 In `take_damage()`: after applying damage, start IFrameTimer and FlickerTimer, set `is_invincible = true`
- [x] 3.4 Connect FlickerTimer timeout: toggle `sprite.visible`
- [x] 3.5 Connect IFrameTimer timeout: set `is_invincible = false`, stop FlickerTimer, ensure `sprite.visible = true`
- [x] 3.6 Handle dash overlap: if dash starts during damage i-frames, let the longer remaining window win
- [x] 3.7 Skip i-frames when HP reaches 0 (death takes priority)
- [x] 3.8 Verify: player flickers for 0.8 sec after hit, cannot take damage during flicker, sprite is visible after i-frames end, death does not trigger i-frames

## 4. Input Buffering

- [x] 4.1 Add private vars: `_buffered_action: StringName = &""`, `_buffer_timestamp: float = 0.0`
- [x] 4.2 Add constant: `INPUT_BUFFER_WINDOW = 0.15`
- [x] 4.3 Add `_buffer_action(action: StringName)` — stores action and current time
- [x] 4.4 Add `_consume_buffered_action(action: StringName) -> bool` — returns true if action matches and within window
- [x] 4.5 In `_handle_actions()`: when shoot/dash/melee is blocked by cooldown or animation, call `_buffer_action()`
- [x] 4.6 In `_handle_actions()`: before normal input checks, try `_consume_buffered_action()` for each action
- [x] 4.7 Clear buffer on death (`_buffered_action = &""`)
- [x] 4.8 Verify: press dash during shoot animation → dash fires immediately after shoot ends; press shoot during fire rate cooldown → shoot fires when cooldown expires; stale buffer (>0.15 sec) does not fire

## 5. Dash Forgiveness Window

- [x] 5.1 Add private var: `_last_damage_time: float = 0.0`
- [x] 5.2 Add constant: `DASH_FORGIVENESS_WINDOW = 0.12`
- [x] 5.3 In `take_damage()`: record `_last_damage_time = Time.get_ticks_msec() / 1000.0`
- [x] 5.4 In dash input check: if `(current_time - _last_damage_time) <= DASH_FORGIVENESS_WINDOW`, allow dash even if normally blocked by hitstun
- [x] 5.5 Verify: take damage → press dash within 0.12 sec → dash executes and player gets i-frames; press dash after 0.12 sec → normal dash rules apply

## 6. Aim Assist / Soft Magnetism

- [x] 6.1 Add constants: `AIM_CONE_HALF_ANGLE = deg_to_rad(12.0)`, `AIM_MAX_CORRECTION = deg_to_rad(8.0)`, `AIM_ASSIST_RANGE = 300.0`
- [x] 6.2 Add `_apply_aim_assist(base_direction: Vector2) -> Vector2` function
- [x] 6.3 Implementation: iterate enemies group, find nearest enemy within cone and range, slerp toward target capped at max correction
- [x] 6.4 Call `_apply_aim_assist()` in `_shoot()` before spawning arrow, pass result as `arrow.direction`
- [x] 6.5 Verify: fire arrow near an enemy (within 12° cone, <300 px) → arrow bends slightly toward enemy; fire with no enemies nearby → arrow goes straight; verify no visual indicator of correction

## 7. EventBus Signal Updates

- [x] 7.1 Add `signal player_dash_started(cooldown_duration: float)` to EventBus
- [x] 7.2 Add `signal player_dash_ready()` to EventBus
- [x] 7.3 Emit `player_dash_started` in `_dash()` with cooldown value
- [x] 7.4 Emit `player_dash_ready` when dash cooldown expires
- [x] 7.5 Verify: signals fire at correct times (for future HUD dash cooldown integration)

## 8. Integration Verification

- [x] 8.1 Test full combat loop: move → shoot (aim assist) → take hit (i-frames + flash) → dash (forgiveness) → shoot (input buffer)
- [x] 8.2 Test edge case: die during i-frames → death proceeds, no lingering invincibility after respawn
- [x] 8.3 Test edge case: buffer dash during death → buffer cleared, no dash after respawn
- [x] 8.4 Test edge case: aim assist with 0 enemies → no errors, arrow flies straight
- [x] 8.5 Test performance: 10 enemies on screen, rapid shooting → 60 FPS maintained
- [x] 8.6 Confirm hitbox sizes feel right: player feels hard to hit, arrows feel generous
