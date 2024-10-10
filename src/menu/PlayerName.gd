extends  LineEditValidation

var alphanumeric_validation_regex: RegEx

var last_check_validation: bool = false

func _ready():
	super()
	alphanumeric_validation_regex = RegEx.new()
	alphanumeric_validation_regex.compile("^[a-zA-Z0-9]+$")
	validation_error.emit("NO_NAME_WAS_ENTERD")

func _on_text_changed(new_text: String):
	if new_text == "":
		validation_failed.emit()
		validation_error.emit("NO_NAME_WAS_ENTERD")
		last_check_validation = false
		return
	if alphanumeric_validation_regex.search(new_text):
		last_check_validation = true
		valid.emit()
		return
	
	validation_failed.emit()
	validation_error.emit("ONLY_LETTER_AND_NUMBERS_ALLOWED_FOR_PLAYERNAME")
	last_check_validation = false

	
func is_valid():
	return last_check_validation
