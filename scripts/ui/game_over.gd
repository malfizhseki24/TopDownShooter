extends Control
## Game over screen for linear stage game.
## Simple: RESTART, QUIT TO TITLE

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	_connect_signals()


func _connect_signals() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	visible = true
	_update_stats()
	restart_button.grab_focus()


func _update_stats() -> void:
	var stats := GameManager.get_run_stats()

	# Show simple stats (no seed)
	var time_str := _format_time(stats.time_elapsed)
	stats_label.text = "Enemies Killed: %d\nTime: %s" % [
		stats.enemies_killed,
		time_str
	]


func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]


func _on_restart_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Restart from Room 1
	GameManager.new_run()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.return_to_menu()
