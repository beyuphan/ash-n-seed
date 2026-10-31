extends Node
## Kriz kartı motoru. data/crisis_pool.json okur, günlük kart seçer, seçimin sonuçlarını uygular.
## Kelebek etkisi: seçimler gecikmeli kartlar planlar (schedule), bayrak koyar (set_flags),
## havuza gizli kart ekler (unlock_cards, kirli deste) ve gizli kirlilik katsayısını değiştirir.

const POOL_PATH := "res://data/crisis_pool.json"
const RECENT_MEMORY := 2

var flags: Dictionary = {}
## Sabah verilen son karar: akşam gazetesi manşeti için. {card_id, character, effects}
var last_choice: Dictionary = {}

var _cards: Dictionary = {}
var _scheduled: Array[Dictionary] = []
var _unlocked: Dictionary = {}
var _seen_once: Dictionary = {}
var _last_drawn_day: Dictionary = {}
var _recent: Array[String] = []
## Her oyunda "şu güne kadar mutlaka çıkmalı" günleri 0-2 gün kayar: hikâye omurgası kartları hep aynı günde gelmesin.
var _deadline_shift: Dictionary = {}


func _ready() -> void:
	_load_pool()
	GameState.run_started.connect(reset)


func reset() -> void:
	flags.clear()
	last_choice = {}
	_scheduled.clear()
	_unlocked.clear()
	_seen_once.clear()
	_last_drawn_day.clear()
	_recent.clear()
	_roll_deadlines()


func _roll_deadlines() -> void:
	_deadline_shift.clear()
	for card in _cards.values():
		if not card.has("must_by_day"):
			continue
		var room := int(card.get("requires", {}).get("max_day", 9999)) - int(card["must_by_day"])
		_deadline_shift[card["id"]] = randi_range(0, clampi(room, 0, 2))


func _deadline(card: Dictionary) -> int:
	return int(card["must_by_day"]) + int(_deadline_shift.get(card["id"], 0))


## Bugünün kartını döndürür. Sıra: vadesi gelen planlı kart, öncelikli kart, ağırlıklı rastgele.
func draw_card() -> Dictionary:
	while not _scheduled.is_empty():
		var due_index := -1
		for i in _scheduled.size():
			if int(_scheduled[i]["due_day"]) <= GameState.day:
				due_index = i
				break
		if due_index == -1:
			break
		var entry := _scheduled[due_index]
		_scheduled.remove_at(due_index)
		if randf() <= float(entry["chance"]) and _cards.has(entry["card"]):
			return _mark_drawn(_cards[entry["card"]])

	var eligible: Array[Dictionary] = []
	for card in _cards.values():
		if _is_eligible(card):
			eligible.append(card)
	# Öncelikli: priority kartlar ve "şu güne kadar mutlaka çıkmalı" (must_by_day) kartlar
	var priority := eligible.filter(func(c: Dictionary) -> bool:
		return c.get("priority", false) \
			or (c.has("must_by_day") and GameState.day >= _deadline(c)))
	if not priority.is_empty():
		return _mark_drawn(priority.pick_random())
	if eligible.is_empty():
		eligible = _recyclable_cards()

	var fresh := eligible.filter(func(c: Dictionary) -> bool: return not _recent.has(c["id"]))
	var pool: Array = fresh if not fresh.is_empty() else eligible
	if pool.is_empty():
		push_warning("CrisisManager: uygun kart yok.")
		return {}
	return _mark_drawn(_weighted_pick(pool))


func has_flag(flag: String) -> bool:
	return flags.has(flag)


## Seçimin göstergelere gerçek etkisi. Kasırga bayrakları burada işler:
## "kasa_kilitli" varken Kasa kazançları sıfırlanır (vergi gelirleri kilitli).
func effective_effects(choice: Dictionary) -> Dictionary:
	var effects: Dictionary = (choice.get("effects", {}) as Dictionary).duplicate()
	if flags.has("kasa_kilitli") and float(effects.get("money", 0.0)) > 0.0:
		effects["money"] = 0.0
	return effects


