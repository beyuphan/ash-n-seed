class_name FieldSpecies
extends RefCounted
## Ağaç türleri. Her tür farklı alan temizler, farklı Çevre kazandırır ve farklı enerjiye mal olur.
##  Çam:    ucuz ve hızlı, artı biçimli 5 karo.
##  Meşe:   pahalı ve yorucu ama 3x3 = 9 karo ve en çok Çevre. Daha büyük görünür.
##  Meyve:  az Çevre ama her akşam Kasa kazandırır (meyve bahçesi geliri).
## Yeni tür eklemek için DATA'ya satır, strings.csv'ye SEED_<TÜR> anahtarı eklemek yeter.

const IDS: Array[String] = ["pine", "oak", "fruit"]

const DATA := {
	"pine": {"name": "SEED_PINE", "tiles": [4, 16, 28], "area": "plus", "nature": 0.9, "energy": 6.0,
		"price": 6.0, "scale": 1.0, "tint": Color(0.55, 0.85, 0.4), "income": 0.0},
	"oak": {"name": "SEED_OAK", "tiles": [16, 28], "area": "square", "nature": 1.5, "energy": 11.0,
		"price": 13.0, "scale": 1.3, "tint": Color(0.95, 0.72, 0.35), "income": 0.0},
	"fruit": {"name": "SEED_FRUIT", "tiles": [5], "area": "plus", "nature": 0.6, "energy": 8.0,
		"price": 10.0, "scale": 1.05, "tint": Color(0.95, 0.4, 0.42), "income": 2.0},
}


static func data(id: String) -> Dictionary:
	return DATA.get(id, DATA["pine"])


## Ekilen karonun çevresinde temizlenecek karoların ofsetleri.
static func area(id: String) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	if data(id)["area"] == "square":
		for d in [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
			offsets.append(d)
	return offsets


## Harita byte kodu: 0 ağaç yok, 1 çam, 2 meşe, 3 meyve.
static func code(id: String) -> int:
	return IDS.find(id) + 1


static func id_from_code(c: int) -> String:
	return IDS[c - 1] if c >= 1 and c <= IDS.size() else ""
