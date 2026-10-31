extends SceneTree
## Karakter PNG'lerini üretir: assets/art/characters/<id>_<kare>.png
## Çalıştır: Godot_console.exe --headless --path D:\Projects\cop31 --script res://tools/generate_characters.gd
## İsteğe bağlı önizleme: -- preview=<klasör> ile 6x büyütülmüş tek bir sayfa yazar.

const OUT_DIR := "res://assets/art/characters"
const FRAMES := {
	"idle": [false, false],
	"blink": [true, false],
	"talk": [false, true],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var sheet_cells: Array[Image] = []
	for id in CharacterPainter.IDS:
		for frame_name in FRAMES:
			var flags: Array = FRAMES[frame_name]
			var img := CharacterPainter.paint(id, flags[0], flags[1])
			var path := "%s/%s_%s.png" % [OUT_DIR, id, frame_name]
			var err := img.save_png(path)
			print(path, " -> ", "ok" if err == OK else "HATA %d" % err)
			sheet_cells.append(img)

	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("preview="):
			_write_preview(sheet_cells, arg.trim_prefix("preview="))
	quit()


func _write_preview(cells: Array[Image], folder: String) -> void:
	var scale := 6
	var cols := FRAMES.size()
	var rows := CharacterPainter.IDS.size()
	var cw := CharacterPainter.W * scale
	var ch := CharacterPainter.H * scale
	var sheet := Image.create_empty(cw * cols, ch * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.35, 0.38, 0.34))
	for i in cells.size():
		var big := cells[i].duplicate() as Image
		big.resize(cw, ch, Image.INTERPOLATE_NEAREST)
		sheet.blend_rect(big, Rect2i(0, 0, cw, ch), Vector2i((i % cols) * cw, (i / cols) * ch))
	sheet.save_png(folder.path_join("characters_preview.png"))
	print("önizleme yazıldı: ", folder)
