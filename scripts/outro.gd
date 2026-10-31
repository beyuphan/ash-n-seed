class_name Outro
extends Control
## Kazanma sinematiği: oyuncunun kendi yeşillenmiş Karatepe'si tepeden gösterilir. Kamera dostları tek tek gezer,
## herkes ne yaptığını söyler, Son Ağaç dikilir. Esc ile atlanır. Bitince `finished` sinyali verir (arkasından son sayı gazetesi gelir).

signal finished

const FONT_BODY := "res://assets/fonts/SpecialElite.ttf"
const FONT_HEAD := "res://assets/fonts/Anton.ttf"
const OUTLINE := Color(0.05, 0.04, 0.03)
const MUSIC := "res://assets/audio/music/outro_theme.ogg"
const CPS := 38.0

var _field: FieldWorld
var _atmosphere: Atmosphere
var _cam: CameraShake
var _birds: OutroBirds
var _flags: Dictionary
var _key := ""
var _tier := 1
var _skip := false
var _done := false

var _fade: ColorRect
var _bar_top: ColorRect
var _bar_bottom: ColorRect
var _narration: Label
var _card: PanelContainer
var _card_portrait: TextureRect
var _card_name: Label
var _card_text: Label
var _hint: Label


## flags: hikâye bayrakları, key: END_WIN_*, tier: 1-3 (yıldız).
func play(field: FieldWorld, atmosphere: Atmosphere, flags: Dictionary, key: String, tier: int) -> void:
	_field = field
	_atmosphere = atmosphere
	_flags = flags
	_key = key
	_tier = clampi(tier, 1, 3)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_setup_world()
	set_process(true)
	AudioManager.play_music(load(MUSIC), 2.0)
	await _run()


func _process(_delta: float) -> void:
	if _field != null and not _done:
		_field.cinematic_update_view()


func _unhandled_input(event: InputEvent) -> void:
	if _done or _skip:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE):
		_skip = true
		get_viewport().set_input_as_handled()


# ------------------------------------------------------------------ Kurulum

func _setup_world() -> void:
	var greens := [0.6, 0.74, 0.88]
	_cam = _field.begin_cinematic(greens[_tier - 1], [0.7, 0.85, 0.95][_tier - 1])
	_atmosphere.override_pollution = [0.4, 0.22, 0.08][_tier - 1]
	GameState.day_progress = 0.8  # altın saat
	GameState.nature = maxf(GameState.nature, 84.0)  # ekran rengi canlı olsun (özet, çağrıdan önce yakalandı)
	GameState.stats_changed.emit()
	_birds = OutroBirds.new()
	_field.add_child(_birds)
	# Karakterleri durağına yerleştir
	var map: FieldMap = _field._map
	for n in map.npcs:
		if n["temp"]:
			continue
		n["marker"] = false
		n["active"] = true
		var spot: String = _spot_for(str(n["id"]))
		if spot != "":
			map.move_npc(n, map.free_near(map.spot_tile(spot)))
	map.spawn_villagers(22, map.tile_at(map.door_world_position()), 34)


func _spot_for(id: String) -> String:
	match id:
		"pinar": return "pinar_agaci"
		"veli": return "iskele_ucu"
		"canan": return "fidanlik_on"
		"riza": return "cay_ocagi_on"
		"kemal": return "fabrika_kapisi_on"
		"hulusi": return "genel_mudurluk_on"
		"yigithan": return "belediye_on" if _flags.get("last_tree_done", false) else "orman_kulubesi_on"
	return ""


func _spot_world(spot: String) -> Vector2:
	var t: Vector2i = _field._map.spot_tile(spot)
	return Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.5) * FieldMap.TILE)


