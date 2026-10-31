class_name FieldObjectives
extends RefCounted
## Günlük saha görevleri: her gün 3 görev, üç gruptan birer tane. Oyuncuya yön ve çeşitlilik verir.
##  Dikim:   ağaç dik, bölgeye dik, meşe/meyve dik, koru oluştur
##  Temizlik: çöp topla, bölgede çöp topla
##  Keşif:   sandık bul, bölge ziyaret et, kuyudan su iç, karakterle konuş, yeşil alanı artır,
##           ve o gün yangın ya da oduncu varsa onu çöz
## Ödül sözlüğü: money, pine, oak, fruit (tohum), stamina (oran).

var items: Array[Dictionary] = []


## ctx: {zones: [bölge], npcs: [karakter id], event: bugünün olayı, green_pct: mevcut yeşil %,
##       full: tam görev listesi mi (ilk iki gün sadeleştirilmiş), oak/fruit/grove/chests/wells/talk: özellik açık mı,
##       theme: bölümün tema görevi (boşsa yok)}
func generate(day: int, ctx: Dictionary) -> void:
	items.clear()
	var zones: Array = ctx.get("zones", [])
	var npcs: Array = ctx.get("npcs", [])
	var full: bool = ctx.get("full", true)

	# Gün 1: tek görev, ekran boş kalsın
	if day == 1:
		items.append(_make("plant", "OBJ_PLANT", 6, {"money": 10}))
		return

	# 1) Dikim
	var plant_pool: Array = [["plant", 3]]
	if full and day >= 2 and not zones.is_empty():
		plant_pool.append(["plant_zone", 2])
	if full and ctx.get("oak", true) and day >= 3:
		plant_pool.append(["oak", 2])
	if full and ctx.get("fruit", true) and day >= 3:
		plant_pool.append(["fruit", 2])
	if full and ctx.get("grove", true) and day >= 4:
		plant_pool.append(["grove", 2])
	match _pick(plant_pool):
		"plant":
			items.append(_make("plant", "OBJ_PLANT", 2 + mini(day / 7, 3), {"money": 10}))
		"plant_zone":
			var z: int = zones.pick_random() if not zones.is_empty() else -1
			items.append(_make("plant_zone", "OBJ_PLANT_ZONE", 2, {"money": 14}, z))
		"oak":
			items.append(_make("species", "OBJ_OAK", 1, {"fruit": 1}, "oak"))
		"fruit":
			items.append(_make("species", "OBJ_FRUIT", 1, {"oak": 1}, "fruit"))
		"grove":
			items.append(_make("grove", "OBJ_GROVE", 1, {"oak": 1, "money": 8}))

	# 2) Temizlik: sadece gerçekten çöp varsa. Temiz bölgeden çöp isteme.
	var trash_total: int = ctx.get("trash_total", 99)
	var zone_trash: Dictionary = ctx.get("zone_trash", {})
	var rich_zones: Array = zones.filter(func(z) -> bool: return int(zone_trash.get(z, 0)) >= 4)
	if full and day >= 3 and randf() < 0.45 and not rich_zones.is_empty():
		var z2: int = rich_zones.pick_random()
		items.append(_make("trash_zone", "OBJ_TRASH_ZONE", mini(4 + day / 5, int(zone_trash[z2]) - 1), {"pine": 2}, z2))
	elif trash_total >= 4:
		items.append(_make("trash", "OBJ_TRASH", mini(mini(5 + day / 2, 16), trash_total - 1), {"pine": 1}))

	# 3) Keşif ya da günün olayı (ilk iki gün yok)
	if full:
		var event: String = ctx.get("event", "none")
		if event == "fire":
			items.append(_make("fire", "OBJ_FIRE", 1, {"money": 8, "stamina": 0.1}))
		elif event == "logger":
			items.append(_make("logger", "OBJ_LOGGER", 1, {"money": 8, "oak": 1}))
		elif event in ["flood", "heat", "leak", "storm"]:
			items.append(_make(event, "OBJ_" + event.to_upper(), 1, {"money": 10, "oak": 1}))
		else:
			var explore_pool: Array = []
			if not ctx.get("places", []).is_empty():
				explore_pool.append(["place", 2])
			if ctx.get("chests", true):
				explore_pool.append(["chest", 2])
			if not zones.is_empty():
				explore_pool.append(["zone", 2])
			if ctx.get("wells", true):
				explore_pool.append(["well", 2])
			if ctx.get("talk", true) and not npcs.is_empty():
				explore_pool.append(["talk", 2])
			if day >= 3:
				explore_pool.append(["green", 2])
			if explore_pool.is_empty():
				explore_pool.append(["green", 1])
			match _pick(explore_pool):
				"chest":
					items.append(_make("chest", "OBJ_CHEST", 1, {"pine": 2}))
				"zone":
					var z3: int = zones.pick_random()
					items.append(_make("zone", "OBJ_VISIT", 1, {"money": 8}, z3))
				"well":
					items.append(_make("well", "OBJ_WELL", 2, {"stamina": 0.15}))
				"place":
					var pid: String = ctx["places"].pick_random()
					items.append(_make("place", "OBJ_PLACE", 1, {"money": 6, "pine": 1}, pid))
				"talk":
					var who: String = npcs.pick_random()
					items.append(_make("talk", "OBJ_TALK", 1, {"pine": 1}, who))
				"green":
					var goal := mini(int(ctx.get("green_pct", 30)) + 5, 95)
					items.append(_make("green", "OBJ_GREEN", goal, {"money": 10, "oak": 1}))

	# 4) Bölümün tema görevi: o bölümün özel mekaniğini öğretir
	var theme: Dictionary = ctx.get("theme", {})
	if not theme.is_empty():
		items.append(_make(theme["kind"], theme["key"], theme["target"], theme["reward"], theme["arg"]))

	# Ekran kalabalık olmasın: en fazla 3 görev. Önce sıradan keşif gider, olay görevi kalır.
	var events := ["fire", "logger", "flood", "heat", "leak", "storm"]
	while items.size() > 3:
		var drop := 1
		for i in range(items.size() - 2, -1, -1):
			if not events.has(items[i]["kind"]):
				drop = i
				break
		items.remove_at(drop)


