extends Node
## Manages audio playback for SFX and music.

# Audio bus indices
const MASTER_BUS := "Master"
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

# Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

# Music player
var music_player: AudioStreamPlayer
var current_music: AudioStream


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)


func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.volume_db = volume_db
	player.global_position = position
	player.bus = SFX_BUS
	add_child(player)
	player.play()

	player.finished.connect(func(): player.queue_free())


func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if stream == current_music:
		return

	current_music = stream

	if music_player.playing:
		# Fade out current music
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
		await tween.finished

	music_player.stream = stream
	music_player.volume_db = -40.0
	music_player.play()

	# Fade in new music
	var fade_in := create_tween()
	fade_in.tween_property(music_player, "volume_db", 0.0, fade_duration)


func stop_music(fade_duration: float = 1.0) -> void:
	if not music_player.playing:
		return

	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
	await tween.finished
	music_player.stop()
	current_music = null


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(MASTER_BUS)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))
