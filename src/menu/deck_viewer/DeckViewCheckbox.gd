extends CheckButton

func _ready():
	if OS.has_feature("web"):
		visible = false

func signal_activated():
	button_pressed = true

func loading_decks():
	disabled = true

func loading_decks_done():
	disabled = false

func toggle_enabled(on: bool):
	disabled = !on
