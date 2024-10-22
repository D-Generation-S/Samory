extends CanvasLayer

signal settings_loaded(settings: SettingsResource)

var inital_settings: SettingsResource;
@onready var current_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	inital_settings = SettingsRepository.load_settings()
	current_settings = inital_settings.duplicate()
	settings_loaded.emit(inital_settings)

func reset_settings():
	settings_loaded.emit(inital_settings)
	close_window()

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
	close_window()

func volume_changed(bus_name: int, new_volume: float):
	match bus_name:
		BusType.Master:
			current_settings.master_volume = new_volume
		BusType.Effect:
			current_settings.effect_volume = new_volume
		BusType.Music:
			current_settings.music_volume = new_volume

func load_custom_deck_changed(toggled: bool):
	current_settings.load_custom_decks = toggled

func close_window():
	GlobalGameManagerAccess.get_game_manager().close_game()