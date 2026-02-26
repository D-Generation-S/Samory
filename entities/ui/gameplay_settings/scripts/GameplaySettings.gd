extends PanelContainer

signal settings_changed(settings: SettingsResource)

signal language_changed(language_code: String)
signal load_custom_deck_changed(state: bool)
signal time_for_completion_changed(time: float)
signal auto_complete_changed(state: bool)
signal reset_tutorial()

func change_language(language_code: String) -> void:
	language_changed.emit(language_code)

func change_custom_deck_loading(state: bool) -> void:
	load_custom_deck_changed.emit(state)

func change_auto_close_round(state: bool) -> void:
	auto_complete_changed.emit(state)

func change_time_to_completion(time: float) -> void:
	time_for_completion_changed.emit(time)

func tutorial_reset() -> void:
	reset_tutorial.emit()
	
func settings_loaded(settings: SettingsResource) -> void:
	settings_changed.emit(settings)