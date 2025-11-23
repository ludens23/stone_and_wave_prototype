extends Node2D


@onready var btn_new_game: Button = $Control/MarginContainer/VBoxContainer/NewGameButton
@onready var btn_endless: Button = $Control/MarginContainer/VBoxContainer/EndlessButton
@onready var btn_settings: Button = $Control/MarginContainer/VBoxContainer/SettingsButton
@onready var label_high_score: Label = $Control/MarginContainer/VBoxContainer/HighScoreLabel
#@onready var settings_window: Window = %SettingsWindow

func _ready() -> void:
	label_high_score.text = "High Score: %d" % SaveData.high_score

	btn_endless.disabled = not SaveData.endless_unlocked
	if btn_endless.disabled:
		btn_endless.text = "Endless Mode (Locked)"
	else:
		btn_endless.text = "Endless Mode"

	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_endless.pressed.connect(_on_endless_pressed)
	#btn_settings.pressed.connect(_on_settings_pressed)

	btn_new_game.mouse_entered.connect(_on_button_hovered)
	btn_endless.mouse_entered.connect(_on_button_hovered)
	#btn_settings.mouse_entered.connect(_on_button_hovered)

	btn_new_game.focus_entered.connect(_on_button_hovered)
	btn_endless.focus_entered.connect(_on_button_hovered)
	#btn_settings.focus_entered.connect(_on_button_hovered)

	AudioManager.play_music("menu")

func _on_button_hovered() -> void:
	AudioManager.play_ui_hover()
	
func _on_new_game_pressed() -> void:
	AudioManager.play_ui_click()
	AudioManager.play_music("light", 1.0)
	get_tree().change_scene_to_file("res://src/level/Story.tscn")

func _on_endless_pressed() -> void:
	if SaveData.endless_unlocked:
		AudioManager.play_ui_click()
		AudioManager.play_music("dark", 1.0)
		get_tree().change_scene_to_file("res://src/level/Endless.tscn")

#func _on_settings_pressed() -> void:
	#settings_window.popup_centered()
