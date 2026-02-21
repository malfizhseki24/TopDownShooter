class_name BaseDestructible
extends StaticBody2D
## Base class for breakable environmental objects.
## Subclasses configure HP, break FX, and visual appearance via scene.

@export var max_hp: int = 1
@export var destructible_type: String = "generic"
@export var drop_table_enabled: bool = true

var hp: int

# Break VFX name (registered in VFXManager)
@export var break_vfx: String = "hit_spark"

# Type-specific break SFX mapping
const BREAK_SFX := {
	"pot": "res://assets/audio/sfx/destructible_break_pot.wav",
	"pottery": "res://assets/audio/sfx/destructible_break_pot.wav",
	"crystal": "res://assets/audio/sfx/destructible_break_crystal.wav",
	"wood": "res://assets/audio/sfx/destructible_break_wood.wav",
	"bone": "res://assets/audio/sfx/destructible_break_bone.wav",
}


func _ready() -> void:
	hp = max_hp
	add_to_group("destructible")


func take_damage(amount: int) -> void:
	hp -= amount
	hp = maxi(hp, 0)

	if hp <= 0:
		_break()


func _break() -> void:
	# Spawn break VFX
	if break_vfx != "":
		VFXManager.spawn(break_vfx, global_position)

	# Play type-specific break SFX
	var sfx_path: String = BREAK_SFX.get(destructible_type, "res://assets/audio/sfx/destructible_break_pot.wav")
	var sfx := AudioManager.load_sfx(sfx_path)
	AudioManager.play_sfx(sfx, global_position)

	# Camera trauma + hitstop
	EventBus.camera_trauma.emit(0.03)
	HitstopManager.freeze(0.02)

	# Roll drops
	if drop_table_enabled:
		DropSpawner.roll_drop(global_position)

	# Emit signal
	EventBus.destructible_broken.emit(global_position, destructible_type)

	# Remove
	queue_free()
