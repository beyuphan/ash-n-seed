class_name FieldEncounters
extends RefCounted
## Saha karakterlerinin karşılaşmaları. Her karakterin birden çok farklı karşılaşması var;
## her gün biri seçilir (ardışık iki gün aynısı gelmez). Yeni karşılaşma eklemek için POOLS'a ad yaz,
## aynı adla _<karakter>_<ad>(npc, portrait, name_key) fonksiyonu ekle ve strings.csv'ye NPC_ metinlerini koy.
##
## Rıza:   çay, söylenti (sandık yeri), yarının havası, mahalle şikâyeti, çöp anlaşması
## Canan:  hediye, ipucu, çöp takası, indirimli tohum, nehir raporu
## Hulusi: rüşvet, sponsorluk (görev), duman anlaşması

const POOLS := {
	"riza": ["tea", "rumor", "tomorrow", "complaint", "trash_deal"],
	"canan": ["gift", "tip", "trade", "discount", "water", "race"],
	"hulusi": ["bribe", "sponsor", "smoke"],
}
const THANKS := ["NPC_CANAN_THANKS"]

var world  # FieldWorld


func _init(w) -> void:
	world = w


func talk(npc: Dictionary) -> void:
	var day: int = GameState.day
	var id: String = npc["id"]
	var name_key := "CHAR_%s_NAME" % id.to_upper()
	var portrait: Texture2D = world.portrait_for(id)
	if npc["used_day"] == day:
		world.say(portrait, name_key, "NPC_%s_DONE" % id.to_upper(), THANKS, Callable())
		return
	var topic: String = npc.get("topic", "")
	if topic == "":  # söyleyecek bir şeyi yok: kısa, sıradan bir laf
		world.say(portrait, name_key, "NPC_%s_IDLE_%d" % [id.to_upper(), randi_range(1, 8)], THANKS, Callable())
		return
	if topic.begins_with("story:"):
		world.story.play(npc, topic.substr(6))
		return
	if npc.get("enc_day", -1) != day:
		var pool: Array = POOLS[id].duplicate()
		if pool.size() > 1 and npc.has("last_enc"):
			pool.erase(npc["last_enc"])
		npc["enc"] = pool.pick_random()
		npc["enc_day"] = day
		npc["last_enc"] = npc["enc"]
	call("_%s_%s" % [id, npc["enc"]], npc, portrait, name_key)


func _finish(npc: Dictionary) -> void:
	npc["used_day"] = GameState.day
	world.report("talk", 1, npc["id"])


func _ok(portrait: Texture2D, name_key: String, text_key: String) -> void:
	world.say(portrait, name_key, text_key, THANKS, Callable())


# ------------------------------------------------------------------ Rıza

func _riza_tea(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_RIZA_ASK", ["NPC_RIZA_YES", "NPC_RIZA_NO"], func(c: int) -> void:
		if c != 0:
			return
		if GameState.money <= 5.0:
			_ok(portrait, name_key, "NPC_RIZA_BROKE")
			return
		_finish(npc)
		GameState.change_stat(&"money", -5.0)
		GameState.change_stat(&"people", 4.0)
		_ok(portrait, name_key, "NPC_RIZA_THANKS"))


