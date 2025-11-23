extends CharacterBody2D

signal energy_changed(current_value: float, max_energy: float, overcharge_limit: float)
signal state_changed(state: int)

enum State { PARTICLE, WAVE, REASSEMBLING }
enum ParticleForm { STONE, HIGH_ENERGY }

@export var PARTICLE_SPEED: float = 300.0
@export var WAVE_SPEED: float = 300.0
@export var MAX_ENERGY: float = 100.0
@export var OVERCHARGE_LIMIT: float = 150.0
@export var HIGH_ENERGY_COLLISION_COST: float = 50.0
@export var MAX_HIGH_ENERGY_PROBABILITY: float = 0.95
@export var WAVE_ENERGY_DRAIN: float = 20.0
@export_group("Wave Visuals")
@export var WAVE_MAX_AMPLITUDE: float = 40.0
@export var WAVE_CYCLES: float = 3.0
@export var WAVE_LENGTH: float = 120.0
@export var WAVE_POINTS: int = 50
@export var WAVE_VERTICAL_SPEED: float = 200.0
@export_group("Particle Forms")
@export var stone_particle_color: Color = Color("#4C7EB5")
@export var high_energy_particle_color: Color = Color("#F38069")
@export var REBOUND_SPEED_MULTIPLIER: float = 0.5

var current_energy: float = 0.0
var current_state: State = State.PARTICLE
var current_particle_form: ParticleForm = ParticleForm.STONE
var wave_base_points: PackedVector2Array = PackedVector2Array()
var _is_in_wall_drain_zone: bool = false
var _current_wall_drain: float = 0.0
var _is_in_recharge_zone: bool = false
var _current_recharge_rate: float = 0.0

@onready var particle_visual: ColorRect = $ParticleVisual
@onready var wave_visual: Line2D = $WaveVisual
@onready var particle_collider: CollisionShape2D = $ParticleCollider
@onready var wave_sensor: Area2D = $WaveSensor
@onready var reassemble_timer: Timer = $ReassembleTimer
@onready var fx_player: AnimationPlayer = $FXPlayer

func _ready() -> void:
	await get_tree().create_timer(0.0).timeout
	randomize()
	particle_visual.modulate = Color(1, 1, 1, 1)
	_set_particle_color(stone_particle_color)
	_generate_base_wave()
	current_energy = MAX_ENERGY
	current_state = State.PARTICLE
	energy_changed.emit(current_energy, MAX_ENERGY, OVERCHARGE_LIMIT)
	state_changed.emit(current_state)

func _generate_base_wave() -> void:
	wave_base_points.clear()
	if WAVE_POINTS <= 1:
		wave_visual.points = PackedVector2Array()
		wave_visual.hide()
		return

	for i in range(WAVE_POINTS):
		var t := float(i) / float(WAVE_POINTS - 1)
		var x := t * WAVE_LENGTH
		var y := sin(t * WAVE_CYCLES * TAU)
		wave_base_points.append(Vector2(x, y))

	wave_visual.points = wave_base_points.duplicate()
	wave_visual.position = Vector2(-WAVE_LENGTH / 2.0, 0.0)
	wave_visual.hide()

func _update_wave_visuals() -> void:
	if wave_base_points.is_empty():
		return
	var energy_ratio: float = clamp(current_energy / MAX_ENERGY, 0.0, 1.0)
	var current_amplitude: float = energy_ratio * WAVE_MAX_AMPLITUDE
	var points := wave_visual.points
	if points.size() != wave_base_points.size():
		points = wave_base_points.duplicate()
	for i in range(wave_base_points.size()):
		var base_point := wave_base_points[i]
		points[i] = Vector2(base_point.x, base_point.y * current_amplitude)
	wave_visual.points = points

func _set_particle_color(color: Color) -> void:
	var shader_material := particle_visual.material
	if shader_material is ShaderMaterial:
		(shader_material as ShaderMaterial).set_shader_parameter("circle_color", color)

func _calculate_high_energy_probability() -> float:
	var probability: float = 0.0
	if current_energy >= MAX_ENERGY and current_energy<= OVERCHARGE_LIMIT - 30:
		probability =  0.6
	elif current_energy > OVERCHARGE_LIMIT - 30:
		probability = 0.9
	
	return probability
func _set_particle_form_stone() -> void:
	current_particle_form = ParticleForm.STONE
	velocity.x = abs(velocity.x)
	_set_particle_color(stone_particle_color)
	
func _set_particle_form_high_energy() -> void:
	current_particle_form = ParticleForm.HIGH_ENERGY
	_set_particle_color(high_energy_particle_color)
	
