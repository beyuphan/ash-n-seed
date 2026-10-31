class_name MiniGame
extends Control
## Tam ekran küçük oyunlar. Yardım isteyen vatandaşlar için: ekran değişir, kurallar değişir, sadece eğlence.
##  lock:    Çilingir yok. Gösterge yeşil bölgedeyken Boşluğa bas, pimleri aç.   Mekanik: zamanlama
##  balance: Merdiveni dik tut. A / D (ya da ok tuşları) ile dengeyi koru.       Mekanik: denge
##  rhythm:  Davul çal. Gelen oku zamanında bas.                                 Mekanik: ritim
##  pump:    Lastik şişir. Boşluğa hızlı hızlı bas, hava kaçıyor.                Mekanik: seri basma
##  catch:   Düşen portakalları sepetle yakala, çürüklerden kaç.                 Mekanik: refleks, A / D
##  sort:    Çöpü doğru kutuya at (kağıt / cam / plastik).                       Mekanik: hızlı karar, ← ↓ →
##  whack:   Köstebekleri vur, kirpiye dokunma.                                  Mekanik: nişan, fare ya da QWE/ASD/ZXC
##  memory:  Çalınan sırayı aynen tekrarla.                                      Mekanik: hafıza, 1-4 / ASDF / fare
##  stack:   Hareket eden kasayı bırak, kule dik dursun.                         Mekanik: zamanlama, Boşluk
## Sonuç `finished(success)` sinyaliyle gelir. Esc: vazgeç.

signal finished(success: bool)

const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.2, 0.15, 0.11, 0.97)
const CREAM := Color(0.97, 0.93, 0.83)
const GOLD := Color(1.0, 0.82, 0.3)
const GREEN := Color(0.5, 0.85, 0.4)
const RED := Color(0.95, 0.42, 0.35)
const BOX := Rect2(310, 170, 660, 380)
const BAR := Rect2(380, 420, 520, 34)
## Yeni oyunların sahne alanı (BOX içinde, başlık ve ipucunun altında)
const AREA := Rect2(340, 285, 600, 232)
const KINDS := ["lock", "balance", "rhythm", "pump", "catch", "sort", "whack", "memory", "stack"]

const SFX_HIT := preload("res://assets/audio/sfx/click_003.wav")
const SFX_BAD := preload("res://assets/audio/sfx/error_001.wav")
const SFX_WIN := preload("res://assets/audio/sfx/confirmation_001.wav")
const SFX_LOSE := preload("res://assets/audio/sfx/bong_001.wav")
const SFX_DROP := preload("res://assets/audio/sfx/drop_001.wav")

const PAD_COLORS := [Color(0.88, 0.3, 0.27), Color(0.3, 0.55, 0.9), Color(0.95, 0.78, 0.25), Color(0.4, 0.78, 0.4)]
const PAD_FREQS := [262.0, 330.0, 392.0, 523.0]
const BIN_COLORS := [Color(0.3, 0.52, 0.88), Color(0.34, 0.7, 0.42), Color(0.95, 0.8, 0.25)]
const BIN_KEYS := ["MG_BIN_PAPER", "MG_BIN_GLASS", "MG_BIN_PLASTIC"]
const WHACK_KEYS := {KEY_Q: 0, KEY_W: 1, KEY_E: 2, KEY_A: 3, KEY_S: 4, KEY_D: 5, KEY_Z: 6, KEY_X: 7, KEY_C: 8}
const CATCH_SPEED := 560.0
const BLOCK_H := 22.0

static var _tone_cache: Array[AudioStreamWAV] = []

