extends Area2D
## Shadow Fragment pickup — increments collectible counter in GameManager.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.shadow_fragments += 1
		VFXManager.spawn("hit_spark", global_position)
		queue_free()
