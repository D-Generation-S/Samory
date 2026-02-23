extends CanvasLayer

var _loaded_settings: SettingsResource = null

func _get_settings() -> SettingsResource:
	if _loaded_settings != null:
		return _loaded_settings

	_loaded_settings = SettingsRepository.load_settings()
	return _loaded_settings

func set_language(language_code: String) -> void:
	_get_settings().language_code = language_code

func toggle_custom_deck(new_value: bool) -> void:
	_get_settings().load_custom_decks = new_value

func volume_changed(bus_name: int, new_volume: float) -> void:
	match bus_name:
		BusType.Master:
			_get_settings().master_volume = new_volume
		BusType.Effect:
			_get_settings().effect_volume = new_volume
		BusType.Music:
			_get_settings().music_volume = new_volume

func window_mode_changed(new_mode: DisplayServer.WindowMode) -> void:
	_get_settings().window_mode = new_mode

func save_settings() -> void:
	SettingsRepository.save_settings( _get_settings())
	if not _get_settings().load_custom_decks:
		GlobalSystemDeckManager.clear_system_decks()