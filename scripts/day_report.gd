class_name DayReport
extends RefCounted
## Gün sonu hesapları ve akşam gazetesi metin seçimi. Metinler strings.csv içindeki NEWS_*, TICKER_* anahtarlarında.
##
## Gün sonu geliri: yeşil alan arttıkça vergi artar, Halk memnuniyeti yeşil oranına ve sokaktaki vatandaşa bağlı.
## Manşet: günün Çevre değişimine göre. Alt başlık: sabah verilen kararın türüne göre.

const HEADLINE_VARIANTS := 5
const SUBHEAD_VARIANTS := 4
const TICKER_COUNT := 20
const EVENT_VARIANTS := 2


## Vergi geliri (Kasa): yeşil oran 0 iken 1, 1 iken 6. Para kıt kalsın, kartlardaki Kasa bedeli acısın.
static func tax_income(green_ratio: float) -> float:
	return roundf(1.0 + 5.0 * green_ratio)


## Halk memnuniyeti değişimi: yeşil oran %50'nin altındaysa düşer. Her gün biraz yorgunluk (bölüm ilerledikçe artar) bunu eksiye çeker:
## halk kendiliğinden 100'e fırlamasın, kararlar ve saha çalışması onu ayakta tutsun.
static func mood_change(green_ratio: float, villagers: int, day: int = 1) -> float:
	var fatigue := 2.0 + 0.7 * float(FieldProgression.number(day))
	return clampf(roundf((green_ratio - 0.5) * 10.0 + float(villagers) / 8.0 - fatigue), -7.0, 3.0)


## Sabah kararının türü: GREEDY, POPULIST, GREEN, AUSTERITY, NEUTRAL.
static func decision_category(effects: Dictionary) -> String:
	var m := float(effects.get("money", 0.0))
	var p := float(effects.get("people", 0.0))
	var n := float(effects.get("nature", 0.0))
	if m > 0.0 and n < 0.0:
		return "GREEDY"
	if p > 0.0 and n < 0.0:
		return "POPULIST"
	if n > 0.0:
		return "GREEN"
	if m < 0.0 and p < 0.0:
		return "AUSTERITY"
	return "NEUTRAL"


## Çevre değişimine göre manşet anahtarı.
static func headline_key(nature_delta: float, day: int) -> String:
	var band := "FLAT"
	if nature_delta >= 8.0:
		band = "HIGH"
	elif nature_delta >= 3.0:
		band = "UP"
	elif nature_delta <= -8.0:
		band = "LOW"
	elif nature_delta <= -3.0:
		band = "DOWN"
	var variant := (day * 7 + int(absf(nature_delta))) % HEADLINE_VARIANTS + 1
	return "NEWS_NAT_%s_%d" % [band, variant]


