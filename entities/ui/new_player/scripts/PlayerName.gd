extends  LineEditValidation

@export var error_no_name_was_entered: TextTranslation
@export var error_only_letters_and_numbers_allowed: TextTranslation

var alphanumeric_validation_regex: RegEx


func _ready() -> void:
	if error_no_name_was_entered == null or error_only_letters_and_numbers_allowed == null:
		printerr("No translations resource set!")
		return 
	super()
	alphanumeric_validation_regex = RegEx.new()
	alphanumeric_validation_regex.compile("^[a-zA-Z0-9]+$")
	validation_error.emit(error_no_name_was_entered.key)


func _validate(new_text: String) -> bool:
	if new_text == "":
		validation_error.emit(error_no_name_was_entered.key)
		return false
	if alphanumeric_validation_regex.search(new_text):
		return true
	
	validation_error.emit(error_only_letters_and_numbers_allowed.key)
	return false