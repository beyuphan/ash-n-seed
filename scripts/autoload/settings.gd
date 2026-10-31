extends Node
## Kullanıcı ayarları: dil ve ses seviyeleri. user://settings.cfg içinde saklanır.

signal language_changed(code: String)
signal volumes_changed

const SAVE_PATH := "user://settings.cfg"
## Yeni dil eklemek için: translations/strings.csv'ye sütun aç + buraya satır ekle.
const LANGUAGES := {"tr": "Türkçe", "en": "English"}

var language: String = "en"
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var fullscreen := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # duraklatma menüsünde de F11 çalışsın
	language = _detect_language()
	_load()
	TranslationServer.set_locale(language)
	if fullscreen and not OS.has_feature("web"):   # tarayıcıda tam ekran ancak kullanıcı tıklamasıyla açılır
		_apply_window()


## F11 ya da Alt+Enter: tam ekran aç/kapat.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F11 or (event.alt_pressed and event.physical_keycode == KEY_ENTER):
			set_fullscreen(not fullscreen)
			get_viewport().set_input_as_handled()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply_window()
	save()
	volumes_changed.emit()   # menüdeki kutu eşitlensin


func _apply_window() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func set_language(code: String) -> void:
	if not LANGUAGES.has(code):
		return
	language = code
	TranslationServer.set_locale(code)
	save()
	language_changed.emit(code)


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	volumes_changed.emit()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	volumes_changed.emit()


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("general", "language", language)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	var saved: String = cfg.get_value("general", "language", language)
	if LANGUAGES.has(saved):
		language = saved
	music_volume = clampf(cfg.get_value("audio", "music", music_volume), 0.0, 1.0)
	sfx_volume = clampf(cfg.get_value("audio", "sfx", sfx_volume), 0.0, 1.0)
	fullscreen = bool(cfg.get_value("video", "fullscreen", fullscreen))


func _detect_language() -> String:
	var system_lang := OS.get_locale_language()
	return system_lang if LANGUAGES.has(system_lang) else "en"
