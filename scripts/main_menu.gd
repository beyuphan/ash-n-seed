extends Control
## Açılış ekranı: zıplayan logo, hareketli dumanlı kasaba, tatlı butonlar.
## Arka plan kodla çizilir (asset gerektirmez). Ayarlar ve Krediler krem kağıt panelde açılır.

const CLICK_SOUND: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const BACK_SOUND: AudioStream = preload("res://assets/audio/sfx/back_001.wav")
const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")
const LOGO_BBCODE := "[center][color=#d9d5c6]ASH[/color] [font_size=70][color=#a8a392]n[/color][/font_size] [color=#7fd35a]SEED[/color][/center]"
const ASH_COUNT := 70

var _main_page: Control
var _settings_page: Control
var _credits_page: Control
var _logo: RichTextLabel
var _time := 0.0
var _ash: Array[Dictionary] = []


var _fs_box: CheckButton


func _sync_fullscreen_box() -> void:
	if is_instance_valid(_fs_box):
		_fs_box.set_pressed_no_signal(Settings.fullscreen)


func _ready() -> void:
	Settings.volumes_changed.connect(_sync_fullscreen_box)
	AudioManager.play_music(load("res://assets/audio/music/menu_theme.ogg"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in ASH_COUNT:
		_ash.append({
			"pos": Vector2(rng.randf(), rng.randf()),
			"speed": rng.randf_range(0.04, 0.12),
			"drift": rng.randf_range(0.01, 0.05),
			"size": rng.randf_range(1.5, 3.5),
		})

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 36)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	_logo = RichTextLabel.new()
	_logo.bbcode_enabled = true
	_logo.text = LOGO_BBCODE
	_logo.fit_content = true
	_logo.scroll_active = false
	_logo.custom_minimum_size = Vector2(900, 0)
	_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_logo.add_theme_font_size_override("normal_font_size", 108)
	_logo.add_theme_color_override("font_outline_color", Color(0.12, 0.09, 0.08))
	_logo.add_theme_constant_override("outline_size", 14)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_logo)

	var ribbon := PanelContainer.new()
	ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var ribbon_style := StyleBoxFlat.new()
	ribbon_style.bg_color = Color(0.16, 0.13, 0.12, 0.88)
	ribbon_style.border_color = Color(0.96, 0.77, 0.26)
	ribbon_style.set_border_width_all(3)
	ribbon_style.set_corner_radius_all(22)
	ribbon_style.content_margin_left = 26
	ribbon_style.content_margin_right = 26
	ribbon_style.content_margin_top = 6
	ribbon_style.content_margin_bottom = 8
	ribbon.add_theme_stylebox_override("panel", ribbon_style)
	column.add_child(ribbon)
	var subtitle := Label.new()
	subtitle.text = "GAME_SUBTITLE"
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.98, 0.85, 0.45))
	ribbon.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	column.add_child(spacer)

	var pages := CenterContainer.new()
	pages.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(pages)
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(470, 360)
	pages.add_child(stack)
	_main_page = _build_main_page()
	_settings_page = _build_settings_page()
	_credits_page = _build_credits_page()
	for page in [_main_page, _settings_page, _credits_page]:
		stack.add_child(page)
		page.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_show_page(_main_page)

	_logo.resized.connect(func() -> void: _logo.pivot_offset = _logo.size / 2.0)
	_intro_animation()


func _process(delta: float) -> void:
	_time += delta
	_logo.rotation_degrees = sin(_time * 1.3) * 1.4
	var pulse := 1.0 + sin(_time * 2.0) * 0.012
	_logo.scale = Vector2(pulse, pulse)
	for p in _ash:
		var pos: Vector2 = p["pos"]
		pos.y += p["speed"] * delta
		pos.x -= p["drift"] * delta
		if pos.y > 1.05 or pos.x < -0.05:
			pos = Vector2(randf_range(0.4, 1.05), -0.05)
		p["pos"] = pos
	queue_redraw()


