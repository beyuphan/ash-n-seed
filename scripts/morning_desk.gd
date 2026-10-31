extends Control
## Sabah aşaması: Karar Koltuğu. Karakter ofise girer, konuşur, oyuncu seçer, karakter çıkar.
## Anlık etkiler gösterilir. Gecikmeli sonuçlar, bayraklar ve gizli kirlilik bilerek gösterilmez.

signal decided

const Backdrop := preload("res://scripts/desk_backdrop.gd")
const CHARACTER_REST := Vector2(110, 212)
const CHARS_PER_SECOND := 55.0
const CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")
const POSITIVE := Color(0.18, 0.55, 0.16)
const NEGATIVE := Color(0.8, 0.26, 0.18)
const PILL_GOOD_BG := Color(0.82, 0.94, 0.74)
const PILL_GOOD_EDGE := Color(0.38, 0.65, 0.3)
const PILL_BAD_BG := Color(0.99, 0.83, 0.77)
const PILL_BAD_EDGE := Color(0.82, 0.38, 0.3)
const MAYOR_SCALE := 9
const MAYOR_REST := Vector2(740, 405)

var _card: Dictionary = {}
var _flow_id := 0
var _typing := false
var _type_tween: Tween
var _character: CharacterView
var _flash: ColorRect
var _plate: PanelContainer
var _plate_name: Label
var _plate_role: Label
var _bubble: PanelContainer
var _text: Label
var _choices_box: VBoxContainer
var _choice_buttons: Array[Button] = []
var _choice_previews: Array[HBoxContainer] = []
var _mayor: TextureRect
var _time := 0.0
var _reacting := false
var _skip_reaction := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var back := Backdrop.new()
	add_child(back)

	_character = CharacterView.new()
	add_child(_character)
	_character.set_rest_position(CHARACTER_REST)

	var front := Backdrop.new()
	front.front = true
	add_child(front)

	# Başkan: arkadan siluet. Masanın bu yakasında oturan oyuncu.
	_mayor = TextureRect.new()
	_mayor.texture = UiArt.mayor_silhouette()
	_mayor.size = Vector2(UiArt.MAYOR_W, UiArt.MAYOR_H) * MAYOR_SCALE
	_mayor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mayor.stretch_mode = TextureRect.STRETCH_SCALE
	_mayor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mayor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mayor.position = MAYOR_REST
	add_child(_mayor)

	# Masanın üstündeki isim plakası
	_plate = PanelContainer.new()
	_plate.position = Vector2(150, 656)
	_plate.modulate.a = 0.0
	var plate_style := StyleBoxFlat.new()  # pirinç çerçeveli küçük plaka
	plate_style.bg_color = Color(0.12, 0.1, 0.07, 0.95)
	plate_style.border_color = Color(0.7, 0.58, 0.25)
	plate_style.set_border_width_all(2)
	plate_style.set_corner_radius_all(4)
	plate_style.content_margin_left = 14
	plate_style.content_margin_right = 14
	plate_style.content_margin_top = 6
	plate_style.content_margin_bottom = 6
	_plate.add_theme_stylebox_override("panel", plate_style)
	add_child(_plate)
	var plate_box := HBoxContainer.new()
	plate_box.add_theme_constant_override("separation", 14)
	_plate.add_child(plate_box)
	_plate_name = Label.new()
	_plate_name.add_theme_font_size_override("font_size", 24)
	plate_box.add_child(_plate_name)
	_plate_role = Label.new()
	_plate_role.add_theme_font_size_override("font_size", 16)
	_plate_role.modulate = Color(1, 1, 1, 0.65)
	_plate_role.size_flags_vertical = Control.SIZE_SHRINK_END
	plate_box.add_child(_plate_role)

	# Konuşma balonu: metin ve seçenekler
	var area := Control.new()
	area.position = Vector2(560, 96)
	area.size = Vector2(680, 350)
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(area)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(center)
	_bubble = PanelContainer.new()
	_bubble.theme = PAPER_THEME
	_bubble.custom_minimum_size = Vector2(660, 0)
	_bubble.modulate.a = 0.0
	center.add_child(_bubble)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	_bubble.add_child(root)

	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(620, 0)
	_text.add_theme_font_size_override("font_size", 24)
	root.add_child(_text)

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 10)
	_choices_box.modulate.a = 0.0
	_choices_box.visible = false
	root.add_child(_choices_box)
	for i in 2:
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		_choices_box.add_child(box)
		var button := Button.new()
		button.pressed.connect(_on_choice.bind(i))
		button.add_theme_font_size_override("font_size", 22)
		UiFx.juicy(button)
		box.add_child(button)
		var preview := HBoxContainer.new()
		preview.add_theme_constant_override("separation", 16)
		preview.alignment = BoxContainer.ALIGNMENT_CENTER
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(preview)
		_choice_buttons.append(button)
		_choice_previews.append(preview)

	# Olay kartlarında ekran parlaması
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)


func _process(delta: float) -> void:
	_time += delta
	_mayor.position.y = MAYOR_REST.y + sin(_time * 1.6) * 3.0  # nefes alıyor


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and not _card.is_empty() and _plate_name != null:
		_render_texts()
		if not _typing:
			_text.visible_characters = -1


func _gui_input(event: InputEvent) -> void:
	# Yazı akarken tıklamak yazıyı hemen bitirir. Tepki gösterilirken tıklamak tepkiyi geçer.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _typing:
			_finish_typing()
		elif _reacting:
			_skip_reaction = true


