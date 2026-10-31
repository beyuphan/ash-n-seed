class_name FieldHome
extends RefCounted
## Başkanın evi. Halk (people) düşükse vatandaşlar evin önüne toplanır, pankart sallar, taş ve domates atar, cam kırar.
## Halk toparlanırsa komşular camı bedavaya takar. Çok sevilirsen kapıya hediye bırakılır.
## Kırık camlar ertesi sabah enerjiyi düşürür (soğuk): tamir için Kasa gider.

const ANGRY_BELOW := 35.0      ## altında kalabalık toplanır
const HAPPY_ABOVE := 75.0      ## üstünde ev bayram yeri olur
const CLEAN_ABOVE := 45.0      ## üstünde komşular lekeleri siler
const FREE_FIX_ABOVE := 58.0   ## üstünde komşular camı bedava takar
const FIX_PRICE := 4.0         ## cam başına tamir
const COLD_ENERGY := 6.0       ## kırık cam başına sabah enerji kaybı
const DOOR_DIST := 30.0

const SFX_GLASS := preload("res://assets/audio/sfx/glass_break.wav")
const SFX_SPLAT := preload("res://assets/audio/sfx/splat.wav")
const SFX_THROW := preload("res://assets/audio/sfx/throw_whistle.wav")
const SFX_FIX := preload("res://assets/audio/sfx/confirmation_001.wav")

var world  # FieldWorld
var _limit := 0                 # bugün kırılabilecek toplam cam sayısı sınırı
var _planned := 0               # şimdiye kadar kırılan + yoldaki cam atışları
var _targeted: Array[int] = []  # havada olan atışların hedef pencereleri
var _first := true
var _gift_day := -1
var _connected := false
var _shard: Texture2D


func _init(w) -> void:
	world = w


func _connect() -> void:
	if _connected:
		return
	_connected = true
	(world._map as FieldMap).shot_landed.connect(_on_landed)


## Gün başında: ruh hâlini belirler, kalabalığı kurar. Banner'a eklenecek satırı döndürür.
func begin_day(day: int) -> String:
	var map: FieldMap = world._map
	map.mob.clear()
	map.shots.clear()
	_targeted.clear()
	if map.home.is_empty() or not FieldProgression.has("home", day):
		return ""
	_connect()
	var people := GameState.people
	var lines: Array[String] = []
	if map.broken_windows() > 0 and people >= FREE_FIX_ABOVE:
		map.repair_home()
		lines.append(world.tr("HOME_NEIGHBORS_FIXED"))
	elif people >= CLEAN_ABOVE:
		(map.home["splats"] as Array).clear()
	var mood := -1 if people < ANGRY_BELOW else (1 if people >= HAPPY_ABOVE else 0)
	map.home["mood"] = mood
	_planned = map.broken_windows()
	_limit = _planned
	_first = true
	if mood < 0:
		var count := 3 + (1 if people < 25.0 else 0) + (1 if people < 15.0 else 0)
		map.spawn_mob(count)
		_limit = _planned + (1 if people >= 25.0 else (2 if people >= 15.0 else 3))
		if not map.mob.is_empty():
			map.mob[0]["throw_t"] = randf_range(3.0, 5.0)
			lines.append(world.tr("HOME_MOB_ARRIVED"))
	var broken := map.broken_windows()
	if broken > 0:
		var cold := COLD_ENERGY * broken
		world.stamina = maxf(world.stamina - cold, 20.0)
		lines.append(world.tr("HOME_COLD") % int(cold))
	return "\n".join(lines)


func update(delta: float) -> void:
	var map: FieldMap = world._map
	for m in map.mob:
		m["throw_t"] = float(m["throw_t"]) - delta
		if float(m["throw_t"]) <= 0.0:
			m["throw_t"] = randf_range(5.0, 10.0)
			_throw(m)


