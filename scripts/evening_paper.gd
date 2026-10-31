class_name EveningPaper
extends Control
## Akşam aşaması: "Karatepe Postası". Günün manşeti, fotoğrafı, bilançosu ve sahada yapılanlar.
## show_report(r) ile gösterilir, oyuncu düğmeye basınca continued sinyali verir.
##
## r: {day, headline, subheadline, deltas{money,people,nature}, nature, planted, lines[], tax, mood, ticker, weather, locked}

signal continued

const FONT_HEAD := "res://assets/fonts/Anton.ttf"
const FONT_BODY := "res://assets/fonts/SpecialElite.ttf"
const FONT_MAST := "res://assets/fonts/IMFellEnglish-Italic.ttf"
const INK := Color(0.14, 0.11, 0.09)
const GREY := Color(0.4, 0.34, 0.28)
const GOOD := Color(0.13, 0.48, 0.15)
const BAD := Color(0.72, 0.17, 0.11)
const SFX_THUMP: AudioStream = preload("res://assets/audio/sfx/drop_002.wav")
const SFX_STAMP: AudioStream = preload("res://assets/audio/sfx/bong_001.wav")
const SFX_CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
const SFX_WHOOSH: AudioStream = preload("res://assets/audio/sfx/paper_whoosh.wav")
const SFX_SLAP: AudioStream = preload("res://assets/audio/sfx/paper_slap.wav")
const STATS := [
	{"id": "money", "label": "STAT_MONEY", "icon": "coin"},
	{"id": "people", "label": "STAT_PEOPLE", "icon": "heart"},
	{"id": "nature", "label": "STAT_NATURE", "icon": "sprout"},
]

