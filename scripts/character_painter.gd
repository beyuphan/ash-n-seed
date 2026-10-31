class_name CharacterPainter
extends RefCounted
## Karakter portrelerini kodla piksel piksel çizer (48x56). Çıktı PNG'ye kaydedilir
## (tools/generate_characters.gd). Oyun PNG'leri yükler, yani bir sanatçı aynı adlarla
## dosyaları kendi çizimiyle değiştirebilir.
##
## Kareler: idle (gözler açık), blink (gözler kapalı), talk (ağız açık).

const W := 48
const H := 56
const OUTLINE := Color(0.09, 0.06, 0.07)
const IDS: Array[String] = ["hulusi", "riza", "canan", "event", "veli", "pinar", "kemal", "nezaket", "defne", "bruce", "mirmir", "yigithan"]


static func paint(id: String, blink: bool = false, talk: bool = false) -> Image:
	var img := Image.create_empty(W, H, false, Image.FORMAT_RGBA8)
	match id:
		"hulusi": _hulusi(img, blink, talk)
		"riza": _riza(img, blink, talk)
		"canan": _canan(img, blink, talk)
		"veli": _veli(img, blink, talk)
		"pinar": _pinar(img, blink, talk)
		"kemal": _kemal(img, blink, talk)
		"nezaket": _nezaket(img, blink, talk)
		"defne": _defne(img, blink, talk)
		"bruce": _bruce(img, blink, talk)
		"mirmir": _mirmir(img, blink, talk)
		"yigithan": _yigithan(img, blink, talk)
		_: _event(img, blink, talk)
	_outline(img)
	return img


# ---------------------------------------------------------------- Hulusi

static func _hulusi(img: Image, blink: bool, talk: bool) -> void:
	var skin := Color(0.87, 0.66, 0.49)
	var skin_d := Color(0.72, 0.5, 0.36)
	var vest := Color(0.96, 0.52, 0.1)
	var vest_d := Color(0.78, 0.38, 0.06)
	var shirt := Color(0.93, 0.92, 0.88)
	var hat := Color(0.98, 0.82, 0.18)
	var hat_d := Color(0.8, 0.62, 0.1)
	var mus := Color(0.2, 0.12, 0.08)
	var silver := Color(0.86, 0.86, 0.8)
	var gold := Color(0.97, 0.8, 0.25)

	# Gövde: gömlek, turuncu yelek, yansıtıcı şeritler
	_ellipse(img, 24, 58, 22, 22, shirt)
	_ellipse(img, 24, 60, 18, 23, vest)
	_rect(img, 35, 42, 6, 14, vest_d)
	for row in 12:
		var half := int(6.0 - row * 0.5)
		_rect(img, 24 - half, 36 + row, half * 2, 1, shirt)
	_rect(img, 12, 40, 3, 16, silver)
	_rect(img, 33, 40, 3, 16, silver)
	# Boyun ve altın zincir
	_rect(img, 20, 28, 8, 8, skin_d)
	for p in [Vector2i(20, 36), Vector2i(21, 37), Vector2i(22, 38), Vector2i(23, 38), Vector2i(24, 38),
			Vector2i(25, 38), Vector2i(26, 38), Vector2i(27, 37), Vector2i(28, 36)]:
		_px(img, p.x, p.y, gold)
	# Elinde para destesi
	_rect(img, 36, 43, 9, 5, Color(0.35, 0.65, 0.35))
	_rect(img, 36, 45, 9, 1, Color(0.6, 0.85, 0.55))
	_ellipse(img, 40, 50, 4.5, 3.5, skin)
	# Kafa
	_ellipse(img, 12.5, 22, 2, 3, skin_d)
	_ellipse(img, 35.5, 22, 2, 3, skin_d)
	_ellipse(img, 24, 21, 11, 10, skin)
	# Baret
	_dome(img, 24, 15, 12, 9, hat)
	_rect(img, 22, 6, 4, 9, Color(1.0, 0.92, 0.45))
	_rect(img, 11, 14, 26, 3, hat_d)
	_rect(img, 10, 15, 28, 2, hat_d)
	# Yüz
	_rect(img, 17, 18, 5, 1, mus)
	_rect(img, 27, 18, 5, 1, mus)
	if blink:
		_rect(img, 18, 21, 3, 1, skin_d)
		_rect(img, 28, 21, 3, 1, skin_d)
	else:
		_rect(img, 19, 20, 2, 2, Color(0.1, 0.07, 0.07))
		_rect(img, 28, 20, 2, 2, Color(0.1, 0.07, 0.07))
	_rect(img, 23, 21, 3, 4, skin_d)
	_ellipse(img, 24, 26, 8.5, 2.6, mus)
	if talk:
		_rect(img, 21, 28, 7, 3, Color(0.35, 0.08, 0.08))
		_rect(img, 23, 30, 3, 1, Color(0.8, 0.3, 0.3))
	else:
		_rect(img, 21, 29, 7, 1, Color(0.55, 0.22, 0.2))


# ---------------------------------------------------------------- Rıza

