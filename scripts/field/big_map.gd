class_name BigMap
extends Control
## Büyük harita: mini haritaya tıklayınca (ya da M ile) açılır, oyun durur.
## Bölge adları, yerler, konuşacak karakterler, sen ve pazar görünür. Tıklayınca işaret konur (tekrar tıkla: kalkar).
## İşaret, sahada ekran kenarında ok olarak yol gösterir.

signal waypoint_changed(tile: Vector2i)

const SCALE := 7
const ORIGIN := Vector2(304, 152)
const FRAME := Color(0.09, 0.065, 0.05)
const PANEL := Color(0.2, 0.15, 0.11, 0.97)
const CREAM := Color(0.97, 0.93, 0.83)
const GOLD := Color(1.0, 0.82, 0.3)
const ZONE_COLORS := {
	FieldMap.Zone.PARK: Color(0.75, 1.0, 0.7),
	FieldMap.Zone.HOUSING: Color(1.0, 0.9, 0.7),
	FieldMap.Zone.FOREST: Color(0.6, 0.95, 0.6),
	FieldMap.Zone.RIVER: Color(0.65, 0.85, 1.0),
	FieldMap.Zone.INDUSTRY: Color(1.0, 0.7, 0.55),
	FieldMap.Zone.FARM: Color(1.0, 0.95, 0.55),
	FieldMap.Zone.LANDFILL: Color(0.85, 0.8, 0.75),
}

var is_open := false
var map: FieldMap
var waypoint := Vector2i(-1, -1)
var player_tile := Vector2i.ZERO
var market_tile := Vector2i.ZERO
var explored_percent := 0

var _texture: ImageTexture
var _zone_pos := {}
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func open(img: Image) -> void:
	_texture = ImageTexture.create_from_image(img)
	_zone_pos.clear()
	var sums := {}
	var counts := {}
	for y in FieldMap.ROWS:
		for x in FieldMap.COLS:
			var t := Vector2i(x, y)
			var z := map.zone_at(t)
			if z == 0 or map.is_locked(t) or not map.is_explored(t):
				continue
			sums[z] = sums.get(z, Vector2.ZERO) + Vector2(x, y)
			counts[z] = counts.get(z, 0) + 1
	for z in sums:
		if counts[z] >= 12:
			_zone_pos[z] = sums[z] / float(counts[z])
	is_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func close() -> void:
	is_open = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if is_open:
		_time += delta
		queue_redraw()


func _tile_at(p: Vector2) -> Vector2i:
	return Vector2i(floori((p.x - ORIGIN.x) / SCALE), floori((p.y - ORIGIN.y) / SCALE))


