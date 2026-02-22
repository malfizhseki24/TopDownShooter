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
@export var shard_drop_chance: float = 0.75  # 75% chance to drop Sun Shard

# Audio
@export var death_sound: AudioStream

# Glow layer
@export var glow_color: Color = Color(1.0, 0.4, 0.2, 0.5)  # Warm orange-red default
@export var glow_enabled: bool = true

var hp: int

# State machine
enum State { IDLE, MOVING, ATTACKING, DYING }
var current_state: State = State.IDLE

# References
@onready var sprite: Node = $AnimatedSprite2D if has_node("AnimatedSprite2D") else $Sprite2D
@onready var hitbox: Area2D = $Hitbox

# Player reference (cached)
var _player: Node2D = null

# Knockback impulse velocity (decays via friction)
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_FRICTION: float = 600.0

# Hit flash + dissolve shader (shared resources)
var _hit_flash_shader: Shader = preload("res://shaders/hit_flash.gdshader")
var _dissolve_noise: Texture2D = preload("res://resources/dissolve_noise.tres")

# Flash tween reference
var _flash_tween: Tween = null

# Spawn animation state (invulnerable during spawn)
var _is_spawning: bool = false

# SFX
var _sfx_enemy_death: AudioStream = preload("res://assets/audio/sfx/enemy_death.wav")
var _sfx_enemy_spawn: AudioStream = preload("res://assets/audio/sfx/enemy_spawn.wav")


func _ready() -> void:
	hp = max_hp

	# Layer 2: Entities (above objects, below VFX)
	z_index = 2

	add_to_group("enemy")
	_connect_signals()
	_find_player()
	# Apply hit flash shader to sprite
	_setup_hit_flash_shader()
	# Cache base sprite scale for squash/stretch
	if sprite:
		_base_sprite_scale = sprite.scale
	# Initialize sprite animation to ensure correct first frame
	_init_sprite_animation()
	# Add glow layer
	if glow_enabled:
		_setup_glow_layer()
	# Play spawn effect
	_play_spawn_effect()
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

	# Decay knockback velocity via friction
	if knockback_velocity.length() > 1.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)

	_update_behavior(delta)

	# Apply knockback on top of behavior velocity
	velocity += knockback_velocity
	move_and_slide()
	# Remove knockback contribution from velocity so subclasses don't accumulate it
	velocity -= knockback_velocity
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
func take_damage(damage: int, type: StringName = &"arrow_hit") -> void:
	if current_state == State.DYING or _is_spawning:
		return

	hp -= damage
	hp = maxi(hp, 0)

	# Emit damage number signal
	EventBus.damage_dealt.emit(global_position, damage, type)

	_flash_white()
	_squash_stretch(Vector2(1.3, 0.7), 0.1)

	# Knockback — impulse-based, per-type distances
	var is_kill := hp <= 0
	var is_melee := type == &"melee_hit"
	var kb_dist: float
	if is_kill:
		kb_dist = 200.0 if is_melee else 120.0
	else:
		kb_dist = 150.0 if is_melee else 80.0
	_apply_knockback(kb_dist)

	# Camera trauma — different values for arrow vs melee, hit vs kill
	if is_kill:
		EventBus.camera_trauma.emit(0.25 if is_melee else 0.12)
	else:
		EventBus.camera_trauma.emit(0.15 if is_melee else 0.08)

	# Hitstop — arrow: 0.04s hit/0.07s kill; melee: 0.08s hit/0.12s kill
	if is_kill:
		HitstopManager.freeze(0.12 if is_melee else 0.07)
	else:
		HitstopManager.freeze(0.08 if is_melee else 0.04)

	if is_kill:
		die()


## Die and play death animation
func die() -> void:
	current_state = State.DYING
	velocity = Vector2.ZERO
	AudioManager.play_sfx(_sfx_enemy_death, global_position)

	# Death stretch effect
	_squash_stretch(Vector2(0.6, 1.4), 0.15)

	# Emit signals
	died.emit()
	EventBus.enemy_died.emit(self)

	# Drop Sun Shard (chance-based)
	_try_drop_shard()

	# Play death animation and wait for it to complete
	await _play_death_animation()

	# Remove after death animation completes
	queue_free()


## Play death animation - override for custom death anims
func _play_death_animation() -> void:
	# Play death sound at enemy position
	if death_sound:
		AudioManager.play_sfx(death_sound, global_position)

	# Stay visible for 2.5 seconds
	await get_tree().create_timer(2.5).timeout

	# Spawn death smoke when body starts dissolving
	VFXManager.spawn("death_smoke", global_position)

	# Dissolve using shader (purple burn edge effect)
	var mat: ShaderMaterial = sprite.material as ShaderMaterial if sprite else null
	if mat:
		var tween := create_tween().set_parallel(true)
		tween.tween_property(mat, "shader_parameter/dissolve_amount", 1.0, 1.0).set_ease(Tween.EASE_IN)
		# Also fade the glow sprite if present
		var glow_sprite := get_node_or_null("GlowSprite")
		if glow_sprite:
			tween.tween_property(glow_sprite, "modulate:a", 0.0, 0.8)
		await tween.finished
	else:
		# Fallback: simple alpha fade if no shader
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
		await tween.finished


