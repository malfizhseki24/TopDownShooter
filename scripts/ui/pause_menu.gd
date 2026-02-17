extends Control
## Pause menu overlay.

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)


func _on_game_paused() -> void:
	visible = true
	resume_button.grab_focus()


func _on_game_resumed() -> void:
	visible = false


func _on_resume_pressed() -> void:
	GameManager.resume_game()


func _on_quit_pressed() -> void:
	GameManager.return_to_menu()
