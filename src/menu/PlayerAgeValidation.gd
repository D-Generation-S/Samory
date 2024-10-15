extends LineEditValidation

var number_validation_regex: RegEx

var last_check_validation: bool = false


func _ready():
	super()
	number_validation_regex = RegEx.new()
	number_validation_regex.compile("^[0-9]+$")
	validation_error.emit("NO_AGE_WAS_ENTERED")

func _on_text_changed(new_text: String):
	if new_text == "":
		validation_error.emit("NO_AGE_WAS_ENTERED")
		last_check_validation = false
		return
	
	if number_validation_regex.search(new_text):
		last_check_validation = true
		valid.emit()
		return
	
	validation_error.emit("AGE_NEEDS_TO_BE_A_NUMBER")
	validation_failed.emit()
	last_check_validation = false

func is_valid():
	return last_check_validation

