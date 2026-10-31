class_name FieldProgression
extends RefCounted
## Oyunun seviye tasarımı: 6 bölüm (her biri 5 gün). Her bölümde harita biraz daha açılır, yeni bir mekanik
## tanıtılır, baskı artar ve bir Çevre hedefi vardır. Bölüm sonunda gazetede yıldızla değerlendirilir.
##
##  1 Uyanış (1-5):        pazar, park, mahalle. Sadece çam ve çöp. Öğretici.
##  2 Nehir ve Orman (6-10): orman ve nehir açılır. Meşe, kuyu, mağaza, yangın tehlikesi.
##  3 Duman (11-15):         sanayi açılır. Baca filtresi, duman günleri, Hulusi.
##  4 Toprak (16-20):        tarım ovası. Meyve ağaçları, oduncu.
##  5 Çöplük (21-25):        çöplük açılır. Çöp seli ve asit baskısı.
##  6 Son Nefes (26-30):     her yer açık, en yüksek baskı.
## Sayıları ayarlamak için sadece aşağıdaki tablolara bak.

## first/last: gün aralığı. goal: bölüm sonunda Çevre hedefi. decay: günlük taban kirlilik (Çevre kaybı).
## trash: çöp yoğunluğu çarpanı. drain: enerji kaybı çarpanı. seeds: sabah bedava çam tohumu.
const CHAPTERS := [
	{"first": 1, "last": 5, "name": "CH1_NAME", "intro": "CH1_INTRO", "goal": 38.0, "decay": 0.8, "trash": 0.7, "drain": 1.0, "seeds": 2},
	{"first": 6, "last": 10, "name": "CH2_NAME", "intro": "CH2_INTRO", "goal": 46.0, "decay": 1.6, "trash": 0.9, "drain": 1.0, "seeds": 2},
	{"first": 11, "last": 15, "name": "CH3_NAME", "intro": "CH3_INTRO", "goal": 52.0, "decay": 2.4, "trash": 1.0, "drain": 1.05, "seeds": 1},
	{"first": 16, "last": 20, "name": "CH4_NAME", "intro": "CH4_INTRO", "goal": 58.0, "decay": 3.2, "trash": 1.1, "drain": 1.1, "seeds": 1},
	{"first": 21, "last": 25, "name": "CH5_NAME", "intro": "CH5_INTRO", "goal": 62.0, "decay": 4.0, "trash": 1.5, "drain": 1.2, "seeds": 1},
	{"first": 26, "last": 30, "name": "CH6_NAME", "intro": "CH6_INTRO", "goal": 66.0, "decay": 4.8, "trash": 1.3, "drain": 1.25, "seeds": 1},
]

## Haritanın açılan kısımları, her bölümde bir öncekine eklenir (altıncı bölüm hepsi).
const REGIONS := [
	Rect2i(0, 21, 38, 43),    # 1: pazar meydanı, park, mahalle
	Rect2i(0, 0, 47, 64),     # 2: orman ve nehir
	Rect2i(47, 0, 49, 37),    # 3: sanayi bölgesi
	Rect2i(47, 37, 31, 27),   # 4: tarım ovası
	Rect2i(78, 37, 18, 27),   # 5: çöplük
]

## Özelliklerin açıldığı gün. Yeni özellik o gün bir bildirimle tanıtılır.
## Gün 1-5 öğretici: her gün tek yeni şey. 1 yürü ve dik, 2 çöp, 3 pazar, 4 harita ve kuyu, 5 karakter.
const FEATURES := {
	"pinar": 2, "canan": 3, "riza": 4, "bench": 3, "recycle": 5, "objectives_full": 4, "minimap": 4, "wells": 4,
	"chests": 5, "oak": 5, "wish": 5, "events": 6, "favors": 3, "rabbit": 3, "veli": 6, "yigithan": 7, "shop": 7, "flood": 7, "fish": 7,
	"dump": 8, "hulusi": 8, "airdrop": 8, "grove": 9, "fruit": 9, "heat": 10, "fire": 10,
	"home": 2, "kemal": 11, "filter": 11, "smog": 11, "leak": 12, "logger": 14, "storm": 16,
}
## İlk bu kadar günde sabah karar kartı yok. 0: kartlar 1. günden başlar (ilk kart Tomurcuk'un tanıtımı).
const CARD_FREE_DAYS := 0
## Sadece geçit olan, ayrıca duyurulmayan özellikler.
const SILENT := ["events", "objectives_full", "bench", "wish", "fish", "wells", "chests", "canan", "riza", "pinar", "veli", "kemal", "hulusi", "yigithan", "home"]


static func index(day: int) -> int:
	return clampi((day - 1) / 5, 0, CHAPTERS.size() - 1)


static func chapter(day: int) -> Dictionary:
	return CHAPTERS[index(day)]


static func number(day: int) -> int:
	return index(day) + 1


static func is_first_day(day: int) -> bool:
	return day == int(chapter(day)["first"])


static func is_last_day(day: int) -> bool:
	return day == int(chapter(day)["last"])


## O gün açık olan harita parçaları.
static func regions(day: int) -> Array[Rect2i]:
	var result: Array[Rect2i] = []
	for i in mini(index(day) + 1, REGIONS.size()):
		result.append(REGIONS[i])
	if index(day) >= REGIONS.size():  # son bölüm: her yer
		result.append(Rect2i(0, 0, FieldMap.COLS, FieldMap.ROWS))
	return result


static func has(feature: String, day: int) -> bool:
	return day >= int(FEATURES.get(feature, 1))


## Tam bu gün açılan özellikler (bildirim için).
static func unlocked_today(day: int) -> Array[String]:
	var list: Array[String] = []
	for f in FEATURES:
		if int(FEATURES[f]) == day and not SILENT.has(f):
			list.append(f)
	return list


## Bölüm temalı görev: o bölümün özel mekaniğini öğreten ve her gün listede olan ek görev.
## Boş sözlük: tema görevi yok (ilk bölüm).
static func theme_objective(day: int) -> Dictionary:
	match number(day):
		2:
			return {"kind": "plant_zone", "key": "OBJ_PLANT_ZONE", "target": 3, "arg": FieldMap.Zone.RIVER, "reward": {"money": 8, "oak": 1}}
		3:
			if has("filter", day):
				return {"kind": "filter", "key": "OBJ_FILTER", "target": 1, "arg": null, "reward": {"money": 12, "oak": 1}}
		4:
			return {"kind": "species", "key": "OBJ_FRUIT", "target": 1, "arg": "fruit", "reward": {"money": 8, "oak": 1}}
		5:
			return {"kind": "trash_zone", "key": "OBJ_TRASH_ZONE", "target": 8, "arg": FieldMap.Zone.LANDFILL, "reward": {"pine": 3, "oak": 1}}
		6:
			return {"kind": "grove", "key": "OBJ_GROVE", "target": 1, "arg": null, "reward": {"money": 10, "oak": 1}}
	return {}


## Bölüm sonu yıldız: 0-3. Hedefin altında 8'den fazla = 0, hedefe yakın = 1, hedef = 2, hedef + 8 = 3.
static func stars(nature: float, goal: float) -> int:
	if nature >= goal + 8.0:
		return 3
	if nature >= goal:
		return 2
	if nature >= goal - 8.0:
		return 1
	return 0