static func _riza(img: Image, blink: bool, talk: bool) -> void:
	var coat := Color(0.46, 0.33, 0.22)
	var coat_d := Color(0.32, 0.22, 0.15)
	var scarf := Color(0.72, 0.2, 0.2)
	var scarf_d := Color(0.5, 0.12, 0.14)
	var cream := Color(0.9, 0.85, 0.7)
	var skin := Color(0.82, 0.64, 0.52)
	var skin_d := Color(0.66, 0.48, 0.38)
	var cap := Color(0.42, 0.45, 0.4)
	var cap_d := Color(0.28, 0.31, 0.27)
	var grey := Color(0.82, 0.82, 0.8)
	var grey_d := Color(0.4, 0.4, 0.4)
	var rose := Color(0.9, 0.5, 0.48)

	# Palto
	_ellipse(img, 24, 60, 19, 24, coat)
	_line(img, 18, 40, 21, 56, coat_d)
	_line(img, 30, 40, 27, 56, coat_d)
	for y in [44, 49, 54]:
		_px(img, 24, y, coat_d)
	# Havaya kalkmış yumruk
	_rect(img, 37, 36, 6, 18, coat)
	_rect(img, 37, 36, 1, 18, coat_d)
	_ellipse(img, 40, 32, 3.6, 3.6, skin)
	_rect(img, 38, 31, 5, 1, skin_d)
	# Atkı (sarkan ucu dahil)
	_ellipse(img, 24, 34, 10, 5, scarf)
	_rect(img, 27, 36, 5, 13, scarf)
	for y in [38, 42, 46]:
		_rect(img, 27, y, 5, 1, cream)
	_rect(img, 14, 35, 20, 1, scarf_d)
	# Kafa
	_ellipse(img, 14.5, 21, 2, 3, skin_d)
	_ellipse(img, 33.5, 21, 2, 3, skin_d)
	_ellipse(img, 24, 20, 9, 10, skin)
	_rect(img, 13, 16, 2, 6, grey)
	_rect(img, 33, 16, 2, 6, grey)
	# Kasket
	_dome(img, 24, 15, 11, 7, cap)
	_rect(img, 13, 14, 22, 2, cap_d)
	_rect(img, 14, 15, 16, 2, cap_d)
	_px(img, 24, 8, cap_d)
	# Yüz: üşümüş yanaklar, kızaran burun, kızgın kaşlar
	_ellipse(img, 18, 24, 2, 1.5, rose)
	_ellipse(img, 30, 24, 2, 1.5, rose)
	_ellipse(img, 24, 23, 2, 2, Color(0.85, 0.4, 0.38))
	if blink:
		_rect(img, 18, 20, 3, 1, skin_d)
		_rect(img, 28, 20, 3, 1, skin_d)
	else:
		_rect(img, 18, 19, 3, 2, Color.WHITE)
		_rect(img, 28, 19, 3, 2, Color.WHITE)
		_px(img, 19, 20, Color(0.1, 0.07, 0.07))
		_px(img, 29, 20, Color(0.1, 0.07, 0.07))
	for p in [Vector2i(17, 17), Vector2i(18, 17), Vector2i(19, 18), Vector2i(20, 18),
			Vector2i(31, 17), Vector2i(30, 17), Vector2i(29, 18), Vector2i(28, 18)]:
		_px(img, p.x, p.y, grey_d)
	_ellipse(img, 24, 25.5, 8, 2, grey)
	_px(img, 15, 27, grey)
	_px(img, 33, 27, grey)
	if talk:
		_ellipse(img, 24, 29, 3.2, 2.6, Color(0.35, 0.08, 0.08))
	else:
		_rect(img, 22, 29, 5, 1, Color(0.4, 0.15, 0.15))


# ---------------------------------------------------------------- Canan

static func _canan(img: Image, blink: bool, talk: bool) -> void:
	var jacket := Color(0.27, 0.52, 0.32)
	var jacket_d := Color(0.17, 0.36, 0.23)
	var collar := Color(0.45, 0.72, 0.42)
	var shirt := Color(0.94, 0.9, 0.78)
	var skin := Color(0.74, 0.52, 0.38)
	var skin_d := Color(0.6, 0.4, 0.3)
	var hair := Color(0.14, 0.1, 0.1)
	var hair_l := Color(0.3, 0.22, 0.2)
	var glass := Color(0.2, 0.66, 0.62)
	var pot := Color(0.78, 0.42, 0.28)
	var pot_l := Color(0.9, 0.55, 0.38)
	var leaf := Color(0.5, 0.84, 0.42)
	var leaf_d := Color(0.28, 0.6, 0.28)

	# Gövde: yeşil mont, krem gömlek, yaka, yaprak rozeti
	_ellipse(img, 24, 60, 19, 24, jacket)
	for row in 10:
		var half := int(4.5 - row * 0.4)
		_rect(img, 24 - half, 36 + row, half * 2, 1, shirt)
	_rect(img, 24, 46, 1, 10, jacket_d)
	_rect(img, 16, 35, 6, 4, collar)
	_rect(img, 27, 35, 6, 4, collar)
	_ellipse(img, 14, 44, 2.2, 1.6, leaf)
	_px(img, 14, 46, leaf_d)
	# Boyun
	_rect(img, 21, 29, 6, 8, skin_d)
	# Elinde fidan saksısı
	_rect(img, 40, 40, 1, 9, leaf_d)
	_ellipse(img, 37, 42, 3, 1.8, leaf)
	_ellipse(img, 43, 40, 3, 1.8, leaf)
	_ellipse(img, 40, 37, 1.8, 3, leaf)
	_rect(img, 34, 48, 12, 2, pot_l)
	_rect(img, 35, 50, 10, 6, pot)
	# Saç (arka), yüz, perde
	_ellipse(img, 24, 21, 12, 11, hair)
	_ellipse(img, 24, 21, 8, 9, skin)
	_dome(img, 24, 16, 10, 5, hair)
	_rect(img, 19, 11, 6, 1, hair_l)
	_rect(img, 13, 22, 3, 9, hair)
	_rect(img, 32, 22, 3, 9, hair)
	# Gözlük
	_ring(img, 20, 20, 2.3, 3.5, glass)
	_ring(img, 28, 20, 2.3, 3.5, glass)
	_rect(img, 23, 19, 2, 1, glass)
	if blink:
		_rect(img, 19, 20, 3, 1, skin_d)
		_rect(img, 27, 20, 3, 1, skin_d)
	else:
		_rect(img, 20, 19, 1, 2, Color(0.1, 0.07, 0.07))
		_rect(img, 28, 19, 1, 2, Color(0.1, 0.07, 0.07))
	_px(img, 17, 24, Color(0.9, 0.5, 0.45))
	_px(img, 31, 24, Color(0.9, 0.5, 0.45))
	if talk:
		_ellipse(img, 24, 27, 2.5, 2, Color(0.4, 0.1, 0.1))
	else:
		for p in [Vector2i(22, 26), Vector2i(23, 27), Vector2i(24, 27), Vector2i(25, 27), Vector2i(26, 26)]:
			_px(img, p.x, p.y, Color(0.5, 0.18, 0.18))


