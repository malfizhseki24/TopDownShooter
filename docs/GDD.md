# Game Design Document

## WARRIOR OF THE SUNRISE
*Working Title*

---

## Overview

| Property | Value |
|----------|-------|
| **Genre** | Top-Down Action Shooter (Stage-based) |
| **Dimension** | 2D |
| **Art Style** | Pixel Art |
| **Tile Size** | 32x32 |
| **Character Max Size** | 128x128 |
| **Combat Style** | Methodical (aim carefully, fewer enemies) |
| **Engine** | Godot 4.6 |
| **Target Platform** | PC (Windows, macOS, Linux) |

---

## Lore & Story

### The Fallen Demigod: KASUARI

**Origin Myth (Based on Sentani & Fakfak Folklore)**

Kasuari was once a bird with magnificent wide wings capable of soaring through the skies. However, consumed by greed and arrogance, it committed a great betrayal. As punishment, its wings were broken (in some versions by the Crowned Dove or Pipit bird), condemning it to become a flightless bird forever bound to walk the earth.

### Game Adaptation

**Protagonist - "Kasuari" (Code Name/Title)**

- **True Identity**: A former War Chief / High General
- **The Fall**: Once a proud and arrogant military leader whose hubris led to a catastrophic defeat. Stripped of honor, rank, and spiritual power ("wings broken")
- **Current State**: Condemned to the Underworld / Forbidden Forest
- **Goal**: Fight through stages to seek redemption and reclaim honor

### Visual Design - Kasuari

| Element | Description |
|---------|-------------|
| **Armor** | Made of bone and thick black feathers resembling a Cassowary |
| **Helmet** | Features the iconic hard "Casque" (helmet crest) |
| **Color Palette** | Black, deep blue, bone white, accents of blood red |
| **Silhouette** | Towering, imposing figure with horned helmet |

---

## Core Gameplay

### Gameplay Loop

```
Stage Start → Explore → Combat Encounters → Stage Boss → Victory Screen → Main Menu
```

### Controls (TBD)

| Action | Input |
|--------|-------|
| Move | WASD / Arrow Keys |
| Aim | Mouse / Right Stick |
| Shoot Arrow | Left Click / RT |
| Heavy Attack / Special | Right Click / LT |
| Dash / Dodge | Space / A Button |
| Interact | E / X Button |

### Core Mechanics

- **Bow & Arrow**: Primary ranged combat with arrow physics, infinite arrows
- **Melee System**: Secondary close-quarters combat with the Casque (heavy attack)
- **Dash/Dodge**: I-frame based evasion with cooldown
- **Stage-Based Progression**: Single level culminating in boss fight
- **Boss Fights**: Shadow Boar encounter with 2 phases

### Arrow System

| Property | Value |
|----------|-------|
| **Ammo** | Infinite |
| **Fire Rate** | 0.5 sec between shots (methodical pace) |
| **Arrow Speed** | 600 px/sec |
| **Arrow Lifetime** | 3 seconds (despawn if no hit) |
| **Damage** | 25 per arrow |

### Camera System

| Property | Value |
|----------|-------|
| **Type** | Smooth follow (lerp) |
| **Follow Speed** | 5.0 |
| **Offset** | Centered on player |
| **Look Ahead** | None (MVP simplicity) |

---

## Game Structure

### Stage Design Philosophy

- Linear progression toward boss arena
- Enemy encounters in cleared areas
- No environmental hazards (MVP simplicity)
- No collectibles (MVP simplicity)

### Enemy Types: Shadow Creatures

Manifestations of Kasuari's past sins and corrupted spirits of the forbidden forest.

| Enemy | HP | Damage | Speed | Behavior |
|-------|-----|--------|-------|----------|
| **Shadow Wisp** | 25 | 10 | Slow | Floating, slow homing toward player |
| **Shadow Crawler** | 40 | 15 | Fast | Ground movement, attacks in groups of 2-3 |
| **Shadow Stalker** | 60 | 20 | Medium | Teleports every 2 sec, ambush attack |
| **Shadow Brute** | 150 | 30 | Slow | Tanky, charges player when in range |

#### Enemy Design Notes

