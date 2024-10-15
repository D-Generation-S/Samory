extends ClickableButton

#signal player_selection()

func _pressed():
	super()

func disable_button():
	disabled = true

func enable_button():
	disabled = false
