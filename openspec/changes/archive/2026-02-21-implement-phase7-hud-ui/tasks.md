## 1. HUD Architecture Setup

- [x] 1.1 Create `scenes/ui/hud.tscn` (CanvasLayer, layer=10, process_mode=ALWAYS) with placeholder child nodes for each HUD element
- [x] 1.2 Create `scripts/ui/hud.gd` — connect to all EventBus signals and delegate to child HUD elements
- [x] 1.3 Replace inline HUD nodes in `scenes/levels/game.tscn` with instanced `hud.tscn`; remove HUD logic from `scripts/levels/game.gd` (keep only game flow: room transitions, player spawn, fade overlay)
- [x] 1.4 Add `DamageNumberLayer` (Node2D) as sibling of Entities in game.tscn for persistent floating numbers
- [x] 1.5 Add `damage_dealt(position: Vector2, amount: int, type: StringName)` and `damage_taken(position: Vector2, amount: int, type: StringName)` signals to `scripts/autoload/event_bus.gd`
- [x] 1.6 Verify HUD loads and game flow still works (room label, health, boss bar unbroken)

## 2. Player Health Bar

- [x] 2.1 Create `scenes/ui/health_bar.tscn` — Control with BarBackground (ColorRect #1a1a2e 60% alpha), DamageTrail (ColorRect #f1f1f1), BarFill (ColorRect #e94560), BarBorder (NinePatchRect 1px #0f0f0f), HPText (Label 5px font)
- [x] 2.2 Create `scripts/ui/health_bar.gd` — `update_health(current, maximum)` method: set BarFill width, tween DamageTrail width over 0.4s, show/fade HPText "72/100" for 1.5s
- [x] 2.3 Implement low-HP pulse: when HP <= 25, shift fill color to #ff2040 and oscillate alpha via `sin(time * 6.0)` in `_process()`
- [x] 2.4 Implement heal flash: on HP gain, instant fill expansion + green tint #70c1b3 for 0.2s
- [x] 2.5 Instance health_bar.tscn in hud.tscn at position (8, 8); wire `EventBus.health_changed` → `health_bar.update_health()`
- [x] 2.6 Playtest: take damage (verify trail drains), heal at shrine (verify green flash), reach low HP (verify pulse)

## 3. Dash Cooldown Indicator

- [x] 3.1 Create `scenes/ui/dash_cooldown.tscn` — Control with DashIcon (TextureRect using dash_icon.png, 5x5), DashBarBG (ColorRect #1a1a2e 40% alpha, 48x4), DashBarFill (ColorRect #16213e)
- [x] 3.2 Create `scripts/ui/dash_cooldown.gd` — `start_cooldown(duration)`: fade bar in to 40% opacity, tween fill width 0→48 over duration; `on_ready()`: flash cyan #70c1b3 for 0.15s, fade entire bar to 0% over 0.3s
- [x] 3.3 Instance dash_cooldown.tscn in hud.tscn at position (8, 18); wire `EventBus.player_dash_started` → `start_cooldown()`, `EventBus.player_dash_ready` → `on_ready()`
- [x] 3.4 Playtest: dash and verify bar appears, fills, flashes cyan, and vanishes

## 4. Room Progress Indicator

- [x] 4.1 Create `scenes/ui/room_progress.tscn` — HBoxContainer anchored top-right with 7 ColorRect dots (5x5 each, 3px separation; dot 7 is 7x7)
- [x] 4.2 Create `scripts/ui/room_progress.gd` — `update_progress(current_room, total_rooms)`: color completed dots white #f1f1f1, current dot red #e94560 with alpha pulse, future dots #f1f1f1 at 30%; heal rooms (3, 6) get green tint #70c1b3 when completed; boss dot (7) gets #ee4540 when current
- [x] 4.3 Implement room transition pulse: on room change, scale current dot to 150% → 100% over 0.2s
- [x] 4.4 Instance room_progress.tscn in hud.tscn; wire `EventBus.room_loaded` → `update_progress()`
- [x] 4.5 Playtest: progress through rooms and verify dots update, pulse, and color correctly

## 5. Boss Health Bar Upgrade

- [x] 5.1 Refactor `scenes/ui/boss_health_bar.tscn` — replace ProgressBar with ColorRect-based bar (240x10, BarBackground, DamageTrail, BarFill, BarBorder 2px) anchored bottom-center, 12px from bottom
- [x] 5.2 Update `scripts/ui/boss_health_bar.gd` — add damage trail (white ghost bar drains over 0.6s), slide-in from below viewport over 0.5s ease-out, boss name "SHADOW BOAR" fades in 0.3s after bar arrives
- [x] 5.3 Implement phase 2 transition FX: on `boss_phase_changed(2)`, flash bar white for 0.15s, tween fill color #ee4540 → #2d132c over 0.3s
- [x] 5.4 Implement defeat animation: on `boss_died`, fade bar out over 0.5s
- [x] 5.5 Playtest: fight boss, verify slide-in, damage trail, phase transition flash, and defeat fade

## 6. Floating Damage Numbers

- [x] 6.1 Create `scenes/ui/damage_number.tscn` — Node2D with Label child; create `scripts/ui/damage_number.gd` with `setup(value, color, font_size, is_heal, float_up)` method
- [x] 6.2 Implement float + fade: tween position.y +/-40px over 0.6s (ease-out quad), scale 150%→100% over 0.1s, fade alpha over final 0.3s, queue_free at end
- [x] 6.3 Add random +/-8px horizontal offset on spawn to prevent stacking
- [x] 6.4 Wire damage number spawning in `hud.gd`: listen to `EventBus.damage_dealt` and `EventBus.damage_taken`, instantiate damage_number.tscn into DamageNumberLayer with correct color/size/direction per type
- [x] 6.5 Emit `EventBus.damage_dealt` from `scripts/enemies/base_enemy.gd` (on `take_damage`) and `scripts/boss/shadow_boar.gd` with position + amount + type data
- [x] 6.6 Emit `EventBus.damage_taken` from `scripts/player/player.gd` (on damage) with position + amount + type data (distinguish regular enemy vs boss)
- [x] 6.7 Emit `EventBus.damage_dealt` with type `&"heal"` from heal shrine on use
- [x] 6.8 Playtest: shoot enemies (white numbers up), melee enemies (yellow numbers up), get hit (red numbers down), heal (green numbers up)

## 7. Contextual Interaction Prompts

- [x] 7.1 Create `scripts/ui/interact_prompt.gd` — standalone Control script with KeyLabel ("[E]"), ActionLabel ("Heal"/"Enter"), appear/disappear/bob animations
- [x] 7.2 Add InteractPrompt (Control) child node to `scenes/interactables/heal_shrine.tscn` — positioned 16px above sprite, KeyLabel #f1f1f1 7px with 1px #0f0f0f shadow, ActionLabel "Heal" in #70c1b3 5px at 60% opacity
- [x] 7.3 Add InteractPrompt child node to `scenes/interactables/room_portal.tscn` — ActionLabel "Enter" in #f1f1f1 at 60% opacity; show only when portal is active
- [x] 7.4 Wire prompt visibility to existing `show_interact_prompt` / `hide_interact_prompt` signals on each interactable (or use Area2D body_entered/exited directly)
- [x] 7.5 Implement locked portal message: on first approach to inactive portal, show red-tinted #e94560 "Defeat all enemies" text that fades after 2s and does not reappear
- [x] 7.6 Playtest: approach shrine (verify [E] Heal appears with bob), clear room (verify [E] Enter on portal), approach locked portal (verify red message)

## 8. Final Integration & Polish

- [x] 8.1 Wire remaining EventBus connections: ensure all signals flow correctly across full game loop (menu → game → rooms → boss → victory/game_over)
- [x] 8.2 Full playthrough test: menu → Room 1–7 → boss → victory; verify every HUD element activates, updates, and deactivates at correct moments
- [x] 8.3 Check no console errors or orphan nodes (damage numbers cleaned up, prompts removed on room change)
- [x] 8.4 Update GDD Phase 7 checkboxes to reflect completion