## Hikâye görevi (Hulusi'nin sponsorluğu gibi): günün görev listesine eklenir.
func add_custom(kind: String, key: String, target: int, reward: Dictionary, arg = null) -> Dictionary:
	var item := _make(kind, key, target, reward, arg)
	items.append(item)
	return item


## Bir olay bildirir. Bu olayla yeni tamamlanan görevleri döndürür.
## arg: bölge, tür ya da karakter (görev türüne göre). kind == "green" için amount mevcut yüzdedir.
func report(kind: String, amount: int = 1, arg = null) -> Array[Dictionary]:
	var completed: Array[Dictionary] = []
	for it in items:
		if it["done"] or it["kind"] != kind:
			continue
		if it["arg"] != null and arg != it["arg"]:
			continue
		if kind == "green":
			it["progress"] = mini(amount, it["target"])
		else:
			it["progress"] = mini(it["progress"] + amount, it["target"])
		if it["progress"] >= it["target"]:
			it["done"] = true
			completed.append(it)
	return completed


## Görevin ekranda görünen metni.
static func text_of(it: Dictionary, translate: Callable) -> String:
	var template: String = translate.call(it["key"])
	match it["kind"]:
		"plant", "trash", "well", "green", "flood", "heat", "leak":
			return template % it["target"]
		"plant_zone", "trash_zone":
			return template % [it["target"], translate.call(FieldMap.ZONE_KEYS.get(it["arg"], "ZONE_RIVER"))]
		"zone":
			return template % translate.call(FieldMap.ZONE_KEYS.get(it["arg"], "ZONE_RIVER"))
		"place":
			return template % translate.call("LM_" + str(it["arg"]).to_upper())
		"talk":
			return template % translate.call("CHAR_%s_NAME" % str(it["arg"]).to_upper())
		_:
			return template


static func reward_text_of(it: Dictionary, translate: Callable) -> String:
	var r: Dictionary = it["reward"]
	var parts: Array[String] = []
	if r.has("money"):
		parts.append("+%d %s" % [r["money"], translate.call("STAT_MONEY")])
	for species in FieldSpecies.IDS:
		if r.has(species):
			parts.append("+%d %s" % [r[species], translate.call(FieldSpecies.data(species)["name"])])
	if r.has("stamina"):
		parts.append("+%d%% %s" % [int(r["stamina"] * 100.0), translate.call("STAT_STAMINA")])
	return ", ".join(parts)


func _make(kind: String, key: String, target: int, reward: Dictionary, arg = null) -> Dictionary:
	return {"kind": kind, "key": key, "target": target, "progress": 0, "done": false, "reward": reward, "arg": arg, "flash": 0.0}


## Ağırlıklı rastgele seçim: [[ad, ağırlık], ...]
func _pick(pool: Array) -> String:
	var total := 0.0
	for p in pool:
		total += float(p[1])
	var roll := randf() * total
	for p in pool:
		roll -= float(p[1])
		if roll <= 0.0:
			return p[0]
	return pool.back()[0]
