class_name FieldDisasters
extends RefCounted
## Gün içi felaketler. Her felaketin KENDİNE ÖZEL bir kurtulma senaryosu var:
##  flood  (Sel):             mahsur kalan vatandaşları yanına al, pazara (güvenli yere) götür.   Mekanik: eşlik etme
##  heat   (Kuraklık):        solan ağaçlar için kuyudan su al, ağaca götür.                      Mekanik: taşıma
##  leak   (Zehirli sızıntı): fabrika varillerine git, Boşluğa art arda basıp kapat.              Mekanik: basarak kapatma
##  storm  (Fırtına):         yıldırım düşecek yerler kırmızı işaretlenir, üstünden çekil.        Mekanik: kaçınma
## Yangın ve oduncu FieldThreats içinde. Haritadaki çizim FieldMap.hazards listesinden yapılır.

const REACH := 30.0
const FLOOD_TIME := 95.0
const HEAT_TIME := 90.0
const LEAK_TIME := 80.0
const STORM_TIME := 45.0
const SEAL_PRESSES := 6
const STRIKE_DELAY := 1.25
const STRIKE_RADIUS := 24.0

var world  # FieldWorld
var map: FieldMap
var kind := ""
var time := 0.0
var carrying_water := false
var hits := 0
var saved := 0
var total := 0
var _strike_timer := 0.0


func _init(w, m: FieldMap) -> void:
	world = w
	map = m


func active() -> bool:
	return kind != ""


func clear() -> void:
	kind = ""
	time = 0.0
	carrying_water = false
	hits = 0
	saved = 0
	total = 0
	map.hazards.clear()


## Felaketi başlatır. Uygun yer/ağaç yoksa false döner (çağıran başka olaya geçer).
func start(what: String) -> bool:
	clear()
	var ok := false
	match what:
		"flood":
			ok = _start_flood()
		"heat":
			ok = _start_heat()
		"leak":
			ok = _start_leak()
		"storm":
			ok = _start_storm()
	if ok:
		kind = what
	else:
		map.hazards.clear()
	return ok


# ------------------------------------------------------------------ Başlatma

func _start_flood() -> bool:
	var door := map.tile_at(map.door_world_position())
	var picks: Array[Vector2i] = []
	for attempt in 600:
		if picks.size() >= 3:
			break
		var t := Vector2i(randi_range(1, FieldMap.COLS - 2), randi_range(1, FieldMap.ROWS - 2))
		if map.zone_at(t) != FieldMap.Zone.RIVER or map.is_locked(t) or not map.is_free_land(t):
			continue
		if Vector2(t - door).length() < 14.0:
			continue
		var far := true
		for p in picks:
			if Vector2(t - p).length() < 7.0:
				far = false
		if far:
			picks.append(t)
	if picks.size() < 2:
		return false
	for t in picks:
		map.hazards.append({"kind": "stranded", "pos": Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.9) * FieldMap.TILE),
			"state": "wait", "style": FieldArt.VILLAGER_STYLES.pick_random(), "walk": 0.0, "facing": 0, "flip": false, "step": 0})
	total = picks.size()
	time = FLOOD_TIME
	return true


func _start_heat() -> bool:
	var door := map.tile_at(map.door_world_position())
	var trees: Array[Vector2i] = []
	for t in map.tree_tiles():
		var d := Vector2(t - door).length()
		if d >= 6.0 and d <= 26.0 and not map.is_locked(t):
			trees.append(t)
	if trees.size() < 3:
		return false
	trees.shuffle()
	var n := mini(4, trees.size())
	for i in n:
		var t: Vector2i = trees[i]
		map.hazards.append({"kind": "wilt", "t": t, "pos": Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.9) * FieldMap.TILE), "life": HEAT_TIME})
	total = n
	time = HEAT_TIME
	return true


func _start_leak() -> bool:
	var spots: Array[Vector2] = []
	for b in map.buildings:
		if b["kind"] != "factory" or b["filtered"]:
			continue
		var r: Rect2i = b["rect"]
		if map.is_locked(r.position):
			continue
		spots.append(Vector2((r.position.x + r.size.x / 2.0) * FieldMap.TILE, (r.end.y + 0.8) * FieldMap.TILE))
	if spots.is_empty():
		return false
	spots.shuffle()
	var n := mini(3, spots.size())
	for i in n:
		map.hazards.append({"kind": "leak", "pos": spots[i], "seal": 0, "emit": randf_range(0.5, 1.5)})
	total = n
	time = LEAK_TIME
	return true


