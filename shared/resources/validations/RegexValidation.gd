class_name RegexValidation extends Validation

@export var regex_rules: String = "*."
@export var regex_validation_error: TextTranslation = preload("res://shared/resources/translations/assets/RegexValidationError.tres")

var _regex: RegEx

func validate(new_text: String) -> bool:
	if _regex == null:
		_regex = RegEx.new()
		_regex.compile(regex_rules)
	super(new_text)
	if _regex.search(new_text):
		return true
	_add_error(tr(regex_validation_error.key))
	return false