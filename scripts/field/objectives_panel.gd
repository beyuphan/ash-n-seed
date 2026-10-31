class_name ObjectivesPanel
extends Control
## Sol üstte "Bugünün Görevleri" listesi: onay kutusu, görev metni, ilerleme ve ödül.
## Tamamlanan görev parlar ve yeşil tik alır.

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.2, 0.15, 0.11, 0.94)
const CREAM := Color(0.97, 0.93, 0.83)
const GOLD := Color(1.0, 0.82, 0.3)
const GREEN := Color(0.5, 0.85, 0.4)
const ROW := 40.0

var objectives: FieldObjectives
var green_text := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size = Vector2(330, 160)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		queue_redraw()


func _process(delta: float) -> void:
	if objectives == null or not visible:
		return
	for it in objectives.items:
		it["flash"] = move_toward(it["flash"], 0.0, delta * 1.6)
	queue_redraw()


func _draw() -> void:
	if objectives == null:
		return
	var count := objectives.items.size()
	var h := 36.0 + count * ROW + 4.0
	size.y = h
	var w := size.x
	var n := 4.0
	draw_rect(Rect2(n, 0, w - 2 * n, h), FRAME)
	draw_rect(Rect2(0, n, w, h - 2 * n), FRAME)
	draw_rect(Rect2(2 * n, n, w - 4 * n, h - 2 * n), PANEL)
	draw_rect(Rect2(n, 2 * n, w - 2 * n, h - 4 * n), PANEL)
	var font := get_theme_font("font", "Label")
	draw_string(font, Vector2(16, 26), tr("OBJ_TITLE"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD)
	draw_string(font, Vector2(0, 26), green_text, HORIZONTAL_ALIGNMENT_RIGHT, w - 16, 16, GREEN)
	var translate := Callable(self, "tr")
	for i in count:
		var it: Dictionary = objectives.items[i]
		var y := 34.0 + i * ROW
		if it["flash"] > 0.0:
			draw_rect(Rect2(8, y, w - 16, ROW - 4), Color(1, 1, 0.6, 0.35 * it["flash"]))
		# Onay kutusu
		var box := Rect2(16, y + 7, 20, 20)
		draw_rect(box, FRAME)
		draw_rect(box.grow(-3), Color(0.32, 0.25, 0.18) if not it["done"] else Color(0.3, 0.6, 0.25))
		if it["done"]:
			draw_line(Vector2(21, y + 17), Vector2(25, y + 22), CREAM, 3.0)
			draw_line(Vector2(25, y + 22), Vector2(32, y + 12), CREAM, 3.0)
		var color := GREEN if it["done"] else CREAM
		draw_string(font, Vector2(46, y + 18), FieldObjectives.text_of(it, translate), HORIZONTAL_ALIGNMENT_LEFT, w - 100, 16, color)
		draw_string(font, Vector2(46, y + 34), FieldObjectives.reward_text_of(it, translate), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GOLD.darkened(0.1))
		draw_string(font, Vector2(0, y + 22), "%d/%d" % [it["progress"], it["target"]], HORIZONTAL_ALIGNMENT_RIGHT, w - 16, 16, color)