var is_open := false
var kind := ""
var level := 1
var _steps := 6
var title_key := ""
var _t := 0.0
var _result := ""
var _result_t := 0.0
var _flash := 0.0
var _held := {}
# lock
var _cur := 0.0
var _dir := 1.0
var _pins := 0
var _tries := 3
var _zone := 0.5
# balance / pump
var _pos := 0.0
var _vel := 0.0
var _prog := 0.0
var _limit := 0.0
# rhythm / sort
var _seq: Array[int] = []
var _variants: Array[int] = []
var _idx := 0
var _left := 0.0
var _misses := 0
var _item_time := 1.8
# catch / whack / stack ortak sayaçlar
var _score := 0
var _goal := 0
var _spawn_t := 0.0
# catch
var _bx := 300.0
var _bvel := 0.0
var _last_x := 300.0
var _items: Array[Dictionary] = []
# whack
var _holes: Array[Dictionary] = []
# memory
var _mem_seq: Array[int] = []
var _mem_len := 2
var _mem_i := 0
var _mem_in := 0
var _mem_t := 0.0
var _mem_phase := "show"
var _lit := -1
var _lit_t := 0.0
# stack
var _blocks: Array[Vector2] = []
var _sx := 0.0
var _sw := 0.0
var _sdir := 1.0
var _perfect := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func start(what: String, title: String, lvl: int = 1) -> void:
	kind = what
	level = clampi(lvl, 1, 6)
	title_key = title
	_t = 0.0
	_result = ""
	_flash = 0.0
	_prog = 0.0
	_held.clear()
	match kind:
		"lock":
			_cur = 0.0
			_dir = 1.0
			_pins = 0
			_tries = 3
			_zone = randf_range(0.2, 0.8)
		"balance":
			_pos = 0.0
			_vel = 0.0
			_limit = 20.0
			_prog = 0.25
		"rhythm":
			_seq.clear()
			_steps = 5 + level
			for i in _steps:
				_seq.append(randi() % 4)
			_idx = 0
			_misses = 0
			_left = 2.2 - 0.1 * level
			_item_time = 1.8
		"pump":
			_limit = 9.0
			_prog = 0.15
		"catch":
			_goal = 6 + level
			_score = 0
			_misses = 0
			_bx = AREA.size.x * 0.5
			_bvel = 0.0
			_last_x = _bx
			_spawn_t = 0.5
			_items.clear()
		"sort":
			_seq.clear()
			_variants.clear()
			_steps = 8 + level
			for i in _steps:
				_seq.append(randi() % 3)
				_variants.append(randi() % 2)
			_idx = 0
			_misses = 0
			_item_time = _sort_time(0)
			_left = _item_time + 0.6
		"whack":
			_goal = 9 + level * 2
			_score = 0
			_limit = 16.0
			_spawn_t = 0.5
			_misses = 0
			_holes.clear()
			for i in 9:
				_holes.append({"state": 0, "t": 0.0, "pop": 0.0})
		"memory":
			_mem_seq.clear()
			_steps = 4 + (level + 1) / 2   # son uzunluk
			for i in _steps:
				_mem_seq.append(randi() % 4)
			_mem_len = 2
			_tries = 2
			_begin_show(0.9)
			_lit = -1
			_lit_t = 0.0
		"stack":
			_goal = 5 + (level + 1) / 2
			_blocks.clear()
			_blocks.append(Vector2((AREA.size.x - 170.0) * 0.5, 170.0))
			_sw = 170.0
			_sx = 0.0
			_sdir = 1.0
			_perfect = 0
	is_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _close(success: bool) -> void:
	is_open = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit(success)


func _end(success: bool) -> void:
	if _result != "":
		return
	_result = "win" if success else "lose"
	_result_t = 1.1
	AudioManager.play_sfx(SFX_WIN if success else SFX_LOSE, 0.0, -2.0)


func _good() -> void:
	AudioManager.play_sfx(SFX_HIT, 0.08, -4.0)


func _bad() -> void:
	AudioManager.play_sfx(SFX_BAD, 0.05, -6.0)
	_flash = 1.0


func _zone_half() -> float:
	return [0.11, 0.09, 0.075, 0.065][clampi(_pins, 0, 3)] * (1.15 - 0.05 * level)


## A / D ya da ok tuşları: -1, 0, 1
func _axis() -> float:
	var left: bool = Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT) or _held.get(KEY_A, false) or _held.get(KEY_LEFT, false)
	var right: bool = Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT) or _held.get(KEY_D, false) or _held.get(KEY_RIGHT, false)
	return (1.0 if right else 0.0) - (1.0 if left else 0.0)


func _process(delta: float) -> void:
	if not is_open:
		return
	_t += delta
	_flash = maxf(_flash - delta * 3.0, 0.0)
	if _result != "":
		_result_t -= delta
		if _result_t <= 0.0:
			_close(_result == "win")
		queue_redraw()
		return
	match kind:
		"lock":
			_cur += _dir * (0.7 + 0.2 * _pins) * (1.0 + 0.06 * level) * delta
			if _cur >= 1.0:
				_cur = 1.0
				_dir = -1.0
			elif _cur <= 0.0:
				_cur = 0.0
				_dir = 1.0
		"balance":
			var noise := sin(_t * 1.7) * 0.9 + sin(_t * 3.1 + 1.0) * 0.7 + sin(_t * 0.6 + 2.0) * 0.6
			var push := _axis()
			_vel += (noise * (1.2 + _t * 0.04) * (0.8 + 0.12 * level) + push * 4.2) * delta
			_vel *= maxf(1.0 - 1.6 * delta, 0.0)
			_pos += _vel * delta
			if absf(_pos) >= 1.0:
				_pos = clampf(_pos, -1.0, 1.0)
				_vel = -_vel * 0.4
				_prog -= 0.12
				_bad()
			_prog += (0.17 if absf(_pos) <= 0.3 else -0.1) * delta
			_limit -= delta
			if _prog >= 1.0:
				_end(true)
			elif _limit <= 0.0 or _prog <= 0.0:
				_end(false)
		"rhythm":
			_left -= delta
			if _left <= 0.0:
				_rhythm_step(false)
		"pump":
			_prog -= (0.16 + 0.015 * level) * delta
			_limit -= delta
			if _prog >= 1.0:
				_end(true)
			elif _limit <= 0.0 or _prog <= 0.0:
				_end(false)
		"catch":
			_process_catch(delta)
		"sort":
			_left -= delta
			if _left <= 0.0:
				_sort_step(-1)
		"whack":
			_process_whack(delta)
		"memory":
			_process_memory(delta)
		"stack":
			_process_stack(delta)
	queue_redraw()


