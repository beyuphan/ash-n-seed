extends Control
## Sabah ekranının ofis arka planı. İki kat: arka (duvar, pencere, zemin) ve ön (masa).
## Karakter arka ile ön arasına girer, böylece masanın arkasında duruyormuş gibi görünür.

const DESK_TOP := 640.0

var front := false
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	if front:
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	if front:
		_draw_front()
	else:
		_draw_back()


func _draw_back() -> void:
	var w := size.x
	var h := size.y
	# Duvar
	var bands := 12
	for i in bands:
		var t := float(i) / (bands - 1)
		draw_rect(Rect2(0, h * i / bands, w, h / bands + 1),
			Color(0.31, 0.34, 0.29).lerp(Color(0.2, 0.22, 0.19), t))
	for x in range(0, int(w), 80):
		draw_rect(Rect2(x, 0, 40, h), Color(1, 1, 1, 0.025))

	# Pencere: arkada kirli şehir ve bacalar
	var win := Rect2(50, 100, 500, 320)
	draw_rect(win.grow(10), Color(0.16, 0.11, 0.08))
	for i in 8:
		var t := float(i) / 7.0
		draw_rect(Rect2(win.position.x, win.position.y + win.size.y * i / 8.0, win.size.x, win.size.y / 8.0 + 1),
			Color(0.62, 0.56, 0.36).lerp(Color(0.45, 0.42, 0.32), t))
	var skyline := Color(0.17, 0.17, 0.15)
	var ground_y := win.end.y
	var buildings := [[70, 70, 90], [150, 110, 60], [250, 80, 100], [340, 130, 70], [440, 90, 80]]
	for b in buildings:
		draw_rect(Rect2(win.position.x + b[0] - 50, ground_y - b[1], b[2], b[1]), skyline)
	for stack_x in [120.0, 300.0, 470.0]:
		draw_rect(Rect2(stack_x, ground_y - 190, 16, 120), skyline)
		for s in 3:
			var drift := sin(_time * 0.4 + stack_x) * 12.0
			draw_circle(Vector2(stack_x + 8 + drift + s * 16, ground_y - 200 - s * 30),
				20.0 + s * 9.0, Color(0.5, 0.47, 0.38, 0.38 - s * 0.09))
	draw_rect(Rect2(win.position.x + win.size.x / 2 - 4, win.position.y, 8, win.size.y), Color(0.16, 0.11, 0.08))
	draw_rect(Rect2(win.position.x, win.position.y + win.size.y / 2 - 4, win.size.x, 8), Color(0.16, 0.11, 0.08))

	# Zemin
	draw_rect(Rect2(0, 560, w, h - 560), Color(0.19, 0.13, 0.09))
	draw_rect(Rect2(0, 556, w, 8), Color(0.3, 0.2, 0.13))
	for x in range(0, int(w), 120):
		draw_rect(Rect2(x, 564, 3, 80), Color(0, 0, 0, 0.18))

	# Zehirli sarı filtre ve kenar kararması
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.55, 0.5, 0.1, 0.12))
	draw_rect(Rect2(0, 0, w, 90), Color(0, 0, 0, 0.3))


func _draw_front() -> void:
	var w := size.x
	var h := size.y
	# Masa üstü ve ön yüzü
	draw_rect(Rect2(0, DESK_TOP, w, 20), Color(0.42, 0.28, 0.17))
	draw_rect(Rect2(0, DESK_TOP, w, 4), Color(0.55, 0.38, 0.24))
	draw_rect(Rect2(0, DESK_TOP + 20, w, h - DESK_TOP - 20), Color(0.27, 0.18, 0.11))
	for x in range(40, int(w), 320):
		draw_rect(Rect2(x, DESK_TOP + 34, 240, 56), Color(0.22, 0.14, 0.09))
		draw_rect(Rect2(x + 108, DESK_TOP + 56, 24, 6), Color(0.7, 0.58, 0.25))
	# Masanın üstünde: dosya yığını ve küllük
	var stack := Vector2(560, DESK_TOP)
	for i in 4:
		draw_rect(Rect2(stack.x - i * 2, stack.y - 12 - i * 10, 96, 10), Color(0.9, 0.86, 0.72).darkened(i * 0.05))
		draw_rect(Rect2(stack.x - i * 2, stack.y - 12 - i * 10, 96, 2), Color(0.75, 0.62, 0.3))
	draw_set_transform(Vector2(470, DESK_TOP - 4), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 30.0, Color(0.12, 0.12, 0.12))
	draw_circle(Vector2.ZERO, 22.0, Color(0.32, 0.3, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(458, DESK_TOP - 12, 14, 3), Color(0.85, 0.82, 0.7))
