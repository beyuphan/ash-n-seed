class_name FieldLayout
extends RefCounted
## Karatepe'nin sabit yerleşimi (tohum 31, her oyunda aynı kasaba). 96x64 karo.
##
##  BATI (nehrin sol kıyısı)
##    Kuzeybatı:  Orman. Bekçi kulübesi, kamp ateşi, Yaşlı Meşe, eski değirmen.
##    Orta:       Pazar Meydanı (çarşı, çeşme, Belediye), Fidanlık (sera) ve Park (gölet).
##    Güneybatı:  Mahalle. Sokak boyunca evler, Okul, Çay Ocağı.
##  ORTA: Karasu nehri. Üç köprü, iskele.
##  DOĞU
##    Kuzeydoğu:  Karatepe Çelik. Taş kapı, Genel Müdürlük, fabrikalar, demiryolu, lojmanlar, sendika barakası.
##    Güney:      Tarım Ovası. Çiftlik evi, ahır, çitli tarlalar, arılık.
##    Güneydoğu:  Çöplük. Bekçi kulübesi, çöp tepeleri ve en arkada gömülü Tohum Bankası.
##
## Yeni bir yapı için: konumu bu dosyada değiştir, landmark ekle (adı strings.csv'de LM_<ID>).

const Zone := FieldMap.Zone

const RIVER_POINTS := [
	Vector2(36, 0), Vector2(38, 8), Vector2(40, 16), Vector2(42, 24), Vector2(41, 32),
	Vector2(40, 40), Vector2(42, 48), Vector2(43, 56), Vector2(44, 63),
]
const BRIDGE_ROWS := [18, 30, 48]  # her köprü 2 satır kalınlığında

const HOUSE_ROOFS := [
	[[52, 53, 54], [64, 65, 66], [84, 85, 84]],  # kırmızı çatı, turuncu duvar
	[[48, 49, 50], [60, 61, 62], [88, 89, 88]],  # gri çatı, gri duvar
]

## Yollar (Catmull-Rom eğrisi), genişlik 2 karo.
const ROADS := {
	"main_w": [Vector2(18, 31), Vector2(24, 31), Vector2(30, 30), Vector2(37, 30)],
	"main_e": [Vector2(45, 30), Vector2(51, 30), Vector2(54, 25), Vector2(53, 19), Vector2(52, 14)],
	"north": [Vector2(17, 24), Vector2(16, 20), Vector2(17, 14), Vector2(19, 10), Vector2(20, 9)],
	"north_bridge": [Vector2(16, 19), Vector2(24, 18), Vector2(32, 18), Vector2(37, 18)],
	"north_bridge_e": [Vector2(45, 18), Vector2(51, 18), Vector2(53, 19)],
	"mill": [Vector2(30, 18), Vector2(32, 15), Vector2(33, 13)],
	"clearing": [Vector2(17, 14), Vector2(13, 13), Vector2(10, 12)],
	"pier": [Vector2(33, 30), Vector2(34, 34), Vector2(37, 36)],
	"mahalle": [Vector2(14, 34), Vector2(14, 39), Vector2(13, 44), Vector2(14, 49), Vector2(19, 52), Vector2(27, 54), Vector2(35, 54)],
	"school": [Vector2(14, 41), Vector2(19, 42), Vector2(24, 44), Vector2(31, 44)],
	"south_bridge": [Vector2(19, 52), Vector2(26, 49), Vector2(32, 48), Vector2(37, 48)],
	"west_loop": [Vector2(13, 46), Vector2(7, 47), Vector2(5, 52), Vector2(8, 57), Vector2(14, 58)],
	"mahalle_w": [Vector2(14, 40), Vector2(8, 40), Vector2(4, 42), Vector2(3, 46)],
	"mahalle_s": [Vector2(20, 53), Vector2(21, 58), Vector2(27, 60), Vector2(34, 59)],
	"farm": [Vector2(52, 30), Vector2(52, 38), Vector2(53, 46), Vector2(58, 49)],
	"farm_e": [Vector2(45, 48), Vector2(52, 48), Vector2(58, 49), Vector2(68, 50), Vector2(78, 50)],
	"landfill": [Vector2(78, 50), Vector2(84, 52), Vector2(88, 53)],
	"plant_a": [Vector2(52, 11), Vector2(52, 9), Vector2(58, 8), Vector2(62, 10), Vector2(72, 12), Vector2(84, 12), Vector2(91, 12)],
	"plant_b": [Vector2(53, 19), Vector2(60, 20), Vector2(72, 20), Vector2(90, 20)],
	"lojman": [Vector2(54, 25), Vector2(62, 24), Vector2(72, 25), Vector2(82, 25)],
}