# ------------------------------------------------------------------ Portakal yakala

func _process_catch(delta: float) -> void:
	_bvel = lerpf(_bvel, _axis() * CATCH_SPEED, minf(delta * 14.0, 1.0))
	_bx = clampf(_bx + _bvel * delta, 48.0, AREA.size.x - 48.0)
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn_t = maxf(0.92 - 0.06 * level, 0.5)
		_last_x = clampf(_last_x + randf_range(-230.0, 230.0), 26.0, AREA.size.x - 26.0)
		_items.append({"x": _last_x, "y": -10.0, "bad": level >= 2 and randf() < 0.22})
	var fall := 150.0 + 20.0 * level
	var basket_y := AREA.size.y - 46.0
	for i in range(_items.size() - 1, -1, -1):
		var it: Dictionary = _items[i]
		it["y"] = float(it["y"]) + fall * delta
		var y: float = it["y"]
		var caught: bool = y >= basket_y and y <= basket_y + 22.0 and absf(float(it["x"]) - _bx) <= 56.0
		if caught:
			_items.remove_at(i)
			if it["bad"]:
				_misses += 1
				_bad()
			else:
				_score += 1
				_good()
		elif y >= AREA.size.y - 14.0:
			_items.remove_at(i)
			if not it["bad"]:
				_misses += 1
				_bad()
	if _score >= _goal:
		_end(true)
	elif _misses >= 3:
		_end(false)


# ------------------------------------------------------------------ Çöp ayır

func _sort_time(i: int) -> float:
	return maxf(2.3 - 0.1 * i - 0.1 * level, 1.05)


func _sort_step(choice: int) -> void:
	if choice == _seq[_idx]:
		_good()
	else:
		_misses += 1
		_bad()
	_idx += 1
	if _misses >= 3:
		_end(false)
	elif _idx >= _steps:
		_end(true)
	else:
		_item_time = _sort_time(_idx)
		_left = _item_time


# ------------------------------------------------------------------ Köstebek vur

func _process_whack(delta: float) -> void:
	_limit -= delta
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn_t = maxf(0.62 - 0.04 * level, 0.36)
		var free: Array[int] = []
		for i in 9:
			if int(_holes[i]["state"]) == 0:
				free.append(i)
		if not free.is_empty():
			var h: Dictionary = _holes[free.pick_random()]
			h["state"] = 2 if randf() < 0.2 else 1   # 1: köstebek, 2: kirpi
			h["t"] = maxf(1.25 - 0.08 * level, 0.7)
			h["pop"] = 0.0
	for h in _holes:
		var s := int(h["state"])
		if s == 0:
			continue
		h["pop"] = minf(float(h["pop"]) + delta * 9.0, 1.0)
		h["t"] = float(h["t"]) - delta
		if float(h["t"]) <= 0.0:
			h["state"] = 0
	if _score >= _goal:
		_end(true)
	elif _limit <= 0.0:
		_end(false)


func _hole_center(i: int) -> Vector2:
	return AREA.position + Vector2(100.0 + (i % 3) * 200.0, 76.0 + (i / 3) * 60.0)


func _whack(i: int) -> void:
	var h: Dictionary = _holes[i]
	match int(h["state"]):
		1:
			_score += 1
			_good()
			h["state"] = 3
			h["t"] = 0.25
		2:
			_score = maxi(_score - 1, 0)
			_bad()
			h["state"] = 3
			h["t"] = 0.25


# ------------------------------------------------------------------ Sırayı hatırla

func _begin_show(delay: float) -> void:
	_mem_phase = "show"
	_mem_i = 0
	_mem_in = 0
	_mem_t = delay


func _process_memory(delta: float) -> void:
	_lit_t = maxf(_lit_t - delta, 0.0)
	if _lit_t <= 0.0:
		_lit = -1
	if _mem_phase != "show":
		return
	_mem_t -= delta
	if _mem_t > 0.0:
		return
	if _mem_i < _mem_len:
		var on := maxf(0.55 - 0.03 * level, 0.35)
		_light(_mem_seq[_mem_i], on)
		_mem_i += 1
		_mem_t = on + 0.2
	else:
		_mem_phase = "input"
		_mem_in = 0


func _light(pad: int, secs: float) -> void:
	_lit = pad
	_lit_t = secs
	AudioManager.play_sfx(_tone(pad), 0.0, -6.0)


func _mem_press(pad: int) -> void:
	if _mem_phase != "input":
		return
	_light(pad, 0.25)
	if pad == _mem_seq[_mem_in]:
		_mem_in += 1
		if _mem_in >= _mem_len:
			if _mem_len >= _steps:
				_end(true)
			else:
				_mem_len += 1
				_begin_show(0.9)
	else:
		_tries -= 1
		_flash = 1.0
		AudioManager.play_sfx(SFX_BAD, 0.05, -6.0)
		if _tries <= 0:
			_end(false)
		else:
			_begin_show(1.1)