func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE or event.physical_keycode == KEY_M:
			close()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		var t := _tile_at(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_set_waypoint(Vector2i(-1, -1))
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if not map.in_bounds(t):
				close()
			elif waypoint.x >= 0 and Vector2(t - waypoint).length() <= 2.5:
				_set_waypoint(Vector2i(-1, -1))
			else:
				_set_waypoint(t)


func _set_waypoint(t: Vector2i) -> void:
	waypoint = t
	waypoint_changed.emit(t)


func _px(t: Vector2) -> Vector2:
	return ORIGIN + t * SCALE


func _draw() -> void:
	if not is_open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.7))
	var panel := Rect2(ORIGIN - Vector2(24, 62), Vector2(FieldMap.COLS * SCALE + 48, FieldMap.ROWS * SCALE + 118))
	draw_rect(panel.grow(6), FRAME)
	draw_rect(panel, PANEL)
	var font := get_theme_font("font", "Label")
	draw_string(font, Vector2(panel.position.x, panel.position.y + 36), "%s  %d%%" % [tr("BIGMAP_TITLE"), explored_percent], HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 28, GOLD)
	if map.filter_enabled:
		var fc := map.factory_counts()
		var ok := fc.x >= fc.y
		draw_string(font, Vector2(panel.end.x - 330, panel.position.y + 36), tr("BIGMAP_FACTORIES") % [fc.x, fc.y], HORIZONTAL_ALIGNMENT_RIGHT, 300, 20, Color(0.55, 0.95, 0.55) if ok else Color(1.0, 0.55, 0.45))
	var area := Rect2(ORIGIN, Vector2(FieldMap.COLS, FieldMap.ROWS) * SCALE)
	draw_rect(area.grow(3), FRAME)
	if _texture != null:
		draw_texture_rect(_texture, area, false)
	# Bölge adları
	for z in _zone_pos:
		var label := tr(FieldMap.ZONE_KEYS.get(z, "ZONE_PARK"))
		var p := _px(_zone_pos[z]) + Vector2(-80, 6)
		draw_string_outline(font, p, label, HORIZONTAL_ALIGNMENT_CENTER, 160, 22, 7, FRAME)
		draw_string(font, p, label, HORIZONTAL_ALIGNMENT_CENTER, 160, 22, ZONE_COLORS.get(z, CREAM))
	# Yerler
	for l in map.landmarks:
		if map.is_locked(l["t"]) or not map.is_explored(l["t"]):
			continue
		var c := _px(Vector2(l["t"]) + Vector2(0.5, 0.5))
		draw_rect(Rect2(c - Vector2(3, 3), Vector2(6, 6)), FRAME)
		draw_rect(Rect2(c - Vector2(2, 2), Vector2(4, 4)), CREAM)
		var name := tr("LM_" + str(l["id"]).to_upper())
		draw_string_outline(font, c + Vector2(-70, -8), name, HORIZONTAL_ALIGNMENT_CENTER, 140, 14, 5, FRAME)
		draw_string(font, c + Vector2(-70, -8), name, HORIZONTAL_ALIGNMENT_CENTER, 140, 14, CREAM)
	# Pınar'ın ağacı
	for st in map.special_trees:
		var tc := _px(Vector2(st["t"]) + Vector2(0.5, 0.5))
		draw_circle(tc, 8.0, FRAME)
		draw_circle(tc, 6.5, Color(0.45, 0.9, 0.4))
		var tname := tr("LM_PINAR_AGACI")
		draw_string_outline(font, tc + Vector2(-70, 22), tname, HORIZONTAL_ALIGNMENT_CENTER, 140, 14, 5, FRAME)
		draw_string(font, tc + Vector2(-70, 22), tname, HORIZONTAL_ALIGNMENT_CENTER, 140, 14, Color(0.6, 1.0, 0.55))
	# Konuşacak karakterler
	for n in map.npcs:
		if n["active"] and n["marker"] and not map.is_locked(n["t"]):
			var c2 := _px(Vector2(n["t"]) + Vector2(0.5, 0.5))
			draw_circle(c2, 8.0, FRAME)
			draw_circle(c2, 6.5, GOLD)
			draw_string(font, c2 + Vector2(-5, 6), "!", HORIZONTAL_ALIGNMENT_CENTER, 10, 15, FRAME)
	# Pazar
	var m := _px(Vector2(market_tile) + Vector2(0.5, 0.5))
	draw_rect(Rect2(m + Vector2(-9, -2), Vector2(18, 4)), GOLD)
	draw_rect(Rect2(m + Vector2(-2, -9), Vector2(4, 18)), GOLD)
	draw_string_outline(font, m + Vector2(-40, 24), tr("FIELD_MARKET"), HORIZONTAL_ALIGNMENT_CENTER, 80, 15, 5, FRAME)
	draw_string(font, m + Vector2(-40, 24), tr("FIELD_MARKET"), HORIZONTAL_ALIGNMENT_CENTER, 80, 15, GOLD)
	# Sen
	var p2 := _px(Vector2(player_tile) + Vector2(0.5, 0.5))
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_circle(p2, 9.0 + pulse * 3.0, Color(1, 1, 1, 0.25))
	draw_circle(p2, 6.0, FRAME)
	draw_circle(p2, 4.5, Color(0.5, 0.9, 1.0))
	draw_string_outline(font, p2 + Vector2(-30, -14), tr("BIGMAP_YOU"), HORIZONTAL_ALIGNMENT_CENTER, 60, 15, 5, FRAME)
	draw_string(font, p2 + Vector2(-30, -14), tr("BIGMAP_YOU"), HORIZONTAL_ALIGNMENT_CENTER, 60, 15, Color(0.5, 0.9, 1.0))
	# İşaret: bayrak
	if waypoint.x >= 0:
		var w := _px(Vector2(waypoint) + Vector2(0.5, 0.5))
		var bob := sin(_time * 5.0) * 2.0
		draw_line(w, w + Vector2(0, -26 + bob), FRAME, 4.0)
		draw_colored_polygon(PackedVector2Array([w + Vector2(0, -26 + bob), w + Vector2(18, -19 + bob), w + Vector2(0, -12 + bob)]), Color(0.85, 0.55, 1.0))
		draw_circle(w, 4.0, Color(0.85, 0.55, 1.0))
	draw_string(font, Vector2(panel.position.x, panel.end.y - 16), tr("BIGMAP_HELP"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 18, CREAM)