# ---------------------------------------------------------------- Dede Veli (yaşlı değirmenci)

static func _veli(img: Image, blink: bool, talk: bool) -> void:
	var sweater := Color(0.36, 0.43, 0.56)
	var sweater_d := Color(0.24, 0.3, 0.42)
	var skin := Color(0.78, 0.6, 0.46)
	var skin_d := Color(0.62, 0.46, 0.35)
	var beard := Color(0.93, 0.93, 0.9)
	var beard_d := Color(0.7, 0.7, 0.68)
	var cap := Color(0.46, 0.38, 0.3)
	var cap_d := Color(0.3, 0.24, 0.18)
	var rose := Color(0.88, 0.52, 0.46)
	# Gövde: örgü kazak
	_ellipse(img, 24, 60, 19, 24, sweater)
	for y in [42, 46, 50, 54]:
		_rect(img, 12, y, 24, 1, sweater_d)
	_rect(img, 20, 34, 8, 5, sweater_d)
	# Elinde olta
	_line(img, 38, 50, 44, 30, Color(0.55, 0.38, 0.2))
	_line(img, 44, 30, 44, 38, Color(0.85, 0.85, 0.85))
	_rect(img, 43, 38, 3, 3, Color(0.9, 0.25, 0.25))
	_rect(img, 43, 39, 3, 1, Color.WHITE)
	_ellipse(img, 37, 50, 3.5, 3, skin)
	# Kafa
	_ellipse(img, 14.5, 21, 2, 3, skin_d)
	_ellipse(img, 33.5, 21, 2, 3, skin_d)
	_ellipse(img, 24, 20, 9, 10, skin)
	# Gür beyaz sakal
	_ellipse(img, 24, 28, 9.5, 7, beard)
	_ellipse(img, 24, 25, 7, 2.5, skin)
	_rect(img, 16, 25, 4, 4, beard)
	_rect(img, 28, 25, 4, 4, beard)
	_rect(img, 18, 31, 12, 2, beard_d)
	# Bıyık
	_ellipse(img, 24, 25.5, 6.5, 1.8, beard)
	# Kasket
	_dome(img, 24, 14, 11, 7, cap)
	_rect(img, 12, 13, 24, 2, cap_d)
	_rect(img, 13, 14, 15, 2, cap_d)
	# Yüz: kırışıklıklar, yanaklar
	_ellipse(img, 17, 23, 1.8, 1.2, rose)
	_ellipse(img, 31, 23, 1.8, 1.2, rose)
	_rect(img, 17, 15, 3, 1, skin_d)
	_rect(img, 28, 15, 3, 1, skin_d)
	if blink:
		_rect(img, 18, 19, 3, 1, skin_d)
		_rect(img, 27, 19, 3, 1, skin_d)
	else:
		_rect(img, 18, 18, 3, 2, Color.WHITE)
		_rect(img, 27, 18, 3, 2, Color.WHITE)
		_px(img, 19, 19, Color(0.12, 0.09, 0.08))
		_px(img, 28, 19, Color(0.12, 0.09, 0.08))
	_rect(img, 17, 17, 4, 1, beard_d)
	_rect(img, 27, 17, 4, 1, beard_d)
	if talk:
		_ellipse(img, 24, 28, 2.6, 2.0, Color(0.35, 0.08, 0.08))
	else:
		_rect(img, 22, 28, 5, 1, Color(0.5, 0.2, 0.18))


# ---------------------------------------------------------------- Pınar (çocuk)

