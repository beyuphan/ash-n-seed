class_name EndPaper
extends Control
## Oyun sonu gazetesi: kazanınca "SON SAYI", kaybedince "ÖZEL SAYI". Masaya fırlatılır, manşet damgalanır.
## show_report(r) ile gösterilir; oyuncu "Tekrar" ya da "Ana Menü" der.
##
## r: {stamp, win, day, headline, sub, nature, trees, rows[{icon,label,value,color}], notes[String], stars (0-3, -1: gösterme),
##     ending_text, quote_who, quote, replay_text}

signal replay_requested
signal menu_requested

const FONT_HEAD := "res://assets/fonts/Anton.ttf"
const FONT_BODY := "res://assets/fonts/SpecialElite.ttf"
const FONT_MAST := "res://assets/fonts/IMFellEnglish-Italic.ttf"
const INK := Color(0.14, 0.11, 0.09)
const GREY := Color(0.4, 0.34, 0.28)
const RED := Color(0.78, 0.14, 0.1)
const GOLD := Color(0.95, 0.72, 0.15)
const SFX_WHOOSH: AudioStream = preload("res://assets/audio/sfx/paper_whoosh.wav")
const SFX_SLAP: AudioStream = preload("res://assets/audio/sfx/paper_slap.wav")
const SFX_STAMP: AudioStream = preload("res://assets/audio/sfx/bong_001.wav")
const SFX_CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")

var _desk: DeskSurface
var _holder: Control
var _stamp: Label
var _headline: Label
var _sub: Label
var _issue: Label
var _date: Label
var _illustration: PaperIllustration
var _caption: Label
var _rows: VBoxContainer
var _notes: VBoxContainer
var _stars: Control
var _star_count := 0
var _ending: Label
var _portrait: TextureRect
var _quote_who: Label
var _quote: Label
var _replay: Button
var _menu: Button
var _busy := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_desk = DeskSurface.new()
	add_child(_desk)

	_holder = Control.new()
	_holder.size = Vector2(1000, 644)
	_holder.position = Vector2(140, 62)
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
	style.content_margin_top = 14
	style.content_margin_bottom = 16
	paper.add_theme_stylebox_override("panel", style)
	_holder.add_child(paper)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 3)
	paper.add_child(page)

	var mast := HBoxContainer.new()
	page.add_child(mast)
	_issue = _label("", FONT_BODY, 16, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_issue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(_issue)
	var name_label := _label("PAPER_MASTHEAD", FONT_MAST, 46, INK, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(name_label)
	_date = _label("", FONT_BODY, 16, GREY, HORIZONTAL_ALIGNMENT_RIGHT)
	_date.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(_date)
	page.add_child(_rule(4))

	_headline = _label("", FONT_HEAD, 42, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.custom_minimum_size = Vector2(900, 52)
	page.add_child(_headline)
	_sub = _label("", FONT_MAST, 23, GREY, HORIZONTAL_ALIGNMENT_CENTER)
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_sub)
	page.add_child(_rule(2))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 26)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 4)
	body.add_child(left)
	_illustration = PaperIllustration.new()
	left.add_child(_illustration)
	_caption = _label("", FONT_MAST, 16, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_caption.custom_minimum_size = Vector2(380, 0)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(_caption)
	_ending = _label("", FONT_BODY, 17, INK, HORIZONTAL_ALIGNMENT_LEFT)
	_ending.custom_minimum_size = Vector2(380, 0)
	_ending.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(_ending)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 3)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	right.add_child(_label("END_PAPER_CARD", FONT_HEAD, 21, INK, HORIZONTAL_ALIGNMENT_LEFT))
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 0)
	right.add_child(_rows)
	_stars = Control.new()
	_stars.custom_minimum_size = Vector2(0, 34)
	_stars.draw.connect(_draw_stars)
	right.add_child(_stars)
	right.add_child(_rule(2))
	_notes = VBoxContainer.new()
	_notes.add_theme_constant_override("separation", 1)
	right.add_child(_notes)

	page.add_child(_rule(2))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 14)
	page.add_child(foot)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(60, 70)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	foot.add_child(_portrait)
	var quote_box := VBoxContainer.new()
	quote_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote_box.alignment = BoxContainer.ALIGNMENT_CENTER
	foot.add_child(quote_box)
	_quote_who = _label("", FONT_HEAD, 17, INK, HORIZONTAL_ALIGNMENT_LEFT)
	quote_box.add_child(_quote_who)
	_quote = _label("", FONT_MAST, 20, GREY, HORIZONTAL_ALIGNMENT_LEFT)
	_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quote.custom_minimum_size = Vector2(380, 0)
	quote_box.add_child(_quote)
	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 6)
	foot.add_child(buttons)
	_replay = Button.new()
	_replay.add_theme_font_size_override("font_size", 22)
	_replay.focus_mode = Control.FOCUS_NONE
	_replay.pressed.connect(func() -> void: _choose(true))
	UiFx.juicy(_replay)
	buttons.add_child(_replay)
	_menu = Button.new()
	_menu.text = "END_BACK_MENU"
	_menu.add_theme_font_size_override("font_size", 18)
	_menu.focus_mode = Control.FOCUS_NONE
	_menu.pressed.connect(func() -> void: _choose(false))
	UiFx.juicy(_menu)
	buttons.add_child(_menu)

	# Damga: eğik kırmızı yazı, manşetin sağ üstünde
	_stamp = Label.new()
	_stamp.add_theme_font_override("font", load(FONT_HEAD))
	_stamp.add_theme_font_size_override("font_size", 30)
	_stamp.add_theme_color_override("font_color", RED)
	_stamp.rotation_degrees = -10.0
	_stamp.position = Vector2(300, 318)
	_stamp.modulate.a = 0.0
	_holder.add_child(_stamp)


