extends HBoxContainer

signal value_changed(new_value: float)

var _current_value: float = 1

func settings_changed(new_settings: SettingsResource) -> void:
	value_changed.emit(new_settings.ui_scale_factor)

func update_preview(_changed: bool) -> void:
	ScaleManager.update_ui_scale(_current_value)

func value_was_changed(new_value: float) -> void:
	_current_value = new_value