func _build_ui() -> void:
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_bar_top = _bar(true)
	_bar_bottom = _bar(false)
	_narration = Label.new()
	_narration.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_narration.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_narration.offset_top = -190
	_narration.offset_bottom = -110
	_narration.offset_left = -560
	_narration.offset_right = 560
	_narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration.add_theme_font_override("font", load(FONT_BODY))
	_narration.add_theme_font_size_override("font_size", 34)
	_narration.add_theme_color_override("font_color", Color(0.98, 0.95, 0.85))
	_narration.add_theme_color_override("font_outline_color", OUTLINE)
	_narration.add_theme_constant_override("outline_size", 9)
	_narration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_narration)

	_card = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.07, 0.05, 0.88)
	style.border_color = Color(0.82, 0.68, 0.3)
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 22
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	_card.add_theme_stylebox_override("panel", style)
	_card.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_card.offset_top = -224
	_card.offset_bottom = -84
	_card.offset_left = -520
	_card.offset_right = 520
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.modulate.a = 0.0
	add_child(_card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	_card.add_child(row)
	_card_portrait = TextureRect.new()
	_card_portrait.custom_minimum_size = Vector2(110, 126)
	_card_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_card_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_card_portrait)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(box)
	_card_name = Label.new()
	_card_name.add_theme_font_override("font", load(FONT_HEAD))
	_card_name.add_theme_font_size_override("font_size", 28)
	_card_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	box.add_child(_card_name)
	_card_text = Label.new()
	_card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_text.custom_minimum_size = Vector2(760, 0)
	_card_text.add_theme_font_override("font", load(FONT_BODY))
	_card_text.add_theme_font_size_override("font_size", 23)
	_card_text.add_theme_color_override("font_color", Color(0.97, 0.94, 0.84))
	box.add_child(_card_text)

	_hint = Label.new()
	_hint.text = "OUTRO_HINT"
	_hint.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint.position += Vector2(-24, 80)
	_hint.add_theme_font_size_override("font_size", 17)
	_hint.modulate = Color(1, 1, 1, 0.55)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint)


func _bar(top: bool) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color.BLACK
	r.set_anchors_preset(Control.PRESET_TOP_WIDE if top else Control.PRESET_BOTTOM_WIDE)
	r.offset_top = -70.0 if not top else 0.0
	r.offset_bottom = 0.0 if not top else 70.0
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


# ------------------------------------------------------------------ Senaryo

func _run() -> void:
	var map: FieldMap = _field._map
	var market := map.door_world_position()
	var world_center := Vector2(768, 512)
	_cam.position = market + Vector2(0, -30)
	_cam.zoom = Vector2(3.4, 3.4)
	await _wait(0.3)
	await _fade_to(0.0, 1.8)
	# 1) Pazar meydanından yükseliş
	await _narrate("OUTRO_N1")
	await _cam_to(market + Vector2(0, -60), 2.2, 4.0)
	await _narrate("OUTRO_N2")
	await _cam_to(Vector2(560, 380), 1.1, 5.0)
	await _narrate("OUTRO_N3")
	await _cam_to(world_center, 0.86, 5.0)
	await _narrate("OUTRO_TIER_%d" % _tier, 3.0)
	await _clear_narration()
	# 2) Dostlar tek tek
	var plan: Array[Dictionary] = _plan()
	for step in plan:
		if _skip:
			break
		await _cam_to(step["pos"], 3.2, 2.4)
		await _show_card(step["portrait"], step["name"], step["text"])
		await _hide_card()
	# 3) Son bakış
	if not _skip:
		await _cam_to(world_center, 0.86, 4.5)
		await _narrate("OUTRO_END", 2.4)
	_done = true
	await _fade_to(1.0, 1.0 if not _skip else 0.35)
	finished.emit()


