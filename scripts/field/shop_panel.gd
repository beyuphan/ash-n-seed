class_name ShopPanel
extends Control
## Pazar tezgâhı: kalıcı geliştirmeler. Pazarın yanında U ile açılır, 1-4 ile satın alınır, U ya da Esc ile kapanır.
## Satın alınan geliştirme oyun boyunca kalır (FieldWorld.upgrades).

signal bought(id: String)

const PAPER_THEME: Theme = preload("res://assets/ui/paper_theme.tres")
const SFX_CLICK: AudioStream = preload("res://assets/audio/sfx/click_001.wav")
## id, ad anahtarı, açıklama anahtarı, fiyat (Kasa)
const ITEMS := [
	{"id": "mask", "name": "UP_MASK", "desc": "UP_MASK_DESC", "price": 30},
	{"id": "boots", "name": "UP_BOOTS", "desc": "UP_BOOTS_DESC", "price": 40},
	{"id": "bucket", "name": "UP_BUCKET", "desc": "UP_BUCKET_DESC", "price": 25},
	{"id": "nursery", "name": "UP_NURSERY", "desc": "UP_NURSERY_DESC", "price": 60},
]

var is_open := false
var owned: Dictionary = {}

var _panel: PanelContainer
var _rows: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_panel = PanelContainer.new()
	_panel.theme = PAPER_THEME
	_panel.size = Vector2(760, 420)
	_panel.position = Vector2(260, 130)
	add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_panel.add_child(box)
	var title := Label.new()
	title.text = "SHOP_TITLE"
	title.add_theme_font_override("font", load("res://assets/fonts/Anton.ttf"))
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.55, 0.32, 0.1))
	box.add_child(title)
	for i in ITEMS.size():
		var item: Dictionary = ITEMS[i]
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.add_theme_font_size_override("font_size", 21)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_buy.bind(i))
		box.add_child(button)
		_rows.append({"button": button, "item": item})
	var hint := Label.new()
	hint.text = "SHOP_HINT"
	hint.add_theme_font_size_override("font_size", 17)
	hint.modulate = Color(1, 1, 1, 0.7)
	box.add_child(hint)


func open(money: float) -> void:
	is_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	refresh(money)
	UiFx.pop_in(_panel)


func close() -> void:
	is_open = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func refresh(money: float) -> void:
	for i in _rows.size():
		var item: Dictionary = _rows[i]["item"]
		var button: Button = _rows[i]["button"]
		var has: bool = owned.get(item["id"], false)
		var suffix := tr("SHOP_OWNED") if has else "%d" % item["price"]
		button.text = "%d.  %s  -  %s   [%s]" % [i + 1, tr(item["name"]), tr(item["desc"]), suffix]
		button.disabled = has or money <= float(item["price"])


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: _buy(0)
			KEY_2: _buy(1)
			KEY_3: _buy(2)
			KEY_4: _buy(3)
			KEY_U, KEY_ESCAPE:
				close()
		get_viewport().set_input_as_handled()


func _buy(index: int) -> void:
	var item: Dictionary = ITEMS[index]
	if owned.get(item["id"], false):
		return
	if GameState.money <= float(item["price"]):
		return
	owned[item["id"]] = true
	GameState.change_stat(&"money", -float(item["price"]))
	AudioManager.play_sfx(SFX_CLICK)
	bought.emit(item["id"])
	refresh(GameState.money)
