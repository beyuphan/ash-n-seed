class_name UiArt
extends RefCounted
## Arayüz ikonları (24x24) ve başkanın arkadan silüeti, kodla piksel piksel çizilir.
## Kullanım: UiArt.icon("coin"), UiArt.mayor_silhouette()

const OUTLINE := Color(0.16, 0.09, 0.05)
const ICON_SIZE := 24
const MAYOR_W := 44
const MAYOR_H := 36

static var _cache: Dictionary = {}


## name: coin (Kasa), heart (Halk), sprout (Çevre)
static func icon(name: String) -> ImageTexture:
	if not _cache.has(name):
		var img := Image.create_empty(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
		match name:
			"coin": _coin(img)
			"heart": _heart(img)
			"bolt": _bolt(img)
			"seed": _seed(img)
			_: _sprout(img)
		_outline(img, OUTLINE)
		_cache[name] = ImageTexture.create_from_image(img)
	return _cache[name]


## Başkanın arkadan görünen siluet bust'ı. Cinsiyetsiz: kapüşonlu yağmurluk, kapüşondan fidan filizi.
static func mayor_silhouette() -> ImageTexture:
	if _cache.has("mayor"):
		return _cache["mayor"]
	var img := Image.create_empty(MAYOR_W, MAYOR_H, false, Image.FORMAT_RGBA8)
	var body := Color(0.09, 0.1, 0.12)
	var body_l := Color(0.15, 0.16, 0.19)
	var leaf := Color(0.45, 0.8, 0.32)
	_ellipse(img, 22, 42, 21, 15, body)           # omuzlar (yağmurluk)
	_ellipse(img, 22, 20, 10.5, 10, body)         # kapüşon gövdesi
	_poly(img, [Vector2(12, 21), Vector2(22, 5), Vector2(32, 21)], body)  # sivri kapüşon ucu
	_rect(img, 16, 27, 12, 4, body)               # kapüşonun alt kıvrımı
	_rect(img, 10, 33, 24, 2, body_l)             # omuz çizgisi
	_line(img, 9, 31, 13, 36, body_l)             # yağmurluk dikişleri
	_line(img, 35, 31, 31, 36, body_l)
	_line(img, 22, 8, 22, 36, body_l)             # kapüşon sırt dikişi
	# Kapüşonun ucundan çıkan fidan
	_line(img, 22, 5, 22, 2, Color(0.25, 0.55, 0.22))
	_ellipse(img, 19, 2, 3, 1.4, leaf)
	_ellipse(img, 25.5, 1.2, 3, 1.4, leaf)
	# Sağ üstten, penceredeki kirli sarı ışığın kenar aydınlatması
	var rim := Color(0.72, 0.64, 0.34)
	var src := img.duplicate() as Image
	for y in MAYOR_H:
		for x in MAYOR_W:
			if src.get_pixel(x, y).a < 0.5:
				continue
			var up_empty := y == 0 or src.get_pixel(x, y - 1).a < 0.5
			var left_empty := x == 0 or src.get_pixel(x - 1, y).a < 0.5
			if up_empty or left_empty:
				img.set_pixel(x, y, rim)
	_cache["mayor"] = ImageTexture.create_from_image(img)
	return _cache["mayor"]


# ------------------------------------------------------------------ ikonlar

## Altın para: koyu kenar, açık yüz, sol üstte parlama, ortada kabartma elmas.
static func _coin(img: Image) -> void:
	var rim := Color(0.82, 0.54, 0.08)
	var face := Color(0.99, 0.8, 0.22)
	var face_l := Color(1.0, 0.88, 0.42)
	_ellipse(img, 12, 12, 10.5, 10.5, rim)
	_ellipse(img, 12, 12, 8.8, 8.8, face)
	_ellipse(img, 12, 12, 6.4, 6.4, face_l)
	for y in ICON_SIZE:
		for x in ICON_SIZE:
			var dx := x + 0.5 - 12.0
			var dy := y + 0.5 - 12.0
			if absf(dx) + absf(dy) <= 3.6:
				_px(img, x, y, Color(0.9, 0.64, 0.12))  # kabartma elmas
			elif dx + dy < -9.0 and Vector2(dx, dy).length() < 9.5:
				_px(img, x, y, Color(1.0, 0.96, 0.72))  # sol üst parlama
	_rect(img, 11, 7, 2, 2, Color(1.0, 0.96, 0.72))


## Kalp: kapalı formülle çizilen yumuşak şekil, sol üstte ışık, sağ altta gölge.
static func _heart(img: Image) -> void:
	var red := Color(0.93, 0.28, 0.34)
	var red_l := Color(1.0, 0.62, 0.66)
	var red_d := Color(0.7, 0.14, 0.2)
	for y in ICON_SIZE:
		for x in ICON_SIZE:
			var px := (x + 0.5 - 12.0) / 9.6
			var py := -(y + 0.5 - 12.6) / 9.6
			var a := px * px + py * py - 1.0
			if a * a * a - px * px * py * py * py <= 0.0:
				var c := red
				if (px + 0.5) * (px + 0.5) + (py - 0.45) * (py - 0.45) < 0.05:
					c = red_l
				elif px - py > 1.0:
					c = red_d
				_px(img, x, y, c)


## Filiz: toprak tepeciği, ince gövde, iki yaprak. Oyunun "Seed" fikri.
static func _sprout(img: Image) -> void:
	var green := Color(0.45, 0.8, 0.3)
	var green_l := Color(0.68, 0.94, 0.45)
	var green_d := Color(0.22, 0.52, 0.2)
	_ellipse(img, 12, 21, 8.5, 3.0, Color(0.46, 0.3, 0.18))
	_ellipse(img, 10, 20.2, 3.5, 1.2, Color(0.6, 0.42, 0.26))
	_line(img, 12, 20, 12, 12, green_d)
	_line(img, 13, 20, 13, 12, green_d)
	_ellipse_rot(img, 7.2, 9.4, 6.4, 3.4, -0.5, green)
	_ellipse_rot(img, 16.8, 7.6, 6.8, 3.6, 0.5, green)
	_ellipse_rot(img, 6.6, 8.6, 3.6, 1.4, -0.5, green_l)
	_ellipse_rot(img, 16.2, 6.6, 3.8, 1.5, 0.5, green_l)
	_line(img, 3, 11, 11, 9, green_d)
	_line(img, 14, 9, 21, 5, green_d)


## Şimşek: stamina ikonu.
static func _bolt(img: Image) -> void:
	var pts := PackedVector2Array([Vector2(14, 1), Vector2(5, 13.5), Vector2(11, 13.5), Vector2(8, 23),
		Vector2(19, 9.5), Vector2(12.5, 9.5), Vector2(15.5, 1)])
	for y in ICON_SIZE:
		for x in ICON_SIZE:
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), pts):
				var c := Color(1.0, 0.86, 0.25)
				if x + y < 20:
					c = Color(1.0, 0.95, 0.6)
				_px(img, x, y, c)


