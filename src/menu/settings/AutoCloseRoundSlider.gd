extends HBoxContainer

signal completion_time_changed(new_time: String)
signal update_min_slider_value(new_min: float)
signal update_max_slider_value(new_max: float)
signal update_slider_value(new_value: float)

@export_range(1, 2, 1) var set_min_value: float = 1
@export_range(2, 5, 1) var set_max_value: float = 5
@export var completion_time_translation: TextTranslation

var _last_stored_value: float = 0

func settings_loaded(settings: SettingsResource):
	update_min_slider_value.emit(set_min_value)
	update_max_slider_value.emit(set_max_value)
	set_translated_text(settings.close_round_after_seconds)
	update_slider_value.emit(settings.close_round_after_seconds)
	

func set_translated_text(value: float):
	var translated_text = tr(completion_time_translation.key) % value
	completion_time_changed.emit(translated_text)

func toggle_visibility(new_state: bool):
	visible = new_state

func slider_changed(value: float):
	_last_stored_value = value
	set_translated_text(value)

func language_changed(_language_code: String):
	set_translated_text(_last_stored_value)
