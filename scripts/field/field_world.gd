class_name FieldWorld
extends Node2D
## Öğleden sonra: kuşbakışı saha. Büyük bir kasaba: gez, keşfet, ağaç dik, çöp topla, tehditlerle uğraş.
## Stamina bitince ya da "Günü bitir" düğmesine basılınca gün biter.
##
## Enerji: yürürken azalır (kirli karoda hızlı, yolda orta, temiz karoda yavaş), eylemler de enerji harcar
## (ağaç dikmek, yangın söndürmek). Koşmak (Shift) hızlandırır ama iki kat yakar.
## Üç ağaç türü (çam, meşe, meyve), kümelenince koru bonusu. Karakterlerin günlük farklı karşılaşmaları var.
## Günlük olay: kaçak çöp, yağmur, duman, tohumcu, yangın, kaçak oduncu.
## Ayar değerleri aşağıdaki sabitlerde, dengelemek için sadece onları değiştir.

signal day_finished

const Zone := FieldMap.Zone

# Enerji
const STAMINA_MAX := 200.0           ## kirli karoda ~40 sn, temiz karoda ~200 sn yürüyüş. Eylemler de harcar.
const DRAIN_DIRTY := 5.0             ## saniyede, kirli karoda yürürken
const DRAIN_CLEAN := 1.0             ## saniyede, temiz karoda yürürken
const DRAIN_ROAD := 2.0              ## saniyede, yolda yürürken
const SPRINT_DRAIN_MULT := 2.0
const STAMINA_X3 := 3.0              ## "stamina_x3" bayrağı varken azalma çarpanı
const SPEED := 78.0                  ## dünya pikseli / saniye
const SPRINT_SPEED_MULT := 1.65
const TRASH_ENERGY := 0.5            ## her çöp toplamak
const FIRE_ENERGY := 6.0             ## yangın söndürmek (kova ile 2)
const CHASE_ENERGY := 3.0            ## oduncuyu kovalamak
## Bölge çarpanları: sanayi zehirli, çöplük ağır. Ağaç dikmenin Çevre ödülü de buna göre artar.
const ZONE_DRAIN := {Zone.INDUSTRY: 1.5, Zone.LANDFILL: 1.25}
const ZONE_TREE_BONUS := {Zone.INDUSTRY: 2.0, Zone.LANDFILL: 1.5, Zone.RIVER: 1.25}
const TRASH_ZONE_WEIGHTS := {
	Zone.LANDFILL: 4.0, Zone.INDUSTRY: 2.5, Zone.RIVER: 2.0, Zone.HOUSING: 1.2,
	Zone.MARKET: 1.0, Zone.FARM: 0.8, Zone.FOREST: 0.6, Zone.NONE: 0.8, Zone.PARK: 0.2,
}

# Ekonomi
const TEA_PRICE := 5.0
const TEA_STAMINA := 0.15            ## çay maks. staminanın yüzde 15'i
const TEA_PER_DAY := 3
const WELL_STAMINA := 0.2
const TRASH_PER_SEED := 5            ## her 5 çöp geri dönüşümü = 1 çam tohumu
const DISCOVER_SEEDS := 1            ## yeni bölge keşfi
const NATURE_PER_TRASH := 0.15
const NATURE_LOST_PER_SPREAD := 0.4
const GROVE_NATURE := 1.2            ## koru bonusu
## Çevre yükseldikçe kazanç azalır (azalan verim): kazanç = ham değer x (DIMINISH_BASE - Çevre/100), en az DIMINISH_MIN.
const DIMINISH_BASE := 1.0
const DIMINISH_MIN := 0.12
const FILTER_PRICE := 15.0           ## baca filtresi (Kasa)
const FILTER_ENERGY := 8.0
const FILTER_DIST := 36.0
const RECYCLE_BATCH := 4            ## kaç çöp = 1 geri dönüşüm ödülü
const CHIMNEY_DECAY := 0.25          ## filtresiz her baca, günlük Çevre kaybı
const FIRE_NATURE_LOSS := 1.0        ## her yanan ağaç
const FIRE_DAILY_CAP := 14.0         ## bir günde yangından en fazla bu kadar Çevre kaybı
const FELLED_NATURE_LOSS := 2.0      ## her kesilen ağaç
const IDLE_BEFORE_SPREAD := 0.8      ## bu kadar durunca kirlilik yayılmaya başlar
const SPREAD_INTERVAL := 0.9
const TRASH_MIN := 24
const TRASH_MAX := 70
const COMBO_WINDOW := 3.0            ## çöp zinciri için süre
const MASK_DRAIN_MULT := 0.7
const BOOTS_SPEED_MULT := 1.15
const PANEL_FADE_ALPHA := 0.25         ## altlarında bir şey olan panellerin saydamlığı

# Harita ve kamera
const REVEAL_RADIUS := 7
const CAMERA_ZOOM := 3.0
const INTERACT_DISTANCE := 22.0
const POINTER_MIN_TILES := 8.0       ## pazara bu kadar uzaksa ok görünür
const GREEN_MIN := 0.06              ## Çevre 0 iken yeşil alan oranı
const GREEN_MAX := 0.8               ## Çevre 100 iken yeşil alan oranı

# Karakterler, olaylar, vatandaşlar
const PEDDLER_PRICE := 3.0           ## gezici tohumcu: yarı fiyat
const PEDDLER_STOCK := 3
const NPC_DISTANCE := 28.0
const SMOG_DRAIN_MULT := 1.4
const RAIN_DRAIN_MULT := 0.8
const VILLAGERS_MAX := 16
## Bölgenin hangi bölümde açıldığı (görev ve keşif için).
const ZONE_OPEN_CHAPTER := {Zone.HOUSING: 1, Zone.FOREST: 2, Zone.RIVER: 2, Zone.INDUSTRY: 3, Zone.FARM: 4, Zone.LANDFILL: 5}
const EVENT_WEIGHTS := {"flood": 12, "heat": 12, "leak": 12, "storm": 12, "airdrop": 14, "none": 12, "dump": 18, "rain": 14, "smog": 12, "peddler": 14, "fire": 16, "logger": 14}

const SFX_PLOP: AudioStream = preload("res://assets/audio/sfx/drop_001.wav")
const SFX_SHINK: AudioStream = preload("res://assets/audio/sfx/confirmation_002.wav")
const SFX_PICK: AudioStream = preload("res://assets/audio/sfx/click_003.wav")
const SFX_BUY: AudioStream = preload("res://assets/audio/sfx/confirmation_001.wav")
const SFX_DENY: AudioStream = preload("res://assets/audio/sfx/error_001.wav")
const SFX_END: AudioStream = preload("res://assets/audio/sfx/bong_001.wav")
const SFX_ALARM: AudioStream = preload("res://assets/audio/sfx/error_003.wav")

const GOOD := Color(0.65, 0.92, 0.5)
const BAD := Color(1.0, 0.55, 0.45)
const GOLD := Color(1.0, 0.86, 0.4)

## Akşam gazetesi için günlük özet.
var day_stats := {}
var seed_counts := {"pine": 0, "oak": 0, "fruit": 0}
var selected_species := "pine"
## O gün açık ağaç türleri (çam her zaman, meşe ve meyve ilerledikçe).
var unlocked_species: Array[String] = ["pine"]
var stamina := STAMINA_MAX
var objectives := FieldObjectives.new()
## Bugünün olayı: none, dump, rain, smog, peddler, fire, logger.
var today_event := "none"
## Hulusi ile duman anlaşması yapıldı: bugün fabrika yakınında kirlilik yayılmaz.
var smoke_off := false

var _map: FieldMap
var _camera: CameraShake
var _threats: FieldThreats
var _encounters: FieldEncounters
var _ui: CanvasLayer
var _ui_root: Control
var _gauge: StatGauge
var _seed_bar: SeedBar
var _hint: Label
var _end_button: Button
var _over_label: Label
var _pointer: MarketPointer
var _guide: MarketPointer
var _rabbit_timer := -1.0
var guide: FieldGuide
var story: FieldStory
var _bag := 0
var _bag_label: Label
var _first_plant_done := false
var _fire_loss_today := 0.0
var _bench_day := {}            # bank karosu -> son oturulan gün
var _wish_day := -1
var _tree_water_day := -1
var _fish_state := ""
var _fish_time := 0.0
var disasters: FieldDisasters
var _disaster_label: Label
var challenge: Dictionary = {}
var _goal_ptr: MarketPointer
var _zone_label: Label
var _challenge_label: Label
var _current_zone := 0
var _quip_cooldown := 0.0
var _drop_time := 0.0
var _drop_total := 0
var _rumor_chest := Vector2i(-1, -1)
var _promise_panel: PromisePanel
var _mini_game: MiniGame
var favors: FieldFavors
var home: FieldHome
var _promise_timer := 0.0
var _aux_ptr: MarketPointer
var _tut_label: Label
var _goal_label: Label
var _tut_done := {}
var _big_map: BigMap
var _wp_ptr: MarketPointer
var waypoint := Vector2i(-1, -1)
var _banner: Label
var _minimap: MiniMap
var _objectives_panel: ObjectivesPanel
var _dialog: DialogPanel
var _shop: ShopPanel
var _weather: WeatherOverlay
var _banner_tween: Tween
var _dust_timer := 0.0
var _discovered: Dictionary = {}     # zone -> true (oyun boyunca kalıcı)
var _tea_left := TEA_PER_DAY
var _last_tile := Vector2i(-1, -1)
var _minimap_timer := 0.0
var _green_timer := 0.0
var _trash_total := 0
var _combo := 0
var _combo_left := 0.0
var _next_event := ""
var _first_day := true
var _active := false
var _ending := false
var _idle_time := 0.0
var _spread_timer := 0.0
var _walk_time := 0.0


func _ready() -> void:
	_map = FieldMap.new()
	add_child(_map)
	_threats = FieldThreats.new(self, _map)
	guide = FieldGuide.new(self)
	story = FieldStory.new(self)
	disasters = FieldDisasters.new(self, _map)
	_encounters = FieldEncounters.new(self)
	favors = FieldFavors.new(self)
	home = FieldHome.new(self)

	_camera = CameraShake.new()
	_camera.zoom = Vector2(CAMERA_ZOOM, CAMERA_ZOOM)
	var world := _map.world_size()
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(world.x)
	_camera.limit_bottom = int(world.y)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 7.0
	add_child(_camera)

	_build_ui()
	_reset_day_stats()
	_fire_loss_today = 0.0
	set_active(false)


func set_active(on: bool) -> void:
	_active = on
	visible = on
	_ui.visible = on
	_map.set_process(on)
	set_process(on)
	set_process_unhandled_input(on)
	_camera.enabled = on
	if on:
		_camera.make_current()


## Yeni gün: enerji dolar, oyuncu pazarın önüne gelir, harita Çevre'ye göre ayarlanır, görevler ve olay yenilenir.
func begin_day() -> void:
	stamina = STAMINA_MAX
	_ending = false
	_idle_time = 0.0
	_spread_timer = 0.0
	_tea_left = TEA_PER_DAY
	_tut_done.clear()
	_combo = 0
	_combo_left = 0.0
	smoke_off = false
	_reset_day_stats()
	_threats.clear()
	_map.drops.clear()
	disasters.clear()
	_drop_time = 0.0
	challenge = {}
	_current_zone = 0
	_rabbit_timer = randf_range(12.0, 45.0) if FieldProgression.has("rabbit", GameState.day) and randf() < 0.7 else -1.0
	_map.player_pos = _map.door_world_position()
	_map.player_facing = 0
	_map.player_flip = false
	_last_tile = Vector2i(-1, -1)
	var day := GameState.day
	var chapter := FieldProgression.chapter(day)
	# Bölüm: açık harita parçaları ve açılan özellikler
	_map.apply_regions(FieldProgression.regions(day))
	_place_npcs(day)
	_apply_features(day)
	_assign_topics(day)
	# Harita Çevre'yi yansıtır: Çevre yükseldikçe daha yeşil ve nehir daha temiz, düştükçe tersi.
	var nature_ratio := clampf(GameState.nature / GameState.STAT_MAX, 0.0, 1.0)
	_map.water_quality = nature_ratio
	_map.view_tiles = Rect2i(0, 0, FieldMap.COLS, FieldMap.ROWS)  # dönüşüm anlık olsun, sonra kameraya döner
	_map.sync_green_to(lerpf(GREEN_MIN, GREEN_MAX, nature_ratio))
	_fill_trash(float(chapter["trash"]) * (0.7 if day == 1 else 1.0))
	_map.spawn_villagers(int(round((1.0 - _map.dirty_ratio()) * VILLAGERS_MAX)),
		_map.tile_at(_map.door_world_position()), 22)  # önce pazar çevresinde, oyuncu onları görsün
	var event_text := _start_today_event()
	var home_line := home.begin_day(day)
	_over_label.visible = false
	_end_button.disabled = false
	var free_seeds := 8 if day == 1 else int(chapter["seeds"]) + (1 if story.flag("seeds_saved") else 0)
	add_seeds("pine", free_seeds + (1 if has_upgrade("nursery") else 0))
	if story.flag("yigithan_roots"):  # Kök Sözü: Yiğithan her sabah bir meşe fidanı bırakır
		add_seeds("oak", 1)
	objectives.generate(day, _objective_context())
	for it in objectives.items:
		if it["kind"] == today_event and disasters.active() and today_event != "storm":
			it["target"] = maxi(1, disasters.total)
	_objectives_panel.objectives = objectives
	set_active(true)
	_camera.position = _map.player_pos
	_camera.reset_smoothing()
	_update_view()
	_gauge.set_value(stamina)
	_refresh_seed_bar()
	_refresh_minimap()
	var banner := tr("FIELD_FREE_SEEDS") % free_seeds
	_update_story_visuals(day)
	guide.on_day_start(day)
	_story_hints()
	if event_text != "":
		banner += "\n" + event_text
	if home_line != "":
		banner += "\n" + home_line
	_show_banner(banner, 6.0 if home_line != "" else 5.0)
	_first_day = false


