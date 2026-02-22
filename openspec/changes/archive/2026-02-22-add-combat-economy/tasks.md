# Tasks: Combat Economy System

## Phase 1: Sun Shards (Pickups)

### 1.1 Shard Scene Setup
- [x] Create `scenes/pickups/sun_shard.tscn` with Area2D root
- [x] Add Sprite2D (placeholder: yellow diamond 8x8)
- [x] Add CollisionShape2D (Circle, r=12)
- [x] Add PointLight2D (subtle glow)
- [x] Configure collision: layer 0, mask player

### 1.2 Shard Script - Core Behavior
- [x] Create `scripts/pickups/sun_shard.gd`
- [x] Implement spawn with random upward velocity
- [x] Implement physics bounce (0.3s duration, gravity dampening)
- [x] Implement idle bob animation (±2px, 1.5s cycle)

### 1.3 Shard Script - Magnetic Pull
- [x] Detect player within 80px radius
- [x] Implement acceleration towards player
- [x] Add sprite stretch in movement direction

### 1.4 Shard Script - Collection
- [x] Emit `shard_collected` signal on player contact
- [x] Play collection particle burst (VFXManager)
- [x] Play collection SFX (AudioManager)
- [x] Implement scale tween death animation
- [x] Implement 5-second auto-collect fallback

### 1.5 Enemy Drop Integration
- [x] Add `drop_chance` export var to base_enemy.gd (default 0.6)
- [x] Connect enemy death to `shard_dropped` signal
- [x] Spawn shard at enemy death position

**Validation**: Kill enemy → shard spawns with bounce → magnetizes → collects

---

## Phase 2: Energy Meter (HUD)

### 2.1 Meter Scene Setup
- [x] Create `scenes/ui/energy_meter.tscn` with Control root
- [x] Add BackgroundCircle (dim outline, 24x24)
- [x] Add FillCircle with radial fill mask
- [x] Add FeatherIcon (centered, 12x12)
- [x] Add ReadyGlow overlay (initially hidden)

### 2.2 Meter Script - Fill Logic
- [x] Create `scripts/ui/energy_meter.gd`
- [x] Connect to `energy_meter_changed` signal
- [x] Implement radial fill animation (0-100%)
- [x] Define color gradient (yellow → orange)

### 2.3 Meter Script - Ready State
- [x] Connect to `energy_meter_full` signal
- [x] Show ReadyGlow with pulse animation
- [x] Play "ready" SFX
- [x] Store `is_ready` state
- [x] Add shard icon in center (12x12)

### 2.4 Meter Script - Firing State
- [x] Connect to `energy_meter_emptied` signal
- [x] Flash white on fire
- [x] Animate drain to 0%

### 2.5 HUD Integration
- [x] Add EnergyMeter to `scenes/ui/hud.tscn`
- [x] Position below dash cooldown bar (8px gap)
- [x] Test with debug key to fill meter

**Validation**: Collect shards → meter fills → glows at 100%

---

## Phase 3: Sun-Piercer (Ultimate Attack)

### 3.1 Input Mapping
- [x] Add `special_attack` action to Project Settings
- [x] Bind Mouse Middle Button (button_index 3)
- [x] Bind Q key

### 3.2 Sun-Piercer Scene Setup
- [x] Create `scenes/player/sun_piercer.tscn` with Area2D root
- [x] Add Sprite2D (placeholder: orange ellipse 32x16)
- [x] Add CollisionShape2D (Rectangle, 32x12)
- [x] Add PointLight2D (bright glow)
- [x] Add TrailParticles (fire effect)
- [x] Configure collision: layer arrow, mask enemy + wall

### 3.3 Sun-Piercer Script - Movement
- [x] Create `scripts/player/sun_piercer.gd`
- [x] Implement directional movement (400 px/s)
- [x] Implement 2-second lifetime or off-screen cleanup

### 3.4 Sun-Piercer Script - Damage & Pierce
- [x] Detect enemy collisions
- [x] Deal 80 damage per hit
- [x] Implement pierce (pass through enemies)
- [x] Track obstacle pierce count (max 3)
- [x] Emit `special_attack_hit` signal per enemy

### 3.5 Player Integration - Wind-up
- [x] Add `is_windup` state to player
- [x] Implement 0.25s wind-up animation
- [x] Player flash during wind-up
- [x] Screen shake on wind-up start (0.2 trauma)
- [x] Play wind-up SFX

### 3.6 Player Integration - Fire
- [x] Check meter is full before firing
- [x] Consume meter (emit `energy_meter_emptied`)
- [x] Spawn Sun-Piercer at player position
- [x] Set direction to aim direction
- [x] Play fire SFX + camera push

### 3.7 Hit Feedback
- [x] Trigger hitstop (0.15s) per enemy hit
- [x] Spawn damage numbers
- [x] Screen shake on hits (0.1 trauma per hit)
- [x] Enemy hit flash (via take_damage)

**Validation**: Full meter → press Q → wind-up → fire → pierce enemies

---

## Phase 4: Polish & Integration

### 4.1 Audio
- [x] Shard collect chime SFX
- [x] Meter ready SFX (ascending tone)
- [x] Sun-Piercer wind-up SFX
- [x] Sun-Piercer fire whoosh SFX
- [x] Sun-Piercer hit impact SFX

### 4.2 Visual Polish
- [x] Replace placeholder shard sprite with pixel art (diamond/crystal shape)
- [x] Replace placeholder Sun-Piercer sprite with pixel art
- [x] Add shard spawn particle burst
- [x] Add Sun-Piercer trail particles

### 4.3 EventBus Updates
- [x] Add new signals to `event_bus.gd`
- [x] Document signal contracts in comments

### 4.4 Balance Testing
- [x] Test shard drop rate feels fair
- [x] Test meter fill rate (~6-8 kills)
- [x] Test Sun-Piercer damage vs enemies
- [x] Adjust parameters as needed

**Validation**: Full playtest of combat economy flow

---

## Parallelization

| Stream | Dependencies | Can Run Parallel With |
|--------|--------------|----------------------|
| Phase 1: Shards | None | Phase 2.1-2.4 (meter UI without signals) |
| Phase 2: Meter | Phase 1.5 (shard signal) | Phase 1.1-1.4 |
| Phase 3: Sun-Piercer | Phase 2 (meter ready state) | None |
| Phase 4: Polish | Phase 3 | None |

Recommended order: 1.1-1.4 + 2.1-2.4 in parallel → 1.5 + 2.5 → 3 → 4
