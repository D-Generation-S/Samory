extends Label

var _initial_text: String
var _last_ui_scale: float

func _ready() -> void:
	_initial_text = text

func _update_text_with_scale(new_ui_scale: float) -> void:
	text = tr(_initial_text) % (new_ui_scale * 100)
	_last_ui_scale = new_ui_scale

func language_changed(_code: String) -> void:
	_update_text_with_scale(_last_ui_scale)