extends Control
## Ash n Seed giriş sekansı: 5 ekran, kasvetli atmosfer.
##  1 Zifiri karanlık, 2 Kül bulutu, 3 30 günlük lanet (dosya masaya çarpar), 4 Başkanın yükü, 5 Logo.
##
## Metin biçimi (strings.csv içinde, her dilde aynı etiketler):
##   {a}vurgu{/a}  Anton, iri, kırmızı     {A}...{/A}  aynı ama titrer
##   {t}rapor{/t}  Courier Prime, sarı     {i}fısıltı{/i}  eski baskı italik, soluk
##   etiketsiz metin: Special Elite (daktilo)
## Yeni sayfa: CSV'ye INTRO_5 yaz, SCREENS listesine ekle.

const Backdrop := preload("res://scripts/intro_backdrop.gd")
const FONT_BODY := "res://assets/fonts/SpecialElite.ttf"
const FONT_HARD := "res://assets/fonts/Anton.ttf"
const FONT_WHISPER := "res://assets/fonts/IMFellEnglish-Italic.ttf"
const FONT_REPORT := "res://assets/fonts/CourierPrime-Bold.ttf"

const SFX_THUMP: AudioStream = preload("res://assets/audio/sfx/drop_002.wav")
const SFX_LOGO_HIT: AudioStream = preload("res://assets/audio/sfx/bong_001.wav")
const SFX_CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const SFX_DING: AudioStream = preload("res://assets/audio/sfx/type_ding.wav")
const SFX_SPACE: AudioStream = preload("res://assets/audio/sfx/type_space.wav")
const SFX_KEYS: Array[AudioStream] = [
	preload("res://assets/audio/sfx/type_1.wav"),
	preload("res://assets/audio/sfx/type_2.wav"),
	preload("res://assets/audio/sfx/type_3.wav"),
	preload("res://assets/audio/sfx/type_4.wav"),
]

const CHARS_PER_SECOND := 30.0
const BONE := Color(0.84, 0.8, 0.7)

const TAGS := {}
const LOGO_BBCODE := "[center][font=%s][color=#d6d0be]ASH n SEED[/color][/font][/center]" % FONT_HARD

## text_key boşsa metin yok (logo ekranı).
const SCREENS: Array[Dictionary] = [
	{"text_key": "INTRO_1", "mode": Backdrop.Mode.BLACK, "centered": true},
	# FLY: oyunun gerçek haritası kirli hâliyle tepeden gezilir (from/to: kamera, zoom: [başla, bitir], dusk: gün batımı)
	{"text_key": "INTRO_2", "mode": Backdrop.Mode.FLY, "centered": false, "from": Vector2(300, 450), "to": Vector2(640, 330), "zoom": [2.3, 1.8], "time": 16.0, "dusk": 0.5},
	{"text_key": "INTRO_3", "mode": Backdrop.Mode.FLY, "centered": false, "from": Vector2(760, 250), "to": Vector2(1040, 170), "zoom": [2.4, 1.9], "time": 16.0, "dusk": 0.35},
	{"text_key": "INTRO_4", "mode": Backdrop.Mode.DESK, "centered": false, "mayor": true, "folder": false},
	{"text_key": "INTRO_5", "mode": Backdrop.Mode.DESK, "centered": false, "mayor": true, "slam": true},
	{"text_key": "INTRO_6", "mode": Backdrop.Mode.DESK, "centered": false, "mayor": true, "robot": true},
	# centered: metin ekranın ortasında. Aksi halde üstte durur, sahne altta kalır.
	{"text_key": "", "mode": Backdrop.Mode.LOGO, "centered": true},
]

var _index := -1
var _typing := false
var _locked := true
var _done := false
var _reveal := 0.0
var _total := 0
var _backdrop: Control
var _shade: TextureRect
var _text_box: VBoxContainer
var _text: RichTextLabel
var _top_spacer: Control
var _logo: RichTextLabel
var _button: Button
var _hint: Label
var _dim: ColorRect
var _world: SubViewportContainer
var _world_root: Node2D
var _map: FieldMap
var _cam: Camera2D
var _smog: ColorRect
var _smog_material := ShaderMaterial.new()
var _cover: ColorRect
var _cam_tween: Tween
var _ambient: Array[AudioStreamPlayer] = []


