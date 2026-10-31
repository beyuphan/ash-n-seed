extends CanvasModulate
## Çevre değerine göre ekran rengini yumuşakça değiştirir: düşükken gri-sarımsı pus, yüksekken canlı gün ışığı.
## Yalnızca World (CanvasLayer 0) tint'lenir; HUD ayrı CanvasLayer'da olduğu için etkilenmez.

const POLLUTED := Color(0.86, 0.82, 0.74)  # asıl pus Atmosphere filtresinde, burası sadece hafif kararma
const CLEAN := Color(1.0, 1.0, 1.0)
const SMOOTHING := 2.0

var _target := POLLUTED


func _ready() -> void:
	GameState.stats_changed.connect(_update_target)
	_update_target()
	color = _target


func _process(delta: float) -> void:
	color = color.lerp(_target, 1.0 - exp(-SMOOTHING * delta))


func _update_target() -> void:
	var t := clampf(GameState.nature / GameState.STAT_MAX, 0.0, 1.0)
	_target = POLLUTED.lerp(CLEAN, t)
