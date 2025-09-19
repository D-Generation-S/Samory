extends CanvasLayer

signal settings_loaded(settings: SettingsResource)

var initial_settings: SettingsResource;
@export var accept_button: Button
@export var close_button: Button

@onready var current_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_settings = SettingsRepository.load_settings()
	current_settings = initial_settings.duplicate_deep()
	settings_loaded.emit(initial_settings)

func reset_settings():
	settings_loaded.emit(initial_settings)
	close_window(close_button)

func reset_tutorial():
	current_settings.tutorials = {}
	current_settings.tutorial_aborted = false
	current_settings.auto_close_popup_shown = false

func save_settings():
	current_settings.vsync_active = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

	if !SettingsRepository.save_settings(current_settings):
		reset_settings()
	
	if !initial_settings.load_custom_decks and current_settings.load_custom_decks:
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

func window_mode_changed(new_mode: DisplayServer.WindowMode):
	current_settings.window_mode = new_mode

func close_window(calling_button: Button):
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(calling_button.get_global_center_position())

func auto_complete_round_changed(toggled: bool):
	current_settings.auto_close_round = toggled

func time_for_completion_changed(new_time: float):
	current_settings.close_round_after_seconds = new_time
