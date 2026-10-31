class_name MiniMap
extends Control
## Sağ üstte küçük harita: keşfedilen alan, nehir, yollar, binalar, sandıklar ve kuyular.
## Oyuncu beyaz yanıp sönen nokta, pazar sarı yıldız. Haritayı FieldMap.minimap_image() üretir.

const SCALE := 2
const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.22, 0.165, 0.12)
const CREAM := Color(0.97, 0.93, 0.83)

var player_tile := Vector2i.ZERO
var market_tile := Vector2i.ZERO
var explored_percent := 0

var _texture: ImageTexture
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(FieldMap.COLS * SCALE + 16, FieldMap.ROWS * SCALE + 38)
	size = custom_minimum_size


func set_image(img: Image) -> void:
	if _texture == null:
		_texture = ImageTexture.create_from_image(img)
	else:
		_texture.update(img)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if visible:
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
	draw_string(font, Vector2(12, 21), "%s %d%%" % [tr("MAP_TITLE"), explored_percent], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CREAM)
	var origin := Vector2(8, 28)
	if _texture != null:
		draw_rect(Rect2(origin - Vector2(2, 2), Vector2(FieldMap.COLS * SCALE + 4, FieldMap.ROWS * SCALE + 4)), FRAME)
		draw_texture_rect(_texture, Rect2(origin, Vector2(FieldMap.COLS, FieldMap.ROWS) * SCALE), false)
	# Pazar: sarı artı
	var m := origin + Vector2(market_tile) * SCALE
	draw_rect(Rect2(m + Vector2(-3, 0), Vector2(8, 2)), Color(1.0, 0.85, 0.3))
	draw_rect(Rect2(m + Vector2(0, -3), Vector2(2, 8)), Color(1.0, 0.85, 0.3))
	# Oyuncu: yanıp sönen beyaz nokta
	var p := origin + Vector2(player_tile) * SCALE
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_rect(Rect2(p + Vector2(-2, -2), Vector2(6, 6)), Color(0.1, 0.07, 0.05))
	draw_rect(Rect2(p + Vector2(-1, -1), Vector2(4, 4)), Color(1, 1, 1, 0.5 + 0.5 * pulse))
