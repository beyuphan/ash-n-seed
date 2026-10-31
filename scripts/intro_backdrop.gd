extends Control
## Giriş sahnelerinin kodla çizilen kasvetli arka planları.
##  BLACK: zifiri karanlık, alttan zayıf kızıl ışıltı. FOG: kurum bulutu, kızıl ufuk, yanan bacalar.
##  DESK: başkanın masası, loş lamba, küllük, kuru saksı. LOGO: karanlık, kıvılcım ve kül.
## slam: masaya kalın dosya çarpar. toxic: sarımsı zehirli filtre ve titreyen lamba.

enum Mode { BLACK, FOG, DESK, LOGO, FLY }

const ROBOT: Texture2D = preload("res://assets/art/characters/assistant_idle.png")  # preload: çizim sırasında yüklenen doku beyaz kalıyordu
const ASH_COUNT := 240
const EMBER_COUNT := 36
const SLAM_AT := 0.85  # mod başladıktan kaç saniye sonra dosya masaya çarpar

var slam := false
var toxic := false
var show_mayor := false      ## masada başkanın arkadan siluet
var show_robot := false      ## masanın arkasından Tomurcuk fırlar
var show_folder := true
var mode: Mode = Mode.BLACK:
	set(value):
		mode = value
		_mode_time = 0.0
		queue_redraw()

var _time := 0.0
var _mode_time := 0.0
var _ash: Array[Dictionary] = []
var _embers: Array[Dictionary] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in ASH_COUNT:
		_ash.append({
			"pos": Vector2(rng.randf(), rng.randf()),
			"speed": rng.randf_range(0.05, 0.17),
			"drift": rng.randf_range(0.02, 0.09),
			"size": rng.randf_range(1.5, 4.5),
			"order": float(i) / ASH_COUNT,
		})
	for i in EMBER_COUNT:
		_embers.append({
			"pos": Vector2(rng.randf(), rng.randf_range(0.5, 1.0)),
			"speed": rng.randf_range(0.03, 0.09),
			"phase": rng.randf() * TAU,
		})


func _process(delta: float) -> void:
	_time += delta
	_mode_time += delta
	for p in _ash:
		var pos: Vector2 = p["pos"]
		pos.y += p["speed"] * delta
		pos.x -= p["drift"] * delta
		if pos.y > 1.05 or pos.x < -0.05:
			pos = Vector2(randf_range(0.5, 1.05), -0.05)
		p["pos"] = pos
	for e in _embers:
		var pos: Vector2 = e["pos"]
		pos.y -= e["speed"] * delta
		pos.x += sin(_time * 1.5 + e["phase"]) * 0.02 * delta
		if pos.y < -0.05:
			pos = Vector2(randf(), 1.05)
		e["pos"] = pos
	queue_redraw()


func _flicker(speed: float = 1.0, seed_offset: float = 0.0) -> float:
	var t := _time * speed + seed_offset
	return clampf(0.78 + 0.2 * sin(t * 3.1 + sin(t * 7.3)) + 0.08 * sin(t * 13.7), 0.3, 1.0)


func _draw() -> void:
	match mode:
		Mode.BLACK:
			_draw_black()
		Mode.FOG:
			_draw_fog()
			_draw_ash(1.0)
			_draw_embers(0.6)
		Mode.DESK:
			_draw_desk()
			_draw_ash(0.35)
		Mode.LOGO:
			_draw_black()
			_draw_ash(0.8)
			_draw_embers(1.0)
			_draw_sprout()
		Mode.FLY:
			_draw_ash(0.6)


func _draw_black() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.01, 0.01))
	var f := _flicker(0.8)
	for i in 7:
		draw_circle(Vector2(size.x * 0.5, size.y * 1.08), 560.0 - i * 75.0,
			Color(0.55, 0.08, 0.03, (0.016 + i * 0.004) * f))


