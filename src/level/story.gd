extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UI
@onready var game_over_screen: CanvasLayer = $GameOver

func _ready() -> void:
	game_over_screen.hide()
	player.energy_changed.connect(_on_player_energy_changed)
	game_over_screen.restart_game.connect(_on_game_over_restart_game)

func _on_player_energy_changed(current_value: float, max_energy: float, overcharge_limit: float) -> void:
	if current_value <= 0.0:
		get_tree().paused = true
		var final_score :float = ui.get_survival_time()
		game_over_screen.show_game_over(final_score)

func _on_game_over_restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
