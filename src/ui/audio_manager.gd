extends Node

@onready var ui_player: AudioStreamPlayer2D   = $UiPlayer
@onready var sfx_player: AudioStreamPlayer2D  = $SFXPlayer
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer

# ========== Audio Dict ==========
var ui_sfx: Dictionary = {
	"click": preload("res://assets/sfx/ui_menu_button_click_01.wav"),
	"hover": preload("res://assets/sfx/Hover1.mp3"),
}

var game_sfx: Dictionary = {
	"jump": preload("res://assets/sfx/RETRO Jump Up Short 12.wav"),
	"hit": preload("res://assets/sfx/RETRO Bump Hit Impact Short 01.wav"),
	"pickup": preload("res://assets/sfx/retro_collect_pickup_item_02.wav"),
}

var music_library: Dictionary = {
	"menu":    preload("res://assets/music/Waves On Rocks Medium Loop A.wav"),
	"light": preload("res://assets/music/SL_Light_Ambient_Am_090bpm_01.wav"),
	"dark": preload("res://assets/music/SL_Dark_Ambient_Am_090bpm_01.wav"),
	"Atmo_Guitar_A":   preload("res://assets/music/SL_Atmospheric_Guitar_0080BPM_A_01.wav"),
	"Atmo_Guitar_C": preload("res://assets/music/SL_Atmospheric_Guitar_0080BPM_C_05.wav"),
	"Atmo_Guitar_D":preload("res://assets/music/SL_Atmospheric_Guitar_0080BPM_D_10.wav"),
	"Atmo_Guitar_Dminor":preload("res://assets/music/SL_Atmospheric_Guitar_080BPM_DMinor_12.wav"),
	"Melo_Guitar_A":preload("res://assets/music/SL_Melodic_Guitar_080BPM_A_002.wav"),
	"Melo_Guitar_C":preload("res://assets/music/SL_Melodic_Guitar_080BPM_C_007.wav"),
	"Melo_Guitar_D":preload("res://assets/music/SL_Melodic_Guitar_080BPM_D_011.wav"),
	"Melo_Guitar_Dminor":preload("res://assets/music/SL_Melodic_Guitar_080BPM_DMinor_012.wav"),
	"Synth_Keys_A":preload("res://assets/music/SL_Synth_Keys_080BPM_A_SunBea.wav"),
	"Synth_Keys_C":preload("res://assets/music/SL_Synth_Keys_080BPM_C_QuietTi.wav"),
	"Synth_Keys_Dminor":preload("res://assets/music/SL_Synth_Keys_080BPM_DMinor_RunTheKe.wav"),
}

var _current_music_name: String = ""
var _fade_tween: Tween

# ========== UI SFX ==========

func play_ui(name: String) -> void:
	var stream: AudioStream = ui_sfx.get(name, null)
	if stream == null:
		push_warning("UI sfx '%s' not found" % name)
		return

	ui_player.stream = stream
	if ui_player.playing:
		ui_player.stop()
	ui_player.play()

func play_ui_click() -> void:
	play_ui("click")

func play_ui_hover() -> void:
	play_ui("hover")


# ========== SFX ==========

func play_sfx(name: String) -> void:
	var stream: AudioStream = game_sfx.get(name, null)
	if stream == null:
		push_warning("Game sfx '%s' not found" % name)
		return

	sfx_player.stream = stream
	if sfx_player.playing:
		sfx_player.stop()
	sfx_player.play()


# ========== BGM ==========

func play_music(name: String, fade_time: float = 0.5) -> void:
	if name == _current_music_name:
		return

	var stream: AudioStream = music_library.get(name, null)
	if stream == null:
		push_warning("Music track '%s' not found" % name)
		return

	_current_music_name = name

	if _fade_tween:
		_fade_tween.kill()

	# Fade Out
	if music_player.playing and fade_time > 0.0:
		_fade_tween = create_tween()
		_fade_tween.tween_property(music_player, "volume_db", -20.0, fade_time * 0.5)
		_fade_tween.tween_callback(func():
			_switch_music(stream, fade_time * 0.5)
		)
	else:
		_switch_music(stream, fade_time)

func _switch_music(stream: AudioStream, fade_in_time: float) -> void:
	music_player.stream = stream
	music_player.play()

	if fade_in_time > 0.0:
		music_player.volume_db = -20.0
		_fade_tween = create_tween()
		_fade_tween.tween_property(music_player, "volume_db", 0.0, fade_in_time)
	else:
		music_player.volume_db = 0.0

func stop_music(fade_time: float = 0.5) -> void:
	if not music_player.playing:
		return

	if _fade_tween:
		_fade_tween.kill()

	if fade_time > 0.0:
		_fade_tween = create_tween()
		_fade_tween.tween_property(music_player, "volume_db", -20.0, fade_time)
		_fade_tween.tween_callback(func():
			music_player.stop()
			music_player.volume_db = 0.0
		)
	else:
		music_player.stop()
		music_player.volume_db = 0.0


# ========== TODO：Volume Setting ==========


func apply_volume(master: float, music: float, sfx: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx)
	)