static func _tone(pad: int) -> AudioStreamWAV:
	if _tone_cache.is_empty():
		for f in PAD_FREQS:
			var rate := 22050
			var n := int(rate * 0.3)
			var data := PackedByteArray()
			data.resize(n * 2)
			for i in n:
				var t := float(i) / rate
				var env := minf(t * 80.0, 1.0) * exp(-t * 6.0)
				var s := sin(TAU * f * t) * 0.6 + sin(TAU * f * 2.0 * t) * 0.25
				data.encode_s16(i * 2, int(s * env * 15000.0))
			var w := AudioStreamWAV.new()
			w.format = AudioStreamWAV.FORMAT_16_BITS
			w.mix_rate = rate
			w.data = data
			_tone_cache.append(w)
	return _tone_cache[pad]


# ------------------------------------------------------------------ Kule

func _process_stack(delta: float) -> void:
	var speed := minf(200.0 + 38.0 * level + 12.0 * (_blocks.size() - 1), 480.0)
	_sx += _sdir * speed * delta
	var hi := AREA.size.x - _sw
	if _sx >= hi:
		_sx = hi
		_sdir = -1.0
	elif _sx <= 0.0:
		_sx = 0.0
		_sdir = 1.0


func _drop_block() -> void:
	var top: Vector2 = _blocks.back()
	var lo := maxf(_sx, top.x)
	var hi := minf(_sx + _sw, top.x + top.y)
	var overlap := hi - lo
	if overlap <= 4.0:
		_bad()
		_end(false)
		return
	if absf(_sx - top.x) <= 5.0:
		_perfect += 1
		_blocks.append(Vector2(top.x, top.y))
		_flash = 0.6
	else:
		_blocks.append(Vector2(lo, overlap))
	AudioManager.play_sfx(SFX_DROP, 0.08, -4.0)
	_sw = _blocks.back().y
	_sx = 0.0 if _sdir < 0.0 else AREA.size.x - _sw
	_sdir = -_sdir
	if _blocks.size() - 1 >= _goal:
		_end(true)


# ------------------------------------------------------------------ Ritim, girdiler

func _rhythm_step(ok: bool) -> void:
	if not ok:
		_misses += 1
		_bad()
	else:
		_good()
	_idx += 1
	_left = maxf(1.8 - 0.08 * _idx - 0.1 * level, 0.8)
	_item_time = _left
	if _misses >= 3:
		_end(false)
	elif _idx >= _steps:
		_end(true)


func _on_click(p: Vector2) -> void:
	match kind:
		"whack":
			for i in 9:
				if Rect2(_hole_center(i) - Vector2(84, 46), Vector2(168, 66)).has_point(p):
					_whack(i)
					return
		"memory":
			for i in 4:
				if _pad_rect(i).has_point(p):
					_mem_press(i)
					return


func _pad_rect(i: int) -> Rect2:
	return Rect2(AREA.position.x + 30.0 + i * 140.0, AREA.position.y + 46.0, 120.0, 120.0)


func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _result == "":
			_on_click(make_input_local(event).position)
		return
	if not (event is InputEventKey):
		return
	get_viewport().set_input_as_handled()
	var key: Key = event.physical_keycode
	_held[key] = event.pressed
	if not event.pressed or event.echo or _result != "":
		return
	if key == KEY_ESCAPE:
		_end(false)
		return
	match kind:
		"lock":
			if key == KEY_SPACE or key == KEY_ENTER:
				if absf(_cur - _zone) <= _zone_half():
					_pins += 1
					_flash = 1.0
					_good()
					if _pins >= (4 if level >= 4 else 3):
						_end(true)
					else:
						_zone = randf_range(0.15, 0.85)
				else:
					_tries -= 1
					_bad()
					if _tries <= 0:
						_end(false)
		"rhythm":
			var d := -1
			match key:
				KEY_LEFT, KEY_A:
					d = 0
				KEY_RIGHT, KEY_D:
					d = 1
				KEY_UP, KEY_W:
					d = 2
				KEY_DOWN, KEY_S:
					d = 3
			if d >= 0:
				_rhythm_step(d == _seq[_idx])
		"pump":
			if key == KEY_SPACE or key == KEY_ENTER:
				_prog += 0.075
				_flash = 1.0
		"sort":
			match key:
				KEY_LEFT, KEY_A:
					_sort_step(0)
				KEY_DOWN, KEY_S:
					_sort_step(1)
				KEY_RIGHT, KEY_D:
					_sort_step(2)
		"whack":
			if WHACK_KEYS.has(key):
				_whack(int(WHACK_KEYS[key]))
		"memory":
			match key:
				KEY_1, KEY_A:
					_mem_press(0)
				KEY_2, KEY_S:
					_mem_press(1)
				KEY_3, KEY_D:
					_mem_press(2)
				KEY_4, KEY_F:
					_mem_press(3)
		"stack":
			if key == KEY_SPACE or key == KEY_ENTER:
				_drop_block()


