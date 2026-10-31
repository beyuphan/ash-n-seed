class_name FieldThreats
extends RefCounted
## Aktif tehditler: yangın ve kaçak oduncu. Oyuncu müdahale etmezse ağaçlar kaybolur.
##  Yangın: bir ağaç tutuşur, her 2 saniyede komşu ağaçlara sıçrar, 6 saniyede kül olur. Yanına gidip Boşluk ile söndür.
##  Oduncu: en yakın ağaca yürür, 3.5 saniyede keser, sonra sıradakine geçer. Yaklaşıp Boşluk ile kov.
## İkisi de mini haritada yanıp söner, yani keşfedilmemiş yerde bile görünür.

const LOGGER_SPEED := 26.0
const LOGGER_LIFETIME := 85.0
const LOGGER_CUT_TIME := 3.5
const REACH := 30.0

var world
var map: FieldMap


func _init(w, m: FieldMap) -> void:
	world = w
	map = m


func clear() -> void:
	map.fires.clear()
	map.logger = {}
	map.rabbit = {}


const RABBIT_LIFETIME := 55.0
const RABBIT_SPEED := 104.0


## Altın tavşan: ara sıra çıkar, oyuncu yaklaşınca zıplayarak kaçar. Yakalayınca ödül verir.
func spawn_rabbit() -> bool:
	var player_tile := map.tile_at(map.player_pos)
	for attempt in 300:
		var t := Vector2i(randi_range(2, FieldMap.COLS - 3), randi_range(2, FieldMap.ROWS - 3))
		var dist := Vector2(t - player_tile).length()
		if map.is_free_land(t) and not map.is_locked(t) and dist >= 12.0 and dist <= 40.0:
			map.rabbit = {"pos": Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.9) * FieldMap.TILE),
				"state": "idle", "timer": 0.5, "life": RABBIT_LIFETIME, "dir": 1.0, "hop": 0.0, "vel": Vector2.ZERO}
			return true
	return false


func _update_rabbit(delta: float) -> void:
	if map.rabbit.is_empty():
		return
	var r := map.rabbit
	r["life"] = float(r["life"]) - delta
	if r["life"] <= 0.0:
		map.rabbit = {}
		return
	var pos: Vector2 = r["pos"]
	var to_player: Vector2 = pos - map.player_pos
	if r["state"] == "run":
		var next: Vector2 = pos + (r["vel"] as Vector2) * delta
		if map.is_solid_world(next) or map.is_locked(map.tile_at(next)) or not map.in_bounds(map.tile_at(next)):
			r["vel"] = (r["vel"] as Vector2).rotated(randf_range(1.2, 2.2))
		else:
			r["pos"] = next
		r["hop"] = float(r["hop"]) + delta
		r["timer"] = float(r["timer"]) - delta
		if r["timer"] <= 0.0:
			r["state"] = "idle"
			r["timer"] = randf_range(0.35, 0.7)  # nefes alır: yetişmek mümkün
	else:
		r["timer"] = float(r["timer"]) - delta
		if to_player.length() < 52.0 and r["timer"] <= 0.0:
			var away := to_player.normalized().rotated(randf_range(-0.7, 0.7))
			r["vel"] = away * RABBIT_SPEED
			r["dir"] = away.x
			r["state"] = "run"
			r["timer"] = randf_range(0.45, 0.7)


func rabbit_near(player_pos: Vector2) -> bool:
	return not map.rabbit.is_empty() and (map.rabbit["pos"] as Vector2).distance_to(player_pos) <= REACH


func catch_rabbit(player_pos: Vector2) -> bool:
	if not rabbit_near(player_pos):
		return false
	map.rabbit = {}
	return true


## Bir bölgede yangın çıkarır. Bölgenin ZONE anahtarını döndürür, uygun ağaç yoksa "".
func start_fire() -> String:
	var candidates: Array[Vector2i] = []
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			var zone := map.zone_at(t)
			if (zone == FieldMap.Zone.FOREST or zone == FieldMap.Zone.HOUSING or zone == FieldMap.Zone.RIVER) and map.is_flammable(t):
				candidates.append(t)
	if candidates.is_empty():
		return ""
	var start: Vector2i = candidates.pick_random()
	map.start_fire(start)
	return FieldMap.ZONE_KEYS.get(map.zone_at(start), "ZONE_FOREST")


