class_name OutroBirds
extends Node2D
## Outro'da haritanın üstünde süzülen kuşlar ve uçuşan polen/yaprak. Dünya koordinatlarında çizilir (kamerayla birlikte hareket eder).

const BIRDS := 22
const MOTES := 70

var _birds: Array[Dictionary] = []
var _motes: Array[Dictionary] = []
var _time := 0.0
var world := Vector2(1536, 1024)


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var flock_center := Vector2(rng.randf_range(0, world.x), rng.randf_range(0, world.y * 0.6))
	for i in BIRDS:
		_birds.append({
			"pos": flock_center + Vector2(rng.randf_range(-90, 90), rng.randf_range(-50, 50)),
			"speed": rng.randf_range(24.0, 38.0),
			"phase": rng.randf() * TAU,
			"size": rng.randf_range(0.8, 1.4),
			"drift": rng.randf_range(-6.0, 6.0),
		})
	for i in MOTES:
		_motes.append({
			"pos": Vector2(rng.randf_range(0, world.x), rng.randf_range(0, world.y)),
			"speed": rng.randf_range(4.0, 12.0),
			"phase": rng.randf() * TAU,
			"kind": rng.randi() % 3,
		})


func _process(delta: float) -> void:
	_time += delta
	for b in _birds:
		var pos: Vector2 = b["pos"]
		pos.x += b["speed"] * delta
		pos.y += (b["drift"] + sin(_time * 0.8 + b["phase"]) * 8.0) * delta
		if pos.x > world.x + 80.0:
			pos = Vector2(-80.0, randf_range(0.0, world.y * 0.7))
		b["pos"] = pos
	for m in _motes:
		var pos: Vector2 = m["pos"]
		pos.y -= m["speed"] * delta * 0.5
		pos.x += sin(_time * 0.7 + m["phase"]) * 6.0 * delta
		if pos.y < -10.0:
			pos = Vector2(randf_range(0.0, world.x), world.y + 10.0)
		m["pos"] = pos
	queue_redraw()


func _draw() -> void:
	# Polen, ışıltı ve yapraklar
	for m in _motes:
		var tw := 0.5 + 0.5 * sin(_time * 2.0 + m["phase"])
		match int(m["kind"]):
			0:
				draw_circle(m["pos"], 1.2, Color(1.0, 0.95, 0.6, 0.35 + 0.4 * tw))
			1:
				draw_circle(m["pos"], 0.9, Color(1.0, 1.0, 0.85, 0.3 + 0.4 * tw))
			_:
				var p: Vector2 = m["pos"]
				draw_line(p, p + Vector2(3, -1.5).rotated(_time * 0.6 + m["phase"]), Color(0.5, 0.85, 0.35, 0.85), 1.6)
	# Kuşlar: kanat çırpan "v" şekilleri
	for b in _birds:
		var p: Vector2 = b["pos"]
		var flap := sin(_time * 7.0 + b["phase"])
		var s: float = b["size"] * 5.0
		var col := Color(0.12, 0.1, 0.1, 0.9)
		draw_line(p, p + Vector2(-s, -s * 0.6 * flap), col, 1.6)
		draw_line(p, p + Vector2(s, -s * 0.6 * flap), col, 1.6)
