extends Control
## Main menu screen for linear stage game.
## Simplified from roguelite to: NEW GAME, OPTIONS (placeholder), QUIT

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	_connect_buttons()
	_setup_focus()


func _connect_buttons() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _setup_focus() -> void:
	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Start a new game from Room 1
	GameManager.start_run(-1, false)
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


func _on_options_pressed() -> void:
	# Placeholder - Options menu not implemented yet
	# Flash the button or play a deny sound
	pass


func _on_quit_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	get_tree().quit()
