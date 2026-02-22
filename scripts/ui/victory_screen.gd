extends Control
## Victory screen shown after defeating the boss.
## Displays run statistics for linear stage game.

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton


func _ready() -> void:
	visible = false
	_connect_signals()


func _connect_signals() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	EventBus.victory.connect(_on_victory)


func _on_victory() -> void:
	visible = true
	_update_stats()
	restart_button.grab_focus()


func _update_stats() -> void:
	var stats := GameManager.get_run_stats()

	# Show stats (no seed for linear game)
	var time_str := _format_time(stats.time_elapsed)
	stats_label.text = "VICTORY!\n\nEnemies Killed: %d\nDamage Taken: %d\nTime: %s" % [
		stats.enemies_killed,
		stats.damage_taken,
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


func _on_menu_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.return_to_menu()