## Açılan özelliklere göre karakterleri, kuyuları, sandıkları, tohum yuvalarını ve arayüzü ayarlar.
func _apply_features(day: int) -> void:
	for n in _map.npcs:
		if not n["temp"]:
			n["active"] = FieldProgression.has(n["id"], day) and not _map.is_locked(n["t"])
	for p in _map.pois:
		p["active"] = FieldProgression.has("chests" if p["kind"] == "chest" else "wells", day) and not _map.is_locked(p["t"])
		if p["active"] and p["kind"] == "well":
			_map.reveal(p["t"], 3)  # kuyular tanıdık yerlerdir, haritada baştan görünür
	_map.filter_enabled = FieldProgression.has("filter", day)
	_minimap.visible = FieldProgression.has("minimap", day)
	unlocked_species = ["pine"]
	if FieldProgression.has("oak", day):
		unlocked_species.append("oak")
	if FieldProgression.has("fruit", day):
		unlocked_species.append("fruit")
	if not unlocked_species.has(selected_species):
		selected_species = "pine"


func _active_poi_count(kind: String) -> int:
	var n := 0
	for p in _map.pois:
		if p["kind"] == kind and p["active"] and not p["used"]:
			n += 1
	return n


func _objective_context() -> Dictionary:
	var day := GameState.day
	var zones: Array = []
	for z in ZONE_OPEN_CHAPTER:
		if FieldProgression.number(day) >= int(ZONE_OPEN_CHAPTER[z]):
			zones.append(z)
	var npcs: Array = []
	for n in _map.npcs:
		if not n["temp"] and n["active"] and n["topic"] != "" and n["used_day"] != day:
			npcs.append(n["id"])
	var places: Array = []
	for l in _map.landmarks:
		if not _map.is_locked(l["t"]) and l["id"] != "tohum_bankasi":
			places.append(l["id"])
	var zone_trash := {}
	for tr_item in _map.trash:
		var zz: int = _map.zone_at(tr_item["tile"])
		zone_trash[zz] = int(zone_trash.get(zz, 0)) + 1
	return {
		"trash_total": _map.trash.size(), "zone_trash": zone_trash,
		"places": places, "zones": zones, "npcs": npcs, "event": today_event,
		"green_pct": int(round((1.0 - _map.dirty_ratio()) * 100.0)),
		"full": FieldProgression.has("objectives_full", day),
		"oak": FieldProgression.has("oak", day), "fruit": FieldProgression.has("fruit", day),
		"grove": FieldProgression.has("grove", day), "chests": _active_poi_count("chest") >= 1,
		"wells": _active_poi_count("well") >= 2, "talk": not npcs.is_empty(),
		"theme": FieldProgression.theme_objective(day),
	}


## Öğretici: ilk günlerde her gün tek bir öğrenilecek şey. [metin, sayaç, hedef]
const TUTORIAL := {
	1: [["TUT_MOVE", "walked", 8], ["TUT_PLANT", "planted", 3], ["TUT_ENERGY", "low_energy", 1], ["TUT_END1", "never", 1]],
	2: [["TUT_PINAR", "talks", 1], ["TUT_TRASH", "collected", 4], ["TUT_PLANT2", "planted", 3], ["TUT_END", "never", 1]],
	3: [["TUT_MARKET", "bought", 1], ["TUT_TEA", "tea", 1], ["TUT_FAVOR", "favors", 1], ["TUT_END", "never", 1]],
	4: [["TUT_MAP", "map", 1], ["TUT_WELL", "wells", 1], ["TUT_END", "never", 1]],
	5: [["TUT_TALK", "talks", 1], ["TUT_END", "never", 1]],
	6: [["TUT_FAVOR", "favors", 1], ["TUT_END", "never", 1]],
}


## Öğretici: en yakın dikilebilir toprağı oyuncuya gösterir (pazar meydanı taş, orada ağaç dikilmez).
func _point_to_plantable() -> void:
	var here := _map.tile_at(_map.player_pos)
	if _map.can_plant(here):
		return
	var best := Vector2i(-1, -1)
	var best_d := 1e9
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			if _map.is_locked(t) or not _map.can_plant(t):
				continue
			var d := Vector2(t - here).length()
			if d < best_d:
				best_d = d
				best = t
	if best.x >= 0 and best_d > 3.0:
		guide.goal_tile = best
		guide.goal_key = "FIELD_GUIDE_PLANTABLE"


func stat(key: String) -> void:
	day_stats[key] = int(day_stats.get(key, 0)) + 1
	GameState.add_total(key)


func _update_tutorial() -> void:
	var steps: Array = TUTORIAL.get(GameState.day, [])
	if steps.is_empty():
		_tut_label.visible = false
		return
	if stamina <= STAMINA_MAX * 0.7:
		day_stats["low_energy"] = 1
	var current := -1
	for i in steps.size():
		var st: Array = steps[i]
		if int(day_stats.get(st[1], 0)) >= int(st[2]):
			if not _tut_done.get(i, false):
				_tut_done[i] = true
				_toast(tr("TUT_OK"), GOLD)
				AudioManager.play_sfx(SFX_BUY, 0.0, -6.0)
		else:
			current = i
			break
	_tut_label.visible = current >= 0
	var key: String = steps[current][0] if current >= 0 else ""
	if (key == "TUT_PLANT" or key == "TUT_PLANT2") and guide.goal_tile.x < 0 and guide.queue.is_empty():
		_point_to_plantable()
	if current >= 0:
		_tut_label.text = tr("TUT_LINE") % [current + 1, steps.size(), tr(key)]
	# Dikkat çek: ilgili öğe nabız gibi atar
	var pulse := 0.65 + 0.35 * sin(Time.get_ticks_msec() / 180.0)
	_gauge.modulate = Color(1, 1, 1, 1).lerp(Color(1.4, 1.4, 0.8), 1.0 - pulse) if key == "TUT_ENERGY" else Color.WHITE
	_end_button.modulate = Color(1, 1, 1, 1).lerp(Color(1.4, 1.4, 0.8), 1.0 - pulse) if key.begins_with("TUT_END") else Color.WHITE


func _reset_day_stats() -> void:
	day_stats = {"planted": 0, "collected": 0, "polluted": 0, "discovered": 0, "chests": 0,
		"groves": 0, "burned": 0, "felled": 0, "chased": 0, "extinguished": 0, "walked": 0, "low_energy": 0, "bought": 0, "tea": 0, "map": 0, "wells": 0, "talks": 0, "favors": 0, "rabbit": 0, "windows": 0}


# ------------------------------------------------------------------ Dışarıya açık yardımcılar (karşılaşmalar, tehditler, gazete)

func dirty_ratio() -> float:
	return _map.dirty_ratio()


func villager_count() -> int:
	return _map.villagers.size()


func water_quality() -> float:
	return _map.water_quality


func total_seeds() -> int:
	var n := 0
	for id in seed_counts:
		n += seed_counts[id]
	return n


func has_upgrade(id: String) -> bool:
	return _shop.owned.get(id, false)


## Akşam: meyve ağaçlarının Kasa geliri.
func fruit_income() -> float:
	return minf(float(_map.species_count("fruit")), 8.0) * float(FieldSpecies.data("fruit")["income"])


## Çevre kazancı: Çevre yükseldikçe azalır. Oyunun kolayca %100'e fırlamasını bu önler.
func gain_nature(raw: float) -> void:
	var factor := clampf(DIMINISH_BASE - GameState.nature / 85.0, DIMINISH_MIN, 1.0)
	GameState.change_stat(&"nature", raw * factor)


## Ertesi sabah kaybedilecek Çevre: bölümün taban kirliliği + filtresiz bacalar.
func daily_decay(day: int) -> float:
	var chimneys := _map.active_chimney_count() if FieldProgression.number(day) >= 3 else 0
	# Çevre yükseldikçe baskı da artar: doğayı korumak, kazanmaktan zordur.
	var pressure := maxf(0.0, GameState.nature - 35.0) * 0.045
	var guard := 0.6 if story.flag("yigithan_guard") else 0.0  # Yiğithan'ın gece nöbeti: günlük Çevre kaybı biraz azalır
	return maxf(float(FieldProgression.chapter(day)["decay"]) + CHIMNEY_DECAY * float(chimneys) + pressure - guard, 0.0)


func tomorrow_event() -> String:
	return _next_event if _next_event != "" else "none"


func add_seeds(species: String, n: int = 1) -> void:
	seed_counts[species] += n
	_refresh_seed_bar()


func give_money(amount: float) -> void:
	if CrisisManager.has_flag("kasa_kilitli"):  # kilitliyken Kasa kazancı yok
		return
	GameState.change_stat(&"money", amount)


func report(kind: String, amount: int = 1, arg = null) -> void:
	if not challenge.is_empty() and kind == challenge["kind"]:
		challenge["progress"] += amount
	_complete(objectives.report(kind, amount, arg))
	story.report_promise(kind, amount)


func portrait_for(npc_id: String) -> Texture2D:
	var path := "res://assets/art/characters/%s_idle.png" % npc_id
	if ResourceLoader.exists(path):
		return load(path)
	return FieldArt.person(npc_id, 0, 0)


## Çevrilmiş hazır metinle konuşma (günlük özeti gibi).
func say_text(portrait: Texture2D, name_key: String, text: String, option_keys: Array) -> void:
	var options: Array[String] = []
	for k in option_keys:
		options.append(tr(k))
	_dialog.open(portrait, tr(name_key), text, options)


func say(portrait: Texture2D, name_key: String, text_key: String, option_keys: Array, callback: Callable) -> void:
	var options: Array[String] = []
	for k in option_keys:
		options.append(tr(k))
	_dialog.open(portrait, tr(name_key), tr(text_key), options)
	if callback.is_valid():
		_dialog.chosen.connect(callback, CONNECT_ONE_SHOT)


## Açılmamış bir sandığın çevresini haritada açar (Rıza'nın söylentisi). Sandık kalmadıysa false.
func reveal_hidden_chest() -> bool:
	var chests: Array[Dictionary] = []
	for p in _map.pois:
		if p["kind"] == "chest" and p["active"] and not p["used"] and not _map.is_explored(p["t"]):
			chests.append(p)
	if chests.is_empty():
		return false
	var chosen: Dictionary = chests.pick_random()
	_map.reveal(chosen["t"], 5)
	_rumor_chest = chosen["t"]
	_minimap_timer = 0.0
	return true


func on_trees_burned(n: int) -> void:
	day_stats["burned"] += n
	# Günlük üst sınır: tek bir yangın bütün oyunu bitirmesin
	var loss := minf(FIRE_NATURE_LOSS * n, maxf(FIRE_DAILY_CAP - _fire_loss_today, 0.0))
	_fire_loss_today += loss
	GameState.change_stat(&"nature", -loss)
	_camera.shake(1.0, 0.3)
	_show_banner(tr("FIELD_FIRE_BURNED"), 2.5)