## Gazete manşeti. Öncelik: o sabahki karta özel manşet, sonra günün olayı ya da sahada yapılanlar, en son Çevre değişimi.
## last_choice: CrisisManager.last_choice, stats: sahanın günlük özeti, event: bugünün olayı.
static func pick_headline(nature_delta: float, day: int, last_choice: Dictionary, stats: Dictionary, event: String) -> String:
	if last_choice.has("card_id") and last_choice.has("choice"):
		var card_key := "NEWS_C_%s_%s" % [str(last_choice["card_id"]).to_upper(), "A" if int(last_choice["choice"]) == 0 else "B"]
		if _has_text(card_key):
			return card_key
	var pool: Array[String] = []
	if event in ["flood", "storm", "heat", "leak", "airdrop", "dump", "rain", "smog", "peddler"]:
		pool.append(event.to_upper())
	if int(stats.get("extinguished", 0)) > 0:
		pool.append("FIRE")
	if int(stats.get("burned", 0)) > 0:
		pool.append("BURNED")
	if int(stats.get("chased", 0)) > 0:
		pool.append("LOGGER")
	if int(stats.get("felled", 0)) > 0:
		pool.append("FELLED")
	if int(stats.get("rabbit", 0)) > 0:
		pool.append("RABBIT")
	if int(stats.get("favors", 0)) > 0:
		pool.append("FAVORS")
	if int(stats.get("windows", 0)) > 0 and randf() < 0.75:   # camı kırılan başkan her zaman manşet olur
		return "NEWS_E_WINDOW_%d" % (randi() % EVENT_VARIANTS + 1)
	if int(stats.get("planted", 0)) >= 18:
		pool.append("PLANTED")
	if int(stats.get("collected", 0)) >= 12:
		pool.append("TRASH")
	if int(stats.get("tea", 0)) >= 2:
		pool.append("TEA")
	var idle: bool = int(stats.get("planted", 0)) == 0 and int(stats.get("collected", 0)) == 0 and int(stats.get("walked", 0)) < 30
	if idle:
		return "NEWS_E_IDLE_%d" % (randi() % EVENT_VARIANTS + 1)
	if not pool.is_empty() and randf() < 0.65:
		var key := "NEWS_E_%s_%d" % [pool.pick_random(), randi() % EVENT_VARIANTS + 1]
		if _has_text(key):
			return key
	return headline_key(nature_delta, day)


static func _has_text(key: String) -> bool:
	return str(TranslationServer.translate(key)) != key


static func subheadline_key(effects: Dictionary, day: int) -> String:
	if effects.is_empty():
		return "NEWS_DEC_NEUTRAL_%d" % (day % SUBHEAD_VARIANTS + 1)
	return "NEWS_DEC_%s_%d" % [decision_category(effects), day % SUBHEAD_VARIANTS + 1]


static func ticker_key(day: int) -> String:
	return "TICKER_%d" % ((day * 7 + 3) % TICKER_COUNT + 1)


static func weather_key(event: String) -> String:
	match event:
		"rain": return "NEWS_WEATHER_RAIN"
		"smog", "leak": return "NEWS_WEATHER_SMOG"
		"flood", "storm": return "NEWS_WEATHER_RAIN"
		"heat": return "NEWS_WEATHER_HEAT"
		_: return "NEWS_WEATHER_CLEAR"


## Sahada yapılanlardan gazetede listelenecek satırlar.
static func highlights(stats: Dictionary, villagers: int, translate: Callable) -> Array[String]:
	var lines: Array[String] = []
	if stats.get("planted", 0) > 0:
		lines.append(translate.call("NEWS_PLANTED") % stats["planted"])
	if stats.get("collected", 0) > 0:
		lines.append(translate.call("NEWS_TRASH") % stats["collected"])
	if stats.get("discovered", 0) > 0:
		lines.append(translate.call("NEWS_DISCOVER") % stats["discovered"])
	if stats.get("chests", 0) > 0:
		lines.append(translate.call("NEWS_CHEST") % stats["chests"])
	if stats.get("groves", 0) > 0:
		lines.append(translate.call("NEWS_GROVES") % stats["groves"])
	if stats.get("windows", 0) > 0:
		lines.append(translate.call("NEWS_WINDOWS") % stats["windows"])
	if stats.get("extinguished", 0) > 0:
		lines.append(translate.call("NEWS_EXTINGUISHED") % stats["extinguished"])
	if stats.get("chased", 0) > 0:
		lines.append(translate.call("NEWS_CHASED"))
	if stats.get("burned", 0) > 0:
		lines.append(translate.call("NEWS_BURNED") % stats["burned"])
	if stats.get("felled", 0) > 0:
		lines.append(translate.call("NEWS_FELLED") % stats["felled"])
	if stats.get("polluted", 0) > 4:
		lines.append(translate.call("NEWS_POLLUTED") % stats["polluted"])
	if villagers > 0:
		lines.append(translate.call("NEWS_VILLAGERS") % villagers)
	if lines.is_empty():
		lines.append(translate.call("NEWS_NOTHING"))
	return lines