static func _pinar(img: Image, blink: bool, talk: bool) -> void:
	var coat := Color(0.97, 0.78, 0.22)
	var coat_d := Color(0.8, 0.6, 0.12)
	var skin := Color(0.8, 0.6, 0.45)
	var skin_d := Color(0.66, 0.47, 0.34)
	var hair := Color(0.2, 0.12, 0.1)
	var hair_l := Color(0.38, 0.24, 0.2)
	var bow := Color(0.9, 0.3, 0.4)
	var rose := Color(0.95, 0.5, 0.48)
	# Gövde: sarı yağmurluk
	_ellipse(img, 24, 62, 15, 22, coat)
	_rect(img, 24, 42, 1, 14, coat_d)
	_rect(img, 20, 44, 2, 2, coat_d)
	_rect(img, 27, 44, 2, 2, coat_d)
	# Elinde rüzgâr gülü
	_rect(img, 38, 38, 1, 14, Color(0.7, 0.5, 0.3))
	_rect(img, 34, 33, 5, 5, Color(0.9, 0.3, 0.35))
	_rect(img, 39, 33, 5, 5, Color(0.3, 0.6, 0.9))
	_rect(img, 34, 38, 5, 4, Color(0.3, 0.75, 0.4))
	_rect(img, 39, 38, 5, 4, Color(1.0, 0.85, 0.3))
	_ellipse(img, 36, 50, 3.2, 3, skin)
	# Büyük yuvarlak kafa ve iki kuyruk
	_ellipse(img, 9, 24, 4, 6, hair)
	_ellipse(img, 39, 24, 4, 6, hair)
	_rect(img, 8, 22, 4, 3, bow)
	_rect(img, 36, 22, 4, 3, bow)
	_ellipse(img, 24, 21, 12, 12, skin)
	_dome(img, 24, 17, 12.5, 11, hair)
	_rect(img, 14, 14, 20, 2, hair_l)
	_rect(img, 12, 16, 3, 8, hair)
	_rect(img, 33, 16, 3, 8, hair)
	# Yüz: iri gözler, yanaklar, kayıp diş
	_ellipse(img, 16.5, 26, 2.2, 1.5, rose)
	_ellipse(img, 31.5, 26, 2.2, 1.5, rose)
	if blink:
		_rect(img, 17, 22, 4, 1, skin_d)
		_rect(img, 28, 22, 4, 1, skin_d)
	else:
		_rect(img, 17, 20, 4, 5, Color.WHITE)
		_rect(img, 28, 20, 4, 5, Color.WHITE)
		_rect(img, 18, 21, 3, 4, Color(0.15, 0.1, 0.08))
		_rect(img, 29, 21, 3, 4, Color(0.15, 0.1, 0.08))
		_px(img, 18, 21, Color.WHITE)
		_px(img, 29, 21, Color.WHITE)
	if talk:
		_ellipse(img, 24, 29, 3.2, 2.4, Color(0.4, 0.1, 0.1))
		_rect(img, 22, 27, 2, 2, Color.WHITE)
	else:
		_rect(img, 21, 29, 7, 1, Color(0.55, 0.2, 0.2))
		_rect(img, 22, 30, 5, 1, Color(0.55, 0.2, 0.2))
		_rect(img, 23, 29, 2, 2, Color.WHITE)


# ---------------------------------------------------------------- Usta Kemal (fabrika ustabaşı)

static func _kemal(img: Image, blink: bool, talk: bool) -> void:
	var overalls := Color(0.33, 0.4, 0.52)
	var overalls_d := Color(0.22, 0.28, 0.38)
	var shirt := Color(0.82, 0.3, 0.26)
	var skin := Color(0.75, 0.55, 0.4)
	var skin_d := Color(0.6, 0.42, 0.3)
	var hat := Color(0.94, 0.94, 0.9)
	var hat_d := Color(0.72, 0.72, 0.7)
	var mus := Color(0.16, 0.1, 0.08)
	var stubble := Color(0.45, 0.33, 0.26)
	# Gövde: geniş omuzlar, tulum, kırmızı gömlek
	_ellipse(img, 24, 62, 23, 24, shirt)
	_ellipse(img, 24, 64, 14, 24, overalls)
	_rect(img, 14, 40, 4, 16, overalls_d)
	_rect(img, 30, 40, 4, 16, overalls_d)
	_rect(img, 15, 41, 3, 3, Color(0.85, 0.75, 0.3))
	_rect(img, 31, 41, 3, 3, Color(0.85, 0.75, 0.3))
	# Elinde İngiliz anahtarı
	_rect(img, 39, 36, 3, 16, Color(0.6, 0.62, 0.66))
	_rect(img, 37, 32, 7, 5, Color(0.6, 0.62, 0.66))
	_rect(img, 39, 33, 3, 3, Color(0.2, 0.2, 0.24))
	_ellipse(img, 40, 52, 3.5, 3, skin)
	# Kafa
	_ellipse(img, 13, 22, 2, 3, skin_d)
	_ellipse(img, 35, 22, 2, 3, skin_d)
	_ellipse(img, 24, 21, 11, 10.5, skin)
	# Baret
	_dome(img, 24, 15, 12, 9, hat)
	_rect(img, 11, 14, 26, 3, hat_d)
	_rect(img, 22, 7, 4, 8, hat_d)
	# Kalın kaşlar, sakal gölgesi, gür bıyık
	_rect(img, 16, 18, 6, 2, mus)
	_rect(img, 26, 18, 6, 2, mus)
	_ellipse(img, 24, 28, 9, 5, stubble)
	_ellipse(img, 24, 24, 5, 3, skin)
	if blink:
		_rect(img, 17, 21, 4, 1, skin_d)
		_rect(img, 27, 21, 4, 1, skin_d)
	else:
		_rect(img, 17, 20, 4, 3, Color.WHITE)
		_rect(img, 27, 20, 4, 3, Color.WHITE)
		_rect(img, 18, 21, 2, 2, Color(0.12, 0.09, 0.08))
		_rect(img, 28, 21, 2, 2, Color(0.12, 0.09, 0.08))
	_rect(img, 23, 22, 3, 4, skin_d)
	_ellipse(img, 24, 26.5, 8.5, 2.8, mus)
	if talk:
		_rect(img, 21, 29, 7, 3, Color(0.35, 0.08, 0.08))
	else:
		_rect(img, 21, 30, 7, 1, Color(0.4, 0.15, 0.13))


# ---------------------------------------------------------------- Nezaket Teyze (börek, dedikodu, dert)

