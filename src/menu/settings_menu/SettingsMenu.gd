extends CanvasLayer

signal settings_loaded(settings: SettingsResource)

var inital_settings: SettingsResource;
@export var accept_button: Button
@export var close_button: Button

@onready var current_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	inital_settings = SettingsRepository.load_settings()
	current_settings = inital_settings.duplicate()
	settings_loaded.emit(inital_settings)

func reset_settings():
	settings_loaded.emit(inital_settings)
	close_window(close_button)

func save_settings():
	var window_mode = DisplayServer.window_get_mode()
	current_settings.fullscreen = false
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		current_settings.fullscreen = true

	current_settings.vsync_active = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

	if !SettingsRepository.save_settings(current_settings):
		reset_settings()
	
	if !inital_settings.load_custom_decks and current_settings.load_custom_decks:
		GlobalGameManagerAccess.get_game_manager().reload_system_decks()
		return
	
	if !current_settings.load_custom_decks:
		GlobalSystemDeckManager.clear_system_decks()
	close_window(accept_button)

func volume_changed(bus_name: int, new_volume: float):
	match bus_name:
		BusType.Master:
			current_settings.master_volume = new_volume
		BusType.Effect:
			current_settings.effect_volume = new_volume
		BusType.Music:
			current_settings.music_volume = new_volume

func language_changed(new_language_code: String):
	current_settings.language_code = new_language_code

func load_custom_deck_changed(toggled: bool):
	current_settings.load_custom_decks = toggled

func close_window(calling_button: Button):
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(calling_button.get_global_center_position())

func auto_complete_round_changed(toggled: bool):
	current_settings.auto_close_round = toggled

func time_for_completion_changed(new_time: float):
	current_settings.close_round_after_seconds = new_time
