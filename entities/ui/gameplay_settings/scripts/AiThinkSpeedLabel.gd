extends Label

signal setting_changed(new_value: float)
signal ai_think_time_changed(new_value: float)

@export var max_allowed_value: float = 3

var _initial_text: String = ""
var _last_think_speed: float = 1

func _ready() -> void:
	_initial_text = text

func set_new_value(new_value: float) -> void:
	_last_think_speed = new_value
	_update_text_table(new_value)

	var real_value: float = _convert_value(new_value)
	real_value = real_value / max_allowed_value
	ai_think_time_changed.emit(real_value)

func _convert_value(new_value: float) -> float:
	return (max_allowed_value + 1) - new_value

func _update_text_table(new_value: float) -> void:
	text = tr(_initial_text) % (new_value * 100.0)

func language_changed(_language_code: String) -> void:
	_update_text_table(_last_think_speed)

func settings_updated(settings: SettingsResource) -> void:
	var base_value: float = settings.ai_think_time * max_allowed_value
	base_value = _convert_value(base_value)
	_update_text_table(base_value)
	setting_changed.emit(base_value)