func on_tree_felled() -> void:
	day_stats["felled"] += 1
	GameState.change_stat(&"nature", -FELLED_NATURE_LOSS)
	_camera.shake(1.0, 0.3)
	AudioManager.play_sfx(SFX_DENY, 0.0, -6.0)
	_show_banner(tr("FIELD_LOGGER_CUT"), 2.5)


# ------------------------------------------------------------------ Ana döngü

func _process(delta: float) -> void:
	if _ending:
		return
	guide.update(delta)
	if _dialog.is_open or _shop.is_open or _mini_game.is_open or _big_map.is_open:  # konuşurken, alışverişte ve küçük oyunda yürünmez, zaman durur
		_map.player_moving = false
		_map.player_step = 0
		return
	_threats.update(delta)
	home.update(delta)
	_update_challenge(delta)
	_update_fishing(delta)
	_update_drops(delta)
	disasters.update(delta)
	_disaster_label.visible = disasters.active()
	if disasters.active():
		_disaster_label.text = disasters.status_text()
	if _rabbit_timer > 0.0:
		_rabbit_timer -= delta
		if _rabbit_timer <= 0.0 and not _ending and _threats.spawn_rabbit():
			_show_banner(tr("FIELD_RABBIT_SPAWN"), 4.0)
			AudioManager.play_sfx(SFX_BUY, 0.0, -6.0)
	_combo_left = maxf(_combo_left - delta, 0.0)
	if _combo_left <= 0.0:
		_combo = 0
	var dir := _read_direction()
	var moving := dir != Vector2.ZERO
	var sprinting := moving and stamina > 0.0 and Input.is_physical_key_pressed(KEY_SHIFT)
	_map.player_moving = moving
	var tile := _map.tile_at(_map.player_pos)
	if moving:
		_idle_time = 0.0
		dir = dir.normalized()
		_update_facing(dir)
		var speed := SPEED * (SPRINT_SPEED_MULT if sprinting else 1.0) * (BOOTS_SPEED_MULT if has_upgrade("boots") else 1.0)
		_move(dir * speed * delta)
		_walk_time += delta * (1.5 if sprinting else 1.0)
		_map.player_step = 1 if fmod(_walk_time * 8.0, 2.0) < 1.0 else 2
		tile = _map.tile_at(_map.player_pos)
		var drain := _drain_at(tile)
		if sprinting:
			drain *= SPRINT_DRAIN_MULT
			_dust_timer -= delta
			if _dust_timer <= 0.0:  # koşarken ayak tozu
				_dust_timer = 0.11
				_spawn_particles(_map.player_pos + Vector2(0, -1), FieldArt.dust(), 2, 0.4, 6.0, 16.0, -8.0, 180.0, 0.0)
		stamina = maxf(stamina - drain * delta, 0.0)
	else:
		_map.player_step = 0
		_idle_time += delta
		if _idle_time >= IDLE_BEFORE_SPREAD and today_event != "rain":  # yağmur kirliliği durdurur
			_spread_timer -= delta
			if _spread_timer <= 0.0:
				_spread_timer = SPREAD_INTERVAL
				_spread_pollution()
	if tile != _last_tile:
		_last_tile = tile
		_on_tile_changed(tile)
	_collect_trash()
	_update_npc_markers()
	GameState.day_progress = clampf(stamina / STAMINA_MAX, 0.0, 1.0)  # gün batımı filtresi için
	_camera.position = _map.player_pos + Vector2(-36, -8)
	_update_view()
	_gauge.set_value(stamina)
	_update_hint()
	_update_pointer()
	_update_waypoint()
	_update_guide()
	_update_labels(delta)
	_quip_cooldown = maxf(_quip_cooldown - delta, 0.0)
	_fade_panels_under_things(delta)
	if stamina <= 0.0:
		_end_day()


func _unhandled_input(event: InputEvent) -> void:
	if _ending or not _active or _dialog.is_open or _shop.is_open or _mini_game.is_open or _big_map.is_open:
		return
	if event.is_action_pressed("ui_accept"):
		_interact()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_E:
				_buy_tea()
			KEY_U:
				_open_shop()
			KEY_1:
				_select_species(0)
			KEY_2:
				_select_species(1)
			KEY_3:
				_select_species(2)
			KEY_R:
				_recycle()
			KEY_H:
				guide.repeat()
			KEY_J:
				_show_journal()
			KEY_M:
				_open_big_map()
			KEY_TAB:
				_select_species((unlocked_species.find(selected_species) + 1) % unlocked_species.size())
			_:
				return
		get_viewport().set_input_as_handled()


# ------------------------------------------------------------------ Hareket

func _read_direction() -> Vector2:
	var d := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		d.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		d.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		d.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		d.y += 1.0
	return d


func _update_facing(dir: Vector2) -> void:
	if absf(dir.x) > absf(dir.y):
		_map.player_facing = 2
		_map.player_flip = dir.x < 0.0
	else:
		_map.player_facing = 0 if dir.y > 0.0 else 1


func _move(step: Vector2) -> void:
	var pos := _map.player_pos
	if not _blocked(pos + Vector2(step.x, 0)):
		pos.x += step.x
	if not _blocked(pos + Vector2(0, step.y)):
		pos.y += step.y
	_map.player_pos = pos


func _blocked(p: Vector2) -> bool:
	for offset in [-4.0, 0.0, 4.0]:
		if _map.is_solid_world(p + Vector2(offset, 0)):
			return true
	return false


## Bulunulan karoya göre saniyedeki stamina kaybı.
func _drain_at(tile: Vector2i) -> float:
	var drain: float
	var ground := _map.ground_at(tile)
	var dirty := _map.is_dirty(tile)
	if ground == FieldMap.G_ROAD or ground == FieldMap.G_BRIDGE or ground == FieldMap.G_PLAZA:
		drain = DRAIN_ROAD
	elif dirty:
		drain = DRAIN_DIRTY * float(ZONE_DRAIN.get(_map.zone_at(tile), 1.0))
	else:
		drain = DRAIN_CLEAN
	if dirty and has_upgrade("mask"):
		drain *= MASK_DRAIN_MULT
	if CrisisManager.has_flag("stamina_x3"):  # kronik asit yağmuru: nefes almak üç kat zor
		drain *= STAMINA_X3
	if today_event == "smog" and dirty:
		drain *= SMOG_DRAIN_MULT
	elif today_event == "rain":
		drain *= RAIN_DRAIN_MULT
	return drain * float(FieldProgression.chapter(GameState.day)["drain"])  # geç bölümlerde nefes almak zorlaşır


## Eylem enerji harcar. Enerji bitince gün biter.
func spend_energy(amount: float) -> void:
	stamina = maxf(stamina - amount, 0.0)
	_gauge.set_value(stamina)


## Yeni karoya girince: sis açılır, yeni bölge keşfedilir, ziyaret görevi ilerler.
func _on_tile_changed(tile: Vector2i) -> void:
	stat("walked")
	if _map.reveal(tile, REVEAL_RADIUS) > 0:
		_minimap_timer = 0.0  # mini haritayı hemen yenile
	for l in _map.landmarks:
		if not _map.is_locked(l["t"]) and Vector2(tile - (l["t"] as Vector2i)).length() <= 5.0:
			report("place", 1, l["id"])
	var zone := _map.zone_at(tile)
	if zone == Zone.NONE:
		return
	_current_zone = zone
	if not _discovered.has(zone):
		_discover(zone)
	report("zone", 1, zone)


func _discover(zone: int) -> void:
	_discovered[zone] = true
	if zone == Zone.MARKET:  # başlangıç bölgesi, ödül yok
		return
	day_stats["discovered"] += 1
	add_seeds("pine", DISCOVER_SEEDS)
	AudioManager.play_sfx(SFX_SHINK, 0.0, -4.0)
	AudioManager.play_sfx(SFX_BUY, 0.0, -6.0)
	if GameState.day <= 3:
		_toast(tr("FIELD_DISCOVER") % tr(FieldMap.ZONE_KEYS[zone]), GOLD)
	else:
		_show_banner(tr("FIELD_DISCOVER") % tr(FieldMap.ZONE_KEYS[zone]), 3.0)
	_spawn_particles(_map.player_pos + Vector2(0, -10), FieldArt.sparkle(), 8, 0.7, 25.0, 60.0, 30.0, 180.0, 0.0)


# ------------------------------------------------------------------ Eylemler

## Boşluk: önce pazar, sonra acil olanlar (yangın, oduncu), karakter, kuyu ve sandık, en son ekim.
func _interact() -> void:
	var tile := _map.tile_at(_map.player_pos)
	if _map.in_market_zone(tile):
		_buy_seed()
		return
	if not _threats.fire_near(_map.player_pos).is_empty():
		_extinguish()
		return
	if _threats.logger_near(_map.player_pos):
		_chase_logger()
		return
	if _threats.rabbit_near(_map.player_pos):
		_catch_rabbit()
		return
	if disasters.interact():
		return
	var npc_first := _map.npc_near(_map.player_pos, NPC_DISTANCE)
	if not npc_first.is_empty():
		_talk(npc_first)
		return
	if home.interact():
		return
	if _mini_interaction():
		return
	if _map.filter_enabled and not _map.filter_building_near(_map.player_pos, FILTER_DIST).is_empty():
		_install_filter()
		return
	var npc := _map.npc_near(_map.player_pos, NPC_DISTANCE)
	if not npc.is_empty():
		_talk(npc)
		return
	var poi := _map.poi_near(_map.player_pos, INTERACT_DISTANCE, GameState.day)
	if not poi.is_empty():
		if poi["kind"] == "chest":
			_open_chest(poi)
		else:
			_drink_well(poi)
		return
	if total_seeds() <= 0:
		_deny("FIELD_NO_SEEDS")
		return
	if not _map.can_plant(tile):
		_deny("FIELD_CANNOT_PLANT")
		return
	_plant(tile)


func _select_species(index: int) -> void:
	if index < 0 or index >= unlocked_species.size():
		return  # bu tür henüz açılmadı
	selected_species = unlocked_species[index]
	AudioManager.play_sfx(SFX_PICK, 0.0, -8.0)
	_refresh_seed_bar()


func _buy_seed() -> void:
	if CrisisManager.has_flag("ambargo"):  # uluslararası ambargo: tohum alımı yasak
		_deny("FIELD_EMBARGO")
		return
	var price: float = FieldSpecies.data(selected_species)["price"]
	# Kasa tam sıfıra inerse oyun biter, o yüzden en az 1 birim artmalı.
	if GameState.money <= price:
		_deny("FIELD_NO_MONEY")
		return
	GameState.change_stat(&"money", -price)
	add_seeds(selected_species, 1)
	stat("bought")
	AudioManager.play_sfx(SFX_BUY, 0.05, -4.0)
	_toast(tr("FIELD_GOT_SEED") % tr(FieldSpecies.data(selected_species)["name"]), GOOD)


func _open_shop() -> void:
	if not FieldProgression.has("shop", GameState.day):
		return
	if not _map.in_market_zone(_map.tile_at(_map.player_pos)):
		return
	_shop.open(GameState.money)


func _on_upgrade_bought(id: String) -> void:
	_toast(tr("SHOP_BOUGHT"), GOLD)
	AudioManager.play_sfx(SFX_SHINK, 0.0, -3.0)
	_refresh_seed_bar()


func _buy_tea() -> void:
	if not _map.in_market_zone(_map.tile_at(_map.player_pos)):
		return
	if _tea_left <= 0:
		_deny("FIELD_TEA_LIMIT")
		return
	if GameState.money <= TEA_PRICE:
		_deny("FIELD_NO_MONEY")
		return
	GameState.change_stat(&"money", -TEA_PRICE)
	_tea_left -= 1
	stat("tea")
	_restore_stamina(TEA_STAMINA)
	AudioManager.play_sfx(SFX_BUY, 0.1, -5.0)
	_toast(tr("FIELD_TEA"), GOOD)
	_quip("FIELD_QUIP_TEA", 5, 1.0)


func _drink_well(poi: Dictionary) -> void:
	if disasters.kind == "heat" and not disasters.carrying_water:
		disasters.on_well()  # kuraklıkta kuyu her zaman kova doldurur
		if poi["used_day"] == GameState.day:
			return
	elif poi["used_day"] == GameState.day:
		_deny("FIELD_WELL_EMPTY")
		return
	poi["used_day"] = GameState.day
	_restore_stamina(WELL_STAMINA)
	AudioManager.play_sfx(SFX_PLOP, 0.2, -3.0)
	_toast(tr("FIELD_WELL"), GOOD)
	stat("wells")
	report("well")


