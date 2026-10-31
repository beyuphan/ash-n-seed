extends Node
## Oyun akışı: Sabah (karar kartı) -> Saha (kuşbakışı) -> Akşam (gazete). Günler böyle döner.
## Çevre rengi (Atmosphere, EnvironmentTint) ve HUD GameState'e bağlı çalışır.

const MorningDesk := preload("res://scripts/morning_desk.gd")
const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")

var _field: FieldWorld
var _desk: Control
var _paper: EveningPaper
var _atmosphere: Atmosphere
var _end_layer: CanvasLayer
var _end_paper: EndPaper
var _pause: PauseMenu
var _ended := false
var _day_start := {"money": 50.0, "people": 50.0, "nature": 30.0}
var _splash: ColorRect
var _splash_kicker: Label
var _splash_title: Label
var _splash_body: Label
var _splash_done_day := -1


func _ready() -> void:
	_field = FieldWorld.new()
	$World.add_child(_field)
	_field.day_finished.connect(GameState.next_phase)
	_atmosphere = Atmosphere.new()
	add_child(_atmosphere)
	_build_phase_ui()
	_build_splash()
	_pause = PauseMenu.new()
	add_child(_pause)
	GameState.phase_changed.connect(func(_p: int) -> void: _refresh())
	GameState.game_over.connect(_show_loss)
	GameState.game_won.connect(_start_outro)
	_refresh()
	_start_music()


## Aşamaya göre müzik: sabah masa, öğleden sonra saha (bölüme göre değişir), akşam gazete cıngılı.
func _start_music() -> void:
	var path := "res://assets/audio/music/calm_loop.ogg"
	match GameState.phase:
		GameState.Phase.MORNING:
			path = "res://assets/audio/music/desk_theme.ogg"
		GameState.Phase.FIELD:
			var chapter := FieldProgression.number(GameState.day)
			if chapter >= 4:
				path = "res://assets/audio/music/field_tense.ogg"
			elif chapter >= 2:
				path = "res://assets/audio/music/field_jaunty.ogg"
		_:
			path = "res://assets/audio/music/paper_theme.ogg"
	var track: AudioStream = load(path)
	if track != null:
		AudioManager.play_music(track)


func _exit_tree() -> void:
	if get_tree() != null:
		get_tree().paused = false
	AudioManager.stop_music()


## Esc: duraklatma menüsü (oyun bitince ya da başka bir şey Esc'yi yutunca açılmaz).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _ended and _pause != null and not _pause.is_open:
		get_viewport().set_input_as_handled()
		_pause.open()


func _build_phase_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 3  # atmosfer filtresi (4) bu katmanı da boyar, saha arayüzü (6) ve HUD (10) boyanmaz
	add_child(layer)

	_desk = MorningDesk.new()
	_desk.decided.connect(GameState.next_phase)
	layer.add_child(_desk)

	# Gazete atmosfer filtresinin üstünde: gün batımı onu karartmasın, okunaklı kalsın
	var paper_layer := CanvasLayer.new()
	paper_layer.layer = 8
	add_child(paper_layer)
	_paper = EveningPaper.new()
	_paper.continued.connect(GameState.next_phase)
	paper_layer.add_child(_paper)


## Oyun bittiği andaki göstergeler (outro sonrası renk için GameState.nature oynanabilir, o yüzden önce yakalanır).
func _capture_stats() -> Dictionary:
	return {"money": GameState.money, "people": GameState.people, "nature": GameState.nature}


func _hide_game_layers() -> void:
	_ended = true
	_field.set_active(false)
	_desk.visible = false
	_paper.visible = false
	$Hud.visible = false


func _ensure_end_layer() -> void:
	if _end_layer != null:
		return
	_end_layer = CanvasLayer.new()
	_end_layer.layer = 22
	add_child(_end_layer)


## Kaybetme: karanlığa gömül, sonra "Karatepe Postası ÖZEL SAYI" masaya fırlatılır.
func _show_loss(ending_key: String) -> void:
	var stats := _capture_stats()
	_hide_game_layers()
	_ensure_end_layer()
	AudioManager.play_music(load("res://assets/audio/music/gameover_theme.ogg"), 1.5)
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_layer.add_child(black)
	create_tween().tween_property(black, "color:a", 1.0, 0.9)
	await get_tree().create_timer(1.0).timeout
	_open_end_paper(EndReports.loss(ending_key, stats))


