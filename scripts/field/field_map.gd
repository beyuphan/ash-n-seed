class_name FieldMap
extends Node2D
## Sahanın dünyası: 96x64 karoluk, bölgelere ayrılmış kasaba. Zemin ya kirli (toprak) ya temiz (çim),
## ayrıca nehir, köprü, yol, bina, ağaç, çöp ve sis (keşfedilmemiş alan) katmanları var.
## Yerleşimi FieldLayout kurar. Çizim yalnızca kameranın gördüğü karolarla sınırlıdır.
## Kenney "Tiny Town" (CC0) karoları kullanılır.

const TILE := 16
const COLS := 96
const ROWS := 64
const ATLAS: Texture2D = preload("res://assets/art/tiny_town/Tilemap/tilemap_packed.png")
const ATLAS_COLS := 12

# Zemin türleri
const G_LAND := 0
const G_WATER := 1
const G_ROAD := 2
const G_BRIDGE := 3
const G_PLAZA := 4        ## meydan taşı (yürünür, ağaç dikilmez)

enum Zone { NONE, MARKET, INDUSTRY, LANDFILL, HOUSING, FARM, FOREST, RIVER, PARK }
const ZONE_KEYS := {
	Zone.MARKET: "ZONE_MARKET", Zone.INDUSTRY: "ZONE_INDUSTRY", Zone.LANDFILL: "ZONE_LANDFILL",
	Zone.HOUSING: "ZONE_HOUSING", Zone.FARM: "ZONE_FARM", Zone.FOREST: "ZONE_FOREST",
	Zone.RIVER: "ZONE_RIVER", Zone.PARK: "ZONE_PARK",
}
## Kirli zeminin bölgeye göre rengi: sanayi ve çöplük daha karanlık.
const ZONE_DIRTY_TINT := {
	Zone.INDUSTRY: Color(0.38, 0.35, 0.37),
	Zone.LANDFILL: Color(0.45, 0.4, 0.34),
	Zone.FARM: Color(0.58, 0.5, 0.4),
	Zone.FOREST: Color(0.5, 0.46, 0.4),
}

const T_GRASS := 0
const T_TUFT := 1
const T_FLOWER := 2
const T_DIRT := 25
const TREE_TILES: Array[int] = [4, 16, 28]
const DRY_TREE_TILES: Array[int] = [3, 15, 27]
const DIRTY_TINT := Color(0.5, 0.45, 0.42)
const TILE_WELL := 104
const TILE_CRATE := 130
const TILE_SIGN := 83

## Pazar binası (5x3). Kapı önü etkileşim bölgesidir.
const MARKET_ROWS := [
	[51, 52, 53, 54, 55],
	[63, 64, 65, 66, 67],
	[72, 73, 74, 73, 75],
]
var market_rect := Rect2i(12, 26, 5, 3)

var player_pos := Vector2.ZERO
var player_facing := 0
var player_flip := false
var player_step := 0
var player_moving := false
var trash: Array[Dictionary] = []
var buildings: Array[Dictionary] = []   # {rect, rows, kind, chimneys}
var pois: Array[Dictionary] = []        # {kind: "chest"|"well", t, used, used_day}
var landmarks: Array[Dictionary] = []   # {id, key, t}
var vault_open := false
var spots: Dictionary = {}               # karakter duraklari: ad -> karo
var special_trees: Array[Dictionary] = []   # {t, heart}: hikâye ağaçları
var signs: Array[Dictionary] = []       # {t, key}
var chimneys: Array[Vector2i] = []      # kirlilik kaynakları
var npcs: Array[Dictionary] = []        # {id, t, style, used_day, temp, marker, stock}
var villagers: Array[Dictionary] = []   # {pos, target, style, wait, facing, flip, step}
var fires: Array[Dictionary] = []       # {t, age, next}: yanan ağaçlar
var butterflies: Array[Dictionary] = []
var _butterfly_timer := 0.0
var _green_cache := 0.0
var hazards: Array[Dictionary] = []        # felaket nesneleri (FieldDisasters)
var drops: Array[Dictionary] = []          # gökten düşen tohum kutuları {pos}
var rabbit: Dictionary = {}             # altın tavşan
var logger: Dictionary = {}             # kaçak oduncu: {pos, state, target, cut, facing, flip, step, walk}
var water_quality := 0.0                # 0 zehirli, 1 temiz: nehrin rengi
var view_tiles := Rect2i(0, 0, COLS, ROWS)

var _dirty := PackedByteArray()
var _clean_t := PackedFloat32Array()
var _tree := PackedInt32Array()
var _tree_t := PackedFloat32Array()
var _dry := PackedByteArray()
var _species := PackedByteArray()      # 0 yok, 1 çam, 2 meşe, 3 meyve (FieldSpecies.code)
var _grove := PackedByteArray()        # 1: bir koru kümesinin üyesi
var _variant := PackedInt32Array()
var _ground := PackedByteArray()
var _zone := PackedByteArray()
var _solid := PackedByteArray()
var _explored := PackedByteArray()
var _props_by_row: Dictionary = {}
var _props: Array[Dictionary] = []
var _buildings_by_row: Dictionary = {}
var _locked := PackedByteArray()       # 1: bu bölüm henüz açılmadı (yürünmez, karanlık)
var _dirty_count := 0
var _land_total := 0
var _unlocked_total := 0
var _time := 0.0
## Baca filtresi mekaniği açık mı (fabrikaların kapısında ok görünür).
var filter_enabled := false
## Başkanın evi (FieldHome yönetir): {rect, windows: Array[bool] (true: kırık), splats: [{p, c}], mood: -1 öfkeli, 0 sıradan, 1 mutlu}
var home: Dictionary = {}
var mob: Array[Dictionary] = []     # evin önündeki öfkeli vatandaşlar: {pos, style, shout, shout_t, throw_t, phase}
var shots: Array[Dictionary] = []   # havadaki taş / domates: {from, to, t, dur, kind (0 taş, 1 domates), window}
const HOME_WINDOWS := 3
## Düşük güç kipi (web): harita saniyede bu kadar kez çizilir, oyuncu ayrı katmanda her karede çizilir.
const LOW_SPEC_REDRAW_HZ := 20.0
var _player_layer: Node2D
var _redraw_acc := 0.0


## Web'de (ya da masaüstünde sınamak için `-- lowspec` argümanıyla) açılan düşük güç kipi. Windows'ta kapalıdır.
static func low_spec_mode() -> bool:
	return OS.has_feature("web") or OS.get_cmdline_user_args().has("lowspec")

signal shot_landed(shot: Dictionary)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	generate()
	if low_spec_mode():
		_player_layer = PlayerLayer.new()
		_player_layer.map = self
		add_child(_player_layer)


## Düşük güç kipinde oyuncuyu haritadan ayrı, her karede çizen küçük katman. (Normal kipte kullanılmaz.)
class PlayerLayer extends Node2D:
	var map: FieldMap

	func _draw() -> void:
		map._draw_player_on(self)


func generate() -> void:
	var count := COLS * ROWS
	_dirty.resize(count)
	_clean_t.resize(count)
	_tree.resize(count)
	_tree_t.resize(count)
	_dry.resize(count)
	_species.resize(count)
	_grove.resize(count)
	_variant.resize(count)
	_ground.resize(count)
	_zone.resize(count)
	_solid.resize(count)
	_explored.resize(count)
	_locked.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	for i in count:
		_dirty[i] = 1
		_clean_t[i] = 0.0
		_tree[i] = -1
		_tree_t[i] = 1.0
		_dry[i] = 0
		_species[i] = 0
		_grove[i] = 0
		_variant[i] = rng.randi_range(0, 99)
		_ground[i] = G_LAND
		_zone[i] = Zone.NONE
		_solid[i] = 0
		_explored[i] = 0
		_locked[i] = 0
	trash.clear()
	buildings.clear()
	pois.clear()
	signs.clear()
	landmarks.clear()
	spots.clear()
	special_trees.clear()
	vault_open = false
	chimneys.clear()
	npcs.clear()
	villagers.clear()
	fires.clear()
	hazards.clear()
	drops.clear()
	logger = {}
	rabbit = {}
	home = {}
	mob.clear()
	shots.clear()
	_props.clear()
	FieldLayout.build(self)
	_finalize()
	player_pos = door_world_position()


func _finalize() -> void:
	_props_by_row.clear()
	for p in _props:
		var row: int = (p["t"] as Vector2i).y
		if not _props_by_row.has(row):
			_props_by_row[row] = []
		_props_by_row[row].append(p)
	_buildings_by_row.clear()
	for b in buildings:
		var rect: Rect2i = b["rect"]
		for r in rect.size.y:
			var y := rect.position.y + r
			if not _buildings_by_row.has(y):
				_buildings_by_row[y] = []
			_buildings_by_row[y].append([b, r])
	_recount()
	for i in _dirty.size():
		_clean_t[i] = 0.0 if _dirty[i] == 1 else 1.0


## Açık (kilitsiz) kara karolarının sayısını yeniden hesaplar. Yeşil oran yalnızca açık alanı sayar.
func _recount() -> void:
	_dirty_count = 0
	_land_total = 0
	_unlocked_total = 0
	for i in _dirty.size():
		if _locked[i] == 1:
			continue
		_unlocked_total += 1
		if _ground[i] == G_LAND and _solid[i] == 0:
			_land_total += 1
			if _dirty[i] == 1:
				_dirty_count += 1


## Açık bölgeleri belirler: bunların dışındaki her karo kilitlenir. FieldProgression.regions(gün) ile çağrılır.
func apply_regions(rects: Array[Rect2i]) -> void:
	for y in ROWS:
		for x in COLS:
			var open := false
			for r in rects:
				if r.has_point(Vector2i(x, y)):
					open = true
					break
			_locked[y * COLS + x] = 0 if open else 1
	_recount()


func is_locked(t: Vector2i) -> bool:
	return not in_bounds(t) or _locked[_index(t)] == 1


func _process(delta: float) -> void:
	_time += delta
	_update_villagers(delta)
	_update_butterflies(delta)
	_update_mob(delta)
	_update_shots(delta)
	var v := _view_clamped()
	for y in range(v.position.y, v.end.y):
		for x in range(v.position.x, v.end.x):
			var i := y * COLS + x
			if _ground[i] != G_LAND:
				continue
			var target := 0.0 if _dirty[i] == 1 else 1.0
			if _clean_t[i] != target:
				_clean_t[i] = move_toward(_clean_t[i], target, delta * 2.5)
			if _tree[i] >= 0 and _tree_t[i] < 1.0:
				_tree_t[i] = minf(_tree_t[i] + delta * 3.0, 1.0)
	if _player_layer != null:
		_player_layer.queue_redraw()
		_redraw_acc += delta
		if _redraw_acc >= 1.0 / LOW_SPEC_REDRAW_HZ:
			_redraw_acc = 0.0
			queue_redraw()
	else:
		queue_redraw()


# ------------------------------------------------------------------ Kurulum (FieldLayout kullanır)