static func build(m: FieldMap) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	_zones(m)
	_river(m)
	_pond(m)
	_landmark_buildings(m)
	_streets_with_houses(m, rng)
	_plaza(m)
	_roads(m)
	_riverbank_zone(m)
	_clean_patches(m, rng)
	_dry_trees(m, rng)
	_deco(m, rng)
	_farm_and_landfill(m, rng)
	_industry(m, rng)
	_forest(m, rng)
	_signs_and_pois(m)
	m.reveal(m.tile_at(m.door_world_position()), 9)


# ------------------------------------------------------------------ Bölgeler

static func _zones(m: FieldMap) -> void:
	m.set_zone_rect(Rect2i(2, 2, 33, 17), Zone.FOREST)
	m.set_zone_rect(Rect2i(4, 21, 30, 16), Zone.MARKET)
	m.set_zone_rect(Rect2i(2, 38, 34, 25), Zone.HOUSING)
	m.set_zone_rect(Rect2i(50, 2, 44, 30), Zone.INDUSTRY)
	m.set_zone_rect(Rect2i(46, 38, 30, 25), Zone.FARM)
	m.set_zone_rect(Rect2i(76, 34, 19, 29), Zone.LANDFILL)
	m.set_zone_rect(Rect2i(18, 29, 11, 8), Zone.PARK)


# ------------------------------------------------------------------ Nehir, köprüler, gölet

static func _river(m: FieldMap) -> void:
	for s in RIVER_POINTS.size() - 1:
		var a: Vector2 = RIVER_POINTS[s]
		var b: Vector2 = RIVER_POINTS[s + 1]
		var steps := int(a.distance_to(b) * 2.0)
		for k in steps + 1:
			var p := a.lerp(b, float(k) / maxi(steps, 1))
			var radius := 1.8 + 0.35 * sin(p.y * 0.55)
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					var t := Vector2i(int(round(p.x)) + dx, int(round(p.y)) + dy)
					if Vector2(t.x - p.x, t.y - p.y).length() <= radius:
						m.set_ground(t, FieldMap.G_WATER)
	for y in BRIDGE_ROWS:
		var min_x := 999
		var max_x := -1
		for x in FieldMap.COLS:
			if m.ground_at(Vector2i(x, y)) == FieldMap.G_WATER:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
		for row in 2:
			for x in range(min_x - 2, max_x + 3):
				var t := Vector2i(x, y + row)
				if m.ground_at(t) == FieldMap.G_WATER:
					m.set_ground(t, FieldMap.G_BRIDGE)
				elif m.ground_at(t) == FieldMap.G_LAND:
					m.set_ground(t, FieldMap.G_ROAD)
	# İskele: batı kıyıdan nehre uzanan tahta yol
	for x in range(37, 42):
		var t := Vector2i(x, 36)
		if m.ground_at(t) == FieldMap.G_WATER:
			m.set_ground(t, FieldMap.G_BRIDGE)
		elif m.ground_at(t) == FieldMap.G_LAND:
			m.set_ground(t, FieldMap.G_ROAD)


static func _pond(m: FieldMap) -> void:
	for row in [[32, 23, 26], [33, 22, 26], [34, 23, 26]]:
		for x in range(row[1], row[2] + 1):
			m.set_ground(Vector2i(x, row[0]), FieldMap.G_WATER)


