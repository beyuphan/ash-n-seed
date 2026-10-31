class_name FieldGuide
extends RefCounted
## Oyun asistanı: Tomurcuk (küçük bir robot). Muhtar Rıza ayrı bir karakterdir. Yeni bir şey açıldığında ya da oyuncu ilk kez bir durumla karşılaştığında
## konuşur, NE yapılacağını ve NEDEN yapılacağını anlatır. Gerekirse haritaya hedef işareti koyar
## (ekran kenarında ok, bölge adı ve uzaklık ekranda yazar).
##
## Yeni ders eklemek için LESSONS'a satır, strings.csv'ye GUIDE_<AD> anahtarı ekle, sonra offer("ad") çağır.
## Hedef: "" yok, "market", "zone:RIVER", "npc:canan", "well", "factory".

const LESSONS := {
	"welcome": {"goal": ""},
	"controls": {"goal": ""},
	"trash": {"goal": ""},
	"first_plant": {"goal": ""},
	"no_seeds": {"goal": "market"},
	"low_energy": {"goal": ""},
	"spread": {"goal": ""},
	"region_2": {"goal": "zone:RIVER"},
	"region_3": {"goal": "zone:INDUSTRY"},
	"region_4": {"goal": "zone:FARM"},
	"region_5": {"goal": "zone:LANDFILL"},
	"region_6": {"goal": ""},
	"f_minimap": {"goal": ""},
	"f_wells": {"goal": "well"},
	"f_chests": {"goal": ""},
	"f_oak": {"goal": ""},
	"f_shop": {"goal": "market"},
	"f_grove": {"goal": ""},
	"f_dump": {"goal": ""},
	"f_fruit": {"goal": ""},
	"f_fire": {"goal": ""},
	"f_filter": {"goal": "factory"},
	"f_smog": {"goal": ""},
	"f_logger": {"goal": ""},
	"f_rabbit": {"goal": ""},
	"f_airdrop": {"goal": ""},
	"f_favors": {"goal": ""},
	"f_race": {"goal": ""},
	"finale": {"goal": ""},
	"f_recycle": {"goal": "market"},
	"f_flood": {"goal": ""},
	"f_heat": {"goal": ""},
	"f_leak": {"goal": ""},
	"f_storm": {"goal": ""},
}
const ARRIVE_TILES := 5.0

var world  # FieldWorld
var seen := {}
var queue: Array[String] = []
var goal_tile := Vector2i(-1, -1)
var goal_key := ""     ## hedefin ekranda görünen adı için çeviri anahtarı
var last_id := ""
var custom := {}   ## hikâye ipuçları: id -> {text, goal}
var _cooldown := 0.0


func _init(w) -> void:
	world = w


## Dersi sıraya koyar. Aynı ders oyunda bir kez anlatılır.
func offer(id: String) -> void:
	if seen.has(id) or not LESSONS.has(id):
		return
	seen[id] = true
	queue.append(id)


## Bir hikâye sahnesi için asistan ipucu: karakteri haritada işaretler.
func offer_story(beat_id: String, npc_id: String) -> void:
	var id := "story_" + beat_id
	if seen.has(id):
		return
	seen[id] = true
	custom[id] = {"text": "GUIDE_STORY_HINT_" + npc_id.to_upper(), "goal": "npc:" + npc_id}
	queue.append(id)


## Gün başı: açılan bölge ve özelliklerin derslerini sıraya koyar.
func on_day_start(day: int) -> void:
	clear_goal()
	if day == GameState.MAX_DAYS:
		offer("finale")
	if day == 1:
		offer("welcome")
	if FieldProgression.is_first_day(day) and day > 1:
		offer("region_%d" % FieldProgression.number(day))
	for f in FieldProgression.unlocked_today(day):
		offer("f_" + f)


func clear_goal() -> void:
	goal_tile = Vector2i(-1, -1)
	goal_key = ""


