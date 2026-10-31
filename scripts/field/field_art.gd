class_name FieldArt
extends RefCounted
## Saha aşamasının piksel çizimleri: oyuncu (başkan), saha karakterleri, vatandaşlar, çöpler ve parçacıklar.
## Hepsi kodla çizilir ve önbelleğe alınır. Ölçüler karo boyutuyla (16 px) uyumlu.

const OUTLINE := Color(0.1, 0.07, 0.07)
const PLAYER_W := 16
const PLAYER_H := 20
const TRASH_KINDS := 3

## Figür paletleri. hat/mustache/scarf boşsa çizilmez. glasses: gözlük, bag: sırt çantası.
const PEOPLE := {
	# Başkan bilerek cinsiyetsiz: kapüşonlu yağmurluk, gaz maskesi, kapüşondan fidan filizi. hood: özel çizim.
	"player": {"skin": Color(0.87, 0.67, 0.5), "hair": Color(0.22, 0.15, 0.11), "jacket": Color(0.24, 0.5, 0.52),
		"pants": Color(0.24, 0.28, 0.42), "bag": true, "hood": true},
	"canan": {"skin": Color(0.74, 0.52, 0.38), "hair": Color(0.14, 0.1, 0.1), "jacket": Color(0.27, 0.55, 0.33),
		"pants": Color(0.2, 0.25, 0.3), "glasses": true, "long_hair": true},
	"riza": {"skin": Color(0.82, 0.64, 0.52), "hair": Color(0.82, 0.82, 0.8), "jacket": Color(0.46, 0.33, 0.22),
		"pants": Color(0.3, 0.28, 0.26), "hat": Color(0.42, 0.45, 0.4), "mustache": Color(0.85, 0.85, 0.82),
		"scarf": Color(0.72, 0.2, 0.2)},
	"hulusi": {"skin": Color(0.87, 0.66, 0.49), "hair": Color(0.2, 0.12, 0.08), "jacket": Color(0.96, 0.52, 0.1),
		"pants": Color(0.2, 0.2, 0.25), "hat": Color(0.98, 0.82, 0.18), "mustache": Color(0.2, 0.12, 0.08)},
	"peddler": {"skin": Color(0.8, 0.6, 0.45), "hair": Color(0.3, 0.2, 0.12), "jacket": Color(0.3, 0.45, 0.72),
		"pants": Color(0.4, 0.3, 0.2), "hat": Color(0.88, 0.76, 0.42), "bag": true},
	"v1": {"skin": Color(0.9, 0.72, 0.58), "hair": Color(0.45, 0.3, 0.15), "jacket": Color(0.82, 0.3, 0.3), "pants": Color(0.25, 0.25, 0.35)},
	"v2": {"skin": Color(0.62, 0.42, 0.3), "hair": Color(0.1, 0.08, 0.08), "jacket": Color(0.3, 0.5, 0.82), "pants": Color(0.3, 0.3, 0.28), "long_hair": true},
	"v3": {"skin": Color(0.78, 0.58, 0.42), "hair": Color(0.6, 0.5, 0.25), "jacket": Color(0.62, 0.38, 0.72), "pants": Color(0.22, 0.3, 0.28)},
	"logger": {"skin": Color(0.8, 0.6, 0.45), "hair": Color(0.2, 0.15, 0.1), "jacket": Color(0.72, 0.22, 0.2),
		"pants": Color(0.25, 0.3, 0.22), "hat": Color(0.25, 0.4, 0.25), "mustache": Color(0.25, 0.15, 0.1)},
	"pinar": {"skin": Color(0.8, 0.6, 0.45), "hair": Color(0.2, 0.12, 0.1), "jacket": Color(0.97, 0.78, 0.22),
		"pants": Color(0.25, 0.3, 0.5), "long_hair": true, "scale": 0.8},
	"veli": {"skin": Color(0.78, 0.6, 0.46), "hair": Color(0.92, 0.92, 0.9), "jacket": Color(0.36, 0.43, 0.56),
		"pants": Color(0.35, 0.3, 0.25), "hat": Color(0.46, 0.38, 0.3), "mustache": Color(0.92, 0.92, 0.9)},
	"kemal": {"skin": Color(0.75, 0.55, 0.4), "hair": Color(0.16, 0.1, 0.08), "jacket": Color(0.82, 0.3, 0.26),
		"pants": Color(0.25, 0.3, 0.4), "hat": Color(0.94, 0.94, 0.9), "mustache": Color(0.16, 0.1, 0.08)},
	"yigithan": {"skin": Color(0.88, 0.68, 0.5), "hair": Color(0.32, 0.2, 0.12), "jacket": Color(0.28, 0.5, 0.3),
		"pants": Color(0.4, 0.3, 0.2), "hat": Color(0.42, 0.48, 0.26), "bag": true},
	"v4": {"skin": Color(0.9, 0.7, 0.55), "hair": Color(0.2, 0.2, 0.22), "jacket": Color(0.9, 0.78, 0.3), "pants": Color(0.35, 0.25, 0.25), "hat": Color(0.85, 0.35, 0.3)},
}
const VILLAGER_STYLES: Array[String] = ["v1", "v2", "v3", "v4"]