## Seçimin sonuçlarını uygular. Göstergeler en son değişir, çünkü oyun bitebilir.
func apply_choice(card: Dictionary, index: int) -> void:
	var choice: Dictionary = card["choices"][index]
	GameState.pollution_rate = maxf(0.0, GameState.pollution_rate + float(choice.get("pollution_rate", 0.0)))
	for flag in choice.get("set_flags", []):
		flags[flag] = true
	for card_id in choice.get("unlock_cards", []):
		_unlocked[card_id] = true
	for item in choice.get("schedule", []):
		_scheduled.append({
			"card": item["card"],
			"due_day": GameState.day + int(item["delay"]),
			"chance": float(item.get("chance", 1.0)),
		})
	var effects := effective_effects(choice)
	last_choice = {"card_id": card["id"], "character": card.get("character", "event"), "effects": effects, "choice": index}
	for stat in ["money", "people", "nature"]:
		if effects.has(stat):
			GameState.change_stat(StringName(stat), float(effects[stat]))


func _is_eligible(card: Dictionary) -> bool:
	if card.get("scheduled_only", false):
		return false
	if card.get("once", false) and _seen_once.has(card["id"]):
		return false
	if card.get("locked", false) and not _unlocked.has(card["id"]):
		return false
	if _last_drawn_day.has(card["id"]) \
			and GameState.day - int(_last_drawn_day[card["id"]]) < int(card.get("cooldown_days", 0)):
		return false
	var req: Dictionary = card.get("requires", {})
	if GameState.day < int(req.get("min_day", 0)) or GameState.day > int(req.get("max_day", 9999)):
		return false
	if GameState.money < float(req.get("min_money", -1.0)) or GameState.money > float(req.get("max_money", 1000.0)):
		return false
	if GameState.people < float(req.get("min_people", -1.0)) or GameState.people > float(req.get("max_people", 1000.0)):
		return false
	if GameState.nature < float(req.get("min_nature", -1.0)) or GameState.nature > float(req.get("max_nature", 1000.0)):
		return false
	for flag in req.get("flags_all", []):
		if not flags.has(flag):
			return false
	for flag in req.get("flags_none", []):
		if flags.has(flag):
			return false
	return true


## Yeni faz kartları gelene kadar (gün 21+) sıradan kartlar yeniden çekilebilir.
## Gün aralığı, bir kez çıkma ve bekleme süresi yok sayılır, bayrak koşulları geçerli kalır.
func _recyclable_cards() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in _cards.values():
		if not card.get("recyclable", false):
			continue
		var req: Dictionary = card.get("requires", {})
		var ok := true
		for flag in req.get("flags_all", []):
			ok = ok and flags.has(flag)
		for flag in req.get("flags_none", []):
			ok = ok and not flags.has(flag)
		if ok and (_recent.is_empty() or not _recent.has(card["id"])):
			result.append(card)
	return result


func _weighted_pick(pool: Array) -> Dictionary:
	var total := 0.0
	for card in pool:
		total += float(card.get("weight", 1.0))
	var roll := randf() * total
	for card in pool:
		roll -= float(card.get("weight", 1.0))
		if roll <= 0.0:
			return card
	return pool.back()


func _mark_drawn(card: Dictionary) -> Dictionary:
	_seen_once[card["id"]] = true
	_last_drawn_day[card["id"]] = GameState.day
	_recent.append(card["id"])
	if _recent.size() > RECENT_MEMORY:
		_recent.pop_front()
	return card


func _load_pool() -> void:
	var file := FileAccess.open(POOL_PATH, FileAccess.READ)
	if file == null:
		push_error("CrisisManager: %s açılamadı." % POOL_PATH)
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY or not data.has("cards"):
		push_error("CrisisManager: JSON biçimi hatalı.")
		return
	for card in data["cards"]:
		_cards[card["id"]] = card