static func _nezaket(img: Image, blink: bool, talk: bool) -> void:
	var cardigan := Color(0.62, 0.45, 0.7)
	var cardigan_d := Color(0.45, 0.3, 0.55)
	var collar := Color(0.95, 0.92, 0.85)
	var scarf := Color(0.86, 0.35, 0.46)
	var scarf_d := Color(0.62, 0.2, 0.32)
	var skin := Color(0.86, 0.68, 0.56)
	var skin_d := Color(0.7, 0.52, 0.42)
	var rose := Color(0.95, 0.5, 0.5)
	var plate := Color(0.85, 0.86, 0.88)
	var crust := Color(0.93, 0.68, 0.28)
	var crust_d := Color(0.78, 0.5, 0.18)
	# Gövde: hırka, düğmeler, yaka
	_ellipse(img, 24, 60, 20, 24, cardigan)
	_rect(img, 24, 40, 1, 16, cardigan_d)
	for y in [44, 49, 54]:
		_px(img, 22, y, collar)
		_px(img, 27, y, collar)
	_rect(img, 17, 35, 14, 3, collar)
	# Elinde börek tepsisi
	_ellipse(img, 39, 46, 7, 2.2, plate)
	_ellipse(img, 39, 43.5, 5.5, 2.4, crust)
	_rect(img, 35, 42, 8, 1, crust_d)
	_rect(img, 37, 44, 3, 1, crust_d)
	_ellipse(img, 33, 48, 3, 2.6, skin)
	# Başörtüsü (arka), yüz, örtünün üstü ve çene altı düğümü
	_ellipse(img, 24, 21, 14, 14, scarf)
	_ellipse(img, 24, 22.5, 9, 10, skin)
	_dome(img, 24, 15, 13.5, 9, scarf)
	_rect(img, 14, 24, 3, 10, scarf)
	_rect(img, 31, 24, 3, 10, scarf)
	_rect(img, 17, 31, 14, 3, scarf_d)
	_ellipse(img, 24, 33, 3.5, 2.5, scarf_d)
	for p in [Vector2i(18, 9), Vector2i(24, 7), Vector2i(30, 9), Vector2i(21, 12), Vector2i(27, 12), Vector2i(15, 15), Vector2i(33, 15), Vector2i(16, 26), Vector2i(32, 26), Vector2i(15, 31), Vector2i(33, 31)]:
		_px(img, p.x, p.y, Color(0.98, 0.88, 0.9))
	# Yüz: gözlük, yanak, gülümseme
	_px(img, 15, 20, Color(0.78, 0.78, 0.76))
	_px(img, 33, 20, Color(0.78, 0.78, 0.76))
	_ring(img, 20, 20, 2.0, 3.1, Color(0.5, 0.35, 0.22))
	_ring(img, 28, 20, 2.0, 3.1, Color(0.5, 0.35, 0.22))
	_rect(img, 23, 19, 2, 1, Color(0.5, 0.35, 0.22))
	if blink:
		_rect(img, 19, 20, 3, 1, skin_d)
		_rect(img, 27, 20, 3, 1, skin_d)
	else:
		_rect(img, 20, 19, 2, 2, Color(0.15, 0.1, 0.1))
		_rect(img, 28, 19, 2, 2, Color(0.15, 0.1, 0.1))
	_rect(img, 18, 16, 4, 1, Color(0.7, 0.7, 0.7))
	_rect(img, 27, 16, 4, 1, Color(0.7, 0.7, 0.7))
	_ellipse(img, 17.5, 25, 2, 1.4, rose)
	_ellipse(img, 31.5, 25, 2, 1.4, rose)
	_rect(img, 23, 23, 3, 2, skin_d)
	if talk:
		_ellipse(img, 24, 29, 3.2, 2.2, Color(0.4, 0.1, 0.1))
	else:
		for p in [Vector2i(20, 28), Vector2i(21, 29), Vector2i(22, 29), Vector2i(23, 29), Vector2i(24, 29), Vector2i(25, 29), Vector2i(26, 29), Vector2i(27, 29), Vector2i(28, 28)]:
			_px(img, p.x, p.y, Color(0.55, 0.2, 0.2))


# ---------------------------------------------------------------- Gazeteci Defne

static func _defne(img: Image, blink: bool, talk: bool) -> void:
	var blazer := Color(0.55, 0.16, 0.26)
	var blazer_d := Color(0.38, 0.1, 0.18)
	var shirt := Color(0.95, 0.94, 0.9)
	var skin := Color(0.78, 0.58, 0.44)
	var skin_d := Color(0.62, 0.44, 0.34)
	var hair := Color(0.1, 0.08, 0.12)
	var hair_l := Color(0.28, 0.24, 0.34)
	var paper := Color(0.96, 0.93, 0.8)
	var rose := Color(0.9, 0.45, 0.45)
	# Gövde: bordo blazer, beyaz gömlek, basın kartı
	_ellipse(img, 24, 60, 19, 24, blazer)
	for row in 10:
		var half := int(5.0 - row * 0.4)
		_rect(img, 24 - half, 36 + row, half * 2, 1, shirt)
	_rect(img, 24, 46, 1, 10, blazer_d)
	_rect(img, 14, 44, 7, 5, Color(0.95, 0.95, 0.95))
	_rect(img, 15, 45, 3, 1, Color(0.85, 0.2, 0.2))
	_rect(img, 15, 47, 5, 1, Color(0.5, 0.5, 0.5))
	# Elinde defter ve kalem
	_rect(img, 34, 40, 11, 14, paper)
	_rect(img, 34, 40, 2, 14, Color(0.3, 0.3, 0.34))
	for y in [43, 46, 49]:
		_rect(img, 37, y, 6, 1, Color(0.6, 0.6, 0.7))
	_line(img, 44, 38, 40, 50, Color(0.15, 0.15, 0.2))
	_ellipse(img, 36, 53, 3.4, 2.6, skin)
	# Saç (kâhkül ve küt kesim), yüz
	_ellipse(img, 24, 21, 13, 12, hair)
	_rect(img, 12, 21, 4, 11, hair)
	_rect(img, 32, 21, 4, 11, hair)
	_ellipse(img, 24, 22, 9, 10, skin)
	_dome(img, 24, 15, 13, 8, hair)
	_rect(img, 15, 14, 18, 3, hair)
	_rect(img, 19, 9, 6, 1, hair_l)
	_px(img, 17, 17, hair)
	_px(img, 30, 17, hair)
	# Yüz: bir kaşı havada, merak dolu gözler
	_rect(img, 17, 18, 5, 1, hair)
	_rect(img, 27, 16, 5, 1, hair)
	if blink:
		_rect(img, 18, 21, 4, 1, skin_d)
		_rect(img, 27, 21, 4, 1, skin_d)
	else:
		_rect(img, 18, 20, 4, 3, Color.WHITE)
		_rect(img, 27, 20, 4, 3, Color.WHITE)
		_rect(img, 19, 20, 2, 3, Color(0.1, 0.08, 0.08))
		_rect(img, 28, 20, 2, 3, Color(0.1, 0.08, 0.08))
		_px(img, 19, 20, Color.WHITE)
		_px(img, 28, 20, Color.WHITE)
	_ellipse(img, 17.5, 26, 1.8, 1.2, rose)
	_ellipse(img, 31.5, 26, 1.8, 1.2, rose)
	if talk:
		_ellipse(img, 25, 29, 3, 2.4, Color(0.45, 0.1, 0.12))
	else:
		_rect(img, 21, 29, 6, 1, Color(0.7, 0.2, 0.22))
		_px(img, 27, 28, Color(0.7, 0.2, 0.22))


