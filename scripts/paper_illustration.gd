class_name PaperIllustration
extends Control
## Gazetenin fotoğrafı: günün Çevre durumunu gösteren küçük bir kasaba manzarası.
## Kirliyse gri-sarı gökyüzü ve yoğun duman, temizse mavi gökyüzü ve çok ağaç. Sepya tonlu, "basılmış" görünüm.

var nature := 30.0       ## 0..100
var trees := 3           ## o gün dikilen ağaç, manzaraya eklenir
var _time := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(380, 190)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var clean := clampf(nature / 100.0, 0.0, 1.0)
	var dirty := 1.0 - clean
	# Gökyüzü
	var sky_top := Color(0.55, 0.5, 0.4).lerp(Color(0.45, 0.65, 0.85), clean)
	var sky_low := Color(0.78, 0.68, 0.45).lerp(Color(0.8, 0.9, 0.95), clean)
	for i in 10:
		draw_rect(Rect2(0, h * 0.7 * i / 10.0, w, h * 0.7 / 10.0 + 1), sky_top.lerp(sky_low, float(i) / 9.0))
	# Güneş
	draw_circle(Vector2(w * 0.8, h * 0.28), 22.0 + 6.0 * clean, Color(1.0, 0.92, 0.6, 0.35 + 0.5 * clean))
	draw_circle(Vector2(w * 0.8, h * 0.28), 14.0, Color(1.0, 0.95, 0.7, 0.6 + 0.4 * clean))
	# Uzak tepeler
	var hills := Color(0.35, 0.33, 0.3).lerp(Color(0.35, 0.6, 0.4), clean)
	var pts := PackedVector2Array([Vector2(0, h * 0.72)])
	for i in 13:
		var x := w * i / 12.0
		pts.append(Vector2(x, h * 0.58 - sin(i * 0.9) * 12.0 - sin(i * 0.4) * 8.0))
	pts.append(Vector2(w, h * 0.72))
	draw_colored_polygon(pts, hills)
	# Fabrikalar ve duman
	var factory := Color(0.18, 0.15, 0.16)
	for f in [0.12, 0.32, 0.5]:
		var fx: float = w * f
		draw_rect(Rect2(fx, h * 0.52, 44, h * 0.2), factory)
		draw_rect(Rect2(fx + 8, h * 0.4, 8, h * 0.13), factory)
		draw_rect(Rect2(fx + 28, h * 0.44, 8, h * 0.09), factory)
		for k in int(2 + dirty * 5):
			var rise := fmod(_time * 12.0 + k * 17.0 + fx, 90.0)
			draw_circle(Vector2(fx + 12 + rise * 0.3 + sin(_time + k) * 4.0, h * 0.4 - rise),
				6.0 + rise * 0.14, Color(0.25, 0.22, 0.2, 0.5 * dirty * (1.0 - rise / 90.0)))
	# Ön plan: çim ve ağaçlar
	var ground := Color(0.4, 0.3, 0.2).lerp(Color(0.38, 0.65, 0.3), clean)
	draw_rect(Rect2(0, h * 0.72, w, h * 0.28), ground)
	var tree_count := int(round(2.0 + clean * 7.0)) + mini(trees, 4)
	for i in tree_count:
		var tx := w * (0.06 + 0.9 * fmod(i * 0.37 + 0.11, 1.0))
		var ty := h * (0.78 + 0.16 * fmod(i * 0.61, 1.0))
		var s := 0.8 + 0.4 * fmod(i * 0.53, 1.0)
		draw_rect(Rect2(tx - 2 * s, ty - 8 * s, 4 * s, 9 * s), Color(0.35, 0.22, 0.12))
		var leaf := Color(0.45, 0.35, 0.22).lerp(Color(0.25, 0.65, 0.28), clean)
		draw_circle(Vector2(tx, ty - 14 * s), 9.0 * s, leaf)
		draw_circle(Vector2(tx - 4 * s, ty - 10 * s), 6.0 * s, leaf.darkened(0.1))
	# Basılı fotoğraf hissi: sepya katman, çerçeve
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.55, 0.42, 0.25, 0.22))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.09, 0.07), false, 4.0)