func _ready() -> void:
	AudioManager.play_music(load("res://assets/audio/music/intro_theme.ogg"), 2.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # tıklama _unhandled_input'a ulaşsın (kök Control tıklamayı yutuyordu)
	# Oyunun gerçek haritası arka planda (kirli hâli); üstüne puslu filtre. Sıralama: dünya, pus, sahne çizimleri, metin.
	_world = SubViewportContainer.new()  # harita kendi görüntü alanında: kamera arayüzü kaydırmasın
	_world.stretch = true
	_world.set_anchors_preset(Control.PRESET_FULL_RECT)
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.visible = false
	var sub := SubViewport.new()
	sub.size = Vector2i(1280, 720)
	_world.add_child(sub)
	_world_root = Node2D.new()
	sub.add_child(_world_root)
	add_child(_world)
	_smog = ColorRect.new()
	var smog_shader := Shader.new()
	smog_shader.code = Atmosphere.SHADER_CODE
	_smog_material.shader = smog_shader
	_smog_material.set_shader_parameter("pollution", 0.88)
	_smog_material.set_shader_parameter("dusk", 0.45)
	_smog.material = _smog_material
	_smog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_smog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_smog.visible = false
	add_child(_smog)
	_backdrop = Backdrop.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE  # tıklama _unhandled_input'a ulaşsın
	add_child(_backdrop)

	_shade = TextureRect.new()  # alt tarafı karartan degrade, metin okunsun diye
	_shade.texture = _vertical_gradient()
	_shade.stretch_mode = TextureRect.STRETCH_SCALE
	_shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shade.flip_v = true
	_shade.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_shade.offset_bottom = 380
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)

	_text_box = VBoxContainer.new()
	_text_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text_box)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(820, 0)
	_text.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.add_theme_font_override("normal_font", load(FONT_BODY))
	_text.add_theme_font_size_override("normal_font_size", 32)
	_text.add_theme_color_override("default_color", BONE)
	_text.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_text.add_theme_constant_override("outline_size", 7)
	_text.add_theme_constant_override("line_separation", 10)
	_top_spacer = Control.new()
	_top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text_box.add_child(_top_spacer)
	_text_box.add_child(_text)

	var logo_box := VBoxContainer.new()
	logo_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo_box.alignment = BoxContainer.ALIGNMENT_CENTER
	logo_box.add_theme_constant_override("separation", 44)
	logo_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo_box)
	_logo = RichTextLabel.new()
	_logo.bbcode_enabled = true
	_logo.text = LOGO_BBCODE
	_logo.fit_content = true
	_logo.scroll_active = false
	_logo.custom_minimum_size = Vector2(1000, 0)
	_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_logo.add_theme_font_size_override("normal_font_size", 110)
	_logo.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_logo.add_theme_constant_override("outline_size", 14)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_logo.visible = false
	logo_box.add_child(_logo)
	_button = Button.new()
	_button.text = "INTRO_5_BUTTON"
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.add_theme_font_override("font", load(FONT_HARD))
	_button.add_theme_font_size_override("font_size", 30)
	_button.visible = false
	UiFx.juicy(_button)
	_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(SFX_CLICK)
		_finish())
	logo_box.add_child(_button)

	_hint = _small_label("INTRO_HINT")
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint.position.y -= 30
	add_child(_hint)
	var skip := _small_label("INTRO_SKIP")
	skip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	skip.position += Vector2(-26, 18)
	add_child(skip)

	# Atmosfer katmanları: vinyet, film greni, bozuk lamba titremesi
	var vignette := TextureRect.new()
	vignette.texture = _vignette_texture()
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)
	var grain := ColorRect.new()
	grain.material = _grain_material()
	grain.set_anchors_preset(Control.PRESET_FULL_RECT)
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grain)
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	_cover = ColorRect.new()
	_cover.color = Color.BLACK
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.modulate.a = 0.0
	add_child(_cover)
	move_child(_cover, _backdrop.get_index() + 1)
	_start_ambient()
	_show_screen(0)
	_build_world.call_deferred()


func _process(delta: float) -> void:
	_update_map_view()
	# Lamba ara sıra sönüp yanar
	if randf() < 0.004:
		_dim.color.a = randf_range(0.15, 0.35)
	else:
		_dim.color.a = move_toward(_dim.color.a, 0.0, delta * 2.4)
	if not _typing:
		return
	var before := int(_reveal)
	_reveal += delta * CHARS_PER_SECOND
	var after := mini(int(_reveal), _total)
	for idx in range(before, after):
		_play_key(idx)
	_text.visible_characters = after
	if after >= _total:
		_complete_typing(true)


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if event.is_action_pressed("ui_cancel"):
		_finish()
	elif event.is_action_pressed("ui_accept") \
			or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_advance()


