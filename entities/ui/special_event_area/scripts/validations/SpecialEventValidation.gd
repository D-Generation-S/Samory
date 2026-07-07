@abstract class_name SpecialEventValidation extends Resource

## Should the text be changed by adding date related information to it?
@export var process_text: bool = false

func text_processor(translated_text: String, year: int, month: int, day: int) -> String:
	if process_text:
		return _process_text(translated_text, year, month, day)
	return translated_text

@abstract func validate(year: int, month: int, day: int) -> bool

@abstract func _process_text(translated_text: String, year: int, month: int, day: int) -> String