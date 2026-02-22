extends Control
## Pause menu overlay for linear stage game.
## Options: RESUME, RESTART, QUIT TO MENU

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")

@onready var resume_button: Button = $ButtonContainer/ResumeButton
@onready var restart_button: Button = $ButtonContainer/RestartButton
@onready var quit_button: Button = $ButtonContainer/QuitButton


func _ready() -> void:
	visible = false
	_connect_signals()


func _connect_signals() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)


func _on_game_paused() -> void:
	visible = true
	resume_button.grab_focus()


func _on_game_resumed() -> void:
	visible = false


func _on_resume_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.resume_game()


func _on_restart_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Unpause first, then restart
	GameManager.resume_game()
	GameManager.new_run()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	GameManager.return_to_menu()