func show_report(r: Dictionary) -> void:
	_busy = false
	_issue.text = tr(str(r.get("issue", "END_PAPER_ISSUE")))
	_date.text = tr("HUD_DAY") % [int(r["day"]), GameState.MAX_DAYS]
	_stamp.text = tr(str(r["stamp"]))
	_stamp.position = Vector2(343.0 - _stamp.get_minimum_size().x * 0.5, 318.0)   # uzun (İngilizce) damga sola yayılsın, metne taşmasın
	_headline.text = tr(str(r["headline"]))
	_sub.text = tr(str(r["sub"]))
	_illustration.nature = float(r["nature"])
	_illustration.trees = int(r["trees"])
	_caption.text = tr(str(r.get("caption", "NEWS_WEATHER_CLEAR")))
	_ending.text = tr(str(r.get("ending_text", ""))) if str(r.get("ending_text", "")) != "" else ""
	_portrait.texture = load("res://assets/art/characters/%s_idle.png" % str(r.get("quote_who", "yigithan")))
	_quote_who.text = tr("CHAR_%s_NAME" % str(r.get("quote_who", "yigithan")).to_upper())
	_quote.text = tr(str(r["quote"]))
	_replay.text = str(r.get("replay_text", "END_RETRY"))
	for c in _rows.get_children():
		c.queue_free()
	for row in r["rows"]:
		_rows.add_child(_stat_row(row))
	for c in _notes.get_children():
		c.queue_free()
	for line in r["notes"]:
		_notes.add_child(_note(str(line)))
	_star_count = int(r.get("stars", -1))
	_stars.visible = _star_count >= 0
	_stars.queue_redraw()
	_enter()


