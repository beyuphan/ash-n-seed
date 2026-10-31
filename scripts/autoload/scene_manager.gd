extends CanvasLayer
## Karartma geçişiyle sahne değiştirir. Kullanım: SceneManager.change_scene("res://scenes/x.tscn")

var _fade: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0.08, 0.09, 0.08, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)


func change_scene(path: String, duration: float = 0.35) -> void:
	if _busy:
		return
	_busy = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var out_tween := create_tween()
	out_tween.tween_property(_fade, "color:a", 1.0, duration)
	await out_tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var in_tween := create_tween()
	in_tween.tween_property(_fade, "color:a", 0.0, duration)
	await in_tween.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
