extends Node
## Müzik ve SFX için tek giriş noktası. Music/SFX busları çalışma anında oluşturulur.

const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"
const SFX_VOICES := 8

const MUSIC_DB := -7.0  # arka plan müziği hep geride kalsın

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_current: AudioStreamPlayer
var _music_stream: AudioStream
var _fade: Tween
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx := 0


func _ready() -> void:
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_MUSIC
		player.volume_db = -60.0
		add_child(player)
		if i == 0:
			_music_a = player
		else:
			_music_b = player
	_music_current = _music_a
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_sfx_players.append(player)
	Settings.volumes_changed.connect(_apply_volumes)
	_apply_volumes()


## Kısa efekt çalar. pitch_jitter > 0 ise her seferinde hafif farklı perde (ekim sesi için ideal).
func play_sfx(stream: AudioStream, pitch_jitter: float = 0.0, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_VOICES
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = maxf(1.0 + randf_range(-pitch_jitter, pitch_jitter), 0.2)
	player.play()


## Müziği yumuşak geçişle değiştirir. Aynı parça zaten çalıyorsa dokunmaz. Ogg parçalar döngüye alınır.
func play_music(stream: AudioStream, fade_time: float = 1.2) -> void:
	if stream == null or _music_stream == stream:
		return
	if "loop" in stream:
		stream.loop = true
	_music_stream = stream
	var previous := _music_current
	_music_current = _music_b if _music_current == _music_a else _music_a
	_music_current.stream = stream
	_music_current.volume_db = -60.0
	_music_current.play()
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = create_tween().set_parallel(true)
	_fade.tween_property(_music_current, "volume_db", MUSIC_DB, fade_time)
	_fade.tween_property(previous, "volume_db", -60.0, fade_time)
	_fade.chain().tween_callback(previous.stop)


func stop_music(fade_time: float = 0.4) -> void:
	_music_stream = null
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = create_tween().set_parallel(true)
	for player in [_music_a, _music_b]:
		_fade.tween_property(player, "volume_db", -60.0, fade_time)
	_fade.chain().tween_callback(func() -> void:
		_music_a.stop()
		_music_b.stop())


func _apply_volumes() -> void:
	_set_bus_linear(BUS_MUSIC, Settings.music_volume)
	_set_bus_linear(BUS_SFX, Settings.sfx_volume)


func _set_bus_linear(bus: StringName, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(idx, value <= 0.001)


func _ensure_bus(bus: StringName) -> void:
	if AudioServer.get_bus_index(bus) != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus)
	AudioServer.set_bus_send(idx, &"Master")