- **Visual**: Dark silhouettes with glowing eyes (color indicates type)
- **Spawn**: Emerge from shadow pools on the ground
- **Death FX**: Dissolve into black particles
- **Max On Screen**: 8-10 (methodical combat)

### Boss: SHADOW BOAR

A massive boar consumed by shadow, representing untamed rage and gluttony.

| Property | Value |
|----------|-------|
| **Total HP** | 500 |
| **Phase 2 Trigger** | 250 HP (50%) |
| **Contact Damage** | 25 |
| **Charge Damage** | 40 |
| **Shockwave Damage** | 20 |

#### Phase 1: Rampage (500-250 HP)
- Charges across arena in straight lines
- Leaves shadow trails that damage player
- Vulnerable after charging into walls (stunned 2 sec)

#### Phase 2: Shadow Storm (250-0 HP)
- Summons 2 Shadow Wisps every 8 seconds
- Ground slam creates expanding shadow shockwave
- Charge attacks become 30% faster

#### Design Notes
- **Visual**: Oversized boar with shadow aura, glowing red eyes, black mist emanating from body
- **Size**: 192x128 (larger than regular enemies)
- **Arena**: Open clearing with destructible pillars (for cover during charges)
- **Telegraphing**: Snort + paw ground animation (1 sec) before charge

---

## Visual & Audio

### Art Direction

- **Style**: Pixel Art
- **Tile Size**: 32x32
- **Character Max Size**: 128x128 (Pixellab constraint)
- **Influences**: Tribal, Papuan indigenous art motifs
- **Environment**: Dense jungle, ancient ruins, spiritual underworld

### Color Palette

| Usage | Colors (Hex) |
|-------|-------------|
| **Kasuari Primary** | `#1a1a2e` (dark blue-black), `#16213e` (navy) |
| **Kasuari Accent** | `#e94560` (blood red), `#f1f1f1` (bone white) |
| **Shadow Enemies** | `#0f0f0f` (black), `#2d132c` (dark purple) |
| **Shadow Glow** | `#ee4540` (red glow), `#70c1b3` (cyan - rare type) |
| **Environment** | `#1e3a1e` (dark green), `#3d2914` (brown), `#1a1a2e` (night sky) |
| **UI** | `#f1f1f1` (white), `#e94560` (red accent) |

### Audio Direction

**Philosophy**: Fusion of traditional Papuan/Indonesian instruments with modern electronic beats. Intense but atmospheric.

| Layer | Style | Purpose |
|-------|-------|---------|
| **Base** | Tifa / Kendang (traditional drums) | Rhythmic foundation |
| **Melody** | Suling (bamboo flute) samples | Haunting, mystical atmosphere |
| **Intensity** | Synth bass + electronic beats | Combat energy, modern feel |
| **Accent** | Tribal vocal chants | Boss moments, high tension |

#### Audio by Game State

| State | Music Style |
|-------|-------------|
| **Exploration** | Slow tribal drums, ambient nature sounds, soft suling |
| **Combat** | Intense beat drop, synth bass, faster Tifa patterns |
| **Boss** | Full fusion - heavy drums + synth + vocal chants |
| **Victory** | Triumphant traditional melody, fading to ambient |

#### SFX Priority List

1. Bow draw & release (satisfying "twang")
2. Arrow hit impact
3. Dash/dodge whoosh
4. Enemy death dissolve
5. Shadow spawn emergence
6. Boss charge telegraph
7. UI confirm/deny

---

## AI Asset Pipeline (Vibe Code)

### Asset Sources

| Asset Type | Source | Notes |
|------------|--------|-------|
| **Characters** | Pixellab | Max 128x128, use prompts below |
| **Environment Tiles** | Pixellab | 32x32 tiles |
| **VFX** | Internet search | Free particle effects, sprite sheets |
| **SFX** | Internet search | Freesound.org, pixabay.com/music |
| **Music** | AI generation / Internet search | Traditional + electronic fusion |

### Pixellab Prompts - Characters

#### Kasuari (Player)
```
Pixel art character, 128x128, top-down view, tribal warrior with cassowary bone armor,
black feather helmet with casque horn, holding bow, dark blue and black color scheme,
blood red accents, bone white details, 4-directional, idle pose, pixel art style
```

