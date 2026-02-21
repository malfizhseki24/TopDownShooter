class_name InteractPrompt
extends Control
## World-space interaction prompt displayed above interactable objects.
## Creates "[E] Action" labels programmatically with appear/disappear/bob animations.
## Attach to a Control node placed as a child of the interactable.

@export var key_text: String = "[E]"
@export var action_text: String = "Interact"
@export var action_color: Color = Color("#f1f1f1")

var _key_label: Label = null
var _action_label: Label = null
var _locked_label: Label = null
var _bob_tween: Tween = null
var _appear_tween: Tween = null
var _base_y: float = 0.0
var _locked_shown: bool = false

# Pixel font for crisp rendering at low-res viewport
var _pixel_font: FontFile = null


func _ready() -> void:
	_base_y = position.y
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Load pixel font with no antialiasing for crisp rendering
	_pixel_font = load("res://assets/fonts/Silkscreen-Regular.ttf") as FontFile
	if _pixel_font:
		_pixel_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		_pixel_font.hinting = TextServer.HINTING_NONE
		_pixel_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED

	# Key label: "[E]"
	_key_label = Label.new()
	_key_label.text = key_text
	if _pixel_font:
		_key_label.add_theme_font_override("font", _pixel_font)
	_key_label.add_theme_font_size_override("font_size", 8)
	_key_label.add_theme_color_override("font_color", Color("#f1f1f1"))
	_key_label.add_theme_color_override("font_shadow_color", Color("#0f0f0f"))
	_key_label.add_theme_constant_override("shadow_offset_x", 1)
	_key_label.add_theme_constant_override("shadow_offset_y", 1)
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_key_label)

	# Action label: "Heal" / "Enter"
	_action_label = Label.new()
	_action_label.text = action_text
	if _pixel_font:
		_action_label.add_theme_font_override("font", _pixel_font)
	_action_label.add_theme_font_size_override("font_size", 8)
	_action_label.add_theme_color_override("font_color", action_color)
	_action_label.modulate.a = 0.7
	_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_action_label)

	# Locked message label (hidden by default)
	_locked_label = Label.new()
	if _pixel_font:
		_locked_label.add_theme_font_override("font", _pixel_font)
	_locked_label.add_theme_font_size_override("font_size", 8)
	_locked_label.add_theme_color_override("font_color", Color("#e94560"))
	_locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_locked_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_locked_label.visible = false
	add_child(_locked_label)

	# Center labels after sizing
	await get_tree().process_frame
	_center_labels()

	# Start hidden
	visible = false
	modulate.a = 0.0


func _center_labels() -> void:
	_key_label.position.x = -_key_label.size.x / 2.0
	_action_label.position.x = -_action_label.size.x / 2.0
	_action_label.position.y = _key_label.size.y
	_locked_label.position.x = -_locked_label.size.x / 2.0


func show_prompt() -> void:
	_key_label.visible = true
	_action_label.visible = true
	_locked_label.visible = false
	visible = true
	if _appear_tween:
		_appear_tween.kill()
	_appear_tween = create_tween()
	_appear_tween.tween_property(self, "modulate:a", 1.0, 0.15)
	_start_bob()


func hide_prompt() -> void:
	if _appear_tween:
		_appear_tween.kill()
	_appear_tween = create_tween()
	_appear_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	_appear_tween.tween_callback(func(): visible = false)
	_stop_bob()


func show_locked_message(text: String) -> void:
	if _locked_shown:
		return
	_locked_shown = true

	_locked_label.text = text
	_locked_label.visible = true
	_key_label.visible = false
	_action_label.visible = false
	visible = true
	modulate.a = 1.0

	# Re-center after text change
	await get_tree().process_frame
	_locked_label.position.x = -_locked_label.size.x / 2.0

	# Fade out after 2s
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		visible = false
		_locked_label.visible = false
	)


func _start_bob() -> void:
	_stop_bob()
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(self, "position:y", _base_y - 2.0, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(self, "position:y", _base_y, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _stop_bob() -> void:
	if _bob_tween:
		_bob_tween.kill()
		_bob_tween = null
		position.y = _base_y