func _show_screen(i: int) -> void:
	_index = i
	_locked = true
	var screen := SCREENS[i]
	_text.text = ""
	_text.visible_characters = 0
	_text_box.alignment = BoxContainer.ALIGNMENT_CENTER if screen["centered"] else BoxContainer.ALIGNMENT_BEGIN
	_top_spacer.custom_minimum_size.y = 0.0 if screen["centered"] else 64.0
	_shade.visible = not screen["centered"]
	_hint.visible = screen["text_key"] != ""
	_backdrop.slam = screen.get("slam", false)
	_backdrop.toxic = screen.get("toxic", false)
	_backdrop.show_mayor = screen.get("mayor", false)
	_backdrop.show_robot = screen.get("robot", false)
	_backdrop.show_folder = screen.get("folder", true)
	_backdrop.mode = screen["mode"]
	var fly: bool = screen["mode"] == Backdrop.Mode.FLY
	_world.visible = fly
	_smog.visible = fly
	if fly:
		_start_fly(screen)
	_backdrop.modulate.a = 0.0
	var fade := create_tween()
	fade.tween_property(_backdrop, "modulate:a", 1.0, 1.0)
	if screen.get("slam", false):
		# Dosya masaya çarpma anında ses ve sarsıntı
		get_tree().create_timer(Backdrop.SLAM_AT).timeout.connect(func() -> void:
			if _done or _index != i:
				return
			AudioManager.play_sfx(SFX_THUMP)
			_shake(16.0, 0.45))
	await fade.finished
	if _done or _index != i:
		return
	if i == 0:
		_play_optional("gears", 0.3)
		_play_optional("cough", 3.2)
	if screen["text_key"] == "":
		_play_logo()
	else:
		_type(screen["text_key"])


func _type(key: String) -> void:
	_text.text = "[center]%s[/center]" % _to_bbcode(tr(key))
	_text.visible_characters = 0
	_total = _text.get_total_character_count()
	_reveal = 0.0
	_typing = true
	_locked = false


func _advance() -> void:
	if _locked:
		return
	if _typing:
		_complete_typing(false)
		return
	if _index + 1 < SCREENS.size():
		_show_screen(_index + 1)


func _complete_typing(with_ding: bool) -> void:
	_typing = false
	_text.visible_characters = -1
	if with_ding:
		AudioManager.play_sfx(SFX_DING, 0.0, -12.0)


## Basılan harfe göre daktilo sesi. Boşluk farklı, görünmeyen karakterler sessiz.
func _play_key(char_index: int) -> void:
	var parsed := _text.get_parsed_text()
	if char_index >= parsed.length():
		return
	var c := parsed.substr(char_index, 1)
	if c == "\n":
		return
	if c == " ":
		AudioManager.play_sfx(SFX_SPACE, 0.05, -10.0)
	else:
		AudioManager.play_sfx(SFX_KEYS.pick_random(), 0.07, -8.0)


