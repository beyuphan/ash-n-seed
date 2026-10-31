class_name DayBadge
extends Control
## Takvim yaprağı: üstte kırmızı şerit, ortada büyük gün sayısı. Sağda aşamanın adı.

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.22, 0.165, 0.12)
const PAPER := Color(0.97, 0.93, 0.8)
const INK := Color(0.2, 0.14, 0.1)
const RED := Color(0.78, 0.22, 0.18)
const CREAM := Color(0.97, 0.93, 0.83)
const PHASE_KEYS := ["PHASE_MORNING", "PHASE_FIELD", "PHASE_EVENING"]


func _ready() -> void:
	custom_minimum_size = Vector2(300, 68)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.day_changed.connect(func(_d: int) -> void: queue_redraw())
	GameState.phase_changed.connect(func(_p: int) -> void: queue_redraw())


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	_pixel_box(Rect2(0, 0, w, h))
	var font := get_theme_font("font", "Label")

	# Takvim yaprağı
	var sheet := Rect2(8, 7, 74, h - 14)
	draw_rect(sheet.grow(3), FRAME)
	draw_rect(sheet, PAPER)
	draw_rect(Rect2(sheet.position, Vector2(sheet.size.x, 17)), RED)
	draw_rect(Rect2(sheet.position.x + 14, sheet.position.y - 4, 6, 9), FRAME)  # spiral halkalar
	draw_rect(Rect2(sheet.end.x - 20, sheet.position.y - 4, 6, 9), FRAME)
	draw_string(font, Vector2(sheet.position.x, sheet.position.y + 14), tr("HUD_DAY_SHORT"),
		HORIZONTAL_ALIGNMENT_CENTER, sheet.size.x, 15, Color.WHITE)
	draw_string(font, Vector2(sheet.position.x, sheet.end.y - 7), str(GameState.day),
		HORIZONTAL_ALIGNMENT_CENTER, sheet.size.x - 14, 30, INK)
	draw_string(font, Vector2(sheet.position.x + 54, sheet.end.y - 7), "/%d" % GameState.MAX_DAYS,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK.lightened(0.3))

	# Aşama adı
	var phase_text := tr(PHASE_KEYS[GameState.phase])
	draw_multiline_string(font, Vector2(96, 30), phase_text, HORIZONTAL_ALIGNMENT_LEFT, w - 108.0, 19, 2, CREAM)


func _pixel_box(r: Rect2) -> void:
	var n := 4.0
	draw_rect(Rect2(r.position.x + n, r.position.y, r.size.x - 2 * n, r.size.y), FRAME)
	draw_rect(Rect2(r.position.x, r.position.y + n, r.size.x, r.size.y - 2 * n), FRAME)
	var i := r.grow(-n)
	draw_rect(Rect2(i.position.x + n, i.position.y, i.size.x - 2 * n, i.size.y), PANEL)
	draw_rect(Rect2(i.position.x, i.position.y + n, i.size.x, i.size.y - 2 * n), PANEL)
	draw_rect(Rect2(i.position.x + n, i.position.y + n, i.size.x - 2 * n, i.size.y - 2 * n), PANEL)