func set_zone_rect(rect: Rect2i, zone: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if in_bounds(Vector2i(x, y)):
				_zone[y * COLS + x] = zone


func set_zone(t: Vector2i, zone: int) -> void:
	if in_bounds(t):
		_zone[_index(t)] = zone


func set_ground(t: Vector2i, ground: int) -> void:
	if in_bounds(t):
		_ground[_index(t)] = ground
		_solid[_index(t)] = 1 if ground == G_WATER else 0


func set_solid(t: Vector2i, value: bool) -> void:
	if in_bounds(t):
		_solid[_index(t)] = 1 if value else 0


func set_clean_initial(t: Vector2i) -> void:
	if in_bounds(t) and _ground[_index(t)] == G_LAND:
		_dirty[_index(t)] = 0


func set_dry_tree(t: Vector2i) -> void:
	if is_free_land(t):
		_dry[_index(t)] = 1


func add_tree(t: Vector2i, tile: int) -> void:
	if is_free_land(t):
		_tree[_index(t)] = tile
		_species[_index(t)] = 1
		_dirty[_index(t)] = 0


func is_free_land(t: Vector2i) -> bool:
	return in_bounds(t) and _ground[_index(t)] == G_LAND and _solid[_index(t)] == 0 and _locked[_index(t)] == 0


func rect_is_free(rect: Rect2i) -> bool:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if not is_free_land(Vector2i(x, y)):
				return false
	return true


func add_building(rect: Rect2i, rows: Array, kind: String, chimney_offsets: Array = []) -> bool:
	if not rect_is_free(rect):
		return false
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_solid[y * COLS + x] = 1
			_dirty[y * COLS + x] = 0
	buildings.append({"rect": rect, "rows": rows, "kind": kind, "chimneys": chimney_offsets, "filtered": false})
	for off in chimney_offsets:
		chimneys.append(Vector2i(rect.position.x + int(off.x), rect.position.y))
	return true


## Filtresiz fabrikaların baca konumları. Kirlilik kaynağı ve duman bunlardan gelir.
func active_chimneys() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for b in buildings:
		if b["kind"] == "factory" and not b["filtered"]:
			for off in b["chimneys"]:
				result.append(Vector2i(b["rect"].position.x + int(off.x), b["rect"].position.y))
	return result


func active_chimney_count() -> int:
	return active_chimneys().size()


## Filtre takılabilir en yakın fabrika (kapısının önünde durmak gerekir). Yoksa boş sözlük.
func filter_building_near(world: Vector2, max_dist: float) -> Dictionary:
	for b in buildings:
		if b["kind"] != "factory" or b["filtered"]:
			continue
		var rect: Rect2i = b["rect"]
		if is_locked(rect.position):
			continue
		var spot := Vector2((rect.position.x + rect.size.x / 2.0) * TILE, (rect.end.y + 0.5) * TILE)
		if world.distance_to(spot) <= max_dist:
			return b
	return {}


func add_prop(t: Vector2i, atlas: int, solid: bool) -> void:
	if not is_free_land(t):
		return
	_props.append({"t": t, "atlas": atlas})
	if solid:
		_solid[_index(t)] = 1


func add_sign(t: Vector2i, key: String) -> void:
	if is_free_land(t):
		signs.append({"t": t, "key": key})
		_props.append({"t": t, "atlas": TILE_SIGN})


## Sabit karakter (Canan, Rıza, Hulusi) ya da geçici (gezici tohumcu). Karosu engel olur.
func add_npc(id: String, t: Vector2i, style: String, temp: bool = false) -> void:
	npcs.append({"id": id, "t": t, "style": style, "used_day": -1, "temp": temp, "marker": true, "stock": 0, "active": true, "topic": "", "last_topic_day": -9})
	_solid[_index(t)] = 1


func remove_temp_npcs() -> void:
	for i in range(npcs.size() - 1, -1, -1):
		if npcs[i]["temp"]:
			_solid[_index(npcs[i]["t"])] = 0
			npcs.remove_at(i)


## Oyuncuya max_dist piksel yakın karakter. Yoksa boş sözlük.
func npc_near(world: Vector2, max_dist: float) -> Dictionary:
	var best: Dictionary = {}
	var best_d := max_dist
	for n in npcs:
		if not n["active"] or is_locked(n["t"]):
			continue
		var center := Vector2((n["t"].x + 0.5) * TILE, (n["t"].y + 0.5) * TILE)
		var d := world.distance_to(center)
		if d <= best_d:
			best_d = d
			best = n
	return best


## Temiz karolara count kadar vatandaş yerleştirir. Yeşil alan büyüdükçe sokaklar kalabalıklaşır.
func spawn_villagers(count: int, around: Vector2i = Vector2i(-1, -1), radius: int = 0) -> void:
	villagers.clear()
	var guard := 0
	while villagers.size() < count and guard < 600:
		guard += 1
		var t := Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		if around.x >= 0 and guard < 400:  # önce merkezin çevresinde ara, bulamazsan her yerde
			t = around + Vector2i(randi_range(-radius, radius), randi_range(-radius, radius))
		if is_free_land(t) and not is_dirty(t):
			var pos := Vector2((t.x + 0.5) * TILE, (t.y + 0.9) * TILE)
			villagers.append({"pos": pos, "target": pos, "style": FieldArt.VILLAGER_STYLES[randi() % FieldArt.VILLAGER_STYLES.size()],
				"wait": randf() * 3.0, "facing": 0, "flip": false, "step": 0, "walk": randf() * 6.0})


func _update_villagers(delta: float) -> void:
	for v in villagers:
		var pos: Vector2 = v["pos"]
		if pos.distance_to(v["target"]) < 1.0:
			v["step"] = 0
			v["wait"] -= delta
			if v["wait"] <= 0.0:
				v["wait"] = randf_range(1.0, 4.0)
				var tries := 0
				while tries < 6:
					tries += 1
					var cand := pos + Vector2(randf_range(-56.0, 56.0), randf_range(-56.0, 56.0))
					var ct := tile_at(cand)
					if in_bounds(ct) and _ground[_index(ct)] != G_WATER and _solid[_index(ct)] == 0 and _locked[_index(ct)] == 0 \
							and not _blocked_line(pos, cand):
						v["target"] = cand
						break
		else:
			var dir: Vector2 = (v["target"] - pos).normalized()
			pos += dir * 15.0 * delta
			v["pos"] = pos
			v["walk"] += delta * 8.0
			v["step"] = 1 if fmod(v["walk"], 2.0) < 1.0 else 2
			if absf(dir.x) > absf(dir.y):
				v["facing"] = 2
				v["flip"] = dir.x < 0.0
			else:
				v["facing"] = 0 if dir.y > 0.0 else 1


## Yolda engel (bina, su, çit) var mı: kaba kontrol, iki uç ve orta nokta.
func _blocked_line(a: Vector2, b: Vector2) -> bool:
	for k in [0.33, 0.66, 1.0]:
		if is_solid_world(a.lerp(b, k)):
			return true
	return false


func add_poi(kind: String, t: Vector2i) -> void:
	pois.append({"kind": kind, "t": t, "used": false, "used_day": -1, "active": true})
	if kind == "well":
		_solid[_index(t)] = 1


# ------------------------------------------------------------------ Dekor, yer işaretleri, özel binalar

## Atlas dışı, kodla çizilen süs nesneleri. kind: bench, lamp, fountain, flowerbed, board, campfire, tent, stall,
## scarecrow, stump, rail, reeds, rocks, table, swing, crate_stack. w/h: kaç karo kapladığı (çizim sol üstten).
func add_deco(t: Vector2i, kind: String, solid: bool = false, w: int = 1, h: int = 1) -> void:
	if not in_bounds(t):
		return
	for dy in h:
		for dx in w:
			var c := t + Vector2i(dx, dy)
			if in_bounds(c) and solid and _ground[_index(c)] != G_WATER:
				_solid[_index(c)] = 1
	_props.append({"t": t, "atlas": -1, "deco": kind, "w": w, "h": h})


## Yakındaki süs nesnesi (bank, çeşme...). Yoksa boş sözlük.
func deco_near(kind: String, world: Vector2, max_dist: float) -> Dictionary:
	var best := {}
	var best_d := max_dist
	for p in _props:
		if p.get("deco", "") != kind:
			continue
		var t: Vector2i = p["t"]
		var c := Vector2((t.x + p["w"] / 2.0) * TILE, (t.y + p["h"] / 2.0) * TILE)
		var d := c.distance_to(world)
		if d <= best_d:
			best_d = d
			best = p
	return best


func add_landmark(id: String, t: Vector2i) -> void:
	landmarks.append({"id": id, "key": "LM_" + id.to_upper(), "t": t})


func add_spot(id: String, t: Vector2i) -> void:
	spots[id] = t


func spot_tile(id: String) -> Vector2i:
	return spots.get(id, Vector2i(-1, -1))


## t'ye en yakın boş (yürünür, engelsiz) karo.
func free_near(t: Vector2i) -> Vector2i:
	for r in 10:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c := t + Vector2i(dx, dy)
				if is_free_land(c):
					return c
	return t


func set_tree_tile(t: Vector2i, tile: int) -> void:
	if in_bounds(t) and _tree[_index(t)] >= 0:
		_tree[_index(t)] = tile


func landmark_tile(id: String) -> Vector2i:
	for l in landmarks:
		if l["id"] == id:
			return l["t"]
	return Vector2i(-1, -1)


func open_tile(t: Vector2i) -> void:
	if in_bounds(t) and _ground[_index(t)] != G_WATER:
		_solid[_index(t)] = 0


## Bir karakteri başka bir karoya taşır (günlük yerleşim).
func move_npc(n: Dictionary, t: Vector2i) -> void:
	var old: Vector2i = n["t"]
	if in_bounds(old):
		_solid[_index(old)] = 0
	n["t"] = t
	if in_bounds(t):
		_solid[_index(t)] = 1


func _draw_deco(p: Dictionary) -> void:
	var t: Vector2i = p["t"]
	var o := Vector2(t.x * TILE, t.y * TILE)
	match p["deco"]:
		"bench":
			draw_rect(Rect2(o + Vector2(1, 8), Vector2(14, 3)), Color(0.3, 0.19, 0.1))
			draw_rect(Rect2(o + Vector2(1, 7), Vector2(14, 2)), Color(0.62, 0.42, 0.22))
			draw_rect(Rect2(o + Vector2(1, 4), Vector2(14, 2)), Color(0.55, 0.37, 0.2))
			draw_rect(Rect2(o + Vector2(2, 11), Vector2(2, 3)), Color(0.25, 0.16, 0.09))
			draw_rect(Rect2(o + Vector2(12, 11), Vector2(2, 3)), Color(0.25, 0.16, 0.09))
		"lamp":
			draw_rect(Rect2(o + Vector2(7, 4), Vector2(2, 12)), Color(0.14, 0.12, 0.14))
			draw_rect(Rect2(o + Vector2(5, 1), Vector2(6, 4)), Color(0.14, 0.12, 0.14))
			var glow := 0.75 + 0.25 * sin(_time * 3.0 + t.x)
			draw_rect(Rect2(o + Vector2(6, 2), Vector2(4, 2)), Color(1.0, 0.85, 0.4, glow))
			draw_circle(o + Vector2(8, 3), 7.0, Color(1.0, 0.85, 0.4, 0.10 * glow))
		"fountain":
			var c := o + Vector2(16, 16)
			draw_circle(c, 14.0, Color(0.16, 0.14, 0.15))
			draw_circle(c, 13.0, Color(0.66, 0.64, 0.6))
			var wq := water_quality
			draw_circle(c, 10.0, Color(0.38, 0.33, 0.25).lerp(Color(0.3, 0.62, 0.85), wq))
			draw_circle(c, 3.5, Color(0.6, 0.58, 0.55))
			draw_rect(Rect2(c + Vector2(-1, -9), Vector2(2, 8)), Color(0.6, 0.58, 0.55))
			if wq > 0.45:  # temiz sudan fışkıran damlalar
				for k in 6:
					var a := fmod(_time * 1.3 + k * 0.17, 1.0)
					var ang := TAU * k / 6.0
					draw_circle(c + Vector2(cos(ang) * a * 8.0, -9.0 - sin(a * PI) * 7.0 + a * 6.0), 1.0, Color(0.8, 0.93, 1.0, 1.0 - a))
		"flowerbed":
			draw_rect(Rect2(o + Vector2(2, 6), Vector2(12, 8)), Color(0.28, 0.2, 0.13))
			var cols: Array = [Color(0.95, 0.4, 0.45), Color(1.0, 0.85, 0.3), Color(0.7, 0.5, 0.95), Color(1, 1, 1)]
			for k in 5:
				var px := 3 + (k * 5 + t.x * 3) % 10
				var py := 6 + (k * 3 + t.y) % 5
				draw_rect(Rect2(o + Vector2(px, py + 2), Vector2(1, 3)), Color(0.25, 0.55, 0.25))
				draw_rect(Rect2(o + Vector2(px - 1, py), Vector2(3, 3)), cols[(k + t.x) % 4])
		"board":
			draw_rect(Rect2(o + Vector2(3, 6), Vector2(2, 10)), Color(0.3, 0.19, 0.1))
			draw_rect(Rect2(o + Vector2(11, 6), Vector2(2, 10)), Color(0.3, 0.19, 0.1))
			draw_rect(Rect2(o + Vector2(1, 1), Vector2(14, 9)), Color(0.22, 0.14, 0.08))
			draw_rect(Rect2(o + Vector2(2, 2), Vector2(12, 7)), Color(0.62, 0.45, 0.25))
			draw_rect(Rect2(o + Vector2(3, 3), Vector2(4, 4)), Color(0.95, 0.92, 0.82))
			draw_rect(Rect2(o + Vector2(8, 3), Vector2(5, 3)), Color(0.9, 0.85, 0.6))
		"campfire":
			draw_rect(Rect2(o + Vector2(3, 11), Vector2(10, 3)), Color(0.35, 0.22, 0.12))
			draw_rect(Rect2(o + Vector2(5, 9), Vector2(6, 3)), Color(0.45, 0.28, 0.14))
			var f := 0.6 + 0.4 * sin(_time * 9.0 + t.x)
			draw_colored_polygon(PackedVector2Array([o + Vector2(5, 10), o + Vector2(8, 1.0 + 3.0 * (1.0 - f)), o + Vector2(11, 10)]), Color(1.0, 0.5, 0.15, 0.95))
			draw_colored_polygon(PackedVector2Array([o + Vector2(6.5, 10), o + Vector2(8, 4.0 + 3.0 * (1.0 - f)), o + Vector2(9.5, 10)]), Color(1.0, 0.9, 0.4, 0.95))
			draw_circle(o + Vector2(8, 8), 14.0, Color(1.0, 0.6, 0.2, 0.08 * f))
		"tent":
			draw_colored_polygon(PackedVector2Array([o + Vector2(1, 15), o + Vector2(8, 2), o + Vector2(15, 15)]), Color(0.2, 0.14, 0.1))
			draw_colored_polygon(PackedVector2Array([o + Vector2(3, 14), o + Vector2(8, 4), o + Vector2(13, 14)]), Color(0.86, 0.62, 0.32))
			draw_colored_polygon(PackedVector2Array([o + Vector2(7, 14), o + Vector2(8, 8), o + Vector2(9, 14)]), Color(0.25, 0.17, 0.1))
		"stall":
			var awn: Color = [Color(0.85, 0.3, 0.3), Color(0.3, 0.55, 0.85), Color(0.9, 0.75, 0.25)][(t.x + t.y) % 3]
			draw_rect(Rect2(o + Vector2(0, 8), Vector2(16, 6)), Color(0.4, 0.27, 0.15))
			draw_rect(Rect2(o + Vector2(0, 7), Vector2(16, 2)), Color(0.62, 0.43, 0.24))
			for k in 4:
				draw_rect(Rect2(o + Vector2(k * 4, 0), Vector2(4, 6)), awn if k % 2 == 0 else Color(0.96, 0.94, 0.88))
			draw_rect(Rect2(o + Vector2(0, 5), Vector2(16, 1)), Color(0.15, 0.1, 0.08))
			draw_rect(Rect2(o + Vector2(3, 9), Vector2(3, 3)), Color(0.9, 0.3, 0.25))
			draw_rect(Rect2(o + Vector2(8, 9), Vector2(3, 3)), Color(0.95, 0.8, 0.25))
		"scarecrow":
			draw_rect(Rect2(o + Vector2(7, 5), Vector2(2, 11)), Color(0.35, 0.22, 0.12))
			draw_rect(Rect2(o + Vector2(2, 7), Vector2(12, 2)), Color(0.35, 0.22, 0.12))
			draw_rect(Rect2(o + Vector2(5, 3), Vector2(6, 5)), Color(0.9, 0.78, 0.4))
			draw_rect(Rect2(o + Vector2(4, 1), Vector2(8, 3)), Color(0.55, 0.32, 0.18))
			draw_rect(Rect2(o + Vector2(6, 5), Vector2(1, 1)), Color(0.1, 0.07, 0.05))
			draw_rect(Rect2(o + Vector2(9, 5), Vector2(1, 1)), Color(0.1, 0.07, 0.05))
		"stump":
			draw_rect(Rect2(o + Vector2(3, 7), Vector2(10, 7)), Color(0.28, 0.17, 0.09))
			draw_rect(Rect2(o + Vector2(3, 5), Vector2(10, 4)), Color(0.72, 0.52, 0.3))
			draw_rect(Rect2(o + Vector2(5, 6), Vector2(6, 1)), Color(0.55, 0.38, 0.2))
		"rail":
			for k in 4:
				draw_rect(Rect2(o + Vector2(k * 4 + 1, 3), Vector2(2, 10)), Color(0.28, 0.2, 0.14))
			draw_rect(Rect2(o + Vector2(0, 5), Vector2(16, 2)), Color(0.5, 0.5, 0.55))
			draw_rect(Rect2(o + Vector2(0, 10), Vector2(16, 2)), Color(0.5, 0.5, 0.55))
		"reeds":
			for k in 4:
				var sway := sin(_time * 1.6 + k + t.x) * 1.2
				draw_rect(Rect2(o + Vector2(2 + k * 4 + sway, 3 + (k % 2) * 2), Vector2(1, 11)), Color(0.38, 0.55, 0.28))
				draw_rect(Rect2(o + Vector2(1.5 + k * 4 + sway, 2 + (k % 2) * 2), Vector2(2, 3)), Color(0.5, 0.36, 0.2))
		"rocks":
			draw_circle(o + Vector2(6, 11), 4.0, Color(0.15, 0.14, 0.15))
			draw_circle(o + Vector2(6, 11), 3.2, Color(0.55, 0.54, 0.52))
			draw_circle(o + Vector2(11, 12), 3.0, Color(0.15, 0.14, 0.15))
			draw_circle(o + Vector2(11, 12), 2.3, Color(0.46, 0.45, 0.44))
		"table":
			draw_rect(Rect2(o + Vector2(1, 5), Vector2(14, 6)), Color(0.25, 0.16, 0.09))
			draw_rect(Rect2(o + Vector2(1, 4), Vector2(14, 5)), Color(0.66, 0.46, 0.26))
			draw_rect(Rect2(o + Vector2(3, 11), Vector2(2, 4)), Color(0.25, 0.16, 0.09))
			draw_rect(Rect2(o + Vector2(11, 11), Vector2(2, 4)), Color(0.25, 0.16, 0.09))
			draw_rect(Rect2(o + Vector2(5, 2), Vector2(3, 3)), Color(0.95, 0.95, 0.9))
			draw_rect(Rect2(o + Vector2(9, 2), Vector2(3, 3)), Color(0.95, 0.95, 0.9))
		"swing":
			draw_rect(Rect2(o + Vector2(1, 1), Vector2(2, 14)), Color(0.35, 0.22, 0.12))
			draw_rect(Rect2(o + Vector2(13, 1), Vector2(2, 14)), Color(0.35, 0.22, 0.12))
			draw_rect(Rect2(o + Vector2(1, 1), Vector2(14, 2)), Color(0.35, 0.22, 0.12))
			var sw := sin(_time * 2.0 + t.x) * 1.5
			draw_rect(Rect2(o + Vector2(5 + sw, 3), Vector2(1, 7)), Color(0.2, 0.2, 0.2))
			draw_rect(Rect2(o + Vector2(10 + sw, 3), Vector2(1, 7)), Color(0.2, 0.2, 0.2))
			draw_rect(Rect2(o + Vector2(4 + sw, 10), Vector2(8, 2)), Color(0.85, 0.3, 0.3))
		"crate_stack":
			draw_rect(Rect2(o + Vector2(1, 6), Vector2(14, 9)), Color(0.2, 0.13, 0.08))
			draw_rect(Rect2(o + Vector2(2, 7), Vector2(12, 7)), Color(0.62, 0.43, 0.24))
			draw_rect(Rect2(o + Vector2(2, 10), Vector2(12, 1)), Color(0.42, 0.28, 0.15))
			draw_rect(Rect2(o + Vector2(4, 1), Vector2(8, 6)), Color(0.7, 0.5, 0.28))
		"rubble":
			for k in 7:
				var rx := float((t.x * 7 + k * 5) % 14)
				var ry := float((t.y * 5 + k * 3) % 10)
				draw_circle(o + Vector2(2 + rx, 5 + ry), 3.0 + float(k % 3), Color(0.2, 0.19, 0.18))
				draw_circle(o + Vector2(2 + rx, 5 + ry), 2.2 + float(k % 3), Color([0.42, 0.4, 0.38, 0.5, 0.36, 0.45, 0.4][k], 0.39, 0.36))
		_:
			pass


## Özel bina ayrıntıları (tuğla dışında kalan çizimler).
func _draw_special_building_row(b: Dictionary, row: int, y: int) -> void:
	var rect: Rect2i = b["rect"]
	var kind: String = b["kind"]
	var x0 := rect.position.x * TILE
	var w := rect.size.x * TILE
	match kind:
		"hall":
			if row == 0:  # çatıda saat
				var c := Vector2(x0 + w / 2.0, y * TILE + 9)
				draw_circle(c, 8.0, Color(0.12, 0.09, 0.08))
				draw_circle(c, 7.0, Color(0.95, 0.92, 0.82))
				var m := fmod(_time * 0.2, 1.0)
				draw_line(c, c + Vector2.from_angle(m * TAU - PI / 2.0) * 6.0, Color(0.1, 0.08, 0.07), 1.0)
				draw_line(c, c + Vector2.from_angle(m * TAU / 12.0 - PI / 2.0) * 4.0, Color(0.1, 0.08, 0.07), 1.0)
			if row == 2:  # bayrak
				draw_rect(Rect2(x0 + 4, y * TILE - 18, 1, 22), Color(0.2, 0.15, 0.1))
				var fl := sin(_time * 4.0) * 1.0
				draw_rect(Rect2(x0 + 5, y * TILE - 18, 9 + fl, 6), Color(0.78, 0.2, 0.2))
		"school":
			if row == 0:
				draw_rect(Rect2(x0 + w - 12, y * TILE - 8, 1, 16), Color(0.2, 0.15, 0.1))
				draw_rect(Rect2(x0 + w - 11, y * TILE - 8, 8 + sin(_time * 4.0), 5), Color(0.3, 0.55, 0.85))
				draw_circle(Vector2(x0 + w / 2.0, y * TILE + 6), 3.5, Color(0.95, 0.8, 0.3))
		"hq":
			if row == 0:
				draw_rect(Rect2(x0 + w / 2.0 - 11, y * TILE + 3, 22, 8), Color(0.1, 0.08, 0.1))
				draw_rect(Rect2(x0 + w / 2.0 - 10, y * TILE + 4, 20, 6), Color(0.96, 0.52, 0.1))
				draw_rect(Rect2(x0 + w / 2.0 - 6, y * TILE + 6, 12, 2), Color(0.15, 0.1, 0.08))
		"mayor_home":
			_draw_home_row(b, row, y)
		"mill":
			if row >= 1:  # dönen su çarkı sağ kenarda
				var c := Vector2(x0 + w + 4, y * TILE + 6 + (row - 1) * 0)
				if row == 1:
					draw_circle(c, 11.0, Color(0.15, 0.1, 0.07))
					draw_circle(c, 10.0, Color(0.5, 0.34, 0.18))
					draw_circle(c, 7.0, Color(0.42, 0.45, 0.4).darkened(0.2))
					for k in 6:
						var a := _time * 1.4 + k * TAU / 6.0
						draw_line(c, c + Vector2.from_angle(a) * 9.0, Color(0.25, 0.16, 0.09), 2.0)
		"greenhouse":
			if row == 0:
				draw_rect(Rect2(x0, y * TILE + 4, w, 12), Color(0.1, 0.16, 0.14))
				draw_rect(Rect2(x0 + 1, y * TILE + 5, w - 2, 10), Color(0.62, 0.86, 0.85, 0.75))
				for k in int(rect.size.x * 2):
					draw_rect(Rect2(x0 + 1 + k * 8, y * TILE + 5, 1, 10), Color(0.9, 0.97, 0.95))
			elif row == 1:
				draw_rect(Rect2(x0, y * TILE, w, 16), Color(0.1, 0.16, 0.14))
				draw_rect(Rect2(x0 + 1, y * TILE, w - 2, 15), Color(0.55, 0.82, 0.8, 0.8))
				for k in int(rect.size.x * 2):
					draw_rect(Rect2(x0 + 1 + k * 8, y * TILE, 1, 15), Color(0.9, 0.97, 0.95))
				for k in rect.size.x:  # içeride fidanlar
					var px := x0 + k * TILE + 8
					draw_rect(Rect2(px - 1, y * TILE + 6, 2, 8), Color(0.2, 0.5, 0.25))
					draw_circle(Vector2(px, y * TILE + 5), 4.0, Color(0.4, 0.78, 0.35))
			else:
				draw_rect(Rect2(x0, y * TILE, w, 16), Color(0.1, 0.16, 0.14))
				draw_rect(Rect2(x0 + 1, y * TILE, w - 2, 15), Color(0.5, 0.78, 0.76, 0.85))
				draw_rect(Rect2(x0 + w / 2.0 - 5, y * TILE + 3, 10, 13), Color(0.2, 0.3, 0.28))
				draw_rect(Rect2(x0 + w / 2.0 - 4, y * TILE + 4, 8, 12), Color(0.45, 0.32, 0.2))
		"bunker":
			if row == rect.size.y - 1:
				var dc := Vector2(x0 + w / 2.0, y * TILE + 8)
				if vault_open:
					var pulse := 0.5 + 0.5 * sin(_time * 3.0)
					draw_circle(dc, 14.0 + pulse * 3.0, Color(0.5, 1.0, 0.85, 0.16))
					draw_rect(Rect2(dc + Vector2(-5, -7), Vector2(10, 15)), Color(0.45, 0.95, 0.8, 0.55 + 0.25 * pulse))
				else:
					for k in 5:  # kapıyı kapatan moloz
						draw_circle(dc + Vector2(-8 + k * 4, 2 + (k % 2) * 3), 5.0, Color(0.18, 0.17, 0.16))
						draw_circle(dc + Vector2(-8 + k * 4, 2 + (k % 2) * 3), 4.0, Color(0.4 + 0.03 * k, 0.38, 0.36))
		_:
			pass



# ------------------------------------------------------------------ Sorgular

func in_bounds(t: Vector2i) -> bool:
	return t.x >= 0 and t.y >= 0 and t.x < COLS and t.y < ROWS


func tile_at(world: Vector2) -> Vector2i:
	return Vector2i(floori(world.x / TILE), floori(world.y / TILE))


func ground_at(t: Vector2i) -> int:
	return _ground[_index(t)] if in_bounds(t) else G_WATER


func zone_at(t: Vector2i) -> int:
	return _zone[_index(t)] if in_bounds(t) else Zone.NONE


## Karo kirli mi: yalnızca kara karoları (su, yol, köprü sayılmaz).
func is_dirty(t: Vector2i) -> bool:
	return in_bounds(t) and _ground[_index(t)] == G_LAND and _dirty[_index(t)] == 1


func has_tree(t: Vector2i) -> bool:
	return in_bounds(t) and _tree[_index(t)] >= 0


func is_solid_world(world: Vector2) -> bool:
	var t := tile_at(world)
	return not in_bounds(t) or _solid[_index(t)] == 1 or _locked[_index(t)] == 1


func can_plant(t: Vector2i) -> bool:
	return is_free_land(t) and _dirty[_index(t)] == 1


func door_world_position() -> Vector2:
	return Vector2((market_rect.position.x + 2.5) * TILE, (market_rect.end.y + 1.0) * TILE)


## Pazar etkileşim bölgesi: bina ve çevresi.
func in_market_zone(t: Vector2i) -> bool:
	return Rect2i(market_rect.position - Vector2i(1, 1), market_rect.size + Vector2i(2, 3)).has_point(t)


func market_sign_position() -> Vector2:
	return Vector2((market_rect.position.x + market_rect.size.x / 2.0) * TILE, market_rect.position.y * TILE)


func dirty_ratio() -> float:
	return float(_dirty_count) / maxf(_land_total, 1.0)


func world_size() -> Vector2:
	return Vector2(COLS, ROWS) * TILE


func random_trash_tile(zone_weights: Dictionary) -> Vector2i:
	for attempt in 120:
		var t := Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		if not is_dirty(t) or not is_free_land(t) or trash_at(t):
			continue
		var weight: float = zone_weights.get(zone_at(t), 1.0)
		if randf() * 4.0 <= weight:
			return t
	return Vector2i(-1, -1)


func add_trash(t: Vector2i, kind: int) -> void:
	trash.append({"tile": t, "kind": kind, "phase": randf() * TAU})


func trash_at(t: Vector2i) -> bool:
	for item in trash:
		if item["tile"] == t:
			return true
	return false


## Karodaki çöpü alır ve türünü döndürür. Çöp yoksa -1.
func take_trash_at(t: Vector2i) -> int:
	for i in trash.size():
		if trash[i]["tile"] == t:
			var kind: int = trash[i]["kind"]
			trash.remove_at(i)
			return kind
	return -1


## Oyuncuya max_dist piksel yakın, kullanılabilir sandık veya kuyu. Yoksa boş sözlük.
func poi_near(world: Vector2, max_dist: float, day: int) -> Dictionary:
	var best: Dictionary = {}
	var best_d := max_dist
	for p in pois:
		if not p["active"] or is_locked(p["t"]) or (p["kind"] == "chest" and p["used"]):
			continue
		var center := Vector2((p["t"].x + 0.5) * TILE, (p["t"].y + 0.5) * TILE)
		var d := world.distance_to(center)
		if d <= best_d:
			best_d = d
			best = p
	return best


# ------------------------------------------------------------------ Sis (keşif)

## Oyuncunun çevresini açar. Yeni açılan karo sayısını döndürür.
func reveal(center: Vector2i, radius: int) -> int:
	var newly := 0
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var t := Vector2i(x, y)
			if not in_bounds(t) or _locked[_index(t)] == 1:
				continue
			if Vector2(x - center.x, y - center.y).length() <= radius + 0.3 and _explored[_index(t)] == 0:
				_explored[_index(t)] = 1
				newly += 1
	return newly


## Sinematikler için bütün sisi kaldırır.
func reveal_all() -> void:
	_explored.fill(1)


func is_explored(t: Vector2i) -> bool:
	return in_bounds(t) and _explored[_index(t)] == 1


func explored_ratio() -> float:
	var n := 0
	for i in _explored.size():
		if _locked[i] == 0:
			n += _explored[i]
	return float(n) / maxf(_unlocked_total, 1.0)


## Mini harita için 1 piksel = 1 karo renk haritası.
func minimap_image() -> Image:
	var img := Image.create_empty(COLS, ROWS, false, Image.FORMAT_RGBA8)
	var fog := Color(0.07, 0.06, 0.06)
	var water_dirty := Color(0.42, 0.4, 0.22)
	var water_clean := Color(0.25, 0.55, 0.85)
	for y in ROWS:
		for x in COLS:
			var i := y * COLS + x
			if _locked[i] == 1:  # kilitli bölüm: koyu gri, çapraz desenli
				img.set_pixel(x, y, Color(0.16, 0.13, 0.13) if (x + y) % 4 == 0 else Color(0.1, 0.085, 0.085))
				continue
			if _explored[i] == 0:
				img.set_pixel(x, y, fog)
				continue
			var c: Color
			match _ground[i]:
				G_WATER:
					c = water_dirty.lerp(water_clean, water_quality)
				G_BRIDGE:
					c = Color(0.6, 0.42, 0.22)
				G_ROAD:
					c = Color(0.62, 0.6, 0.6)
				G_PLAZA:
					c = Color(0.78, 0.74, 0.66)
				_:
					if _solid[i] == 1:
						c = Color(0.5, 0.45, 0.45)
					elif _dirty[i] == 1:
						c = Color(0.36, 0.28, 0.21)
					elif _tree[i] >= 0:
						c = Color(0.16, 0.5, 0.2)
					else:
						c = Color(0.38, 0.68, 0.3)
			img.set_pixel(x, y, c)
	for b in buildings:
		var rect: Rect2i = b["rect"]
		if is_explored(rect.position):
			for y in range(rect.position.y, rect.end.y):
				for x in range(rect.position.x, rect.end.x):
					img.set_pixel(x, y, _minimap_building_color(b))
	for p in pois:
		if p["active"] and is_explored(p["t"]) and not (p["kind"] == "chest" and p["used"]):
			img.set_pixel(p["t"].x, p["t"].y, Color(1.0, 0.85, 0.3) if p["kind"] == "chest" else Color(0.4, 0.8, 1.0))
	for n in npcs:
		if n["active"] and n["marker"] and not n["temp"] and in_bounds(n["t"]):
			var nc := Color(1.0, 0.85, 0.2)
			for off in [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.DOWN]:
				var np: Vector2i = n["t"] + off
				if in_bounds(np):
					img.set_pixel(np.x, np.y, nc)
	# Tehlikeler keşfedilmemiş yerde bile görünür: oyuncuyu çağırır
	var blink := fmod(_time, 0.8) < 0.5
	for f in fires:
		img.set_pixel(f["t"].x, f["t"].y, Color(1.0, 0.45, 0.1) if blink else Color(1.0, 0.9, 0.3))
	if not logger.is_empty():
		var lt := tile_at(logger["pos"])
		if in_bounds(lt):
			img.set_pixel(lt.x, lt.y, Color(1.0, 0.2, 0.2) if blink else Color(1.0, 0.8, 0.8))
	for hz in hazards:
		var ht := tile_at(hz["pos"])
		if in_bounds(ht) and hz["kind"] != "strike":
			var hc := Color(0.4, 0.9, 1.0) if hz["kind"] == "stranded" else (Color(1.0, 0.6, 0.2) if hz["kind"] == "wilt" else Color(0.5, 1.0, 0.3))
			img.set_pixel(ht.x, ht.y, hc if blink else Color(1, 1, 1))
	for d in drops:
		var dt := tile_at(d["pos"])
		if in_bounds(dt):
			img.set_pixel(dt.x, dt.y, Color(1.0, 0.4, 0.9) if blink else Color(1, 1, 1))
	if not rabbit.is_empty():
		var rt := tile_at(rabbit["pos"])
		if in_bounds(rt):
			img.set_pixel(rt.x, rt.y, Color(1.0, 0.9, 0.25) if blink else Color(1, 1, 1))
	return img


# ------------------------------------------------------------------ Değişiklikler

## Seçilen türün alanını temizler ve ortaya ağaç diker. Yakında 4 ağaç kümelenirse KORU oluşur:
## yarıçap 2 ek temizlik ve üyeler işaretlenir (bir ağaç tek koruya katılır).
## Döndürür: {cleaned: Array[Vector2i], grove: bool, grove_tiles: Array[Vector2i]}
func plant(t: Vector2i, species_id: String = "pine", allow_grove: bool = true) -> Dictionary:
	var result := {"cleaned": [] as Array[Vector2i], "grove": false, "grove_tiles": [] as Array[Vector2i]}
	for d in FieldSpecies.area(species_id):
		var n: Vector2i = t + d
		if can_plant(n):
			_set_clean(n, false)
			result["cleaned"].append(n)
	if in_bounds(t) and _tree[_index(t)] < 0:
		var tiles: Array = FieldSpecies.data(species_id)["tiles"]
		_tree[_index(t)] = tiles[randi() % tiles.size()]
		_tree_t[_index(t)] = 0.0
		_species[_index(t)] = FieldSpecies.code(species_id)
	var members: Array[Vector2i] = []
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var n: Vector2i = t + Vector2i(dx, dy)
			if in_bounds(n) and _tree[_index(n)] >= 0 and _grove[_index(n)] == 0:
				members.append(n)
	if allow_grove and members.size() >= 4:
		for m in members:
			_grove[_index(m)] = 1
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var n: Vector2i = t + Vector2i(dx, dy)
				if can_plant(n):
					_set_clean(n, false)
					result["cleaned"].append(n)
		result["grove"] = true
		result["grove_tiles"] = members
	return result


func tree_count() -> int:
	var n := 0
	for v in _tree:
		if v >= 0:
			n += 1
	return n


## Belirli türden kaç ağaç var (akşam meyve geliri için).
func species_count(species_id: String) -> int:
	var code := FieldSpecies.code(species_id)
	var n := 0
	for i in _tree.size():
		if _tree[i] >= 0 and _species[i] == code:
			n += 1
	return n


func in_grove(t: Vector2i) -> bool:
	return in_bounds(t) and _grove[_index(t)] == 1


# ------------------------------------------------------------------ Yangın ve oduncu

func fire_at(t: Vector2i) -> bool:
	for f in fires:
		if f["t"] == t:
			return true
	return false


func start_fire(t: Vector2i) -> void:
	if in_bounds(t) and not fire_at(t):
		fires.append({"t": t, "age": 0.0, "next": 1.6})


func nearest_fire(world: Vector2, max_dist: float) -> Dictionary:
	var best: Dictionary = {}
	var best_d := max_dist
	for f in fires:
		var center := Vector2((f["t"].x + 0.5) * TILE, (f["t"].y + 0.5) * TILE)
		var d := world.distance_to(center)
		if d <= best_d:
			best_d = d
			best = f
	return best


func extinguish(f: Dictionary) -> void:
	fires.erase(f)


## Ağaç ya da kuru ağaç tutuşabilir.
func is_flammable(t: Vector2i) -> bool:
	return in_bounds(t) and (_tree[_index(t)] >= 0 or _dry[_index(t)] == 1)


## Yangınları ilerletir: komşu ağaçlara sıçrar, 6 sn sönmeyen ağaç yanıp kül olur.
## Bu çağrıda kül olan karo sayısını döndürür.
func update_fires(delta: float) -> int:
	var burned := 0
	for f in fires.duplicate():
		f["age"] += delta
		f["next"] -= delta
		if f["next"] <= 0.0:
			f["next"] = 2.0
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = f["t"] + d
				if is_flammable(n) and not fire_at(n) and randf() < 0.4:
					start_fire(n)
		if f["age"] >= 6.0:
			fires.erase(f)
			remove_tree_at(f["t"])
			burned += 1
	return burned


## Ağacı ve kuru ağacı söker, karoyu yeniden kirletir (yangın ve oduncu kullanır).
func remove_tree_at(t: Vector2i) -> void:
	if not in_bounds(t):
		return
	var i := _index(t)
	_tree[i] = -1
	_dry[i] = 0
	_species[i] = 0
	_grove[i] = 0
	if _ground[i] == G_LAND:
		_set_dirty(t)


func spawn_logger(pos: Vector2) -> void:
	logger = {"pos": pos, "state": "walk", "target": Vector2i(-1, -1), "cut": 0.0, "facing": 0, "flip": false, "step": 0, "walk": 0.0}


## Oduncuya en yakın ağaç karosu. Ağaç yoksa Vector2i(-1, -1).
func nearest_tree_tile(from: Vector2) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d := INF
	for i in _tree.size():
		if _tree[i] < 0:
			continue
		var t := Vector2i(i % COLS, i / COLS)
		var d := from.distance_to(Vector2((t.x + 0.5) * TILE, (t.y + 0.5) * TILE))
		if d < best_d:
			best_d = d
			best = t
	return best


## Temiz çimenlerden biri kirlenir: kirli bir karoyla komşu, ağaçsız karo. Kaynak yakını tercih edilir.
## Kirlenen karoyu döndürür, uygun karo yoksa Vector2i(-1, -1).
func pollute_one(prefer_sources: bool = true) -> Vector2i:
	var candidates: Array[Vector2i] = []
	var near_source: Array[Vector2i] = []
	var sources := active_chimneys() if prefer_sources else ([] as Array[Vector2i])
	var v := _view_clamped().grow(6)
	for y in range(maxi(v.position.y, 0), mini(v.end.y, ROWS)):
		for x in range(maxi(v.position.x, 0), mini(v.end.x, COLS)):
			var t := Vector2i(x, y)
			if not _qualifies(t, false):
				continue
			candidates.append(t)
			for c in sources:
				if Vector2(t - c).length() <= 12.0:
					near_source.append(t)
					break
	if candidates.is_empty():
		return Vector2i(-1, -1)
	var pool := near_source if (not near_source.is_empty() and randf() < 0.6) else candidates
	var chosen: Vector2i = pool.pick_random()
	_set_dirty(chosen)
	return chosen


## Yeşil alanı hedef orana getirir: eksikse temiz bölgelerin kenarları yeşillenir (ara sıra ağaç çıkar),
## fazlaysa yeşil kenarlar kirlenir. Çevre göstergesine bağlı. Değişen karo sayısını döndürür.
func sync_green_to(target_ratio: float) -> int:
	var diff := int(round(((1.0 - target_ratio) * _land_total - _dirty_count) * -1.0))
	if diff > 0:
		return _convert(diff, true)
	if diff < 0:
		return _convert(-diff, false)
	return 0


func _convert(count: int, to_clean: bool) -> int:
	var frontier: Array[Vector2i] = []
	for y in ROWS:
		for x in COLS:
			var t := Vector2i(x, y)
			if _qualifies(t, to_clean):
				frontier.append(t)
	var done := 0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	while done < count and not frontier.is_empty():
		var pick := rng.randi() % frontier.size()
		var t: Vector2i = frontier[pick]
		frontier[pick] = frontier.back()
		frontier.pop_back()
		if not _qualifies(t, to_clean):
			continue
		var i := _index(t)
		if to_clean:
			_set_clean(t, false)
			if rng.randf() < 0.1 and _tree[i] < 0 and not trash_at(t):
				_tree[i] = TREE_TILES[rng.randi_range(0, TREE_TILES.size() - 1)]
				_tree_t[i] = 0.0
				_species[i] = 1
		else:
			_set_dirty(t)
		done += 1
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = t + d
			if _qualifies(n, to_clean):
				frontier.append(n)
	return done


## Yeşillenecek karo: kirli kara ve temiz kara komşusu var. Kirlenecek karo: temiz, ağaçsız ve kirli komşusu var.
func _qualifies(t: Vector2i, to_clean: bool) -> bool:
	if not is_free_land(t):
		return false
	var i := _index(t)
	if to_clean:
		if _dirty[i] != 1:
			return false
	else:
		if _dirty[i] != 0 or _tree[i] >= 0:
			return false
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var n: Vector2i = t + d
		if is_free_land(n) and (is_dirty(n) != to_clean):
			return true
	return false


func _set_clean(t: Vector2i, instant: bool) -> void:
	var i := _index(t)
	if _dirty[i] == 1:
		_dirty[i] = 0
		_dirty_count -= 1
	if _dry[i] == 1:  # kuru ağaç söker, bazen yerine yeşil ağaç çıkar
		_dry[i] = 0
		if randf() < 0.4 and _tree[i] < 0:
			_tree[i] = TREE_TILES[randi() % TREE_TILES.size()]
			_tree_t[i] = 0.0
			_species[i] = 1
	if instant or not _is_in_view(t):
		_clean_t[i] = 1.0


func _set_dirty(t: Vector2i) -> void:
	var i := _index(t)
	if _dirty[i] == 0:
		_dirty[i] = 1
		_dirty_count += 1
	if not _is_in_view(t):
		_clean_t[i] = 0.0


func _index(t: Vector2i) -> int:
	return t.y * COLS + t.x


func _is_in_view(t: Vector2i) -> bool:
	return view_tiles.has_point(t)


func _view_clamped() -> Rect2i:
	var v := view_tiles
	var x0 := clampi(v.position.x, 0, COLS)
	var y0 := clampi(v.position.y, 0, ROWS)
	var x1 := clampi(v.end.x, 0, COLS)
	var y1 := clampi(v.end.y, 0, ROWS)
	return Rect2i(x0, y0, x1 - x0, y1 - y0)


func _atlas_rect(tile: int) -> Rect2:
	return Rect2((tile % ATLAS_COLS) * TILE, (tile / ATLAS_COLS) * TILE, TILE, TILE)


## 0'dan 1'e büyürken 1'i biraz aşıp geri döner (zıplayan büyüme hissi).
func _overshoot(t: float) -> float:
	if t >= 1.0:
		return 1.0
	var c := 1.70158
	var u := t - 1.0
	return maxf(0.05, 1.0 + (c + 1.0) * u * u * u + c * u * u)


# ------------------------------------------------------------------ Çizim

func _draw() -> void:
	var v := _view_clamped()
	for y in range(v.position.y, v.end.y):
		for x in range(v.position.x, v.end.x):
			_draw_ground(x, y)
	var player_row := clampi(int(player_pos.y / TILE), 0, ROWS - 1)
	for y in range(v.position.y, v.end.y):
		for x in range(v.position.x, v.end.x):
			var i := y * COLS + x
			if _dry[i] == 1 and _dirty[i] == 1:
				_draw_dry_tree(x, y, i)
			if _tree[i] >= 0:
				_draw_tree(x, y, _tree[i], _tree_t[i], _species[i], _grove[i] == 1)
		if _props_by_row.has(y):
			for p in _props_by_row[y]:
				if (p["t"] as Vector2i).x >= v.position.x and (p["t"] as Vector2i).x < v.end.x:
					_draw_prop(p)
		if _buildings_by_row.has(y):
			for entry in _buildings_by_row[y]:
				_draw_building_row(entry[0], entry[1], v)
		for p in pois:
			if (p["t"] as Vector2i).y == y and p["active"]:
				_draw_poi(p)
		for item in trash:
			if (item["tile"] as Vector2i).y == y:
				_draw_trash(item)
		for n in npcs:
			if (n["t"] as Vector2i).y == y and n["active"]:
				_draw_npc(n)
		for mb in mob:
			if int((mb["pos"] as Vector2).y / TILE) == y:
				_draw_protester(mb)
		for vil in villagers:
			if int(vil["pos"].y / TILE) == y:
				_draw_villager(vil)
		for f in fires:
			if (f["t"] as Vector2i).y == y:
				_draw_fire(f)
		if not logger.is_empty() and int(logger["pos"].y / TILE) == y:
			_draw_logger()
		if not rabbit.is_empty() and int(rabbit["pos"].y / TILE) == y:
			_draw_rabbit()
		for d in drops:
			if int(d["pos"].y / TILE) == y:
				_draw_drop(d)
		for hz in hazards:
			if int(hz["pos"].y / TILE) == y:
				_draw_hazard(hz)
		if y == player_row and _player_layer == null:
			_draw_player()
	_draw_smoke(v)
	_draw_clean_steam(v)
	_draw_shots()
	_draw_butterflies()
	_draw_signs(v)
	_draw_landmarks(v)
	_draw_market_sign()
	_draw_fog(v)


func _draw_ground(x: int, y: int) -> void:
	var i := y * COLS + x
	var pos := Vector2(x * TILE, y * TILE)
	var rect := Rect2(pos, Vector2(TILE, TILE))
	match _ground[i]:
		G_WATER:
			_draw_water(x, y, pos)
		G_BRIDGE:
			_draw_water(x, y, pos)
			_draw_bridge(x, y, pos)
		G_ROAD:
			_draw_road(x, y, pos)
		G_PLAZA:
			_draw_plaza(x, y, pos)
		_:
			var t := _clean_t[i]
			if t < 1.0:
				var tint: Color = ZONE_DIRTY_TINT.get(_zone[i], DIRTY_TINT)
				draw_texture_rect_region(ATLAS, rect, _atlas_rect(T_DIRT), tint)
				_draw_soot(x, y, pos, 1.0 - t)
				if _zone[i] == Zone.FARM and y % 2 == 0:  # kuru sürülmüş tarla
					draw_rect(Rect2(pos + Vector2(0, 5), Vector2(TILE, 1)), Color(0.25, 0.2, 0.15, 0.55 * (1.0 - t)))
					draw_rect(Rect2(pos + Vector2(0, 11), Vector2(TILE, 1)), Color(0.25, 0.2, 0.15, 0.55 * (1.0 - t)))
			if t > 0.0:
				var variant := _variant[i]
				var tile := T_GRASS
				if variant < 12:
					tile = T_TUFT
				elif variant < 16:
					tile = T_FLOWER
				draw_texture_rect_region(ATLAS, rect, _atlas_rect(tile), Color(1, 1, 1, t))


## Kirli karoda sabit konumlu koyu lekeler: kirlilik hissi.
func _draw_soot(x: int, y: int, pos: Vector2, strength: float) -> void:
	var h := (x * 73856093) ^ (y * 19349663)
	for n in 3:
		var sx := float((h >> (n * 4)) & 15)
		var sy := float((h >> (n * 4 + 2)) & 15)
		draw_rect(Rect2(pos + Vector2(sx, sy), Vector2(2, 1)), Color(0.12, 0.1, 0.09, 0.5 * strength))


func _draw_water(x: int, y: int, pos: Vector2) -> void:
	var poison := Color(0.4, 0.38, 0.2)
	var clean := Color(0.24, 0.52, 0.85)
	var base := poison.lerp(clean, water_quality)
	draw_rect(Rect2(pos, Vector2(TILE, TILE)), base)
	var wave := sin(_time * 2.0 + x * 0.8 + y * 0.5)
	var light := base.lightened(0.25)
	draw_rect(Rect2(pos + Vector2(3 + wave * 2.0, 4), Vector2(6, 1)), light)
	draw_rect(Rect2(pos + Vector2(8 - wave * 2.0, 11), Vector2(5, 1)), light)
	# Kıyı: kara komşusu varsa açık kenar çizgisi
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var n: Vector2i = Vector2i(x, y) + d
		if in_bounds(n) and _ground[_index(n)] == G_LAND:
			var edge := Color(0.55, 0.5, 0.35).lerp(Color(0.8, 0.9, 1.0), water_quality)
			match d:
				Vector2i.LEFT: draw_rect(Rect2(pos, Vector2(2, TILE)), edge)
				Vector2i.RIGHT: draw_rect(Rect2(pos + Vector2(TILE - 2, 0), Vector2(2, TILE)), edge)
				Vector2i.UP: draw_rect(Rect2(pos, Vector2(TILE, 2)), edge)
				_: draw_rect(Rect2(pos + Vector2(0, TILE - 2), Vector2(TILE, 2)), edge)


func _draw_road(x: int, y: int, pos: Vector2) -> void:
	draw_rect(Rect2(pos, Vector2(TILE, TILE)), Color(0.5, 0.48, 0.47))
	var h := (x * 92837111) ^ (y * 689287499)
	for n in 4:
		var sx := float((h >> (n * 5)) & 7) * 2.0
		var sy := float((h >> (n * 5 + 3)) & 7) * 2.0
		draw_rect(Rect2(pos + Vector2(sx, sy), Vector2(3, 2)), Color(0.62, 0.6, 0.59))
		draw_rect(Rect2(pos + Vector2(sx, sy + 2), Vector2(3, 1)), Color(0.38, 0.36, 0.36))


func _draw_plaza(x: int, y: int, pos: Vector2) -> void:
	var checker := (x + y) % 2 == 0
	draw_rect(Rect2(pos, Vector2(TILE, TILE)), Color(0.66, 0.62, 0.56) if checker else Color(0.6, 0.56, 0.5))
	draw_rect(Rect2(pos, Vector2(TILE, 1)), Color(0.45, 0.42, 0.38))
	draw_rect(Rect2(pos, Vector2(1, TILE)), Color(0.45, 0.42, 0.38))
	draw_rect(Rect2(pos + Vector2(8, 8), Vector2(1, 1)), Color(0.8, 0.77, 0.7))
	var h := (x * 73856093) ^ (y * 19349663)
	draw_rect(Rect2(pos + Vector2(float(h & 7) * 1.5 + 2.0, float((h >> 3) & 7) * 1.5 + 2.0), Vector2(2, 1)), Color(0.78, 0.74, 0.66))


func _draw_bridge(x: int, y: int, pos: Vector2) -> void:
	for k in 4:
		var plank := Color(0.58, 0.4, 0.22) if (k + x) % 2 == 0 else Color(0.5, 0.34, 0.18)
		draw_rect(Rect2(pos + Vector2(k * 4, 0), Vector2(4, TILE)), plank)
		draw_rect(Rect2(pos + Vector2(k * 4 + 3, 0), Vector2(1, TILE)), Color(0.3, 0.2, 0.1))
	if y > 0 and _ground[_index(Vector2i(x, y - 1))] != G_BRIDGE:
		draw_rect(Rect2(pos + Vector2(0, 0), Vector2(TILE, 3)), Color(0.35, 0.22, 0.1))
	if y < ROWS - 1 and _ground[_index(Vector2i(x, y + 1))] != G_BRIDGE:
		draw_rect(Rect2(pos + Vector2(0, TILE - 3), Vector2(TILE, 3)), Color(0.35, 0.22, 0.1))


func _draw_dry_tree(x: int, y: int, i: int) -> void:
	var base := Vector2(x * TILE + TILE / 2.0, (y + 1) * TILE)
	var tile := DRY_TREE_TILES[_variant[i] % DRY_TREE_TILES.size()]
	draw_texture_rect_region(ATLAS, Rect2(base - Vector2(TILE / 2.0, TILE), Vector2(TILE, TILE)),
		_atlas_rect(tile), Color(0.62, 0.55, 0.5))


func _draw_tree(x: int, y: int, tile_index: int, grow: float, species_code: int, in_grove_flag: bool) -> void:
	var base := Vector2(x * TILE + TILE / 2.0, (y + 1) * TILE)
	var info := FieldSpecies.data(FieldSpecies.id_from_code(species_code) if species_code > 0 else "pine")
	var scale_k: float = info["scale"]
	draw_set_transform(base + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	if in_grove_flag:  # koru: ağacın altında hafif yeşil ışık
		draw_circle(Vector2.ZERO, 11.0, Color(0.5, 0.95, 0.4, 0.22 + 0.08 * sin(_time * 2.0 + x)))
	draw_circle(Vector2.ZERO, 6.0 * minf(grow * 1.2, 1.0) * scale_k, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var s := _overshoot(grow) * scale_k
	var size := Vector2(TILE, TILE) * s
	var rect := Rect2(base - Vector2(size.x / 2.0, size.y), size)
	draw_texture_rect_region(ATLAS, rect, _atlas_rect(tile_index))
	if species_code == 3 and grow >= 1.0:  # meyve ağacı: kırmızı elmalar
		for k in 4:
			draw_rect(Rect2(rect.position + Vector2(3 + k * 3 + (k % 2) * 1, 4 + (k * 5) % 7), Vector2(2, 2)), Color(0.9, 0.18, 0.2))


func _draw_prop(p: Dictionary) -> void:
	if p.has("deco"):
		_draw_deco(p)
		return
	var t: Vector2i = p["t"]
	draw_texture_rect_region(ATLAS, Rect2(Vector2(t.x * TILE, t.y * TILE), Vector2(TILE, TILE)), _atlas_rect(p["atlas"]))


func _draw_building_row(b: Dictionary, row: int, v: Rect2i) -> void:
	var rect: Rect2i = b["rect"]
	if rect.end.x < v.position.x or rect.position.x >= v.end.x:
		return
	var rows: Array = b["rows"]
	var y := rect.position.y + row
	var tint := Color(0.7, 0.68, 0.78) if (b["kind"] == "factory" or b["kind"] == "lojman") else Color.WHITE  # fabrikalar çelik gri
	if b["kind"] == "factory" and b["filtered"]:
		tint = Color(0.8, 0.9, 0.86)   # filtreli fabrika: daha açık, yeşilimsi, temiz
	elif b["kind"] == "factory" and filter_enabled:
		tint = Color(0.6, 0.55, 0.62)  # filtresiz fabrika: is içinde, koyu
	for col in rect.size.x:
		var tile: int = rows[row][col]
		if tile < 0:
			continue
		draw_texture_rect_region(ATLAS, Rect2(Vector2((rect.position.x + col) * TILE, y * TILE), Vector2(TILE, TILE)), _atlas_rect(tile), tint)
	_draw_special_building_row(b, row, y)
	if b["kind"] == "factory":
		_draw_factory_details(b, row, y)
	if b["kind"] == "market" and row == rows.size() - 1:
		var left := Vector2((rect.position.x - 1) * TILE, y * TILE)
		draw_texture_rect_region(ATLAS, Rect2(left, Vector2(TILE, TILE)), _atlas_rect(TILE_SIGN))
		var right := Vector2(rect.end.x * TILE, y * TILE)
		draw_texture_rect_region(ATLAS, Rect2(right, Vector2(TILE, TILE)), _atlas_rect(106))


## Fabrika: bacalar ve pencereler. Filtresiz: kızıl alev, kırmızı uyarı lambası, uyarı levhası, turuncu titreyen pencere.
## Filtreli: bacanın üstünde büyük yeşil filtre kutusu, çatıda yeşil yaprak levhası, sakin pencereler.
func _draw_factory_details(b: Dictionary, row: int, y: int) -> void:
	var rect: Rect2i = b["rect"]
	var filtered: bool = b["filtered"]
	if row == 0:
		for off in b["chimneys"]:
			var cx: float = (rect.position.x + off.x) * TILE + 4
			var top := y * TILE - 20.0
			draw_rect(Rect2(cx, top, 8, 26), Color(0.16, 0.14, 0.15))
			draw_rect(Rect2(cx + 1, top, 2, 26), Color(0.3, 0.27, 0.28))
			draw_rect(Rect2(cx - 1, top - 2, 10, 3), Color(0.1, 0.09, 0.1))
			if filtered:
				_draw_filter_unit(cx, top)
			else:
				var glow := 0.55 + 0.45 * sin(_time * 4.0 + cx)
				draw_rect(Rect2(cx + 1, top - 3, 6, 2), Color(1.0, 0.5, 0.15, glow))
				if filter_enabled:  # uyarı lambası: bu baca hâlâ zehir saçıyor
					var blink := 0.5 + 0.5 * sin(_time * 6.0 + cx)
					draw_circle(Vector2(cx + 4, top - 6), 3.5, Color(1.0, 0.1, 0.05, 0.18 + 0.3 * blink))
					draw_circle(Vector2(cx + 4, top - 6), 2.0, Color(1.0, 0.2, 0.12, 0.5 + 0.5 * blink))
		_draw_factory_badge(b, y)
	elif row == 1 and filter_enabled and not filtered:
		# Filtre mekaniği açıkken kapının önünde zıplayan ok: "buraya gel"
		var door_x := (rect.position.x + rect.size.x / 2.0) * TILE
		var bob := sin(_time * 5.0) * 2.0
		draw_colored_polygon(PackedVector2Array([Vector2(door_x - 5, y * TILE + 20 + bob), Vector2(door_x + 5, y * TILE + 20 + bob), Vector2(door_x, y * TILE + 28 + bob)]), Color(0.4, 0.85, 0.45))
	if row == 1:
		for col in range(1, rect.size.x - 1, 2):
			var wx := (rect.position.x + col) * TILE + 3.0
			draw_rect(Rect2(wx, y * TILE + 3, 10, 7), Color(0.08, 0.07, 0.08))
			if filtered:   # sakin, soğuk ışık
				draw_rect(Rect2(wx + 1, y * TILE + 4, 8, 5), Color(0.75, 0.95, 0.92, 0.85))
				draw_rect(Rect2(wx + 1, y * TILE + 4, 8, 1), Color(1, 1, 1, 0.6))
			else:
				var flick := 0.6 + 0.4 * sin(_time * 3.0 + col * 1.7)
				draw_rect(Rect2(wx + 1, y * TILE + 4, 8, 5), Color(1.0, 0.6, 0.2, 0.75 * flick))


## Bacanın tepesine takılan yeşil filtre kutusu (yaprak işaretli).
func _draw_filter_unit(cx: float, top: float) -> void:
	var dark := Color(0.08, 0.22, 0.1)
	draw_rect(Rect2(cx - 3, top - 14, 14, 13), dark)
	draw_rect(Rect2(cx - 2, top - 13, 12, 11), Color(0.3, 0.7, 0.36))
	draw_rect(Rect2(cx - 2, top - 13, 12, 3), Color(0.55, 0.93, 0.56))
	draw_rect(Rect2(cx - 2, top - 6, 12, 1), Color(0.16, 0.42, 0.2))
	draw_rect(Rect2(cx - 1, top - 16, 10, 3), dark)
	# beyaz yaprak
	draw_rect(Rect2(cx + 2, top - 11, 4, 3), Color(1, 1, 1, 0.95))
	draw_rect(Rect2(cx + 4, top - 8, 1, 3), Color(1, 1, 1, 0.95))
	var tw := 0.5 + 0.5 * sin(_time * 3.0 + cx)
	draw_rect(Rect2(cx + 7, top - 12, 1, 1), Color(1, 1, 0.8, 0.4 + 0.5 * tw))


## Çatının ortasında levha: filtreli fabrikada yeşil yaprak, filtresiz fabrikada kırmızı uyarı (mekanik açıkken).
func _draw_factory_badge(b: Dictionary, y: int) -> void:
	var rect: Rect2i = b["rect"]
	var bx := (rect.position.x + rect.size.x / 2.0) * TILE
	var by := y * TILE - 8.0
	if b["filtered"]:
		draw_rect(Rect2(bx - 1, by - 8, 2, 16), Color(0.2, 0.15, 0.1))
		var sway := sin(_time * 2.0 + bx) * 0.8
		draw_rect(Rect2(bx + 1, by - 10, 13 + sway, 9), Color(0.08, 0.22, 0.1))
		draw_rect(Rect2(bx + 2, by - 9, 11 + sway, 7), Color(0.34, 0.76, 0.4))
		draw_rect(Rect2(bx + 5, by - 8, 4, 3), Color(1, 1, 1, 0.95))
		draw_rect(Rect2(bx + 7, by - 5, 1, 3), Color(1, 1, 1, 0.95))
	elif filter_enabled:
		var pulse := 0.75 + 0.25 * sin(_time * 5.0 + bx)
		draw_colored_polygon(PackedVector2Array([Vector2(bx - 8, by + 3), Vector2(bx + 8, by + 3), Vector2(bx, by - 11)]), Color(0.1, 0.05, 0.05))
		draw_colored_polygon(PackedVector2Array([Vector2(bx - 6, by + 1), Vector2(bx + 6, by + 1), Vector2(bx, by - 8)]), Color(0.95, 0.25 * pulse + 0.1, 0.12))
		draw_rect(Rect2(bx - 1, by - 5, 2, 4), Color(1, 1, 1, 0.95))
		draw_rect(Rect2(bx - 1, by, 2, 2), Color(1, 1, 1, 0.95))


func _draw_smoke(v: Rect2i) -> void:
	for c in active_chimneys():
		if c.x < v.position.x - 3 or c.x > v.end.x + 3 or c.y < v.position.y - 10 or c.y > v.end.y + 3:
			continue
		var base := Vector2(c.x * TILE + 8, c.y * TILE - 24)
		var phase := float((c.x * 31 + c.y * 17) % 100)
		for n in 7:
			var rise := fmod(_time * 7.0 + n * 11.0 + phase, 77.0)
			var alpha := 0.62 * (1.0 - rise / 77.0)
			var sway := sin(_time * 0.6 + n + phase) * 5.0
			draw_circle(base + Vector2(sway + rise * 0.3, -rise), 4.5 + rise * 0.14, Color(0.1, 0.09, 0.1, alpha))


## Filtreli bacalardan hafif, temiz beyaz buhar (çalışıyor ama zehir yok).
func _draw_clean_steam(v: Rect2i) -> void:
	for b in buildings:
		if b["kind"] != "factory" or not b["filtered"]:
			continue
		var rect: Rect2i = b["rect"]
		if rect.end.x < v.position.x - 3 or rect.position.x > v.end.x + 3 or rect.end.y < v.position.y - 6 or rect.position.y > v.end.y + 6:
			continue
		for off in b["chimneys"]:
			var base := Vector2((rect.position.x + off.x) * TILE + 8, rect.position.y * TILE - 38)
			for n in 3:
				var rise := fmod(_time * 6.0 + n * 9.0 + off.x * 7.0, 27.0)
				var alpha := 0.38 * (1.0 - rise / 27.0)
				draw_circle(base + Vector2(sin(_time + n) * 2.0, -rise), 2.5 + rise * 0.06, Color(0.95, 1.0, 0.97, alpha))


# ------------------------------------------------------------------ Başkanın evi, öfkeli kalabalık

func set_home(rect: Rect2i) -> void:
	var windows: Array = []
	for i in HOME_WINDOWS:
		windows.append(false)
	home = {"rect": rect, "windows": windows, "splats": [], "mood": 0}


## Kapının önü: etkileşim noktası ve kalabalığın toplandığı yer.
func home_door_world() -> Vector2:
	var r: Rect2i = home["rect"]
	return Vector2((r.position.x + 2.5) * TILE, r.end.y * TILE + 6.0)


func home_window_world(i: int) -> Vector2:
	var r: Rect2i = home["rect"]
	return Vector2((r.position.x + 1.5 + i) * TILE, (r.position.y + 1) * TILE + 8.0)


func broken_windows() -> int:
	if home.is_empty():
		return 0
	var n := 0
	for w in home["windows"]:
		if w:
			n += 1
	return n


func repair_home() -> void:
	if home.is_empty():
		return
	for i in HOME_WINDOWS:
		home["windows"][i] = false
	home["splats"].clear()


## x: filtreli fabrika sayısı, y: toplam fabrika.
func factory_counts() -> Vector2i:
	var done := 0
	var total := 0
	for b in buildings:
		if b["kind"] == "factory":
			total += 1
			if b["filtered"]:
				done += 1
	return Vector2i(done, total)


func _minimap_building_color(b: Dictionary) -> Color:
	match b["kind"]:
		"market":
			return Color(0.8, 0.45, 0.3)
		"mayor_home":
			return Color(0.98, 0.78, 0.25)
		"factory":
			if b["filtered"]:
				return Color(0.3, 0.85, 0.4)
			if filter_enabled:
				return Color(0.95, 0.3, 0.2)
	return Color(0.55, 0.52, 0.55)


func spawn_mob(count: int) -> void:
	mob.clear()
	if home.is_empty():
		return
	var door := home_door_world()
	var guard := 0
	while mob.size() < count and guard < 300:
		guard += 1
		var p := door + Vector2(randf_range(-80.0, 80.0), randf_range(16.0, 72.0))
		var t := tile_at(p)
		if not in_bounds(t) or is_solid_world(p) or _locked[_index(t)] == 1 or _ground[_index(t)] == G_WATER:
			continue
		var crowded := false
		for m in mob:
			if (m["pos"] as Vector2).distance_to(p) < 16.0:
				crowded = true
		if crowded:
			continue
		mob.append({"pos": p, "style": FieldArt.VILLAGER_STYLES[randi() % FieldArt.VILLAGER_STYLES.size()], "shout": "",
			"shout_t": randf_range(0.5, 3.0), "throw_t": randf_range(4.0, 9.0), "phase": randf() * TAU})


func _update_mob(delta: float) -> void:
	for m in mob:
		m["shout_t"] = float(m["shout_t"]) - delta
		if float(m["shout_t"]) > 0.0:
			continue
		if m["shout"] != "":
			m["shout"] = ""
			m["shout_t"] = randf_range(2.0, 5.0)
		else:
			m["shout"] = tr("PROTEST_%d" % randi_range(1, 10))
			m["shout_t"] = 2.4


func _update_shots(delta: float) -> void:
	for i in range(shots.size() - 1, -1, -1):
		var s: Dictionary = shots[i]
		s["t"] = float(s["t"]) + delta
		if float(s["t"]) >= float(s["dur"]):
			shots.remove_at(i)
			shot_landed.emit(s)


func _draw_shots() -> void:
	for s in shots:
		var k := clampf(float(s["t"]) / float(s["dur"]), 0.0, 1.0)
		var p: Vector2 = (s["from"] as Vector2).lerp(s["to"], k) + Vector2(0, -sin(PI * k) * 26.0)
		if int(s["kind"]) == 0:
			draw_circle(p, 3.0, Color(0.1, 0.09, 0.09))
			draw_circle(p, 2.2, Color(0.66, 0.64, 0.6))
		else:
			draw_circle(p, 3.4, Color(0.4, 0.05, 0.04))
			draw_circle(p, 2.7, Color(0.9, 0.18, 0.14))
			draw_circle(p + Vector2(-0.8, -0.8), 0.9, Color(1, 0.7, 0.6))


## Öfkeli vatandaş: zıplar, pankart sallar, ara sıra bağırır.
func _draw_protester(m: Dictionary) -> void:
	var pos: Vector2 = m["pos"]
	var jump := absf(sin(_time * 7.0 + float(m["phase"]))) * 2.5
	var ground := Vector2(roundf(pos.x), roundf(pos.y))
	var origin := ground + Vector2(0, -roundf(jump))
	draw_set_transform(ground + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 4.5, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var to_home := home_door_world() + Vector2(0, -28) - pos
	var facing := 0
	var flip := false
	if absf(to_home.x) > absf(to_home.y) * 1.3:
		facing = 2
		flip = to_home.x < 0.0
	elif to_home.y < 0.0:
		facing = 1
	var tex := FieldArt.person(m["style"], facing, 1 if jump > 1.2 else 0)
	var size := Vector2(FieldArt.PLAYER_W, FieldArt.PLAYER_H)
	var top_left := origin - Vector2(size.x / 2.0, size.y - 1.0)
	if facing == 2 and flip:
		draw_texture_rect(tex, Rect2(top_left + Vector2(size.x, 0), Vector2(-size.x, size.y)), false)
	else:
		draw_texture_rect(tex, Rect2(top_left, size), false)
	# Pankart
	var sway := sin(_time * 7.0 + float(m["phase"])) * 2.0
	var px := origin.x - 7.0 + sway
	var py := origin.y - size.y - 12.0
	draw_line(Vector2(origin.x + 3, origin.y - size.y + 6), Vector2(px + 7, py + 9), Color(0.35, 0.22, 0.1), 1.0)
	draw_rect(Rect2(px - 1, py - 1, 16, 11), Color(0.15, 0.1, 0.07))
	draw_rect(Rect2(px, py, 14, 9), Color(0.96, 0.92, 0.78))
	draw_rect(Rect2(px + 2, py + 2, 10, 2), Color(0.8, 0.15, 0.12))
	draw_rect(Rect2(px + 2, py + 5, 7, 2), Color(0.8, 0.15, 0.12))
	# Öfke işareti
	var a := 0.5 + 0.5 * sin(_time * 10.0 + float(m["phase"]))
	var hx := origin.x + 7.0
	var hy := origin.y - size.y + 3.0
	var red := Color(0.95, 0.15, 0.1, 0.5 + 0.5 * a)
	draw_line(Vector2(hx - 2, hy - 2), Vector2(hx + 2, hy + 2), red, 1.0)
	draw_line(Vector2(hx + 2, hy - 2), Vector2(hx - 2, hy + 2), red, 1.0)
	if m["shout"] != "":
		var font: Font = ThemeDB.fallback_font
		var text: String = m["shout"]
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		var bp := Vector2(origin.x - w / 2.0, py - 6.0)
		draw_rect(Rect2(bp.x - 3, bp.y - 9, w + 6, 12), Color(0.12, 0.08, 0.06, 0.92))
		draw_string(font, bp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.85, 0.75))


func _draw_heart(c: Vector2, r: float, col: Color) -> void:
	draw_circle(c + Vector2(-r * 0.55, 0), r * 0.6, col)
	draw_circle(c + Vector2(r * 0.55, 0), r * 0.6, col)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 1.1, r * 0.2), c + Vector2(r * 1.1, r * 0.2), c + Vector2(0, r * 1.5)]), col)


