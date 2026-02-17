extends Control
## Game over screen.

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	visible = true
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	GameManager.restart_game()


func _on_quit_pressed() -> void:
	GameManager.return_to_menu()
