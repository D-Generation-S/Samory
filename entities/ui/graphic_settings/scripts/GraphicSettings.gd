extends PanelContainer

signal window_mode_changed(new_mode: DisplayServer.WindowMode)
signal v_sync_changed(state: bool)
signal ui_scale_changed(new_scale: float)
signal settings_changed(setting: SettingsResource)
signal language_changed(language_code: String)

func change_window_mode(new_mode: DisplayServer.WindowMode) -> void:
	window_mode_changed.emit(new_mode)

func change_v_sync(state: bool) -> void:
	v_sync_changed.emit(state)

func change_ui_scale(new_scale: float) -> void:
	ui_scale_changed.emit(new_scale)

func settings_loaded(settings: SettingsResource) -> void:
	settings_changed.emit(settings)

func change_language(language_code: String) -> void:
	language_changed.emit(language_code)