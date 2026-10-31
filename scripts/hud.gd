extends CanvasLayer
## Üst bar: takvim yaprağı (gün) ve üç gösterge (Kasa, Halk, Çevre). GameState sinyallerine bağlıdır.
## Değer değişince gösterge parlar, +/- sayısı yukarı süzülür. Çerçeveli kartlar yok, sahne üstte yüzer.

const STATS := [
	{"id": &"money", "label": "STAT_MONEY", "icon": "coin", "color": Color(0.96, 0.77, 0.26)},
	{"id": &"people", "label": "STAT_PEOPLE", "icon": "heart", "color": Color(0.94, 0.4, 0.44)},
	{"id": &"nature", "label": "STAT_NATURE", "icon": "sprout", "color": Color(0.45, 0.8, 0.32)},
]
const POSITIVE := Color(0.62, 0.9, 0.5)
const NEGATIVE := Color(1.0, 0.55, 0.45)

var _gauges: Dictionary = {}  # id -> StatGauge
var _last: Dictionary = {}


func _ready() -> void:
	_build()
	GameState.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()


func _build() -> void:
	# Sahneyi çok bozmadan okunurluğu artıran yumuşak üst gölge
	var shade := TextureRect.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0.7))
	gradient.set_color(1, Color(0, 0, 0, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 8
	tex.height = 128
	shade.texture = tex
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	shade.offset_bottom = 110

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var badge := DayBadge.new()
	row.add_child(badge)
	for stat in STATS:
		var gauge := StatGauge.new()
		gauge.setup(stat["label"], stat["icon"], stat["color"])
		gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(gauge)
		_gauges[stat["id"]] = gauge


func _on_stats_changed() -> void:
	var values := {
		&"money": GameState.money,
		&"people": GameState.people,
		&"nature": GameState.nature,
	}
	for stat in STATS:
		var id: StringName = stat["id"]
		var gauge: StatGauge = _gauges[id]
		var value: float = values[id]
		if _last.has(id):
			var delta := value - float(_last[id])
			if absf(delta) >= 0.5:
				UiFx.punch(gauge, 1.08)
				_spawn_delta(gauge, delta)
		_last[id] = value
		gauge.set_value(value)


## Göstergenin altında +/- sayısı belirir, süzülür ve kaybolur.
func _spawn_delta(gauge: Control, delta: float) -> void:
	var label := Label.new()
	label.text = "%+d" % int(round(delta))
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", POSITIVE if delta > 0.0 else NEGATIVE)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.06))
	label.add_theme_constant_override("outline_size", 9)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var origin := gauge.global_position + Vector2(gauge.size.x - 72.0, gauge.size.y + 2.0)
	label.position = origin
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", origin.y + 28.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.9).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)