func _enter() -> void:
	visible = true
	position = Vector2.ZERO
	_replay.disabled = true
	_menu.disabled = true
	_stamp.modulate.a = 0.0
	_desk.modulate.a = 0.0
	create_tween().tween_property(_desk, "modulate:a", 1.0, 0.25)
	_holder.pivot_offset = _holder.size / 2.0
	_holder.position = Vector2(1500, -420)
	_holder.rotation_degrees = 430.0
	_holder.scale = Vector2(1.55, 1.55)
	_headline.modulate.a = 0.0
	_sub.modulate.a = 0.0
	await get_tree().create_timer(0.3).timeout
	AudioManager.play_sfx(SFX_WHOOSH, 0.03, -2.0)
	var fly := create_tween().set_parallel(true)
	fly.tween_property(_holder, "position", Vector2(230, 78), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(_holder, "rotation_degrees", -7.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fly.tween_property(_holder, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fly.finished
	AudioManager.play_sfx(SFX_SLAP, 0.02, 0.0)
	_shake(14.0, 0.34)
	var skid := create_tween().set_parallel(true)
	skid.tween_property(_holder, "position", Vector2(140, 62), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	skid.tween_property(_holder, "rotation_degrees", -1.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var squash := create_tween()
	squash.tween_property(_holder, "scale", Vector2(1.035, 0.965), 0.06)
	squash.tween_property(_holder, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await skid.finished
	await get_tree().process_frame
	_headline.pivot_offset = _headline.size / 2.0
	_headline.scale = Vector2(1.7, 1.7)
	AudioManager.play_sfx(SFX_STAMP, 0.0, -4.0)
	var press := create_tween().set_parallel(true)
	press.tween_property(_headline, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	press.tween_property(_headline, "modulate:a", 1.0, 0.1)
	await press.finished
	create_tween().tween_property(_sub, "modulate:a", 1.0, 0.4)
	await get_tree().create_timer(0.35).timeout
	# Kırmızı damga şap diye vurur
	_stamp.scale = Vector2(2.6, 2.6)
	_stamp.pivot_offset = _stamp.size / 2.0
	AudioManager.play_sfx(SFX_STAMP, 0.0, -2.0)
	var stamp_tween := create_tween().set_parallel(true)
	stamp_tween.tween_property(_stamp, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	stamp_tween.tween_property(_stamp, "modulate:a", 0.92, 0.1)
	await stamp_tween.finished
	_shake(6.0, 0.2)
	await get_tree().create_timer(0.5).timeout
	_replay.disabled = false
	_menu.disabled = false


func _choose(replay: bool) -> void:
	if _busy:
		return
	_busy = true
	AudioManager.play_sfx(SFX_CLICK)
	AudioManager.play_sfx(SFX_WHOOSH, 0.05, -8.0)
	var out := create_tween().set_parallel(true)
	out.tween_property(_holder, "position", Vector2(-1300, 160), 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	out.tween_property(_holder, "rotation_degrees", -35.0, 0.38)
	await out.finished
	if replay:
		replay_requested.emit()
	else:
		menu_requested.emit()


func _shake(strength: float, duration: float) -> void:
	var tween := create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		tween.tween_property(self, "position", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff, 0.03)
	tween.tween_property(self, "position", Vector2.ZERO, 0.03)


func _stat_row(row: Dictionary) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.texture = UiArt.icon(str(row["icon"]))
	icon.custom_minimum_size = Vector2(22, 22)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	h.add_child(icon)
	var name_label := _label(str(row["label"]), FONT_BODY, 19, INK, HORIZONTAL_ALIGNMENT_LEFT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(name_label)
	h.add_child(_label(str(row["value"]), FONT_HEAD, 22, row.get("color", INK), HORIZONTAL_ALIGNMENT_RIGHT))
	return h


func _note(text: String) -> Label:
	var l := _label(text, FONT_BODY, 16, INK, HORIZONTAL_ALIGNMENT_LEFT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(440, 0)
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


## Yıldız sırası: dolu altın, boş sönük. Beş köşeli yıldızlar kodla çizilir.
func _draw_stars() -> void:
	var cx := 18.0
	for i in 3:
		var filled := i < _star_count
		var pts := PackedVector2Array()
		for k in 10:
			var r := 15.0 if k % 2 == 0 else 6.5
			var a := -PI / 2.0 + k * PI / 5.0
			pts.append(Vector2(cx + cos(a) * r, 17.0 + sin(a) * r))
		_stars.draw_colored_polygon(pts, GOLD if filled else Color(0.75, 0.7, 0.6, 0.55))
		_stars.draw_polyline(pts + PackedVector2Array([pts[0]]), INK if filled else GREY, 1.5)
		cx += 38.0
