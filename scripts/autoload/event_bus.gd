extends Node
## Global event bus for decoupled communication between game systems.

# Player signals
signal player_damaged(damage: int)
signal player_died
signal player_healed(amount: int)
signal player_respawned
signal player_dash_started(cooldown_duration: float)
signal player_dash_ready

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

# Run signals (linear game)
signal run_started(seed_value: int)
signal run_ended(victory: bool, stats: Dictionary)
signal stage_generated

# UI signals
signal health_changed(current: int, maximum: int)
signal damage_dealt(position: Vector2, amount: int, type: StringName)
signal damage_taken(position: Vector2, amount: int, type: StringName)

# Room system signals
signal room_loaded(room_index: int)
signal room_cleared(room_index: int)
signal room_transition_requested(next_room_index: int)
signal all_rooms_cleared

# Camera signals
signal camera_trauma(amount: float)

# Screen flash signals
signal screen_flash_requested(color: Color, opacity: float, duration: float)

# Destructible signals
signal destructible_broken(position: Vector2, type: String)

# Interactable signals
signal show_interact_prompt(message: String)
signal hide_interact_prompt

# Combat Economy signals
signal shard_dropped(position: Vector2)
signal shard_collected
signal energy_meter_changed(current: int, maximum: int)
signal energy_meter_full
signal energy_meter_emptied
signal special_attack_fired(direction: Vector2)
signal special_attack_hit(target: Node, damage: int)

# Skill signals
signal skill_activated(skill_index: int)
signal skill_cooldown_started(skill_index: int, duration: float)
signal skill_cooldown_ready(skill_index: int)
