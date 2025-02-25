extends LineEdit

func toggle_enabled(on: bool):
	editable = on

func enable():
	toggle_enabled(true)

func disable():
	text = ""
	toggle_enabled(false)
