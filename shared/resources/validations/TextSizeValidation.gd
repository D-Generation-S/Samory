class_name TextSizeValidation extends Validation

@export var min_size: int = 0
@export var max_size: int = 2000
@export var min_size_error: TextTranslation = preload("res://shared/resources/translations/assets/MinSizeTranslation.tres")
@export var max_size_error: TextTranslation = preload("res://shared/resources/translations/assets/MaxSizeTranslation.tres")

func validate(new_text: String) -> bool:
	super(new_text)
	if new_text.length() < min_size:
		_add_error(tr(min_size_error.key) % min_size)
		return false
	if new_text.length() > max_size:
		print(tr(max_size_error.key) % max_size)
		print(tr(max_size_error.key))
		print(max_size)
		_add_error(tr(max_size_error.key) % max_size)
		return false
	return true