# ------------------------------------------------------------------ Çizim

func _draw() -> void:
	if not is_open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
	var n := 6.0
	draw_rect(BOX.grow(n), FRAME)
	draw_rect(BOX, PANEL)
	var font := get_theme_font("font", "Label")
	draw_string(font, Vector2(BOX.position.x, BOX.position.y + 46), tr(title_key), HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 30, GOLD)
	var hint := tr("MG_HINT_" + kind.to_upper())
	draw_string(font, Vector2(BOX.position.x, BOX.position.y + 82), hint, HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 20 if hint.length() <= 54 else 16, CREAM)
	match kind:
		"lock":
			_draw_lock(font)
		"balance":
			_draw_balance(font)
		"rhythm":
			_draw_rhythm(font)
		"pump":
			_draw_pump(font)
		"catch":
			_draw_catch(font)
		"sort":
			_draw_sort(font)
		"whack":
			_draw_whack(font)
		"memory":
			_draw_memory(font)
		"stack":
			_draw_stack(font)
	if _result != "":
		var win := _result == "win"
		draw_rect(Rect2(BOX.position.x, BOX.position.y + 160, BOX.size.x, 70), Color(0.05, 0.04, 0.03, 0.88))
		draw_string(font, Vector2(BOX.position.x, BOX.position.y + 210), tr("MG_WIN" if win else "MG_LOSE"), HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 40, GREEN if win else RED)
	else:
		draw_string(font, Vector2(BOX.position.x, BOX.end.y - 16), tr("MG_ESC"), HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 16, Color(1, 1, 1, 0.45))


func _bar(rect: Rect2, frac: float, color: Color) -> void:
	draw_rect(rect.grow(3), FRAME)
	draw_rect(rect, Color(0.12, 0.09, 0.07))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(frac, 0.0, 1.0), rect.size.y)), color)


## Yeni oyunların ortak sahne zemini + sol üst sayaç + sağ üst süre
func _stage(font: Font, left_text: String, left_color: Color = CREAM, right_text: String = "") -> void:
	draw_rect(AREA.grow(4), FRAME)
	draw_rect(AREA, Color(0.13, 0.1, 0.08))
	draw_string(font, AREA.position + Vector2(12, 24), left_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, left_color)
	if right_text != "":
		draw_string(font, AREA.position + Vector2(-12, 24), right_text, HORIZONTAL_ALIGNMENT_RIGHT, AREA.size.x, 20, CREAM)


func _draw_lock(font: Font) -> void:
	# Kilit gövdesi
	var c := Vector2(BOX.get_center().x, BOX.position.y + 150)
	draw_rect(Rect2(c.x - 34, c.y - 14, 68, 52), Color(0.72, 0.58, 0.2))
	draw_rect(Rect2(c.x - 34, c.y - 14, 68, 52), FRAME, false, 3.0)
	draw_arc(c + Vector2(0, -14), 22.0, PI, TAU, 16, Color(0.75, 0.75, 0.78), 6.0)
	draw_circle(c + Vector2(0, 10), 6.0, FRAME)
	# Pimler
	for i in (4 if level >= 4 else 3):
		draw_circle(Vector2(c.x + 70.0 + i * 28.0, c.y + 10.0), 9.0, GREEN if i < _pins else Color(0.3, 0.25, 0.2))
	draw_rect(BAR.grow(3), FRAME)
	draw_rect(BAR, Color(0.12, 0.09, 0.07))
	var hw := _zone_half()
	draw_rect(Rect2(BAR.position.x + BAR.size.x * (_zone - hw), BAR.position.y, BAR.size.x * hw * 2.0, BAR.size.y), Color(0.3, 0.7, 0.3))
	var cx := BAR.position.x + BAR.size.x * _cur
	draw_rect(Rect2(cx - 4, BAR.position.y - 8, 8, BAR.size.y + 16), CREAM)
	draw_string(font, Vector2(BOX.position.x, BAR.end.y + 44), tr("MG_TRIES") % _tries, HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 22, RED if _tries < 2 else CREAM)


