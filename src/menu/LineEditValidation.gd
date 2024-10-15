extends LineEdit

class_name LineEditValidation

@export var is_focused: bool = false

signal validation_error(error_message: String)
signal validation_failed()
signal valid()

func _ready():
    if is_focused:
        grab_focus()