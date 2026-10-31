class_name DeskSurface
extends Control
## Akşam gazetesinin fırlatıldığı ahşap masa: tahta kaplama, damarlar, kahve lekesi, kalem. Kodla çizilir.

const PLANK_H := 96.0
const BASE := Color(0.31, 0.2, 0.13)

var _grain: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 140:
		_grain.append({"x": rng.randf_range(0.0, 1280.0), "y": rng.randf_range(0.0, 720.0), "w": rng.randf_range(60.0, 260.0), "a": rng.randf_range(0.06, 0.16)})


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var rows := int(ceil(720.0 / PLANK_H))
	for r in rows:
		var shade := rng.randf_range(-0.035, 0.035)
		draw_rect(Rect2(0, r * PLANK_H, 1280, PLANK_H), Color(BASE.r + shade, BASE.g + shade * 0.8, BASE.b + shade * 0.6))
		draw_rect(Rect2(0, r * PLANK_H, 1280, 3), Color(0.12, 0.08, 0.05))
		# Tahta birleşim yerleri
		var seam := rng.randf_range(200.0, 1000.0)
		draw_rect(Rect2(seam, r * PLANK_H, 3, PLANK_H), Color(0.12, 0.08, 0.05))
	for g in _grain:
		draw_line(Vector2(g["x"], g["y"]), Vector2(g["x"] + g["w"], g["y"] + 1.5), Color(0.15, 0.09, 0.05, g["a"]), 2.0)
	# Kahve lekesi
	draw_arc(Vector2(1110, 560), 42.0, 0.3, TAU - 0.4, 40, Color(0.12, 0.07, 0.04, 0.5), 5.0)
	draw_arc(Vector2(1108, 562), 38.0, 0.0, TAU, 40, Color(0.2, 0.12, 0.07, 0.25), 2.0)
	# Kalem
	draw_line(Vector2(60, 640), Vector2(200, 600), Color(0.95, 0.78, 0.2), 9.0)
	draw_line(Vector2(200, 600), Vector2(222, 593), Color(0.9, 0.75, 0.55), 9.0)
	draw_line(Vector2(222, 593), Vector2(234, 589), Color(0.15, 0.1, 0.1), 6.0)
	draw_line(Vector2(60, 640), Vector2(52, 642), Color(0.85, 0.4, 0.45), 9.0)
	# Kenar karartması
	for i in 6:
		var a := 0.16 - i * 0.025
		draw_rect(Rect2(0, 0, 1280, 18 + i * 22), Color(0, 0, 0, a * 0.5))
		draw_rect(Rect2(0, 720 - (18 + i * 22), 1280, 18 + i * 22), Color(0, 0, 0, a))
