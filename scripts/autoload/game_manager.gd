extends Node
## Manages global game state and flow.
## Supports roguelite structure with seed-based runs.

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, VICTORY }

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU

# Player spawn point (set by level)
var player_spawn_position: Vector2 = Vector2.ZERO

# Enemy tracking
const MAX_ENEMIES: int = 10
var enemy_count: int = 0

# Roguelite state
var current_seed: int = -1
var is_daily_run: bool = false
var run_count: int = 0

# Run statistics
var enemies_killed: int = 0
var damage_taken: int = 0
var time_elapsed: float = 0.0
var run_start_time: float = 0.0

# Room tracking
var current_room: int = 0
var total_rooms: int = 7

# Collectibles
var shadow_fragments: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.player_damaged.connect(_on_player_damaged)


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		time_elapsed += delta


func _on_enemy_spawned(_enemy: Node) -> void:
	enemy_count += 1


func _on_enemy_died(_enemy: Node) -> void:
	enemy_count -= 1
	enemy_count = maxi(enemy_count, 0)
	enemies_killed += 1


func _on_player_damaged(damage: int) -> void:
	damage_taken += damage


func can_spawn_enemy() -> bool:
	return enemy_count < MAX_ENEMIES


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


## Start a new roguelite run with optional seed.
func start_run(seed_value: int = -1, daily: bool = false) -> void:
	# Reset statistics
	enemies_killed = 0
	damage_taken = 0
	time_elapsed = 0.0
	run_start_time = Time.get_ticks_msec() / 1000.0
	enemy_count = 0
	shadow_fragments = 0
	is_daily_run = daily

	# Reset room tracking
	current_room = 0

	# Determine seed
	if daily:
		# Daily challenge: same seed for everyone on same day
		var date := Time.get_date_dict_from_system()
		current_seed = hash(str(date.year) + str(date.month) + str(date.day))
	else:
		current_seed = seed_value if seed_value != -1 else randi()

	run_count += 1

	# Emit signal for UI
	EventBus.run_started.emit(current_seed)

	print("Run %d started with seed: %d (daily: %s)" % [run_count, current_seed, daily])


## Get run statistics as dictionary.
func get_run_stats() -> Dictionary:
	return {
		"seed": current_seed,
		"run_count": run_count,
		"is_daily": is_daily_run,
		"enemies_killed": enemies_killed,
		"damage_taken": damage_taken,
		"time_elapsed": time_elapsed,
		"shadow_fragments": shadow_fragments
	}


## End current run.
func end_run(victory: bool) -> void:
	var stats := get_run_stats()
	EventBus.run_ended.emit(victory, stats)

	print("Run ended: %s" % ("Victory!" if victory else "Defeat"))
	print("  Seed: %d" % current_seed)
	print("  Enemies killed: %d" % enemies_killed)
	print("  Damage taken: %d" % damage_taken)
	print("  Time: %.1f seconds" % time_elapsed)


func start_game() -> void:
	current_state = GameState.PLAYING
	get_tree().paused = false
	EventBus.game_started.emit()


func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		pause_game()
	elif current_state == GameState.PAUSED:
		resume_game()


func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return
	previous_state = current_state
	current_state = GameState.PAUSED
	get_tree().paused = true
	EventBus.game_paused.emit()


func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return
	current_state = previous_state
	get_tree().paused = false
	EventBus.game_resumed.emit()


func trigger_game_over() -> void:
	end_run(false)
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	EventBus.game_over.emit()


func trigger_victory() -> void:
	end_run(true)
	current_state = GameState.VICTORY
	get_tree().paused = true
	EventBus.victory.emit()


func return_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


## Restart with a NEW seed (roguelite - new run).
func new_run() -> void:
	get_tree().paused = false
	start_run(-1, false)
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


## Retry with the SAME seed.
func retry_run() -> void:
	get_tree().paused = false
	var same_seed := current_seed
	start_run(same_seed, false)
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


## Load a specific seed.
func load_seed(seed_string: String) -> void:
	var seed_value := seed_string.to_int()
	if seed_value != 0:
		get_tree().paused = false
		start_run(seed_value, false)
		get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


func is_playing() -> bool:
	return current_state == GameState.PLAYING


## Advance to next room
func advance_room() -> void:
	current_room += 1
	print("Advanced to room %d/%d" % [current_room, total_rooms])


## Set total rooms for current stage
func set_total_rooms(count: int) -> void:
	total_rooms = count


## Check if final room
func is_final_room() -> bool:
	return current_room >= total_rooms - 1


## Get seed as display string.
func get_seed_string() -> String:
	return str(current_seed)
