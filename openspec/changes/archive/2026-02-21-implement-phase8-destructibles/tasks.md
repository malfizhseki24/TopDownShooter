## 1. Base Destructible System

- [x] 1.1 Add physics layer 6 "destructible" to `project.godot`, update arrow collision mask to include layer 6
- [x] 1.2 Add `destructible_broken(position: Vector2, type: String)` signal to `scripts/autoload/event_bus.gd`
- [x] 1.3 Create `scripts/interactables/base_destructible.gd` — extends StaticBody2D, exported `max_hp`, `break_fx_scene`, `drop_table_enabled`; `take_damage(amount)` method; on break: spawn FX, roll drops, emit signal, emit camera trauma +0.03, emit hitstop 0.02s, queue_free
- [x] 1.4 Create `scripts/interactables/drop_spawner.gd` — static `roll_drop(position)` method; 80% nothing, 15% Spirit Ember, 5% Shadow Fragment; spawns pickup scene at position with arc tween

## 2. Destructible Types

- [x] 2.1 Create `scenes/interactables/ancient_pot.tscn` — Sprite2D + CollisionShape2D, 1 HP, pot break FX (4-6 shards + dust puff)
- [x] 2.2 Create `scenes/interactables/shadow_pillar.tscn` — Sprite2D + CollisionShape2D, 3 HP, crystal shatter FX (dark fragments + shadow burst); also on wall layer for boss collision
- [x] 2.3 Create `scenes/interactables/corrupted_root.tscn` — Sprite2D + CollisionShape2D, 1 HP, snap FX (leaf particles)
- [x] 2.4 Create `scenes/interactables/bone_totem.tscn` — Sprite2D + CollisionShape2D, 2 HP, skull pop + feather scatter FX

## 3. Pickup Items

- [x] 3.1 Create `scenes/interactables/spirit_ember.tscn` — Area2D pickup, glowing sprite, on player overlap: emit `player_healed(5)`, play pickup VFX + chime SFX, queue_free
- [x] 3.2 Create `scenes/interactables/shadow_fragment.tscn` — Area2D pickup, on player overlap: increment GameManager counter, play pickup VFX, queue_free

## 4. Arrow/Melee Integration

- [x] 4.1 Update `scripts/player/arrow.gd` to detect destructible collision — call `take_damage()`, play hit effect, queue_free arrow
- [x] 4.2 Update melee attack in `scripts/player/player.gd` to detect destructibles in MeleeArea — call `take_damage()` on overlapping destructibles

## 5. Room Placement

- [x] 5.1 Place 5-6 ancient pots near spawn in Room 1 scenes (tutorial encouragement)
- [x] 5.2 Place 3-5 mixed destructibles at edges/corners in Room 2-5 scenes
- [x] 5.3 Place 2-3 bone totems in heal room scenes
- [x] 5.4 Place 4 shadow pillars at boss room edges

## 6. Boss Interaction

- [x] 6.1 Ensure shadow pillars are on both destructible and wall layers so boss charge collision triggers pillar destruction + boss stun

## 7. GDD Update

- [x] 7.1 Update GDD Phase 8 checkbox for Destructible Props