func _start_storm() -> bool:
	time = STORM_TIME
	_strike_timer = 2.0
	total = 1
	return true


# ------------------------------------------------------------------ Her kare

func update(delta: float) -> void:
	if kind == "":
		return
	time -= delta
	match kind:
		"flood":
			_update_flood(delta)
		"heat":
			_update_heat(delta)
		"leak":
			_update_leak(delta)
		"storm":
			_update_storm(delta)
	if kind != "" and time <= 0.0:
		finish()


func _update_flood(delta: float) -> void:
	var market := map.door_world_position()
	var player := map.player_pos
	var followers := 0
	for h in map.hazards.duplicate():
		if h["state"] != "follow":
			continue
		followers += 1
		var dest: Vector2 = player + Vector2(-8.0 * (followers), 6.0)
		var d: Vector2 = dest - (h["pos"] as Vector2)
		if d.length() > 10.0:
			var dir := d.normalized()
			h["pos"] = (h["pos"] as Vector2) + dir * 74.0 * delta
			h["walk"] += delta * 8.0
			h["step"] = 1 if fmod(h["walk"], 2.0) < 1.0 else 2
			if absf(dir.x) > absf(dir.y):
				h["facing"] = 2
				h["flip"] = dir.x < 0.0
			else:
				h["facing"] = 0 if dir.y > 0.0 else 1
		else:
			h["step"] = 0
		if (h["pos"] as Vector2).distance_to(market) < 44.0:
			map.hazards.erase(h)
			saved += 1
			world.on_disaster_progress("flood", h["pos"])
	if map.hazards.is_empty():
		finish()


func _update_heat(delta: float) -> void:
	for h in map.hazards.duplicate():
		h["life"] = float(h["life"]) - delta
		if h["life"] <= 0.0:
			map.hazards.erase(h)
			map.remove_tree_at(h["t"])
			world.on_disaster_loss("heat", h["pos"])
	if map.hazards.is_empty():
		finish()


func _update_leak(delta: float) -> void:
	for h in map.hazards:
		h["emit"] = float(h["emit"]) - delta
		if h["emit"] <= 0.0:
			h["emit"] = 2.2
			world.on_leak_pulse(h["pos"])


func _update_storm(delta: float) -> void:
	_strike_timer -= delta
	if _strike_timer <= 0.0 and time > 2.0:
		_strike_timer = randf_range(0.9, 1.5)
		var pos: Vector2 = map.player_pos
		if randf() < 0.45:  # bazıları doğrudan oyuncunun üstüne: durma, hareket et
			pos += Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
		else:
			pos += Vector2(randf_range(-110.0, 110.0), randf_range(-80.0, 80.0))
		if not map.is_solid_world(pos):
			map.hazards.append({"kind": "strike", "pos": pos, "age": 0.0})
	for h in map.hazards.duplicate():
		h["age"] = float(h["age"]) + delta
		if h["age"] >= STRIKE_DELAY:
			map.hazards.erase(h)
			if (h["pos"] as Vector2).distance_to(map.player_pos) <= STRIKE_RADIUS:
				hits += 1
				world.on_storm_hit(h["pos"])
			else:
				world.on_storm_miss(h["pos"])


# ------------------------------------------------------------------ Etkileşim

## Boşluk tuşu. Bir felaket nesnesiyle etkileşildiyse true.
func interact() -> bool:
	var player := map.player_pos
	match kind:
		"flood":
			for h in map.hazards:
				if h["state"] == "wait" and (h["pos"] as Vector2).distance_to(player) <= REACH:
					h["state"] = "follow"
					world.on_disaster_touch("flood", h["pos"])
					return true
		"heat":
			var h := _nearest("wilt", player)
			if not h.is_empty():
				if carrying_water:
					carrying_water = false
					map.hazards.erase(h)
					saved += 1
					world.on_disaster_progress("heat", h["pos"])
				else:
					world.deny_key("DIS_HEAT_NEED_WATER")
				return true
		"leak":
			var l := _nearest("leak", player)
			if not l.is_empty():
				l["seal"] += 1
				world.on_disaster_touch("leak", l["pos"], l["seal"])
				if l["seal"] >= SEAL_PRESSES:
					map.hazards.erase(l)
					saved += 1
					world.on_disaster_progress("leak", l["pos"])
					if map.hazards.is_empty():
						finish()
				return true
	return false


