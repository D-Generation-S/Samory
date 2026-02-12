class_name LineEditValidation extends LineEdit

@warning_ignore("unused_signal")
signal validation_error(error_message: String)

signal validation_failed()
signal valid()

signal got_submitted()

@export var is_focused: bool = false
@export var validation: Validation = null

var _is_valid: bool = true

func _ready() -> void:
	if is_focused:
		grab_focus()
	text_submitted.connect(_text_submitted)
	text_changed.connect(_on_text_changed)
	_validate_and_trigger(text)

func _on_text_changed(new_text: String) -> void:
	_validate_and_trigger(new_text)

func _text_submitted(new_text: String) -> void:
	_validate_and_trigger(new_text)
	got_submitted.emit()

func _validate_and_trigger(new_text: String) -> void:
	_is_valid = _validate(new_text)
	if _is_valid:
		valid.emit()
		return
	validation_failed.emit()

func _validate(new_text: String) -> bool:
	if validation != null:
		var validated: bool = validation.validate(new_text)
		if not validated:
			validation_error.emit("")
			for error: String in validation.get_last_errors():
				validation_error.emit(error)
			return false
	return true

func is_valid() -> bool:
	return _is_valid