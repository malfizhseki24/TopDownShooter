extends Control
## Victory screen shown after defeating the boss.
## Displays run statistics and allows sharing seed.

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var seed_label: Label = $Panel/VBoxContainer/SeedLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var copy_seed_button: Button = $Panel/VBoxContainer/CopySeedButton
@onready var new_run_button: Button = $Panel/VBoxContainer/NewRunButton
@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton


func _ready() -> void:
	visible = false
	_connect_signals()


func _connect_signals() -> void:
	copy_seed_button.pressed.connect(_on_copy_seed_pressed)
	new_run_button.pressed.connect(_on_new_run_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	EventBus.victory.connect(_on_victory)


func _on_victory() -> void:
	visible = true
	_update_stats()
	new_run_button.grab_focus()


func _update_stats() -> void:
	var stats := GameManager.get_run_stats()

	# Show seed
	seed_label.text = "Seed: %s" % str(stats.seed)

	# Show stats
	var time_str := _format_time(stats.time_elapsed)
	stats_label.text = "Enemies Killed: %d\nDamage Taken: %d\nTime: %s\n\nRun #%d" % [
		stats.enemies_killed,
		stats.damage_taken,
		time_str,
		stats.run_count
	]


func _format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]


func _on_copy_seed_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Copy seed to clipboard
	var stats := GameManager.get_run_stats()
	DisplayServer.clipboard_set(str(stats.seed))

	# Visual feedback
	copy_seed_button.text = "COPIED!"
	await get_tree().create_timer(1.0).timeout
	copy_seed_button.text = "COPY SEED"


func _on_new_run_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Start a new run (harder difficulty)
	GameManager.new_run()


func _on_menu_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.return_to_menu()
