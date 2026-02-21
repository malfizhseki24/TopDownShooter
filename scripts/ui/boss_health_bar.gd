extends Control
## Boss health bar UI — ColorRect-based bar with damage trail, phase transition FX, and defeat fade.
## Connects to EventBus signals for boss_spawned, enemy_hit, boss_phase_changed, boss_died.

@onready var boss_name_label: Label = $BossName
@onready var bar_fill: ColorRect = $BarFill
@onready var damage_trail: ColorRect = $DamageTrail

const BAR_INNER_WIDTH: float = 236.0  # 240 - 4px padding
const COLOR_PHASE1 := Color("#ee4540")
const COLOR_PHASE2 := Color("#2d132c")

var _boss_ref: Node = null
var _max_hp: int = 1
var _trail_tween: Tween = null
var _initial_y: float = 0.0


func _ready() -> void:
	visible = false
	_initial_y = position.y
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.enemy_hit.connect(_on_enemy_hit)
	EventBus.boss_phase_changed.connect(_on_boss_phase_changed)
	EventBus.boss_died.connect(_on_boss_died)


func _on_boss_spawned(boss: Node) -> void:
	_boss_ref = boss
	_max_hp = boss.max_hp

	# Reset bar
	bar_fill.size.x = BAR_INNER_WIDTH
	bar_fill.color = COLOR_PHASE1
	damage_trail.size.x = BAR_INNER_WIDTH
	boss_name_label.modulate.a = 0.0

	# Slide in from below viewport
	visible = true
	modulate.a = 1.0
	var slide_offset := 40.0
	position.y = _initial_y + slide_offset

	var tween := create_tween()
	tween.tween_property(self, "position:y", _initial_y, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Fade in boss name after bar arrives
	tween.tween_property(boss_name_label, "modulate:a", 1.0, 0.3)


func _on_enemy_hit(enemy: Node, _damage: int) -> void:
	if enemy != _boss_ref or not _boss_ref:
		return
	var current_hp: int = _boss_ref.hp
	var fill_ratio := float(current_hp) / float(_max_hp)
	var new_width := fill_ratio * BAR_INNER_WIDTH

	# Instant fill update
	bar_fill.size.x = new_width

	# Damage trail drains over 0.6s
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_property(damage_trail, "size:x", new_width, 0.6)


func _on_boss_phase_changed(phase: int) -> void:
	if phase == 2:
		# Flash bar white briefly, then transition to purple
		var tween := create_tween()
		tween.tween_property(bar_fill, "color", Color.WHITE, 0.05)
		tween.tween_interval(0.1)
		tween.tween_property(bar_fill, "color", COLOR_PHASE2, 0.3)


func _on_boss_died(_boss: Node) -> void:
	# Fade out
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		visible = false
		position.y = _initial_y
	)
	_boss_ref = null