func _draw_balance(font: Font) -> void:
	var base := Vector2(BOX.get_center().x, BOX.end.y - 70)
	# Zemin ve denge alanı
	draw_rect(Rect2(base.x - 250, base.y + 18, 500, 8), Color(0.35, 0.28, 0.2))
	draw_rect(Rect2(base.x - 250 * 0.3, base.y + 18, 500 * 0.3, 8), Color(0.3, 0.7, 0.3))
	# Merdiven: pozisyona göre eğilir
	var tilt := _pos * 0.5
	var top := base + Vector2(sin(tilt), -cos(tilt)) * 150.0
	draw_line(base + Vector2(-12, 0), top + Vector2(-12, 0), Color(0.75, 0.55, 0.3), 6.0)
	draw_line(base + Vector2(12, 0), top + Vector2(12, 0), Color(0.75, 0.55, 0.3), 6.0)
	for k in 6:
		var f := float(k) / 5.0
		var p := base.lerp(top, f)
		draw_line(p + Vector2(-12, 0), p + Vector2(12, 0), Color(0.6, 0.42, 0.22), 4.0)
	# Tepedeki kedi
	var cat := top + Vector2(0, -14)
	draw_rect(Rect2(cat.x - 10, cat.y - 8, 20, 14), Color(0.9, 0.62, 0.3))
	draw_rect(Rect2(cat.x - 12, cat.y - 16, 8, 8), Color(0.9, 0.62, 0.3))
	draw_rect(Rect2(cat.x + 4, cat.y - 16, 8, 8), Color(0.9, 0.62, 0.3))
	# Çubuklar
	_bar(Rect2(BOX.position.x + 40, BOX.position.y + 110, BOX.size.x - 80, 18), _prog, GREEN if _flash <= 0.0 else RED)
	draw_string(font, Vector2(BOX.position.x, BOX.position.y + 152), tr("MG_TIME") % int(ceil(_limit)), HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 20, CREAM)


func _draw_rhythm(font: Font) -> void:
	var step := minf(82.0, 560.0 / _steps)
	var start_x := BOX.get_center().x - step * (_steps - 1) / 2.0
	for i in _steps:
		var c := Vector2(start_x + i * step, BOX.position.y + 205)
		var done := i < _idx
		var cur := i == _idx
		var col := Color(0.35, 0.3, 0.25)
		if cur:
			col = GOLD
		elif done:
			col = Color(0.4, 0.55, 0.4)
		var s := 26.0 if cur else 20.0
		draw_rect(Rect2(c - Vector2(s + 6, s + 6), Vector2((s + 6) * 2, (s + 6) * 2)), FRAME)
		draw_rect(Rect2(c - Vector2(s + 2, s + 2), Vector2((s + 2) * 2, (s + 2) * 2)), PANEL.lightened(0.08))
		var pts := PackedVector2Array()
		match _seq[i]:
			0:
				pts = PackedVector2Array([c + Vector2(-s, 0), c + Vector2(s * 0.6, -s * 0.8), c + Vector2(s * 0.6, s * 0.8)])
			1:
				pts = PackedVector2Array([c + Vector2(s, 0), c + Vector2(-s * 0.6, -s * 0.8), c + Vector2(-s * 0.6, s * 0.8)])
			2:
				pts = PackedVector2Array([c + Vector2(0, -s), c + Vector2(-s * 0.8, s * 0.6), c + Vector2(s * 0.8, s * 0.6)])
			_:
				pts = PackedVector2Array([c + Vector2(0, s), c + Vector2(-s * 0.8, -s * 0.6), c + Vector2(s * 0.8, -s * 0.6)])
		draw_colored_polygon(pts, col)
	_bar(Rect2(BOX.position.x + 90, BOX.position.y + 290, BOX.size.x - 180, 16), _left / 1.8, RED if _left < 0.5 else GOLD)
	draw_string(font, Vector2(BOX.position.x, BOX.position.y + 340), tr("MG_MISSES") % _misses, HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 22, RED if _misses >= 2 else CREAM)


func _draw_pump(font: Font) -> void:
	# Lastik: dolulukla büyür
	var c := Vector2(BOX.get_center().x, BOX.position.y + 205)
	var r := 28.0 + 40.0 * clampf(_prog, 0.0, 1.0) * (1.0 + 0.06 * _flash)
	draw_circle(c, r + 8.0, FRAME)
	draw_circle(c, r, Color(0.16, 0.16, 0.18))
	draw_circle(c, r * 0.45, Color(0.6, 0.6, 0.62))
	_bar(Rect2(BOX.position.x + 40, BOX.position.y + 290, BOX.size.x - 80, 18), _prog, GREEN)
	draw_string(font, Vector2(BOX.position.x, BOX.position.y + 340), tr("MG_TIME") % int(ceil(_limit)), HORIZONTAL_ALIGNMENT_CENTER, BOX.size.x, 20, CREAM)


func _draw_catch(font: Font) -> void:
	_stage(font, tr("MG_CAUGHT") % [_score, _goal], CREAM, tr("MG_MISSES") % _misses)
	var o := AREA.position
	draw_rect(Rect2(o.x, o.y + AREA.size.y - 12, AREA.size.x, 12), Color(0.3, 0.23, 0.16))
	for it in _items:
		var c := o + Vector2(float(it["x"]), float(it["y"]))
		if it["bad"]:
			draw_circle(c, 15.0, Color(0.32, 0.36, 0.14))
			draw_circle(c + Vector2(-4, -3), 3.0, Color(0.12, 0.12, 0.06))
			draw_circle(c + Vector2(5, 2), 3.0, Color(0.12, 0.12, 0.06))
			draw_line(c + Vector2(-8, -20), c + Vector2(-4, -26), Color(0.6, 0.7, 0.3), 2.0)
			draw_line(c + Vector2(8, -20), c + Vector2(4, -26), Color(0.6, 0.7, 0.3), 2.0)
		else:
			draw_circle(c, 15.0, Color(0.95, 0.55, 0.12))
			draw_circle(c + Vector2(-5, -5), 4.0, Color(1.0, 0.8, 0.45))
			draw_rect(Rect2(c.x - 1, c.y - 19, 3, 6), Color(0.3, 0.55, 0.2))
	var b := o + Vector2(_bx, AREA.size.y - 46.0)
	var col := Color(0.78, 0.55, 0.28) if _flash <= 0.0 else RED
	draw_colored_polygon(PackedVector2Array([b + Vector2(-50, 0), b + Vector2(50, 0), b + Vector2(40, 30), b + Vector2(-40, 30)]), col)
	draw_line(b + Vector2(-50, 0), b + Vector2(50, 0), FRAME, 4.0)
	for k in range(-2, 3):
		draw_line(b + Vector2(k * 18.0, 2), b + Vector2(k * 14.0, 28), Color(0.5, 0.33, 0.15), 2.0)


