extends CanvasLayer

signal restart_game

@onready var result_label: Label = $VBoxContainer/ResultLabel

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	restart_game.emit()

func show_game_over(final_score: float) -> void:
	result_label.text = "Final Score: %.2f" % final_score
	show()
