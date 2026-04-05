extends HBoxContainer
## Skill bar HUD — 3 skill slots with icons, radial cooldown sweep, and ready feedback.
## Connects exclusively to EventBus signals; holds no direct game node references.

var _slots: Array[Control] = []
var _cooldown_bars: Array[TextureProgressBar] = []
var _icons: Array[TextureRect] = []
var _slot_bgs: Array[ColorRect] = []
var _ready_glows: Array[ColorRect] = []

var _cooldown_tweens: Array[Tween] = [null, null, null]
var _glow_tweens: Array[Tween] = [null, null, null]

# Cooldown durations for computing progress during _process
var _cooldown_duration: Array[float] = [0.0, 0.0, 0.0]
var _cooldown_elapsed: Array[float] = [0.0, 0.0, 0.0]
var _on_cooldown: Array[bool] = [false, false, false]

const COLOR_SLOT_BG       := Color(0.06, 0.06, 0.14, 0.85)
const COLOR_SLOT_BORDER   := Color(0.25, 0.25, 0.45, 1.0)
const COLOR_COOLDOWN_FILL := Color(0.0, 0.0, 0.0, 0.88)
const COLOR_READY_GLOW    := Color(1.0, 0.87, 0.3, 0.0)
const COLOR_WARD_GLOW     := Color(0.44, 0.9, 0.9, 0.0)
const COLOR_KEY           := Color(0.9, 0.9, 0.9, 0.6)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_slots       = [$Slot1, $Slot2, $Slot3]
	_slot_bgs    = [$Slot1/SlotBG, $Slot2/SlotBG, $Slot3/SlotBG]
	_icons       = [$Slot1/Icon, $Slot2/Icon, $Slot3/Icon]
	_cooldown_bars = [$Slot1/CooldownSweep, $Slot2/CooldownSweep, $Slot3/CooldownSweep]
	_ready_glows = [$Slot1/ReadyGlow, $Slot2/ReadyGlow, $Slot3/ReadyGlow]

	for i in 3:
		_cooldown_bars[i].value = 0.0
		_ready_glows[i].modulate.a = 0.0

	EventBus.skill_cooldown_started.connect(_on_skill_cooldown_started)
	EventBus.skill_cooldown_ready.connect(_on_skill_cooldown_ready)
	EventBus.skill_activated.connect(_on_skill_activated)


func _process(delta: float) -> void:
	# Drive the radial sweep from elapsed time (smoother than a single tween)
	for i in 3:
		if not _on_cooldown[i]:
			continue
		_cooldown_elapsed[i] += delta
		var t := clampf(_cooldown_elapsed[i] / _cooldown_duration[i], 0.0, 1.0)
		# value goes 100 → 0 as cooldown drains
		_cooldown_bars[i].value = (1.0 - t) * 100.0
		# Dim the icon while on cooldown
		_icons[i].modulate.a = lerpf(0.35, 1.0, t)


func _on_skill_cooldown_started(skill_index: int, duration: float) -> void:
	if skill_index < 0 or skill_index >= 3:
		return

	_cooldown_duration[skill_index] = duration
	_cooldown_elapsed[skill_index] = 0.0
	_on_cooldown[skill_index] = true
	_cooldown_bars[skill_index].value = 100.0
	_cooldown_bars[skill_index].visible = true
	_icons[skill_index].modulate.a = 0.35

	# Stop ward glow if ward was consumed
	if skill_index == 2:
		_stop_glow(2)


func _on_skill_cooldown_ready(skill_index: int) -> void:
	if skill_index < 0 or skill_index >= 3:
		return

	_on_cooldown[skill_index] = false
	_cooldown_bars[skill_index].value = 0.0
	_cooldown_bars[skill_index].visible = false
	_icons[skill_index].modulate.a = 1.0

	_play_ready_flash(skill_index)


func _on_skill_activated(skill_index: int) -> void:
	# Ward active — pulse cyan glow on slot 3
	if skill_index != 2:
		return
	_play_ward_glow()


# --- Internal helpers ---

func _play_ready_flash(i: int) -> void:
	_stop_glow(i)
	var glow := _ready_glows[i]
	var tween := create_tween()
	_glow_tweens[i] = tween
	# Bright flash in, then fade out
	tween.tween_property(glow, "modulate:a", 0.9, 0.06)
	tween.tween_property(glow, "modulate:a", 0.0, 0.25)


func _play_ward_glow() -> void:
	_stop_glow(2)
	var glow := _ready_glows[2]
	glow.color = COLOR_WARD_GLOW
	var tween := create_tween().set_loops()
	_glow_tweens[2] = tween
	tween.tween_property(glow, "modulate:a", 0.85, 0.4)
	tween.tween_property(glow, "modulate:a", 0.2, 0.4)


func _stop_glow(i: int) -> void:
	if _glow_tweens[i]:
		_glow_tweens[i].kill()
		_glow_tweens[i] = null
	_ready_glows[i].modulate.a = 0.0
	_ready_glows[i].color = COLOR_READY_GLOW