func _open_chest(poi: Dictionary) -> void:
	poi["used"] = true
	day_stats["chests"] += 1
	var t: Vector2i = poi["t"]
	var center := Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.5) * FieldMap.TILE)
	_spawn_particles(center, FieldArt.sparkle(), 8, 0.8, 30.0, 70.0, 80.0, 90.0, 0.0)
	AudioManager.play_sfx(SFX_SHINK, 0.0, -3.0)
	AudioManager.play_sfx(SFX_BUY, 0.05, -4.0)
	_camera.shake(0.8, 0.25)
	var roll := randf()
	if roll < 0.35:
		add_seeds("pine", 2)
		add_seeds("oak", 1)
		_toast(tr("FIELD_CHEST_SEEDS"), GOLD)
	elif roll < 0.55:
		add_seeds("fruit", 2)
		_toast(tr("FIELD_CHEST_FRUIT"), GOLD)
	elif roll < 0.8:
		var amount := randi_range(10, 20)
		give_money(float(amount))
		_toast(tr("FIELD_CHEST_MONEY") % amount, GOLD)
	else:
		_restore_stamina(1.0)
		_toast(tr("FIELD_CHEST_ENERGY"), GOLD)
	_minimap_timer = 0.0
	report("chest")


func _plant(tile: Vector2i) -> void:
	if seed_counts[selected_species] <= 0:  # seçili tür bittiyse eldeki ilk türe geç
		for id in FieldSpecies.IDS:
			if seed_counts[id] > 0:
				selected_species = id
				break
	var species := selected_species
	var info := FieldSpecies.data(species)
	var result := _map.plant(tile, species, FieldProgression.has("grove", GameState.day))
	seed_counts[species] -= 1
	day_stats["planted"] += 1
	GameState.add_total("planted")
	_refresh_seed_bar()
	spend_energy(float(info["energy"]))
	var center := Vector2((tile.x + 0.5) * FieldMap.TILE, (tile.y + 0.5) * FieldMap.TILE)
	var big := species == "oak"
	# "Pıtpıt": yaprak parçacıkları, tok ses, hafif kamera sarsıntısı. Meşe daha gürültülü.
	_spawn_particles(center, FieldArt.leaf(), randi_range(3, 5) + (3 if big else 0), 0.9, 38.0, 80.0, 170.0, 75.0, 7.0)
	_spawn_particles(center, FieldArt.sparkle(), 4, 0.45, 18.0, 46.0, 0.0, 180.0, 0.0)
	AudioManager.play_sfx(SFX_PLOP, 0.1 if not big else 0.04, -1.0 if not big else 2.0)
	AudioManager.play_sfx(SFX_SHINK, 0.04, -10.0)
	_camera.shake(1.3 if not big else 2.0, 0.5)
	var bonus := float(ZONE_TREE_BONUS.get(_map.zone_at(tile), 1.0))
	gain_nature(float(info["nature"]) * bonus)
	_cheer_villagers(center)
	report("plant")
	_quip("FIELD_QUIP_PLANT", 14, 0.3)
	guide.offer("first_plant")
	if not _first_plant_done:
		_first_plant_done = true
		_spawn_particles(center + Vector2(0, -10), FieldArt.leaf(), 18, 1.2, 40.0, 110.0, 120.0, 180.0, 8.0)
		_camera.shake(2.5, 0.4)
		_toast(tr("FIELD_FIRST_TREE"), GOLD)
	report("plant_zone", 1, _map.zone_at(tile))
	report("species", 1, species)
	if result["grove"]:
		_on_grove(center)


## Dört ağaç yakın kümelenince koru: ek Çevre, bedava tohum, büyük parıltı.
func _on_grove(center: Vector2) -> void:
	day_stats["groves"] += 1
	GameState.add_total("groves")
	gain_nature(GROVE_NATURE * (1.8 if story.flag("grove_ritual") else 1.0))
	add_seeds("pine", 1)
	_spawn_particles(center + Vector2(0, -8), FieldArt.leaf(), 10, 1.1, 40.0, 100.0, 120.0, 180.0, 8.0)
	_spawn_particles(center + Vector2(0, -8), FieldArt.sparkle(), 10, 0.8, 30.0, 80.0, 0.0, 180.0, 0.0)
	AudioManager.play_sfx(SFX_SHINK, 0.0, -2.0)
	AudioManager.play_sfx(SFX_BUY, 0.0, -3.0)
	_camera.shake(2.4, 0.6)
	_toast(tr("FIELD_GROVE"), GOLD)
	report("grove")


func _extinguish() -> void:
	var cost := 2.0 if has_upgrade("bucket") else FIRE_ENERGY
	if _threats.extinguish(_map.player_pos):
		spend_energy(cost)
		day_stats["extinguished"] += 1
		AudioManager.play_sfx(SFX_PLOP, 0.1, 1.0)
		_spawn_particles(_map.player_pos + Vector2(0, -8), FieldArt.puff(), 5, 0.7, 20.0, 50.0, -20.0, 90.0, 0.0)
		_toast(tr("FIELD_FIRE_OUT"), GOOD)
		give_money(3.0)
		report("fire")


func _install_filter() -> void:
	var b := _map.filter_building_near(_map.player_pos, FILTER_DIST)
	if b.is_empty():
		return
	if GameState.money <= filter_price():
		_deny("FIELD_NO_MONEY")
		return
	GameState.change_stat(&"money", -filter_price())
	b["filtered"] = true
	spend_energy(FILTER_ENERGY)
	AudioManager.play_sfx(SFX_BUY, 0.0, -2.0)
	_spawn_particles(_map.player_pos + Vector2(0, -12), FieldArt.puff(), 6, 0.8, 20.0, 50.0, -20.0, 90.0, 0.0)
	_spawn_particles(_map.player_pos + Vector2(0, -16), FieldArt.sparkle(), 14, 1.0, 30.0, 80.0, 40.0, 180.0, 0.0)
	_camera.shake(1.2, 0.25)
	var counts := _map.factory_counts()
	_toast(tr("FIELD_FILTER_DONE") + "  " + tr("FIELD_FILTER_COUNT") % [counts.x, counts.y], GOOD)
	report("filter")


func _catch_rabbit() -> void:
	var pos := _map.player_pos
	if not _threats.catch_rabbit(pos):
		return
	day_stats["discovered"] += 1
	if unlocked_species.has("oak"):
		add_seeds("oak", 2)
	else:
		add_seeds("pine", 3)
	give_money(8.0)
	GameState.change_stat(&"people", 1.0)
	AudioManager.play_sfx(SFX_BUY, 0.0, 0.0)
	_camera.shake(2.0, 0.4)
	_spawn_particles(pos + Vector2(0, -10), FieldArt.sparkle(), 14, 0.9, 30.0, 90.0, 0.0, 180.0, 0.0)
	_toast(tr("FIELD_RABBIT_CAUGHT"), GOLD)
	stat("rabbit")
	report("rabbit")


func _chase_logger() -> void:
	if _threats.chase(_map.player_pos):
		spend_energy(CHASE_ENERGY)
		day_stats["chased"] += 1
		give_money(10.0)
		GameState.change_stat(&"people", 1.0)
		AudioManager.play_sfx(SFX_BUY, 0.0, -2.0)
		_toast(tr("FIELD_LOGGER_CHASED") % 10, GOOD)
		report("logger")


func _collect_trash() -> void:
	var tile := _map.tile_at(_map.player_pos)
	var kind := _map.take_trash_at(tile)
	if kind < 0:
		return
	day_stats["collected"] += 1
	GameState.add_total("collected")
	spend_energy(TRASH_ENERGY)
	var center := Vector2((tile.x + 0.5) * FieldMap.TILE, (tile.y + 0.5) * FieldMap.TILE)
	_spawn_particles(center, FieldArt.sparkle(), 3, 0.4, 14.0, 36.0, 0.0, 180.0, 0.0)
	AudioManager.play_sfx(SFX_PICK, 0.15 + 0.05 * _combo, -3.0)
	_trash_total += 1
	_bag += 1
	# Zincir: 3 saniye içinde peş peşe toplarsan her çöp daha çok Çevre kazandırır
	_combo += 1
	_combo_left = COMBO_WINDOW
	if _combo >= 3:
		_toast("x%d" % _combo, GOLD)
	if _combo == 6:
		add_seeds("pine", 1)
		_toast(tr("FIELD_COMBO_BONUS"), GOLD)
	if _trash_total % TRASH_PER_SEED == 0:  # sıfır atık: geri dönüşüm tohum kazandırır
		add_seeds("pine", 1)
		AudioManager.play_sfx(SFX_BUY, 0.05, -6.0)
		_toast(tr("FIELD_TRASH_SEED"), GOOD)
	gain_nature(NATURE_PER_TRASH * (1.0 + 0.1 * float(mini(_combo, 6))))
	_quip("FIELD_QUIP_TRASH", 10, 0.1)
	report("trash")
	report("trash_zone", 1, _map.zone_at(tile))


func _spread_pollution() -> void:
	var t := _map.pollute_one(not smoke_off)
	if t.x < 0:
		return
	day_stats["polluted"] += 1
	if GameState.day >= 3:
		guide.offer("spread")
	var center := Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.5) * FieldMap.TILE)
	_spawn_particles(center, FieldArt.puff(), 3, 0.8, 8.0, 20.0, -20.0, 60.0, 0.0)
	GameState.change_stat(&"nature", -NATURE_LOST_PER_SPREAD)


func _restore_stamina(fraction: float) -> void:
	stamina = minf(stamina + STAMINA_MAX * fraction, STAMINA_MAX)
	_gauge.set_value(stamina)


## Tamamlanan görevlerin ödülünü verir.
func _complete(done: Array[Dictionary]) -> void:
	for it in done:
		it["flash"] = 1.0
		var r: Dictionary = it["reward"]
		if r.has("money"):
			give_money(float(r["money"]))
		for species in FieldSpecies.IDS:
			if r.has(species):
				add_seeds(species, int(r[species]))
		if r.has("stamina"):
			_restore_stamina(float(r["stamina"]))
		AudioManager.play_sfx(SFX_SHINK, 0.0, -2.0)
		AudioManager.play_sfx(SFX_BUY, 0.0, -3.0)
		_show_banner("%s  %s" % [tr("OBJ_DONE"), FieldObjectives.reward_text_of(it, Callable(self, "tr"))], 3.5)
		_spawn_particles(_map.player_pos + Vector2(0, -12), FieldArt.sparkle(), 10, 0.8, 30.0, 70.0, 20.0, 180.0, 0.0)


func _end_day() -> void:
	if _ending:
		return
	_ending = true
	disasters.finish()
	_map.player_moving = false
	_map.player_step = 0
	_end_button.disabled = true
	_over_label.text = tr("FIELD_DAY_OVER")
	_over_label.visible = true
	UiFx.pop_in(_over_label)
	AudioManager.play_sfx(SFX_END, 0.0, -6.0)
	await get_tree().create_timer(1.2).timeout
	if _active:
		day_finished.emit()


func _fill_trash(density: float = 1.0) -> void:
	var target := int(lerpf(TRASH_MIN, TRASH_MAX, _map.dirty_ratio()) * density)
	var guard := 0
	while _map.trash.size() < target and guard < 600:
		guard += 1
		var tile := _map.random_trash_tile(TRASH_ZONE_WEIGHTS)
		if tile.x >= 0:
			_map.add_trash(tile, randi() % FieldArt.TRASH_KINDS)


# ------------------------------------------------------------------ Karakterler, olaylar, vatandaşlar

func _talk(npc: Dictionary) -> void:
	if npc["id"] == "peddler":
		_buy_from_peddler(npc)
	elif npc["id"] == "favor":
		favors.talk(npc)
	else:
		stat("talks")
		_encounters.talk(npc)


func _buy_from_peddler(npc: Dictionary) -> void:
	if npc["stock"] <= 0:
		_deny("FIELD_PEDDLER_SOLD_OUT")
		return
	if GameState.money <= PEDDLER_PRICE:
		_deny("FIELD_NO_MONEY")
		return
	GameState.change_stat(&"money", -PEDDLER_PRICE)
	npc["stock"] -= 1
	add_seeds(selected_species, 1)
	AudioManager.play_sfx(SFX_BUY, 0.05, -4.0)
	_toast(tr("FIELD_GOT_SEED") % tr(FieldSpecies.data(selected_species)["name"]), GOOD)


