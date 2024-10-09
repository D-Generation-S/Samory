extends LineEdit

class_name LineEditValidation

signal validation_error(error_message: String)
signal validation_failed()
signal valid()

func is_valid():
    return false