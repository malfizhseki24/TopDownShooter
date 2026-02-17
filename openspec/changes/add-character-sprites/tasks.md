# Tasks: Character Sprites via PixelLab MCP

## 1. Setup Asset Folders

- [x] 1.1 Create `assets/sprites/characters/player/kasuari/`
- [x] 1.2 Create `assets/sprites/characters/enemies/shadow_wisp/`
- [x] 1.3 Create `assets/sprites/characters/enemies/shadow_crawler/`
- [x] 1.4 Create `assets/sprites/characters/enemies/shadow_stalker/`
- [x] 1.5 Create `assets/sprites/characters/enemies/shadow_brute/`
- [x] 1.6 Create `assets/sprites/characters/boss/shadow_boar/`

## 2. Generate Player Character (Kasuari)

- [x] 2.1 Queue Kasuari character creation (128x128, 4-directional)
- [x] 2.2 Queue idle animation (4 frames per direction)
- [x] 2.3 Queue walk animation (6 frames per direction)
- [x] 2.4 Queue shoot animation (4 frames per direction)
- [x] 2.5 Queue dash animation (3 frames per direction)
- [x] 2.6 Queue death animation (6 frames, single direction)
- [x] 2.7 Poll status until complete
- [x] 2.8 Download and extract to `assets/sprites/characters/player/kasuari/`

## 3. Generate Shadow Wisp Enemy

- [ ] 3.1 Queue Shadow Wisp character creation (64x64, 4-directional)
- [ ] 3.2 Queue idle animation (float bob)
- [ ] 3.3 Queue move animation (homing drift)
- [ ] 3.4 Queue death animation (dissolve)
- [ ] 3.5 Poll status until complete
- [ ] 3.6 Download and extract to `assets/sprites/characters/enemies/shadow_wisp/`

## 4. Generate Shadow Crawler Enemy

- [ ] 4.1 Queue Shadow Crawler character creation (64x64, 4-directional, quadruped)
- [ ] 4.2 Queue idle animation
- [ ] 4.3 Queue walk animation (fast crawl)
- [ ] 4.4 Queue attack animation (lunge)
- [ ] 4.5 Queue death animation
- [ ] 4.6 Poll status until complete
- [ ] 4.7 Download and extract to `assets/sprites/characters/enemies/shadow_crawler/`

## 5. Generate Shadow Stalker Enemy

- [ ] 5.1 Queue Shadow Stalker character creation (96x96, 4-directional)
- [ ] 5.2 Queue idle animation
- [ ] 5.3 Queue walk animation
- [ ] 5.4 Queue teleport animation (fade out/in)
- [ ] 5.5 Queue attack animation
- [ ] 5.6 Queue death animation
- [ ] 5.7 Poll status until complete
- [ ] 5.8 Download and extract to `assets/sprites/characters/enemies/shadow_stalker/`

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