## Nehre 3 karo yakın kara, Nehir Kıyısı bölgesi olur (pazar, park ve mahalle dışında).
static func _riverbank_zone(m: FieldMap) -> void:
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			if m.ground_at(t) == FieldMap.G_WATER or m.zone_at(t) == Zone.MARKET or m.zone_at(t) == Zone.PARK:
				continue
			if x < 30 or x > 52:
				continue
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					if m.ground_at(t + Vector2i(dx, dy)) == FieldMap.G_WATER and Vector2i(dx, dy) != Vector2i.ZERO:
						if t.x >= 33 and t.x <= 46:
							m.set_zone(t, Zone.RIVER)
						break
				if m.zone_at(t) == Zone.RIVER:
					break


# ------------------------------------------------------------------ Önemli yapılar

static func _landmark_buildings(m: FieldMap) -> void:
	m.add_building(m.market_rect, FieldMap.MARKET_ROWS, "market")
	# Belediye
	m.add_building(Rect2i(19, 21, 7, 3), [
		[48, 49, 49, 49, 49, 49, 50], [60, 61, 61, 61, 61, 61, 62], [88, 88, 88, 89, 88, 88, 88]], "hall")
	m.add_landmark("belediye", Vector2i(22, 21))
	# Fidanlık (sera): Canan'ın yeri, Tomurcuk'un doğduğu yer
	m.add_building(Rect2i(29, 22, 5, 3), [[-1, -1, -1, -1, -1], [-1, -1, -1, -1, -1], [-1, -1, -1, -1, -1]], "greenhouse")
	m.add_landmark("fidanlik", Vector2i(31, 22))
	# Okul ve çay ocağı
	m.add_building(Rect2i(23, 39, 6, 3), [
		[48, 49, 49, 49, 49, 50], [60, 61, 61, 61, 61, 62], [88, 88, 89, 89, 88, 88]], "school")
	m.add_landmark("okul", Vector2i(25, 39))
	m.add_building(Rect2i(16, 45, 4, 3), [
		[52, 53, 53, 54], [64, 65, 65, 66], [84, 84, 85, 84]], "house")
	m.add_landmark("cay_ocagi", Vector2i(17, 45))
	# Orman bekçi kulübesi ve eski değirmen
	m.add_building(Rect2i(19, 6, 3, 3), HOUSE_ROOFS[0], "house")
	m.add_landmark("orman_kulubesi", Vector2i(20, 6))
	m.add_building(Rect2i(31, 10, 3, 3), HOUSE_ROOFS[0], "mill")
	m.add_landmark("degirmen", Vector2i(32, 10))
	m.add_landmark("iskele", Vector2i(38, 35))
	# Sanayi: taş kapı, Genel Müdürlük, fabrikalar
	m.add_building(Rect2i(50, 11, 4, 2), [[111, 112, 111, 112], [123, 124, 123, 124]], "gate")
	m.open_tile(Vector2i(51, 12))
	m.open_tile(Vector2i(53, 12))
	m.add_landmark("fabrika_kapisi", Vector2i(51, 11))
	m.add_building(Rect2i(55, 3, 7, 3), [
		[48, 49, 49, 49, 49, 49, 50], [60, 61, 61, 61, 61, 61, 62], [88, 88, 88, 89, 88, 88, 88]], "hq")
	m.add_landmark("genel_mudurluk", Vector2i(58, 3))
	for spec in [[66, 4, 7], [78, 5, 5], [58, 14, 5], [70, 14, 6], [84, 14, 6]]:
		_factory(m, Vector2i(spec[0], spec[1]), spec[2])
	# Lojmanlar ve sendika barakası
	for x in [56, 61, 66, 71]:
		m.add_building(Rect2i(x, 27, 3, 3), HOUSE_ROOFS[1], "lojman")
	m.add_building(Rect2i(78, 27, 4, 3), [[48, 49, 49, 50], [60, 61, 61, 62], [88, 89, 88, 88]], "lojman")
	m.add_landmark("lojman", Vector2i(63, 27))
	m.add_landmark("sendika", Vector2i(79, 27))
	# Çiftlik
	m.add_building(Rect2i(55, 41, 5, 3), [
		[52, 53, 53, 53, 54], [64, 65, 65, 65, 66], [84, 84, 85, 84, 84]], "house")
	m.add_landmark("ciftlik", Vector2i(57, 41))
	m.add_building(Rect2i(62, 41, 5, 3), [
		[48, 49, 49, 49, 50], [60, 61, 61, 61, 62], [88, 89, 89, 89, 88]], "house")
	# Çöplük bekçi kulübesi ve gömülü Tohum Bankası
	m.add_building(Rect2i(79, 45, 3, 3), HOUSE_ROOFS[1], "house")
	m.add_landmark("copluk_kapisi", Vector2i(78, 44))
	m.add_building(Rect2i(87, 54, 5, 3), [
		[96, 97, 97, 97, 98], [108, 109, 109, 109, 110], [120, 121, 124, 121, 122]], "bunker")
	m.open_tile(Vector2i(89, 56))
	m.add_landmark("tohum_bankasi", Vector2i(89, 54))
	# Başkanın evi: pazarın doğusunda. Halk kızarsa önüne toplanır (FieldHome)
	for at in [Vector2i(21, 26), Vector2i(20, 29), Vector2i(27, 26), Vector2i(21, 30)]:
		var home_rect := Rect2i(at, Vector2i(5, 3))
		if m.add_building(home_rect, [[52, 53, 53, 53, 54], [64, 65, 65, 65, 66], [84, 84, 85, 84, 84]], "mayor_home"):
			m.set_home(home_rect)
			m.add_landmark("baskan_evi", at + Vector2i(2, 0))
			break