## Kazanma: önce sinematik (kendi Karatepe'n tepeden), sonra "SON SAYI".
func _start_outro() -> void:
	var stats := _capture_stats()
	var key := _field.story.ending_key()
	var goal := float(FieldProgression.chapter(GameState.MAX_DAYS)["goal"])
	var tier := clampi(FieldProgression.stars(stats["nature"], goal), 1, 3)
	_hide_game_layers()
	_ensure_end_layer()
	var outro := Outro.new()
	_end_layer.add_child(outro)
	outro.finished.connect(func() -> void:
		_field.visible = false
		_atmosphere.visible = false
		outro.queue_free()
		_open_end_paper(EndReports.win(key, stats, tier)))
	outro.play(_field, _atmosphere, _field.story.flags, key, tier)


func _open_end_paper(report: Dictionary) -> void:
	_end_paper = EndPaper.new()
	_end_layer.add_child(_end_paper)
	_end_paper.replay_requested.connect(func() -> void:
		GameState.new_game()
		SceneManager.change_scene("res://scenes/game.tscn"))
	_end_paper.menu_requested.connect(func() -> void: SceneManager.change_scene("res://scenes/main_menu.tscn"))
	_end_paper.show_report(report)


func _refresh() -> void:
	if not GameState.running:
		return
	_start_music()
	match GameState.phase:
		GameState.Phase.MORNING:
			_start_morning()
		GameState.Phase.FIELD:
			_desk.visible = false
			_paper.visible = false
			GameState.day_progress = 1.0
			_field.begin_day()
		_:
			_field.set_active(false)
			_desk.visible = false
			GameState.day_progress = 0.0
			_show_paper()


func _build_splash() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	_splash = ColorRect.new()
	_splash.color = Color(0.03, 0.025, 0.02, 0.94)
	_splash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_splash.visible = false
	layer.add_child(_splash)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_splash.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	_splash_kicker = Label.new()
	_splash_kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_splash_kicker.add_theme_font_size_override("font_size", 22)
	_splash_kicker.add_theme_color_override("font_color", Color(0.75, 0.7, 0.55))
	box.add_child(_splash_kicker)
	_splash_title = Label.new()
	_splash_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_splash_title.add_theme_font_size_override("font_size", 64)
	_splash_title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
	box.add_child(_splash_title)
	_splash_body = Label.new()
	_splash_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_splash_body.custom_minimum_size = Vector2(760, 0)
	_splash_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_splash_body.add_theme_font_size_override("font_size", 24)
	box.add_child(_splash_body)
	var go := Button.new()
	go.text = "CH_BEGIN"
	go.add_theme_font_size_override("font_size", 28)
	go.pressed.connect(_close_splash)
	UiFx.juicy(go)
	box.add_child(go)


func _show_splash() -> void:
	var day := GameState.day
	var ch := FieldProgression.chapter(day)
	_splash_kicker.text = tr("CH_KICKER") % [FieldProgression.number(day), FieldProgression.CHAPTERS.size()]
	_splash_title.text = tr(ch["name"])
	var text := tr(ch["intro"]) + "\n\n" + tr("CH_GOAL") % int(ch["goal"])
	if FieldProgression.number(day) >= 2:
		text += "\n" + tr("CH_FAIL") % int(float(ch["goal"]) - 8.0)
	for feature in FieldProgression.unlocked_today(day):
		text += "\n" + tr("UNLOCK_%s" % feature.to_upper())
	_splash_body.text = text
	_splash.visible = true
	_desk.visible = false
	UiFx.pop_in(_splash_body)


func _close_splash() -> void:
	_splash.visible = false
	_splash_done_day = GameState.day
	_start_morning()