**Animation Frames Needed:**
| Animation | Frames | Size |
|-----------|--------|------|
| Idle (per direction) | 4 | 128x128 |
| Walk (per direction) | 6 | 128x128 |
| Shoot (per direction) | 4 | 128x128 |
| Dash (per direction) | 3 | 128x128 |
| Death | 6 | 128x128 |

#### Shadow Wisp
```
Pixel art enemy, 64x64, top-down view, floating shadow orb with glowing red eyes,
dark silhouette, wispy trail, simple animated blob shape, black with red glow
```

#### Shadow Crawler
```
Pixel art enemy, 64x64, top-down view, quadruped shadow creature, fast crawler,
dark silhouette with cyan glowing eyes, spindly legs, black purple gradient
```

#### Shadow Stalker
```
Pixel art enemy, 96x96, top-down view, humanoid shadow figure, hooded silhouette,
glowing white eyes, ethereal cloak, teleport pose, dark purple black
```

#### Shadow Brute
```
Pixel art enemy, 128x128, top-down view, large hulking shadow monster,
glowing red eyes, bulky armored silhouette, slow heavy presence, black with red accents
```

#### Shadow Boar (Boss)
```
Pixel art boss, 192x128, top-down view, massive demonic boar with shadow aura,
glowing red eyes, black mist emanating, tusks, oversized, intimidating, dark with red glow
```

### Pixellab Prompts - Environment

#### Ground Tiles (32x32)
```
Pixel art tile, 32x32, dark jungle floor, dirt and roots, dark green and brown,
top-down view, seamless tile, Papuan forest theme
```

#### Wall Tiles (32x32)
```
Pixel art tile, 32x32, ancient stone ruins, moss-covered rocks, dark green brown,
top-down view, seamless tile, tribal carving details
```

#### Shadow Pool (Spawn Point)
```
Pixel art effect, 64x64, dark shadow pool on ground, swirling black liquid,
purple glow edges, animated spawn point, top-down
```

### VFX Search Keywords

| Effect | Search Terms |
|--------|--------------|
| Arrow trail | "pixel art arrow trail sprite", "projectile effect 2d" |
| Enemy death | "pixel art death particles", "enemy dissolve sprite" |
| Hit impact | "pixel art hit effect", "impact flash sprite" |
| Shadow spawn | "dark portal sprite", "summon effect pixel" |
| Boss shockwave | "shockwave sprite sheet", "ground slam effect 2d" |
| Dash trail | "dash afterimage sprite", "motion blur pixel" |

### SFX Search Sources & Keywords

| Sound | Source | Search Terms |
|-------|--------|--------------|
| Bow draw | Freesound.org | "bow draw", "arrow pull" |
| Arrow release | Freesound.org | "bow release", "arrow shoot" |
| Arrow hit | Freesound.org | "arrow impact", "arrow hit flesh" |
| Dash | Freesound.org | "whoosh", "dash sound" |
| Enemy hit | Freesound.org | "hit flesh", "impact soft" |
| Enemy death | Freesound.org | "shadow dissolve", "monster death" |
| Boss charge | Freesound.org | "boar grunt", "beast roar" |
| UI click | Freesound.org | "menu click", "ui select" |

### Hit Feedback System

| Event | Visual | Audio | Duration |
|-------|--------|-------|----------|
| **Player Hit** | Screen flash red, camera shake | Hurt grunt | 0.2 sec |
| **Enemy Hit** | Flash white, knockback | Hit sound | 0.1 sec |
| **Enemy Death** | Dissolve particles | Death sound | 0.5 sec |
| **Boss Hit** | Flash white, slight shake | Heavy hit | 0.15 sec |
| **Player Death** | Screen fade, player fall | Death sound | 1.0 sec |

---

## Technical Specifications

### Built With

- **Engine**: Godot 4.6 (2D)
- **Physics**: Godot Physics 2D
- **Language**: GDScript

### Player Stats