## Başkanın evi: pencereler (sağlam / kırık), mutluysa bayram süsü ve çiçek, öfkeliyse yazılama ve domates lekeleri.
func _draw_home_row(b: Dictionary, row: int, y: int) -> void:
	if home.is_empty():
		return
	var rect: Rect2i = b["rect"]
	var x0 := float(rect.position.x * TILE)
	var w := float(rect.size.x * TILE)
	var mood := int(home["mood"])
	var ty := float(y * TILE)
	if row == 0:
		var fx := x0 + w - 12.0   # çatıda yeşil yapraklı bayrak
		draw_rect(Rect2(fx, ty - 16, 1, 18), Color(0.2, 0.15, 0.1))
		var fl := sin(_time * 4.0) * 1.0
		draw_rect(Rect2(fx + 1, ty - 16, 10 + fl, 7), Color(0.1, 0.25, 0.12))
		draw_rect(Rect2(fx + 1, ty - 15, 9 + fl, 5), Color(0.34, 0.76, 0.4))
		draw_rect(Rect2(fx + 4, ty - 14, 3, 2), Color(1, 1, 1, 0.9))
		if mood > 0:   # bayram: renkli flamalar ve yükselen kalpler
			var flags := [Color(0.95, 0.35, 0.3), Color(0.95, 0.8, 0.25), Color(0.35, 0.75, 0.95), Color(0.5, 0.85, 0.4)]
			for k in 8:
				var bx := x0 + 3.0 + k * (w - 6.0) / 7.0
				var by := ty + 4.0 + sin(k * 0.9) * 2.0
				draw_colored_polygon(PackedVector2Array([Vector2(bx - 2, by), Vector2(bx + 2, by), Vector2(bx, by + 4)]), flags[k % 4])
			for k in 2:
				var rise := fmod(_time * 10.0 + k * 20.0, 40.0)
				_draw_heart(Vector2(x0 + w * (0.3 + 0.3 * k) + sin(_time + k) * 3.0, ty - 4.0 - rise), 3.0, Color(0.95, 0.3, 0.4, 1.0 - rise / 40.0))
	elif row == 1:
		for i in HOME_WINDOWS:
			_draw_home_window(x0 + (1 + i) * TILE, ty, bool(home["windows"][i]), mood)
	else:
		var font: Font = ThemeDB.fallback_font
		var plate := tr("HOME_PLATE")
		var pw := font.get_string_size(plate, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
		var px := x0 + 3.5 * TILE - pw / 2.0
		draw_rect(Rect2(px - 2, ty + 3, pw + 4, 9), Color(0.3, 0.2, 0.1))
		draw_string(font, Vector2(px, ty + 10.5), plate, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.92, 0.7))
		if mood < 0:
			draw_set_transform(Vector2(x0 + 3, ty + 14), -0.1, Vector2.ONE)
			draw_string(font, Vector2.ZERO, tr("HOME_GRAFFITI"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.1, 0.08))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if mood > 0:   # kapının iki yanında çiçekler
			var petals := [Color(0.95, 0.35, 0.4), Color(1.0, 0.85, 0.3), Color(0.9, 0.5, 0.9)]
			for k in 6:
				var fxp := x0 + 2.0 * TILE + (k - 2.5) * 4.0 + (-9.0 if k < 3 else 9.0)
				draw_rect(Rect2(fxp, ty + 11, 1, 4), Color(0.2, 0.5, 0.25))
				draw_circle(Vector2(fxp + 0.5, ty + 10), 1.6, petals[k % 3])
		for i in HOME_WINDOWS:   # kırık camın yere dökülen parçaları
			if bool(home["windows"][i]):
				var gx := x0 + (1 + i) * TILE + 8.0
				draw_colored_polygon(PackedVector2Array([Vector2(gx - 4, ty + 15), Vector2(gx - 1, ty + 15), Vector2(gx - 3, ty + 12)]), Color(0.6, 0.85, 0.95, 0.9))
				draw_colored_polygon(PackedVector2Array([Vector2(gx + 1, ty + 15), Vector2(gx + 4, ty + 15), Vector2(gx + 3, ty + 13)]), Color(0.75, 0.92, 1.0, 0.9))
	# Domates ve yumurta lekeleri (bulundukları satırda çizilir)
	for sp in home["splats"]:
		var sp_pos: Vector2 = sp["p"]
		if int(sp_pos.y / TILE) != row:
			continue
		var c := Vector2(x0, float(rect.position.y * TILE)) + sp_pos
		var col: Color = sp["c"]
		draw_circle(c, 3.0, col)
		draw_circle(c + Vector2(2, 1), 1.8, col)
		draw_circle(c + Vector2(-2, 2), 1.4, col)
		draw_line(c + Vector2(0, 2), c + Vector2(0, 6), col, 1.0)
		draw_line(c + Vector2(-2, 3), c + Vector2(-2, 5), col, 1.0)


