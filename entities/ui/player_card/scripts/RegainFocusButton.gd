class_name RegainFocusButton extends ClickableButton

var was_pressed: bool = false

func _pressed() -> void:
	was_pressed = true

func regain_focus() -> void:
	if was_pressed:
		grab_focus()
		was_pressed = false