static func _factory(m: FieldMap, at: Vector2i, width: int) -> void:
	var top: Array = [96]
	var mid: Array = [108]
	var low: Array = [120]
	for i in width - 2:
		top.append(97)
		mid.append(109)
		low.append(121)
	top.append(98)
	mid.append(110)
	low.append(122)
	var chimneys: Array = [Vector2(1.0, 0.0)]
	if width >= 6:
		chimneys.append(Vector2(width - 2.5, 0.0))
	m.add_building(Rect2i(at, Vector2i(width, 3)), [top, mid, low], "factory", chimneys)


# ------------------------------------------------------------------ Sokaklar boyunca evler

static func _streets_with_houses(m: FieldMap, rng: RandomNumberGenerator) -> void:
	var variant := 0
	for key in ["mahalle", "school", "west_loop", "mahalle_w", "mahalle_s"]:
		variant = _houses_along(m, ROADS[key], Zone.HOUSING, 4.4, 3.4, rng, variant)
	for key in ["mahalle", "west_loop", "mahalle_s"]:  # ikinci sıra, arka bahçeler
		variant = _houses_along(m, ROADS[key], Zone.HOUSING, 4.6, 7.4, rng, variant)


## Bir yol boyunca iki yana, aralarında boşluk bırakarak 3x3 ev dizer.
static func _houses_along(m: FieldMap, pts: Array, zone: int, spacing: float, offset: float,
		rng: RandomNumberGenerator, variant: int) -> int:
	var samples := _spline(pts, 1.0)
	var acc := spacing
	for i in range(1, samples.size() - 1):
		acc += samples[i].distance_to(samples[i - 1])
		if acc < spacing:
			continue
		acc = 0.0
		var dir: Vector2 = (samples[i + 1] - samples[i - 1]).normalized()
		var normal := Vector2(-dir.y, dir.x)
		for side in [-1.0, 1.0]:
			var c: Vector2 = samples[i] + normal * side * (offset + rng.randf_range(0.0, 1.5))
			var rect := Rect2i(Vector2i(int(round(c.x)) - 1, int(round(c.y)) - 1), Vector2i(3, 3))
			if not _clear_of_roads(samples, rect, 2.6):
				continue
			if m.zone_at(rect.position + Vector2i(1, 1)) != zone:
				continue
			if m.add_building(rect, HOUSE_ROOFS[variant % HOUSE_ROOFS.size()], "house"):
				variant += 1
	return variant


static func _clear_of_roads(samples: Array, rect: Rect2i, margin: float) -> bool:
	var c := Vector2(rect.position) + Vector2(rect.size) / 2.0
	for p in samples:
		if p.distance_to(c) < margin + 1.0:
			return false
	for key in ROADS:
		for p in _spline(ROADS[key], 2.0):
			if p.distance_to(c) < margin:
				return false
	return true


# ------------------------------------------------------------------ Meydan, yollar

