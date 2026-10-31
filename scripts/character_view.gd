class_name CharacterView
extends Control
## Ekrandaki karakter: piksel portre, giriş animasyonu (her karakterin kendi tarzı), nefes alma,
## göz kırpma ve konuşurken ağız hareketi. Portre PNG'leri assets/art/characters/ içinden yüklenir.

signal landed

const SCALE := 8
const SIZE := Vector2(CharacterPainter.W, CharacterPainter.H) * SCALE
const BLINK_MIN := 2.2
const BLINK_MAX := 4.5
const TALK_FRAME_TIME := 0.13

## from: giriş başlangıç ofseti. hops: inişten sonra sıçrama. shake: inişte titreme.
const STYLES := {
	"hulusi": {"from": Vector2(560, 0), "time": 0.75, "trans": Tween.TRANS_SINE, "hops": 2, "sfx": "drop_001"},
	"riza": {"from": Vector2(-700, 0), "time": 0.28, "trans": Tween.TRANS_EXPO, "shake": true, "sfx": "click_003"},
	"canan": {"from": Vector2(0, 480), "time": 0.6, "trans": Tween.TRANS_BACK, "sfx": "confirmation_001"},
	"event": {"from": Vector2(0, -560), "time": 0.35, "trans": Tween.TRANS_BOUNCE, "shake": true, "sfx": "error_001"},
	"nezaket": {"from": Vector2(0, 520), "time": 0.75, "trans": Tween.TRANS_ELASTIC, "sfx": "confirmation_002"},
	"mirmir": {"from": Vector2(0, -420), "time": 0.5, "trans": Tween.TRANS_BOUNCE, "hops": 3, "sfx": "drop_001"},
	"defne": {"from": Vector2(700, 0), "time": 0.3, "trans": Tween.TRANS_EXPO, "shake": true, "sfx": "click_001"},
	"bruce": {"from": Vector2(-640, -220), "time": 0.85, "trans": Tween.TRANS_CIRC, "hops": 1, "sfx": "bong_001"},
	"yigithan": {"from": Vector2(-620, 0), "time": 0.6, "trans": Tween.TRANS_BACK, "hops": 1, "sfx": "confirmation_001"},
	"assistant": {"from": Vector2(0, 340), "time": 0.5, "trans": Tween.TRANS_BACK, "hops": 2, "sfx": "confirmation_001"},
}

var character_id := ""
var _sprite: TextureRect
var _frames: Dictionary = {}
var _rest_position := Vector2.ZERO
var _time := 0.0
var _blink_timer := 2.0
var _blink_left := 0.0
var _talking := false
var _talk_timer := 0.0
var _talk_open := false
var _entering := false
var _tween: Tween


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	pivot_offset = Vector2(SIZE.x / 2.0, SIZE.y)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite = TextureRect.new()
	_sprite.size = SIZE
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_SCALE
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sprite)
	visible = false


func _process(delta: float) -> void:
	if not visible or character_id == "":
		return
	_time += delta
	if not _entering:
		_sprite.position.y = sin(_time * 2.2) * 3.0
	# Göz kırpma
	if _blink_left > 0.0:
		_blink_left -= delta
	else:
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			_blink_left = 0.12
			_blink_timer = randf_range(BLINK_MIN, BLINK_MAX)
	# Konuşma: ağız açılıp kapanır
	if _talking:
		_talk_timer -= delta
		if _talk_timer <= 0.0:
			_talk_timer = TALK_FRAME_TIME
			_talk_open = not _talk_open
	else:
		_talk_open = false
	_sprite.texture = _frames["talk"] if _talk_open else (_frames["blink"] if _blink_left > 0.0 else _frames["idle"])


func set_rest_position(pos: Vector2) -> void:
	_rest_position = pos
	position = pos


func set_talking(value: bool) -> void:
	_talking = value


## Karakteri giriş animasyonuyla getirir. Bittiğinde landed sinyali verir.
func enter(id: String) -> void:
	_kill_tween()
	character_id = id
	_load_frames(id)
	_talking = false
	_entering = true
	_sprite.position = Vector2.ZERO
	var style: Dictionary = STYLES.get(id, STYLES["event"])
	visible = true
	scale = Vector2.ONE
	modulate.a = 0.0
	position = _rest_position + style["from"]
	_play_sfx(style.get("sfx", ""))

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	_tween.parallel().tween_property(self, "position", _rest_position, style["time"]) \
		.set_trans(style["trans"]).set_ease(Tween.EASE_OUT)
	# İniş: ezilme ve toparlanma
	_tween.tween_property(self, "scale", Vector2(1.07, 0.93), 0.07)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if style.get("hops", 0) > 0:
		for i in int(style["hops"]):
			_tween.tween_property(self, "position:y", _rest_position.y - 22.0, 0.1).set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "position:y", _rest_position.y, 0.1).set_ease(Tween.EASE_IN)
	if style.get("shake", false):
		for i in 5:
			_tween.tween_property(self, "position:x", _rest_position.x + (8.0 if i % 2 == 0 else -8.0), 0.035)
		_tween.tween_property(self, "position:x", _rest_position.x, 0.035)
	await _tween.finished
	_entering = false
	landed.emit()


## Karakter sola doğru hızla çıkar.
func exit() -> void:
	_kill_tween()
	_talking = false
	_entering = true
	_tween = create_tween()
	_tween.tween_property(self, "position:x", _rest_position.x - 520.0, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.28)
	await _tween.finished
	visible = false
	_entering = false


func _load_frames(id: String) -> void:
	_frames.clear()
	var flags := {"idle": [false, false], "blink": [true, false], "talk": [false, true]}
	for frame_name in flags:
		var path := "res://assets/art/characters/%s_%s.png" % [id, frame_name]
		if ResourceLoader.exists(path):
			_frames[frame_name] = load(path)
		else:  # PNG yoksa kodla çiz
			var f: Array = flags[frame_name]
			_frames[frame_name] = ImageTexture.create_from_image(CharacterPainter.paint(id, f[0], f[1]))
	_sprite.texture = _frames["idle"]


func _play_sfx(sound_name: String) -> void:
	if sound_name == "":
		return
	var path := "res://assets/audio/sfx/%s.wav" % sound_name
	if ResourceLoader.exists(path):
		AudioManager.play_sfx(load(path))


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
