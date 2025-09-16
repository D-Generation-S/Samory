extends  LineEditValidation

@export var error_no_name_was_entered: TextTranslation
@export var error_only_letters_and_numbers_allowed: TextTranslation

var alphanumeric_validation_regex: RegEx

var last_check_validation: bool = false

func _ready():
	if error_no_name_was_entered == null or error_only_letters_and_numbers_allowed == null:
		printerr("No translations resource set!")
		return 
	super()
	alphanumeric_validation_regex = RegEx.new()
	alphanumeric_validation_regex.compile("^[a-zA-Z0-9]+$")
	validation_error.emit(error_no_name_was_entered.key)

func _on_text_changed(new_text: String):
	if new_text == "":
		validation_failed.emit()
		validation_error.emit(error_no_name_was_entered.key)
		last_check_validation = false
		return
	if alphanumeric_validation_regex.search(new_text):
		last_check_validation = true
		valid.emit()
		return
	
	validation_failed.emit()
	validation_error.emit(error_only_letters_and_numbers_allowed.key)
	last_check_validation = false

	
func is_valid():
	return last_check_validation