## Kimin neyi söyleyeceği. Hikâye bayraklarına göre metinler değişir.
func _plan() -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	steps.append(_step("pinar", "pinar_agaci", "OUTRO_PINAR_1" if _flags.get("pinar_tree", false) else "OUTRO_PINAR_2"))
	steps.append(_step("veli", "iskele_ucu", "OUTRO_VELI_1"))
	steps.append(_step("canan", "fidanlik_on", "OUTRO_CANAN_1"))
	steps.append(_step("riza", "cay_ocagi_on", "OUTRO_RIZA_1"))
	steps.append(_step("kemal", "fabrika_kapisi_on", "OUTRO_KEMAL_1" if _flags.get("workers_ally", false) else "OUTRO_KEMAL_2"))
	var hulusi_key := "OUTRO_HULUSI_DEFAULT"
	match _key:
		"END_WIN_SOLD": hulusi_key = "OUTRO_HULUSI_SOLD"
		"END_WIN_REDEEMED": hulusi_key = "OUTRO_HULUSI_REDEEMED"
		"END_WIN_JUSTICE": hulusi_key = "OUTRO_HULUSI_JUSTICE"
	steps.append(_step("hulusi", "genel_mudurluk_on", hulusi_key))
	var tomurcuk := _step("assistant", "pazar_on", "OUTRO_TOMURCUK_1")
	tomurcuk["pos"] = _field._map.door_world_position() + Vector2(0, 8)
	steps.append(tomurcuk)
	# Yiğithan: Son Ağaç dikildiyse belediye önünde, yoksa kulübesinde
	var last_tree: bool = _flags.get("last_tree_done", false)
	var yig := _step("yigithan", "belediye_on" if last_tree else "orman_kulubesi_on", "OUTRO_YIGITHAN_1" if last_tree else "OUTRO_YIGITHAN_2")
	if last_tree:
		_plant_last_tree(yig["pos"])
	steps.append(yig)
	return steps


func _step(who: String, spot: String, text_key: String) -> Dictionary:
	var name_key := "CHAR_ASSIST_NAME" if who == "assistant" else "CHAR_%s_NAME" % who.to_upper()
	return {"portrait": who, "name": name_key, "text": text_key, "pos": _spot_world(spot) + Vector2(0, -8)}


func _plant_last_tree(near: Vector2) -> void:
	var map: FieldMap = _field._map
	var t: Vector2i = map.free_near(map.tile_at(near) + Vector2i(2, 0))
	map.add_tree(t, 17)
	map.special_trees.append({"t": t})


# ------------------------------------------------------------------ Yardımcılar

func _wait(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds and not _skip:
		await get_tree().process_frame
		elapsed += get_process_delta_time()


func _fade_to(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, duration)
	await _wait(duration)
	if _skip:
		tween.kill()
		_fade.color.a = alpha


func _cam_to(pos: Vector2, zoom: float, duration: float) -> void:
	if _skip:
		return
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_cam, "position", pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_cam, "zoom", Vector2(zoom, zoom), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _wait(duration)
	if _skip:
		tween.kill()


## Ekranın altında daktilo yazısı. Okunacak kadar bekler.
func _narrate(key: String, hold: float = 2.2) -> void:
	if _skip:
		return
	var text := tr(key)
	_narration.text = text
	_narration.visible_characters = 0
	_narration.modulate.a = 1.0
	await _type(_narration, text.length())
	await _wait(hold)
	var tween := create_tween()
	tween.tween_property(_narration, "modulate:a", 0.0, 0.5)
	await _wait(0.5)


func _clear_narration() -> void:
	_narration.text = ""


func _type(label: Label, length: int) -> void:
	var shown := 0.0
	while shown < length and not _skip:
		await get_tree().process_frame
		shown += get_process_delta_time() * CPS
		label.visible_characters = int(shown)
	label.visible_characters = -1


func _show_card(portrait: String, name_key: String, text_key: String) -> void:
	if _skip:
		return
	var path := "res://assets/art/characters/%s_idle.png" % portrait
	_card_portrait.texture = load(path) if ResourceLoader.exists(path) else null
	_card_name.text = tr(name_key)
	var text := tr(text_key)
	_card_text.text = text
	_card_text.visible_characters = 0
	create_tween().tween_property(_card, "modulate:a", 1.0, 0.3)
	AudioManager.play_sfx(load("res://assets/audio/sfx/confirmation_002.wav"), 0.05, -8.0)
	await _type(_card_text, text.length())
	await _wait(1.8 + text.length() * 0.022)


func _hide_card() -> void:
	create_tween().tween_property(_card, "modulate:a", 0.0, 0.3)
	await _wait(0.3)
