## VFXManager - Autoload for spawning visual effects
## Usage: VFXManager.spawn("hit_spark", position)
extends Node

# Preloaded VFX scenes
const VFX_SCENES := {
	"hit_spark": preload("res://assets/vfx/scenes/hit_spark.tscn"),
	"arrow_trail": preload("res://assets/vfx/scenes/arrow_trail.tscn"),
	"dash_trail": preload("res://assets/vfx/scenes/dash_trail.tscn"),
	"death_smoke": preload("res://assets/vfx/scenes/death_smoke.tscn"),
	"explosion": preload("res://assets/vfx/scenes/explosion.tscn"),
	"ambient_dust": preload("res://assets/vfx/scenes/ambient_dust.tscn"),
	"shadow_spawn": preload("res://assets/vfx/scenes/shadow_spawn.tscn"),
	# Portal and shrine VFX
	"portal_idle": preload("res://assets/vfx/scenes/portal_idle.tscn"),
	"portal_activate": preload("res://assets/vfx/scenes/portal_activate.tscn"),
	"portal_travel": preload("res://assets/vfx/scenes/portal_travel.tscn"),
	"heal_burst": preload("res://assets/vfx/scenes/heal_burst.tscn"),
	"heal_shrine_spiral": preload("res://scenes/vfx/heal_shrine_vfx.tscn"),
	"spawn_emerge": preload("res://scenes/vfx/spawn_emerge.tscn"),
	# Combat Economy VFX
	"shard_spawn_burst": preload("res://assets/vfx/scenes/shard_spawn_burst.tscn"),
	"shard_collect_burst": preload("res://assets/vfx/scenes/shard_collect_burst.tscn"),
	"sun_piercer_impact": preload("res://assets/vfx/scenes/sun_piercer_impact.tscn"),
	# Skill VFX
	"ward_aura": preload("res://assets/vfx/scenes/ward_aura.tscn"),
}

# Container for spawned effects
var _vfx_container: Node2D


func _ready() -> void:
	_vfx_container = Node2D.new()
	_vfx_container.name = "VFXContainer"
	_vfx_container.z_index = 10  # Render above game objects
	add_child(_vfx_container)


## Spawn a VFX at a global position
## Returns the spawned node for further control
func spawn(vfx_name: String, global_pos: Vector2, parent: Node = null) -> Node2D:
	if not VFX_SCENES.has(vfx_name):
		push_warning("VFXManager: Unknown VFX '%s'" % vfx_name)
		return null

	var vfx_instance: Node2D = VFX_SCENES[vfx_name].instantiate()

	# CRITICAL: Set position BEFORE adding to tree to prevent interpolation flash
	vfx_instance.global_position = global_pos

	# Disable physics interpolation for instant VFX (prevents frame-1 position bug)
	vfx_instance.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

	# Add to container or specified parent
	if parent:
		parent.add_child(vfx_instance)
	else:
		_vfx_container.add_child(vfx_instance)

	# Auto-start all particle systems in the effect
	var all_particles := _get_all_particles(vfx_instance)
	var longest_oneshot: GPUParticles2D = null
	var max_lifetime: float = 0.0

	for particles in all_particles:
		particles.emitting = true
		# Track the longest one-shot for auto-cleanup
		if particles.one_shot and particles.lifetime > max_lifetime:
			max_lifetime = particles.lifetime
			longest_oneshot = particles

	# Connect cleanup to the longest one-shot particle system
	if longest_oneshot:
		longest_oneshot.finished.connect(_on_vfx_finished.bind(vfx_instance))

	return vfx_instance


## Get first GPUParticles2D from a node (for attached/single effects)
func _get_particles(node: Node) -> GPUParticles2D:
	if node is GPUParticles2D:
		return node
	for child in node.get_children():
		if child is GPUParticles2D:
			return child
	return null


## Get all GPUParticles2D from a node (handles composite effects with multiple layers)
func _get_all_particles(node: Node) -> Array[GPUParticles2D]:
	var result: Array[GPUParticles2D] = []
	if node is GPUParticles2D:
		result.append(node)
		return result
	for child in node.get_children():
		if child is GPUParticles2D:
			result.append(child)
	return result


## Spawn VFX attached to a node (follows the node)
## Returns the GPUParticles2D for direct control (emitting, etc.)
func spawn_attached(vfx_name: String, attach_to: Node2D) -> GPUParticles2D:
	if not VFX_SCENES.has(vfx_name):
		push_warning("VFXManager: Unknown VFX '%s'" % vfx_name)
		return null

	var vfx_instance: Node2D = VFX_SCENES[vfx_name].instantiate()

	# Set local position before adding to tree
	vfx_instance.position = Vector2.ZERO

	# Disable physics interpolation for instant VFX
	vfx_instance.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

	attach_to.add_child(vfx_instance)

	# Return the actual particles for direct control
	var particles := _get_particles(vfx_instance)
	if particles:
		particles.emitting = true
	return particles


## Spawn VFX with custom rotation
func spawn_rotated(vfx_name: String, global_pos: Vector2, rotation: float) -> Node2D:
	var vfx := spawn(vfx_name, global_pos)
	if vfx:
		vfx.rotation = rotation
	return vfx


## Clean up finished one-shot VFX
func _on_vfx_finished(vfx_instance: Node) -> void:
	vfx_instance.queue_free()


## Preload all VFX for faster spawning
func warmup() -> void:
	for key in VFX_SCENES:
		var _dummy: Node = VFX_SCENES[key].instantiate()
		_dummy.queue_free()