static var _cache: Dictionary = {}


## Başkan. facing: 0 aşağı, 1 yukarı, 2 yan (sağa). step: 0 dururken, 1 sol bacak kalkık, 2 sağ bacak kalkık.
static func player(facing: int, step: int) -> ImageTexture:
	return person("player", facing, step)


## style: PEOPLE anahtarlarından biri.
static func person(style: String, facing: int, step: int) -> ImageTexture:
	var key := "person_%s_%d_%d" % [style, facing, step]
	if not _cache.has(key):
		var img := Image.create_empty(PLAYER_W, PLAYER_H, false, Image.FORMAT_RGBA8)
		_paint_person(img, PEOPLE.get(style, PEOPLE["player"]), facing, step)
		_outline(img)
		_cache[key] = ImageTexture.create_from_image(img)
	return _cache[key]


## kind: 0 poşet, 1 teneke, 2 şişe
static func trash(kind: int) -> ImageTexture:
	var key := "trash_%d" % kind
	if not _cache.has(key):
		var img := Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
		match kind:
			0:
				_ellipse(img, 8, 9.5, 5.2, 4.8, Color(0.2, 0.2, 0.24))
				_rect(img, 7, 3, 2, 3, Color(0.2, 0.2, 0.24))
				_rect(img, 5, 7, 2, 2, Color(0.5, 0.5, 0.56))
			1:
				_rect(img, 5, 5, 6, 8, Color(0.76, 0.79, 0.83))
				_rect(img, 5, 8, 6, 2, Color(0.82, 0.2, 0.2))
				_rect(img, 5, 4, 6, 1, Color(0.5, 0.52, 0.56))
				_rect(img, 6, 6, 1, 1, Color.WHITE)
			_:
				_rect(img, 6, 7, 4, 7, Color(0.3, 0.64, 0.42))
				_rect(img, 7, 3, 2, 4, Color(0.3, 0.64, 0.42))
				_rect(img, 7, 2, 2, 1, Color(0.85, 0.8, 0.25))
				_rect(img, 7, 8, 1, 3, Color(0.7, 0.92, 0.78))
		_outline(img)
		_cache[key] = ImageTexture.create_from_image(img)
	return _cache[key]


static func leaf() -> ImageTexture:
	if not _cache.has("leaf"):
		var img := Image.create_empty(9, 9, false, Image.FORMAT_RGBA8)
		_ellipse_rot(img, 4.5, 4.5, 3.8, 2.0, -0.7, Color(0.48, 0.82, 0.3))
		_line(img, 2, 6, 6, 2, Color(0.24, 0.55, 0.2))
		_outline(img)
		_cache["leaf"] = ImageTexture.create_from_image(img)
	return _cache["leaf"]


static func heart() -> ImageTexture:
	if not _cache.has("heart_small"):
		var img := Image.create_empty(9, 8, false, Image.FORMAT_RGBA8)
		var red := Color(0.95, 0.3, 0.38)
		_ellipse(img, 2.8, 2.8, 2.4, 2.4, red)
		_ellipse(img, 6.2, 2.8, 2.4, 2.4, red)
		for y in range(3, 8):
			var half := 4.5 - (y - 3) * 0.95
			for x in range(int(4.5 - half), int(4.5 + half) + 1):
				_px(img, x, y, red)
		_px(img, 2, 1, Color(1.0, 0.75, 0.78))
		_outline(img)
		_cache["heart_small"] = ImageTexture.create_from_image(img)
	return _cache["heart_small"]


