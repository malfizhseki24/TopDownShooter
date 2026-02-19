class_name BaseEnemy
extends CharacterBody2D
## Base class for all enemy types in the game.
## Provides common functionality: HP, damage, movement, hit feedback, death.
##
## Subclasses should override:
##   - _update_behavior(delta) for movement AI
##   - _update_animation() for sprite animations
##   - die() if custom death behavior needed (e.g., respawn)

## Emitted when enemy dies
signal died

# Stats (to be overridden by subclasses)
@export var max_hp: int = 25
@export var contact_damage: int = 10
@export var move_speed: float = 80.0

# Audio
@export var death_sound: AudioStream

var hp: int

# State machine
enum State { IDLE, MOVING, ATTACKING, DYING }
var current_state: State = State.IDLE

# References
@onready var sprite: Node = $AnimatedSprite2D if has_node("AnimatedSprite2D") else $Sprite2D
@onready var hitbox: Area2D = $Hitbox

# Player reference (cached)
var _player: Node2D = null


func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	_connect_signals()
	_find_player()
	# Initialize sprite animation to ensure correct first frame
	_init_sprite_animation()
	# Emit spawn signal for tracking (works for both pre-placed and spawned enemies)
	EventBus.enemy_spawned.emit(self)


func _init_sprite_animation() -> void:
	# Ensure sprite starts with correct animation (fixes flash of wrong sprite on spawn)
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		# Force animation and frame before first render
		if sprite.sprite_frames.has_animation("idle_south"):
			sprite.animation = &"idle_south"
			sprite.frame = 0
			sprite.play("idle_south")


func _physics_process(delta: float) -> void:
	if current_state == State.DYING:
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_update_behavior(delta)
	move_and_slide()
	_update_animation()


func _connect_signals() -> void:
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]


## Override in subclasses for specific movement behavior
func _update_behavior(_delta: float) -> void:
	pass


## Override in subclasses for animation updates
func _update_animation() -> void:
	pass


## Get the direction toward the player
func _get_direction_to_player() -> Vector2:
	if not _player:
		_find_player()
	if not _player:
		return Vector2.ZERO
	return (_player.global_position - global_position).normalized()


## Get cardinal direction string from current velocity (north, south, east, west)
## Use this for animation names like "walk_north", "attack_east", etc.
func _get_animation_direction() -> String:
	return _get_animation_direction_from_vector(velocity)


## Get cardinal direction string from a given direction vector
## Useful when you need direction before setting velocity (e.g., during attack)
func _get_animation_direction_from_vector(dir: Vector2) -> String:
	if dir.y < -0.5:
		return "north"
	elif dir.y > 0.5:
		return "south"
	elif dir.x < 0:
		return "west"
	else:
		return "east"


## Take damage from an external source
func take_damage(damage: int) -> void:
	if current_state == State.DYING:
		return

	hp -= damage
	hp = maxi(hp, 0)

	_flash_white()
	_knockback()

	if hp <= 0:
		die()


## Die and play death animation
func die() -> void:
	current_state = State.DYING
	velocity = Vector2.ZERO

	# Emit signals
	died.emit()
	EventBus.enemy_died.emit(self)

	# Play death animation and wait for it to complete
	await _play_death_animation()

	# Remove after death animation completes
	queue_free()


## Play death animation - override for custom death anims
func _play_death_animation() -> void:
	# Play death sound at enemy position
	if death_sound:
		AudioManager.play_sfx(death_sound, global_position)

	# Stay visible for 2.5 seconds, then dissolve over 1 second
	await get_tree().create_timer(2.5).timeout

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)


## Flash white when hit
func _flash_white() -> void:
	# Store original modulate
	var original_modulate: Color = sprite.modulate

	# Flash to red (damage indication)
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout

	# Restore original
	sprite.modulate = original_modulate


## Knockback away from damage source
func _knockback() -> void:
	var knockback_dir := Vector2.ZERO
	if _player:
		knockback_dir = (global_position - _player.global_position).normalized()

	var knockback_dist := 50.0
	var target_pos := global_position + knockback_dir * knockback_dist

	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.15)


## Return contact damage for player collision
func get_contact_damage() -> int:
	return contact_damage


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
