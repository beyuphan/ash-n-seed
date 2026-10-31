class_name PauseMenu
extends CanvasLayer
## Esc ile açılan duraklatma menüsü: devam, ses ayarları, ana menü (iki tıkla onay). Oyunu dondurur.

const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")
const CLICK_SOUND: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const BACK_SOUND: AudioStream = preload("res://assets/audio/sfx/back_001.wav")

var is_open := false
var _resume: Button
var _menu_button: Button
var _armed := false
var _fs_box: CheckButton


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	panel.theme = PAPER_THEME
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(380, 0)
	panel.add_child(box)
	var title := Label.new()
	title.text = tr("PAUSE_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)
	_resume = _button(tr("PAUSE_RESUME"), close)
	box.add_child(_resume)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 12)
	box.add_child(grid)
	grid.add_child(_caption(tr("SETTINGS_MUSIC")))
	grid.add_child(_slider(Settings.music_volume, Settings.set_music_volume))
	grid.add_child(_caption(tr("SETTINGS_SFX")))
	grid.add_child(_slider(Settings.sfx_volume, Settings.set_sfx_volume))
	grid.add_child(_caption(tr("SETTINGS_FULLSCREEN")))
	var fs_box := CheckButton.new()
	fs_box.toggled.connect(func(on: bool) -> void:
		if on != Settings.fullscreen:
			Settings.set_fullscreen(on))
	_fs_box = fs_box
	Settings.volumes_changed.connect(_sync_fullscreen_box)
	fs_box.button_pressed = Settings.fullscreen
	grid.add_child(fs_box)
	_menu_button = _button(tr("PAUSE_MENU"), _on_menu)
	box.add_child(_menu_button)
	var hint := Label.new()
	hint.text = tr("PAUSE_HINT")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate = Color(1, 1, 1, 0.6)
	hint.add_theme_font_size_override("font_size", 16)
	box.add_child(hint)


func _sync_fullscreen_box() -> void:
	if is_instance_valid(_fs_box):
		_fs_box.set_pressed_no_signal(Settings.fullscreen)


func open() -> void:
	if is_open:
		return
	is_open = true
	_armed = false
	_menu_button.text = tr("PAUSE_MENU")
	visible = true
	get_tree().paused = true
	_resume.grab_focus()
	AudioManager.play_sfx(CLICK_SOUND)


func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	Settings.save()
	get_tree().paused = false
	AudioManager.play_sfx(BACK_SOUND)


func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_menu() -> void:
	if not _armed:
		_armed = true
		_menu_button.text = tr("PAUSE_CONFIRM")
		return
	Settings.save()
	get_tree().paused = false
	is_open = false
	SceneManager.change_scene("res://scenes/main_menu.tscn")


func _button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 24)
	b.pressed.connect(callback)
	UiFx.juicy(b)
	return b


func _caption(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	return l


func _slider(value: float, setter: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(200, 24)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value_changed.connect(func(v: float) -> void: setter.call(v))
	return s
