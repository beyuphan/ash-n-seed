extends SceneTree
## Tema dosyalarını üretir: assets/ui/theme.tres (koyu sahneler) ve assets/ui/paper_theme.tres (krem kağıt paneller).
## Renkleri değiştirmek için burayı düzenleyip çalıştır:
##   Godot_console.exe --headless --path D:\Projects\cop31 --script res://tools/build_themes.gd

const FONT_PATH := "res://assets/fonts/Baloo2.ttf"

const CREAM := Color(0.96, 0.93, 0.84)
const INK := Color(0.24, 0.17, 0.12)
const GREEN := Color(0.42, 0.76, 0.29)
const GREEN_L := Color(0.54, 0.85, 0.38)
const GREEN_D := Color(0.2, 0.45, 0.17)
const PAPER := Color(0.98, 0.94, 0.82)
const PAPER_EDGE := Color(0.72, 0.55, 0.3)
const DARK_PANEL := Color(0.2, 0.18, 0.16, 0.95)
const DARK_EDGE := Color(0.4, 0.34, 0.27)


func _initialize() -> void:
	var font := load(FONT_PATH) as Font
	var wght := TextServerManager.get_primary_interface().name_to_tag("wght")
	var body := _font(font, wght, 500)
	var bold := _font(font, wght, 700)

	# ---------------- Koyu tema (proje varsayılanı)
	var t := Theme.new()
	t.default_font = body
	t.default_font_size = 22
	t.set_color("font_color", "Label", CREAM)
	t.set_color("default_color", "RichTextLabel", CREAM)
	t.set_font("normal_font", "RichTextLabel", body)
	t.set_font("bold_font", "RichTextLabel", bold)
	_button_styles(t, "Button", bold, true)
	_button_styles(t, "OptionButton", bold, true)
	t.set_stylebox("panel", "PanelContainer", _panel(DARK_PANEL, DARK_EDGE))
	t.set_stylebox("background", "ProgressBar", _box(Color(0.1, 0.09, 0.08), Color(0.28, 0.24, 0.2), 14, Vector4i(3, 3, 3, 3), Vector4(0, 0, 0, 0)))
	t.set_stylebox("fill", "ProgressBar", _box(GREEN, GREEN, 12, Vector4i(0, 0, 0, 0), Vector4(0, 0, 0, 0)))
	t.set_font("font", "ProgressBar", bold)
	_slider(t)
	_popup(t)
	ResourceSaver.save(t, "res://assets/ui/theme.tres")

	# ---------------- Kağıt tema (krem paneller: konuşma balonu, ayarlar, son ekranı)
	var p := Theme.new()
	p.set_color("font_color", "Label", INK)
	p.set_color("default_color", "RichTextLabel", INK)
	p.set_stylebox("panel", "PanelContainer", _panel(PAPER, PAPER_EDGE))
	# Kağıt üstündeki butonlar: krem beyaz, mürekkep yazı
	for type_name in ["Button", "OptionButton"]:
		p.set_stylebox("normal", type_name, _chunky(Color(1.0, 0.98, 0.92), PAPER_EDGE, 6))
		p.set_stylebox("hover", type_name, _chunky(Color(1.0, 0.93, 0.62), Color(0.78, 0.58, 0.22), 6))
		p.set_stylebox("pressed", type_name, _chunky(Color(0.98, 0.85, 0.45), Color(0.78, 0.58, 0.22), 2, true))
		p.set_stylebox("focus", type_name, StyleBoxEmpty.new())
		p.set_color("font_color", type_name, INK)
		p.set_color("font_hover_color", type_name, INK)
		p.set_color("font_pressed_color", type_name, INK)
		p.set_color("font_focus_color", type_name, INK)
		p.set_constant("outline_size", type_name, 0)
	_slider(p)
	ResourceSaver.save(p, "res://assets/ui/paper_theme.tres")
	print("temalar yazıldı")
	quit()


