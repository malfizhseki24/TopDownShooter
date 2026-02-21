extends Control
## Game over screen with roguelite features.

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var seed_label: Label = $Panel/VBoxContainer/SeedLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var new_run_button: Button = $Panel/VBoxContainer/NewRunButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	_connect_signals()


func _connect_signals() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	new_run_button.pressed.connect(_on_new_run_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	visible = true
	_update_stats()
	new_run_button.grab_focus()


func _update_stats() -> void:
	var stats := GameManager.get_run_stats()

	# Show seed
	seed_label.text = "Seed: %s" % str(stats.seed)

	# Show stats
	var time_str := _format_time(stats.time_elapsed)
	stats_label.text = "Enemies Killed: %d\nDamage Taken: %d\nTime: %s" % [
		stats.enemies_killed,
		stats.damage_taken,
		time_str
	]


func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]


func _on_retry_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Retry with same seed
	GameManager.retry_run()


func _on_new_run_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Start fresh with new seed
	GameManager.new_run()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.return_to_menu()
