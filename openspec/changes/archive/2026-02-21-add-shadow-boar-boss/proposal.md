# Feature: Add Shadow Boar Boss (Phase 4)

## Why
Room 7 is the boss arena but currently spawns a placeholder Shadow Brute. The game needs a proper two-phase boss encounter with the Shadow Boar to deliver the climactic finale of Stage 1 as described in the GDD.

## What Changes
- Rewrite `scripts/boss/shadow_boar.gd` with proper two-phase boss AI (charge, wall-stun, shockwave, wisp summon)
- Update `scenes/boss/shadow_boar.tscn` with correct collision sizes, boss health bar integration
- Update `room_manager.gd` to load the Shadow Boar scene (replace shadow_brute placeholder)
- Emit boss-specific EventBus signals (`boss_spawned`, `boss_phase_changed`, `boss_died`)
- Add boss health bar UI (`scenes/ui/boss_health_bar.tscn`)
- Add shadow trail VFX for charge attacks
- Add shockwave VFX for ground slam (Phase 2)
- Remove respawn logic from shadow_boar.gd (already removed from all other enemies)
- Victory triggers on boss death via existing `all_rooms_cleared` signal chain

## Impact
- Affected systems: boss (new spec), enemies (modified — boss extends BaseEnemy), stage-rooms (modified — boss room setup), game-state (existing victory flow)
- Affected files: `scripts/boss/shadow_boar.gd`, `scenes/boss/shadow_boar.tscn`, `scripts/stage/room_manager.gd`, `scripts/autoload/event_bus.gd`, new UI files for boss health bar
- Existing sprites: shadow_boar has idle, attack, jump-attack, running-8-frames, walk-8-frames (4 directions each) — all ready
