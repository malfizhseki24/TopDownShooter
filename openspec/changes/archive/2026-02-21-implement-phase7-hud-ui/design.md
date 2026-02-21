## Context

Phase 7 delivers the complete in-game HUD as specified in the GDD's "In-Game HUD Design (MVP)" section. The current implementation uses a basic ProgressBar and Labels embedded directly in game.tscn — functional but lacking visual identity, feedback layering, and the "whisper not shout" design philosophy described in the GDD.

The game's 480x270 viewport (scaled 4x to 1080p) means every pixel matters. HUD elements must be compact, translucent, and signal-driven to avoid clutter during combat.

## Goals / Non-Goals

**Goals:**
- Implement all 6 HUD elements from GDD spec with exact colors, sizes, and animations
- Signal-driven architecture — HUD never polls game state, only reacts to EventBus signals
- Each HUD element is a self-contained scene for reuse and testability
- `process_mode = ALWAYS` so HUD updates during hitstop/slow-mo
- Floating damage numbers and interact prompts are world-space (not screen-space HUD)

**Non-Goals:**
- Settings menu / options screen (post-MVP)
- Gamepad UI hints (post-MVP)
- Accessibility options (post-MVP)
- Redesigning main menu, pause menu, game over, victory screen (already functional)

## Technical Decisions

### Decision: Extract HUD into dedicated scene

**What**: Move HUD from inline nodes in game.tscn into a standalone `hud.tscn` with `hud.gd` script.

**Why**: Current game.tscn mixes game logic (room management, player spawning, camera) with HUD management (_on_health_changed, _update_room_label, etc). Separating concerns means:
- HUD can be tested independently
- game.gd shrinks to game flow only
- Each HUD element is a child scene, easily swappable

**How**: `hud.tscn` is a CanvasLayer (layer=10, process_mode=ALWAYS) instanced in game.tscn. Its script `hud.gd` connects to EventBus signals and delegates to child elements.

### Decision: ColorRect-based bars (not ProgressBar)

**What**: Use ColorRect nodes with manual width tweening for health bars instead of Godot's ProgressBar.

**Why**: ProgressBar doesn't support:
- Damage trail ghost bar (second fill that drains slowly)
- Phase color transitions
- Per-pixel control at 480x270 viewport scale
- NinePatchRect borders with custom art

ColorRect with `size.x` tweening gives full control over every visual detail.

### Decision: Floating damage numbers as independent scene instances

**What**: Each damage number is an independent Node2D (not a child of the damaged entity).

**Why**: If a damage number is parented to an enemy and that enemy dies mid-float, the number vanishes. By spawning damage numbers into a persistent `DamageNumberLayer` node in the game scene, they survive entity death and float smoothly to completion.

### Decision: World-space interact prompts (not HUD overlay)

**What**: [E] prompts are Control nodes parented to interactable objects, positioned 16px above the sprite in world space.

**Why**: Players' eyes are on the interactable they're approaching. A HUD-corner prompt forces a saccade — the player must look away from the action. World-space prompts keep attention where it matters.

### Decision: Additive EventBus signals (no breaking changes)

**What**: Add new signals to EventBus rather than modifying existing ones.

**Why**: Existing signals like `health_changed`, `boss_spawned`, `boss_died` are already connected throughout the codebase. New HUD-specific signals (e.g., `damage_dealt` with position data) are added alongside, and HUD elements connect to whichever signals they need.

**New signals to add:**
```gdscript
signal damage_dealt(position: Vector2, amount: int, type: StringName)
signal damage_taken(position: Vector2, amount: int, type: StringName)
```

Existing signals already sufficient for other HUD elements:
- `health_changed(current, maximum)` — health bar
- `player_dash_started(cooldown_duration)` — dash bar
- `player_dash_ready` — dash bar reset
- `room_loaded(room_index)` — room progress
- `boss_spawned(boss)` — boss health bar
- `enemy_hit(enemy, damage)` — boss health bar damage
- `boss_phase_changed(phase)` — boss health bar color
- `boss_died(boss)` — boss health bar dismiss
- `show_interact_prompt(message)` / `hide_interact_prompt` — [E] prompts
- `player_healed(amount)` — heal damage numbers

## Visual Specifications

### Color Palette (from GDD)

| Token | Hex | Usage |
|-------|-----|-------|
| `bg_dark` | `#1a1a2e` | Bar backgrounds |
| `health_fill` | `#e94560` | Player HP fill |
| `health_low` | `#ff2040` | Low HP pulse |
| `health_trail` | `#f1f1f1` | Damage trail ghost bar |
| `heal_tint` | `#70c1b3` | Heal flash, heal numbers |
| `dash_charge` | `#16213e` | Dash bar charging |
| `dash_ready` | `#70c1b3` | Dash bar ready flash |
| `boss_fill_p1` | `#ee4540` | Boss HP Phase 1 |
| `boss_fill_p2` | `#2d132c` | Boss HP Phase 2 |
| `text_white` | `#f1f1f1` | UI text, arrow damage numbers |
| `text_melee` | `#f0e68c` | Melee damage numbers |
| `text_hurt` | `#e94560` | Player damage taken |
| `text_boss_hurt` | `#ff2040` | Boss → player damage |
| `outline` | `#0f0f0f` | Bar borders |

