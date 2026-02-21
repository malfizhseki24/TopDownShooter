# Tasks: Character Sprites via PixelLab MCP

## 0. Art Style Reference

All characters use **Octopath Traveler Heroes** art style:
- Chibi proportions (2-3 heads tall, 40% head)
- Clean dark outlines (not pure black)
- Muted color palette
- Soft shading (2-3 shades per color)
- Clear readable silhouettes

## 1. Setup Asset Folders

- [x] 1.1 Create `assets/sprites/characters/player/kasuari/`
- [x] 1.2 Create `assets/sprites/characters/enemies/shadow_wisp/`
- [x] 1.3 Create `assets/sprites/characters/enemies/shadow_crawler/`
- [x] 1.4 Create `assets/sprites/characters/enemies/shadow_stalker/`
- [x] 1.5 Create `assets/sprites/characters/enemies/shadow_brute/`
- [x] 1.6 Create `assets/sprites/characters/boss/shadow_boar/`

## 2. Generate Player Character (Kasuari) - 64x64

- [x] 2.1 Queue Kasuari character creation (64x64, 4-directional, Octopath style)
- [x] 2.2 Queue idle animation → breathing-idle
- [x] 2.3 Queue walk animation → walking-4-frames
- [x] 2.4 Queue shoot animation → lead-jab
- [x] 2.5 Queue dash animation → running-slide
- [x] 2.6 Queue death animation → falling-back-death
- [x] 2.7 Poll status until complete
- [x] 2.8 Download and extract to `assets/sprites/characters/player/kasuari/`

**Target Size:** 64x64 pixels
**Character ID:** 2a45b783-281b-4e81-9bc2-af691e12daaa

**Note:** PixelLab did not generate all 4 directions for every animation:
- breathing-idle: south, east, north (west missing - use flip_h)
- walking-4-frames: south, east, north (west missing - use flip_h)
- lead-jab: east, north, west (south missing - use north or east)
- running-slide: south, east, north, west (complete)
- falling-back-death: south, east, north (west missing - use flip_h)

## 3. Generate Shadow Wisp Enemy - 64x64

- [x] 3.1 Queue Shadow Wisp character creation (64x64, 4-directional, Octopath style)
- [x] 3.2 Queue idle animation → breathing-idle
- [x] 3.3 Queue move animation → walking-4-frames
- [x] 3.4 Queue death animation → falling-back-death
- [x] 3.5 Poll status until complete
- [x] 3.6 Download and extract to `assets/sprites/characters/enemies/shadow_wisp/`

**Target Size:** 64x64 pixels
**Character ID:** c07cdaed-8134-476c-9906-ec36c89291ef

**Note:** Shadow Wisp is an orb/ball-shaped creature (not humanoid).
- breathing-idle: north, south, east (no west - use flip_h)
- walking-4-frames: north, south, east, west (complete)
- falling-back-death: north, south, east, west (complete, 7 frames each)

## 4. Generate Shadow Crawler Enemy - 64x64 (Quadruped)

- [x] 4.1 Queue Shadow Crawler character creation (64x64, 4-directional, quadruped, Octopath style)
- [x] 4.2 Queue idle animation → idle
- [x] 4.3 Queue walk animation → running-4-frames
- [x] 4.4 Queue attack animation → angry
- [x] 4.5 Queue death animation → seated-on-belly-idle
- [x] 4.6 Poll status until complete
- [x] 4.7 Download and extract to `assets/sprites/characters/enemies/shadow_crawler/`

**Target Size:** 64x64 pixels
**Body Type:** Quadruped (cat template)
**Character ID:** 65a13ae1-5f1d-40a6-af5c-0be43449f831

**Animations Generated:**
- idle: 8 frames × 4 directions (complete)
- running-4-frames: 4 frames × 4 directions (complete)
- angry (attack): 7 frames × 4 directions (complete)
- seated-on-belly-idle (death): 10 frames × 4 directions (complete)

## 5. Generate Shadow Stalker Enemy - 64x64