func _collapse_wave_function() -> void:
	var probability_high_energy := _calculate_high_energy_probability()
	var roll := randf()
	if roll <= probability_high_energy:
		_set_particle_form_high_energy()
	else:
		_set_particle_form_stone()

func handle_input() -> void:
	var old_state := current_state
	if Input.is_action_pressed("transform"):
		current_state = State.WAVE
	else:
		current_state = State.PARTICLE
	if old_state != current_state:
		state_changed.emit(current_state)
		if current_state == State.PARTICLE:
			_collapse_wave_function()

func _process(delta: float) -> void:
	if current_state == State.REASSEMBLING:
		return
	if current_state == State.PARTICLE and _is_in_recharge_zone:
		current_energy += _current_recharge_rate * delta
		current_energy = clamp(current_energy, 0.0, OVERCHARGE_LIMIT)
		energy_changed.emit(current_energy, MAX_ENERGY, OVERCHARGE_LIMIT)
	handle_input()
	if current_state == State.WAVE:
		var total_drain := WAVE_ENERGY_DRAIN
		if _is_in_wall_drain_zone:
			total_drain += _current_wall_drain
		current_energy -= total_drain * delta
		energy_changed.emit(current_energy, MAX_ENERGY, OVERCHARGE_LIMIT)
		_update_wave_visuals()

func _physics_process(delta: float) -> void:
	if current_state == State.PARTICLE:
		particle_visual.show()
		wave_visual.hide()
		particle_collider.disabled = false
		if wave_visual and wave_visual.get_point_count() > 0:
			wave_visual.clear_points()
	elif current_state == State.WAVE:
		particle_visual.hide()
		wave_visual.show()
		particle_collider.disabled = true
		_update_wave_visuals()
	elif current_state == State.REASSEMBLING:
		particle_visual.show()
		wave_visual.hide()
		particle_collider.disabled = true
	wave_sensor.monitoring = true
	var horizontal_speed := PARTICLE_SPEED
	if current_state == State.WAVE:
		horizontal_speed = WAVE_SPEED
	elif current_state == State.REASSEMBLING:
		horizontal_speed = velocity.x
	velocity.x = horizontal_speed
	if current_state == State.WAVE:
		var input_dir_y := Input.get_axis("move_up", "move_down")
		velocity.y = input_dir_y * WAVE_VERTICAL_SPEED
	else:
		velocity.y = 0.0 # GDD: Particle has no vertical control
	move_and_slide()
	var collision: KinematicCollision2D = null
	if get_slide_collision_count() > 0:
		collision = get_slide_collision(get_slide_collision_count() - 1)

	if collision and current_state == State.PARTICLE:
		var collider: Object = collision.get_collider()
		if collider and collider.is_in_group("wall"):
			if current_particle_form == ParticleForm.STONE:
				current_energy = 0.0
			elif current_particle_form == ParticleForm.HIGH_ENERGY:
				current_energy -= HIGH_ENERGY_COLLISION_COST
				current_energy = max(current_energy, 0.0)
				current_state = State.REASSEMBLING
				velocity.x = -PARTICLE_SPEED * REBOUND_SPEED_MULTIPLIER
				reassemble_timer.start()
				fx_player.play("Blink")
			energy_changed.emit(current_energy, MAX_ENERGY, OVERCHARGE_LIMIT)

func _on_wave_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall_drain_zone"):
		var wall_root := area.get_parent()
		if wall_root and "wall_drain_cost" in wall_root:
			_is_in_wall_drain_zone = true
			var drain_cost: Variant = wall_root.get("wall_drain_cost")
			if drain_cost != null:
				_current_wall_drain = float(drain_cost)

	if area.is_in_group("enabler"):
		if "RECHARGE_RATE" in area:
			_is_in_recharge_zone = true
			var recharge_rate: Variant = area.get("RECHARGE_RATE")
			if recharge_rate != null:
				_current_recharge_rate = float(recharge_rate)

func _on_wave_sensor_area_exited(area: Area2D) -> void:
	if area.is_in_group("wall_drain_zone"):
		_is_in_wall_drain_zone = false
		_current_wall_drain = 0.0

	if area.is_in_group("enabler"):
		_is_in_recharge_zone = false
		_current_recharge_rate = 0.0

func _on_reassemble_timer_timeout() -> void:
	_set_particle_form_stone()
	current_state = State.PARTICLE
	fx_player.stop()
	particle_visual.modulate = Color(1, 1, 1, 1)
