# Proposal: Audio Implementation (Phase 8E)

## Summary

Implement all priority SFX (bow, hit, death, break, UI), music tracks (exploration, combat, boss) with crossfade system, and a balancing pass on all damage/HP/speed values. This is the **final polish layer** that completes Phase 8.

## Motivation

The AudioManager autoload exists but currently has minimal implementation. The GDD specifies a 10-item SFX priority list, a 5-state music system with crossfade, and a fusion audio style (Papuan instruments + electronic). Sound is the most impactful missing feedback layer — hits without sound feel weightless regardless of visual polish. The balancing pass ensures all the new systems (trauma, hitstop, knockback) feel tuned.

## Scope

### SFX Implementation (10 priority sounds)
1. Bow draw & release ("twang")
2. Arrow hit impact (enemy vs. destructible variants)
3. Dash/dodge whoosh
4. Enemy death dissolve
5. Shadow spawn emergence
6. Boss charge telegraph
7. Destructible break (pottery, crystal, wood, bone variants)
8. Hitstop impact bass thump
9. UI confirm/deny
10. Spirit Ember pickup chime

### Music Implementation
- **Exploration**: Slow tribal drums, ambient nature, soft suling (bamboo flute)
- **Combat**: Intense beat drop, synth bass, faster Tifa drum patterns
- **Boss**: Full fusion — heavy drums + synth + vocal chants
- **Victory**: Triumphant traditional melody
- **Death/Game Over**: Somber fading drums
- Crossfade between states over 1.0s

### Balancing Pass
- Review and tune all damage, HP, speed values
- Verify hitstop durations feel right (not too long/short)
- Verify trauma values produce appropriate shake intensity
- Verify knockback distances feel impactful but fair
- Test with all Phase 8 systems active simultaneously

## Affected Files

### Modified
- `scripts/autoload/audio_manager.gd` — full SFX/music system with crossfade
- `scripts/player/player.gd` — SFX calls on shoot, dash, take_damage, die
- `scripts/player/arrow.gd` — SFX on hit
- `scripts/enemies/base_enemy.gd` — SFX on death, spawn
- `scripts/boss/shadow_boar.gd` — SFX on charge, slam, phase transition
- `scripts/interactables/base_destructible.gd` — SFX on break
- `scripts/ui/main_menu.gd` — UI SFX
- Various stat values across player, enemy, boss scripts

### New Assets (placeholder or generated)
- `assets/sfx/` — Sound effect files (.wav/.ogg)
- `assets/music/` — Music track files (.ogg)

## Dependencies

- Depends on **Phase 8A-D** being complete (SFX hooks into all combat/VFX/destructible systems)
- Balancing pass requires all systems active
