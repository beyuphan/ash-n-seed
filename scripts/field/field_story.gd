class_name FieldStory
extends RefCounted
## Ana hikâye: 21 sahne, 6 karakter, üç perde. Veri: story_data.gd (tools/build_story.py üretir).
##
##  Perde 1 (1-10)  Uyanış:     Pınar'ın ağacı, Canan ve Tohum Bankası, Rıza'nın ikilemi, Veli'nin efsanesi, Hulusi'nin teklifi
##  Perde 2 (11-20) Duman, Toprak: Kemal ve işçiler, filtreler, Pınar'ın öksürüğü, Selim'in günlüğü, Hulusi'nin baskısı
##  Perde 3 (21-30) Çöplük, Son Nefes: Tohum Bankası açılır, Hulusi hesaplaşması, kasaba birleşir, final
##
## Bir sahne belirli günde, karakterin yerinde "!" olarak çıkar (WINDOW gün bekler). Seçimler bayrak bırakır;
## bayraklar sonraki sahneleri, oyunun mekaniklerini ve final metnini değiştirir.
## Etkiler: money, people, nature, seeds {tür: adet}, pollution, cost (Kasa), flags [], extra_if {flag, people},
## vault_open, pinar_tree, filter (kaç fabrikaya filtre).

const Data := preload("res://scripts/field/story_data.gd")

## Sözler: seçimle verilen, sonradan tutulan taahhütler. Sol panelde görünür.
const PROMISES := {
	"pinar_tree": {"kind": "water", "target": 3, "who": "pinar", "reward": {"people": 4, "seeds": {"oak": 1}}},
	"riza_word": {"kind": "plant", "target": 10, "who": "riza", "reward": {"people": 5, "money": 10}},
	"canan_lab": {"kind": "trash", "target": 10, "who": "canan", "reward": {"people": 2, "seeds": {"pine": 3}}},
	"veli_fish": {"kind": "fish", "target": 1, "who": "veli", "reward": {"people": 2, "seeds": {"oak": 2}}},
	"neighbor": {"kind": "favor", "target": 4, "who": "", "reward": {"people": 8, "seeds": {"oak": 2}, "money": 15}},
	"kemal_filter": {"kind": "filter", "target": 1, "who": "kemal", "reward": {"people": 4, "money": 12}},
}

var world  # FieldWorld
var promises: Array[Dictionary] = []
var flags := {}
var done := {}
var done_day := {}


func _init(w) -> void:
	world = w


func flag(name: String) -> bool:
	return flags.get(name, false)


func beat(id: String) -> Dictionary:
	return Data.BEATS[id]


## Bu karakterin bugün anlatacağı sahne. Yoksa "".
func topic_for(npc_id: String, day: int) -> String:
	var best := ""
	var best_day := 999
	for id in Data.BEATS:
		var b: Dictionary = Data.BEATS[id]
		if b["npc"] != npc_id or done.has(id):
			continue
		var first := int(b["day"])
		if day < first or day > first + int(b["window"]) or first >= best_day:
			continue
		var ok := true
		for f in b["req"]:
			ok = ok and flag(f)
		for f in b["not"]:
			ok = ok and not flag(f)
		if ok:
			best = id
			best_day = first
	return best


## Karakterin bu bölümdeki durağı (landmark/spot adı).
func home_for(npc_id: String, day: int) -> String:
	var homes: Array = Data.HOMES.get(npc_id, [])
	if homes.is_empty():
		return ""
	return homes[mini(FieldProgression.index(day), homes.size() - 1)]


func play(npc: Dictionary, id: String) -> void:
	var b: Dictionary = Data.BEATS[id]
	var portrait: Texture2D = world.portrait_for(npc["id"])
	var name_key := "CHAR_%s_NAME" % str(npc["id"]).to_upper()
	_line(npc, id, 1, portrait, name_key)


func _line(npc: Dictionary, id: String, index: int, portrait: Texture2D, name_key: String) -> void:
	var b: Dictionary = Data.BEATS[id]
	var key := "STORY_%s" % id.to_upper()
	var text_key := "%s_L%d" % [key, index]
	if index == 1 and str(b["variant"]) != "":
		text_key += "_Y" if flag(b["variant"]) else "_N"
	var total := int(b["lines"])
	if index < total:
		world.say(portrait, name_key, text_key, ["STORY_NEXT"], func(_c: int) -> void:
			_line(npc, id, index + 1, portrait, name_key))
		return
	var options: Array = []
	for i in b["choices"].size():
		options.append("%s_C%d" % [key, i + 1])
	world.say(portrait, name_key, text_key, options, func(c: int) -> void:
		_choose(npc, id, c, portrait, name_key))