func _font(base: Font, wght: int, weight: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = base
	fv.variation_opentype = {wght: weight}
	return fv


func _box(bg: Color, border: Color, radius: int, bw: Vector4i, margin: Vector4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_left = bw.x
	s.border_width_top = bw.y
	s.border_width_right = bw.z
	s.border_width_bottom = bw.w
	s.set_corner_radius_all(radius)
	s.content_margin_left = margin.x
	s.content_margin_top = margin.y
	s.content_margin_right = margin.z
	s.content_margin_bottom = margin.w
	return s


## Altı kalın kenarlı, "basılabilir" düğme. pressed olunca alt kenar incelir, içerik aşağı iner.
func _chunky(bg: Color, edge: Color, bottom: int, pressed: bool = false) -> StyleBoxFlat:
	# Basılı halde içerik 4 px aşağı iner, alt kenar o kadar incelir.
	var top_margin := 14.0 if pressed else 10.0
	var bottom_margin := 10.0 if pressed else 14.0
	return _box(bg, edge, 16, Vector4i(3, 3, 3, bottom), Vector4(22, top_margin, 22, bottom_margin))


func _button_styles(t: Theme, type_name: String, font: Font, green: bool) -> void:
	t.set_stylebox("normal", type_name, _chunky(GREEN, GREEN_D, 7))
	t.set_stylebox("hover", type_name, _chunky(GREEN_L, GREEN_D, 7))
	t.set_stylebox("pressed", type_name, _chunky(Color(0.34, 0.66, 0.24), GREEN_D, 3, true))
	t.set_stylebox("disabled", type_name, _chunky(Color(0.55, 0.55, 0.5), Color(0.38, 0.38, 0.34), 7))
	t.set_stylebox("focus", type_name, StyleBoxEmpty.new())
	t.set_font("font", type_name, font)
	t.set_font_size("font_size", type_name, 24)
	t.set_color("font_color", type_name, Color.WHITE)
	t.set_color("font_hover_color", type_name, Color.WHITE)
	t.set_color("font_pressed_color", type_name, Color.WHITE)
	t.set_color("font_focus_color", type_name, Color.WHITE)
	t.set_color("font_disabled_color", type_name, Color(0.8, 0.8, 0.75))
	t.set_color("font_outline_color", type_name, Color(0.16, 0.34, 0.12))
	t.set_constant("outline_size", type_name, 5)


func _panel(bg: Color, edge: Color) -> StyleBoxFlat:
	var s := _box(bg, edge, 22, Vector4i(4, 4, 4, 4), Vector4(24, 20, 24, 20))
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 12
	s.shadow_offset = Vector2(0, 6)
	return s


func _slider(t: Theme) -> void:
	# content_margin dikey kalınlığı belirler: 6+6 = 12 px'lik çubuk.
	var rail := Vector4(0, 6, 0, 6)
	t.set_stylebox("slider", "HSlider", _box(Color(0.32, 0.26, 0.2), Color(0.2, 0.15, 0.1), 6, Vector4i(2, 2, 2, 2), rail))
	t.set_stylebox("grabber_area", "HSlider", _box(GREEN, GREEN_D, 6, Vector4i(2, 2, 2, 2), rail))
	t.set_stylebox("grabber_area_highlight", "HSlider", _box(GREEN_L, GREEN_D, 6, Vector4i(2, 2, 2, 2), rail))
	var knob := _knob(false)
	var knob_hi := _knob(true)
	t.set_icon("grabber", "HSlider", knob)
	t.set_icon("grabber_highlight", "HSlider", knob_hi)
	t.set_icon("grabber_disabled", "HSlider", knob)
	t.set_constant("center_grabber", "HSlider", 0)


func _popup(t: Theme) -> void:
	t.set_stylebox("panel", "PopupMenu", _panel(Color(0.2, 0.18, 0.16, 0.98), DARK_EDGE))
	t.set_stylebox("hover", "PopupMenu", _box(GREEN, GREEN_D, 10, Vector4i(0, 0, 0, 0), Vector4(8, 4, 8, 4)))
	t.set_color("font_color", "PopupMenu", CREAM)
	t.set_color("font_hover_color", "PopupMenu", Color.WHITE)
	t.set_font_size("font_size", "PopupMenu", 22)


func _knob(highlight: bool) -> ImageTexture:
	var size := 30
	var img := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if d <= 14.0:
				var c := GREEN_D if d > 11.0 else (Color(1, 0.98, 0.9) if not highlight else Color(1, 0.93, 0.62))
				img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)