## Setup hit flash + dissolve shader material on sprite
func _setup_hit_flash_shader() -> void:
	if not sprite:
		return
	# Only apply if sprite doesn't already have a shader material
	if sprite.material is ShaderMaterial:
		return
	var mat := ShaderMaterial.new()
	mat.shader = _hit_flash_shader
	mat.set_shader_parameter("flash_intensity", 0.0)
	mat.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	# Dissolve params (inactive until dissolve_amount > 0)
	mat.set_shader_parameter("dissolve_texture", _dissolve_noise)
	mat.set_shader_parameter("dissolve_amount", 0.0)
	mat.set_shader_parameter("burn_size", 0.08)
	mat.set_shader_parameter("burn_color", Color(0.6, 0.2, 0.8, 1.0))
	mat.set_shader_parameter("emission_amount", 2.0)
	sprite.material = mat


## Setup additive glow layer using duplicate sprite with additive blend
func _setup_glow_layer() -> void:
	if not sprite:
		return

	# Create CanvasItemMaterial with additive blend
	var glow_mat := CanvasItemMaterial.new()
	glow_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	if sprite is AnimatedSprite2D:
		# Duplicate as AnimatedSprite2D to follow animations
		var glow := AnimatedSprite2D.new()
		glow.name = "GlowSprite"
		glow.sprite_frames = sprite.sprite_frames
		glow.animation = sprite.animation
		glow.scale = sprite.scale * 1.05  # Slightly larger for glow bleed
		glow.modulate = glow_color
		glow.material = glow_mat
		glow.z_index = -1  # Behind main sprite
		add_child(glow)

		# Sync animation with main sprite
		sprite.animation_changed.connect(func():
			if is_instance_valid(glow):
				glow.animation = sprite.animation
		)
		sprite.frame_changed.connect(func():
			if is_instance_valid(glow):
				glow.frame = sprite.frame
		)
	elif sprite is Sprite2D:
		var glow := Sprite2D.new()
		glow.name = "GlowSprite"
		glow.texture = sprite.texture
		glow.scale = sprite.scale * 1.05
		glow.modulate = glow_color
		glow.material = glow_mat
		glow.z_index = -1
		add_child(glow)


## Flash white when hit (shader-based)
func _flash_white() -> void:
	var mat: ShaderMaterial = sprite.material as ShaderMaterial
	if not mat:
		return
	if _flash_tween:
		_flash_tween.kill()
	mat.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	mat.set_shader_parameter("flash_intensity", 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(mat, "shader_parameter/flash_intensity", 0.0, 0.08)


## Apply knockback impulse away from damage source
func _apply_knockback(distance: float) -> void:
	var knockback_dir := Vector2.ZERO
	if _player:
		knockback_dir = (global_position - _player.global_position).normalized()
	if knockback_dir == Vector2.ZERO:
		knockback_dir = Vector2.DOWN
	# Set impulse velocity — friction in _physics_process decays it
	knockback_velocity = knockback_dir * distance * 6.0


## Squash/stretch the sprite with tween (targets sprite.scale, not root)
## target_scale is a multiplier relative to _base_sprite_scale (e.g., Vector2(1.3, 0.7))
var _squash_tween: Tween = null
var _base_sprite_scale: Vector2 = Vector2(0.5, 0.5)

func _squash_stretch(target_scale: Vector2, duration: float) -> void:
	if _squash_tween:
		_squash_tween.kill()
	var actual_target := _base_sprite_scale * target_scale
	_squash_tween = create_tween()
	_squash_tween.tween_property(sprite, "scale", actual_target, duration * 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_squash_tween.tween_property(sprite, "scale", _base_sprite_scale, duration * 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


## Return contact damage for player collision
func get_contact_damage() -> int:
	return contact_damage


## Try to drop a Sun Shard on death
func _try_drop_shard() -> void:
	if randf() >= shard_drop_chance:
		return

	# Emit signal for shard spawner to handle
	EventBus.shard_dropped.emit(global_position)


## Play spawn effect (shadow emergence with squash/stretch scale animation)
func _play_spawn_effect() -> void:
	# Spawn shadow smoke puff
	VFXManager.spawn("shadow_spawn", global_position)
	VFXManager.spawn("spawn_emerge", global_position)
	AudioManager.play_sfx(_sfx_enemy_spawn, global_position)

	if not sprite:
		return

	# Start invulnerable during spawn
	_is_spawning = true

	# Scale animation: (0, 0) → (1.1, 0.9) → (1.0, 1.0) over 0.3s
	var target_scale := _base_sprite_scale
	sprite.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(sprite, "scale", target_scale * Vector2(1.1, 0.9), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", target_scale, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func(): _is_spawning = false)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