## Bir kuyudan su alındı: kuraklıkta kova dolar.
func on_well() -> void:
	if kind == "heat" and not carrying_water:
		carrying_water = true
		world.on_disaster_touch("heat_water", map.player_pos)


func hint_key() -> String:
	var player := map.player_pos
	match kind:
		"flood":
			for h in map.hazards:
				if h["state"] == "wait" and (h["pos"] as Vector2).distance_to(player) <= REACH:
					return "DIS_FLOOD_HINT"
		"heat":
			if not _nearest("wilt", player).is_empty():
				return "DIS_HEAT_HINT_WATER" if carrying_water else "DIS_HEAT_NEED_WATER"
		"leak":
			if not _nearest("leak", player).is_empty():
				return "DIS_LEAK_HINT"
	return ""


## Ekran kenarındaki ok için hedef: {tile, label}. Yoksa boş sözlük.
func target() -> Dictionary:
	var player := map.player_pos
	match kind:
		"flood":
			var waiting := _nearest_of("stranded", player, "wait")
			if not waiting.is_empty():
				return {"pos": waiting["pos"], "label": "DIS_LABEL_PERSON"}
			if not map.hazards.is_empty():
				return {"pos": map.door_world_position(), "label": "DIS_LABEL_SAFE"}
		"heat":
			if carrying_water:
				var w := _nearest("wilt", player)
				if not w.is_empty():
					return {"pos": w["pos"], "label": "DIS_LABEL_TREE"}
			else:
				var best := INF
				var pos := Vector2.ZERO
				for p in map.pois:
					if p["kind"] == "well" and p["active"]:
						var wp := Vector2((p["t"].x + 0.5) * FieldMap.TILE, (p["t"].y + 0.5) * FieldMap.TILE)
						if wp.distance_to(player) < best:
							best = wp.distance_to(player)
							pos = wp
				if best < INF:
					return {"pos": pos, "label": "FIELD_GUIDE_WELL"}
		"leak":
			var l := _nearest("leak", player, INF)
			if not l.is_empty():
				return {"pos": l["pos"], "label": "DIS_LABEL_LEAK"}
	return {}


## İkinci ok: kuraklıkta su yokken, kurumak üzere olan en yakın ağaç.
func second_target() -> Dictionary:
	if kind == "heat" and not carrying_water:
		var w := _nearest("wilt", map.player_pos, INF)
		if not w.is_empty():
			return {"pos": w["pos"], "label": "DIS_LABEL_TREE"}
	return {}


func status_text() -> String:
	var t_ := func(k: String) -> String: return world.tr(k)
	var left := maxi(int(ceil(time)), 0)
	match kind:
		"flood":
			return t_.call("DIS_FLOOD_LINE") % [saved, total, left]
		"heat":
			var line: String = t_.call("DIS_HEAT_LINE") % [saved, total, left]
			line += "\n" + t_.call("DIS_HEAT_CARRY" if carrying_water else "DIS_HEAT_STEP_WELL")
			return line
		"leak":
			return t_.call("DIS_LEAK_LINE") % [saved, total, left]
		"storm":
			return t_.call("DIS_STORM_LINE") % [left, hits]
	return ""


## Süre doldu ya da gün bitti: ne kadar kurtarıldıysa ona göre sonuç.
func finish() -> void:
	if kind == "":
		return
	var what := kind
	var lost := map.hazards.size() if what != "storm" else 0
	var result_saved := saved
	var result_total := total
	var result_hits := hits
	kind = ""
	for h in map.hazards:
		if what == "leak" and h["kind"] == "leak":
			world.on_disaster_loss("leak", h["pos"])
		elif what == "flood" and h["kind"] == "stranded":
			world.on_disaster_loss("flood", h["pos"])
	map.hazards.clear()
	carrying_water = false
	world.on_disaster_end(what, result_saved, result_total, lost, result_hits)


# ------------------------------------------------------------------ Yardımcı

func _nearest(hazard_kind: String, from: Vector2, max_dist: float = REACH) -> Dictionary:
	return _nearest_of(hazard_kind, from, "", max_dist)


func _nearest_of(hazard_kind: String, from: Vector2, state: String, max_dist: float = INF) -> Dictionary:
	var best := {}
	var best_d := max_dist
	for h in map.hazards:
		if h["kind"] != hazard_kind or (state != "" and h.get("state", "") != state):
			continue
		var d := (h["pos"] as Vector2).distance_to(from)
		if d <= best_d:
			best_d = d
			best = h
	return best