- [x] 5.1 Queue Shadow Stalker character creation (64x64, 4-directional, Octopath style)
- [x] 5.2 Queue idle animation → breathing-idle
- [x] 5.3 Queue walk animation → walking-8
- [x] 5.4 Queue teleport animation → surprise-uppercut
- [x] 5.5 Queue attack animation → cross-punch
- [x] 5.6 Queue death animation → falling-back-death
- [x] 5.7 Poll status until complete
- [x] 5.8 Download and extract to `assets/sprites/characters/enemies/shadow_stalker/`

**Target Size:** 64x64 pixels
**Character ID:** `eb196173-2ed6-4b53-8265-3910d28d1491`

**Animations Generated:**
- breathing-idle: 4 frames × 3 directions (south, north, east)
- walking-8: 6 frames × 4 directions (complete)
- surprise-uppercut (teleport): 7 frames × 3 directions
- cross-punch (attack): 6 frames × 4 directions (complete)
- falling-back-death: 7 frames × 3 directions

## 6. Generate Shadow Brute Enemy - 64x64

- [x] 6.1 Queue Shadow Brute character creation (64x64, 4-directional, Octopath style)
- [x] 6.2 Queue idle animation → breathing-idle
- [x] 6.3 Queue walk animation → walking-6
- [x] 6.4 Queue charge animation → crouched-walking
- [x] 6.5 Queue attack animation → two-footed-jump
- [x] 6.6 Queue death animation → falling-back-death
- [x] 6.7 Poll status until complete
- [x] 6.8 Download and extract to `assets/sprites/characters/enemies/shadow_brute/`

**Target Size:** 64x64 pixels
**Character ID:** `f5049017-c2f2-4185-9362-fc379ef0062e`

**Animations Generated:**
- breathing-idle: 4 frames × 4 directions (complete)
- walking-6: 6 frames × 4 directions (complete)
- crouched-walking (charge): 6 frames × 4 directions (complete)
- two-footed-jump (attack): 7 frames × 4 directions (complete)
- falling-back-death: 7 frames × 4 directions (complete)

## 7. Generate Shadow Boar Boss - 96x96 (Quadruped)

- [x] 7.1 Queue Shadow Boar character creation (96x96, 4-directional, quadruped, Octopath style)
- [x] 7.2 Queue idle animation → idle (9 frames × 4 directions)
- [x] 7.3 Queue walk animation → walk (8 frames × 4 directions)
- [x] 7.4 Queue charge animation → run (8 frames × 4 directions)
- [x] 7.5 Queue slam animation → attack (9 frames × 4 directions)
- [x] 7.6 Queue death animation → jump-attack (8 frames × 4 directions)
- [x] 7.7 Poll status until complete
- [x] 7.8 Download and extract to `assets/sprites/characters/boss/shadow_boar/`

**Target Size:** 96x96 pixels
**Body Type:** Quadruped (bear template)
**Character ID:** `19d3e573-1b15-49b4-9af9-c389c7ded558`

## 8. Import & Configure in Godot

- [x] 8.1 Import all sprites to Godot project (671 .import files)
- [x] 8.2 Configure import settings (Filter: Nearest, Mipmaps: Disabled)
- [x] 8.3 Create SpriteFrame resources for each character
- [x] 8.4 Set up animation players with correct frame timings
- [x] 8.5 Verify pixel-perfect rendering at 4x scale

**Scenes Created:**
- Player: `scenes/player/player.tscn`
- Enemies: `scenes/enemies/shadow_*.tscn` (wisp, crawler, stalker, brute)
- Boss: `scenes/boss/shadow_boar.tscn`

## 9. Verification

- [x] 9.1 All characters display correctly in editor
- [x] 9.2 All animations play smoothly
- [x] 9.3 Color palette matches GDD specifications
- [x] 9.4 Art style consistent (Octopath Traveler reference)
- [x] 9.5 Sizes match design (48/64/96 as specified)

## ✅ CHANGE COMPLETE - Ready to Archive
