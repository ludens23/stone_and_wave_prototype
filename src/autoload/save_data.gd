extends Node

var story_cleared: bool = false
var endless_unlocked: bool = false
var high_score: int = 0

var settings := {
	"fullscreen": false,
	"resolution": Vector2i(1280, 720),
	"master_volume": 0.8,
	"sfx_volume": 0.8,
	"debug_mode":true,
}

const SAVE_PATH := "user://save.cfg"

func _ready() -> void:
	load_game()

func unlock_endless():
	story_cleared = true
	endless_unlocked = true
	save_game()

func set_high_score(score: int) -> void:
	if score > high_score:
		high_score = score
		save_game()

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "story_cleared", story_cleared)
	cfg.set_value("progress", "endless_unlocked", endless_unlocked)
	cfg.set_value("progress", "high_score", high_score)

	cfg.set_value("settings", "fullscreen", settings.fullscreen)
	cfg.set_value("settings", "resolution", settings.resolution)
	cfg.set_value("settings", "master_volume", settings.master_volume)
	cfg.set_value("settings", "sfx_volume", settings.sfx_volume)
	cfg.set_value("settings", "debug_mode", settings.debug_mode)

	cfg.save(SAVE_PATH)

func load_game() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return 

	story_cleared = cfg.get_value("progress", "story_cleared", false)
	endless_unlocked = cfg.get_value("progress", "endless_unlocked", story_cleared)
	high_score = cfg.get_value("progress", "high_score", 0)

	settings.fullscreen = cfg.get_value("settings", "fullscreen", false)
	settings.resolution = cfg.get_value("settings", "resolution", Vector2i(1280, 720))
	settings.master_volume = cfg.get_value("settings", "master_volume", 0.8)
	settings.sfx_volume = cfg.get_value("settings", "sfx_volume", 0.8)
	settings.debug_mode = cfg.get_value("settings", "debug_mode", true)
