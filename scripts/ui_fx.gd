class_name UiFx
extends RefCounted
## Arayüz hareketleri: butonlar üzerine gelince büyür, basınca ezilir, paneller zıplayarak açılır.

const HOVER_SOUND: AudioStream = preload("res://assets/audio/sfx/click_003.wav")


## Butonu "canlı" yapar: hover büyüme, basma ezilmesi, hover sesi.
static func juicy(button: Control, with_sound: bool = true) -> void:
	button.resized.connect(func() -> void: button.pivot_offset = button.size / 2.0)
	button.mouse_entered.connect(func() -> void:
		_scale_to(button, 1.05, 0.14)
		if with_sound and not (button is BaseButton and button.disabled):
			AudioManager.play_sfx(HOVER_SOUND, 0.08))
	button.mouse_exited.connect(func() -> void: _scale_to(button, 1.0, 0.14))
	if button is BaseButton:
		button.button_down.connect(func() -> void: _scale_to(button, 0.95, 0.06))
		button.button_up.connect(func() -> void: _scale_to(button, 1.05, 0.14))


## Paneli küçükten büyüterek ve belirginleştirerek açar.
static func pop_in(node: Control, delay: float = 0.0) -> void:
	var extent := node.size if node.size != Vector2.ZERO else node.get_combined_minimum_size()
	node.pivot_offset = extent / 2.0
	node.scale = Vector2(0.88, 0.88)
	node.modulate.a = 0.0
	var tween := node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, 0.35).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 1.0, 0.2).set_delay(delay)


## Anlık "pıt" vurgusu: değer değişince çip bir an büyür.
static func punch(node: Control, amount: float = 1.12) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2(amount, amount)
	node.create_tween().tween_property(node, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func _scale_to(node: Control, target: float, duration: float) -> void:
	node.create_tween().tween_property(node, "scale", Vector2(target, target), duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
