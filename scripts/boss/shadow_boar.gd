class_name ShadowBoar
extends BaseEnemy
## Shadow Boar Boss: Massive demonic boar with two-phase combat.
## Stats: 500 HP, 25 contact damage (40 during charge), 80 px/sec movement.
## Phase 1: Chase → Telegraph → Charge → Wall Stun (vulnerable)
## Phase 2 (at 250 HP): Faster charges, ground slam shockwave, wisp summoning.

# Wisp scene for Phase 2 summoning
const WISP_SCENE := preload("res://scenes/enemies/shadow_wisp.tscn")

# Boss states (overrides simple BaseEnemy states)
enum BossState { IDLE, CHASE, TELEGRAPH, CHARGING, STUNNED, SLAM, SUMMONING, TRANSITIONING, DYING }
var boss_state: BossState = BossState.IDLE

# Phase tracking
var current_phase: int = 1
var _phase_transition_done: bool = false

# --- Phase 1 values ---
const P1_CHARGE_SPEED: float = 467.0
const P1_CHARGE_COOLDOWN: float = 4.0
const P1_TELEGRAPH_DURATION: float = 1.0
const P1_STUN_DURATION: float = 2.0

# --- Phase 2 values ---
const P2_CHARGE_SPEED: float = 607.0
const P2_CHARGE_COOLDOWN: float = 3.0
const P2_TELEGRAPH_DURATION: float = 0.7
const P2_STUN_DURATION: float = 1.5

# Charge settings
const CHARGE_RANGE: float = 267.0
const CHARGE_DURATION: float = 0.6
const CHARGE_DAMAGE: int = 40

# Slam settings (Phase 2 only)
const SLAM_RANGE: float = 107.0
const SLAM_COOLDOWN: float = 5.0
const SHOCKWAVE_RADIUS: float = 160.0
const SHOCKWAVE_EXPAND_TIME: float = 0.5
const SHOCKWAVE_DAMAGE: int = 20

# Wisp summoning (Phase 2 only)
const WISP_SUMMON_INTERVAL: float = 8.0
const WISP_SUMMON_COUNT: int = 2
const WISP_MAX_ALIVE: int = 4
const WISP_SPAWN_MIN_DIST: float = 107.0
const WISP_SPAWN_MAX_DIST: float = 160.0

# Phase transition
const PHASE_2_HP_THRESHOLD: int = 250
const TRANSITION_DURATION: float = 1.0

# Timers
var _charge_cooldown_timer: float = 0.0
var _slam_cooldown_timer: float = 0.0
var _stun_timer: float = 0.0
var _telegraph_timer: float = 0.0
var _charge_timer: float = 0.0
var _wisp_summon_timer: float = 0.0
var _charge_direction: Vector2 = Vector2.ZERO

# Summoned wisp tracking
var _summoned_wisps: Array[Node] = []

# Charge hit tracking (prevent multi-hit per charge)
var _charge_hit_player: bool = false

# SFX
var _sfx_boss_charge: AudioStream = preload("res://assets/audio/sfx/boss_charge.wav")
var _sfx_boss_slam: AudioStream = preload("res://assets/audio/sfx/boss_slam.wav")
var _sfx_boss_roar: AudioStream = preload("res://assets/audio/sfx/boss_roar.wav")


func _ready() -> void:
	max_hp = 500
	contact_damage = 25
	move_speed = 107.0
	glow_color = Color(0.6, 0.1, 0.8, 0.6)  # Dark purple shadow aura
	super._ready()
	add_to_group("boss")
	boss_state = BossState.CHASE
	EventBus.boss_spawned.emit(self)


func _physics_process(delta: float) -> void:
	if boss_state == BossState.DYING:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_update_boss_behavior(delta)
	# Only call move_and_slide for states that use velocity
	if boss_state in [BossState.CHASE, BossState.CHARGING]:
		move_and_slide()
		# Check wall collision during charge
		if boss_state == BossState.CHARGING and is_on_wall():
			_on_charge_hit_wall()
	_update_boss_animation()


## Main boss AI — replaces BaseEnemy._update_behavior
func _update_boss_behavior(delta: float) -> void:
	# Update cooldowns
	if _charge_cooldown_timer > 0:
		_charge_cooldown_timer -= delta
	if _slam_cooldown_timer > 0:
		_slam_cooldown_timer -= delta

	# Phase 2: wisp summon timer
	if current_phase == 2:
		_wisp_summon_timer += delta

	match boss_state:
		BossState.IDLE:
			velocity = Vector2.ZERO
			boss_state = BossState.CHASE

		BossState.CHASE:
			_do_chase(delta)

		BossState.TELEGRAPH:
			_do_telegraph(delta)

		BossState.CHARGING:
			_do_charge(delta)

		BossState.STUNNED:
			_do_stunned(delta)

		BossState.SLAM:
			pass  # Handled by await in _perform_slam

		BossState.SUMMONING:
			pass  # Handled by await in _summon_wisps

		BossState.TRANSITIONING:
			pass  # Handled by await in _do_phase_transition