## Karakterleri bölümün durağına yerleştirir (story_data.gd HOMES).
func _place_npcs(day: int) -> void:
	for n in _map.npcs:
		if n["temp"]:
			continue
		var spot := story.home_for(n["id"], day)
		if spot != "":
			_move_to_spot(n, spot)


func _move_to_spot(n: Dictionary, spot: String) -> void:
	var t := _map.spot_tile(spot)
	if t.x < 0:
		return
	_map.move_npc(n, _map.free_near(t))


## Pınar'ın ağacı: park gölünün kenarında, hikâye ilerledikçe büyür.
func plant_pinar_tree() -> void:
	var t := _map.free_near(Vector2i(20, 32))
	_map.add_tree(t, 17)
	_map.special_trees.append({"t": t})
	_update_story_visuals(GameState.day)
	_spawn_particles(Vector2((t.x + 0.5) * FieldMap.TILE, t.y * FieldMap.TILE), FieldArt.leaf(), 10, 1.0, 30.0, 80.0, 100.0, 180.0, 6.0)


func _update_story_visuals(day: int) -> void:
	var tile := 17 if day < 8 else (5 if day < 15 else (28 if day < 23 else 16))
	for st in _map.special_trees:
		_map.set_tree_tile(st["t"], tile)
	_map.vault_open = story.flag("vault_open")


func open_vault() -> void:
	_map.vault_open = true
	_camera.shake(3.0, 0.6)
	_show_banner(tr("FIELD_VAULT_OPEN"), 5.0)


## Fabrikalardan n tanesine filtre takar (hikâye kararları).
func filter_factories(n: int) -> void:
	for b in _map.buildings:
		if n <= 0:
			break
		if b["kind"] == "factory" and not b["filtered"]:
			b["filtered"] = true
			n -= 1


# ------------------------------------------------------------------ Küçük etkileşimler: bank, çeşme, iskele, Pınar'ın ağacı

func _near_pier() -> bool:
	var spot := _map.spot_tile("iskele_ucu")
	if spot.x < 0 or _map.is_locked(spot):
		return false
	var p := Vector2((spot.x + 0.5) * FieldMap.TILE, (spot.y + 0.5) * FieldMap.TILE)
	return _map.player_pos.distance_to(p) <= 40.0


func _near_pinar_tree() -> bool:
	for st in _map.special_trees:
		var t: Vector2i = st["t"]
		if _map.player_pos.distance_to(Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.5) * FieldMap.TILE)) <= 28.0:
			return true
	return false


func _mini_hint() -> String:
	var pp := _map.player_pos
	if _fish_state == "wait":
		return "FIELD_HINT_FISH_WAIT"
	if _fish_state == "bite":
		return "FIELD_HINT_FISH_PULL"
	if _near_pinar_tree():
		return "FIELD_HINT_TREE"
	if FieldProgression.has("bench", GameState.day) and not _map.deco_near("bench", pp, 20.0).is_empty():
		return "FIELD_HINT_SIT"
	if FieldProgression.has("wish", GameState.day) and not _map.deco_near("fountain", pp, 30.0).is_empty():
		return "FIELD_HINT_WISH"
	if _near_pinar_tree():
		return "FIELD_HINT_TREE"
	if FieldProgression.has("fish", GameState.day) and _near_pier():
		return "FIELD_HINT_FISH"
	return ""


## Boşluk tuşunun küçük etkileşimleri. İşlendiyse true.
func _mini_interaction() -> bool:
	var pp := _map.player_pos
	if _fish_state != "":
		_pull_line()
		return true
	if _near_pinar_tree():
		_water_pinar_tree()
		return true
	var bench := _map.deco_near("bench", pp, 20.0) if FieldProgression.has("bench", GameState.day) else {}
	if not bench.is_empty():
		var key: Vector2i = bench["t"]
		if _bench_day.get(key, -1) == GameState.day:
			_deny("FIELD_BENCH_USED")
		else:
			_bench_day[key] = GameState.day
			_restore_stamina(0.12)
			AudioManager.play_sfx(SFX_PLOP, 0.1, -4.0)
			_toast(tr("FIELD_SAT"), GOOD)
		return true
	if FieldProgression.has("wish", GameState.day) and not _map.deco_near("fountain", pp, 30.0).is_empty():
		_make_wish()
		return true
	if _near_pinar_tree():
		_water_pinar_tree()
		return true
	if FieldProgression.has("fish", GameState.day) and _near_pier():
		_cast_line()
		return true
	return false


func _make_wish() -> void:
	if _wish_day == GameState.day:
		_deny("FIELD_WISH_DONE")
		return
	if GameState.money <= 3.0:
		_deny("FIELD_NO_MONEY")
		return
	_wish_day = GameState.day
	GameState.change_stat(&"money", -2.0)
	AudioManager.play_sfx(SFX_PLOP, 0.15, 0.0)
	var c := Vector2(10.0 * FieldMap.TILE, 30.0 * FieldMap.TILE)
	_spawn_particles(c, FieldArt.sparkle(), 8, 0.9, 20.0, 60.0, 0.0, 180.0, 0.0)
	var roll := randf()
	if roll < 0.4:
		add_seeds("pine", 1)
		_toast(tr("FIELD_WISH_SEED"), GOLD)
	elif roll < 0.7:
		GameState.change_stat(&"people", 2.0)
		_toast(tr("FIELD_WISH_PEOPLE"), GOLD)
	else:
		_toast(tr("FIELD_WISH_NONE"), GOOD)


func _water_pinar_tree() -> void:
	if _tree_water_day == GameState.day:
		_deny("FIELD_TREE_DONE")
		return
	_tree_water_day = GameState.day
	report("water")
	GameState.change_stat(&"people", 1.0)
	AudioManager.play_sfx(SFX_PLOP, 0.1, -2.0)
	for st in _map.special_trees:
		var t: Vector2i = st["t"]
		_spawn_particles(Vector2((t.x + 0.5) * FieldMap.TILE, t.y * FieldMap.TILE), FieldArt.heart(), 4, 1.0, 14.0, 30.0, -6.0, 60.0, 0.0)
	_toast(tr("FIELD_TREE_WATERED"), GOLD)


func _cast_line() -> void:
	_fish_state = "wait"
	_fish_time = randf_range(1.6, 3.6)
	AudioManager.play_sfx(SFX_PLOP, 0.1, -6.0)
	_toast(tr("FIELD_FISH_CAST"), GOOD)


func _pull_line() -> void:
	if _fish_state == "wait":
		_fish_state = ""
		_toast(tr("FIELD_FISH_EARLY"), BAD)
		return
	_fish_state = ""
	spend_energy(4.0)
	var q := water_quality()
	if randf() < 0.45 + 0.45 * q:
		var gain := 4.0 + roundf(4.0 * q)
		give_money(gain)
		report("fish")
		AudioManager.play_sfx(SFX_BUY, 0.1, -2.0)
		_spawn_particles(_map.player_pos + Vector2(0, -12), FieldArt.sparkle(), 8, 0.7, 25.0, 60.0, 0.0, 180.0, 0.0)
		_toast(tr("FIELD_FISH_CATCH") % int(gain), GOLD)
	else:
		_bag += 1
		_toast(tr("FIELD_FISH_JUNK"), BAD)


func _update_fishing(delta: float) -> void:
	if _fish_state == "":
		return
	if not _near_pier():  # iskeleden uzaklaşırsan olta toplanır
		_fish_state = ""
		return
	_fish_time -= delta
	if _fish_state == "wait" and _fish_time <= 0.0:
		_fish_state = "bite"
		_fish_time = 0.9
		AudioManager.play_sfx(SFX_ALARM, 0.0, -10.0)
		_toast(tr("FIELD_FISH_BITE"), GOLD)
		_camera.shake(1.0, 0.15)
	elif _fish_state == "bite" and _fish_time <= 0.0:
		_fish_state = ""
		_toast(tr("FIELD_FISH_LOST"), BAD)


const PLACE_KEYS := {
	"okul_avlu": "LM_OKUL", "fidanlik_on": "LM_FIDANLIK", "cay_ocagi_on": "LM_CAY_OCAGI", "belediye_on": "LM_BELEDIYE",
	"degirmen_on": "LM_DEGIRMEN", "iskele_ucu": "LM_ISKELE", "orman_kulubesi_on": "LM_ORMAN_KULUBESI",
	"fabrika_kapisi_on": "LM_FABRIKA_KAPISI", "genel_mudurluk_on": "LM_GENEL_MUDURLUK", "lojman_on": "LM_LOJMAN",
	"sendika_on": "LM_SENDIKA", "ciftlik_on": "LM_CIFTLIK", "copluk_kapisi_on": "LM_COPLUK_KAPISI",
	"tohum_bankasi_on": "LM_TOHUM_BANKASI", "pazar_on": "FIELD_MARKET", "pinar_agaci": "LM_PINAR_AGACI",
}
const JOURNAL_FLAGS := ["vault_open", "journal", "kemal_gate", "workers_ally", "lab_report", "canan_trust", "canan_skeptic", "veli_legend", "deal", "pinar_tree"]


## J tuşu: Tomurcuk güncel durumu özetler. Ne yapacağını unutan oyuncu için yön gösterir.
func _show_journal() -> void:
	if _dialog.is_open or _shop.is_open or _mini_game.is_open or _big_map.is_open:
		return
	var day := GameState.day
	var ch := FieldProgression.chapter(day)
	var lines: Array[String] = []
	lines.append(tr("JOURNAL_CHAPTER") % [FieldProgression.number(day), tr(ch["name"]), int(ch["goal"]), int(GameState.nature)])
	var leads: Array[String] = []
	for n in _map.npcs:
		if n["temp"] or not n["active"] or n["topic"] == "" or n["used_day"] == day:
			continue
		var spot := story.home_for(n["id"], day)
		if str(n["topic"]).begins_with("story:"):
			spot = str(story.beat(str(n["topic"]).substr(6))["at"])
		leads.append(tr("JOURNAL_LEAD_ITEM") % [tr("CHAR_%s_NAME" % str(n["id"]).to_upper()), tr(PLACE_KEYS.get(spot, "FIELD_MARKET"))])
	if leads.is_empty():
		lines.append(tr("JOURNAL_NONE"))
	else:
		lines.append(tr("JOURNAL_LEADS") % ", ".join(leads))
	var clues: Array[String] = []
	for f in JOURNAL_FLAGS:
		if story.flag(f) and clues.size() < 3:
			clues.append(tr("JOURNAL_CLUE_" + f.to_upper()))
	if not clues.is_empty():
		lines.append(tr("JOURNAL_KNOWN") % " ".join(clues))
	say_text(portrait_for("assistant"), "CHAR_ASSIST_NAME", "\n".join(lines), ["JOURNAL_OK"])


## Panel ve uyarı şeritleri için yarı saydam koyu zemin.
func _strip_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.05, 0.04, 0.72)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


## Küçük oyunu açar. Bitince callback(başarı) çağrılır.
func start_mini_game(game: String, title_key: String, level: int, callback: Callable) -> void:
	_mini_game.start(game, title_key, level)
	_mini_game.finished.connect(callback, CONNECT_ONE_SHOT)


func promise_kept(id: String) -> void:
	AudioManager.play_sfx(SFX_BUY, 0.0, -2.0)
	_camera.shake(1.5, 0.3)
	_show_banner(tr("PROM_KEPT") % tr("PROM_%s_S" % id.to_upper()), 4.5)


## Sol panel: sözler, seni bekleyen karakter, yardım isteyen.
func _refresh_promises() -> void:
	var rows: Array = story.promise_rows(Callable(self, "tr"))
	var day := GameState.day
	var lead_count := 0
	for n in _map.npcs:
		if lead_count >= 1 or n["temp"] or not n["active"] or n["topic"] == "" or n["used_day"] == day:
			continue
		if not str(n["topic"]).begins_with("story:"):
			continue
		var spot := str(story.beat(str(n["topic"]).substr(6))["at"])
		rows.append({"mark": "!", "title": tr("PROM_WAITING") % tr("CHAR_%s_NAME" % str(n["id"]).to_upper()), "sub": tr(PLACE_KEYS.get(spot, "FIELD_MARKET")), "prog": ""})
		lead_count += 1
	if not favors.pending(_map).is_empty():
		rows.append({"mark": "!", "title": tr("FAVOR_ROW_T"), "sub": tr("FAVOR_ROW_S"), "prog": ""})
	_promise_panel.set_rows(rows)


