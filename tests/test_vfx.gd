extends Node2D
## Test scene for VFX effects
## Run this scene to preview all particle effects

# Preload all VFX scenes
const VFX_SCENES := {
	"hit_spark": preload("res://assets/vfx/scenes/hit_spark.tscn"),
	"arrow_trail": preload("res://assets/vfx/scenes/arrow_trail.tscn"),
	"dash_trail": preload("res://assets/vfx/scenes/dash_trail.tscn"),
	"death_smoke": preload("res://assets/vfx/scenes/death_smoke.tscn"),
	"explosion": preload("res://assets/vfx/scenes/explosion.tscn"),
	"shadow_spawn": preload("res://assets/vfx/scenes/shadow_spawn.tscn"),
}

@onready var spawn_point: Marker2D = $SpawnPoint


func _spawn_vfx(vfx_name: String) -> void:
	var vfx_instance: Node2D = VFX_SCENES[vfx_name].instantiate()
	vfx_instance.global_position = spawn_point.global_position
	add_child(vfx_instance)

	# Auto-start one-shot effects
	if vfx_instance is GPUParticles2D:
		var particles := vfx_instance as GPUParticles2D
		if particles.one_shot:
			particles.emitting = true
			particles.finished.connect(particles.queue_free)
	elif vfx_instance is Node2D:
		# Handle composite effects (like explosion with multiple particles)
		for child in vfx_instance.get_children():
			if child is GPUParticles2D:
				child.emitting = true
		# Clean up after all particles finish
		await get_tree().create_timer(2.0).timeout
		vfx_instance.queue_free()


func _on_hit_spark_btn_pressed() -> void:
	_spawn_vfx("hit_spark")


func _on_arrow_trail_btn_pressed() -> void:
	_spawn_vfx("arrow_trail")


func _on_dash_trail_btn_pressed() -> void:
	_spawn_vfx("dash_trail")


func _on_death_smoke_btn_pressed() -> void:
	_spawn_vfx("death_smoke")


func _on_explosion_btn_pressed() -> void:
	_spawn_vfx("explosion")


func _on_shadow_spawn_btn_pressed() -> void:
	_spawn_vfx("shadow_spawn")