## Chase: move toward player, check attack conditions
func _do_chase(_delta: float) -> void:
	if not _player:
		_find_player()
	if not _player:
		velocity = Vector2.ZERO
		return

	var dist := global_position.distance_to(_player.global_position)

	# Phase 2: Check wisp summon
	if current_phase == 2 and _wisp_summon_timer >= WISP_SUMMON_INTERVAL:
		_wisp_summon_timer = 0.0
		_summon_wisps()
		return

	# Phase 2: Check slam (close range, higher priority than charge)
	if current_phase == 2 and dist < SLAM_RANGE and _slam_cooldown_timer <= 0:
		_perform_slam()
		return

	# Check charge (medium range)
	if dist < CHARGE_RANGE and _charge_cooldown_timer <= 0:
		_start_telegraph()
		return

	# Default: chase
	var direction := _get_direction_to_player()
	velocity = direction * move_speed


## Telegraph: flash red/white, lock direction
func _do_telegraph(delta: float) -> void:
	_telegraph_timer -= delta
	sprite.modulate = Color.RED if int(_telegraph_timer * 10) % 2 == 0 else Color.WHITE
	velocity = Vector2.ZERO

	if _telegraph_timer <= 0:
		_start_charge()


## Charge: move at high speed in locked direction
func _do_charge(delta: float) -> void:
	_charge_timer -= delta
	var charge_speed := P1_CHARGE_SPEED if current_phase == 1 else P2_CHARGE_SPEED
	velocity = _charge_direction * charge_speed

	if _charge_timer <= 0:
		_end_charge()


## Stunned: vulnerable, no movement
func _do_stunned(delta: float) -> void:
	_stun_timer -= delta
	velocity = Vector2.ZERO

	# Visual: slow pulse to show stunned
	sprite.modulate.a = 0.6 + 0.4 * abs(sin(_stun_timer * 4.0))

	if _stun_timer <= 0:
		sprite.modulate = Color.WHITE
		boss_state = BossState.CHASE


func _start_telegraph() -> void:
	boss_state = BossState.TELEGRAPH
	var telegraph_dur := P1_TELEGRAPH_DURATION if current_phase == 1 else P2_TELEGRAPH_DURATION
	_telegraph_timer = telegraph_dur
	velocity = Vector2.ZERO
	AudioManager.play_sfx(_sfx_boss_charge, global_position)

	# Lock charge direction toward player
	if _player:
		_charge_direction = (_player.global_position - global_position).normalized()

	_set_animation_from_direction(_charge_direction, "idle")


func _start_charge() -> void:
	boss_state = BossState.CHARGING
	_charge_timer = CHARGE_DURATION
	_charge_hit_player = false
	sprite.modulate = Color.WHITE

	# Re-lock direction in case player moved slightly
	if _player:
		_charge_direction = (_player.global_position - global_position).normalized()

	_set_animation_from_direction(_charge_direction, "running-8-frames")

	# Spawn shadow trail VFX (visual only)
	VFXManager.spawn("shadow_spawn", global_position)


func _end_charge() -> void:
	var cooldown := P1_CHARGE_COOLDOWN if current_phase == 1 else P2_CHARGE_COOLDOWN
	_charge_cooldown_timer = cooldown
	velocity = Vector2.ZERO
	boss_state = BossState.CHASE


func _on_charge_hit_wall() -> void:
	var stun_dur := P1_STUN_DURATION if current_phase == 1 else P2_STUN_DURATION
	boss_state = BossState.STUNNED
	_stun_timer = stun_dur
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE

	# Destroy any destructible pillars the boss collided with
	_destroy_collided_destructibles()

	# Wall impact VFX and camera trauma
	VFXManager.spawn("death_smoke", global_position)
	EventBus.camera_trauma.emit(0.40)

	var cooldown := P1_CHARGE_COOLDOWN if current_phase == 1 else P2_CHARGE_COOLDOWN
	_charge_cooldown_timer = cooldown


## Destroy destructible objects near the boss after a charge collision
func _destroy_collided_destructibles() -> void:
	for node in get_tree().get_nodes_in_group("destructible"):
		if node.has_method("take_damage"):
			var dist := global_position.distance_to(node.global_position)
			if dist < 53.0:
				node.take_damage(999)  # Instant destroy


