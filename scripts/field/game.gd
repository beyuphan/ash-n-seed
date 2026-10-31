extends Node
## Oyun akışı: Sabah (karar kartı) -> Saha (kuşbakışı) -> Akşam (gazete). Günler böyle döner.
## Çevre rengi (Atmosphere, EnvironmentTint) ve HUD GameState'e bağlı çalışır.

const MorningDesk := preload("res://scripts/morning_desk.gd")
const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")

var _field: FieldWorld
var _desk: Control
var _paper: EveningPaper
var _end_panel: PanelContainer
var _end_label: Label
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
	add_child(Atmosphere.new())
	_build_phase_ui()
	_build_end_panel()
	_build_splash()
	GameState.phase_changed.connect(func(_p: int) -> void: _refresh())
	GameState.game_over.connect(_show_end)
	GameState.game_won.connect(func() -> void: _show_end(_field.story.ending_key()))
	_refresh()
	_start_music()


func _start_music() -> void:
	var track: AudioStreamOggVorbis = load("res://assets/audio/music/calm_loop.ogg")
	if track == null:
		return
	track.loop = true
	AudioManager.play_music(track)


func _exit_tree() -> void:
	AudioManager.stop_music()


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


func _build_end_panel() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	_end_panel = PanelContainer.new()
	_end_panel.theme = PAPER_THEME
	_end_panel.visible = false
	center.add_child(_end_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	_end_panel.add_child(box)
	_end_label = Label.new()
	_end_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_end_label.custom_minimum_size = Vector2(520, 0)
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_label.add_theme_font_size_override("font_size", 28)
	box.add_child(_end_label)
	var back := Button.new()
	back.text = "END_BACK_MENU"
	back.pressed.connect(func() -> void: SceneManager.change_scene("res://scenes/main_menu.tscn"))
	box.add_child(back)


func _show_end(ending_key: String) -> void:
	_field.set_active(false)
	_desk.visible = false
	_paper.visible = false
	_end_label.text = ending_key
	_end_panel.visible = true
	UiFx.pop_in(_end_panel)


func _refresh() -> void:
	if not GameState.running:
		return
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
	_desk.visible = true
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
	var mood := DayReport.mood_change(green, villagers)
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
	# Bölüm sonu: hedefe göre yıldız, ödül ya da ceza
	if FieldProgression.is_last_day(GameState.day):
		var goal := float(FieldProgression.chapter(GameState.day)["goal"])
		var stars := FieldProgression.stars(GameState.nature, goal)
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
		"headline": DayReport.headline_key(deltas["nature"], GameState.day),
		"subheadline": DayReport.subheadline_key(effects, GameState.day),
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
