extends Area2D

@export var RECHARGE_RATE: float = 15.0

@onready var color_rect: ColorRect = $ColorRect
@onready var collider: CollisionShape2D = $CollisionShape2D

func setup(width: float, height: float, y_pos: float) -> void:
	color_rect.size = Vector2(width, height)
	color_rect.position = Vector2(-width / 2.0, -height / 2.0)
	if collider.shape and collider.shape is RectangleShape2D:
		(collider.shape as RectangleShape2D).size = Vector2(width, height)
	position.y = y_pos

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
