class_name MarketPointer
extends Control
## Ekran kenarında pazarı gösteren ok. Pazar uzaktayken görünür, yaklaşınca kaybolur.
## target: pazarın ekran koordinatı. Ok, ekranın görünür alanı içinde kenara yapışır.

## Okun durabileceği alan. Üst bar, alt göstergeler ve ipucu yazısı dışarıda kalır.
const AREA := Rect2(60, 112, 1160, 400)
## Ok bu panellerin üstüne düşmesin, düşerse altına itilir (görev paneli, mini harita).
const AVOID: Array[Rect2] = [Rect2(8, 86, 346, 320), Rect2(1046, 88, 230, 176)]
const COLOR := Color(1.0, 0.82, 0.3)
const DARK := Color(0.1, 0.06, 0.04)

var target := Vector2.ZERO
var label := ""
var color := COLOR
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	_time += delta
	if visible:
		queue_redraw()


func _inside_avoid(p: Vector2) -> bool:
	for rect in AVOID:
		if rect.has_point(p):
			return true
	return false


func _draw() -> void:
	var area := AREA
	var center := Rect2(Vector2.ZERO, size).get_center()
	var pos := Vector2(clampf(target.x, area.position.x, area.end.x), clampf(target.y, area.position.y, area.end.y))
	for rect in AVOID:
		if rect.has_point(pos):
			pos.y = rect.end.y + 30.0
	var angle := (target - center).angle()
	if area.has_point(target) and not _inside_avoid(target):
		# Pazar ekranda: üstünde aşağı bakan sallanan ok
		pos = target + Vector2(0, -64)
		angle = PI / 2.0
	else:
		angle = (target - pos).angle()
	var bob := sin(_time * 5.0) * 4.0
	var tip := pos + Vector2.from_angle(angle) * (30.0 + bob)
	var left := pos + Vector2.from_angle(angle + 2.5) * 22.0
	var right := pos + Vector2.from_angle(angle - 2.5) * 22.0
	draw_colored_polygon(PackedVector2Array([tip + Vector2.from_angle(angle) * 4.0, left, right]), DARK)
	draw_colored_polygon(PackedVector2Array([tip, pos + Vector2.from_angle(angle + 2.4) * 17.0, pos + Vector2.from_angle(angle - 2.4) * 17.0]), color)
	var font := get_theme_font("font", "Label")
	var text_pos := pos + Vector2(-120, -30) if pos.y > size.y * 0.5 else pos + Vector2(-120, 52)
	draw_string_outline(font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 240, 22, 8, DARK)
	draw_string(font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 240, 22, color)