## Ormanda oduncu belirir. Haritada hiç ağaç yoksa "" döner (çıkmaz).
func start_logger() -> String:
	if map.tree_count() == 0:
		return ""
	var player_tile := map.tile_at(map.player_pos)
	for attempt in 200:
		var t := Vector2i(randi_range(2, 30), randi_range(2, 20))
		if map.is_free_land(t) and Vector2(t - player_tile).length() >= 18.0:
			map.spawn_logger(Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.9) * FieldMap.TILE))
			map.logger["life"] = LOGGER_LIFETIME
			return "ZONE_FOREST"
	return ""


func update(delta: float) -> void:
	var burned := map.update_fires(delta)
	if burned > 0:
		world.on_trees_burned(burned)
	_update_logger(delta)
	_update_rabbit(delta)


func _update_logger(delta: float) -> void:
	if map.logger.is_empty():
		return
	var l := map.logger
	l["life"] = float(l.get("life", LOGGER_LIFETIME)) - delta
	if l["life"] <= 0.0 and l["state"] != "flee":
		l["state"] = "flee"
	var pos: Vector2 = l["pos"]
	match l["state"]:
		"walk":
			var target: Vector2i = l["target"]
			if not map.has_tree(target):
				target = map.nearest_tree_tile(pos)
				l["target"] = target
			if target.x < 0:
				l["state"] = "flee"
				return
			var dest := Vector2((target.x + 0.5) * FieldMap.TILE, (target.y + 1.1) * FieldMap.TILE)
			var d := dest - pos
			if d.length() <= maxf(3.0, LOGGER_SPEED * delta):  # hedefi aşıp sallanmasın
				l["pos"] = dest
				l["state"] = "cut"
				l["cut"] = 0.0
			else:
				_step(l, d.normalized(), LOGGER_SPEED, delta)
		"cut":
			l["step"] = 0
			l["cut"] += delta
			if not map.has_tree(l["target"]):
				l["state"] = "walk"
			elif l["cut"] >= LOGGER_CUT_TIME:
				map.remove_tree_at(l["target"])
				world.on_tree_felled()
				l["state"] = "walk"
				l["target"] = Vector2i(-1, -1)
		_:  # flee: en yakın harita kenarına koşar
			var edge := Vector2(0, pos.y) if pos.x < map.world_size().x / 2.0 else Vector2(map.world_size().x, pos.y)
			_step(l, (edge - pos).normalized(), LOGGER_SPEED * 2.6, delta)
			if pos.x < -8.0 or pos.x > map.world_size().x + 8.0:
				map.logger = {}


func _step(l: Dictionary, dir: Vector2, speed: float, delta: float) -> void:
	l["pos"] = (l["pos"] as Vector2) + dir * speed * delta
	l["walk"] += delta * 8.0
	l["step"] = 1 if fmod(l["walk"], 2.0) < 1.0 else 2
	if absf(dir.x) > absf(dir.y):
		l["facing"] = 2
		l["flip"] = dir.x < 0.0
	else:
		l["facing"] = 0 if dir.y > 0.0 else 1


func fire_near(player_pos: Vector2) -> Dictionary:
	return map.nearest_fire(player_pos, REACH)


func logger_near(player_pos: Vector2) -> bool:
	return not map.logger.is_empty() and map.logger["state"] != "flee" \
		and (map.logger["pos"] as Vector2).distance_to(player_pos) <= REACH


func extinguish(player_pos: Vector2) -> bool:
	var f := fire_near(player_pos)
	if f.is_empty():
		return false
	map.extinguish(f)
	return true


func chase(player_pos: Vector2) -> bool:
	if not logger_near(player_pos):
		return false
	map.logger["state"] = "flee"
	return true