func _draw_item(type: int, variant: int, c: Vector2, s: float) -> void:
	match type:
		0:   # kağıt: gazete ya da koli
			if variant == 0:
				draw_rect(Rect2(c + Vector2(-22, -28) * s, Vector2(44, 56) * s), Color(0.93, 0.92, 0.86))
				draw_rect(Rect2(c + Vector2(-22, -28) * s, Vector2(44, 56) * s), FRAME, false, 2.0)
				for k in 5:
					draw_line(c + Vector2(-16, -16 + k * 9) * s, c + Vector2(16, -16 + k * 9) * s, Color(0.45, 0.43, 0.4), 2.0)
			else:
				draw_rect(Rect2(c + Vector2(-26, -20) * s, Vector2(52, 40) * s), Color(0.7, 0.52, 0.3))
				draw_rect(Rect2(c + Vector2(-26, -20) * s, Vector2(52, 40) * s), FRAME, false, 2.0)
				draw_rect(Rect2(c + Vector2(-5, -20) * s, Vector2(10, 40) * s), Color(0.85, 0.75, 0.5))
		1:   # cam: şişe ya da kavanoz
			var gc := Color(0.3, 0.62, 0.38) if variant == 0 else Color(0.62, 0.8, 0.85)
			if variant == 0:
				draw_rect(Rect2(c + Vector2(-14, -4) * s, Vector2(28, 34) * s), gc)
				draw_rect(Rect2(c + Vector2(-6, -28) * s, Vector2(12, 26) * s), gc)
			else:
				draw_rect(Rect2(c + Vector2(-20, -16) * s, Vector2(40, 44) * s), gc)
				draw_rect(Rect2(c + Vector2(-22, -26) * s, Vector2(44, 10) * s), Color(0.8, 0.7, 0.3))
			draw_rect(Rect2(c + Vector2(-8, 4) * s, Vector2(5, 18) * s), Color(1, 1, 1, 0.35))
		_:   # plastik: şişe ya da bardak
			if variant == 0:
				draw_rect(Rect2(c + Vector2(-14, -8) * s, Vector2(28, 38) * s), Color(0.55, 0.78, 0.95))
				draw_rect(Rect2(c + Vector2(-7, -24) * s, Vector2(14, 16) * s), Color(0.55, 0.78, 0.95))
				draw_rect(Rect2(c + Vector2(-8, -30) * s, Vector2(16, 7) * s), Color(0.9, 0.3, 0.3))
			else:
				draw_colored_polygon(PackedVector2Array([c + Vector2(-20, -22) * s, c + Vector2(20, -22) * s, c + Vector2(14, 28) * s, c + Vector2(-14, 28) * s]), Color(0.95, 0.5, 0.65))
				draw_line(c + Vector2(6, -22) * s, c + Vector2(14, -38) * s, Color(0.95, 0.95, 0.95), 4.0)


