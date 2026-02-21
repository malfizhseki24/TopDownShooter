extends Area2D
## Spirit Ember pickup — heals player for 5 HP on collection.

const HEAL_AMOUNT: int = 5

var _sfx_pickup: AudioStream = preload("res://assets/audio/sfx/pickup_chime.wav")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		EventBus.player_healed.emit(HEAL_AMOUNT)
		AudioManager.play_sfx(_sfx_pickup, global_position)
		VFXManager.spawn("heal_burst", global_position)
		queue_free()
