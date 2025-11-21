extends StaticBody2D

# Default drain cost (Normal Wall).
# This variable is accessed by the Player script when colliding with the DrainZone.
@export var wall_drain_cost: float = 25.0

@onready var color_rect: ColorRect = $ColorRect
@onready var physical_collider: CollisionShape2D = $PhysicalCollider
# Use get_node_or_null to be safe, but assuming the structure is fixed
@onready var drain_collider: CollisionShape2D = $DrainZone/DrainCollider

# Setup function called by the LevelGenerator
func setup(width: float, height: float, color: Color, cost: float) -> void:
	# 1. Update Visuals
	if color_rect:
		color_rect.size = Vector2(width, height)
		color_rect.position = Vector2(-width / 2.0, -height / 2.0)
		color_rect.color = color
	
	# 2. Update Physics Collider (Solid part)
	if physical_collider and physical_collider.shape is RectangleShape2D:
		(physical_collider.shape as RectangleShape2D).size = Vector2(width, height)
		
	# 3. Update Drain Zone Collider (Area detection part)
	if drain_collider and drain_collider.shape is RectangleShape2D:
		(drain_collider.shape as RectangleShape2D).size = Vector2(width, height)
		
	# 4. Update Logic (Energy Drain)
	wall_drain_cost = cost

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Auto-destroy when leaving the screen
	queue_free()