static func _plaza(m: FieldMap) -> void:
	_fill_plaza(m, Rect2i(6, 23, 12, 11), 2)
	_fill_plaza(m, Rect2i(18, 24, 8, 2), 0)
	# Çay ocağı önü
	_fill_plaza(m, Rect2i(13, 49, 8, 3), 1)
	# Okul avlusu
	_fill_plaza(m, Rect2i(22, 43, 8, 2), 0)


static func _fill_plaza(m: FieldMap, rect: Rect2i, corner: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var dx := mini(x - rect.position.x, rect.end.x - 1 - x)
			var dy := mini(y - rect.position.y, rect.end.y - 1 - y)
			if dx + dy < corner:
				continue
			var t := Vector2i(x, y)
			if m.is_free_land(t):
				m.set_ground(t, FieldMap.G_PLAZA)


static func _roads(m: FieldMap) -> void:
	for key in ROADS:
		for p in _spline(ROADS[key], 0.5):
			for dy in 2:
				for dx in 2:
					var t := Vector2i(int(round(p.x)) + dx, int(round(p.y)) + dy)
					if m.is_free_land(t):
						m.set_ground(t, FieldMap.G_ROAD)
	# Kapının önü ve bina girişleri
	for t in [Vector2i(22, 24), Vector2i(31, 25), Vector2i(25, 42), Vector2i(17, 48), Vector2i(57, 6), Vector2i(58, 6)]:
		if m.is_free_land(t):
			m.set_ground(t, FieldMap.G_ROAD)


## Catmull-Rom eğrisi üzerinde yaklaşık "step" aralıklı noktalar.
static func _spline(pts: Array, step: float) -> Array:
	var out: Array = []
	for s in pts.size() - 1:
		var p0: Vector2 = pts[maxi(s - 1, 0)]
		var p1: Vector2 = pts[s]
		var p2: Vector2 = pts[s + 1]
		var p3: Vector2 = pts[mini(s + 2, pts.size() - 1)]
		var n := maxi(int(p1.distance_to(p2) / step), 1)
		for k in n:
			var t := float(k) / n
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3))
	out.append(pts[pts.size() - 1])
	return out


# ------------------------------------------------------------------ Doğa ve temizlik

static func _clean_patches(m: FieldMap, rng: RandomNumberGenerator) -> void:
	# Park: temiz çim ve yeşil ağaçlar
	for y in range(29, 37):
		for x in range(18, 29):
			m.set_clean_initial(Vector2i(x, y))
	for off in [Vector2i(19, 30), Vector2i(27, 31), Vector2i(21, 35), Vector2i(27, 36), Vector2i(19, 34)]:
		m.add_tree(off, FieldMap.TREE_TILES[rng.randi_range(0, 2)])
	# Pazar ve belediye çevresi
	for y in range(m.market_rect.position.y - 2, m.market_rect.end.y + 4):
		for x in range(m.market_rect.position.x - 4, m.market_rect.end.x + 3):
			m.set_clean_initial(Vector2i(x, y))
	for y in range(20, 27):
		for x in range(18, 35):
			m.set_clean_initial(Vector2i(x, y))
	# Dağınık küçük temiz cepler
	for n in 26:
		var c := Vector2i(rng.randi_range(2, FieldMap.COLS - 3), rng.randi_range(2, FieldMap.ROWS - 3))
		for d in [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.DOWN]:
			m.set_clean_initial(c + d)


static func _dry_trees(m: FieldMap, rng: RandomNumberGenerator) -> void:
	var chance := {
		Zone.FOREST: 0.2, Zone.INDUSTRY: 0.03, Zone.LANDFILL: 0.05, Zone.HOUSING: 0.03,
		Zone.FARM: 0.012, Zone.RIVER: 0.05, Zone.NONE: 0.03, Zone.MARKET: 0.015,
	}
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			if not m.is_free_land(t) or m.zone_at(t) == Zone.PARK:
				continue
			if rng.randf() < float(chance.get(m.zone_at(t), 0.02)):
				m.set_dry_tree(t)


# ------------------------------------------------------------------ Süsler: meydan, park, mahalle