func _draw_fog() -> void:
	var w := size.x
	var h := size.y
	var bands := 14
	for i in bands:
		var t := pow(float(i) / (bands - 1), 1.6)
		draw_rect(Rect2(0, h * i / bands, w, h / bands + 1),
			Color(0.07, 0.06, 0.065).lerp(Color(0.34, 0.22, 0.15), t))
	var ground := h * 0.82
	# Ufuktaki kızıl parıltılar (yanan fabrikalar)
	for g in 4:
		var gx := w * (0.15 + g * 0.24)
		var f := _flicker(1.2, g * 2.0)
		for k in 4:
			draw_circle(Vector2(gx, ground - 30), 190.0 - k * 38.0, Color(0.95, 0.35, 0.1, 0.045 * f))
	# Siluetler: pencereleri yanıp sönen binalar, bacalar, bacaların tepesinde alev
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var black := Color(0.02, 0.016, 0.02)
	var x := -30.0
	var index := 0
	while x < w:
		var bw := rng.randf_range(90.0, 180.0)
		var bh := rng.randf_range(80.0, 200.0)
		draw_rect(Rect2(x, ground - bh, bw, bh + h), black)
		for wy in range(int(ground - bh + 16), int(ground - 10), 26):
			for wx in range(int(x + 12), int(x + bw - 14), 22):
				var lit := fmod(sin(wx * 12.9898 + wy * 78.233) * 43758.5453, 1.0)
				if absf(lit) < 0.22:
					var blink := 0.6 + 0.4 * sin(_time * (1.0 + absf(lit) * 8.0) + wx)
					draw_rect(Rect2(wx, wy, 8, 11), Color(0.95, 0.55, 0.15, 0.7 * blink))
		if rng.randf() < 0.6:
			var cx := x + bw * rng.randf_range(0.2, 0.7)
			var ch := rng.randf_range(90.0, 170.0)
			draw_rect(Rect2(cx, ground - bh - ch, 22, ch), black)
			var top := Vector2(cx + 11, ground - bh - ch)
			draw_circle(top + Vector2(0, -4), 9.0 * _flicker(2.0, index), Color(1.0, 0.45, 0.1, 0.55))
			draw_circle(top + Vector2(0, -6), 4.0, Color(1.0, 0.8, 0.4, 0.8))
			_draw_smoke(top, index)
			index += 1
		x += bw + rng.randf_range(2.0, 12.0)
	# Sis katmanları
	for i in 5:
		var fy := h * (0.45 + i * 0.09) + sin(_time * 0.3 + i) * 10.0
		draw_rect(Rect2(0, fy, w, 60), Color(0.35, 0.3, 0.27, 0.07))
	# Çorak zemin ve çöp yığınları
	draw_rect(Rect2(0, ground, w, h - ground), Color(0.035, 0.028, 0.026))
	for i in 14:
		var tx := fmod(i * 173.0 + 40.0, w)
		draw_circle(Vector2(tx, ground + 4), 26.0 + (i % 4) * 8.0, Color(0.05, 0.04, 0.04))


func _draw_smoke(base: Vector2, index: int) -> void:
	for i in 5:
		var rise := fmod(_time * 15.0 + i * 52.0 + index * 29.0, 260.0)
		var alpha := 0.5 * (1.0 - rise / 260.0)
		var sway := sin(_time * 0.5 + i + index) * 18.0
		draw_circle(base + Vector2(sway + rise * 0.3, -rise), 18.0 + rise * 0.16, Color(0.05, 0.045, 0.045, alpha))


func _draw_ash(strength: float) -> void:
	var ramp := clampf(_mode_time / 4.0, 0.0, 1.0)  # önce köşeden birkaç parça, sonra yağmur
	for p in _ash:
		if p["order"] > ramp:
			continue
		var pos: Vector2 = (p["pos"] as Vector2) * size
		draw_circle(pos, p["size"], Color(0.02, 0.018, 0.018, 0.9 * strength))
		draw_circle(pos, p["size"] + 1.2, Color(0.5, 0.42, 0.36, 0.18 * strength))


func _draw_embers(strength: float) -> void:
	for e in _embers:
		var pos: Vector2 = (e["pos"] as Vector2) * size
		var twinkle := 0.5 + 0.5 * sin(_time * 5.0 + e["phase"])
		draw_circle(pos, 2.2, Color(1.0, 0.55, 0.15, (0.35 + 0.5 * twinkle) * strength))
		draw_circle(pos, 5.0, Color(1.0, 0.4, 0.1, 0.08 * strength))