func _draw_sort(font: Font) -> void:
	_stage(font, tr("MG_MISSES") % _misses, RED if _misses >= 2 else CREAM, "%d / %d" % [mini(_idx + 1, _steps), _steps])
	var o := AREA.position
	# Kalan süre
	_bar(Rect2(o.x + 150, o.y + 40, AREA.size.x - 300, 10), _left / maxf(_item_time, 0.1), RED if _left < 0.6 else GOLD)
	if _idx < _steps:
		_draw_item(_seq[_idx], _variants[_idx], o + Vector2(AREA.size.x * 0.5, 100.0), 1.15)
	for i in 3:
		var r := Rect2(o.x + 40 + i * 190.0, o.y + AREA.size.y - 74.0, 130.0, 66.0)
		var col: Color = BIN_COLORS[i]
		draw_rect(r.grow(3), FRAME)
		draw_rect(r, col.darkened(0.15))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 12)), col.lightened(0.15))
		draw_string(font, r.position + Vector2(0, 38), tr(BIN_KEYS[i]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 20, FRAME)
		draw_string(font, r.position + Vector2(0, 58), ["← / A", "↓ / S", "→ / D"][i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 14, FRAME)
	if _flash > 0.0:
		draw_rect(AREA, Color(0.9, 0.2, 0.15, 0.25 * _flash))


func _draw_whack(font: Font) -> void:
	_stage(font, tr("MG_HITS") % [_score, _goal], CREAM, tr("MG_TIME") % int(ceil(maxf(_limit, 0.0))))
	for i in 9:
		var c := _hole_center(i)
		var h: Dictionary = _holes[i]
		var s := int(h["state"])
		_ellipse(c + Vector2(0, 16), Vector2(48, 14), Color(0.04, 0.03, 0.02))
		if s != 0:
			var up := 30.0 * float(h["pop"])
			var bc := c + Vector2(0, 16 - up)
			if s == 1:
				draw_circle(bc, 24.0, Color(0.42, 0.3, 0.2))
				draw_circle(bc + Vector2(0, 8), 7.0, Color(0.9, 0.55, 0.55))
				draw_circle(bc + Vector2(-9, -6), 3.0, Color.BLACK)
				draw_circle(bc + Vector2(9, -6), 3.0, Color.BLACK)
			elif s == 2:
				draw_circle(bc, 24.0, Color(0.6, 0.45, 0.3))
				for k in range(-3, 4):
					draw_line(bc + Vector2(k * 7.0, -14), bc + Vector2(k * 10.0, -34), Color(0.3, 0.2, 0.12), 3.0)
				draw_circle(bc + Vector2(0, 6), 8.0, Color(0.95, 0.8, 0.65))
				draw_circle(bc + Vector2(-7, 0), 3.0, Color.BLACK)
				draw_circle(bc + Vector2(7, 0), 3.0, Color.BLACK)
			else:
				draw_circle(bc, 22.0, Color(0.55, 0.4, 0.3, 0.8))
				draw_string(font, bc + Vector2(-8, 6), "*", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, GOLD)
		# Mağara ağzı önü
		_ellipse(c + Vector2(0, 22), Vector2(52, 10), Color(0.2, 0.15, 0.1))
		draw_string(font, c + Vector2(-5, 27), "QWEASDZXC"[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.45))
	if _flash > 0.0:
		draw_rect(AREA, Color(0.9, 0.2, 0.15, 0.25 * _flash))


func _ellipse(c: Vector2, r: Vector2, col: Color) -> void:
	var pts := PackedVector2Array()
	for k in 20:
		var a := TAU * k / 20.0
		pts.append(c + Vector2(cos(a) * r.x, sin(a) * r.y))
	draw_colored_polygon(pts, col)


func _draw_memory(font: Font) -> void:
	_stage(font, tr("MG_ROUND") % [_mem_len - 1, _steps - 1], CREAM, tr("MG_TRIES") % _tries)
	for i in 4:
		var r := _pad_rect(i)
		var col: Color = PAD_COLORS[i]
		var on := _lit == i
		draw_rect(r.grow(4), FRAME)
		draw_rect(r, col.lightened(0.35) if on else col.darkened(0.45))
		if on:
			draw_rect(r.grow(8), Color(col.r, col.g, col.b, 0.3), false, 4.0)
		draw_string(font, r.position + Vector2(0, 74), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 40, FRAME)
	var msg := tr("MG_WATCH") if _mem_phase == "show" else tr("MG_YOURS")
	draw_string(font, AREA.position + Vector2(0, AREA.size.y - 30), msg, HORIZONTAL_ALIGNMENT_CENTER, AREA.size.x, 22, GOLD if _mem_phase == "input" else CREAM)
	if _flash > 0.0:
		draw_rect(AREA, Color(0.9, 0.2, 0.15, 0.25 * _flash))


func _draw_stack(font: Font) -> void:
	_stage(font, tr("MG_STACKED") % [_blocks.size() - 1, _goal], CREAM, "")
	var o := AREA.position
	var ground := o.y + AREA.size.y - 8.0
	draw_rect(Rect2(o.x, ground, AREA.size.x, 8), Color(0.3, 0.23, 0.16))
	for i in _blocks.size():
		var b: Vector2 = _blocks[i]
		_draw_crate(Rect2(o.x + b.x, ground - (i + 1) * BLOCK_H, b.y, BLOCK_H), i)
	if _result == "":
		_draw_crate(Rect2(o.x + _sx, ground - (_blocks.size() + 1) * BLOCK_H, _sw, BLOCK_H), _blocks.size())
	if _flash > 0.0 and _result == "":
		draw_string(font, o + Vector2(0, 50), tr("MG_PERFECT"), HORIZONTAL_ALIGNMENT_CENTER, AREA.size.x, 22, GOLD)


func _draw_crate(r: Rect2, i: int) -> void:
	var base := Color(0.32, 0.62, 0.3) if i % 2 == 0 else Color(0.4, 0.7, 0.34)
	draw_rect(r, base)
	for k in int(r.size.x / 16.0):
		draw_rect(Rect2(r.position.x + 6 + k * 16.0, r.position.y, 6, r.size.y), base.darkened(0.2))
	draw_rect(r, FRAME, false, 2.0)
