extends Node2D
## Manages portal visual effects: idle shimmer, activation burst, travel warp.
## Added as child of RoomPortal scene.
## Uses RPicster soft glow textures for polished particle look.

enum PortalState { IDLE_LOCKED, IDLE_UNLOCKED, ACTIVATED, TRAVEL }

var current_state: PortalState = PortalState.IDLE_LOCKED

@onready var idle_particles: GPUParticles2D = $IdleParticles
@onready var floaty_particles: GPUParticles2D = $FloatyParticles


func _ready() -> void:
	set_state(PortalState.IDLE_LOCKED)


func set_state(new_state: PortalState) -> void:
	current_state = new_state
	match current_state:
		PortalState.IDLE_LOCKED:
			_set_idle_locked()
		PortalState.IDLE_UNLOCKED, PortalState.ACTIVATED:
			_set_activated()
		PortalState.TRAVEL:
			_play_travel()


func _set_idle_locked() -> void:
	if idle_particles:
		idle_particles.emitting = true
		# Dim and slow for locked state
		idle_particles.speed_scale = 0.5
		idle_particles.modulate = Color(0.4, 0.6, 0.8, 0.4)
	if floaty_particles:
		floaty_particles.emitting = true
		floaty_particles.speed_scale = 0.4
		floaty_particles.modulate = Color(0.3, 0.5, 0.7, 0.3)


func _set_activated() -> void:
	if idle_particles:
		idle_particles.emitting = true
		# Bright and normal speed for active state
		idle_particles.speed_scale = 1.0
		idle_particles.modulate = Color(0.6, 0.9, 1.0, 1.0)
	if floaty_particles:
		floaty_particles.emitting = true
		floaty_particles.speed_scale = 1.0
		floaty_particles.modulate = Color(0.5, 0.8, 1.0, 0.7)
	# Spawn activation burst
	VFXManager.spawn("portal_activate", global_position)


func _play_travel() -> void:
	# Spawn travel warp burst
	VFXManager.spawn("portal_travel", global_position)
	# Brief screen flash for warp feel
	EventBus.screen_flash_requested.emit(Color(0.6, 0.9, 1.0), 0.3, 0.15)
	# Stop all particles during travel
	if idle_particles:
		idle_particles.emitting = false
	if floaty_particles:
		floaty_particles.emitting = false
