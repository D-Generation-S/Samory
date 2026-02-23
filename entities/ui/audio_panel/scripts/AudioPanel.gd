extends Control

signal audio_bus_changed(bus_name: int, new_volume: float)
signal _setting_was_set(settings: SettingsResource)

func audio_updated(bus_name: int, new_volume: float) -> void:
	audio_bus_changed.emit(bus_name, new_volume)

func settings_loaded(settings: SettingsResource) -> void:
	_setting_was_set.emit(settings)