func _play_logo() -> void:
	_logo.visible = true
	_logo.modulate.a = 0.0
	await get_tree().process_frame
	_logo.pivot_offset = _logo.size / 2.0
	_logo.scale = Vector2(2.8, 2.8)
	AudioManager.play_sfx(SFX_LOGO_HIT)
	var slam := create_tween().set_parallel(true)
	slam.tween_property(_logo, "modulate:a", 1.0, 0.1)
	slam.tween_property(_logo, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await slam.finished
	if _done:
		return
	_shake(20.0, 0.4)
	await get_tree().create_timer(1.0).timeout
	if _done:
		return
	_button.visible = true
	_button.modulate.a = 0.0
	create_tween().tween_property(_button, "modulate:a", 1.0, 0.6)
	_button.grab_focus()


func _shake(strength: float, duration: float) -> void:
	var tween := create_tween()
	var steps := int(duration / 0.035)
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		tween.tween_property(self, "position",
			Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff, 0.035)
	tween.tween_property(self, "position", Vector2.ZERO, 0.04)


func _finish() -> void:
	if _done:
		return
	_done = true
	for player in _ambient:
		player.stop()
	GameState.new_game()
	SceneManager.change_scene("res://scenes/game.tscn")


## {a}...{/a} gibi sade etiketleri RichTextLabel BBCode'una çevirir.
func _to_bbcode(raw: String) -> String:
	var out := raw
	for key in TAGS:
		out = out.replace("{%s}" % key, TAGS[key][0]).replace("{/%s}" % key, TAGS[key][1])
	return out


# ------------------------------------------------------------------ Gerçek harita

## Oyunun haritası kirli hâliyle arka planda kurulur. Ağır iş: ilk ekran sürerken ertelenmiş olarak yapılır.
func _build_world() -> void:
	await get_tree().create_timer(0.4).timeout
	_map = FieldMap.new()
	_world_root.add_child(_map)
	_map.reveal_all()
	_map.water_quality = 0.0
	_map.sync_green_to(FieldWorld.GREEN_MIN)
	_map.player_pos = Vector2(-500.0, -500.0)
	for n in _map.npcs:
		n["active"] = false
	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = false
	_cam.limit_left = -400
	_cam.limit_top = -400
	_cam.limit_right = int(_map.world_size().x) + 400
	_cam.limit_bottom = int(_map.world_size().y) + 400
	_world_root.add_child(_cam)
	_cam.make_current()


## Kamera haritanın üstünde yavaşça süzülür; gün batımı rengi ekran boyunca açılır.
func _start_fly(screen: Dictionary) -> void:
	while _map == null and not _done:
		await get_tree().process_frame
	if _done or _index < 0 or SCREENS[_index] != screen:
		return
	var zoom: Array = screen["zoom"]
	_cam.position = screen["from"]
	_cam.zoom = Vector2(zoom[0], zoom[0])
	_cover.modulate.a = 1.0
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = create_tween().set_parallel(true)
	_cam_tween.tween_property(_cam, "position", screen["to"], screen["time"]).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_cam_tween.tween_property(_cam, "zoom", Vector2(zoom[1], zoom[1]), screen["time"]).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_cam_tween.tween_property(_cover, "modulate:a", 0.0, 1.6)
	_cam_tween.tween_method(func(v: float) -> void: _smog_material.set_shader_parameter("dusk", v), 0.75, float(screen["dusk"]), 4.0)


func _update_map_view() -> void:
	if _map == null or _cam == null or not _world.visible:
		return
	var half := get_viewport_rect().size / (2.0 * _cam.zoom.x)
	var top_left := _cam.get_screen_center_position() - half
	var tiles := Vector2i(ceili(half.x * 2.0 / FieldMap.TILE) + 5, ceili(half.y * 2.0 / FieldMap.TILE) + 6)
	_map.view_tiles = Rect2i(floori(top_left.x / FieldMap.TILE) - 2, floori(top_left.y / FieldMap.TILE) - 2, tiles.x, tiles.y)


# ------------------------------------------------------------------ Görsel yardımcılar

func _small_label(key: String) -> Label:
	var label := Label.new()
	label.text = key
	label.add_theme_font_override("font", load(FONT_WHISPER))
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = Color(1, 1, 1, 0.5)
	return label


func _vertical_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, 0.82))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 8
	tex.height = 256
	return tex


func _vignette_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.3, 1.0])
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.92)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.15, 0.5)
	tex.width = 512
	tex.height = 288
	return tex


func _grain_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float strength = 0.075;
// Dave Hoskins hash: sin() kullanmadığı için çapraz desen oluşturmaz.
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}
void fragment() {
	float t = floor(TIME * 14.0);
	float n = hash(floor(FRAGCOORD.xy / 2.0) + vec2(t * 37.0, t * 17.0));
	COLOR = vec4(vec3(n), strength);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


# ------------------------------------------------------------------ Opsiyonel ses

func _start_ambient() -> void:
	var stream := _load_optional("wind")
	if stream == null:
		return
	if "loop" in stream:
		stream.loop = true
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = AudioManager.BUS_SFX
	player.volume_db = -4.0
	add_child(player)
	player.play()
	_ambient.append(player)


func _play_optional(sound_name: String, delay: float) -> void:
	var stream := _load_optional(sound_name)
	if stream == null:
		return
	await get_tree().create_timer(delay).timeout
	if not _done:
		AudioManager.play_sfx(stream)


func _load_optional(sound_name: String) -> AudioStream:
	for ext in ["ogg", "wav", "mp3"]:
		var path := "res://assets/audio/intro/%s.%s" % [sound_name, ext]
		if ResourceLoader.exists(path):
			return load(path)
	return null
