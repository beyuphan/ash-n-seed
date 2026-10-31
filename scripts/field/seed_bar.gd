class_name SeedBar
extends Control
## Tohum çubuğu: üç ağaç türü için yuvalar. 1, 2, 3 tuşları (ya da Tab) seçer. Seçili tür dikilir ve pazardan alınır.
## Pazar yakınındayken yuvalarda fiyat görünür.

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.22, 0.165, 0.12)
const CREAM := Color(0.97, 0.93, 0.83)
const GOLD := Color(1.0, 0.82, 0.3)
const SLOT_W := 104.0

var counts: Dictionary = {"pine": 0, "oak": 0, "fruit": 0}
## Açılmış türler; çubuk sadece bunları gösterir.
var species: Array[String] = ["pine"]:
	set(value):
		species = value
		custom_minimum_size = Vector2(species.size() * SLOT_W + 16, 68)
		size = custom_minimum_size
		queue_redraw()
var selected := "pine"
var show_prices := false


func _ready() -> void:
	custom_minimum_size = Vector2(species.size() * SLOT_W + 16, 68)
	size = custom_minimum_size
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func refresh() -> void:
	queue_redraw()


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
	var font := get_theme_font("font", "Label")
	for i in species.size():
		var id: String = species[i]
		var info := FieldSpecies.data(id)
		var x := 8.0 + i * SLOT_W
		var slot := Rect2(x, 6, SLOT_W - 4, h - 12)
		var is_selected := id == selected
		draw_rect(slot, FRAME)
		draw_rect(slot.grow(-3), Color(0.32, 0.25, 0.18) if not is_selected else Color(0.45, 0.36, 0.2))
		if is_selected:
			draw_rect(slot, GOLD, false, 3.0)
		var empty: bool = counts[id] <= 0
		draw_texture_rect(UiArt.icon("seed"), Rect2(x + 6, 14, 40, 40), false, (info["tint"] as Color) if not empty else Color(0.5, 0.5, 0.5, 0.6))
		draw_string(font, Vector2(x + 8, 20), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GOLD if is_selected else CREAM.darkened(0.3))
		draw_string(font, Vector2(x, 36), "x%d" % counts[id], HORIZONTAL_ALIGNMENT_RIGHT, SLOT_W - 12, 24, CREAM if not empty else CREAM.darkened(0.5))
		var label := "%d" % int(info["price"]) if show_prices else tr(info["name"])
		draw_string(font, Vector2(x, 56), label, HORIZONTAL_ALIGNMENT_RIGHT, SLOT_W - 12, 14, GOLD if show_prices else CREAM.darkened(0.2))
