# Design: Character Sprites via PixelLab MCP

## Context

Generating all character sprites for "Warrior of the Sunrise" using PixelLab MCP's AI-powered pixel art generation. Characters must match the Papuan folklore theme with dark, tribal aesthetics, following the Octopath Traveler Heroes art style.

## Art Style Reference: Octopath Traveler Heroes

The character sprites should follow the art style of Octopath Traveler's playable characters:
- **Proportions**: Chibi/SD (2-3 heads tall), similar to Primrose, Therion, Olberic
- **Outlines**: Clean single-color outlines (not pure black, use dark variant of character color)
- **Shading**: Soft dithering, 2-3 shade levels per color, subtle highlights
- **Colors**: Muted, atmospheric palette - not oversaturated
- **Detail Level**: Moderate - readable at small sizes but not overly complex
- **Animation**: Clear key poses, readable silhouettes in motion
- **Personality**: Each character has distinctive features (hair, clothing, weapons)

**Key Visual Traits from Octopath Traveler:**
| Trait | Octopath Style | Our Adaptation |
|-------|---------------|----------------|
| Head size | Large (40% of height) | Same - chibi proportions |
| Eyes | Small but expressive, not anime-huge | Exaggerated but grounded |
| Outlines | Dark color-matched, not pure black | Dark navy/dark purple outlines |
| Shading | Soft gradients, dithering | Basic-medium shading |
| Colors | Muted earth tones, jewel accents | Tribal palette - dark blue, red, bone |
| Animation frames | 4-8 frames, smooth loops | 4-6 frames per animation |

## Goals / Non-Goals

### Goals
- Generate consistent pixel art style across all characters
- Create 4-directional sprites for top-down gameplay
- Produce animations for all required actions
- Match GDD color palette specifications
- Follow Octopath Traveler-inspired visual style

### Non-Goals
- Hand-drawn custom sprites
- Multiple outfit/variant sprites
- Particle effects (handled separately)

## Technical Decisions

### Decision 1: 4-Directional vs 8-Directional

**Chosen**: 4-directional (South, West, East, North)

**Rationale**:
- Reduces generation time by ~40%
- Godot can mirror East/West sprites for simpler enemies
- GDD specifies methodical combat where 4 directions sufficient
- Player uses mouse aiming, so sprite rotation less critical

### Decision 2: Canvas Sizes

| Character | Canvas Size | Effective Character Size |
|-----------|-------------|-------------------------|
| Kasuari (Player) | 48x48 | ~29px tall |
| Shadow Wisp | 64x64 | ~38px tall |
| Shadow Crawler | 64x64 | ~38px tall |
| Shadow Stalker | 64x64 | ~38px tall |
| Shadow Brute | 64x64 | ~38px tall |
| Shadow Boar (Boss) | 96x96 | ~58px tall |

**Rationale**:
- Player at 48x48 for compact, readable chibi sprite
- Most enemies at 64x64 for visual hierarchy
- Boss at 96x96 to appear larger and more imposing
- Smaller sizes = faster generation, smaller files, cleaner pixels

### Decision 3: Style Parameters

| Parameter | Value | Reason |
|-----------|-------|--------|
| View | `high top-down` | Better for top-down shooter perspective |
| Outline | `single color outline` | Color-matched outlines (not pure black) |
| Shading | `basic shading` | Octopath-style soft shading |
| Detail | `medium detail` | Readable at game scale |
| AI Freedom | `700-800` | Balance consistency with creativity |
| Proportions | `chibi` preset | SD (Super Deformed) style - large head, small body |

### Chibi/SD Proportions

All characters use the **chibi** proportions preset which creates:
- Head-to-body ratio of approximately 1:1 to 1:2
- Exaggerated, expressive eyes
- Shorter, stubbier limbs
- Cute but readable silhouettes

### Decision 4: Quadruped Enemies

Shadow Crawler and Shadow Boar use `body_type: "quadruped"` with appropriate templates for natural 4-legged movement.

## PixelLab MCP Parameters

### Kasuari (Player)