## Her karakterin bugün anlatacağı bir şey var mı: hikâye sahnesi, ara sıra sıradan bir karşılaşma ya da hiçbir şey.
func _assign_topics(day: int) -> void:
	for n in _map.npcs:
		if n["temp"]:
			continue
		n["topic"] = ""
		if not n["active"]:
			continue
		var beat := story.topic_for(n["id"], day)
		if beat != "":
			n["topic"] = "story:" + beat
			_move_to_spot(n, str(story.beat(beat)["at"]))
		elif FieldEncounters.POOLS.has(n["id"]) and n["used_day"] != day and day - int(n["last_topic_day"]) >= 3 and randf() < 0.4:
			n["topic"] = "enc"
			n["last_topic_day"] = day


func _story_hints() -> void:
	for n in _map.npcs:
		if not n["temp"] and str(n["topic"]).begins_with("story:"):
			guide.offer_story(str(n["topic"]).substr(6), n["id"])


func filter_price() -> float:
	return FILTER_PRICE - (7.0 if story.flag("filter_cheap") else 0.0)


## Pazarda biriken çöpü geri dönüştür: her 4 çöp = 1 çam tohumu ve biraz Kasa.
func _recycle() -> void:
	if not FieldProgression.has("recycle", GameState.day) or not _map.in_market_zone(_map.tile_at(_map.player_pos)):
		return
	if _bag < RECYCLE_BATCH:
		_deny("FIELD_RECYCLE_NEED")
		return
	var batches := _bag / RECYCLE_BATCH
	_bag -= batches * RECYCLE_BATCH
	add_seeds("pine", batches)
	give_money(2.0 * batches)
	AudioManager.play_sfx(SFX_BUY, 0.1, -2.0)
	_spawn_particles(_map.player_pos + Vector2(0, -10), FieldArt.sparkle(), 8, 0.7, 25.0, 60.0, 0.0, 180.0, 0.0)
	_toast(tr("FIELD_RECYCLED") % batches, GOOD)


func _update_npc_markers() -> void:
	for n in _map.npcs:
		if n["id"] == "favor":
			n["marker"] = not n["done"]
		else:
			n["marker"] = n["stock"] > 0 if n["id"] == "peddler" else (n["topic"] != "" and n["used_day"] != GameState.day)


## Olay hangi özellik gününden sonra çıkabilir.
const EVENT_FEATURE := {"flood": "flood", "heat": "heat", "leak": "leak", "storm": "storm", "airdrop": "airdrop", "dump": "dump", "smog": "smog", "fire": "fire", "logger": "logger", "peddler": "events", "rain": "events"}


func _pick_event_name(for_day: int = -1) -> String:
	var day := for_day if for_day > 0 else GameState.day
	var pool := {}
	for k in EVENT_WEIGHTS:
		if EVENT_FEATURE.has(k) and not FieldProgression.has(EVENT_FEATURE[k], day):
			continue
		pool[k] = EVENT_WEIGHTS[k]
	var total := 0.0
	for k in pool:
		total += float(pool[k])
	var roll := randf() * total
	for k in pool:
		roll -= float(pool[k])
		if roll <= 0.0:
			return k
	return "none"


## Bugünün olayını belirler (dün Rıza haber verdiyse o), yarınınkini önceden seçer. Banner metnini döndürür.
func _start_today_event() -> String:
	_map.remove_temp_npcs()
	_weather.mode = "none"
	var name := _next_event if _next_event != "" else _pick_event_name()
	if GameState.day < 2:
		name = "none"
	_next_event = _pick_event_name(GameState.day + 1) if GameState.day + 1 >= 2 else "none"
	today_event = name
	var text := _apply_event(name)
	favors.maybe_spawn(GameState.day, _map)
	return text


func _apply_event(name: String) -> String:
	match name:
		"dump":
			var zone: int = [Zone.HOUSING, Zone.FARM, Zone.FOREST, Zone.RIVER].pick_random()
			var added := 0
			var guard := 0
			while added < 14 and guard < 800:
				guard += 1
				var t := Vector2i(randi_range(0, FieldMap.COLS - 1), randi_range(0, FieldMap.ROWS - 1))
				if _map.zone_at(t) == zone and _map.is_free_land(t) and not _map.trash_at(t):
					_map.add_trash(t, randi() % FieldArt.TRASH_KINDS)
					added += 1
			return tr("EVENT_DUMP_BANNER") % tr(FieldMap.ZONE_KEYS[zone])
		"flood", "heat", "leak", "storm":
			if not disasters.start(name):
				today_event = "none"
				return ""
			if name == "flood" or name == "storm":
				_weather.mode = "rain"
			AudioManager.play_sfx(SFX_ALARM, 0.0, -6.0)
			return tr("EVENT_%s_BANNER" % name.to_upper())
		"airdrop":
			var placed := _map_spawn_drops(5)
			if placed == 0:
				return ""
			_drop_total = placed
			_drop_time = 75.0
			AudioManager.play_sfx(SFX_ALARM, 0.0, -10.0)
			return tr("EVENT_AIRDROP_BANNER")
		"rain":
			_weather.mode = "rain"
			GameState.change_stat(&"nature", 1.0)
			return tr("EVENT_RAIN_BANNER")
		"smog":
			_weather.mode = "smog"
			return tr("EVENT_SMOG_BANNER")
		"peddler":
			var door := _map.tile_at(_map.door_world_position())
			for attempt in 80:
				var t := door + Vector2i(randi_range(-14, 14), randi_range(-10, 10))
				if _map.is_free_land(t) and not _map.trash_at(t) and not _map.in_market_zone(t):
					_map.add_npc("peddler", t, "peddler", true)
					_map.npcs.back()["stock"] = PEDDLER_STOCK
					break
			return tr("EVENT_PEDDLER_BANNER")
		"fire":
			var zone_key := _threats.start_fire()
			if zone_key == "":
				today_event = "none"
				return ""
			AudioManager.play_sfx(SFX_ALARM, 0.0, -6.0)
			return tr("EVENT_FIRE_BANNER") % tr(zone_key)
		"logger":
			var logger_zone := _threats.start_logger()
			if logger_zone == "":
				today_event = "dump"
				return _apply_event("dump")
			AudioManager.play_sfx(SFX_ALARM, 0.0, -6.0)
			return tr("EVENT_LOGGER_BANNER") % tr(logger_zone)
		_:
			return ""


## Ağaç dikilince yakındaki vatandaşların başında kalpler uçuşur.
func _cheer_villagers(center: Vector2) -> void:
	var hearts := 0
	for v in _map.villagers:
		if hearts >= 4:
			break
		if (v["pos"] as Vector2).distance_to(center) <= 110.0:
			_spawn_particles((v["pos"] as Vector2) + Vector2(0, -24), FieldArt.heart(), 1, 0.9, 14.0, 26.0, -6.0, 40.0, 0.0)
			hearts += 1


# ------------------------------------------------------------------ Kamera ve harita görünümü

func _update_view() -> void:
	var center := _camera.get_screen_center_position()
	var half := get_viewport_rect().size / (2.0 * _camera.zoom.x)
	var top_left := center - half
	var tiles := Vector2i(ceili(half.x * 2.0 / FieldMap.TILE) + 5, ceili(half.y * 2.0 / FieldMap.TILE) + 6)
	_map.view_tiles = Rect2i(floori(top_left.x / FieldMap.TILE) - 2, floori(top_left.y / FieldMap.TILE) - 2, tiles.x, tiles.y)


## Outro: oyun durur, arayüz gizlenir, bütün harita sinematik olarak gösterilir. Kamerayı döndürür.
func begin_cinematic(green_ratio: float, water: float) -> CameraShake:
	_active = false
	set_process(false)
	set_process_unhandled_input(false)
	visible = true
	_ui.visible = false
	_map.set_process(true)
	_map.reveal_all()
	_map.water_quality = water
	_map.view_tiles = Rect2i(0, 0, FieldMap.COLS, FieldMap.ROWS)
	_map.sync_green_to(green_ratio)
	_map.player_pos = Vector2(-500.0, -500.0)  # başkan görünmesin
	_camera.enabled = true
	_camera.limit_left = -600
	_camera.limit_top = -600
	_camera.limit_right = int(_map.world_size().x) + 600
	_camera.limit_bottom = int(_map.world_size().y) + 600
	_camera.position_smoothing_enabled = false
	_camera.make_current()
	return _camera


func cinematic_update_view() -> void:
	_update_view()


func _refresh_minimap() -> void:
	_minimap.set_image(_map.minimap_image())
	_minimap.player_tile = _map.tile_at(_map.player_pos)
	_bag_label.visible = FieldProgression.has("recycle", GameState.day) and _bag > 0
	_bag_label.text = tr("FIELD_BAG") % _bag
	_update_zone_label()
	_minimap.market_tile = _map.tile_at(_map.door_world_position()) + Vector2i(0, -2)
	_minimap.explored_percent = int(round(_map.explored_ratio() * 100.0))


func _refresh_seed_bar() -> void:
	_seed_bar.species = unlocked_species
	_seed_bar.counts = seed_counts
	_seed_bar.selected = selected_species
	_seed_bar.show_prices = _map.in_market_zone(_map.tile_at(_map.player_pos))
	_seed_bar.refresh()


func _update_labels(delta: float) -> void:
	var green_pct := int(round((1.0 - _map.dirty_ratio()) * 100.0))
	_objectives_panel.green_text = ("%s %d%%" % [tr("FIELD_GREEN"), green_pct]) if FieldProgression.has("minimap", GameState.day) else ""
	_update_tutorial()
	_promise_timer -= delta
	if _promise_timer <= 0.0:
		_promise_timer = 0.4
		_refresh_promises()
	_promise_panel.position = Vector2(14, _objectives_panel.position.y + _objectives_panel.size.y + 8.0)
	_minimap.player_tile = _map.tile_at(_map.player_pos)
	_minimap_timer -= delta
	if _minimap_timer <= 0.0:
		_minimap_timer = 0.5
		_refresh_minimap()
		_refresh_seed_bar()
	_green_timer -= delta
	if _green_timer <= 0.0:
		_green_timer = 1.0
		report("green", green_pct)


# ------------------------------------------------------------------ Efektler

func _spawn_particles(pos: Vector2, tex: Texture2D, amount: int, lifetime: float, v_min: float,
		v_max: float, gravity_y: float, spread: float, spin: float) -> void:
	var particles := GPUParticles2D.new()
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = spread
	mat.initial_velocity_min = v_min
	mat.initial_velocity_max = v_max
	mat.gravity = Vector3(0, gravity_y, 0)
	mat.angular_velocity_min = -spin * 60.0
	mat.angular_velocity_max = spin * 60.0
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.65, 1.0])
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp
	particles.process_material = mat
	particles.texture = tex
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.position = pos
	particles.z_index = 10
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(lifetime + 0.4).timeout.connect(particles.queue_free)   # düz metot bağlantısı: parçacık önce silinirse bağlantı kendiliğinden düşer


## Oyuncunun başında yukarı süzülen kısa yazı.
## Başkanın kafasının üstünde kısa, esprili bir konuşma balonu. Sık çıkmasın diye bekleme süresi var.
func _quip(prefix: String, count: int, chance: float) -> void:
	if _quip_cooldown > 0.0 or randf() > chance or _ui_root == null:
		return
	_quip_cooldown = 7.0
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.85)
	style.border_color = Color(0.7, 0.58, 0.25)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 5
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = tr("%s_%d" % [prefix, randi_range(1, count)])
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.8))
	panel.add_child(label)
	_ui_root.add_child(panel)
	var screen := get_viewport().get_canvas_transform() * (_map.player_pos + Vector2(0, -44))
	var width := panel.get_combined_minimum_size().x
	panel.position = Vector2(clampf(screen.x - width / 2.0, 12.0, 1268.0 - width), screen.y - 20.0)
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(panel, "position:y", panel.position.y - 14.0, 0.3)
	tween.tween_interval(2.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)