func _draw_desk() -> void:
	var w := size.x
	var h := size.y
	var lamp_f := _flicker(2.5) if toxic else _flicker(0.7)
	# Duvar ve pencere
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.045, 0.04, 0.036))
	var win := Rect2(w * 0.56, h * 0.52, w * 0.32, h * 0.2)
	draw_rect(win.grow(8), Color(0.02, 0.016, 0.014))
	for i in 8:
		draw_rect(Rect2(win.position.x, win.position.y + win.size.y * i / 8.0, win.size.x, win.size.y / 8.0 + 1),
			Color(0.14, 0.07, 0.05).lerp(Color(0.34, 0.2, 0.1), float(i) / 7.0))
	draw_rect(Rect2(win.position.x + win.size.x / 2 - 3, win.position.y, 6, win.size.y), Color(0.02, 0.016, 0.014))
	draw_rect(Rect2(win.position.x, win.position.y + win.size.y / 2 - 3, win.size.x, 6), Color(0.02, 0.016, 0.014))
	for sx in [0.2, 0.55, 0.8]:
		draw_rect(Rect2(win.position.x + win.size.x * sx, win.end.y - 120, 14, 120), Color(0.02, 0.016, 0.02))
	var desk_y := h * 0.76
	# Başkan: pencerenin önünde arkadan siluet, kapüşonundan fidan filizi
	if show_mayor:
		var mw := UiArt.MAYOR_W * 9.0
		var mh := UiArt.MAYOR_H * 9.0
		draw_texture_rect(UiArt.mayor_silhouette(), Rect2(w * 0.6, desk_y - mh + 80.0 + sin(_time * 1.6) * 3.0, mw, mh), false)
	# Tomurcuk: masanın arkasından zıplayarak çıkar (masa onu alttan keser)
	if show_robot:
		var rt := clampf((_mode_time - 0.5) / 0.9, 0.0, 1.0)
		var rise := 1.0 - pow(1.0 - rt, 3.0)
		var rs := 5.5
		var rw := 48.0 * rs
		var rh := 56.0 * rs
		var tex: Texture2D = ROBOT
		var pop := sin(rt * PI) * 38.0
		draw_texture_rect(tex, Rect2(w * 0.26 - rw / 2.0, desk_y - rh + 70.0 + (1.0 - rise) * 330.0 - pop + sin(_time * 2.2) * 3.0 * rise, rw, rh), false)
		if rt >= 1.0:
			for i in 5:
				var p := (_mode_time * 0.9 + i * 0.37)
				var ang := i * 1.3 + _mode_time * 0.6
				var c := Vector2(w * 0.26, desk_y - 250.0) + Vector2(cos(ang), sin(ang)) * (110.0 + 22.0 * sin(p * 4.0))
				var tw := 0.5 + 0.5 * sin(_time * 6.0 + i)
				draw_line(c - Vector2(7, 0), c + Vector2(7, 0), Color(1.0, 0.95, 0.6, 0.4 + 0.5 * tw), 3.0)
				draw_line(c - Vector2(0, 7), c + Vector2(0, 7), Color(1.0, 0.95, 0.6, 0.4 + 0.5 * tw), 3.0)
	# Masa
	draw_rect(Rect2(0, desk_y, w, h - desk_y), Color(0.085, 0.055, 0.035))
	draw_rect(Rect2(0, desk_y, w, 6), Color(0.15, 0.1, 0.06))
	# Masa lambası ve ışık konisi
	var lamp := Vector2(w * 0.2, h * 0.56)
	var tint := Color(1.0, 0.82, 0.3) if not toxic else Color(0.95, 0.9, 0.2)
	for k in 4:
		var spread := 1.0 - k * 0.18
		draw_colored_polygon(PackedVector2Array([
			lamp + Vector2(-16, 10), lamp + Vector2(16, 10),
			Vector2(w * 0.2 + w * 0.3 * spread, desk_y + 4), Vector2(w * 0.2 - w * 0.3 * spread, desk_y + 4),
		]), Color(tint.r, tint.g, tint.b, 0.05 * lamp_f))
	draw_set_transform(Vector2(w * 0.2, desk_y + 14), 0.0, Vector2(1.0, 0.16))
	draw_circle(Vector2.ZERO, w * 0.28, Color(tint.r, tint.g, tint.b, 0.16 * lamp_f))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_polyline(PackedVector2Array([Vector2(w * 0.08, desk_y), Vector2(w * 0.1, h * 0.65), lamp + Vector2(0, -20)]),
		Color(0.03, 0.025, 0.02), 7.0)
	draw_colored_polygon(PackedVector2Array([
		lamp + Vector2(-34, 10), lamp + Vector2(34, 10), lamp + Vector2(16, -20), lamp + Vector2(-16, -20)]),
		Color(0.03, 0.025, 0.02))
	draw_rect(Rect2(lamp.x - 10, lamp.y + 8, 20, 5), Color(tint.r, tint.g, tint.b, 0.9 * lamp_f))
	# Kirli küllük ve ince duman
	var ash_pos := Vector2(w * 0.3, desk_y + 12)
	draw_set_transform(ash_pos, 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 62.0, Color(0.06, 0.06, 0.06))
	draw_circle(Vector2.ZERO, 48.0, Color(0.2, 0.19, 0.17))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in 6:
		draw_rect(Rect2(ash_pos + Vector2(-28 + i * 11, -10 + (i % 2) * 5), Vector2(14, 4)), Color(0.75, 0.72, 0.62))
	var smoke := PackedVector2Array()
	for i in 14:
		smoke.append(ash_pos + Vector2(sin(_time * 1.4 + i * 0.6) * (6 + i), -16 - i * 12))
	draw_polyline(smoke, Color(0.6, 0.58, 0.55, 0.18), 3.0)
	# Kuru saksı
	var pot := Vector2(w * 0.8, desk_y + 4)
	draw_colored_polygon(PackedVector2Array([
		pot + Vector2(-38, -64), pot + Vector2(38, -64), pot + Vector2(28, 0), pot + Vector2(-28, 0)]), Color(0.3, 0.16, 0.09))
	draw_rect(Rect2(pot + Vector2(-44, -78), Vector2(88, 15)), Color(0.38, 0.2, 0.11))
	var stem := Color(0.22, 0.16, 0.09)
	draw_polyline(PackedVector2Array([pot + Vector2(0, -78), pot + Vector2(-6, -130), pot + Vector2(-34, -150)]), stem, 4.0)
	draw_polyline(PackedVector2Array([pot + Vector2(0, -78), pot + Vector2(10, -120), pot + Vector2(36, -128)]), stem, 4.0)
	draw_polyline(PackedVector2Array([pot + Vector2(0, -78), pot + Vector2(0, -145)]), stem, 3.0)
	# Kalın dosya: slam açıksa SLAM_AT anında masaya çarpar ve masa sarsılır
	if show_folder and (not slam or _mode_time >= SLAM_AT):
		var since := _mode_time - SLAM_AT if slam else 99.0
		var bounce := 0.0
		if slam and since < 0.35:
			bounce = -sin(since / 0.35 * PI) * 10.0 * (1.0 - since / 0.35)
		var folder := Rect2(w * 0.46, desk_y - 34 + bounce, 190, 38)
		draw_rect(folder, Color(0.62, 0.55, 0.38))
		draw_rect(Rect2(folder.position.x, folder.position.y, 190, 6), Color(0.45, 0.4, 0.26))
		draw_rect(Rect2(folder.position.x + 20, folder.position.y + 14, 90, 8), Color(0.55, 0.1, 0.08))
		draw_rect(Rect2(folder.position.x - 6, folder.end.y - 8, 202, 8), Color(0.8, 0.77, 0.66))
		if slam and since < 0.5:  # çarpma tozu
			for i in 6:
				var dir := -1.0 if i % 2 == 0 else 1.0
				var d := since * (60.0 + i * 20.0)
				draw_circle(Vector2(folder.position.x + 95 + dir * (40 + d), desk_y - 2 - since * 20.0),
					5.0 + since * 12.0, Color(0.5, 0.45, 0.4, 0.5 * (1.0 - since / 0.5)))
	# Zehirli sarımsı filtre
	if toxic:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.7, 0.6, 0.05, 0.2 + 0.04 * sin(_time * 1.3)))