# ---------------------------------------------------------------- Bay Bruce (yabancı yatırımcı)

static func _bruce(img: Image, blink: bool, talk: bool) -> void:
	var shirt := Color(0.18, 0.66, 0.72)
	var shirt_d := Color(0.1, 0.45, 0.52)
	var skin := Color(0.93, 0.68, 0.52)
	var skin_d := Color(0.78, 0.5, 0.38)
	var hat := Color(0.95, 0.9, 0.7)
	var hat_d := Color(0.78, 0.72, 0.5)
	var band := Color(0.2, 0.16, 0.14)
	var mus := Color(0.85, 0.7, 0.3)
	var gold := Color(0.97, 0.8, 0.25)
	# Gövde: çiçekli gömlek
	_ellipse(img, 24, 60, 21, 24, shirt)
	for p in [Vector2i(14, 44), Vector2i(20, 50), Vector2i(30, 46), Vector2i(34, 53), Vector2i(26, 56), Vector2i(16, 54)]:
		_rect(img, p.x, p.y, 3, 3, Color(0.98, 0.5, 0.65))
		_px(img, p.x + 1, p.y + 1, Color(1.0, 0.9, 0.3))
	_rect(img, 22, 38, 4, 18, shirt_d)
	# Altın zincir
	for p in [Vector2i(18, 36), Vector2i(19, 38), Vector2i(21, 40), Vector2i(24, 41), Vector2i(27, 40), Vector2i(29, 38), Vector2i(30, 36)]:
		_px(img, p.x, p.y, gold)
	# Elinde poster tüpü
	_rect(img, 37, 36, 6, 18, Color(0.95, 0.92, 0.82))
	_rect(img, 37, 36, 6, 2, Color(0.4, 0.75, 0.4))
	_rect(img, 39, 42, 2, 6, Color(0.3, 0.6, 0.3))
	_ellipse(img, 40, 54, 3.5, 3, skin)
	# Kafa
	_ellipse(img, 13, 22, 2, 3, skin_d)
	_ellipse(img, 35, 22, 2, 3, skin_d)
	_ellipse(img, 24, 22, 11, 10.5, skin)
	# Panama şapka
	_dome(img, 24, 15, 11, 8, hat)
	_rect(img, 13, 14, 22, 2, band)
	_rect(img, 6, 15, 36, 3, hat)
	_rect(img, 6, 17, 36, 1, hat_d)
	_rect(img, 16, 9, 16, 1, hat_d)
	# Güneş gözlüğü
	_rect(img, 14, 19, 9, 4, Color(0.08, 0.08, 0.1))
	_rect(img, 25, 19, 9, 4, Color(0.08, 0.08, 0.1))
	_rect(img, 23, 20, 2, 1, Color(0.08, 0.08, 0.1))
	_rect(img, 15, 19, 3, 1, Color(0.5, 0.6, 0.7))
	_rect(img, 26, 19, 3, 1, Color(0.5, 0.6, 0.7))
	if blink:
		_rect(img, 14, 21, 9, 1, Color(0.3, 0.3, 0.35))
		_rect(img, 25, 21, 9, 1, Color(0.3, 0.3, 0.35))
	# Bıyık ve kocaman gülümseme
	_ellipse(img, 24, 26, 6.5, 1.8, mus)
	if talk:
		_ellipse(img, 24, 30, 5, 3, Color(0.35, 0.08, 0.08))
		_rect(img, 20, 28, 9, 2, Color.WHITE)
	else:
		_ellipse(img, 24, 29.5, 6, 2.4, Color.WHITE)
		_rect(img, 18, 29, 12, 1, Color(0.7, 0.55, 0.5))


# ---------------------------------------------------------------- Mırmır (Belediye Kedisi, Başkan Yardımcısı)

