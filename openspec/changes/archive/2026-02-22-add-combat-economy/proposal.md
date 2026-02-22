# Proposal: Add Combat Economy System

## Summary

Implement a "Combat Economy" system that replaces traditional shop/coin mechanics with an in-combat resource cycle. Players collect "Sun Shards" from defeated enemies to fill an Energy Meter, then unleash a powerful "Sun-Piercer" ultimate attack. This keeps the MVP scope lean while maintaining satisfying progression within combat encounters.

## Motivation

- **Keeps combat fast-paced**: Rewards are immediate and tied to killing enemies
- **No meta-progression scope creep**: Avoids shops, currency, and persistent unlocks
- **Adds strategic depth**: Players decide when to use their ultimate
- **Enhances game feel**: Another layer of juice (bouncy drops, magnetic pull, screen shake)

## Scope

### In Scope

1. **Sun Shards** — Energy pickup items dropped by enemies on death
2. **Energy Meter** — HUD element tracking collected feather energy
3. **Sun-Piercer** — Ultimate attack that consumes full meter

### Out of Scope

- Persistent upgrades or meta-progression
- Multiple ultimate abilities
- Feather value variations by enemy type (MVP: all feathers = 1 unit)
- Shard magnets/upgrades

## Affected Systems

| System | Impact |
|--------|--------|
| `enemies` | Enemies emit shard drop signal on death |
| `hud` | New Energy Meter UI element |
| `player-combat` | New special attack input and execution |
| `EventBus` | New signals for feather collection, meter updates |
| `vfx-particles` | Feather spawn particles, Sun-Piercer trail |
| `hitstop` | Sun-Piercer impact triggers extended hitstop |

## Deliverables

1. `scenes/pickups/sun_shard.tscn` — Sun Shard pickup scene
2. `scripts/pickups/sun_shard.gd` — Bounce + magnetic pull behavior
3. `scenes/ui/energy_meter.tscn` — Circular gauge UI
4. `scripts/ui/energy_meter.gd` — Fill animation + ready state
5. `scenes/player/sun_piercer.tscn` — Ultimate projectile scene
6. `scripts/player/sun_piercer.gd` — Piercing projectile logic
7. Updates to `player.gd` — Special attack input handling
8. Updates to `event_bus.gd` — New signals

## Success Criteria

- [ ] Enemies drop shards on death with visual bounce
- [ ] Shards magnetize to player within 80px
- [ ] Energy meter fills incrementally and shows "ready" state
- [ ] Player can trigger Sun-Piercer when meter is full
- [ ] Sun-Piercer pierces all enemies and obstacles
- [ ] Sun-Piercer triggers screen shake and hitstop on impact
- [ ] All elements have appropriate SFX

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Shard clutter in rooms with many enemies | Shards auto-collect after 5 seconds |
| Sun-Piercer too powerful | Tune damage to ~3x normal arrow, limit pierce count |
| UI clutter with new meter | Place meter below health bar, compact design |

## Alternatives Considered

1. **Traditional coin/shop system** — Rejected: adds scope, slows pacing
2. **Cooldown-based ultimate** — Rejected: less engaging than resource collection
3. **Multiple ultimates** — Rejected: scope creep for MVP

## Timeline

This is a self-contained feature with three parallelizable streams:
1. Feather drops (can be tested standalone)
2. Energy meter UI (can be tested with debug fill)
3. Sun-Piercer attack (can be tested with debug meter fill)

Implementation order: Feathers → Meter → Special Attack → Polish