```json
{
  "description": "Octopath Traveler style chibi hero, tribal warrior with cassowary-inspired armor, dark skin, black feather headdress with bone casque, holding wooden bow, flowing grass skirt, tribal bone jewelry, muted color palette: dark navy blue, deep black, muted blood red accents, bone white, clean dark outline, soft shading, 2-3 color shades per element",
  "name": "Kasuari",
  "n_directions": 4,
  "size": 48,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "basic shading",
  "detail": "medium detail",
  "proportions": "{\"type\": \"preset\", \"name\": \"chibi\"}",
  "ai_freedom": 750
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `breathing-idle` | alert stance with bow |
| Walk | `walking-4-frames` | careful movement |
| Shoot | `lead-jab` | draw and release bow |
| Dash | `running-slide` | quick dodge roll |
| Death | `falling-back-death` | dramatic fall |

### Shadow Wisp

```json
{
  "description": "Octopath Traveler style chibi, floating shadow orb spirit, round blob shape with wispy edges, small glowing red eyes, ethereal trailing mist, muted dark purple and black, subtle red glow accents, clean dark outline, soft shading",
  "name": "Shadow Wisp",
  "n_directions": 4,
  "size": 64,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "basic shading",
  "detail": "low detail",
  "ai_freedom": 800
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `breathing-idle` | floating bob |
| Move | `walking-4-frames` | slow drift |
| Death | `falling-back-death` | dissolve away |

### Shadow Crawler (Quadruped)

```json
{
  "description": "Octopath Traveler style chibi, quadruped shadow creature, short stubby legs, hunched body, glowing cyan eyes, feral but cute silhouette, muted black and dark purple gradient, clean outline, soft shading",
  "name": "Shadow Crawler",
  "body_type": "quadruped",
  "template": "cat",
  "n_directions": 4,
  "size": 64,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "basic shading",
  "detail": "medium detail",
  "ai_freedom": 800
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `idle` | crouched ready |
| Walk | `walk` | fast crawl |
| Attack | `attack` | lunge bite |
| Death | `death` | collapse dissolve |

### Shadow Stalker

```json
{
  "description": "Octopath Traveler style chibi, humanoid shadow figure with oversized hooded head, ethereal cloak, large glowing white eyes, small body, mysterious silhouette, muted dark purple and black, clean outline, soft shading",
  "name": "Shadow Stalker",
  "n_directions": 4,
  "size": 64,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "basic shading",
  "detail": "medium detail",
  "proportions": "{\"type\": \"preset\", \"name\": \"chibi\"}",
  "ai_freedom": 750
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `breathing-idle` | ethereal float |
| Walk | `walking-4-frames` | silent glide |
| Teleport | `surprise-uppercut` | fade vanish |
| Attack | `cross-punch` | ambush strike |
| Death | `falling-back-death` | fade to nothing |

### Shadow Brute

```json
{
  "description": "Octopath Traveler style chibi, hulking shadow monster, large head with bulky silhouette, small legs, slow heavy presence, glowing red eyes, muted black with dark red accents, clean outline, soft shading",
  "name": "Shadow Brute",
  "n_directions": 4,
  "size": 64,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "medium shading",
  "detail": "medium detail",
  "proportions": "{\"type\": \"preset\", \"name\": \"chibi\"}",
  "ai_freedom": 700
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `breathing-idle` | heavy breathing |
| Walk | `walking-6-frames` | slow heavy steps |
| Charge | `running-4-frames` | building momentum |
| Attack | `two-footed-jump` | ground slam |
| Death | `falling-back-death` | heavy collapse |

### Shadow Boar (Boss)

```json
{
  "description": "Octopath Traveler style chibi, massive demonic boar, huge head with tusks, shadow aura emanating, glowing red eyes, intimidating but stylized silhouette, muted black with dark red glow, clean outline, soft shading",
  "name": "Shadow Boar",
  "n_directions": 4,
  "size": 96,
  "view": "high top-down",
  "outline": "single color outline",
  "shading": "detailed shading",
  "detail": "high detail",
  "body_type": "quadruped",
  "template": "bear",
  "ai_freedom": 650
}
```

**Animations**:
| Animation | Template ID | Action Description |
|-----------|-------------|-------------------|
| Idle | `idle` | menacing snort |
| Walk | `walk` | heavy trot |
| Charge | `run` | telegraphed rush |
| Slam | `attack` | ground pound |
| Death | `death` | dramatic collapse |

## Godot Import Settings

```
Texture Type: 2D
Filter: Nearest (pixel perfect)
Mipmaps: Disabled
Repeat: Disabled
```

## Asset File Naming Convention

```
assets/sprites/characters/
├── player/
│   └── kasuari/
│       └── animations/
│           ├── breathing-idle/
│           │   ├── south/frame_000.png
│           │   ├── east/frame_000.png
│           │   └── north/frame_000.png
│           ├── walking-4-frames/
│           ├── lead-jab/
│           ├── running-slide/
│           └── falling-back-death/
├── enemies/
│   ├── shadow_wisp/
│   ├── shadow_crawler/
│   ├── shadow_stalker/
│   └── shadow_brute/
└── boss/
    └── shadow_boar/
```

## Open Questions

1. ~~**Shadow Wisp directions**: Does a floating orb need 4 directions, or can we use 1 sprite with rotation?~~ → Keep 4 directions for consistency
2. **Death animations**: Single direction or all 4? (currently planned all 4 for consistency)
3. ~~**Boss scale**: Test 1.5x scaling to ensure no visual artifacts at 192x128~~ → Use 96x96 canvas directly

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Generation doesn't match vision | Use lower `ai_freedom` (650-700) for more control |
| Animations don't fit gameplay | Use custom `action_description` to guide movement style |
| Colors don't match palette | Specify exact colors in description, may need post-processing |
| Style inconsistent across characters | Reference Octopath Traveler style in all prompts |