static func _mirmir(img: Image, blink: bool, talk: bool) -> void:
	var fur := Color(0.95, 0.6, 0.25)
	var fur_d := Color(0.78, 0.4, 0.14)
	var cream := Color(0.98, 0.92, 0.8)
	var pink := Color(0.95, 0.55, 0.6)
	var green := Color(0.5, 0.85, 0.35)
	var dark := Color(0.12, 0.08, 0.08)
	var red := Color(0.85, 0.2, 0.22)
	var gold := Color(0.97, 0.8, 0.25)
	# Gövde: küçük, krem göğüslü, kırmızı papyon, altın rozet
	_ellipse(img, 24, 62, 15, 17, fur)
	_ellipse(img, 24, 58, 7, 11, cream)
	_rect(img, 14, 47, 2, 6, fur_d)
	_rect(img, 32, 47, 2, 6, fur_d)
	_rect(img, 19, 42, 4, 5, red)
	_rect(img, 25, 42, 4, 5, red)
	_rect(img, 23, 43, 2, 3, Color(0.6, 0.12, 0.14))
	_ellipse(img, 34, 52, 2.3, 2.3, gold)
	_px(img, 34, 52, Color(0.7, 0.5, 0.1))
	# Kulaklar
	_poly(img, [Vector2(9, 18), Vector2(11, 6), Vector2(21, 13)], fur)
	_poly(img, [Vector2(39, 18), Vector2(37, 6), Vector2(27, 13)], fur)
	_poly(img, [Vector2(12, 15), Vector2(13, 9), Vector2(18, 13)], pink)
	_poly(img, [Vector2(36, 15), Vector2(35, 9), Vector2(30, 13)], pink)
	# Kafa
	_ellipse(img, 24, 27, 15, 13, fur)
	for x in [20, 24, 28]:
		_rect(img, x, 15, 1, 5, fur_d)
	_rect(img, 10, 25, 3, 1, fur_d)
	_rect(img, 35, 25, 3, 1, fur_d)
	_ellipse(img, 24, 33, 7.5, 5.5, cream)
	# Gözler
	if blink:
		_rect(img, 15, 25, 6, 1, dark)
		_rect(img, 27, 25, 6, 1, dark)
	else:
		_ellipse(img, 18, 25, 3.4, 3.8, green)
		_ellipse(img, 30, 25, 3.4, 3.8, green)
		_rect(img, 17, 22, 2, 7, dark)
		_rect(img, 29, 22, 2, 7, dark)
		_px(img, 16, 23, Color.WHITE)
		_px(img, 28, 23, Color.WHITE)
	# Burun, ağız, bıyıklar
	_poly(img, [Vector2(22, 30), Vector2(26, 30), Vector2(24, 33)], pink)
	if talk:
		_ellipse(img, 24, 36, 2.6, 2.4, Color(0.55, 0.12, 0.15))
		_rect(img, 23, 37, 3, 1, Color(0.95, 0.5, 0.55))
	else:
		_px(img, 22, 35, dark)
		_px(img, 23, 36, dark)
		_px(img, 24, 35, dark)
		_px(img, 25, 36, dark)
		_px(img, 26, 35, dark)
	for dy in [-1, 1]:
		_line(img, 15, 33 + dy, 6, 32 + dy * 3, dark)
		_line(img, 33, 33 + dy, 42, 32 + dy * 3, dark)


# ---------------------------------------------------------------- Yiğithan (orman bekçisi, ağaçların abisi, omzunda baykuş Gece)

static func _yigithan(img: Image, blink: bool, talk: bool) -> void:
	var flannel := Color(0.28, 0.5, 0.3)
	var flannel_d := Color(0.18, 0.34, 0.2)
	var cream := Color(0.95, 0.9, 0.78)
	var skin := Color(0.88, 0.68, 0.5)
	var skin_d := Color(0.72, 0.52, 0.38)
	var hair := Color(0.32, 0.2, 0.12)
	var hat := Color(0.42, 0.48, 0.26)
	var hat_d := Color(0.28, 0.33, 0.16)
	var band := Color(0.3, 0.2, 0.1)
	var fur := Color(0.58, 0.42, 0.26)
	var fur_l := Color(0.85, 0.74, 0.55)
	var rose := Color(0.95, 0.5, 0.45)
	# Gövde: kareli gömlek, açık yaka, meşe palamudu kolye
	_ellipse(img, 24, 60, 23, 24, flannel)
	for x in range(6, 44, 5):
		_rect(img, x, 38, 1, 18, flannel_d)
	for y in [42, 48, 54]:
		_rect(img, 4, y, 40, 1, flannel_d)
	for row in 9:
		var half := int(5.0 - row * 0.4)
		_rect(img, 24 - half, 35 + row, half * 2, 1, cream)
	_line(img, 18, 36, 24, 45, Color(0.45, 0.3, 0.15))
	_line(img, 30, 36, 24, 45, Color(0.45, 0.3, 0.15))
	_ellipse(img, 24, 47, 2.6, 3.2, Color(0.62, 0.4, 0.18))
	_rect(img, 22, 43, 5, 2, Color(0.4, 0.26, 0.12))
	# Omzundaki baykuş: Gece
	_ellipse(img, 39, 33, 5.5, 7, fur)
	_ellipse(img, 39, 36, 3.3, 4.2, fur_l)
	_px(img, 35, 26, fur)
	_px(img, 43, 26, fur)
	_px(img, 34, 27, fur)
	_px(img, 44, 27, fur)
	if blink:
		_rect(img, 35, 31, 3, 1, Color(0.1, 0.07, 0.05))
		_rect(img, 40, 31, 3, 1, Color(0.1, 0.07, 0.05))
	else:
		_ellipse(img, 36.5, 31, 2.2, 2.2, Color(1.0, 0.85, 0.25))
		_ellipse(img, 41.5, 31, 2.2, 2.2, Color(1.0, 0.85, 0.25))
		_rect(img, 36, 31, 1, 2, Color(0.08, 0.05, 0.04))
		_rect(img, 41, 31, 1, 2, Color(0.08, 0.05, 0.04))
	_rect(img, 39, 33, 1, 2, Color(0.95, 0.6, 0.15))
	# Boyun, kafa, kulaklar
	_rect(img, 20, 28, 8, 8, skin_d)
	_ellipse(img, 13.5, 22, 2, 3, skin_d)
	_ellipse(img, 34.5, 22, 2, 3, skin_d)
	_ellipse(img, 24, 22, 10.5, 10, skin)
	# Dağınık saç (şapkanın altından)
	_rect(img, 13, 16, 3, 7, hair)
	_rect(img, 32, 16, 3, 7, hair)
	_px(img, 12, 22, hair)
	_px(img, 35, 22, hair)
	# Bekçi şapkası: geniş kenar, bant, tüy
	_dome(img, 24, 14, 11, 8, hat)
	_rect(img, 8, 14, 32, 3, hat)
	_rect(img, 8, 16, 32, 1, hat_d)
	_rect(img, 13, 12, 22, 2, band)
	_line(img, 33, 12, 40, 6, Color(0.85, 0.25, 0.2))
	_line(img, 34, 12, 41, 7, Color(0.95, 0.9, 0.85))
	# Yüz: gür kaşlar, sıcak gözler, yanaklar, gür bir gülümseme, hafif sakal gölgesi
	_rect(img, 17, 18, 5, 2, hair)
	_rect(img, 26, 18, 5, 2, hair)
	if blink:
		_rect(img, 18, 21, 4, 1, skin_d)
		_rect(img, 27, 21, 4, 1, skin_d)
	else:
		_rect(img, 18, 20, 4, 3, Color.WHITE)
		_rect(img, 27, 20, 4, 3, Color.WHITE)
		_rect(img, 19, 20, 2, 3, Color(0.18, 0.1, 0.06))
		_rect(img, 28, 20, 2, 3, Color(0.18, 0.1, 0.06))
		_px(img, 19, 20, Color.WHITE)
		_px(img, 28, 20, Color.WHITE)
	_rect(img, 23, 22, 2, 3, skin_d)
	_ellipse(img, 16.5, 25.5, 2, 1.4, rose)
	_ellipse(img, 31.5, 25.5, 2, 1.4, rose)
	for p in [Vector2i(17, 29), Vector2i(19, 31), Vector2i(22, 32), Vector2i(26, 32), Vector2i(29, 31), Vector2i(31, 29), Vector2i(20, 28), Vector2i(28, 28)]:
		_px(img, p.x, p.y, Color(0.5, 0.36, 0.26))
	if talk:
		_ellipse(img, 24, 28, 4.2, 3, Color(0.4, 0.1, 0.1))
		_rect(img, 21, 26, 7, 2, Color.WHITE)
	else:
		_rect(img, 19, 27, 10, 3, Color.WHITE)
		_rect(img, 18, 26, 1, 1, Color(0.6, 0.3, 0.25))
		_rect(img, 29, 26, 1, 1, Color(0.6, 0.3, 0.25))
		_rect(img, 19, 30, 10, 1, Color(0.6, 0.3, 0.25))


