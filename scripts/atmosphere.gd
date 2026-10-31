class_name Atmosphere
extends CanvasLayer
## Genel atmosfer filtresi (Eco / Frostpunk tarzı). Çevre düşükken tüm oyun gri, puslu, sarımsı ve soluk;
## yükseldikçe yumuşakça canlı, doygun bir gün ışığına döner. Geçiş lerp ile akar.
## Dünya, sabah masası ve akşam ekranı filtrelenir. HUD ve saha arayüzü (üst katmanlar) etkilenmez.

const SMOOTHING := 1.6

const SHADER_CODE := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float pollution = 0.7;  // 0 = tertemiz, 1 = zehir
uniform float dusk = 0.0;       // 0 = öğle, 1 = gün batımı sonrası

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	float p = pollution;

	// Renkler solar, sarımsı-kahverengi bir pus çöker
	vec3 col = mix(c, vec3(luma), p * 0.72);
	col *= mix(vec3(1.0), vec3(1.06, 0.93, 0.7), p);
	// Kontrast düşer, siyahlar kalkar: sis
	col = mix(col, vec3(0.6, 0.55, 0.46), p * 0.2);
	// Ağır, yavaş dalgalanan duman bantları
	float fog = 0.5 + 0.5 * sin(SCREEN_UV.x * 3.0 + TIME * 0.18) * sin(SCREEN_UV.y * 4.0 - TIME * 0.12);
	col = mix(col, vec3(0.58, 0.52, 0.42), p * 0.13 * fog);
	// Kenarlar kararır
	vec2 uv = SCREEN_UV - 0.5;
	float v = smoothstep(0.3, 0.95, length(uv * vec2(1.15, 1.0)));
	col *= 1.0 - v * (0.1 + 0.55 * p);

	// Temizken: canlı, doygun, sıcak gün ışığı
	float clean = 1.0 - p;
	vec3 vivid = mix(vec3(luma), col, 1.0 + 0.3 * clean);
	vivid *= vec3(1.03, 1.02, 0.98);
	col = mix(col, vivid, clean * clean);

	// Gün batımı: sıcak turuncu ışık, sonra mavimsi alacakaranlık ve kararma
	float d = dusk;
	vec3 sunset = col * vec3(1.12, 0.82, 0.62);
	vec3 night = col * vec3(0.55, 0.6, 0.85);
	col = mix(col, sunset, smoothstep(0.0, 0.55, d));
	col = mix(col, night, smoothstep(0.55, 1.0, d));
	col *= 1.0 - 0.3 * d;
	COLOR = vec4(col, 1.0);
}
"""

var _material := ShaderMaterial.new()
var _current := 0.7
var _target := 0.7
var _dusk := 0.0
## >= 0 ise kirlilik bu değere zorlanır (outro/intro sinematikleri). -1: Çevre'ye göre.
var override_pollution := -1.0


func _ready() -> void:
	layer = 4
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material.shader = shader
	var rect := ColorRect.new()
	rect.material = _material
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	GameState.stats_changed.connect(_update_target)
	_update_target()
	_current = _target
	_material.set_shader_parameter("pollution", _current)


func _process(delta: float) -> void:
	_current = lerpf(_current, _target, 1.0 - exp(-SMOOTHING * delta))
	_material.set_shader_parameter("pollution", _current)
	# Gün ilerledikçe (stamina azaldıkça) akşama dönüşür. Son çeyrekte belirginleşir.
	var target_dusk := clampf(1.0 - GameState.day_progress, 0.0, 1.0)
	_dusk = lerpf(_dusk, pow(target_dusk, 1.4) * 0.85, 1.0 - exp(-2.0 * delta))
	_material.set_shader_parameter("dusk", _dusk)


func _update_target() -> void:
	if override_pollution >= 0.0:
		_target = override_pollution
		return
	var clean := clampf(GameState.nature / GameState.STAT_MAX, 0.0, 1.0)
	_target = pow(1.0 - clean, 0.85)