## Soldaki paneller (görevler, sözler), mini harita ve tohum çubuğu: altlarına oyuncu, karakter ya da çöp girerse yarı saydamlaşır.
func _fade_panels_under_things(delta: float) -> void:
	var canvas := get_viewport().get_canvas_transform()
	var tile := float(FieldMap.TILE)
	var points: Array[Vector2] = [canvas * _map.player_pos]
	for n in _map.npcs:
		if n["active"] or n["temp"]:
			var t: Vector2i = n["t"]
			points.append(canvas * (Vector2(t.x + 0.5, t.y + 0.5) * tile))
	for item in _map.trash:
		var tt: Vector2i = item["tile"]
		points.append(canvas * (Vector2(tt.x + 0.5, tt.y + 0.5) * tile))
	for panel in [_objectives_panel, _promise_panel, _minimap, _seed_bar]:
		if panel == null or not panel.visible:
			continue
		var rect: Rect2 = panel.get_global_rect().grow(14.0)
		var under := false
		for p in points:
			if rect.has_point(p):
				under = true
				break
		panel.modulate.a = move_toward(panel.modulate.a, PANEL_FADE_ALPHA if under else 1.0, delta * 5.0)


func _toast(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.06))
	label.add_theme_constant_override("outline_size", 8)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(label)
	var screen := get_viewport().get_canvas_transform() * (_map.player_pos + Vector2(0, -30))
	label.position = screen - Vector2(label.get_minimum_size().x / 2.0, 0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.55)
	tween.chain().tween_callback(label.queue_free)


func _deny(key: String) -> void:
	AudioManager.play_sfx(SFX_DENY, 0.05, -9.0)
	_camera.shake(0.6, 0.2)
	_toast(tr(key), BAD)


# ------------------------------------------------------------------ Arayüz

func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 6
	add_child(_ui)
	_ui_root = Control.new()
	_ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_ui_root)
	_ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_weather = WeatherOverlay.new()  # en altta: panellerin arkasında kalır
	_ui_root.add_child(_weather)

	_gauge = StatGauge.new()
	_gauge.setup("STAT_STAMINA", "bolt", Color(0.4, 0.72, 0.96))
	_gauge.max_value = STAMINA_MAX
	_ui_root.add_child(_gauge)
	_gauge.size = Vector2(320, 68)
	_gauge.position = Vector2(14, 720 - 68 - 14)

	_seed_bar = SeedBar.new()
	_ui_root.add_child(_seed_bar)
	_seed_bar.position = Vector2(14 + 320 + 12, 720 - 68 - 14)

	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_hint.add_theme_constant_override("outline_size", 8)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(_hint)
	_hint.custom_minimum_size = Vector2(760, 0)
	_hint.position = Vector2(260, 560)
	_hint.size = Vector2(760, 36)

	_end_button = Button.new()
	_end_button.text = "FIELD_END_DAY"
	_end_button.focus_mode = Control.FOCUS_NONE  # Boşluk tuşu düğmeyi tetiklemesin
	_end_button.add_theme_font_size_override("font_size", 24)
	UiFx.juicy(_end_button)
	_end_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(SFX_PICK)
		_end_day())
	_ui_root.add_child(_end_button)
	_end_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 14)

	_over_label = Label.new()
	_over_label.add_theme_font_size_override("font_size", 64)
	_over_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_over_label.add_theme_constant_override("outline_size", 14)
	_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_over_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_over_label.visible = false
	_ui_root.add_child(_over_label)
	_over_label.custom_minimum_size = Vector2(700, 90)
	_over_label.size = Vector2(700, 90)
	_over_label.position = Vector2(290, 300)

	_objectives_panel = ObjectivesPanel.new()
	_objectives_panel.position = Vector2(14, 90)
	_ui_root.add_child(_objectives_panel)
	_promise_panel = PromisePanel.new()
	_promise_panel.visible = false
	_ui_root.add_child(_promise_panel)

	_minimap = MiniMap.new()
	_minimap.mouse_filter = Control.MOUSE_FILTER_STOP
	_minimap.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and not _dialog.is_open:
			_open_big_map())
	_ui_root.add_child(_minimap)
	_minimap.position = Vector2(1280 - 14 - (FieldMap.COLS * MiniMap.SCALE + 16), 90)

	# Gün başı bilgi şeridi (ilk gün öğretici)
	_banner = Label.new()
	_banner.add_theme_font_size_override("font_size", 26)
	_banner.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
	_banner.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_banner.add_theme_constant_override("outline_size", 10)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.add_theme_stylebox_override("normal", _strip_style())
	_banner.size = Vector2(640, 80)
	_banner.position = Vector2(320, 310)
	_banner.visible = false
	_ui_root.add_child(_banner)

	_pointer = MarketPointer.new()
	_ui_root.add_child(_pointer)
	_guide = MarketPointer.new()
	_ui_root.add_child(_guide)
	_wp_ptr = MarketPointer.new()
	_wp_ptr.color = Color(0.85, 0.55, 1.0)
	_ui_root.add_child(_wp_ptr)
	_aux_ptr = MarketPointer.new()
	_aux_ptr.color = Color(1.0, 0.55, 0.4)
	_ui_root.add_child(_aux_ptr)
	_goal_ptr = MarketPointer.new()
	_goal_ptr.color = Color(0.45, 0.9, 1.0)
	_ui_root.add_child(_goal_ptr)

	# Bulunduğun bölge ve hedef: ekranın üstünde hep görünür
	_tut_label = Label.new()
	_tut_label.add_theme_font_size_override("font_size", 22)
	_tut_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	_tut_label.add_theme_stylebox_override("normal", _strip_style())
	_tut_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tut_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut_label.size = Vector2(620, 0)
	_tut_label.position = Vector2(350, 118)
	_tut_label.visible = false
	_ui_root.add_child(_tut_label)

	_zone_label = Label.new()
	_zone_label.add_theme_font_size_override("font_size", 20)
	_zone_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	_zone_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_zone_label.add_theme_constant_override("outline_size", 9)
	_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zone_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zone_label.size = Vector2(560, 28)
	_zone_label.position = Vector2(360, 88)
	_ui_root.add_child(_zone_label)

	_goal_label = Label.new()
	_goal_label.add_theme_font_size_override("font_size", 19)
	_goal_label.add_theme_color_override("font_color", Color(0.55, 0.92, 1.0))
	_goal_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_goal_label.add_theme_constant_override("outline_size", 8)
	_goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_goal_label.size = Vector2(560, 28)
	_goal_label.position = Vector2(360, 160)
	_ui_root.add_child(_goal_label)

	_bag_label = Label.new()
	_bag_label.add_theme_font_size_override("font_size", 20)
	_bag_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.75))
	_bag_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_bag_label.add_theme_constant_override("outline_size", 7)
	_bag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_label.position = Vector2(356, 612)
	_bag_label.visible = false
	_ui_root.add_child(_bag_label)

	_disaster_label = Label.new()
	_disaster_label.add_theme_font_size_override("font_size", 22)
	_disaster_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.4))
	_disaster_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_disaster_label.add_theme_constant_override("outline_size", 10)
	_disaster_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_disaster_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disaster_label.add_theme_stylebox_override("normal", _strip_style())
	_disaster_label.size = Vector2(620, 60)
	_disaster_label.position = Vector2(330, 196)
	_disaster_label.visible = false
	_ui_root.add_child(_disaster_label)

	_challenge_label = Label.new()
	_challenge_label.add_theme_font_size_override("font_size", 22)
	_challenge_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.4))
	_challenge_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_challenge_label.add_theme_constant_override("outline_size", 10)
	_challenge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_challenge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_challenge_label.add_theme_stylebox_override("normal", _strip_style())
	_challenge_label.size = Vector2(620, 40)
	_challenge_label.position = Vector2(330, 262)
	_challenge_label.visible = false
	_ui_root.add_child(_challenge_label)

	_shop = ShopPanel.new()
	_shop.bought.connect(_on_upgrade_bought)
	_ui_root.add_child(_shop)

	_big_map = BigMap.new()
	_big_map.map = _map
	_big_map.waypoint_changed.connect(func(t: Vector2i) -> void: waypoint = t)
	_ui_root.add_child(_big_map)

	_mini_game = MiniGame.new()
	_ui_root.add_child(_mini_game)

	_dialog = DialogPanel.new()  # en üstte
	_ui_root.add_child(_dialog)


func _show_banner(text: String, seconds: float = 6.0) -> void:
	_banner.text = text
	_banner.size = Vector2(640, 0)
	_banner.visible = true
	_banner.modulate.a = 1.0
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_interval(seconds)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.8)
	_banner_tween.tween_callback(func() -> void: _banner.visible = false)


## Pazar uzaktaysa ekran kenarında ok gösterir.
func _open_big_map() -> void:
	if not FieldProgression.has("minimap", GameState.day) or _dialog.is_open or _shop.is_open or _mini_game.is_open or _big_map.is_open:
		return
	_big_map.player_tile = _map.tile_at(_map.player_pos)
	_big_map.market_tile = _map.tile_at(_map.door_world_position()) + Vector2i(0, -2)
	_big_map.explored_percent = int(round(_map.explored_ratio() * 100.0))
	_big_map.waypoint = waypoint
	_big_map.open(_map.minimap_image())
	stat("map")
	AudioManager.play_sfx(SFX_PICK, 0.0, -6.0)


## Haritada konan işaret: uzaktaysa ok gösterir, varınca kalkar.
func _update_waypoint() -> void:
	if waypoint.x < 0:
		_wp_ptr.visible = false
		return
	var w := Vector2((waypoint.x + 0.5) * FieldMap.TILE, (waypoint.y + 0.5) * FieldMap.TILE)
	var steps := int(_map.player_pos.distance_to(w) / FieldMap.TILE)
	if steps <= 2:
		waypoint = Vector2i(-1, -1)
		_wp_ptr.visible = false
		_toast(tr("BIGMAP_REACHED"), GOLD)
		return
	_wp_ptr.visible = steps > 4
	_wp_ptr.target = get_viewport().get_canvas_transform() * (w + Vector2(0, -16))
	_wp_ptr.label = tr("BIGMAP_FLAG") % steps


func _update_pointer() -> void:
	var market := _map.door_world_position()
	var tiles_away := _map.player_pos.distance_to(market) / FieldMap.TILE
	_pointer.visible = tiles_away > POINTER_MIN_TILES and not CrisisManager.has_flag("ambargo")
	if _pointer.visible:
		_pointer.target = get_viewport().get_canvas_transform() * (market + Vector2(0, -24))
		_pointer.label = tr("FIELD_MARKET")


## Görev yönlendirmesi: açık bir kuyu/sandık görevi ya da Rıza'nın söylentisi varsa ekran kenarında ok gösterir.
# ------------------------------------------------------------------ Felaket geri çağrıları (FieldDisasters)

func deny_key(key: String) -> void:
	_deny(key)


func on_disaster_touch(what: String, pos: Vector2, seal: int = 0) -> void:
	match what:
		"flood":
			AudioManager.play_sfx(SFX_PICK, 0.05, 0.0)
			_toast(tr("DIS_FLOOD_FOLLOW"), GOOD)
		"leak":
			AudioManager.play_sfx(SFX_PICK, 0.02 * seal, -2.0)
			_camera.shake(0.8, 0.12)
			_spawn_particles(pos + Vector2(0, -8), FieldArt.puff(), 3, 0.5, 14.0, 30.0, -10.0, 120.0, 0.0)
		"heat_water":
			AudioManager.play_sfx(SFX_PLOP, 0.1, 0.0)
			_toast(tr("DIS_HEAT_FILLED"), GOOD)


func on_disaster_progress(what: String, pos: Vector2) -> void:
	_spawn_particles(pos + Vector2(0, -10), FieldArt.sparkle(), 10, 0.8, 30.0, 80.0, 0.0, 180.0, 0.0)
	AudioManager.play_sfx(SFX_BUY, 0.0, -2.0)
	_camera.shake(1.2, 0.2)
	give_money(4.0)
	if what == "heat":
		gain_nature(0.5)
	elif what == "flood":
		GameState.change_stat(&"people", 1.0)
	_toast(tr("DIS_%s_SAVED" % what.to_upper()), GOLD)
	report(what)


func on_disaster_loss(what: String, pos: Vector2) -> void:
	_spawn_particles(pos + Vector2(0, -8), FieldArt.puff(), 6, 0.8, 14.0, 36.0, -10.0, 180.0, 0.0)
	match what:
		"flood":
			GameState.change_stat(&"people", -5.0)
		"heat":
			GameState.change_stat(&"nature", -2.5)
			day_stats["burned"] += 1
		"leak":
			GameState.change_stat(&"nature", -5.0)
	AudioManager.play_sfx(SFX_ALARM, 0.0, -10.0)
	_toast(tr("DIS_%s_LOST" % what.to_upper()), BAD)