## Tohum: kahverengi çekirdek ve filizlenmeye başlayan uç.
static func _seed(img: Image) -> void:
	_ellipse_rot(img, 11, 14, 7.0, 4.6, -0.5, Color(0.6, 0.38, 0.2))
	_ellipse_rot(img, 9.5, 12.2, 3.2, 1.4, -0.5, Color(0.84, 0.62, 0.4))
	_line(img, 7, 17, 15, 11, Color(0.4, 0.24, 0.12))
	_line(img, 16, 9, 18, 4, Color(0.25, 0.55, 0.22))
	_ellipse_rot(img, 20, 4.5, 3.0, 1.7, -0.4, Color(0.5, 0.82, 0.32))


# ------------------------------------------------------------------ yardımcılar

static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in h:
		for i in w:
			_px(img, x + i, y + j, c)


static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	_ellipse_rot(img, cx, cy, rx, ry, 0.0, c)


static func _ellipse_rot(img: Image, cx: float, cy: float, rx: float, ry: float, angle: float, c: Color) -> void:
	var reach := int(maxf(rx, ry)) + 2
	for y in range(int(cy) - reach, int(cy) + reach + 1):
		for x in range(int(cx) - reach, int(cx) + reach + 1):
			var local := Vector2(x + 0.5 - cx, y + 0.5 - cy).rotated(-angle)
			var dx := local.x / rx
			var dy := local.y / ry
			if dx * dx + dy * dy <= 1.0:
				_px(img, x, y, c)


static func _poly(img: Image, pts: Array, c: Color) -> void:
	var packed := PackedVector2Array()
	for p in pts:
		packed.append(p)
	for y in img.get_height():
		for x in img.get_width():
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), packed):
				_px(img, x, y, c)


static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var steps := maxi(absi(x1 - x0), absi(y1 - y0))
	for i in steps + 1:
		var t := 0.0 if steps == 0 else float(i) / steps
		_px(img, roundi(lerpf(x0, x1, t)), roundi(lerpf(y0, y1, t)), c)


static func _outline(img: Image, color: Color) -> void:
	var src := img.duplicate() as Image
	var w := img.get_width()
	var h := img.get_height()
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.5:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and src.get_pixel(nx, ny).a > 0.5:
					img.set_pixel(x, y, color)
					break