var _holder: Control
var _desk: DeskSurface
var _issue: Label
var _date: Label
var _headline: Label
var _sub: Label
var _illustration: PaperIllustration
var _caption: Label
var _bars_box: VBoxContainer
var _lines_box: VBoxContainer
var _ticker: Label
var _button: Button
var _busy := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_desk = DeskSurface.new()
	add_child(_desk)

	_holder = Control.new()
	_holder.size = Vector2(1000, 636)
	_holder.position = Vector2(140, 64)
	_holder.pivot_offset = _holder.size / 2.0
	add_child(_holder)

	var paper := PanelContainer.new()
	paper.size = _holder.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.94, 0.9, 0.78)
	style.border_color = Color(0.3, 0.23, 0.16)
	style.set_border_width_all(5)
	style.set_corner_radius_all(4)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 24
	style.shadow_offset = Vector2(0, 10)
	style.content_margin_left = 34
	style.content_margin_right = 34
	style.content_margin_top = 18
	style.content_margin_bottom = 22
	paper.add_theme_stylebox_override("panel", style)
	_holder.add_child(paper)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 4)
	paper.add_child(page)

	# Künye: sayı, gazete adı, tarih
	var mast := HBoxContainer.new()
	page.add_child(mast)
	_issue = _label("", FONT_BODY, 17, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_issue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(_issue)
	var name_label := _label("PAPER_MASTHEAD", FONT_MAST, 50, INK, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(name_label)
	_date = _label("", FONT_BODY, 17, GREY, HORIZONTAL_ALIGNMENT_RIGHT)
	_date.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(_date)
	page.add_child(_rule(4))

	_headline = _label("", FONT_HEAD, 44, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.custom_minimum_size = Vector2(900, 54)
	page.add_child(_headline)
	_sub = _label("", FONT_MAST, 25, GREY, HORIZONTAL_ALIGNMENT_CENTER)
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_sub)
	page.add_child(_rule(2))

	# Gövde: solda fotoğraf, sağda bilanço ve notlar
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 28)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 6)
	body.add_child(left)
	_illustration = PaperIllustration.new()
	left.add_child(_illustration)
	_caption = _label("", FONT_MAST, 17, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_caption.custom_minimum_size = Vector2(380, 0)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(_caption)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 6)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	right.add_child(_label("PAPER_BALANCE", FONT_HEAD, 22, INK, HORIZONTAL_ALIGNMENT_LEFT))
	_bars_box = VBoxContainer.new()
	_bars_box.add_theme_constant_override("separation", 0)
	right.add_child(_bars_box)
	right.add_child(_rule(2))
	_lines_box = VBoxContainer.new()
	_lines_box.add_theme_constant_override("separation", 1)
	_lines_box.clip_contents = true
	right.add_child(_lines_box)

	# Alt şerit: haber bandı ve devam düğmesi
	page.add_child(_rule(2))
	var foot := HBoxContainer.new()
	page.add_child(foot)
	_ticker = _label("", FONT_MAST, 19, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_ticker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ticker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ticker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(_ticker)
	_button = Button.new()
	_button.text = "PAPER_NEXT"
	_button.add_theme_font_size_override("font_size", 26)
	_button.focus_mode = Control.FOCUS_NONE  # Boşluk tuşu yanlışlıkla gazeteyi geçmesin, sadece tıkla
	_button.pressed.connect(_on_next)
	UiFx.juicy(_button)
	foot.add_child(_button)


func show_report(r: Dictionary) -> void:
	_busy = false
	_issue.text = tr("PAPER_ISSUE") % r["day"]
	_date.text = tr("HUD_DAY") % [r["day"], GameState.MAX_DAYS]
	_headline.text = tr(r["headline"])
	_sub.text = tr(r["subheadline"])
	_illustration.nature = float(r["nature"])
	_illustration.trees = int(r["planted"])
	_caption.text = tr(r["weather"])
	_ticker.text = tr(r["ticker"])

	for child in _bars_box.get_children():
		child.queue_free()
	for stat in STATS:
		_bars_box.add_child(_bar_row(stat, float(r["deltas"].get(stat["id"], 0.0))))
	for child in _lines_box.get_children():
		child.queue_free()
	var income := ""
	if float(r["tax"]) > 0.0:
		income = tr("PAPER_TAX") % int(r["tax"])
	elif r["locked"]:
		income = tr("PAPER_LOCKED")
	if float(r.get("fruit", 0.0)) > 0.0:
		income += ("  " if income != "" else "") + tr("NEWS_FRUIT") % int(r["fruit"])
	if income != "":
		_lines_box.add_child(_note(income))
	var mood: float = r["mood"]
	_lines_box.add_child(_note(tr("PAPER_MOOD") % ("%+d" % int(mood))))
	var extras: Array = r.get("extra", [])
	for line in extras:
		_lines_box.add_child(_note(line))
	var shown := 0
	var max_lines := 2 if extras.size() <= 2 else 1  # kâğıt taşmasın
	for line in r["lines"]:
		if shown >= max_lines:
			break
		shown += 1
		_lines_box.add_child(_note("- " + line))
	_enter()


func _enter() -> void:
	visible = true
	position = Vector2.ZERO
	_button.disabled = true
	_desk.modulate.a = 0.0
	create_tween().tween_property(_desk, "modulate:a", 1.0, 0.2)
	# Gazete sağ üstten, dönerek masaya fırlatılır
	_holder.pivot_offset = _holder.size / 2.0
	_holder.position = Vector2(1500, -420)
	_holder.rotation_degrees = 430.0
	_holder.scale = Vector2(1.55, 1.55)
	_holder.modulate.a = 1.0
	_headline.modulate.a = 0.0
	_sub.modulate.a = 0.0
	await get_tree().create_timer(0.22).timeout
	AudioManager.play_sfx(SFX_WHOOSH, 0.03, -2.0)
	var fly := create_tween().set_parallel(true)
	fly.tween_property(_holder, "position", Vector2(230, 86), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(_holder, "rotation_degrees", -7.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fly.tween_property(_holder, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fly.finished
	# Şap! Masaya çarpar, kayar, toz kalkar, ekran sarsılır
	AudioManager.play_sfx(SFX_SLAP, 0.02, 0.0)
	_shake(12.0, 0.32)
	_dust()
	var skid := create_tween().set_parallel(true)
	skid.tween_property(_holder, "position", Vector2(140, 64), 0.38).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	skid.tween_property(_holder, "rotation_degrees", -1.2, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var squash := create_tween()
	squash.tween_property(_holder, "scale", Vector2(1.035, 0.965), 0.06)
	squash.tween_property(_holder, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await skid.finished
	# Manşet "damgalanır"
	await get_tree().process_frame
	_headline.pivot_offset = _headline.size / 2.0
	_headline.scale = Vector2(1.7, 1.7)
	AudioManager.play_sfx(SFX_STAMP, 0.0, -4.0)
	var stamp := create_tween().set_parallel(true)
	stamp.tween_property(_headline, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	stamp.tween_property(_headline, "modulate:a", 1.0, 0.1)
	await stamp.finished
	create_tween().tween_property(_sub, "modulate:a", 1.0, 0.4)
	await get_tree().create_timer(0.4).timeout
	_button.disabled = false


func _on_next() -> void:
	if _busy:
		return
	_busy = true
	AudioManager.play_sfx(SFX_CLICK)
	AudioManager.play_sfx(SFX_WHOOSH, 0.05, -8.0)
	var out := create_tween().set_parallel(true)
	out.tween_property(_holder, "position", Vector2(-1300, 160), 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	out.tween_property(_holder, "rotation_degrees", -35.0, 0.38)
	out.tween_property(_desk, "modulate:a", 0.0, 0.38)
	await out.finished
	visible = false
	continued.emit()


## Çarpma anında ekran sarsıntısı.
func _shake(strength: float, duration: float) -> void:
	var tween := create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		tween.tween_property(self, "position", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff, 0.03)
	tween.tween_property(self, "position", Vector2.ZERO, 0.03)


## Çarpma anında kağıdın kenarlarından toz bulutçukları.
func _dust() -> void:
	var rect := Rect2(_holder.position + Vector2(40, 20), _holder.size - Vector2(80, 40))
	for i in 12:
		var puff := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.85, 0.78, 0.66, 0.55)
		style.set_corner_radius_all(20)
		puff.add_theme_stylebox_override("panel", style)
		puff.size = Vector2.ONE * randf_range(14.0, 30.0)
		puff.pivot_offset = puff.size / 2.0
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var edge := randi() % 4
		var start := Vector2.ZERO
		match edge:
			0: start = Vector2(rect.position.x + randf() * rect.size.x, rect.position.y)
			1: start = Vector2(rect.position.x + randf() * rect.size.x, rect.end.y)
			2: start = Vector2(rect.position.x, rect.position.y + randf() * rect.size.y)
			_: start = Vector2(rect.end.x, rect.position.y + randf() * rect.size.y)
		puff.position = start
		add_child(puff)
		move_child(puff, _holder.get_index())  # kağıdın arkasında kalsın
		var dir := (start - rect.get_center()).normalized()
		var tween := create_tween().set_parallel(true)
		tween.tween_property(puff, "position", start + dir * randf_range(40.0, 90.0), 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(puff, "scale", Vector2.ONE * 2.2, 0.55)
		tween.tween_property(puff, "modulate:a", 0.0, 0.55)
		tween.chain().tween_callback(puff.queue_free)


func _bar_row(stat: Dictionary, delta: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.texture = UiArt.icon(stat["icon"])
	icon.custom_minimum_size = Vector2(22, 22)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	var name := _label(stat["label"], FONT_BODY, 19, INK, HORIZONTAL_ALIGNMENT_LEFT)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var color := GOOD if delta > 0.0 else (BAD if delta < 0.0 else GREY)
	var text := "%+d" % int(round(delta)) if int(round(delta)) != 0 else "0"
	row.add_child(_label(text, FONT_HEAD, 22, color, HORIZONTAL_ALIGNMENT_RIGHT))
	return row


func _note(text: String) -> Label:
	var l := _label(text, FONT_BODY, 16, INK, HORIZONTAL_ALIGNMENT_LEFT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(430, 0)
	return l


func _label(text: String, font_path: String, font_size: int, color: Color, align: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align as HorizontalAlignment
	l.add_theme_font_override("font", load(font_path))
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


func _rule(thickness: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = INK
	r.custom_minimum_size = Vector2(0, thickness)
	return r
