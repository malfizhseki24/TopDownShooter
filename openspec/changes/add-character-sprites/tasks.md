# Tasks: Character Sprites via PixelLab MCP

## 1. Setup Asset Folders

- [x] 1.1 Create `assets/sprites/characters/player/kasuari/`
- [x] 1.2 Create `assets/sprites/characters/enemies/shadow_wisp/`
- [x] 1.3 Create `assets/sprites/characters/enemies/shadow_crawler/`
- [x] 1.4 Create `assets/sprites/characters/enemies/shadow_stalker/`
- [x] 1.5 Create `assets/sprites/characters/enemies/shadow_brute/`
- [x] 1.6 Create `assets/sprites/characters/boss/shadow_boar/`

## 2. Generate Player Character (Kasuari)

- [x] 2.1 Queue Kasuari character creation (128x128, 4-directional, chibi style)
- [x] 2.2 Queue idle animation (4 frames per direction) → breathing-idle
- [x] 2.3 Queue walk animation (4 frames per direction) → walking-4-frames
- [x] 2.4 Queue shoot animation (4 frames per direction) → lead-jab
- [x] 2.5 Queue dash animation (6 frames per direction) → running-slide
- [x] 2.6 Queue death animation (4 frames per direction) → falling-back-death ⏳ processing
- [x] 2.7 Poll status until complete
- [x] 2.8 Download and extract to `assets/sprites/characters/player/kasuari/`

**Progress:** Complete ✓ (Base, Idle, Walk, Shoot, Dash, Death)
**Character ID:** `2b658a0f-3ad4-4b68-96d5-7017a9871166`
**Downloaded:** 67 PNGs (4 rotations + 5 animations x 4 directions)

## 3. Generate Shadow Wisp Enemy

- [x] 3.1 Queue Shadow Wisp character creation (64x64, 4-directional)
- [x] 3.2 Queue idle animation (float bob) → breathing-idle ⏳ processing (2-4 min)
- [ ] 3.3 Queue move animation (homing drift)
- [ ] 3.4 Queue death animation (dissolve)
- [ ] 3.5 Poll status until complete
- [ ] 3.6 Download and extract to `assets/sprites/characters/enemies/shadow_wisp/`

**Progress:** Base ✓, Idle ⏳ (queued 2026-02-17)
**Character ID:** `63605b0a-c5d5-42ff-b38b-3507cacee06c`

## 4. Generate Shadow Crawler Enemy

- [x] 4.1 Queue Shadow Crawler character creation (64x64, 4-directional, quadruped)
- [x] 4.2 Queue idle animation → idle ✓
- [ ] 4.3 Queue walk animation (fast crawl)
- [ ] 4.4 Queue attack animation (lunge)
- [ ] 4.5 Queue death animation
- [x] 4.6 Poll status until complete
- [x] 4.7 Download and extract to `assets/sprites/characters/enemies/shadow_crawler/`

**Progress:** Complete ✓ (minimal - idle only)
**Character ID:** `2db46d9f-f4c7-4856-997d-de06ad924a05`
**Downloaded:** 36 PNGs (4 rotations + 32 idle frames)

## 5. Generate Shadow Stalker Enemy

- [x] 5.1 Queue Shadow Stalker character creation (96x96, 4-directional) ✓
- [x] 5.2 Queue idle animation ✓ (breathing-idle complete)
- [x] 5.3 Queue walk animation → walking-4-frames ⏳ processing (2-4 min)
- [ ] 5.4 Queue teleport animation (fade out/in)
- [ ] 5.5 Queue attack animation
- [ ] 5.6 Queue death animation
- [x] 5.7 Download base rotations ✓
- [ ] 5.8 Download animations when complete

**Progress:** Base ✓, Idle ✓, Walk ⏳ (queued 2026-02-17)
**Character ID:** `2c11e362-c314-4b5f-9460-734af8889641`

## 6. Generate Shadow Brute Enemy

- [ ] 6.1 Queue Shadow Brute character creation (128x128, 4-directional)
- [ ] 6.2 Queue idle animation (heavy breathing)
- [ ] 6.3 Queue walk animation (slow, heavy)
- [ ] 6.4 Queue charge animation
- [ ] 6.5 Queue attack animation (slam)
- [ ] 6.6 Queue death animation
- [ ] 6.7 Poll status until complete
- [ ] 6.8 Download and extract to `assets/sprites/characters/enemies/shadow_brute/`

## 7. Generate Shadow Boar Boss

- [ ] 7.1 Queue Shadow Boar character creation (128x128, 4-directional)
- [ ] 7.2 Queue idle animation (menacing)
- [ ] 7.3 Queue walk animation (heavy trot)
- [ ] 7.4 Queue charge animation (telegraph + rush)
- [ ] 7.5 Queue slam animation (ground pound)
- [ ] 7.6 Queue death animation
- [ ] 7.7 Poll status until complete
- [ ] 7.8 Download and extract to `assets/sprites/characters/boss/shadow_boar/`

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
- [ ] 9.4 Sizes match design (scaled appropriately for boss)
