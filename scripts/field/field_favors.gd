class_name FieldFavors
extends RefCounted
## Yardım isteyen vatandaşlar: ana işten bağımsız, sadece eğlence. Her biri ekranı değiştiren küçük bir oyun açar.
## Üçüncü günden itibaren çoğu gün bir tane çıkar. Kapıda kalan biri, çatıda kedi, davulcu, patlak lastik...
## Yeni bir istek eklemek için KINDS'a satır ekle ve strings.csv'ye FAVOR_<KIND>_NAME/ASK/YES/NO/WIN/LOSE koy.

## chapter: bu istek en erken hangi bölümde çıkar. Bölüm ilerledikçe oyun zorlaşır ve ödül büyür.
const KINDS := {
	"tire": {"game": "pump", "money": 8, "people": 1, "chapter": 1},
	"cat": {"game": "balance", "money": 5, "people": 3, "chapter": 1},
	"lock": {"game": "lock", "money": 8, "people": 2, "chapter": 3},
	"drum": {"game": "rhythm", "money": 7, "people": 2, "chapter": 4},
	"grill": {"game": "pump", "money": 7, "people": 2, "chapter": 1},
	"crow": {"game": "balance", "money": 6, "people": 2, "chapter": 2},
	"safe": {"game": "lock", "money": 9, "people": 1, "chapter": 3},
	"karaoke": {"game": "rhythm", "money": 8, "people": 3, "chapter": 3},
	"orange": {"game": "catch", "money": 6, "people": 2, "chapter": 1},
	"melon": {"game": "stack", "money": 7, "people": 2, "chapter": 1},
	"recycle": {"game": "sort", "money": 6, "people": 2, "chapter": 2},
	"mole": {"game": "whack", "money": 7, "people": 2, "chapter": 2},
	"wedding": {"game": "memory", "money": 9, "people": 3, "chapter": 3},
}
const CHANCE := 0.6
const LOSS_ENERGY := 8.0

var world  # FieldWorld
var _last_kind := ""
var _dry := 0
var _seen: Array[String] = []   # bu tur içinde çıkanlar: hepsi bir kez çıkmadan tekrar etmez


func _init(w) -> void:
	world = w


## Gün başında: uygun bir yerde yardım isteyen biri belirir.
func maybe_spawn(day: int, map: FieldMap) -> void:
	if not FieldProgression.has("favors", day):
		return
	var first: bool = world.story.flag("favor_seen") == false
	if not first and _dry < 2 and randf() > CHANCE:   # üst üste iki gün boş geçerse üçüncüde mutlaka biri gelir
		_dry += 1
		return
	var level := FieldProgression.number(day)
	var eligible: Array = KINDS.keys().filter(func(k) -> bool: return int(KINDS[k]["chapter"]) <= level)
	var pool: Array = eligible.filter(func(k) -> bool: return not _seen.has(k))
	if pool.is_empty():
		_seen.clear()
		pool = eligible.duplicate()
		pool.erase(_last_kind)
	var kind: String = pool.pick_random()
	var door := map.tile_at(map.door_world_position())
	for attempt in 200:
		var t := door + Vector2i(randi_range(-26, 26), randi_range(-18, 18))
		if not map.in_bounds(t) or map.is_locked(t) or not map.is_free_land(t) or map.trash_at(t):
			continue
		if Vector2(t - door).length() < 7.0 or map.in_market_zone(t):
			continue
		var zone := map.zone_at(t)
		if zone == FieldMap.Zone.LANDFILL or zone == FieldMap.Zone.INDUSTRY:
			continue
		_last_kind = kind
		_seen.append(kind)
		_dry = 0
		map.add_npc("favor", t, FieldArt.VILLAGER_STYLES.pick_random(), true)
		var n: Dictionary = map.npcs.back()
		n["favor"] = kind
		n["done"] = false
		if first:
			world.story.flags["favor_seen"] = true
			world.story.add_promise("neighbor")
		return


func name_key(npc: Dictionary) -> String:
	return "FAVOR_%s_NAME" % str(npc["favor"]).to_upper()


func pending(map: FieldMap) -> Dictionary:
	for n in map.npcs:
		if n["id"] == "favor" and not n["done"]:
			return n
	return {}


func talk(npc: Dictionary) -> void:
	var kind: String = npc["favor"]
	var key := "FAVOR_%s" % kind.to_upper()
	var portrait: Texture2D = FieldArt.person(npc["style"], 0, 0)
	if npc["done"]:
		world.say(portrait, name_key(npc), "FAVOR_DONE", ["STORY_OK"], Callable())
		return
	world.say(portrait, name_key(npc), key + "_ASK", [key + "_YES", key + "_NO"], func(c: int) -> void:
		if c != 0:
			return
		world.start_mini_game(KINDS[kind]["game"], key + "_TITLE", FieldProgression.number(GameState.day), func(ok: bool) -> void:
			_result(npc, kind, ok, portrait)))


func _result(npc: Dictionary, kind: String, ok: bool, portrait: Texture2D) -> void:
	npc["done"] = true
	npc["marker"] = false
	var key := "FAVOR_%s" % kind.to_upper()
	var data: Dictionary = KINDS[kind]
	if ok:
		var level := FieldProgression.number(GameState.day)
		world.give_money(float(data["money"]) + 3.0 * level)
		GameState.change_stat(&"people", float(data["people"]))
		if randf() < 0.5:
			world.add_seeds("pine", 1)
		world.report("favor")
		world.stat("favors")
	else:
		world.spend_energy(LOSS_ENERGY)
	world.say(portrait, name_key(npc), key + ("_WIN" if ok else "_LOSS"), ["STORY_OK"], Callable())