func _intro_animation() -> void:
	await get_tree().process_frame
	_logo.pivot_offset = _logo.size / 2.0
	_logo.modulate.a = 0.0
	var pos_y := _logo.position.y
	_logo.position.y = pos_y - 160.0
	var drop := create_tween().set_parallel(true)
	drop.tween_property(_logo, "position:y", pos_y, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	drop.tween_property(_logo, "modulate:a", 1.0, 0.2)
	var delay := 0.35
	for button in _main_page.get_children():
		UiFx.pop_in(button as Control, delay)
		delay += 0.09


# ------------------------------------------------------------------ Arka plan

func _draw() -> void:
	var w := size.x
	var h := size.y
	var bands := 14
	for i in bands:
		var t := float(i) / (bands - 1)
		var c := Color(0.45, 0.42, 0.38).lerp(Color(0.86, 0.72, 0.5), pow(t, 1.4))
		draw_rect(Rect2(0, h * i / bands, w, h / bands + 1), c)
	# Bulanık güneş
	draw_circle(Vector2(w * 0.78, h * 0.62), 120.0, Color(1.0, 0.85, 0.5, 0.16))
	draw_circle(Vector2(w * 0.78, h * 0.62), 70.0, Color(1.0, 0.9, 0.6, 0.2))

	# Fabrika siluetleri ve dumanlı bacalar
	var ground := h * 0.84
	var skyline := Color(0.22, 0.18, 0.2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var x := -20.0
	var chimney_index := 0
	while x < w:
		var bw := rng.randf_range(90.0, 170.0)
		var bh := rng.randf_range(70.0, 170.0)
		draw_rect(Rect2(x, ground - bh, bw, bh + h), skyline)
		if rng.randf() < 0.55:
			var cx := x + bw * rng.randf_range(0.2, 0.7)
			var ch := rng.randf_range(70.0, 130.0)
			draw_rect(Rect2(cx, ground - bh - ch, 20, ch), skyline)
			_draw_smoke(Vector2(cx + 10, ground - bh - ch), chimney_index)
			chimney_index += 1
		x += bw + rng.randf_range(2.0, 14.0)

	# Kül yağmuru
	for p in _ash:
		draw_circle((p["pos"] as Vector2) * size, p["size"], Color(0.12, 0.1, 0.1, 0.8))

	# Çorak zemin ve filiz
	draw_rect(Rect2(0, ground, w, h - ground), Color(0.3, 0.22, 0.17))
	draw_rect(Rect2(0, ground, w, 10), Color(0.38, 0.28, 0.2))
	_draw_seedling(Vector2(w * 0.12, ground + 4))


func _draw_smoke(base: Vector2, index: int) -> void:
	for i in 5:
		var rise := fmod(_time * 16.0 + i * 46.0 + index * 31.0, 230.0)
		var alpha := 0.34 * (1.0 - rise / 230.0)
		var sway := sin(_time * 0.6 + i + index) * 16.0
		draw_circle(base + Vector2(sway + rise * 0.25, -rise), 14.0 + rise * 0.13, Color(0.42, 0.38, 0.34, alpha))


func _draw_seedling(base: Vector2) -> void:
	var grow := clampf(_time / 1.6, 0.0, 1.0)
	var sway := sin(_time * 1.8) * 5.0 * grow
	var tip := base + Vector2(sway, -70.0 * grow)
	var green := Color(0.5, 0.82, 0.32)
	var green_d := Color(0.28, 0.58, 0.24)
	draw_polyline(PackedVector2Array([base, base + Vector2(sway * 0.4, -35.0 * grow), tip]), green_d, 6.0)
	_draw_leaf(tip, -2.6 + sway * 0.01, 30.0 * grow, green)
	_draw_leaf(tip + Vector2(0, 8 * grow), -0.5 + sway * 0.01, 26.0 * grow, green)
	# Parıltılar
	for i in 3:
		var phase := fmod(_time * 0.8 + i * 0.7, 2.0)
		if phase < 0.6 and grow >= 1.0:
			var s := sin(phase / 0.6 * PI) * 7.0
			var c := tip + Vector2(-34 + i * 30, -24 - i * 10)
			var spark := Color(1.0, 0.95, 0.6, 0.9)
			draw_line(c - Vector2(s, 0), c + Vector2(s, 0), spark, 3.0)
			draw_line(c - Vector2(0, s), c + Vector2(0, s), spark, 3.0)


func _draw_leaf(origin: Vector2, angle: float, length: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 14:
		var a := TAU * float(i) / 14.0
		var local := Vector2(cos(a) * length * 0.5 + length * 0.5, sin(a) * length * 0.26)
		pts.append(origin + local.rotated(angle))
	draw_colored_polygon(pts, color)


# ------------------------------------------------------------------ Sayfalar

func _build_main_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	var start := _button("MENU_START", _on_start)
	start.add_theme_font_size_override("font_size", 32)
	page.add_child(start)
	page.add_child(_button("MENU_SETTINGS", func() -> void: _show_page(_settings_page)))
	page.add_child(_button("MENU_CREDITS", func() -> void: _show_page(_credits_page)))
	if not OS.has_feature("web"):  # tarayıcıda çıkış anlamsız
		page.add_child(_button("MENU_QUIT", func() -> void: get_tree().quit()))
	return page


func _build_settings_page() -> Control:
	var panel := PanelContainer.new()
	panel.theme = PAPER_THEME
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(_heading("SETTINGS_TITLE"))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	grid.add_child(_caption("SETTINGS_LANGUAGE"))
	var lang_picker := OptionButton.new()
	lang_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lang_picker.add_theme_font_size_override("font_size", 20)
	var index := 0
	for code in Settings.LANGUAGES:
		lang_picker.add_item(Settings.LANGUAGES[code])
		lang_picker.set_item_metadata(index, code)
		if code == Settings.language:
			lang_picker.select(index)
		index += 1
	lang_picker.item_selected.connect(func(i: int) -> void:
		AudioManager.play_sfx(CLICK_SOUND)
		Settings.set_language(lang_picker.get_item_metadata(i)))
	grid.add_child(lang_picker)

	grid.add_child(_caption("SETTINGS_MUSIC"))
	grid.add_child(_volume_slider(Settings.music_volume, Settings.set_music_volume))
	grid.add_child(_caption("SETTINGS_SFX"))
	grid.add_child(_volume_slider(Settings.sfx_volume, Settings.set_sfx_volume))
	grid.add_child(_caption("SETTINGS_FULLSCREEN"))
	var fs_box := CheckButton.new()
	fs_box.button_pressed = Settings.fullscreen
	fs_box.toggled.connect(func(on: bool) -> void:
		if on != Settings.fullscreen:
			Settings.set_fullscreen(on))
	fs_box.custom_minimum_size = Vector2(0, 34)
	_fs_box = fs_box   # sayfa yeniden kurulursa eski kutu serbest kalır; eşitleme her zaman son kutuya bakar
	grid.add_child(fs_box)

	var back := _button("MENU_BACK", func() -> void:
		Settings.save()
		_show_page(_main_page), BACK_SOUND)
	box.add_child(back)
	return panel


func _build_credits_page() -> Control:
	var panel := PanelContainer.new()
	panel.theme = PAPER_THEME
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(_heading("CREDITS_TITLE"))
	var body := Label.new()
	body.text = "CREDITS_BODY"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(640, 0)
	body.add_theme_font_size_override("font_size", 18)
	box.add_child(body)
	box.add_child(_button("MENU_BACK", func() -> void: _show_page(_main_page), BACK_SOUND))
	return panel


func _heading(key: String) -> Label:
	var label := Label.new()
	label.text = key
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	return label


func _button(key: String, callback: Callable, sound: AudioStream = CLICK_SOUND) -> Button:
	var button := Button.new()
	button.text = key
	button.pressed.connect(func() -> void: AudioManager.play_sfx(sound))
	button.pressed.connect(callback)
	UiFx.juicy(button)
	return button


func _caption(key: String) -> Label:
	var label := Label.new()
	label.text = key
	label.add_theme_font_size_override("font_size", 20)
	return label


func _volume_slider(initial: float, setter: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = initial
	slider.custom_minimum_size = Vector2(240, 30)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(setter)
	return slider


func _show_page(target: Control) -> void:
	for page in [_main_page, _settings_page, _credits_page]:
		page.visible = (page == target)
	if target != _main_page:
		UiFx.pop_in(target)
	else:
		for button in _main_page.get_children():
			(button as Control).modulate.a = 1.0
			(button as Control).scale = Vector2.ONE


func _on_start() -> void:
	SceneManager.change_scene("res://scenes/intro.tscn")
