class_name IconCounter
extends Control
## Pikselli çerçeveli küçük sayaç: ikon plakası, isim ve "x3" gibi sayı. Tohum sayısı için.

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.22, 0.165, 0.12)
const CREAM := Color(0.97, 0.93, 0.83)

var icon_name := "seed"
var label_key := ""
var plate_color := Color(0.6, 0.4, 0.2)
var count := 0


func setup(label: String, icon: String, color: Color) -> void:
	label_key = label
	icon_name = icon
	plate_color = color


func set_count(value: int) -> void:
	count = value
	queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(170, 68)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var n := 4.0
	draw_rect(Rect2(n, 0, w - 2 * n, h), FRAME)
	draw_rect(Rect2(0, n, w, h - 2 * n), FRAME)
	draw_rect(Rect2(2 * n, n, w - 4 * n, h - 2 * n), PANEL)
	draw_rect(Rect2(n, 2 * n, w - 2 * n, h - 4 * n), PANEL)
	var plate := Rect2(7, 7, h - 14, h - 14)
	draw_rect(plate, plate_color.darkened(0.55))
	draw_rect(plate, FRAME, false, 3.0)
	var icon_size := 48.0
	draw_texture_rect(UiArt.icon(icon_name),
		Rect2(plate.get_center() - Vector2(icon_size, icon_size) / 2.0, Vector2(icon_size, icon_size)), false)
	var font := get_theme_font("font", "Label")
	var text_x := h + 2.0
	draw_string(font, Vector2(text_x, 25), tr(label_key), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, CREAM)
	draw_string(font, Vector2(text_x, 56), "x%d" % count, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, CREAM)
