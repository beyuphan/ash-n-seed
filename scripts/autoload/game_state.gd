extends Node
## Oyunun tek doğruluk kaynağı: Kasa, Halk, Çevre, gün ve faz.
## UI ve sahneler değerleri buradan okur ve sinyallere bağlanır.

signal run_started
signal stats_changed
signal day_changed(day: int)
signal phase_changed(phase: int)
signal game_over(ending_key: String)
signal game_won

enum Phase { MORNING, FIELD, EVENING }

const MAX_DAYS := 30
const STAT_MAX := 100.0
## 30. gün sonunda "dönüşü olmayan noktayı" aşmamak için gereken Çevre değeri. Son bölüm hedefi 66, görevden alınma sınırı 58:
## 58 ve üstü kazanmaktır (aradaki boşluk kalmasın).
const WIN_NATURE_THRESHOLD := 58.0

## Gizli günlük çevre kaybı. Kötü kararlar bunu yükseltir, her sabah Çevre'den düşülür.
var pollution_rate: float = 0.0
## Bölümün ve filtresiz bacaların getirdiği günlük Çevre kaybı. Akşam saha tarafından hesaplanır.
var base_decay: float = 0.0
var money: float = 50.0
var people: float = 50.0
var nature: float = 30.0
var day: int = 1
var phase: Phase = Phase.MORNING
var running: bool = false
## Günün ne kadarı kaldı: 1 sabah, 0 gece. Saha stamina'sından beslenir, Atmosphere gün batımı için okur.
var day_progress: float = 1.0
## Oyun boyunca toplam sayaçlar (outro ve son ekran için): planted, collected, favors, groves, tea, rabbit ...
var totals: Dictionary = {}


func new_game() -> void:
	money = 50.0
	people = 50.0
	nature = 30.0
	pollution_rate = 0.0
	base_decay = 0.0
	day = 1
	phase = Phase.MORNING
	running = true
	day_progress = 1.0
	totals = {}
	run_started.emit()
	stats_changed.emit()
	day_changed.emit(day)
	phase_changed.emit(phase)


## stat: &"money", &"people" veya &"nature". Değer 0..100 arasında kalır.
func add_total(key: String, amount: int = 1) -> void:
	totals[key] = int(totals.get(key, 0)) + amount


func change_stat(stat: StringName, delta: float) -> void:
	if not running:
		return
	match stat:
		&"money": money = clampf(money + delta, 0.0, STAT_MAX)
		&"people": people = clampf(people + delta, 0.0, STAT_MAX)
		&"nature": nature = clampf(nature + delta, 0.0, STAT_MAX)
		_:
			push_warning("Bilinmeyen gösterge: %s" % stat)
			return
	stats_changed.emit()
	_check_loss()


func next_phase() -> void:
	if not running:
		return
	if phase == Phase.EVENING:
		if day >= MAX_DAYS:
			_finish_run()
			return
		day += 1
		phase = Phase.MORNING
		day_changed.emit(day)
		change_stat(&"nature", -(pollution_rate + base_decay))  # gizli kirlilik ve bölüm baskısı her sabah işler
		if not running:
			return
	else:
		phase = (phase + 1) as Phase
	phase_changed.emit(phase)


func _check_loss() -> void:
	if money <= 0.0:
		_end("END_BANKRUPT")
	elif people <= 0.0:
		_end("END_REVOLT")
	elif nature <= 0.0:
		_end("END_POLLUTION")


func _finish_run() -> void:
	if nature >= WIN_NATURE_THRESHOLD:
		running = false
		game_won.emit()
	else:
		_end("END_DEADLINE")


func _end(ending_key: String) -> void:
	running = false
	game_over.emit(ending_key)
