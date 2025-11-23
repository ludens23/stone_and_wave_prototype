extends Node2D

@export var wall_scene: PackedScene
@export var beam_scene: PackedScene
@export var player: Node2D

# Configuration for procedural generation
var next_spawn_x: float = 1000.0
var spawn_distance: float = 1500.0
var pattern_queue: Array = [] # Stores manual commands

func _process(delta: float) -> void:
	if player == null:
		return
	
	# Check if we need to spawn a new object based on player position
	if player.global_position.x + spawn_distance > next_spawn_x:
		spawn_next_object()

func spawn_next_object() -> void:
	var cmd: Dictionary = {}
	
	# Priority 1: Check if there are manual patterns in the queue
	if not pattern_queue.is_empty():
		cmd = pattern_queue.pop_front()
	else:
		# Priority 2: Fallback to procedural random generation
		cmd = _generate_random_command()

	if cmd.is_empty():
		return

	# Dispatch based on type
	var obj_type: String = cmd.get("type", "wall")
	
	if obj_type == "wall":
		_spawn_wall(cmd)
	elif obj_type == "beam":
		_spawn_beam(cmd)

func _spawn_wall(cmd: Dictionary) -> void:
	if wall_scene == null: return
	
	# Extract parameters with default fallbacks
	var width := float(cmd.get("width", randf_range(50.0, 150.0)))
	var height := float(cmd.get("height", 400.0))
	var gap := float(cmd.get("gap", randf_range(200.0, 400.0)))
	var screen_center_y = get_viewport_rect().size.y / 2.0
	var y_pos := float(cmd.get("y", screen_center_y))
	var is_absorption := bool(cmd.get("absorption", false))

	var wall = wall_scene.instantiate()
	add_child(wall)
	
	wall.global_position = Vector2(next_spawn_x, y_pos)
	
	# Determine Wall Type properties
	var color := Color.WHITE
	var drain_cost := 25.0
	
	if is_absorption:
		# Absorption Wall: Deep Purple, High Cost
		color = Color("#660066") 
		drain_cost = 100.0
	else:
		# Normal Wall: Random Gray scale, Standard Cost
		var gray_val = randf_range(0.5, 0.9)
		color = Color(gray_val, gray_val, gray_val)
		drain_cost = 25.0
	
	# Apply configuration
	if wall.has_method("setup"):
		wall.setup(width, height, color, drain_cost)

	next_spawn_x += width + gap

func _spawn_beam(cmd: Dictionary) -> void:
	if beam_scene == null: return
	
	var width := float(cmd.get("width", randf_range(100.0, 300.0)))
	var height := float(cmd.get("height", 400.0))
	var gap := float(cmd.get("gap", randf_range(200.0, 400.0)))
	var screen_center_y = get_viewport_rect().size.y / 2.0
	var y_pos := float(cmd.get("y", screen_center_y))

	var beam = beam_scene.instantiate()
	add_child(beam)
	
	beam.global_position = Vector2(next_spawn_x, y_pos)
	
	if beam.has_method("setup"):
		beam.setup(width, height, y_pos)

	next_spawn_x += width + gap

func _generate_random_command() -> Dictionary:
	var roll := randf()
	# 70% chance for Wall, 30% chance for Beam
	if roll < 0.7:
		# 30% chance for the wall to be an Absorption Wall
		var is_absorption := randf() < 0.3
		return {
			"type": "wall",
			"width": randf_range(50.0, 150.0),
			"gap": randf_range(300.0, 500.0),
			"absorption": is_absorption
		}
	else:
		return {
			"type": "beam",
			"width": randf_range(100.0, 300.0),
			"gap": randf_range(200.0, 400.0)
		}

# API for external scripts (e.g., Main.gd) to inject manual patterns
func add_manual_pattern(pattern_array: Array) -> void:
	for cmd in pattern_array:
		pattern_queue.push_back(cmd)
