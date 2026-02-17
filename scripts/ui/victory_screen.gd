extends Control
## Victory screen shown after defeating the boss.

@onready var menu_button: Button = $Panel/VBoxContainer/MenuButton


func _ready() -> void:
	visible = false
	menu_button.pressed.connect(_on_menu_pressed)
	EventBus.victory.connect(_on_victory)


func _on_victory() -> void:
	visible = true
	menu_button.grab_focus()


func _on_menu_pressed() -> void:
	GameManager.return_to_menu()