static func _deco(m: FieldMap, rng: RandomNumberGenerator) -> void:
	# Çarşı: tezgâhlar, çeşme, banklar, fenerler, ilan panosu
	for t in [Vector2i(7, 24), Vector2i(8, 24), Vector2i(10, 24), Vector2i(6, 28), Vector2i(6, 31), Vector2i(15, 24)]:
		m.add_deco(t, "stall", true)
	m.add_deco(Vector2i(9, 29), "fountain", true, 2, 2)
	for t in [Vector2i(13, 33), Vector2i(8, 33), Vector2i(16, 31), Vector2i(17, 26)]:
		m.add_deco(t, "bench")
	for t in [Vector2i(6, 23), Vector2i(17, 23), Vector2i(6, 33), Vector2i(17, 33), Vector2i(12, 24), Vector2i(21, 24), Vector2i(25, 24)]:
		m.add_deco(t, "lamp")
	m.add_deco(Vector2i(18, 27), "board", true)
	m.add_deco(Vector2i(14, 25), "flowerbed")
	m.add_deco(Vector2i(18, 25), "flowerbed")
	# Fidanlığın önü
	for x in [29, 30, 32, 33]:
		m.add_deco(Vector2i(x, 26), "flowerbed")
	m.add_deco(Vector2i(31, 26), "board", true)
	# Park: banklar gölete bakar, çiçek tarhları, fenerler
	for t in [Vector2i(22, 31), Vector2i(25, 31), Vector2i(21, 34), Vector2i(27, 34)]:
		m.add_deco(t, "bench")
	for t in [Vector2i(19, 29), Vector2i(28, 29), Vector2i(19, 36), Vector2i(28, 36)]:
		m.add_deco(t, "lamp")
	for t in [Vector2i(20, 29), Vector2i(21, 29), Vector2i(26, 29), Vector2i(27, 29)]:
		m.add_deco(t, "flowerbed")
	m.add_deco(Vector2i(22, 35), "reeds")
	m.add_deco(Vector2i(24, 35), "reeds")
	m.add_deco(Vector2i(27, 33), "reeds")
	# Mahalle: çay ocağı masaları, okul bahçesi, çiçeklikler
	for t in [Vector2i(14, 49), Vector2i(17, 49), Vector2i(19, 49)]:
		m.add_deco(t, "table")
	for t in [Vector2i(23, 44), Vector2i(26, 44), Vector2i(29, 44)]:
		m.add_deco(t, "swing", true)
	for t in [Vector2i(22, 40), Vector2i(29, 40), Vector2i(22, 41), Vector2i(29, 41)]:
		m.add_deco(t, "flowerbed")
	for t in [Vector2i(15, 38), Vector2i(12, 43), Vector2i(15, 53), Vector2i(31, 53)]:
		m.add_deco(t, "lamp")
	# Nehir kıyısı: kamış ve kayalar
	for t in [Vector2i(38, 22), Vector2i(38, 26), Vector2i(38, 34), Vector2i(38, 42), Vector2i(37, 50), Vector2i(36, 12), Vector2i(36, 6)]:
		m.add_deco(t, "reeds")
	for t in [Vector2i(37, 24), Vector2i(38, 40), Vector2i(45, 20), Vector2i(46, 36), Vector2i(45, 52)]:
		m.add_deco(t, "rocks", true)
	# Kuzey köprü ve iskele ucundaki fener
	m.add_deco(Vector2i(36, 17), "lamp")
	m.add_deco(Vector2i(36, 29), "lamp")
	m.add_deco(Vector2i(36, 47), "lamp")


# ------------------------------------------------------------------ Tarım ve çöplük

