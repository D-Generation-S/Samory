class_name RegainFocusButton extends ClickableButton

var was_pressed: bool = false

func _pressed():
	super()
	was_pressed = true

func regain_focus():
	if was_pressed:
		grab_focus()
		was_pressed = false
