class_name DialogPanel
extends Control
## Sahada karakterle konuşma kutusu: portre, isim, söz ve 1-2 seçenek. Alt tarafta açılır.
## open() ile açılır. Seçim yapılınca chosen(index) sinyali gelir ve kutu kapanır.
## Klavye: 1, 2, 3 ya da Boşluk (ilk seçenek).

signal chosen(index: int)

const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")
const SFX_CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const SFX_OPEN: AudioStream = preload("res://assets/audio/sfx/click_003.wav")

var is_open := false

var _panel: PanelContainer
var _portrait: TextureRect
var _name: Label
var _text: Label
var _buttons: Array[Button] = []
var _type_tween: Tween
var _ready_for_input := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_panel = PanelContainer.new()
	_panel.theme = PAPER_THEME
	_panel.size = Vector2(960, 200)
	_panel.position = Vector2(160, 480)
	add_child(_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	_panel.add_child(row)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(150, 180)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_portrait)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	row.add_child(column)
	_name = Label.new()
	_name.add_theme_font_override("font", load("res://assets/fonts/Anton.ttf"))
	_name.add_theme_font_size_override("font_size", 28)
	_name.add_theme_color_override("font_color", Color(0.55, 0.32, 0.1))
	column.add_child(_name)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(700, 60)
	_text.add_theme_font_size_override("font_size", 22)
	column.add_child(_text)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	column.add_child(buttons)
	for i in 3:
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 21)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_choose.bind(i))
		UiFx.juicy(button)
		buttons.add_child(button)
		_buttons.append(button)


## portrait: sahne portresi dokusu, speaker: isim anahtarı, text: söz, options: seçenek yazıları (1 ya da 2)
func open(portrait: Texture2D, speaker: String, text: String, options: Array) -> void:
	_portrait.texture = portrait
	_name.text = speaker
	_text.text = text
	_text.visible_characters = 0
	var font := _text.get_theme_font("font")
	var fsize := _text.get_theme_font_size("font_size")
	_text.custom_minimum_size.y = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, 700.0, fsize).y + 8.0
	for i in _buttons.size():
		_buttons[i].visible = i < options.size()
		if i < options.size():
			_buttons[i].text = options[i]
	visible = true
	is_open = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_ready_for_input = false
	AudioManager.play_sfx(SFX_OPEN, 0.05, -4.0)
	UiFx.pop_in(_panel)
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	_type_tween = create_tween()
	var length := text.length()
	_type_tween.tween_property(_text, "visible_characters", length, maxf(0.2, length / 90.0))
	for i in 2:
		await get_tree().process_frame
		_panel.reset_size()
		_panel.position = Vector2((1280.0 - _panel.size.x) / 2.0, 704.0 - _panel.size.y)
	await get_tree().create_timer(0.25).timeout
	_ready_for_input = true


func close() -> void:
	is_open = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not _ready_for_input:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1, KEY_SPACE, KEY_ENTER:
				_choose(0)
				get_viewport().set_input_as_handled()
			KEY_2:
				if _buttons[1].visible:
					_choose(1)
					get_viewport().set_input_as_handled()
			KEY_3:
				if _buttons[2].visible:
					_choose(2)
					get_viewport().set_input_as_handled()


func _choose(index: int) -> void:
	if not is_open or not _ready_for_input:
		return
	AudioManager.play_sfx(SFX_CLICK)
	close()
	chosen.emit(index)
