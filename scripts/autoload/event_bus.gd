extends Node
## Global event bus for decoupled communication between game systems.

# Player signals
signal player_damaged(damage: int)
signal player_died
signal player_healed(amount: int)

# Enemy signals
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node)
signal enemy_hit(enemy: Node, damage: int)

# Boss signals
signal boss_spawned(boss: Node)
signal boss_died(boss: Node)
signal boss_phase_changed(phase: int)

# Game state signals
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal victory

# UI signals
signal health_changed(current: int, maximum: int)
signal show_damage_number(position: Vector2, damage: int)
