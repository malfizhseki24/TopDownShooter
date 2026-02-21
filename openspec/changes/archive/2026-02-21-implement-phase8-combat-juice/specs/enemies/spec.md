## MODIFIED Requirements

### Requirement: Enemy Glow Layer

All enemies SHALL have a visible glow element (eyes, aura, or outline) using additive blend sprites for visual readability against any background.

#### Scenario: Enemy glow sprite setup

- **WHEN** an enemy is rendered
- **THEN** a child `Sprite2D` named `GlowSprite` is present with `CanvasItemMaterial(blend_mode = Add)`
- **AND** the glow texture covers the enemy's eyes or aura region

#### Scenario: Shadow Wisp glow

- **WHEN** a Shadow Wisp is rendered
- **THEN** it has a cyan glow on its core/eyes (color temperature: cool)
- **AND** the glow pixels are at least 40% brighter than the darkest expected background tile

#### Scenario: Shadow Crawler/Stalker/Brute glow

- **WHEN** a Shadow Crawler, Stalker, or Brute is rendered
- **THEN** it has a warm glow (red/orange) on its eyes
- **AND** eye glow size is at least 3x3px for Crawler, 4x4px for Stalker/Brute

#### Scenario: Boss aura glow

- **WHEN** the Shadow Boar boss is rendered
- **THEN** it has a persistent 4-8px shadow/glow aura around its body
- **AND** the aura uses additive blend to dominate visual attention