## Logo sahnesi: külün içinden bir filiz uzar ve sallanır.
func _draw_sprout() -> void:
	var grow := clampf((_mode_time - 1.4) / 2.4, 0.0, 1.0)
	if grow < 0.12:
		return  # yaprak çokgeni çok küçükken üçgenlenemez
	var base := Vector2(size.x * 0.5, size.y * 0.95)
	var sway := sin(_time * 1.6) * 5.0 * grow
	draw_set_transform(base, 0.0, Vector2(1.0, 0.25))
	draw_circle(Vector2.ZERO, 70.0, Color(0.1, 0.07, 0.06))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var green := Color(0.5, 0.85, 0.32)
	var green_d := Color(0.28, 0.6, 0.24)
	var tip := base + Vector2(sway, -92.0 * grow)
	draw_polyline(PackedVector2Array([base, base + Vector2(sway * 0.4, -46.0 * grow), tip]), green_d, 7.0)
	for side in [-1.0, 1.0]:
		var leaf := PackedVector2Array()
		for i in 14:
			var a := TAU * float(i) / 14.0
			leaf.append(Vector2(cos(a) * 30.0 * grow + 30.0 * grow, sin(a) * 12.0 * grow))
		for k in leaf.size():
			var p := leaf[k]
			leaf[k] = tip + Vector2(p.x * side, p.y - 6.0 * grow).rotated(side * -0.35 + sway * 0.01)
		draw_colored_polygon(leaf, green)
	if grow >= 1.0:
		for i in 3:
			var phase := fmod(_time * 0.8 + i * 0.7, 2.0)
			if phase < 0.6:
				var sp := sin(phase / 0.6 * PI) * 8.0
				var c := tip + Vector2(-40 + i * 38, -26 - i * 10)
				draw_line(c - Vector2(sp, 0), c + Vector2(sp, 0), Color(1.0, 0.95, 0.6, 0.9), 3.0)
				draw_line(c - Vector2(0, sp), c + Vector2(0, sp), Color(1.0, 0.95, 0.6, 0.9), 3.0)
