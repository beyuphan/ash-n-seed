class_name CameraShake
extends Camera2D
## Kamera: oyuncuyu yumuşakça takip eder, shake() ile kısa süre hafifçe titrer.

var _strength := 0.0
var _duration := 0.01
var _time_left := 0.0


## strength: piksel cinsinden en büyük kayma (dünya biriminde), duration: saniye.
func shake(strength: float, duration: float) -> void:
	_strength = maxf(_strength * (_time_left / _duration), strength)
	_duration = maxf(duration, 0.01)
	_time_left = duration


func _process(delta: float) -> void:
	if _time_left > 0.0:
		_time_left -= delta
		var falloff := clampf(_time_left / _duration, 0.0, 1.0)
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _strength * falloff
	else:
		offset = Vector2.ZERO
		_strength = 0.0