| Property | Value |
|----------|-------|
| **Max HP** | 100 |
| **Move Speed** | 200 px/sec |
| **Dash Speed** | 400 px/sec |
| **Dash Duration** | 0.2 sec |
| **Dash Cooldown** | 1.0 sec |
| **Dash I-Frames** | 0.15 sec |
| **Melee Damage** | 35 |
| **Melee Range** | 64 px |

### Performance Targets

| Target | Value |
|--------|-------|
| **Frame Rate** | 60 FPS stable |
| **Max Enemies On Screen** | 10 (methodical combat) |
| **Resolution** | 1920x1080 (scalable) |
| **Viewport** | 480x270 (pixel perfect, 4x scale) |

### Scope: First Iteration (MVP)

**What's IN:**
- 1 playable character (Kasuari) with bow & arrow + dash + melee
- 4 enemy types (Shadow creatures)
- 1 boss (Shadow Boar with 2 phases)
- 1 complete stage/level
- Basic HUD (health bar)
- Hit feedback system (flash, shake, hitstop)
- Main menu + pause menu
- Victory screen → return to menu

**What's OUT (for now):**
- Multiple stages
- Upgrades/progression system
- Save/load system
- Multiple weapons
- Dialogue/story cutscenes
- Environmental hazards
- Collectibles
- Arrow count (infinite ammo)

---

## Development Roadmap

### Phase 1: Foundation
- [ ] Project structure setup (folders, autoloads)
- [ ] Pixel perfect camera setup (480x270 viewport)
- [ ] Smooth follow camera
- [ ] Player movement (8-directional, 200 px/sec)
- [ ] Player aiming (mouse direction)
- [ ] Bow & arrow shooting (0.5 sec fire rate, infinite)

### Phase 2: Player Polish
- [ ] Dash/dodge (400 px/sec, 0.2 sec, 1.0 sec cooldown)
- [ ] I-frames system (0.15 sec)
- [ ] Melee attack (35 damage, 64 px range)
- [ ] Player health system (100 HP)
- [ ] Player death & respawn
- [ ] Player hit feedback (flash red, shake)

### Phase 3: Enemies
- [ ] Base enemy class (HP, damage, speed, behavior)
- [ ] Shadow Wisp (25 HP, slow homing)
- [ ] Shadow Crawler (40 HP, fast, groups)
- [ ] Shadow Stalker (60 HP, teleport every 2 sec)
- [ ] Shadow Brute (150 HP, charge attack)
- [ ] Enemy spawn system (shadow pools)
- [ ] Enemy hit feedback (flash white, knockback)
- [ ] Enemy death (dissolve particles)

### Phase 4: Boss
- [ ] Boss arena scene
- [ ] Shadow Boar base (500 HP)
- [ ] Phase 1: Charge attack, shadow trails, wall stun
- [ ] Phase 2 trigger (250 HP)
- [ ] Phase 2: Wisp summon, shockwave, faster charges
- [ ] Boss health bar UI
- [ ] Boss death → victory trigger

### Phase 5: Level & UI
- [ ] Stage 1 layout (tiles, walls)
- [ ] Basic HUD (health bar)
- [ ] Main menu (Start, Quit)
- [ ] Pause menu (Resume, Quit)
- [ ] Game over screen (Restart, Quit)
- [ ] Victory screen (return to menu)

### Phase 6: Polish & Juice
- [ ] Screen shake on player hit
- [ ] Hitstop (0.1 sec) on enemy hit
- [ ] Arrow trail VFX
- [ ] Shadow pool spawn animation
- [ ] SFX implementation (bow, hit, death, UI)
- [ ] Music implementation (exploration, combat, boss)
- [ ] Balancing pass (test all values)

---

## Changelog

| Date | Changes |
|------|---------|
| 2026-02-17 | Initial GDD creation |
| 2026-02-17 | Updated: 2D pixel art, bow & arrow weapon |
| 2026-02-17 | Added: Enemy types, Shadow Boar boss, audio direction, MVP scope, detailed roadmap |
| 2026-02-17 | Completed: Player stats, enemy stats, boss stats, arrow system, camera system, color palette, AI asset pipeline (Pixellab prompts), VFX/SFX search keywords, hit feedback system, pixel perfect viewport |

---

*This is a living document. Update as the project evolves.*
