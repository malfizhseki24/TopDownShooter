extends Sprite2D
## A ghost sprite that captures the player's current frame and fades out.
## Spawned during dash to create afterimage trail effect.

const FADE_DURATION: float = 0.15
const START_ALPHA: float = 0.6


func _ready() -> void:
	# Start faded
	modulate.a = START_ALPHA
	# Tint slightly blue/desaturated
	modulate = Color(0.6, 0.7, 1.0, START_ALPHA)
	# Fade to transparent and self-free
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(queue_free)


## Setup the afterimage with the player's current sprite data
func setup(tex: Texture2D, flip_h_value: bool, sprite_scale: Vector2) -> void:
	texture = tex
	flip_h = flip_h_value
	scale = sprite_scale
