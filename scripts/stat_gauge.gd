class_name StatGauge
extends Control
## Tek bir gösterge: ikon plakası, isim, değer ve 10 bölmeli çubuk. Pikselli çerçeve.
## Değer değişince parlar, düşünce titrer, 25 altında kırmızı yanıp söner.

const SEGMENTS := 10
const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.22, 0.165, 0.12)
const EMPTY := Color(0.11, 0.08, 0.065)
const CREAM := Color(0.97, 0.93, 0.83)
const WARN := Color(0.9, 0.24, 0.2)
const WARN_BELOW := 25.0

var label_key := ""
var icon_name := ""
var color := Color.WHITE
var value := 50.0
## Üst sınır. Gösterge her zaman yüzde olarak okunur (stamina 300 ise 150 = %50).
var max_value := 100.0

var _shown := 50.0
var _flash := 0.0
var _shake := 0.0
var _time := 0.0
var _first := true


func setup(label: String, icon: String, bar_color: Color) -> void:
	label_key = label
	icon_name = icon
	color = bar_color


func _ready() -> void:
	custom_minimum_size = Vector2(250, 68)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(func() -> void: pivot_offset = size / 2.0)


## Yeni değeri verir. Değişim varsa parlama, düşüşse titreme tetiklenir.
func set_value(new_value: float) -> void:
	if _first:
		value = new_value
		_shown = new_value
		_first = false
		return
	var delta := new_value - value
	value = new_value
	if absf(delta) >= 0.5:
		_flash = 1.0
		if delta < 0.0:
			_shake = 0.4


func _process(delta: float) -> void:
	_time += delta
	_shown = lerpf(_shown, value, 1.0 - exp(-7.0 * delta))
	_flash = move_toward(_flash, 0.0, delta * 3.0)
	_shake = move_toward(_shake, 0.0, delta)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var low := value / max_value * 100.0 <= WARN_BELOW
	var frame := FRAME.lerp(WARN, 0.5 + 0.5 * sin(_time * 8.0)) if low else FRAME
	var shake_x := sin(_time * 90.0) * 5.0 * (_shake / 0.4) if _shake > 0.0 else 0.0
	draw_set_transform(Vector2(shake_x, 0), 0.0, Vector2.ONE)

	_pixel_box(Rect2(0, 0, w, h), frame, PANEL)

	# İkon plakası
	var plate := Rect2(7, 7, h - 14, h - 14)
	draw_rect(plate, color.darkened(0.6))
	draw_rect(plate, frame, false, 3.0)
	var icon_size := 48.0
	var bob := sin(_time * 3.0) * 1.5 if low else 0.0
	draw_texture_rect(UiArt.icon(icon_name),
		Rect2(plate.get_center() - Vector2(icon_size, icon_size) / 2.0 + Vector2(0, bob), Vector2(icon_size, icon_size)), false)

	# İsim ve değer
	var font := get_theme_font("font", "Label")
	var text_x := h + 2.0
	draw_string(font, Vector2(text_x, 25), tr(label_key), HORIZONTAL_ALIGNMENT_LEFT, -1, 19, CREAM)
	draw_string(font, Vector2(text_x, 25), str(int(round(value / max_value * 100.0))), HORIZONTAL_ALIGNMENT_RIGHT, w - text_x - 12.0, 23, CREAM)

	# Bölmeli çubuk
	var bar := Rect2(text_x, 35, w - text_x - 12.0, 21)
	draw_rect(bar.grow(3), frame)
	var gap := 3.0
	var seg_w := (bar.size.x - gap * (SEGMENTS - 1)) / SEGMENTS
	var fill_color := WARN if low else color
	for i in SEGMENTS:
		var x := bar.position.x + i * (seg_w + gap)
		draw_rect(Rect2(x, bar.position.y, seg_w, bar.size.y), EMPTY)
		var fill := clampf(_shown / max_value * 10.0 - i, 0.0, 1.0)
		if fill <= 0.0:
			continue
		var r := Rect2(x, bar.position.y, seg_w * fill, bar.size.y)
		draw_rect(r, fill_color)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), fill_color.lightened(0.38))
		draw_rect(Rect2(r.position.x, r.end.y - 4, r.size.x, 4), fill_color.darkened(0.3))

	if _flash > 0.0:
		draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1, 0.3 * _flash))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Köşeleri kırpılmış "piksel" dikdörtgen: dış çerçeve ve iç dolgu.
func _pixel_box(r: Rect2, frame: Color, fill: Color) -> void:
	var n := 4.0
	draw_rect(Rect2(r.position.x + n, r.position.y, r.size.x - 2 * n, r.size.y), frame)
	draw_rect(Rect2(r.position.x, r.position.y + n, r.size.x, r.size.y - 2 * n), frame)
	var i := r.grow(-n)
	draw_rect(Rect2(i.position.x + n, i.position.y, i.size.x - 2 * n, i.size.y), fill)
	draw_rect(Rect2(i.position.x, i.position.y + n, i.size.x, i.size.y - 2 * n), fill)
	draw_rect(Rect2(i.position.x + n, i.position.y + n, i.size.x - 2 * n, i.size.y - 2 * n), fill)