static func puff() -> ImageTexture:
	if not _cache.has("puff"):
		var img := Image.create_empty(10, 10, false, Image.FORMAT_RGBA8)
		_ellipse(img, 5, 5, 4.4, 4.4, Color(0.3, 0.27, 0.25, 0.85))
		_ellipse(img, 4, 4, 2.2, 2.2, Color(0.42, 0.38, 0.35, 0.85))
		_cache["puff"] = ImageTexture.create_from_image(img)
	return _cache["puff"]


static func dust() -> ImageTexture:
	if not _cache.has("dust"):
		var img := Image.create_empty(6, 6, false, Image.FORMAT_RGBA8)
		_ellipse(img, 3, 3, 2.6, 2.6, Color(0.78, 0.7, 0.58, 0.8))
		_cache["dust"] = ImageTexture.create_from_image(img)
	return _cache["dust"]


static func sparkle() -> ImageTexture:
	if not _cache.has("sparkle"):
		var img := Image.create_empty(7, 7, false, Image.FORMAT_RGBA8)
		var c := Color(1.0, 0.95, 0.6)
		_rect(img, 3, 0, 1, 7, c)
		_rect(img, 0, 3, 7, 1, c)
		_rect(img, 2, 2, 3, 3, Color.WHITE)
		_cache["sparkle"] = ImageTexture.create_from_image(img)
	return _cache["sparkle"]


# ------------------------------------------------------------------ Figür çizimi

static func _paint_person(img: Image, p: Dictionary, facing: int, step: int) -> void:
	var skin: Color = p["skin"]
	var hair: Color = p["hair"]
	var jacket: Color = p["jacket"]
	var jacket_d := jacket.darkened(0.3)
	var pants: Color = p["pants"]
	var boot := Color(0.34, 0.21, 0.12)
	var bag := Color(0.62, 0.43, 0.22)
	var eye := Color(0.1, 0.07, 0.07)

	# Bacaklar ve botlar: yürürken bir bacak kısalır
	var left_h := 3 - (1 if step == 1 else 0)
	var right_h := 3 - (1 if step == 2 else 0)
	_rect(img, 5, 14, 2, left_h, pants)
	_rect(img, 5, 14 + left_h, 2, 2, boot)
	_rect(img, 9, 14, 2, right_h, pants)
	_rect(img, 9, 14 + right_h, 2, 2, boot)

	if p.get("hood", false):
		_paint_hooded(img, jacket, facing)
		return

	match facing:
		0:  # aşağı: yüz görünür
			_rect(img, 4, 8, 8, 6, jacket)
			_rect(img, 3, 9, 1, 4, jacket_d)
			_rect(img, 12, 9, 1, 4, jacket_d)
			_px(img, 3, 13, skin)
			_px(img, 12, 13, skin)
			if p.has("long_hair"):
				_rect(img, 4, 2, 8, 8, hair)
			_rect(img, 5, 1, 6, 3, hair)
			_rect(img, 5, 4, 6, 4, skin)
			_px(img, 4, 5, skin)
			_px(img, 11, 5, skin)
			_px(img, 6, 5, eye)
			_px(img, 9, 5, eye)
			if p.has("glasses"):
				for x in [5, 7, 8, 10]:
					_px(img, x, 5, Color(0.2, 0.7, 0.66))
				_px(img, 6, 4, Color(0.2, 0.7, 0.66))
				_px(img, 9, 4, Color(0.2, 0.7, 0.66))
			if p.has("mustache"):
				_rect(img, 6, 7, 4, 1, p["mustache"])
			if p.has("scarf"):
				_rect(img, 5, 8, 6, 2, p["scarf"])
		1:  # yukarı: ense, sırt çantası
			_rect(img, 4, 8, 8, 6, jacket)
			if p.get("bag", false):
				_rect(img, 5, 9, 6, 4, bag)
			_rect(img, 3, 9, 1, 4, jacket_d)
			_rect(img, 12, 9, 1, 4, jacket_d)
			_rect(img, 5, 1, 6, 7, hair)
			if p.has("long_hair"):
				_rect(img, 4, 2, 8, 8, hair)
		_:  # yan (sağa bakar)
			_rect(img, 5, 8, 6, 6, jacket)
			if p.get("bag", false):
				_rect(img, 3, 8, 3, 5, bag)
			_rect(img, 7, 9, 2, 4, jacket_d)
			_px(img, 8, 13, skin)
			_rect(img, 5, 1, 6, 3, hair)
			_rect(img, 5, 4, 2, 3, hair)
			_rect(img, 7, 4, 4, 4, skin)
			_px(img, 9, 5, eye)
			_px(img, 11, 6, skin)
			if p.has("mustache"):
				_rect(img, 9, 7, 3, 1, p["mustache"])
			if p.has("scarf"):
				_rect(img, 6, 8, 5, 2, p["scarf"])
	# Şapka: tüm yönlerde kafanın üstünde
	if p.has("hat"):
		var hat: Color = p["hat"]
		_rect(img, 4, 0, 8, 3, hat)
		_rect(img, 3, 3, 10, 1, hat.darkened(0.25))