static func _farm_and_landfill(m: FieldMap, rng: RandomNumberGenerator) -> void:
	_fence_rect(m, Rect2i(48, 50, 11, 8), 53)
	_fence_rect(m, Rect2i(64, 52, 12, 8), 70)
	for t in [Vector2i(57, 53), Vector2i(68, 56)]:
		m.add_deco(t, "scarecrow", true)
	# Arılık
	for t in [Vector2i(72, 44), Vector2i(73, 44), Vector2i(74, 45), Vector2i(72, 46), Vector2i(74, 47)]:
		m.add_prop(t, 94, false)
	# Saman balyaları, çiftlik fenerleri
	for t in [Vector2i(60, 46), Vector2i(61, 46), Vector2i(68, 44), Vector2i(50, 45), Vector2i(51, 46), Vector2i(48, 41)]:
		m.add_prop(t, 93, false)
	m.add_deco(Vector2i(54, 45), "lamp")
	m.add_deco(Vector2i(60, 45), "lamp")
	# Çöplük: çit hattı, kapı, çöp tepeleri
	for y in range(38, 62):
		if y < 48 or y > 51:
			m.add_prop(Vector2i(77, y), 59 if y % 3 != 0 else 47, true)
	m.add_deco(Vector2i(76, 52), "board", true)
	for n in 14:
		var t := Vector2i(rng.randi_range(80, 93), rng.randi_range(38, 61))
		if Vector2(t).distance_to(Vector2(89, 55)) > 6.0:
			m.add_deco(t, "rubble", true)
	for n in 50:
		var t := Vector2i(rng.randi_range(78, 93), rng.randi_range(36, 61))
		if Vector2(t).distance_to(Vector2(89, 56)) > 3.0:
			m.add_prop(t, [106, 107, 130, 131][rng.randi_range(0, 3)], false)
	for t in [Vector2i(80, 49), Vector2i(81, 51), Vector2i(82, 50)]:
		m.add_deco(t, "crate_stack", true)
	# Tohum Bankası önü: moloz (hikâye ilerleyince kalkar) ve fener
	m.add_deco(Vector2i(88, 57), "lamp")
	m.add_deco(Vector2i(90, 57), "lamp")


static func _fence_rect(m: FieldMap, rect: Rect2i, gate_x: int) -> void:
	var x0 := rect.position.x
	var y0 := rect.position.y
	var x1 := rect.end.x - 1
	var y1 := rect.end.y - 1
	for x in range(x0, x1 + 1):
		var top := 44 if x == x0 else (46 if x == x1 else 81)
		m.add_prop(Vector2i(x, y0), top, true)
		if x == gate_x - 1:
			m.add_prop(Vector2i(x, y1), 69, true)
		elif x == gate_x + 1:
			m.add_prop(Vector2i(x, y1), 70, true)
		elif x == gate_x:
			continue
		else:
			var bottom := 68 if x == x0 else (70 if x == x1 else 81)
			m.add_prop(Vector2i(x, y1), bottom, true)
	for y in range(y0 + 1, y1):
		m.add_prop(Vector2i(x0, y), 56, true)
		m.add_prop(Vector2i(x1, y), 58, true)


# ------------------------------------------------------------------ Sanayi

static func _industry(m: FieldMap, rng: RandomNumberGenerator) -> void:
	# Demiryolu: fabrikalarla lojmanlar arasında
	for x in range(48, 94):
		var t := Vector2i(x, 23)
		if m.ground_at(t) == FieldMap.G_LAND and m.zone_at(t) == Zone.INDUSTRY:
			m.add_deco(t, "rail")
	# Fabrika arazisi: sandık, varil, kütük
	for n in 26:
		var t := Vector2i(rng.randi_range(52, 92), rng.randi_range(3, 21))
		m.add_prop(t, [106, 107, 130][rng.randi_range(0, 2)], false)
	for t in [Vector2i(57, 7), Vector2i(60, 7), Vector2i(53, 10), Vector2i(55, 10)]:
		m.add_deco(t, "lamp")
	# Sendika barakasının önü: kamp masası ve pano
	m.add_deco(Vector2i(80, 31), "table")
	m.add_deco(Vector2i(78, 31), "board", true)
	m.add_deco(Vector2i(75, 31), "campfire")


# ------------------------------------------------------------------ Orman

