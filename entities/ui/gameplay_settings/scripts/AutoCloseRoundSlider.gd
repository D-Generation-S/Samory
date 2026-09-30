extends Control

signal completion_time_changed(new_time: String)
signal update_slider_value(new_value: float)

@export var completion_time_translation: TextTranslation

var _last_stored_value: float = 0

func _ready() -> void:
	LanguageManager.language_changed.connect(_language_changed)

func _language_changed() -> void:
	set_translated_text(_last_stored_value)

func settings_loaded(settings: SettingsResource) -> void:
	set_translated_text(settings.close_round_after_seconds)
	update_slider_value.emit(settings.close_round_after_seconds)

func set_translated_text(value: float) -> void:
	var translated_text: String = tr(completion_time_translation.key) % value
	completion_time_changed.emit(translated_text)

func toggle_visibility(new_state: bool) -> void:
	visible = new_state

func slider_changed(value: float) -> void:
	_last_stored_value = value
	set_translated_text(value)
