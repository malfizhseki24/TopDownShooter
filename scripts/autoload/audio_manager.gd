extends Node
## Manages audio playback for SFX and music.
## SFX: pool of 8 AudioStreamPlayer2D for spatial, 2 AudioStreamPlayer for global.
## Music: two AudioStreamPlayer nodes with crossfade for seamless transitions.

# Audio bus names
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

# Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

# --- SFX Pool ---
const SFX_POOL_SIZE: int = 8
const GLOBAL_SFX_POOL_SIZE: int = 2
var _sfx_pool: Array[AudioStreamPlayer2D] = []
var _global_sfx_pool: Array[AudioStreamPlayer] = []

# --- Music Crossfade ---
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _crossfade_tween: Tween
var current_music_track: String = ""

# --- Music State ---
enum MusicState { NONE, EXPLORATION, COMBAT, BOSS, VICTORY, DEATH }
var _music_state: MusicState = MusicState.NONE

const MUSIC_TRACKS := {
	MusicState.EXPLORATION: "res://assets/audio/music/Exploration_bgm.mp3",
	MusicState.COMBAT: "res://assets/audio/music/Combat_bgm.mp3",
	MusicState.BOSS: "res://assets/audio/music/Boss_bgm.mp3",
	MusicState.VICTORY: "res://assets/audio/music/Victory_bgm.mp3",
}

# SFX cache (loaded on demand)
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_sfx_pool()
	_create_music_players()
	_connect_game_signals()


# --- SFX Pool Setup ---

func _create_sfx_pool() -> void:
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer2D.new()
		player.bus = SFX_BUS
		player.max_polyphony = 1
		add_child(player)
		_sfx_pool.append(player)

	for i in range(GLOBAL_SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		player.max_polyphony = 1
		add_child(player)
		_global_sfx_pool.append(player)


func _get_free_sfx_player() -> AudioStreamPlayer2D:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return _sfx_pool[0]


func _get_free_global_player() -> AudioStreamPlayer:
	for player in _global_sfx_pool:
		if not player.playing:
			return player
	return _global_sfx_pool[0]


# --- Public SFX API ---

## Play a spatial SFX at a world position (uses pool)
func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player := _get_free_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.global_position = position
	player.play()


## Play a non-spatial (global) SFX (UI sounds, hitstop thump)
func play_sfx_global(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player := _get_free_global_player()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Load and cache an SFX by path, returns null if file missing
func load_sfx(path: String) -> AudioStream:
	if _sfx_cache.has(path):
		return _sfx_cache[path]
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		_sfx_cache[path] = stream
		return stream
	return null


# --- Music System ---

func _create_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = MUSIC_BUS
	_music_player_a.volume_db = 0.0
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = MUSIC_BUS
	_music_player_b.volume_db = -80.0
	add_child(_music_player_b)

	_active_music_player = _music_player_a


## Crossfade to a new music track (1.0s default)
func play_music(track_path: String, fade_duration: float = 1.0) -> void:
	if track_path == current_music_track:
		return
	if not ResourceLoader.exists(track_path):
		push_warning("AudioManager: Music file not found: %s" % track_path)
		return

	current_music_track = track_path
	var stream: AudioStream = load(track_path)

	# Determine which player to fade in
	var fade_in_player: AudioStreamPlayer
	var fade_out_player: AudioStreamPlayer
	if _active_music_player == _music_player_a:
		fade_in_player = _music_player_b
		fade_out_player = _music_player_a
	else:
		fade_in_player = _music_player_a
		fade_out_player = _music_player_b

	# Setup new track
	fade_in_player.stream = stream
	fade_in_player.volume_db = -80.0
	fade_in_player.play()

	# Kill any existing crossfade
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()

	# Crossfade
	_crossfade_tween = create_tween().set_parallel(true)
	_crossfade_tween.tween_property(fade_in_player, "volume_db", 0.0, fade_duration)
	_crossfade_tween.tween_property(fade_out_player, "volume_db", -80.0, fade_duration)
	_crossfade_tween.set_parallel(false)
	_crossfade_tween.tween_callback(func():
		fade_out_player.stop()
	)

	_active_music_player = fade_in_player


func stop_music(fade_duration: float = 1.0) -> void:
	if not _active_music_player.playing:
		return

	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()

	var player := _active_music_player
	_crossfade_tween = create_tween()
	_crossfade_tween.tween_property(player, "volume_db", -80.0, fade_duration)
	_crossfade_tween.tween_callback(func():
		player.stop()
	)
	current_music_track = ""
	_music_state = MusicState.NONE


# --- Game State Music Transitions ---

func _connect_game_signals() -> void:
	EventBus.room_loaded.connect(_on_room_loaded)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.victory.connect(_on_victory)
	EventBus.game_over.connect(_on_game_over)
	EventBus.player_died.connect(_on_player_died)


func _set_music_state(new_state: MusicState) -> void:
	if new_state == _music_state:
		return
	_music_state = new_state
	if MUSIC_TRACKS.has(new_state):
		play_music(MUSIC_TRACKS[new_state])
	elif new_state == MusicState.DEATH:
		stop_music(1.5)
	elif new_state == MusicState.NONE:
		stop_music()


func _on_room_loaded(_room_index: int) -> void:
	if _music_state != MusicState.BOSS:
		_set_music_state(MusicState.EXPLORATION)


func _on_enemy_spawned(_enemy: Node) -> void:
	if _music_state == MusicState.EXPLORATION:
		_set_music_state(MusicState.COMBAT)


func _on_boss_spawned(_boss: Node) -> void:
	_set_music_state(MusicState.BOSS)


func _on_room_cleared(_room_index: int) -> void:
	if _music_state == MusicState.COMBAT:
		_set_music_state(MusicState.EXPLORATION)


func _on_victory() -> void:
	_set_music_state(MusicState.VICTORY)


func _on_game_over() -> void:
	_set_music_state(MusicState.DEATH)


func _on_player_died() -> void:
	_set_music_state(MusicState.DEATH)


# --- Volume Controls ---

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))