func _start_morning() -> void:
	_field.set_active(false)
	_paper.visible = false
	GameState.day_progress = 1.0
	if FieldProgression.is_first_day(GameState.day) and _splash_done_day != GameState.day:
		_show_splash()
		return
	_day_start = {"money": GameState.money, "people": GameState.people, "nature": GameState.nature}
	if GameState.day <= FieldProgression.CARD_FREE_DAYS:  # öğretici: karar kartı yok, doğrudan sahaya
		CrisisManager.last_choice = {}
		GameState.next_phase()
		return
	_desk.visible = true
	CrisisManager.last_choice = {}
	var card := CrisisManager.draw_card()
	if card.is_empty():
		GameState.next_phase()  # kart yoksa günü atla
		return
	_desk.show_card(card)


## Gün sonu: vergi ve halk memnuniyeti uygulanır, "Karatepe Postası" günün özetini gösterir.
func _show_paper() -> void:
	var green := 1.0 - _field.dirty_ratio()
	var villagers := _field.villager_count()
	var locked := CrisisManager.has_flag("kasa_kilitli")
	var tax := 0.0 if locked else DayReport.tax_income(green)
	var fruit := 0.0 if locked else _field.fruit_income()
	var mood := DayReport.mood_change(green, villagers, GameState.day)
	if tax + fruit > 0.0:
		GameState.change_stat(&"money", tax + fruit)
	GameState.change_stat(&"people", mood)
	if not GameState.running:
		return  # gün sonu etkileri oyunu bitirdi, bitiş paneli açılır
	# Yarın sabah işleyecek baskı (bölüm taban kirliliği + filtresiz bacalar)
	var extra: Array[String] = []
	for key in _field.story.news_today(GameState.day):
		extra.append(tr("PAPER_NEWS") % tr(key))
		break
	if GameState.day < GameState.MAX_DAYS:
		GameState.base_decay = _field.daily_decay(GameState.day + 1)
		extra.append(tr("PAPER_DECAY") % snappedf(GameState.base_decay + GameState.pollution_rate, 0.1))
	if FieldProgression.number(GameState.day) >= 2 and GameState.day == int(FieldProgression.chapter(GameState.day)["last"]) - 1:
		var need := float(FieldProgression.chapter(GameState.day)["goal"]) - 8.0
		extra.append(tr("PAPER_CH_WARN") % [int(need), int(GameState.nature)])
	# Bölüm sonu: hedefe göre yıldız, ödül ya da ceza
	if FieldProgression.is_last_day(GameState.day):
		var goal := float(FieldProgression.chapter(GameState.day)["goal"])
		var stars := FieldProgression.stars(GameState.nature, goal)
		if stars == 0 and FieldProgression.number(GameState.day) >= 2:
			GameState._end("END_DISMISSED")
			return
		match stars:
			3:
				GameState.change_stat(&"money", 10.0)
				GameState.change_stat(&"people", 5.0)
			2:
				GameState.change_stat(&"money", 5.0)
			0:
				GameState.change_stat(&"people", -5.0)
		extra.append(tr("CH_END_STARS") % [FieldProgression.number(GameState.day), stars, int(goal)])
		extra.append(tr("CH_END_%d" % stars))
		if not GameState.running:
			return
	var deltas := {
		"money": GameState.money - float(_day_start["money"]),
		"people": GameState.people - float(_day_start["people"]),
		"nature": GameState.nature - float(_day_start["nature"]),
	}
	var effects: Dictionary = CrisisManager.last_choice.get("effects", {})
	var stats := _field.day_stats
	_paper.show_report({
		"day": GameState.day,
		"headline": DayReport.pick_headline(deltas["nature"], GameState.day, CrisisManager.last_choice, stats, _field.today_event),
		"subheadline": ("NEWS_TUT_SUB_%d" % (GameState.day % 3 + 1)) if (effects.is_empty() and GameState.day <= FieldProgression.CARD_FREE_DAYS) else DayReport.subheadline_key(effects, GameState.day),
		"deltas": deltas,
		"nature": GameState.nature,
		"planted": stats.get("planted", 0),
		"lines": DayReport.highlights(stats, villagers, Callable(self, "tr")),
		"tax": tax,
		"fruit": fruit,
		"locked": locked,
		"mood": mood,
		"extra": extra,
		"ticker": DayReport.ticker_key(GameState.day),
		"weather": DayReport.weather_key(_field.today_event),
	})