## Her karede çağrılır: sıradaki dersi gösterir, hedefe varınca işareti kaldırır, ilk kez yaşanan durumları yakalar.
func update(delta: float) -> void:
	var dlg_open: bool = world._dialog.is_open or world._shop.is_open
	if dlg_open:
		_cooldown = 0.35
		return
	_cooldown -= delta
	if not queue.is_empty():
		if _cooldown <= 0.0:
			_show(queue.pop_front())
		return
	if goal_tile.x >= 0:
		var here: Vector2i = world._map.tile_at(world._map.player_pos)
		if Vector2(here - goal_tile).length() <= ARRIVE_TILES:
			world.goal_reached(goal_key)
			clear_goal()
	# Bağlama duyarlı ipuçları
	if world.stamina < world.STAMINA_MAX * 0.22 and GameState.day >= 1:
		offer("low_energy")
	if world.day_stats["planted"] > 0 and world.total_seeds() <= 0:
		offer("no_seeds")


func repeat() -> void:
	if last_id != "" and queue.is_empty():
		_show(last_id)


func _show(id: String) -> void:
	last_id = id
	var spec: Dictionary = custom[id] if custom.has(id) else LESSONS[id]
	var text_key: String = spec["text"] if spec.has("text") else "GUIDE_" + id.to_upper()
	var portrait: Texture2D = world.portrait_for("assistant")
	world.say(portrait, "CHAR_ASSIST_NAME", text_key, ["GUIDE_OK"], func(_c: int) -> void:
		_apply_goal(spec["goal"]))


func _apply_goal(spec: String) -> void:
	if spec == "":
		return
	var map: FieldMap = world._map
	var tile := Vector2i(-1, -1)
	var key := ""
	if spec == "market":
		tile = map.tile_at(map.door_world_position())
		key = "FIELD_MARKET"
	elif spec.begins_with("zone:"):
		var zone: int = FieldMap.Zone[spec.substr(5)]
		tile = _zone_center(map, zone)
		key = FieldMap.ZONE_KEYS.get(zone, "")
	elif spec.begins_with("npc:"):
		var id := spec.substr(4)
		for n in map.npcs:
			if n["id"] == id and n["active"] and not n["temp"]:
				tile = n["t"]
				key = "CHAR_%s_NAME" % id.to_upper()
	elif spec.begins_with("spot:"):
		tile = map.spot_tile(spec.substr(5))
		key = "FIELD_GUIDE_PLACE"
	elif spec == "well":
		var best := 1e9
		for p in map.pois:
			if p["kind"] == "well" and p["active"]:
				var d := Vector2(p["t"] - map.tile_at(map.player_pos)).length()
				if d < best:
					best = d
					tile = p["t"]
		key = "FIELD_GUIDE_WELL"
	elif spec == "factory":
		for b in map.buildings:
			if b["kind"] == "factory" and not b["filtered"] and not map.is_locked((b["rect"] as Rect2i).position):
				var r: Rect2i = b["rect"]
				tile = Vector2i(r.position.x + r.size.x / 2, r.end.y)
				key = "FIELD_GUIDE_FACTORY"
				break
	if tile.x < 0:
		return
	goal_tile = tile
	goal_key = key


## Bölgenin açık, yürünebilir karolarının merkezine en yakın karo.
func _zone_center(map: FieldMap, zone: int) -> Vector2i:
	var tiles: Array[Vector2i] = []
	var sum := Vector2.ZERO
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			if map.zone_at(t) == zone and not map.is_locked(t) and map.is_free_land(t):
				tiles.append(t)
				sum += Vector2(t)
	if tiles.is_empty():
		return Vector2i(-1, -1)
	var center := sum / float(tiles.size())
	var best := tiles[0]
	var best_d := 1e9
	for t in tiles:
		var d := Vector2(t).distance_to(center)
		if d < best_d:
			best_d = d
			best = t
	return best