func _draw_home_window(x: float, y: float, broken: bool, mood: int) -> void:
	var frame := Color(0.22, 0.13, 0.08)
	draw_rect(Rect2(x + 1, y + 2, 14, 12), frame)
	if not broken:
		draw_rect(Rect2(x + 2, y + 3, 12, 10), Color(0.5, 0.78, 0.92))
		draw_rect(Rect2(x + 2, y + 3, 12, 3), Color(0.72, 0.9, 0.98))
		draw_line(Vector2(x + 4, y + 12), Vector2(x + 8, y + 4), Color(1, 1, 1, 0.55), 1.0)
		draw_rect(Rect2(x + 8, y + 3, 1, 10), frame)
		draw_rect(Rect2(x + 2, y + 7, 12, 1), frame)
		draw_rect(Rect2(x + 2, y + 3, 3, 4), Color(0.75, 0.25, 0.25, 0.9))   # perdeler
		draw_rect(Rect2(x + 11, y + 3, 3, 4), Color(0.75, 0.25, 0.25, 0.9))
	else:
		draw_rect(Rect2(x + 2, y + 3, 12, 10), Color(0.08, 0.06, 0.07))
		var shard := Color(0.55, 0.8, 0.92, 0.9)
		draw_colored_polygon(PackedVector2Array([Vector2(x + 2, y + 3), Vector2(x + 6, y + 3), Vector2(x + 2, y + 8)]), shard)
		draw_colored_polygon(PackedVector2Array([Vector2(x + 14, y + 13), Vector2(x + 10, y + 13), Vector2(x + 14, y + 9)]), shard)
		var crack := Color(0.95, 0.97, 1.0, 0.9)
		draw_line(Vector2(x + 8, y + 8), Vector2(x + 3, y + 4), crack, 1.0)
		draw_line(Vector2(x + 8, y + 8), Vector2(x + 13, y + 5), crack, 1.0)
		draw_line(Vector2(x + 8, y + 8), Vector2(x + 7, y + 13), crack, 1.0)
		draw_line(Vector2(x + 8, y + 8), Vector2(x + 14, y + 11), crack, 1.0)
		draw_rect(Rect2(x + 6, y + 6, 4, 4), Color(0.08, 0.06, 0.07))
	if mood > 0 and not broken:   # pencere saksısı
		draw_rect(Rect2(x + 2, y + 13, 12, 3), Color(0.45, 0.28, 0.14))
		var blooms := [Color(0.95, 0.35, 0.4), Color(1.0, 0.85, 0.3)]
		for k in 4:
			draw_circle(Vector2(x + 4 + k * 3, y + 12), 1.5, blooms[k % 2])


