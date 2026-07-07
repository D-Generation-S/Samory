class_name SpecialEvent extends Resource

@export var event_name: TextTranslation = null
@export var event_text: TextTranslation = null
## This value is getting used to calculate the difference between the current year and the year provided
@export var validation: SpecialEventValidation

func is_valid_today(year: int, month: int, day: int) -> bool:
	return _content_valid() and validation.validate(year, month, day)

func _content_valid() -> bool:
	return event_name != null and event_text != null and validation != null

func get_text(year: int, month: int, day: int) -> String:
	var text: String = tr(event_text.key)
	return "[center]%s[/center][hr][br]%s" % [_get_headline(), validation.text_processor(text, year, month, day)]

func _get_headline() -> String:
	return tr(event_name.key)