func _throw(m: Dictionary) -> void:
	var map: FieldMap = world._map
	var windows: Array = map.home["windows"]
	var intact: Array[int] = []
	for i in windows.size():
		if not windows[i] and not _targeted.has(i):
			intact.append(i)
	var aim := not intact.is_empty() and _planned < _limit and (_first or randf() < 0.55)
	_first = false
	var shot := {"from": (m["pos"] as Vector2) + Vector2(0, -14), "t": 0.0, "dur": 0.8, "window": -1, "kind": 1}
	if aim:
		var idx: int = intact.pick_random()
		_planned += 1
		_targeted.append(idx)
		shot["window"] = idx
		shot["kind"] = 0
		shot["to"] = map.home_window_world(idx)
	else:
		var r: Rect2i = map.home["rect"]
		shot["to"] = Vector2(randf_range(r.position.x + 0.6, r.end.x - 0.6) * FieldMap.TILE, randf_range(r.position.y + 1.0, r.end.y - 0.2) * FieldMap.TILE)
	map.shots.append(shot)
	AudioManager.play_sfx(SFX_THROW, 0.12, -8.0)


func _on_landed(s: Dictionary) -> void:
	var map: FieldMap = world._map
	if map.home.is_empty():
		return
	var idx := int(s["window"])
	var to: Vector2 = s["to"]
	if idx >= 0:
		_targeted.erase(idx)
		if not map.home["windows"][idx]:
			map.home["windows"][idx] = true
			world.stat("windows")
			AudioManager.play_sfx(SFX_GLASS, 0.05, -2.0)
			_burst(to)
			if map.player_pos.distance_to(to) < 260.0:
				world._camera.shake(2.5, 0.3)
			world._toast(world.tr("HOME_WINDOW_BROKE"), Color(1.0, 0.55, 0.45))
		return
	AudioManager.play_sfx(SFX_SPLAT, 0.1, -6.0)
	var r: Rect2i = map.home["rect"]
	var local := to - Vector2(r.position * FieldMap.TILE)
	var colors := [Color(0.85, 0.16, 0.12), Color(0.98, 0.88, 0.45), Color(0.45, 0.32, 0.2)]
	var splats: Array = map.home["splats"]
	splats.append({"p": local, "c": colors.pick_random()})
	if splats.size() > 12:
		splats.pop_front()


func _burst(pos: Vector2) -> void:
	if _shard == null:
		var img := Image.create_empty(3, 3, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.72, 0.93, 1.0))
		_shard = ImageTexture.create_from_image(img)
	world._spawn_particles(pos, _shard, 16, 0.9, 40.0, 110.0, 320.0, 170.0, 4.0)


func near_door() -> bool:
	var map: FieldMap = world._map
	if map.home.is_empty() or not FieldProgression.has("home", GameState.day):
		return false
	return map.player_pos.distance_to(map.home_door_world()) <= DOOR_DIST


## Kapıdayken Boşluk: kırık cam varsa tamir teklifi, yoksa Tomurcuk'tan bir laf (ya da komşu hediyesi).
func interact() -> bool:
	if not near_door():
		return false
	var map: FieldMap = world._map
	var portrait: Texture2D = world.portrait_for("assistant")
	var broken := map.broken_windows()
	var mood := int(map.home["mood"])
	if broken > 0:
		var cost := FIX_PRICE * broken
		var key := "HOME_BROKEN_MOB" if not map.mob.is_empty() else "HOME_BROKEN"
		world.say_text(portrait, "CHAR_ASSIST_NAME", world.tr(key) % [broken, int(cost)], ["HOME_FIX", "HOME_LEAVE"])
		world._dialog.chosen.connect(func(c: int) -> void:
			if c != 0:
				return
			if GameState.money <= cost:
				world._deny("FIELD_NO_MONEY")
				return
			GameState.change_stat(&"money", -cost)
			map.repair_home()
			_planned = 0
			AudioManager.play_sfx(SFX_FIX, 0.0, -4.0)
			world._toast(world.tr("HOME_FIXED"), Color(0.65, 0.92, 0.5)), CONNECT_ONE_SHOT)
		return true
	if mood > 0 and _gift_day != GameState.day:
		_gift_day = GameState.day
		world.add_seeds("pine", 1)
		world.give_money(3.0)
		world.say(portrait, "CHAR_ASSIST_NAME", "HOME_GIFT", ["STORY_OK"], Callable())
		return true
	var fine := "HOME_FINE_ANGRY" if mood < 0 else ("HOME_FINE_HAPPY" if mood > 0 else "HOME_FINE")
	world.say(portrait, "CHAR_ASSIST_NAME", fine, ["STORY_OK"], Callable())
	return true