## Ground slam with expanding shockwave (Phase 2)
func _perform_slam() -> void:
	boss_state = BossState.SLAM
	velocity = Vector2.ZERO
	_slam_cooldown_timer = SLAM_COOLDOWN

	# Play jump-attack animation
	if _player:
		var dir := (_player.global_position - global_position).normalized()
		_set_animation_from_direction(dir, "jump-attack")

	# Wait for the slam animation (non-looping) or use fixed fallback
	if sprite is AnimatedSprite2D and sprite.sprite_frames \
			and sprite.sprite_frames.has_animation(sprite.animation) \
			and not sprite.sprite_frames.get_animation_loop(sprite.animation):
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.4).timeout

	if boss_state != BossState.SLAM:
		return  # State changed (e.g. died during slam)

	# Spawn shockwave
	_spawn_shockwave()
	boss_state = BossState.CHASE


## Spawn expanding shockwave area damage
func _spawn_shockwave() -> void:
	# Create shockwave Area2D
	var shockwave := Area2D.new()
	shockwave.name = "Shockwave"
	shockwave.global_position = global_position
	shockwave.collision_layer = 0
	shockwave.collision_mask = 1  # Player layer

	var shape := CircleShape2D.new()
	shape.radius = 1.0  # Start small
	var collision := CollisionShape2D.new()
	collision.shape = shape
	shockwave.add_child(collision)

	# Visual ring
	var ring := Node2D.new()
	ring.name = "Ring"
	shockwave.add_child(ring)

	get_tree().current_scene.add_child(shockwave)

	# Track if already hit player this shockwave
	var hit_player := false

	# Connect body entered for damage
	shockwave.body_entered.connect(func(body: Node2D):
		if not hit_player and body.is_in_group("player") and body.has_method("take_damage"):
			hit_player = true
			body.take_damage(SHOCKWAVE_DAMAGE, &"boss_hurt_player")
	)

	# Expand over time
	var tween := create_tween()
	tween.tween_property(shape, "radius", SHOCKWAVE_RADIUS, SHOCKWAVE_EXPAND_TIME)
	tween.tween_callback(shockwave.queue_free)

	# VFX: spawn explosion at center
	VFXManager.spawn("explosion", global_position)
	AudioManager.play_sfx(_sfx_boss_slam, global_position)

	# Camera trauma for ground slam
	EventBus.camera_trauma.emit(0.50)


## Summon Shadow Wisps (Phase 2)
func _summon_wisps() -> void:
	# Clean dead wisps from tracking
	_summoned_wisps = _summoned_wisps.filter(func(w): return is_instance_valid(w) and not w.is_queued_for_deletion())

	var alive_count := _summoned_wisps.size()
	if alive_count >= WISP_MAX_ALIVE:
		return  # Cap reached

	boss_state = BossState.SUMMONING
	velocity = Vector2.ZERO

	var to_spawn := mini(WISP_SUMMON_COUNT, WISP_MAX_ALIVE - alive_count)

	for i in range(to_spawn):
		# Random position near boss
		var angle := randf() * TAU
		var dist := randf_range(WISP_SPAWN_MIN_DIST, WISP_SPAWN_MAX_DIST)
		var spawn_pos := global_position + Vector2(cos(angle), sin(angle)) * dist

		var wisp := WISP_SCENE.instantiate() as Node2D
		wisp.global_position = spawn_pos

		# Add to entities node (same parent as boss)
		var parent_node := get_parent()
		if parent_node:
			parent_node.add_child(wisp)
		_summoned_wisps.append(wisp)

		# VFX at spawn point
		VFXManager.spawn("shadow_spawn", spawn_pos)

	# Brief pause for summoning
	await get_tree().create_timer(0.5).timeout

	if boss_state == BossState.SUMMONING:
		boss_state = BossState.CHASE


## Override take_damage to check phase transition
func take_damage(damage: int, type: StringName = &"arrow_hit") -> void:
	if boss_state == BossState.DYING or boss_state == BossState.TRANSITIONING:
		return

	hp -= damage
	hp = maxi(hp, 0)

	# Emit damage number signal
	EventBus.damage_dealt.emit(global_position, damage, type)

	_flash_white()

	# Boss has reduced knockback resistance
	var is_melee := type == &"melee_hit"
	var boss_kb := 53.0 if is_melee else 27.0
	_apply_knockback(boss_kb)

	# Camera trauma on boss hit (+0.06)
	EventBus.camera_trauma.emit(0.06)

	# Hitstop — 0.03s arrow, 0.06s melee
	HitstopManager.freeze(0.06 if is_melee else 0.03)

	# Update health bar via EventBus
	EventBus.enemy_hit.emit(self, damage)

	# Check phase transition
	if hp <= PHASE_2_HP_THRESHOLD and not _phase_transition_done:
		hp = maxi(hp, 1)  # Don't die during transition
		_do_phase_transition()
		return

	if hp <= 0:
		die()