func _draw_poi(p: Dictionary) -> void:
	var t: Vector2i = p["t"]
	var pos := Vector2(t.x * TILE, t.y * TILE)
	if p["kind"] == "chest":
		var bob := sin(_time * 3.0 + t.x) * 1.0
		draw_texture_rect_region(ATLAS, Rect2(pos + Vector2(0, bob), Vector2(TILE, TILE)), _atlas_rect(TILE_CRATE))
		var tw := 0.5 + 0.5 * sin(_time * 5.0 + t.y)
		draw_circle(pos + Vector2(12, 2 + bob), 1.2 + tw, Color(1.0, 0.9, 0.4, 0.4 + 0.5 * tw))
	else:
		draw_texture_rect_region(ATLAS, Rect2(pos, Vector2(TILE, TILE)), _atlas_rect(TILE_WELL))
		draw_circle(pos + Vector2(8, 2), 1.5, Color(0.5, 0.85, 1.0, 0.6 + 0.3 * sin(_time * 4.0)))


## Sabit karakter: hafifçe soluyor, konuşacak şeyi varsa başında sarı "!" (tohumcuda tohum simgesi).
func _draw_npc(n: Dictionary) -> void:
	var t: Vector2i = n["t"]
	var origin := Vector2((t.x + 0.5) * TILE, (t.y + 0.95) * TILE)
	var bob := sin(_time * 2.2 + t.x) * 0.6
	draw_set_transform(origin + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 5.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tex := FieldArt.person(n["style"], 0, 0)
	var sc: float = float(FieldArt.PEOPLE.get(n["style"], {}).get("scale", 1.0))
	var sw := FieldArt.PLAYER_W * sc
	var sh := FieldArt.PLAYER_H * sc
	draw_texture_rect(tex, Rect2(origin - Vector2(sw / 2.0, sh - 1.0 + bob), Vector2(sw, sh)), false)
	if n["marker"]:
		var mb := sin(_time * 4.0 + t.y) * 1.5
		var mp := origin + Vector2(-2, -sh - 6 + mb)
		if n["id"] == "peddler":
			draw_texture_rect(UiArt.icon("seed"), Rect2(mp + Vector2(-4, -4), Vector2(12, 12)), false)
		else:
			draw_rect(Rect2(mp + Vector2(-1, -1), Vector2(6, 11)), Color(0.1, 0.07, 0.05))
			draw_rect(Rect2(mp, Vector2(4, 6)), Color(1.0, 0.85, 0.25))
			draw_rect(Rect2(mp + Vector2(0, 8), Vector2(4, 2)), Color(1.0, 0.85, 0.25))


## Yanan ağaç: titreyen turuncu-sarı alevler, ısı parıltısı ve kalan süreye göre büyüyen yangın.
func _draw_fire(f: Dictionary) -> void:
	var t: Vector2i = f["t"]
	var base := Vector2((t.x + 0.5) * TILE, (t.y + 1) * TILE - 1)
	var danger := clampf(float(f["age"]) / 6.0, 0.0, 1.0)
	draw_circle(base + Vector2(0, -6), 10.0 + 4.0 * danger, Color(1.0, 0.5, 0.1, 0.18 + 0.12 * danger))
	for k in 3:
		var phase := _time * 9.0 + k * 2.1 + t.x
		var h := 9.0 + 5.0 * sin(phase) + danger * 6.0
		var w := 5.0 - k * 0.6
		var cx := base.x + (k - 1) * 4.0 + sin(phase * 0.7) * 1.2
		draw_colored_polygon(PackedVector2Array([Vector2(cx - w, base.y), Vector2(cx, base.y - h), Vector2(cx + w, base.y)]),
			Color(1.0, 0.45 + 0.2 * k, 0.1, 0.95))
		draw_colored_polygon(PackedVector2Array([Vector2(cx - w * 0.5, base.y), Vector2(cx, base.y - h * 0.6), Vector2(cx + w * 0.5, base.y)]),
			Color(1.0, 0.9, 0.4, 0.95))


## Kaçak oduncu: ağaca vardığında kesme çubuğu dolar. Üstünde kırmızı ünlem.
func tree_tiles() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for i in _tree.size():
		if _tree[i] >= 0:
			var t := Vector2i(i % COLS, i / COLS)
			if not is_locked(t):
				result.append(t)
	return result


## Temiz yerlerde kelebekler uçar: Çevre arttıkça sayıları artar, ilerlemeyi gösterir.
func _update_butterflies(delta: float) -> void:
	_butterfly_timer -= delta
	if _butterfly_timer <= 0.0:
		_butterfly_timer = 0.6
		_green_cache = 1.0 - dirty_ratio()
	var v := _view_clamped()
	var want := int(clampf((_green_cache - 0.2) * 22.0, 0.0, 16.0))
	if butterflies.size() < want and randf() < 0.1 and v.size.x > 0:
		var t := Vector2i(randi_range(v.position.x, v.end.x - 1), randi_range(v.position.y, v.end.y - 1))
		if is_free_land(t) and not is_dirty(t) and zone_at(t) != Zone.INDUSTRY and zone_at(t) != Zone.LANDFILL:
			var p := Vector2((t.x + randf()) * TILE, (t.y + randf()) * TILE)
			butterflies.append({"pos": p, "target": p, "phase": randf() * 6.0,
				"color": [Color(1.0, 0.85, 0.3), Color(0.95, 0.5, 0.6), Color(0.6, 0.8, 1.0), Color(1, 1, 1)].pick_random()})
	elif butterflies.size() > want and not butterflies.is_empty():
		butterflies.pop_back()
	for b in butterflies.duplicate():
		var pos: Vector2 = b["pos"]
		if pos.distance_to(b["target"]) < 3.0:
			b["target"] = pos + Vector2(randf_range(-36.0, 36.0), randf_range(-24.0, 24.0))
		pos += (b["target"] - pos).normalized() * 16.0 * delta
		b["pos"] = pos
		var t2 := tile_at(pos)
		if not in_bounds(t2) or is_dirty(t2) or not v.grow(3).has_point(t2):
			butterflies.erase(b)


func _draw_butterflies() -> void:
	for b in butterflies:
		var pos: Vector2 = b["pos"] + Vector2(0, sin(_time * 3.0 + b["phase"]) * 2.0 - 10.0)
		var flap := absf(sin(_time * 16.0 + b["phase"]))
		var c: Color = b["color"]
		draw_rect(Rect2(pos + Vector2(-3, -2.0 * flap - 1.0), Vector2(3, 2.0 + 2.0 * flap)), c)
		draw_rect(Rect2(pos + Vector2(0, -2.0 * flap - 1.0), Vector2(3, 2.0 + 2.0 * flap)), c)
		draw_rect(Rect2(pos + Vector2(-0.5, -1), Vector2(1, 3)), Color(0.15, 0.1, 0.08))


func _draw_hazard(h: Dictionary) -> void:
	var pos: Vector2 = h["pos"]
	var o := Vector2(roundf(pos.x), roundf(pos.y))
	match h["kind"]:
		"stranded":
			draw_set_transform(o + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
			draw_circle(Vector2.ZERO, 9.0, Color(0.3, 0.6, 0.95, 0.45))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			var tex := FieldArt.person(h["style"], h["facing"], h["step"])
			var size := Vector2(FieldArt.PLAYER_W, FieldArt.PLAYER_H)
			var top_left := o - Vector2(size.x / 2.0, size.y - 1.0)
			if h["facing"] == 2 and h["flip"]:
				draw_texture_rect(tex, Rect2(top_left + Vector2(size.x, 0), Vector2(-size.x, size.y)), false)
			else:
				draw_texture_rect(tex, Rect2(top_left, size), false)
			if h["state"] == "wait":
				var bob := sin(_time * 7.0) * 2.0
				draw_rect(Rect2(o + Vector2(-2, -size.y - 11 + bob), Vector2(5, 7)), Color(0.1, 0.05, 0.05))
				draw_rect(Rect2(o + Vector2(-1, -size.y - 10 + bob), Vector2(3, 4)), Color(1.0, 0.3, 0.25))
				draw_rect(Rect2(o + Vector2(-1, -size.y - 5 + bob), Vector2(3, 2)), Color(1.0, 0.3, 0.25))
		"wilt":
			var pulse := 0.5 + 0.5 * sin(_time * 5.0 + pos.x)
			draw_circle(o + Vector2(0, -12), 10.0 + pulse * 2.0, Color(0.8, 0.6, 0.15, 0.28))
			var drop := o + Vector2(0, -30 + sin(_time * 4.0) * 2.0)
			draw_colored_polygon(PackedVector2Array([drop + Vector2(0, -5), drop + Vector2(-3.5, 0), drop + Vector2(0, 3.5), drop + Vector2(3.5, 0)]), Color(0.35, 0.7, 1.0))
			var p := clampf(float(h["life"]) / 60.0, 0.0, 1.0)
			draw_rect(Rect2(o + Vector2(-9, -24), Vector2(18, 4)), Color(0.1, 0.07, 0.05))
			draw_rect(Rect2(o + Vector2(-8, -23), Vector2(16.0 * p, 2)), Color(1.0, 0.3, 0.2).lerp(Color(0.4, 0.9, 0.35), p))
		"leak":
			var glow := 0.5 + 0.5 * sin(_time * 3.0 + pos.x)
			draw_circle(o + Vector2(0, -8), 15.0 + glow * 3.0, Color(0.45, 0.95, 0.2, 0.16))
			draw_rect(Rect2(o + Vector2(-6, -13), Vector2(12, 13)), Color(0.08, 0.12, 0.06))
			draw_rect(Rect2(o + Vector2(-5, -12), Vector2(10, 11)), Color(0.3, 0.42, 0.2))
			draw_rect(Rect2(o + Vector2(-5, -8), Vector2(10, 3)), Color(0.9, 0.8, 0.2))
			for k in 3:
				var tt := fmod(_time * 0.9 + k * 0.33, 1.0)
				draw_circle(o + Vector2(-3 + k * 3, -14 - tt * 18.0), 2.0 + tt, Color(0.55, 1.0, 0.3, 0.7 * (1.0 - tt)))
			var seal := int(h["seal"])
			if seal > 0:
				draw_rect(Rect2(o + Vector2(-10, -22), Vector2(20, 5)), Color(0.1, 0.07, 0.05))
				draw_rect(Rect2(o + Vector2(-9, -21), Vector2(18.0 * seal / 6.0, 3)), Color(0.4, 0.9, 1.0))
			else:
				draw_rect(Rect2(o + Vector2(-1, -27 + sin(_time * 7.0) * 2.0), Vector2(3, 7)), Color(1.0, 0.3, 0.25))
		"strike":
			var p2 := clampf(float(h["age"]) / 1.25, 0.0, 1.0)
			draw_circle(o, 24.0, Color(1.0, 0.2, 0.15, 0.10 + 0.22 * p2))
			draw_arc(o, 24.0, 0.0, TAU, 28, Color(1.0, 0.35, 0.25, 0.9), 1.5)
			draw_circle(o, 24.0 * p2, Color(1.0, 0.5, 0.3, 0.35))
			if p2 > 0.88:
				draw_circle(o, 26.0, Color(1.0, 1.0, 0.9, 0.7))


func _draw_drop(d: Dictionary) -> void:
	var pos: Vector2 = d["pos"]
	var bob := sin(_time * 3.0 + pos.x) * 1.5
	var o := Vector2(roundf(pos.x), roundf(pos.y))
	var pulse := 0.5 + 0.5 * sin(_time * 4.0 + pos.y)
	draw_circle(o + Vector2(0, -6), 11.0 + pulse * 3.0, Color(1.0, 0.85, 0.4, 0.16 + 0.12 * pulse))
	draw_set_transform(o + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 5.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var b := o + Vector2(0, bob)
	draw_rect(Rect2(b + Vector2(-6, -11), Vector2(12, 10)), Color(0.25, 0.14, 0.07))
	draw_rect(Rect2(b + Vector2(-5, -10), Vector2(10, 8)), Color(0.72, 0.46, 0.22))
	draw_rect(Rect2(b + Vector2(-1, -10), Vector2(2, 8)), Color(1.0, 0.82, 0.3))
	draw_rect(Rect2(b + Vector2(-5, -7), Vector2(10, 2)), Color(1.0, 0.82, 0.3))
	draw_rect(Rect2(b + Vector2(-3, -13), Vector2(3, 3)), Color(1.0, 0.82, 0.3))
	draw_rect(Rect2(b + Vector2(0, -13), Vector2(3, 3)), Color(1.0, 0.82, 0.3))


func _draw_rabbit() -> void:
	var pos: Vector2 = rabbit["pos"]
	var hop := 0.0
	if rabbit["state"] == "run":
		hop = absf(sin(float(rabbit["hop"]) * 9.0)) * 4.0
	var o := Vector2(roundf(pos.x), roundf(pos.y))
	draw_set_transform(o + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 4.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var dir := 1.0 if float(rabbit["dir"]) >= 0.0 else -1.0
	var b := o + Vector2(0, -hop)
	var gold := Color(1.0, 0.82, 0.25)
	var dark := Color(0.35, 0.22, 0.05)
	draw_rect(Rect2(b + Vector2(-5, -8), Vector2(10, 7)), dark)
	draw_rect(Rect2(b + Vector2(-4, -7), Vector2(8, 5)), gold)
	draw_rect(Rect2(b + Vector2(dir * 3.0 - 2.0, -11), Vector2(5, 5)), gold)
	draw_rect(Rect2(b + Vector2(dir * 3.0 - 2.0, -16), Vector2(2, 5)), gold)
	draw_rect(Rect2(b + Vector2(dir * 3.0 + 1.0, -17), Vector2(2, 6)), gold)
	draw_rect(Rect2(b + Vector2(-dir * 5.0 - 1.0, -6), Vector2(3, 3)), Color.WHITE)
	draw_rect(Rect2(b + Vector2(dir * 3.0 + dir, -10), Vector2(1, 1)), dark)
	var tw := fmod(_time * 3.0, 1.0)
	draw_rect(Rect2(b + Vector2(-9.0 + tw * 18.0, -20.0 + sin(_time * 7.0) * 3.0), Vector2(2, 2)), Color(1, 1, 0.8, 1.0 - tw))
	draw_rect(Rect2(b + Vector2(8.0 - tw * 16.0, -14.0 + cos(_time * 6.0) * 3.0), Vector2(2, 2)), Color(1, 1, 0.8, tw))


func _draw_logger() -> void:
	var pos: Vector2 = logger["pos"]
	var origin := Vector2(roundf(pos.x), roundf(pos.y))
	draw_set_transform(origin + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 4.5, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tex := FieldArt.person("logger", logger["facing"], logger["step"])
	var size := Vector2(FieldArt.PLAYER_W, FieldArt.PLAYER_H)
	var top_left := origin - Vector2(size.x / 2.0, size.y - 1.0)
	if logger["facing"] == 2 and logger["flip"]:
		draw_texture_rect(tex, Rect2(top_left + Vector2(size.x, 0), Vector2(-size.x, size.y)), false)
	else:
		draw_texture_rect(tex, Rect2(top_left, size), false)
	var bob := sin(_time * 6.0) * 1.5
	draw_rect(Rect2(origin + Vector2(-2, -size.y - 9 + bob), Vector2(5, 9)), Color(0.1, 0.05, 0.05))
	draw_rect(Rect2(origin + Vector2(-1, -size.y - 8 + bob), Vector2(3, 5)), Color(1.0, 0.25, 0.2))
	draw_rect(Rect2(origin + Vector2(-1, -size.y - 2 + bob), Vector2(3, 2)), Color(1.0, 0.25, 0.2))
	if logger["state"] == "cut":
		var p := clampf(float(logger["cut"]) / 3.5, 0.0, 1.0)
		draw_rect(Rect2(origin + Vector2(-8, -size.y - 14), Vector2(16, 4)), Color(0.1, 0.07, 0.05))
		draw_rect(Rect2(origin + Vector2(-7, -size.y - 13), Vector2(14.0 * p, 2)), Color(1.0, 0.4, 0.2))


func _draw_villager(v: Dictionary) -> void:
	var pos: Vector2 = v["pos"]
	var origin := Vector2(roundf(pos.x), roundf(pos.y))
	draw_set_transform(origin + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 4.5, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tex := FieldArt.person(v["style"], v["facing"], v["step"])
	var size := Vector2(FieldArt.PLAYER_W, FieldArt.PLAYER_H)
	var top_left := origin - Vector2(size.x / 2.0, size.y - 1.0)
	if v["facing"] == 2 and v["flip"]:
		draw_texture_rect(tex, Rect2(top_left + Vector2(size.x, 0), Vector2(-size.x, size.y)), false)
	else:
		draw_texture_rect(tex, Rect2(top_left, size), false)


func _draw_trash(item: Dictionary) -> void:
	var t: Vector2i = item["tile"]
	var bob := sin(_time * 3.0 + float(item["phase"])) * 0.8
	var pos := Vector2(t.x * TILE, t.y * TILE + bob)
	draw_texture_rect(FieldArt.trash(item["kind"]), Rect2(pos, Vector2(TILE, TILE)), false)


func _draw_player() -> void:
	_draw_player_on(self)


func _draw_player_on(c: CanvasItem) -> void:
	var facing := player_facing
	var tex := FieldArt.player(facing, player_step)
	var bob := -1.0 if player_moving and player_step != 0 else 0.0
	var origin := Vector2(roundf(player_pos.x), roundf(player_pos.y))
	c.draw_set_transform(origin + Vector2(0, -1), 0.0, Vector2(1.0, 0.35))
	c.draw_circle(Vector2.ZERO, 5.0, Color(0, 0, 0, 0.3))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var size := Vector2(FieldArt.PLAYER_W, FieldArt.PLAYER_H)
	var top_left := origin - Vector2(size.x / 2.0, size.y - 1.0) + Vector2(0, bob)
	if facing == 2 and player_flip:
		c.draw_texture_rect(tex, Rect2(top_left + Vector2(size.x, 0), Vector2(-size.x, size.y)), false)
	else:
		c.draw_texture_rect(tex, Rect2(top_left, size), false)


## Pazarın üstünde "PAZAR" tabelası ve sallanan tohum simgesi.
func _draw_market_sign() -> void:
	var font: Font = ThemeDB.fallback_font
	var center := market_sign_position()
	var text := tr("FIELD_MARKET")
	var size := 10
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var board := Rect2(center.x - width / 2.0 - 5, center.y - 21, width + 10, 14)
	draw_rect(board.grow(1), Color(0.1, 0.06, 0.04))
	draw_rect(board, Color(0.85, 0.66, 0.28))
	draw_rect(Rect2(board.position, Vector2(board.size.x, 2)), Color(1.0, 0.86, 0.5))
	draw_string(font, Vector2(board.position.x + 5, board.end.y - 3), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.2, 0.12, 0.06))
	var bob := sin(_time * 3.0) * 1.5
	draw_texture_rect(UiArt.icon("seed"), Rect2(center.x - 6, center.y - 36 + bob, 12, 12), false)


## Yer işaretleri: önemli yapıların adı, keşfedilince üstlerinde belirir.
func _draw_landmarks(v: Rect2i) -> void:
	var font: Font = ThemeDB.fallback_font
	for st in special_trees:
		var st_t: Vector2i = st["t"]
		if v.grow(2).has_point(st_t):
			var hb := sin(_time * 3.0) * 1.5
			draw_texture_rect(FieldArt.heart(), Rect2(Vector2(st_t.x * TILE + 3, st_t.y * TILE - 16 + hb), Vector2(9, 8)), false)
	for l in landmarks:
		var t: Vector2i = l["t"]
		if not v.grow(4).has_point(t) or not is_explored(t) or is_locked(t):
			continue
		var text := tr(l["key"])
		var size := 8
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos := Vector2(t.x * TILE + 8, t.y * TILE - 8)
		draw_rect(Rect2(pos.x - width / 2.0 - 4, pos.y - 9, width + 8, 12), Color(0.12, 0.2, 0.14, 0.9))
		draw_rect(Rect2(pos.x - width / 2.0 - 4, pos.y - 9, width + 8, 1), Color(0.55, 0.8, 0.45, 0.9))
		draw_string(font, Vector2(pos.x - width / 2.0, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.88, 1.0, 0.8))


## Bölge tabelaları: yön bulmak için adı sabit yazılı.
func _draw_signs(v: Rect2i) -> void:
	var font: Font = ThemeDB.fallback_font
	for s in signs:
		var t: Vector2i = s["t"]
		if not v.grow(2).has_point(t) or not is_explored(t) or is_locked(t):
			continue
		var text := tr(s["key"])
		var size := 8
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos := Vector2(t.x * TILE + 8, t.y * TILE - 3)
		draw_rect(Rect2(pos.x - width / 2.0 - 3, pos.y - 9, width + 6, 11), Color(0.1, 0.07, 0.05, 0.85))
		draw_string(font, Vector2(pos.x - width / 2.0, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(1.0, 0.92, 0.7))


## Kilitli bölüm: koyu ve çapraz çizgili. Açık alanla sınır olan karolarda sarı-siyah bariyer şeridi.
func _draw_locked_tile(x: int, y: int) -> void:
	var pos := Vector2(x * TILE, y * TILE)
	draw_rect(Rect2(pos, Vector2(TILE, TILE)), Color(0.05, 0.04, 0.045, 0.97))
	var border := false
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var n: Vector2i = Vector2i(x, y) + d
		if in_bounds(n) and _locked[_index(n)] == 0:
			border = true
			break
	if border:
		for k in 4:
			var off := k * 5.0 - 3.0
			draw_colored_polygon(PackedVector2Array([pos + Vector2(off, 0), pos + Vector2(off + 3, 0), pos + Vector2(off - 3, TILE), pos + Vector2(off - 6, TILE)]),
				Color(0.95, 0.75, 0.15, 0.85))
	elif (x + y) % 2 == 0:
		draw_line(pos + Vector2(0, TILE), pos + Vector2(TILE, 0), Color(0.12, 0.1, 0.11), 1.0)


## Keşfedilmemiş alan karanlık; keşfedilmişle sınır olan karolar yarı saydam.
func _draw_fog(v: Rect2i) -> void:
	for y in range(v.position.y, v.end.y):
		for x in range(v.position.x, v.end.x):
			var i := y * COLS + x
			if _locked[i] == 1:
				_draw_locked_tile(x, y)
				continue
			if _explored[i] == 1:
				continue
			var edge := false
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if in_bounds(n) and _explored[_index(n)] == 1:
					edge = true
					break
			draw_rect(Rect2(x * TILE, y * TILE, TILE, TILE), Color(0.04, 0.035, 0.035, 0.55 if edge else 0.93))
