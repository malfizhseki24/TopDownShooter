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

- [ ] 4.1 Queue Shadow Crawler character creation (64x64, 4-directional, quadruped, Octopath style)
- [ ] 4.2 Queue idle animation → idle
- [ ] 4.3 Queue walk animation → walk
- [ ] 4.4 Queue attack animation → attack
- [ ] 4.5 Queue death animation → death
- [ ] 4.6 Poll status until complete
- [ ] 4.7 Download and extract to `assets/sprites/characters/enemies/shadow_crawler/`

**Target Size:** 64x64 pixels
**Body Type:** Quadruped (cat template)
**Character ID:** _pending_

## 5. Generate Shadow Stalker Enemy - 64x64

- [ ] 5.1 Queue Shadow Stalker character creation (64x64, 4-directional, Octopath style)
- [ ] 5.2 Queue idle animation → breathing-idle
- [ ] 5.3 Queue walk animation → walking-4-frames
- [ ] 5.4 Queue teleport animation → surprise-uppercut
- [ ] 5.5 Queue attack animation → cross-punch
- [ ] 5.6 Queue death animation → falling-back-death
- [ ] 5.7 Poll status until complete
- [ ] 5.8 Download and extract to `assets/sprites/characters/enemies/shadow_stalker/`

**Target Size:** 64x64 pixels
**Character ID:** _pending_

## 6. Generate Shadow Brute Enemy - 64x64

- [ ] 6.1 Queue Shadow Brute character creation (64x64, 4-directional, Octopath style)
- [ ] 6.2 Queue idle animation → breathing-idle
- [ ] 6.3 Queue walk animation → walking-6-frames
- [ ] 6.4 Queue charge animation → running-4-frames
- [ ] 6.5 Queue attack animation → two-footed-jump
- [ ] 6.6 Queue death animation → falling-back-death
- [ ] 6.7 Poll status until complete
- [ ] 6.8 Download and extract to `assets/sprites/characters/enemies/shadow_brute/`

**Target Size:** 64x64 pixels
**Character ID:** _pending_

## 7. Generate Shadow Boar Boss - 96x96 (Quadruped)

- [ ] 7.1 Queue Shadow Boar character creation (96x96, 4-directional, quadruped, Octopath style)
- [ ] 7.2 Queue idle animation → idle
- [ ] 7.3 Queue walk animation → walk
- [ ] 7.4 Queue charge animation → run
- [ ] 7.5 Queue slam animation → attack
- [ ] 7.6 Queue death animation → death
- [ ] 7.7 Poll status until complete
- [ ] 7.8 Download and extract to `assets/sprites/characters/boss/shadow_boar/`

**Target Size:** 96x96 pixels
**Body Type:** Quadruped (bear template)
**Character ID:** _pending_

## 8. Import & Configure in Godot

- [ ] 8.1 Import all sprites to Godot project
- [ ] 8.2 Configure import settings (Filter: Nearest, Mipmaps: Disabled)
- [ ] 8.3 Create SpriteFrame resources for each character
- [ ] 8.4 Set up animation players with correct frame timings
- [ ] 8.5 Verify pixel-perfect rendering at 4x scale

## 9. Verification

- [ ] 9.1 All characters display correctly in editor
- [ ] 9.2 All animations play smoothly
- [ ] 9.3 Color palette matches GDD specifications
- [ ] 9.4 Art style consistent (Octopath Traveler reference)
- [ ] 9.5 Sizes match design (48/64/96 as specified)