## Söylenti: açılmamış bir sandığın bulunduğu bölgeyi haritada açar.
func _riza_rumor(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	var found: bool = world.reveal_hidden_chest()
	_finish(npc)
	_ok(portrait, name_key, "NPC_RIZA_RUMOR_ASK" if found else "NPC_RIZA_RUMOR_NONE")


## Yarının olayını önceden haber verir: plan yapmak için.
func _riza_tomorrow(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	_finish(npc)
	_ok(portrait, name_key, "NPC_RIZA_TOMORROW_%s" % str(world.tomorrow_event()).to_upper())


func _riza_complaint(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_RIZA_COMPLAINT_ASK", ["NPC_RIZA_COMPLAINT_YES", "NPC_RIZA_COMPLAINT_NO"], func(c: int) -> void:
		if c == 0:
			if GameState.money <= 8.0:
				_ok(portrait, name_key, "NPC_RIZA_BROKE")
				return
			_finish(npc)
			GameState.change_stat(&"money", -8.0)
			GameState.change_stat(&"people", 5.0)
			_ok(portrait, name_key, "NPC_RIZA_COMPLAINT_THANKS")
		else:
			_finish(npc)
			GameState.change_stat(&"people", -2.0)
			_ok(portrait, name_key, "NPC_RIZA_COMPLAINT_SULK"))


## Bugün en az 5 çöp topladıysan Halk sevinir ve tohum verir. Yoksa "devam et".
func _riza_trash_deal(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	if world.day_stats["collected"] >= 5:
		_finish(npc)
		GameState.change_stat(&"people", 6.0)
		world.add_seeds("pine", 1)
		_ok(portrait, name_key, "NPC_RIZA_TRASH_OK")
	else:
		_ok(portrait, name_key, "NPC_RIZA_TRASH_NOT_YET")


# ------------------------------------------------------------------ Canan

func _canan_race(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	if not world.challenge.is_empty():
		_ok(portrait, name_key, "NPC_CANAN_RACE_BUSY")
		return
	world.say(portrait, name_key, "NPC_CANAN_RACE_ASK", ["NPC_CANAN_RACE_YES", "NPC_CANAN_RACE_NO"], func(c: int) -> void:
		if c != 0:
			return
		_finish(npc)
		world.add_seeds("pine", 4)
		world.start_challenge("plant", 4, 45.0)
		world.guide.offer("f_race"))


func _canan_gift(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	_finish(npc)
	var green: float = 1.0 - world.dirty_ratio()
	if green >= 0.4:
		world.add_seeds("oak", 1)
		world.add_seeds("pine", 1)
	else:
		world.add_seeds("pine", 2)
	_ok(portrait, name_key, "NPC_CANAN_GREEN" if green >= 0.4 else "NPC_CANAN_DRY")


## İpucu: koru mekaniğini öğretir ve bir meyve tohumu verir.
func _canan_tip(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	_finish(npc)
	world.add_seeds("fruit", 1)
	_ok(portrait, name_key, "NPC_CANAN_TIP")


func _canan_trade(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	if world.day_stats["collected"] >= 4:
		_finish(npc)
		world.add_seeds("oak", 1)
		_ok(portrait, name_key, "NPC_CANAN_TRADE_OK")
	else:
		_ok(portrait, name_key, "NPC_CANAN_TRADE_NOT_YET")


func _canan_discount(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_CANAN_DISCOUNT_ASK", ["NPC_CANAN_DISCOUNT_YES", "NPC_CANAN_DISCOUNT_NO"], func(c: int) -> void:
		if c != 0:
			return
		if GameState.money <= 10.0:
			_ok(portrait, name_key, "NPC_RIZA_BROKE")
			return
		_finish(npc)
		GameState.change_stat(&"money", -10.0)
		world.add_seeds("fruit", 1)
		_ok(portrait, name_key, "NPC_CANAN_DISCOUNT_OK"))


func _canan_water(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	_finish(npc)
	var good: bool = world.water_quality() >= 0.35
	GameState.change_stat(&"people" if good else &"nature", 1.0)
	_ok(portrait, name_key, "NPC_CANAN_WATER_GOOD" if good else "NPC_CANAN_WATER_BAD")


# ------------------------------------------------------------------ Hulusi

func _hulusi_bribe(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_HULUSI_ASK", ["NPC_HULUSI_YES", "NPC_HULUSI_NO"], func(c: int) -> void:
		_finish(npc)
		if c == 0:
			world.give_money(20.0)
			GameState.change_stat(&"nature", -3.0)
			_ok(portrait, name_key, "NPC_HULUSI_TAKEN")
		else:
			GameState.change_stat(&"people", 1.0)
			_ok(portrait, name_key, "NPC_HULUSI_REFUSED"))


## Sponsorluk: sanayi bölgesine 2 ağaç dikersen 30 Kasa. Günün görev listesine eklenir.
func _hulusi_sponsor(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_HULUSI_SPONSOR_ASK", ["NPC_HULUSI_SPONSOR_YES", "NPC_HULUSI_SPONSOR_NO"], func(c: int) -> void:
		if c != 0:
			return
		_finish(npc)
		world.objectives.add_custom("plant_zone", "OBJ_PLANT_ZONE", 2, {"money": 30}, FieldMap.Zone.INDUSTRY)
		_ok(portrait, name_key, "NPC_HULUSI_SPONSOR_OK"))


## Duman anlaşması: 15 Kasa'ya bacalar bugün kısılır, fabrikaların yakınında kirlilik yayılmaz.
func _hulusi_smoke(npc: Dictionary, portrait: Texture2D, name_key: String) -> void:
	world.say(portrait, name_key, "NPC_HULUSI_SMOKE_ASK", ["NPC_HULUSI_SMOKE_YES", "NPC_HULUSI_SMOKE_NO"], func(c: int) -> void:
		if c != 0:
			return
		if GameState.money <= 15.0:
			_ok(portrait, name_key, "NPC_RIZA_BROKE")
			return
		_finish(npc)
		GameState.change_stat(&"money", -15.0)
		world.smoke_off = true
		_ok(portrait, name_key, "NPC_HULUSI_SMOKE_OK"))