### Size Specifications (viewport pixels, 480x270)

| Element | Size | Position |
|---------|------|----------|
| Player HP bar | 80 x 8 px | Top-left, 8px from edges |
| HP bar border | 1px outline | Around HP bar |
| Damage trail bar | Same as HP bar | Behind HP fill |
| Dash cooldown bar | 48 x 4 px | Below HP bar, 8px left |
| Dash icon | 5 x 5 px | Left of dash bar |
| Room dots | 5 x 5 px each, 3px gap | Top-right, 8px from edges |
| Boss dot (room 7) | 7 x 7 px | Last in room dots row |
| Boss HP bar | 240 x 10 px | Bottom-center, 12px from bottom |
| Boss HP border | 2px outline | Around boss HP bar |
| Boss name label | 7px font | Centered above boss HP bar |
| Damage numbers | 5–8px font | World-space at hit point |
| Interact prompt [E] | 7px font | 16px above interactable |
| Interact sub-label | 5px font | Below [E] prompt |

### Animation Specifications

| Animation | Duration | Easing | Details |
|-----------|----------|--------|---------|
| HP damage trail drain | 0.4 sec | Linear | White ghost bar shrinks to match new HP |
| HP heal flash | 0.2 sec | Instant fill, green tint fades | Fill expands immediately |
| Low HP pulse | Continuous | `sin(time * 6.0)` | Alpha oscillates 0.6–1.0 |
| HP text fade in/out | 1.5 sec visible | Fade in 0.15s, fade out 0.15s | Shows "72/100" then hides |
| Dash bar fill | 1.0 sec (cooldown) | Linear left-to-right | Matches actual cooldown duration |
| Dash ready flash | 0.15 sec cyan | Flash then 0.3s fade out | Bar becomes invisible |
| Room dot pulse | 0.2 sec | Scale 150% → 100% | On room change |
| Boss bar slide in | 0.5 sec | Ease-out | Slides up from below viewport |
| Boss name fade in | 0.3 sec | Linear | 0.3s delay after bar arrives |
| Boss bar phase flash | 0.3 sec | Linear | White flash, color transition |
| Boss bar defeat fade | 0.5 sec | Linear | Fades out |
| Damage number float | 0.6 sec | Ease-out quad | 40px up (dealt) or down (taken) |
| Damage number scale pop | 0.1 sec | Ease-out | 150% → 100% |
| Damage number fade | 0.3 sec | Linear | Final 0.3s of 0.6s lifetime |
| Interact prompt appear | 0.15 sec | Linear | Alpha 0→1, float up 4px |
| Interact prompt disappear | 0.1 sec | Linear | Alpha 1→0 |
| Interact prompt bob | 1.5 sec period | Sine | ±1px vertical |

## PixelLab Asset Reference

Generated HUD frame asset:
- `assets/sprites/ui/health_bar_frame.png` — Tribal-themed ornate health bar border (96x96 pixel art, dark carved wood/bone motif)
- This will be sliced into a NinePatchRect for scalable bar borders

## Scene Tree Architecture

```
Game (Node2D)
├── RoomManager
├── Entities
├── Interactables
├── DamageNumberLayer (Node2D)              # Persistent container for floating numbers
├── Camera2D
└── HUD (CanvasLayer, layer=10, process_mode=ALWAYS)
    ├── PlayerHealthBar (Control)
    │   ├── BarBackground (ColorRect)        # #1a1a2e, 60% alpha
    │   ├── DamageTrail (ColorRect)          # #f1f1f1, tweens width on damage
    │   ├── BarFill (ColorRect)              # #e94560
    │   ├── BarBorder (NinePatchRect)        # 1px #0f0f0f outline
    │   └── HPText (Label)                   # Optional, fades in/out
    ├── DashCooldown (Control)
    │   ├── DashIcon (Label)                 # Diamond glyph
    │   ├── DashBarBG (ColorRect)            # #1a1a2e, 40% alpha
    │   └── DashBarFill (ColorRect)          # Width tweened over cooldown
    ├── RoomProgress (HBoxContainer)
    │   └── RoomDot1–7 (ColorRect)           # Programmatic circles
    ├── BossHealthBar (Control, visible=false)
    │   ├── BossName (Label)                 # "SHADOW BOAR"
    │   ├── BarBackground (ColorRect)
    │   ├── DamageTrail (ColorRect)
    │   ├── BarFill (ColorRect)
    │   └── BarBorder (NinePatchRect)
    ├── GameOver (instance)
    ├── VictoryScreen (instance)
    ├── PauseMenu (instance)
    └── FadeRect (ColorRect)                 # Room transition overlay
```

Interactable scenes gain a child:
```
HealShrine / RoomPortal
└── InteractPrompt (Control)
    ├── KeyLabel (Label)                     # "[E]"
    └── ActionLabel (Label)                  # "Heal" / "Enter"
```

## Open Questions

None — the GDD provides complete specifications for all 6 HUD elements with exact values.
