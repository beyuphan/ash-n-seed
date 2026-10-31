class_name WeatherOverlay
extends Control
## Ekran üstü hava efektleri: yağmur damlaları ve duman bulutu. mode: "none", "rain", "smog".

const DROPS := 140

var mode := "none"

var _drops: Array[Vector2] = []
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in DROPS:
		_drops.append(Vector2(randf(), randf()))


func _process(delta: float) -> void:
	_time += delta
	if mode == "none":
		return
	if mode == "rain":
		for i in _drops.size():
			var d := _drops[i]
			d.y += delta * (1.4 + float(i % 5) * 0.15)
			d.x -= delta * 0.25
			if d.y > 1.05 or d.x < -0.05:
				d = Vector2(randf_range(0.0, 1.2), -0.05)
			_drops[i] = d
	queue_redraw()


func _draw() -> void:
	match mode:
		"rain":
			draw_rect(Rect2(Vector2.ZERO, size), Color(0.35, 0.45, 0.6, 0.12))
			for d in _drops:
				var p := Vector2(d.x * size.x, d.y * size.y)
				draw_line(p, p + Vector2(-6, 16), Color(0.75, 0.85, 1.0, 0.55), 2.0)
		"smog":
			var pulse := 0.5 + 0.5 * sin(_time * 0.8)
			draw_rect(Rect2(Vector2.ZERO, size), Color(0.45, 0.35, 0.2, 0.16 + 0.05 * pulse))
			for i in 6:
				var x := fmod(_time * 20.0 + i * 260.0, size.x + 400.0) - 200.0
				draw_circle(Vector2(x, size.y * (0.2 + 0.13 * i)), 140.0, Color(0.4, 0.33, 0.22, 0.07))
