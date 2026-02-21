extends Node2D
## Floating damage number — spawns at hit position, floats up/down, fades, self-destructs.

@onready var label: Label = $Label

var float_up: bool = true

const FLOAT_DISTANCE: float = 40.0
const LIFETIME: float = 0.6


func setup(value: int, color: Color, font_size: int, is_heal: bool = false, p_float_up: bool = true) -> void:
	float_up = p_float_up

	# Set text
	label.text = ("+%d" if is_heal else "-%d") % abs(value)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)

	# Random horizontal offset to prevent stacking
	position.x += randf_range(-8.0, 8.0)

	# Scale pop: 150% → 100%
	scale = Vector2(1.5, 1.5)
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

	# Float up or down
	var direction := -1.0 if float_up else 1.0
	var target_y := position.y + (FLOAT_DISTANCE * direction)
	tween.parallel().tween_property(self, "position:y", target_y, LIFETIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Fade out during final half
	tween.tween_property(label, "modulate:a", 0.0, LIFETIME * 0.5).set_delay(LIFETIME * 0.5 - 0.1)

	# Self-destruct
	tween.tween_callback(queue_free)