static func _forest(m: FieldMap, rng: RandomNumberGenerator) -> void:
	# Kamp yeri ve kuzey patikası
	m.add_deco(Vector2i(9, 11), "campfire")
	m.add_deco(Vector2i(7, 12), "tent", true)
	m.add_deco(Vector2i(11, 13), "stump")
	m.add_deco(Vector2i(8, 13), "stump")
	for n in 22:
		m.add_prop(Vector2i(rng.randi_range(3, 31), rng.randi_range(3, 18)), 29, false)
	for n in 12:
		m.add_prop(Vector2i(rng.randi_range(3, 31), rng.randi_range(3, 18)), 106, false)
	# Yaşlı Meşe: ormanın kalbindeki büyük, yaşlı ağaç
	m.add_tree(Vector2i(25, 13), 28)
	m.add_landmark("yasli_mese", Vector2i(25, 12))
	m.add_deco(Vector2i(24, 14), "bench")
	m.add_deco(Vector2i(27, 14), "stump")
	m.add_deco(Vector2i(20, 10), "lamp")
	# Değirmenin çevresi
	m.add_deco(Vector2i(30, 13), "crate_stack", true)


# ------------------------------------------------------------------ Tabelalar, kuyular, karakterler

static func _signs_and_pois(m: FieldMap) -> void:
	var signs := [
		[Vector2i(16, 21), "ZONE_FOREST"],
		[Vector2i(11, 22), "ZONE_MARKET"],
		[Vector2i(16, 39), "ZONE_HOUSING"],
		[Vector2i(55, 26), "ZONE_INDUSTRY"],
		[Vector2i(49, 40), "ZONE_FARM"],
		[Vector2i(76, 46), "ZONE_LANDFILL"],
		[Vector2i(36, 22), "ZONE_RIVER"],
		[Vector2i(23, 28), "ZONE_PARK"],
	]
	for s in signs:
		m.add_sign(_free_near(m, s[0]), s[1])
	for t in [Vector2i(20, 27), Vector2i(16, 51), Vector2i(60, 47), Vector2i(56, 20), Vector2i(12, 10), Vector2i(80, 47)]:
		m.add_poi("well", _free_near(m, t))
	# Karakter durakları: hikâye (story_data.gd HOMES) buraları kullanır
	for sp in [["okul_avlu", Vector2i(26, 44)], ["fidanlik_on", Vector2i(31, 26)], ["cay_ocagi_on", Vector2i(18, 50)],
			["belediye_on", Vector2i(22, 25)], ["degirmen_on", Vector2i(33, 14)], ["iskele_ucu", Vector2i(37, 36)],
			["orman_kulubesi_on", Vector2i(21, 10)], ["fabrika_kapisi_on", Vector2i(52, 15)], ["genel_mudurluk_on", Vector2i(58, 7)],
			["lojman_on", Vector2i(64, 26)], ["sendika_on", Vector2i(80, 31)], ["ciftlik_on", Vector2i(57, 45)],
			["copluk_kapisi_on", Vector2i(79, 49)], ["tohum_bankasi_on", Vector2i(89, 58)], ["pazar_on", Vector2i(14, 31)],
			["pinar_agaci", Vector2i(21, 33)]]:
		m.add_spot(sp[0], sp[1])
	# Karakterler. Günlük yerleri hikâye belirler (FieldStory.HOMES); burası ilk yerleşim.
	m.add_npc("pinar", _free_near(m, Vector2i(26, 44)), "pinar")
	m.add_npc("canan", _free_near(m, Vector2i(31, 26)), "canan")
	m.add_npc("riza", _free_near(m, Vector2i(18, 49)), "riza")
	m.add_npc("veli", _free_near(m, Vector2i(33, 14)), "veli")
	m.add_npc("hulusi", _free_near(m, Vector2i(58, 7)), "hulusi")
	m.add_npc("kemal", _free_near(m, Vector2i(64, 26)), "kemal")
	m.add_npc("yigithan", _free_near(m, Vector2i(21, 10)), "yigithan")
	# Gizli sandıklar: keşfetmenin ödülü
	for t in [Vector2i(5, 4), Vector2i(27, 16), Vector2i(3, 60), Vector2i(72, 61),
			Vector2i(92, 58), Vector2i(90, 3), Vector2i(35, 6), Vector2i(93, 28)]:
		m.add_poi("chest", _free_near(m, t))


static func _free_near(m: FieldMap, t: Vector2i) -> Vector2i:
	for r in 8:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var c := t + Vector2i(dx, dy)
				if m.is_free_land(c):
					return c
	return t
