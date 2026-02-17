# Design: Character Sprites via PixelLab MCP

## Context

Generating all character sprites for "Warrior of the Sunrise" using PixelLab MCP's AI-powered pixel art generation. Characters must match the Papuan folklore theme with dark, tribal aesthetics.

## Goals / Non-Goals

### Goals
- Generate consistent pixel art style across all characters
- Create 4-directional sprites for top-down gameplay
- Produce animations for all required actions
- Match GDD color palette specifications

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
| Shadow Wisp | 64x64 | ~38px tall |
| Shadow Crawler | 64x64 | ~38px tall |
| Shadow Stalker | 96x96 | ~58px tall |
| Shadow Brute | 128x128 | ~77px tall |
| Kasuari (Player) | 128x128 | ~77px tall |
| Shadow Boar (Boss) | 128x128 | ~77px tall (scaled 1.5x) |

**Rationale**:
- PixelLab max is 128x128 for characters
- Boss needs 192x128 visual size → render at 128x128, scale 1.5x in Godot
- Smaller enemies use 64x64 for faster generation and smaller file sizes

### Decision 3: Style Parameters

| Parameter | Value | Reason |
|-----------|-------|--------|
| View | `low top-down` | Matches top-down shooter perspective |
| Outline | `single color black outline` | Clear silhouettes, retro aesthetic |
| Shading | `medium shading` | Balance detail and clarity |
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

Shadow Crawler uses `body_type: "quadruped"` with template `"cat"` or `"dog"` as base for natural 4-legged movement.

## PixelLab MCP Parameters

### Kasuari (Player)

```json
{
  "description": "chibi SD style, cute but fierce tribal warrior with cassowary bone armor, black feather helmet with casque horn, holding bow, big expressive eyes, dark blue and black color scheme, blood red accents, bone white details",
  "name": "Kasuari",
  "n_directions": 4,
  "size": 128,
  "view": "low top-down",
  "outline": "single color black outline",
  "shading": "medium shading",
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
  "description": "chibi SD style, cute floating shadow orb with large glowing red eyes, wispy dark silhouette, round blob shape, black with red glow",
  "name": "Shadow Wisp",
  "n_directions": 4,
  "size": 64,
  "view": "low top-down",
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
  "description": "chibi SD style, cute but creepy quadruped shadow creature, short stubby legs, dark silhouette with big cyan glowing eyes, fast crawler, black purple gradient",
  "name": "Shadow Crawler",
  "body_type": "quadruped",
  "template": "cat",
  "n_directions": 4,
  "size": 64,
  "view": "low top-down",
  "outline": "single color black outline",
  "shading": "basic shading",
  "detail": "low detail",
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
  "description": "chibi SD style, cute spooky humanoid shadow figure, large glowing white eyes, oversized hooded head, ethereal cloak, small body, dark purple black",
  "name": "Shadow Stalker",
  "n_directions": 4,
  "size": 96,
  "view": "low top-down",
  "outline": "single color black outline",
  "shading": "medium shading",
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
  "description": "chibi SD style, cute intimidating hulking shadow monster, big glowing red eyes, large head with bulky silhouette, small legs, slow heavy presence, black with red accents",
  "name": "Shadow Brute",
  "n_directions": 4,
  "size": 128,
  "view": "low top-down",
  "outline": "single color black outline",
  "shading": "detailed shading",
  "detail": "high detail",
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
  "description": "chibi SD style, cute but terrifying massive demonic boar with shadow aura, huge head with glowing red eyes, black mist emanating, tusks, oversized intimidating chibi form, dark with red glow",
  "name": "Shadow Boar",
  "n_directions": 4,
  "size": 128,
  "view": "low top-down",
  "outline": "single color black outline",
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

**Note**: Rendered at 128x128, scaled to 1.5x (192x128) in Godot.

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
│       ├── kasuari_south.png
│       ├── kasuari_west.png
│       ├── kasuari_east.png
│       ├── kasuari_north.png
│       └── animations/
│           ├── idle_south.png (spritesheet)
│           ├── walk_south.png
│           └── ...
├── enemies/
│   ├── shadow_wisp/
│   ├── shadow_crawler/
│   ├── shadow_stalker/
│   └── shadow_brute/
└── boss/
    └── shadow_boar/
```

## Open Questions

1. **Shadow Wisp directions**: Does a floating orb need 4 directions, or can we use 1 sprite with rotation?
2. **Death animations**: Single direction or all 4? (currently planned single for efficiency)
3. **Boss scale**: Test 1.5x scaling to ensure no visual artifacts at 192x128

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Generation doesn't match vision | Use lower `ai_freedom` (650-700) for more control |
| Animations don't fit gameplay | Use custom `action_description` to guide movement style |
| Colors don't match palette | Specify exact colors in description, may need post-processing |
| Boss too small at 128px | Accept 1.5x scale or use map_object tool for larger size |