func on_leak_pulse(pos: Vector2) -> void:
	_map.pollute_one(true)
	GameState.change_stat(&"nature", -0.25)
	_spawn_particles(pos + Vector2(0, -12), FieldArt.puff(), 3, 0.9, 10.0, 26.0, -14.0, 40.0, 0.0)


func on_storm_hit(pos: Vector2) -> void:
	spend_energy(25.0)
	_camera.shake(5.0, 0.35)
	AudioManager.play_sfx(SFX_ALARM, 0.0, 0.0)
	_spawn_particles(pos + Vector2(0, -6), FieldArt.sparkle(), 12, 0.5, 40.0, 100.0, 0.0, 180.0, 0.0)
	_toast(tr("DIS_STORM_HIT"), BAD)


func on_storm_miss(pos: Vector2) -> void:
	_camera.shake(1.4, 0.15)
	AudioManager.play_sfx(SFX_PLOP, 0.2, -6.0)
	_spawn_particles(pos + Vector2(0, -6), FieldArt.sparkle(), 6, 0.4, 30.0, 70.0, 0.0, 180.0, 0.0)


## Felaket bitti: sonuç ödülü ya da cezası.
func on_disaster_end(what: String, saved: int, total: int, _lost: int, hits: int) -> void:
	if what == "flood" or what == "storm":
		_weather.mode = "none"
	if what == "storm":
		report("storm")
		if hits == 0:
			give_money(12.0)
			GameState.change_stat(&"people", 3.0)
			_show_banner(tr("DIS_STORM_PERFECT"), 4.0)
		elif hits <= 3:
			give_money(6.0)
			_show_banner(tr("DIS_STORM_OK"), 4.0)
		else:
			_show_banner(tr("DIS_STORM_BAD"), 4.0)
		return
	if saved >= total:
		give_money(8.0)
		GameState.change_stat(&"people", 2.0)
		_show_banner(tr("DIS_ALL_SAVED"), 4.0)
	elif saved > 0:
		_show_banner(tr("DIS_SOME_SAVED") % [saved, total], 4.0)
	else:
		_show_banner(tr("DIS_NONE_SAVED"), 4.0)


## Bulunduğun yer: ekranın üstünde sabit duran yazı; hedef varsa altında görünür.
func _update_zone_label() -> void:
	var text := ""
	var goal_text := ""
	if _current_zone != 0:
		text = tr("FIELD_YOU_ARE") % tr(FieldMap.ZONE_KEYS.get(_current_zone, "ZONE_PARK"))
	if guide.goal_tile.x >= 0:
		var goal_world := Vector2((guide.goal_tile.x + 0.5) * FieldMap.TILE, (guide.goal_tile.y + 0.5) * FieldMap.TILE)
		var steps := int(_map.player_pos.distance_to(goal_world) / FieldMap.TILE)
		goal_text = tr("FIELD_GOAL_LINE") % [tr(guide.goal_key), steps]
		_goal_ptr.visible = steps > 4
		if _goal_ptr.visible:
			_goal_ptr.target = get_viewport().get_canvas_transform() * (goal_world + Vector2(0, -16))
			_goal_ptr.label = tr(guide.goal_key)
	else:
		_goal_ptr.visible = false
	_zone_label.text = text
	_goal_label.text = goal_text


func goal_reached(key: String) -> void:
	_toast(tr("FIELD_GOAL_REACHED") % tr(key), GOLD)
	AudioManager.play_sfx(SFX_BUY, 0.0, -4.0)


# ------------------------------------------------------------------ Meydan okuma ve tohum kutuları

## Zamana karşı görev: süre dolmadan hedefi tamamla, ödülü al; yapamazsan küçük ceza.
func start_challenge(kind: String, target: int, seconds: float) -> void:
	challenge = {"kind": kind, "target": target, "progress": 0, "left": seconds}
	_challenge_label.visible = true
	_show_banner(tr("FIELD_RACE_START") % [target, int(seconds)], 4.0)


func _update_challenge(delta: float) -> void:
	if challenge.is_empty():
		return
	challenge["left"] = float(challenge["left"]) - delta
	var left := maxf(float(challenge["left"]), 0.0)
	_challenge_label.text = tr("FIELD_RACE_LINE") % [challenge["progress"], challenge["target"], int(ceil(left))]
	if challenge["progress"] >= challenge["target"]:
		challenge = {}
		_challenge_label.visible = false
		give_money(18.0)
		add_seeds("oak" if unlocked_species.has("oak") else "pine", 1)
		_camera.shake(2.0, 0.4)
		AudioManager.play_sfx(SFX_BUY, 0.0, 0.0)
		_toast(tr("FIELD_RACE_WON"), GOLD)
	elif left <= 0.0:
		challenge = {}
		_challenge_label.visible = false
		GameState.change_stat(&"money", -4.0)
		_toast(tr("FIELD_RACE_LOST"), BAD)


func _map_spawn_drops(count: int) -> int:
	var placed := 0
	var player_tile := _map.tile_at(_map.player_pos)
	for attempt in 600:
		if placed >= count:
			break
		var t := Vector2i(randi_range(2, FieldMap.COLS - 3), randi_range(2, FieldMap.ROWS - 3))
		var dist := Vector2(t - player_tile).length()
		if dist < 9.0 or dist > 38.0 or _map.is_locked(t) or not _map.is_free_land(t) or _map.trash_at(t):
			continue
		_map.drops.append({"pos": Vector2((t.x + 0.5) * FieldMap.TILE, (t.y + 0.9) * FieldMap.TILE)})
		placed += 1
	return placed


func _update_drops(delta: float) -> void:
	if _map.drops.is_empty():
		return
	_drop_time -= delta
	for d in _map.drops.duplicate():
		if _map.player_pos.distance_to(d["pos"]) <= 14.0:
			_map.drops.erase(d)
			_collect_drop(d["pos"])
	if _map.drops.is_empty() and _drop_total > 0:
		_drop_total = 0
		add_seeds("oak" if unlocked_species.has("oak") else "pine", 2)
		_toast(tr("FIELD_DROP_ALL"), GOLD)
	elif _drop_time <= 0.0:
		_map.drops.clear()
		_drop_total = 0
		_toast(tr("FIELD_DROP_LOST"), BAD)


func _collect_drop(pos: Vector2) -> void:
	_spawn_particles(pos + Vector2(0, -8), FieldArt.sparkle(), 10, 0.8, 30.0, 80.0, 0.0, 180.0, 0.0)
	AudioManager.play_sfx(SFX_PICK, 0.1, 2.0)
	if randf() < 0.65:
		var species: String = unlocked_species.pick_random()
		add_seeds(species, 1)
		_toast(tr("FIELD_GOT_SEED") % tr(FieldSpecies.data(species)["name"]), GOOD)
	else:
		give_money(6.0)
		_toast("+6 " + tr("STAT_MONEY"), GOOD)


func _update_guide() -> void:
	var tile := Vector2i(-1, -1)
	var label := ""
	var want_well := false
	var want_chest := false
	for it in objectives.items:
		if it["done"]:
			continue
		if it["kind"] == "well":
			want_well = true
		elif it["kind"] == "chest":
			want_chest = true
	var dt := disasters.target()
	if not dt.is_empty():
		tile = _map.tile_at(dt["pos"])
		label = tr(dt["label"])
	if tile.x < 0:
		var fv := favors.pending(_map)
		if not fv.is_empty() and Vector2(fv["t"] - _map.tile_at(_map.player_pos)).length() > 4.0:
			tile = fv["t"]
			label = tr("FAVOR_POINTER")
	if tile.x < 0 and _tree_water_day != GameState.day and not _map.special_trees.is_empty():
		for pr in story.promises:
			if pr["id"] == "pinar_tree":
				tile = _map.special_trees[0]["t"]
				label = tr("FIELD_GUIDE_PINAR_TREE")
	if tile.x < 0 and not _map.drops.is_empty():
		var bestd := 1e9
		for d in _map.drops:
			var dd: float = _map.player_pos.distance_to(d["pos"])
			if dd < bestd:
				bestd = dd
				tile = _map.tile_at(d["pos"])
		label = tr("FIELD_GUIDE_DROP")
	if tile.x < 0 and _rumor_chest.x >= 0:
		for p in _map.pois:
			if p["t"] == _rumor_chest and p["used"]:
				_rumor_chest = Vector2i(-1, -1)
		if _rumor_chest.x >= 0:
			tile = _rumor_chest
			label = tr("FIELD_GUIDE_CHEST")
	if tile.x < 0 and (want_well or want_chest):
		var kind := "well" if want_well else "chest"
		var best := 1e9
		for p in _map.pois:
			if p["kind"] != kind or not p["active"] or p["used"] and kind == "chest":
				continue
			var d := _map.player_pos.distance_to(Vector2((p["t"].x + 0.5) * FieldMap.TILE, (p["t"].y + 0.5) * FieldMap.TILE))
			if d < best:
				best = d
				tile = p["t"]
		label = tr("FIELD_GUIDE_WELL" if kind == "well" else "FIELD_GUIDE_CHEST")
	var world := Vector2((tile.x + 0.5) * FieldMap.TILE, (tile.y + 0.5) * FieldMap.TILE)
	var second := disasters.second_target()
	_aux_ptr.visible = not second.is_empty()
	if _aux_ptr.visible:
		_aux_ptr.target = get_viewport().get_canvas_transform() * ((second["pos"] as Vector2) + Vector2(0, -16))
		_aux_ptr.label = tr(second["label"])
	_guide.visible = tile.x >= 0 and _map.player_pos.distance_to(world) / FieldMap.TILE > 3.0
	if _guide.visible:
		_guide.target = get_viewport().get_canvas_transform() * (world + Vector2(0, -16))
		_guide.label = label


func _update_hint() -> void:
	var tile := _map.tile_at(_map.player_pos)
	var text := ""
	var strong := true
	var poi := _map.poi_near(_map.player_pos, INTERACT_DISTANCE, GameState.day)
	var npc := _map.npc_near(_map.player_pos, NPC_DISTANCE)
	var species_name := tr(FieldSpecies.data(selected_species)["name"])
	if _map.in_market_zone(tile):
		text = tr("FIELD_EMBARGO") if CrisisManager.has_flag("ambargo") else \
			tr("FIELD_HINT_BUY_SHOP" if FieldProgression.has("shop", GameState.day) else "FIELD_HINT_BUY") % [species_name, int(FieldSpecies.data(selected_species)["price"]), int(TEA_PRICE)]
	elif not _threats.fire_near(_map.player_pos).is_empty():
		text = tr("FIELD_HINT_FIRE")
	elif _threats.logger_near(_map.player_pos):
		text = tr("FIELD_HINT_LOGGER")
	elif _threats.rabbit_near(_map.player_pos):
		text = tr("FIELD_HINT_RABBIT")
	elif disasters.hint_key() != "":
		text = tr(disasters.hint_key())
	elif _mini_hint() != "":
		text = tr(_mini_hint())
	elif home.near_door():
		text = tr("FIELD_HINT_HOME")
	elif _map.filter_enabled and not _map.filter_building_near(_map.player_pos, FILTER_DIST).is_empty():
		text = tr("FIELD_HINT_FILTER") % [int(filter_price()), int(FILTER_ENERGY)]
	elif not npc.is_empty():
		text = tr("FIELD_PEDDLER_HINT") % int(PEDDLER_PRICE) if npc["id"] == "peddler" else tr("FIELD_TALK_HINT")
	elif not poi.is_empty():
		text = tr("FIELD_HINT_CHEST") if poi["kind"] == "chest" else tr("FIELD_HINT_WELL")
	elif total_seeds() > 0 and _map.can_plant(tile):
		text = tr("FIELD_HINT_PLANT_SPECIES") % [species_name, int(FieldSpecies.data(selected_species)["energy"])]
	elif total_seeds() <= 0:
		text = tr("FIELD_HINT_NEED_SEEDS")
	else:
		text = tr("FIELD_CONTROLS")
		strong = false
	if _map.in_market_zone(tile) and FieldProgression.has("recycle", GameState.day) and _bag >= RECYCLE_BATCH:
		text += "\n" + tr("FIELD_HINT_RECYCLE") % [_bag / RECYCLE_BATCH]
	_hint.text = text
	_hint.modulate.a = 1.0 if strong else 0.6