func _choose(npc: Dictionary, id: String, choice: int, portrait: Texture2D, name_key: String) -> void:
	var b: Dictionary = Data.BEATS[id]
	var fx: Dictionary = b["choices"][choice]
	var cost := float(fx.get("cost", 0.0))
	if cost > 0.0 and GameState.money <= cost + 1.0:
		world.say(portrait, name_key, "STORY_NO_MONEY", ["STORY_OK"], Callable())
		return  # sahne bekler, para toplayınca tekrar gelinir
	_apply(fx)
	done[id] = true
	done_day[id] = GameState.day
	world._encounters._finish(npc)
	npc["topic"] = ""
	world.say(portrait, name_key, "STORY_%s_R%d" % [id.to_upper(), choice + 1], ["STORY_OK"], Callable())


func _apply(fx: Dictionary) -> void:
	var cost := float(fx.get("cost", 0.0))
	if cost > 0.0:
		GameState.change_stat(&"money", -cost)
	var m := float(fx.get("money", 0.0))
	if m > 0.0:
		world.give_money(m)
	elif m < 0.0 and GameState.money > absf(m) + 1.0:
		GameState.change_stat(&"money", m)
	if fx.has("people"):
		GameState.change_stat(&"people", float(fx["people"]))
	if fx.has("nature"):
		GameState.change_stat(&"nature", float(fx["nature"]))
	for species in fx.get("seeds", {}):
		world.add_seeds(species, int(fx["seeds"][species]))
	if fx.has("pollution"):
		GameState.pollution_rate = maxf(0.0, GameState.pollution_rate + float(fx["pollution"]))
	for f in fx.get("flags", []):
		flags[f] = true
	if fx.has("promise"):
		add_promise(str(fx["promise"]))
	if fx.has("extra_if") and flag(fx["extra_if"]["flag"]):
		GameState.change_stat(&"people", float(fx["extra_if"].get("people", 0.0)))
	if fx.get("vault_open", false):
		world.open_vault()
	if fx.get("pinar_tree", false):
		world.plant_pinar_tree()
	if fx.has("filter"):
		world.filter_factories(int(fx["filter"]))
	AudioManager.play_sfx(world.SFX_BUY, 0.0, -4.0)


## Bugün tamamlanan sahnelerin gazete haberi anahtarları.
func news_today(day: int) -> Array[String]:
	var result: Array[String] = []
	for id in done_day:
		if int(done_day[id]) == day:
			result.append("STORY_%s_NEWS" % str(id).to_upper())
	return result


## Oyun sonu: hikâyedeki seçimlere göre kapanış metni anahtarı.
func ending_key() -> String:
	if flag("sold"):
		return "END_WIN_SOLD"
	if flag("hulusi_redeemed"):
		return "END_WIN_REDEEMED"
	if flag("hulusi_justice"):
		return "END_WIN_JUSTICE"
	if flag("pinar_hope") and flag("workers_ally"):
		return "END_WIN_HERO"
	return "END_WIN"


func add_promise(id: String) -> void:
	for p in promises:
		if p["id"] == id:
			return
	promises.append({"id": id, "progress": 0, "target": int(PROMISES[id]["target"])})


## Oyundan gelen olay: kind uyan sözler ilerler, tamamlanan söz ödülünü verir.
func report_promise(kind: String, amount: int = 1) -> void:
	for p in promises.duplicate():
		var def: Dictionary = PROMISES[p["id"]]
		if def["kind"] != kind:
			continue
		p["progress"] = mini(int(p["progress"]) + amount, int(p["target"]))
		if p["progress"] >= p["target"]:
			promises.erase(p)
			flags[str(p["id"]) + "_kept"] = true
			_apply(def["reward"])
			world.promise_kept(str(p["id"]))


## Sol paneldeki söz satırları.
func promise_rows(tr_func: Callable) -> Array:
	var rows: Array = []
	for p in promises:
		var up := str(p["id"]).to_upper()
		rows.append({"mark": "p", "title": tr_func.call("PROM_%s_T" % up), "sub": tr_func.call("PROM_%s_S" % up),
			"prog": ("%d/%d" % [p["progress"], p["target"]]) if int(p["target"]) > 1 else ""})
	return rows
