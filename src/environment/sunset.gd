extends Node2D

@onready var color_rect: ColorRect = $ColorRect

@export var day_cycle_duration: float = 60.0

@export var top_color_gradient: Gradient
@export var bottom_color_gradient: Gradient

var current_time: float = 0.0

func _process(delta: float) -> void:
	current_time += delta
	
	if current_time > day_cycle_duration:
		current_time = 0.0 # 或者 current_time -= day_cycle_duration
	

	var time_ratio = current_time / day_cycle_duration
	
	update_sky_shader(time_ratio)

func update_sky_shader(ratio: float):
	var material:ShaderMaterial = color_rect.material 
	if material and top_color_gradient and bottom_color_gradient:
		var top = top_color_gradient.sample(ratio)
		var bottom = bottom_color_gradient.sample(ratio)
		
		material.set_shader_parameter("top_color", top)
		material.set_shader_parameter("bottom_color", bottom)

func get_game_hour() -> int:
	var ratio = current_time / day_cycle_duration
	return int(ratio * 24.0)