func show_card(card: Dictionary) -> void:
	_card = card
	_flow_id += 1
	var my_flow := _flow_id
	var character: String = card.get("character", "event")

	_typing = false
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	_bubble.modulate.a = 0.0
	_plate.modulate.a = 0.0
	_choices_box.visible = false
	_choices_box.modulate.a = 0.0
	_render_texts()
	_text.visible_characters = 0

	_character.enter(character)
	await _character.landed
	if my_flow != _flow_id:
		return
	if character == "event":
		_flash_screen()

	var fade := create_tween().set_parallel(true)
	fade.tween_property(_plate, "modulate:a", 1.0, 0.25)
	fade.tween_property(_bubble, "modulate:a", 1.0, 0.25)
	await fade.finished
	if my_flow != _flow_id:
		return
	_start_typing()


func _start_typing() -> void:
	var length := tr(_text.text).length()
	_typing = true
	_character.set_talking(true)
	_type_tween = create_tween()
	_type_tween.tween_property(_text, "visible_characters", length, length / CHARS_PER_SECOND)
	_type_tween.finished.connect(_finish_typing)


func _finish_typing() -> void:
	if not _typing:
		return
	_typing = false
	if _type_tween != null and _type_tween.is_valid():
		_type_tween.kill()
	_text.visible_characters = -1
	_character.set_talking(false)
	_choices_box.visible = true
	create_tween().tween_property(_choices_box, "modulate:a", 1.0, 0.25)


func _render_texts() -> void:
	var id: String = _card["id"]
	var character: String = _card.get("character", "event")
	var key_id := id.to_upper()
	_plate_name.text = "CHAR_%s_NAME" % character.to_upper()
	_plate_role.text = "CHAR_%s_ROLE" % character.to_upper()
	_text.text = "CARD_%s_TEXT" % key_id
	var choices: Array = _card["choices"]
	for i in _choice_buttons.size():
		var has_choice := i < choices.size()
		_choice_buttons[i].get_parent().visible = has_choice
		if not has_choice:
			continue
		_choice_buttons[i].text = "CARD_%s_%s" % [key_id, "A" if i == 0 else "B"]
		_fill_chips(_choice_previews[i], CrisisManager.effective_effects(choices[i]))


## Anlık etkileri ikon ve renkli sayı olarak gösterir. Gecikmeli sonuçlar gizli kalır.
func _fill_chips(box: HBoxContainer, effects: Dictionary) -> void:
	for child in box.get_children():
		child.queue_free()
	for stat in ["money", "people", "nature"]:
		var value := float(effects.get(stat, 0.0))
		if value == 0.0:
			continue
		var good := value > 0.0
		var pill := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = PILL_GOOD_BG if good else PILL_BAD_BG
		style.border_color = PILL_GOOD_EDGE if good else PILL_BAD_EDGE
		style.set_border_width_all(2)
		style.set_corner_radius_all(14)
		style.content_margin_left = 14
		style.content_margin_right = 14
		style.content_margin_top = 2
		style.content_margin_bottom = 4
		pill.add_theme_stylebox_override("panel", style)
		var label := Label.new()
		label.text = "%s %+d" % [tr("STAT_%s" % stat.to_upper()), int(value)]
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", POSITIVE if good else NEGATIVE)
		pill.add_child(label)
		box.add_child(pill)


func _flash_screen() -> void:
	_flash.color.a = 0.55
	create_tween().tween_property(_flash, "color:a", 0.0, 0.35)


func _on_choice(index: int) -> void:
	AudioManager.play_sfx(CLICK)
	for button in _choice_buttons:
		button.disabled = true
	CrisisManager.apply_choice(_card, index)
	var my_flow := _flow_id
	await _show_reaction(index, my_flow)
	var fade := create_tween().set_parallel(true)
	fade.tween_property(_bubble, "modulate:a", 0.0, 0.2)
	fade.tween_property(_plate, "modulate:a", 0.0, 0.2)
	await _character.exit()
	for button in _choice_buttons:
		button.disabled = false
	if my_flow == _flow_id:
		decided.emit()


## Karardan sonra karakter kısa bir tepki verir (komik ya da şaşkın). Tıklayınca geçilir.
func _show_reaction(index: int, my_flow: int) -> void:
	if not GameState.running or (_card["choices"] as Array).size() < 2:
		return
	var key := _reaction_key(index)
	if key == "":
		return
	_choices_box.visible = false
	_text.text = key
	_text.visible_characters = 0
	var length := tr(key).length()
	var type_time := length / 70.0
	_character.set_talking(true)
	var type_tween := create_tween()
	type_tween.tween_property(_text, "visible_characters", length, type_time)
	_reacting = true
	_skip_reaction = false
	var wait := clampf(type_time + 1.5, 2.0, 5.0)
	var elapsed := 0.0
	while elapsed < wait and not _skip_reaction and my_flow == _flow_id:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		if elapsed > type_time:
			_character.set_talking(false)
	type_tween.kill()
	_text.visible_characters = -1
	_character.set_talking(false)
	_reacting = false


## Özel tepki (CARD_<ID>_RA/RB) varsa o, yoksa karakter ve kararın doğaya etkisine göre havuzdan.
func _reaction_key(index: int) -> String:
	var suffix := "A" if index == 0 else "B"
	var custom := "CARD_%s_R%s" % [str(_card["id"]).to_upper(), suffix]
	if tr(custom) != custom:
		return custom
	var effects: Dictionary = CrisisManager.last_choice.get("effects", {})
	var nature := float(effects.get("nature", 0.0))
	var mood := "GREEN" if nature > 0.0 else ("DIRTY" if nature < 0.0 else "MEH")
	var who := str(_card.get("character", "event")).to_upper()
	var key := "REACT_%s_%s_%d" % [who, mood, randi() % 2 + 1]
	if tr(key) != key:
		return key
	key = "REACT_EVENT_%s_%d" % [mood, randi() % 2 + 1]
	return key if tr(key) != key else ""
