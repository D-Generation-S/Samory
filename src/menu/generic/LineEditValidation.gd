extends LineEdit

class_name LineEditValidation

@export var is_focused: bool = false

@warning_ignore("unused_signal")
signal validation_error(error_message: String)

@warning_ignore("unused_signal")
signal validation_failed()

@warning_ignore("unused_signal")
signal valid()

func _ready():
    if is_focused:
        grab_focus()