# ---------------------------------------------------------------- Olay (siren)

static func _event(img: Image, blink: bool, talk: bool) -> void:
	var base := Color(0.35, 0.36, 0.4)
	var base_l := Color(0.55, 0.56, 0.6)
	var lit := Color(0.95, 0.2, 0.18)
	var dim := Color(0.55, 0.1, 0.1)
	var ray := Color(1.0, 0.85, 0.25)
	var dome := dim if blink else lit
	_rect(img, 10, 46, 28, 10, base)
	_rect(img, 12, 44, 24, 3, base_l)
	_dome(img, 24, 44, 11, 15, dome)
	_rect(img, 18, 33, 2, 7, Color(1.0, 0.7, 0.68) if not blink else Color(0.7, 0.3, 0.3))
	if not blink:
		var len := 5 if talk else 3
		_line(img, 24, 26 - len + 3, 24, 26, ray)
		_line(img, 11, 31, 11 - len, 28, ray)
		_line(img, 37, 31, 37 + len, 28, ray)
		_line(img, 8, 40, 8 - len, 40, ray)
		_line(img, 40, 40, 40 + len, 40, ray)


# ---------------------------------------------------------------- Çizim yardımcıları

static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < W and y < H:
		img.set_pixel(x, y, c)


static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for j in h:
		for i in w:
			_px(img, x + i, y + j, c)


static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				_px(img, x, y, c)


## Elipsin yalnızca cy çizgisinin üstü (kubbe).
static func _dome(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for y in range(int(cy - ry) - 1, int(cy) + 1):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				_px(img, x, y, c)


static func _ring(img: Image, cx: float, cy: float, r_in: float, r_out: float, c: Color) -> void:
	for y in range(int(cy - r_out) - 1, int(cy + r_out) + 2):
		for x in range(int(cx - r_out) - 1, int(cx + r_out) + 2):
			var d := Vector2(x + 0.5 - cx, y + 0.5 - cy).length()
			if d >= r_in and d <= r_out:
				_px(img, x, y, c)


## Üçgen/çokgen doldurma.
static func _poly(img: Image, pts: Array, c: Color) -> void:
	var packed := PackedVector2Array()
	for p in pts:
		packed.append(p)
	for y in H:
		for x in W:
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), packed):
				_px(img, x, y, c)


static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var steps := maxi(absi(x1 - x0), absi(y1 - y0))
	for i in steps + 1:
		var t := 0.0 if steps == 0 else float(i) / steps
		_px(img, roundi(lerpf(x0, x1, t)), roundi(lerpf(y0, y1, t)), c)


## Şeffaf pikselleri, dolu komşusu varsa koyu kenar çizgisine çevirir.
static func _outline(img: Image) -> void:
	var source := img.duplicate() as Image
	for y in H:
		for x in W:
			if source.get_pixel(x, y).a > 0.5:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < W and ny < H and source.get_pixel(nx, ny).a > 0.5:
					img.set_pixel(x, y, OUTLINE)
					break
