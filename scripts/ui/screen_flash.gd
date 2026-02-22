extends ColorRect
## Full-screen color overlay for hit flashes, death fade, etc.
## Lives on a CanvasLayer so it renders above everything.
## Connects to EventBus.screen_flash_requested for decoupled triggering.

var _flash_tween: Tween = null


func _ready() -> void:
	# Start fully transparent
	color = Color(0, 0, 0, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

	EventBus.screen_flash_requested.connect(_on_flash_requested)
	EventBus.player_died.connect(_on_player_died)


func _on_flash_requested(flash_color: Color, opacity: float, duration: float) -> void:
	if _flash_tween:
		_flash_tween.kill()

	# Set color with target opacity
	color = Color(flash_color.r, flash_color.g, flash_color.b, opacity)

	# Fade out
	_flash_tween = create_tween()
	_flash_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_flash_tween.tween_property(self, "color:a", 0.0, duration)


func _on_player_died() -> void:
	# Death fade is handled by HUD's FadeRect instead
	# This ScreenFlash stays transparent so it doesn't cover the GameOver screen
	pass