## Phase 2 transition: invulnerable pause, screen flash, emit signal
func _do_phase_transition() -> void:
	_phase_transition_done = true
	boss_state = BossState.TRANSITIONING
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE

	# Phase transition roar SFX
	AudioManager.play_sfx(_sfx_boss_roar, global_position)

	# Screen flash: white overlay via EventBus
	EventBus.screen_flash_requested.emit(Color.WHITE, 0.60, 0.15)

	# Camera trauma and hitstop for phase transition
	EventBus.camera_trauma.emit(0.60)
	HitstopManager.freeze(0.20)

	# Brief invulnerability period
	await get_tree().create_timer(TRANSITION_DURATION).timeout

	# Apply Phase 2
	current_phase = 2
	# Set timer to interval so wisps spawn on the first chase tick
	_wisp_summon_timer = WISP_SUMMON_INTERVAL

	# Grow 50% bigger
	var grow_tween := create_tween()
	grow_tween.tween_property(sprite, "scale", Vector2(0.75, 0.75), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	EventBus.boss_phase_changed.emit(2)
	print("Shadow Boar entered Phase 2!")

	boss_state = BossState.CHASE


## Override hitbox collision for charge damage
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		if boss_state == BossState.CHARGING and not _charge_hit_player:
			_charge_hit_player = true
			body.take_damage(CHARGE_DAMAGE, &"boss_hurt_player")
		elif boss_state != BossState.CHARGING:
			body.take_damage(contact_damage, &"boss_hurt_player")


## Override die() — kill wisps, emit boss signals
func die() -> void:
	if boss_state == BossState.DYING:
		return
	boss_state = BossState.DYING

	# Silently remove summoned wisps (queue_free, not die()) to avoid
	# triggering enemy_died signals that would miscount enemies_in_room.
	for wisp in _summoned_wisps:
		if is_instance_valid(wisp):
			wisp.queue_free()
	_summoned_wisps.clear()

	# Reset visuals
	sprite.modulate = Color.WHITE

	# Disable collision
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	# Emit boss-specific signal
	EventBus.boss_died.emit(self)

	# Call base die() for standard death flow (signals, animation, queue_free)
	super.die()


## Boss animation based on boss_state
func _update_boss_animation() -> void:
	if boss_state == BossState.DYING:
		return

	match boss_state:
		BossState.CHASE:
			if velocity.length() > 10.0:
				_set_animation_from_direction(velocity, "walk-8-frames")
			else:
				_set_animation_from_direction(velocity if velocity.length() > 0 else Vector2.DOWN, "idle")
		BossState.TELEGRAPH:
			_set_animation_from_direction(_charge_direction, "idle")
		BossState.CHARGING:
			_set_animation_from_direction(_charge_direction, "running-8-frames")
		BossState.STUNNED:
			_set_animation_from_direction(_charge_direction, "idle")
		BossState.SLAM:
			pass  # Handled in _perform_slam
		BossState.SUMMONING:
			_set_animation_from_direction(Vector2.DOWN, "idle")
		BossState.TRANSITIONING:
			_set_animation_from_direction(Vector2.DOWN, "idle")


## Play death animation override
func _play_death_animation() -> void:
	if sprite is AnimatedSprite2D and sprite.sprite_frames:
		var dir := _get_animation_direction()
		# Try attack animation as death (no dedicated death anim)
		var death_anim := "attack_" + dir
		if sprite.sprite_frames.has_animation(death_anim):
			sprite.play(death_anim)
			await sprite.animation_finished

	# Then dissolve
	await super._play_death_animation()


## Set animation with direction handling (west→flip east)
func _set_animation_from_direction(dir: Vector2, anim_name: String) -> void:
	if not sprite is AnimatedSprite2D or not sprite.sprite_frames:
		return

	var suffix := "_south"
	if abs(dir.x) > abs(dir.y):
		suffix = "_east" if dir.x > 0 else "_west"
	else:
		suffix = "_south" if dir.y > 0 else "_north"

	var full_anim := anim_name + suffix
	if sprite.sprite_frames.has_animation(full_anim):
		sprite.flip_h = false
		if sprite.animation != full_anim:
			sprite.play(full_anim)
	elif suffix == "_west":
		var east_anim := anim_name + "_east"
		if sprite.sprite_frames.has_animation(east_anim):
			sprite.flip_h = true
			if sprite.animation != east_anim:
				sprite.play(east_anim)
