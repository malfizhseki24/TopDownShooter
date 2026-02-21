extends Control
## Main menu screen with roguelite options.

var _sfx_confirm: AudioStream = preload("res://assets/audio/sfx/ui_confirm.wav")
var _sfx_deny: AudioStream = preload("res://assets/audio/sfx/ui_deny.wav")

@onready var new_run_button: Button = $VBoxContainer/NewRunButton
@onready var daily_button: Button = $VBoxContainer/DailyButton
@onready var seed_input: LineEdit = $VBoxContainer/SeedInput
@onready var load_seed_button: Button = $VBoxContainer/LoadSeedButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	_connect_buttons()
	_setup_focus()


func _connect_buttons() -> void:
	new_run_button.pressed.connect(_on_new_run_pressed)
	daily_button.pressed.connect(_on_daily_pressed)
	load_seed_button.pressed.connect(_on_load_seed_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	seed_input.text_submitted.connect(_on_seed_submitted)


func _setup_focus() -> void:
	new_run_button.grab_focus()


func _on_new_run_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Start a new run with random seed
	GameManager.start_run(-1, false)
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


func _on_daily_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	# Start daily challenge (same seed for everyone today)
	GameManager.start_run(-1, true)
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")


func _on_load_seed_pressed() -> void:
	var seed_text := seed_input.text.strip_edges()
	if seed_text.is_valid_int():
		AudioManager.play_sfx_global(_sfx_confirm)
		GameManager.start_run(seed_text.to_int(), false)
		get_tree().change_scene_to_file("res://scenes/levels/game.tscn")
	else:
		AudioManager.play_sfx_global(_sfx_deny)
		# Flash the input to indicate error
		seed_input.modulate = Color.RED
		var tween := create_tween()
		tween.tween_property(seed_input, "modulate", Color.WHITE, 0.3)


func _on_seed_submitted(text: String) -> void:
	_on_load_seed_pressed()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx_global(_sfx_confirm)
	get_tree().quit()
