extends CanvasLayer

var survival_time: float = 0.0

@onready var energy_bar: ProgressBar = $EnergyBar
@onready var form_indicator: Label = $FormIndicator
@onready var score_label: Label = $ScoreLabel
var _energy_bar_fill_style: StyleBoxFlat
var _default_fill_color: Color

func _ready() -> void:
	var style_box := energy_bar.get_theme_stylebox("fill")
	if style_box is StyleBoxFlat:
		_energy_bar_fill_style = style_box.duplicate()
		_default_fill_color = _energy_bar_fill_style.bg_color
		energy_bar.add_theme_stylebox_override("fill", _energy_bar_fill_style)
	else:
		push_warning("EnergyBar 'fill' style is not a StyleBoxFlat. Cannot change color.")

func _process(delta: float) -> void:
	survival_time += delta
	score_label.text = "Score: %.2f" % survival_time

func get_survival_time() -> float:
	return survival_time

func update_energy_bar(current_value: float, max_energy: float, overcharge_limit: float) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = clamp(current_value, 0.0, max_energy)
	if _energy_bar_fill_style == null:
		return
	if current_value > max_energy:
		_energy_bar_fill_style.bg_color = Color("#F38069")
	else:
		_energy_bar_fill_style.bg_color = _default_fill_color

func update_form_label(state: int) -> void:
	if state == 0:
		form_indicator.text = "Particle"
	else:
		form_indicator.text = "Wave"
