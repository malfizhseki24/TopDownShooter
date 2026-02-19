extends Node
## Manages global game state and flow.

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, VICTORY }

var current_state: GameState = GameState.MENU
var previous_state: GameState = GameState.MENU

# Player spawn point (set by level)
var player_spawn_position: Vector2 = Vector2.ZERO

# Enemy tracking
const MAX_ENEMIES: int = 10
var enemy_count: int = 0

# Game stats
var enemies_killed: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_died.connect(_on_enemy_died)


func _on_enemy_spawned(_enemy: Node) -> void:
	enemy_count += 1


func _on_enemy_died(_enemy: Node) -> void:
	enemy_count -= 1
	enemy_count = maxi(enemy_count, 0)
	enemies_killed += 1


func can_spawn_enemy() -> bool:
	return enemy_count < MAX_ENEMIES


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func start_game() -> void:
	enemies_killed = 0
	enemy_count = 0
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
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	EventBus.game_over.emit()


func trigger_victory() -> void:
	current_state = GameState.VICTORY
	get_tree().paused = true
	EventBus.victory.emit()


func return_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func is_playing() -> bool:
	return current_state == GameState.PLAYING
