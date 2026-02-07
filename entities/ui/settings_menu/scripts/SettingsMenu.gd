extends CanvasLayer

signal settings_loaded(settings: SettingsResource)

var initial_settings: SettingsResource;
@export var accept_button: Button
@export var close_button: Button

@onready var _current_settings: SettingsResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_settings = SettingsRepository.load_settings()
	_current_settings = initial_settings.duplicate_deep()
	settings_loaded.emit(initial_settings)

func reset_settings() -> void:
	settings_loaded.emit(initial_settings)
	close_window(close_button)

func reset_tutorial() -> void:
	_current_settings.tutorials = {}
	_current_settings.tutorial_aborted = false
	_current_settings.auto_close_popup_shown = false

func save_settings() -> void:
	_current_settings.vsync_active = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

	if !SettingsRepository.save_settings(_current_settings):
		reset_settings()
	
	if !initial_settings.load_custom_decks and _current_settings.load_custom_decks:
		GlobalGameManagerAccess.get_game_manager().reload_system_decks()
		return
	
	if !_current_settings.load_custom_decks:
		GlobalSystemDeckManager.clear_system_decks()
	close_window(accept_button)

func volume_changed(bus_name: int, new_volume: float) -> void:
	match bus_name:
		BusType.Master:
			_current_settings.master_volume = new_volume
		BusType.Effect:
			_current_settings.effect_volume = new_volume
		BusType.Music:
			_current_settings.music_volume = new_volume

func language_changed(new_language_code: String) -> void:
	_current_settings.language_code = new_language_code

func load_custom_deck_changed(toggled: bool) -> void:
	_current_settings.load_custom_decks = toggled

func window_mode_changed(new_mode: DisplayServer.WindowMode) -> void:
	_current_settings.window_mode = new_mode

func close_window(calling_button: Button) -> void:
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(calling_button.get_global_center_position())
	ScaleManager.update_ui_scale(SettingsRepository.load_settings().ui_scale_factor)

func auto_complete_round_changed(toggled: bool) -> void:
	_current_settings.auto_close_round = toggled

func time_for_completion_changed(new_time: float) -> void:
	_current_settings.close_round_after_seconds = new_time

func ui_scale_changed(new_value: float) -> void:
	_current_settings.ui_scale_factor = new_value

func v_sync_changed(new_value: bool) -> void:
	var mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED
	if not new_value:
		mode = DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)
