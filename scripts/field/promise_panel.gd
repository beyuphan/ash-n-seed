class_name PromisePanel
extends Control
## "Sözlerim": Bugünün Görevleri'nin hemen altında. Verdiğin sözler, seni bekleyen karakterler ve yardım isteyenler.
## rows: [{mark: "p" (söz) ya da "!" (çağrı), title, sub, prog}]. Boşsa panel görünmez.

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.16, 0.12, 0.1, 0.94)
const CREAM := Color(0.97, 0.93, 0.83)
const GOLD := Color(1.0, 0.82, 0.3)
const ROW := 40.0

var rows: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size = Vector2(330, 80)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		queue_redraw()


func set_rows(new_rows: Array) -> void:
	if new_rows != rows:
		rows = new_rows
		visible = not rows.is_empty()
		queue_redraw()


func _draw() -> void:
	if rows.is_empty():
		return
	var h := 34.0 + rows.size() * ROW + 4.0
	size.y = h
	var w := size.x
	var n := 4.0
	draw_rect(Rect2(n, 0, w - 2 * n, h), FRAME)
	draw_rect(Rect2(0, n, w, h - 2 * n), FRAME)
	draw_rect(Rect2(n, n, w - 2 * n, h - 2 * n), PANEL)
	var font := get_theme_font("font", "Label")
	draw_string(font, Vector2(14, 24), tr("PROM_TITLE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD)
	for i in rows.size():
		var r: Dictionary = rows[i]
		var y := 32.0 + i * ROW
		var c := Vector2(26, y + 18)
		if r["mark"] == "!":
			draw_circle(c, 11.0, FRAME)
			draw_circle(c, 9.0, GOLD)
			draw_string(font, c + Vector2(-5, 7), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 20, FRAME)
		else:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -11), c + Vector2(10, 0), c + Vector2(0, 11), c + Vector2(-10, 0)]), FRAME)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -8), c + Vector2(7, 0), c + Vector2(0, 8), c + Vector2(-7, 0)]), Color(0.9, 0.5, 0.45))
		draw_string(font, Vector2(46, y + 16), r["title"], HORIZONTAL_ALIGNMENT_LEFT, w - 100, 16, CREAM)
		draw_string(font, Vector2(46, y + 33), r["sub"], HORIZONTAL_ALIGNMENT_LEFT, w - 100, 13, GOLD.darkened(0.1))
		if r.get("prog", "") != "":
			draw_string(font, Vector2(0, y + 22), r["prog"], HORIZONTAL_ALIGNMENT_RIGHT, w - 16, 17, CREAM)
