class_name Validation extends Resource

var _errors: Array[String] = []

func validate(_new_text: String) -> bool:
	_clear_errors()
	return true

func get_last_errors() -> Array[String]:
	return _errors

func _add_error(error: String) -> void:
	if error == "":
		return
	_errors.append(error)

func _add_errors(errors: Array[String]) -> void:
	for  error: String in errors:
		_add_error(error)

func _clear_errors() -> void:
	_errors.clear()