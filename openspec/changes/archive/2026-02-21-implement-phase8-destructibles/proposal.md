# Proposal: Destructible Props (Phase 8D)

## Summary

Implement all 4 destructible prop types (Ancient Clay Pot, Shadow Pillar, Corrupted Root, Bone Totem) with break FX, debris particles, and rare drops. Destructibles serve as target practice, room dressing, micro-rewards, and teaching tools.

## Motivation

The GDD specifies destructible objects as a core part of game feel — "something satisfying to shoot before/between enemy waves." Currently no destructible system exists. This adds breakable props with HP, shatter effects, and a drop system (80% nothing, 15% Spirit Ember heal, 5% Shadow Fragment collectible).

## Scope

### Base Destructible System
- `BaseDestructible` script extending `StaticBody2D` with HP, break threshold
- Take damage from arrows and melee
- Break FX: debris particles flying outward, type-specific effects
- Drop system: weighted random (80/15/5)

### 4 Destructible Types

| Object | HP | Break FX |
|--------|-----|----------|
| Ancient Clay Pot | 1 | 4-6 shard pieces fly outward, dust puff |
| Shadow Pillar | 3 | Dark crystal fragments, brief shadow burst |
| Corrupted Root | 1 | Snap apart, small leaf particles |
| Bone Totem | 2 | Skull pops off, feathers scatter |

### Drops
- Spirit Ember (15%): glowing pickup, heals 5 HP
- Shadow Fragment (5%): visual collectible (no gameplay effect yet)

### Placement (handled by room scenes, not automated)
- Room 1: 5-6 pots near spawn (tutorial)
- Room 2-5: 3-5 mixed at edges/corners
- Heal rooms: 2-3 bone totems (calm atmosphere)
- Boss room: 4 shadow pillars at edges (boss can charge through them)

## Affected Files

### New
- `scripts/interactables/base_destructible.gd` — Base destructible logic
- `scenes/interactables/ancient_pot.tscn` — Clay pot scene
- `scenes/interactables/shadow_pillar.tscn` — Shadow pillar scene
- `scenes/interactables/corrupted_root.tscn` — Corrupted root scene
- `scenes/interactables/bone_totem.tscn` — Bone totem scene
- `scripts/interactables/drop_spawner.gd` — Drop logic (Spirit Ember, Shadow Fragment)
- `scenes/interactables/spirit_ember.tscn` — Heal pickup scene
- `scenes/interactables/shadow_fragment.tscn` — Collectible pickup scene

### Modified
- `scripts/autoload/event_bus.gd` — add `destructible_broken(position, type)` signal
- `scripts/player/arrow.gd` — handle collision with destructibles (physics layer)
- `project.godot` — add destructible physics layer
- Room scenes — place destructible instances

## Dependencies

- Depends on **Phase 8A** (camera-time) for trauma on break (+0.03)
- Depends on **Phase 8A** (camera-time) for hitstop on break (0.02s)
- Independent of Phase 8B/8C but break FX layer on top of VFXManager