## Cinsiyetsiz başkan: yağmurluk, kapüşon, gaz maskesi, kırmızı kuşak ve kapüşondan çıkan fidan.
static func _paint_hooded(img: Image, poncho: Color, facing: int) -> void:
	var poncho_l := poncho.lightened(0.3)
	var poncho_d := poncho.darkened(0.3)
	var sash := Color(0.86, 0.26, 0.26)
	var mask := Color(0.66, 0.68, 0.72)
	var mask_d := Color(0.42, 0.44, 0.5)
	var lens := Color(0.55, 0.95, 0.7)
	var shade := Color(0.08, 0.1, 0.12)
	var leaf := Color(0.5, 0.88, 0.35)
	var leaf_d := Color(0.25, 0.6, 0.22)
	var bag := Color(0.62, 0.43, 0.22)
	match facing:
		0:  # aşağı
			_rect(img, 3, 8, 10, 6, poncho)
			_rect(img, 3, 13, 10, 1, poncho_d)
			_line(img, 4, 8, 11, 13, sash)
			_line(img, 5, 8, 12, 13, sash)
			_ellipse(img, 8, 6, 5.5, 5, poncho_l)
			_ellipse(img, 8, 6.5, 4, 3.8, shade)
			_rect(img, 5, 5, 2, 2, lens)
			_rect(img, 9, 5, 2, 2, lens)
			_px(img, 5, 5, Color.WHITE)
			_px(img, 9, 5, Color.WHITE)
			_rect(img, 7, 6, 2, 1, mask_d)
			_rect(img, 6, 7, 4, 2, mask)
			_px(img, 7, 9, mask_d)
			_px(img, 8, 9, mask_d)
		1:  # yukarı: ense, sırt çantası
			_rect(img, 3, 8, 10, 6, poncho)
			_rect(img, 3, 13, 10, 1, poncho_d)
			_rect(img, 5, 9, 6, 4, bag)
			_line(img, 4, 8, 11, 13, sash)
			_ellipse(img, 8, 6, 5.5, 5, poncho_l)
			_rect(img, 6, 6, 4, 1, poncho)
			_rect(img, 7, 3, 2, 1, poncho)
		_:  # yan (sağa)
			_rect(img, 5, 8, 6, 6, poncho)
			_rect(img, 5, 13, 6, 1, poncho_d)
			_rect(img, 3, 8, 3, 5, bag)
			_line(img, 5, 8, 10, 13, sash)
			_ellipse(img, 7, 6, 4.5, 5, poncho_l)
			_rect(img, 8, 4, 3, 5, shade)
			_rect(img, 9, 5, 2, 2, lens)
			_px(img, 9, 5, Color.WHITE)
			_rect(img, 11, 6, 2, 3, mask)
			_px(img, 12, 8, mask_d)
	# Kapüşondan çıkan fidan
	_px(img, 8, 1, leaf_d)
	_px(img, 8, 0, leaf_d)
	_px(img, 7, 0, leaf)
	_px(img, 6, 1, leaf)
	_px(img, 9, 0, leaf)
	_px(img, 10, 1, leaf)


# ------------------------------------------------------------------ Yardımcılar

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


static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var steps := maxi(absi(x1 - x0), absi(y1 - y0))
	for i in steps + 1:
		var t := 0.0 if steps == 0 else float(i) / steps
		_px(img, roundi(lerpf(x0, x1, t)), roundi(lerpf(y0, y1, t)), c)


static func _outline(img: Image) -> void:
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
					img.set_pixel(x, y, OUTLINE)
					break
