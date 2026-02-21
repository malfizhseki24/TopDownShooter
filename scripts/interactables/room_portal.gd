class_name RoomPortal
extends Area2D
## Portal that transports player to the next room.
## Activates when current room is cleared.

## Which room this portal leads to
@export var next_room_index: int = 0

@onready var portal_visual: Node2D = $PortalVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var interact_prompt: InteractPrompt = $InteractPrompt
@onready var portal_vfx: Node2D = $PortalVFX

var is_active: bool = false
var player_in_range: bool = false


func _ready() -> void:
	# Layer 1: Objects (above map, below entities)
	z_index = 1

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Start inactive (visual dimmed, but keep collision enabled)
	_set_inactive_visual()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("Portal: Interact pressed, player_in_range=%s, is_active=%s" % [player_in_range, is_active])
		if player_in_range and is_active:
			_travel_to_next_room()


## Activate portal when room is cleared
func activate() -> void:
	is_active = true
	_activate_deferred.call_deferred()


func _activate_deferred() -> void:
	# Visual feedback - show portal
	if portal_visual:
		portal_visual.visible = true
		portal_visual.modulate = Color(1, 1, 1, 1)

	# Enable light
	if point_light:
		point_light.enabled = true

	# Trigger activation VFX
	if portal_vfx and portal_vfx.has_method("set_state"):
		portal_vfx.set_state(portal_vfx.PortalState.ACTIVATED)

	# Show prompt if player is already in range
	if player_in_range and interact_prompt:
		interact_prompt.show_prompt()

	print("Portal activated - leads to room %d" % next_room_index)


## Deactivate portal (default state)
func deactivate() -> void:
	is_active = false
	_set_inactive_visual()


func _set_inactive_visual() -> void:
	# Visual feedback - dim portal (but keep collision enabled for detection)
	if portal_visual:
		portal_visual.modulate = Color(0.3, 0.3, 0.3, 0.5)

	# Disable light
	if point_light:
		point_light.enabled = false


## Set which room this portal leads to
func set_next_room_index(index: int) -> void:
	next_room_index = index


func _on_body_entered(body: Node2D) -> void:
	print("Portal: Body entered - %s (is_player: %s)" % [body.name, body.is_in_group("player")])

	if not body.is_in_group("player"):
		return

	player_in_range = true
	print("Portal: Player in range! is_active=%s" % is_active)

	if is_active:
		# Show interact prompt
		EventBus.show_interact_prompt.emit("Press E to enter portal")
		if interact_prompt:
			interact_prompt.show_prompt()
	else:
		# Show locked message (only once)
		if interact_prompt:
			interact_prompt.show_locked_message("Defeat all enemies")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		EventBus.hide_interact_prompt.emit()
		if interact_prompt:
			interact_prompt.hide_prompt()
		print("Portal: Player exited")


func _travel_to_next_room() -> void:
	# Prevent double-activation
	is_active = false

	# Trigger travel VFX
	if portal_vfx and portal_vfx.has_method("set_state"):
		portal_vfx.set_state(portal_vfx.PortalState.TRAVEL)

	# Let VFX play before fade-to-black covers the screen
	await get_tree().create_timer(0.35).timeout

	print("Traveling to room %d" % next_room_index)

	# Signal to RoomManager to load next room
	EventBus.room_transition_requested.emit(next_room_index)
