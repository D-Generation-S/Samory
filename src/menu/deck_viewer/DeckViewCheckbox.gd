extends ClickableToggle

func _ready():
	super()
	if OS.has_feature("web"):
		visible = false
	starts_ready = true

func signal_activated():
	button_pressed = true

func loading_decks():
	disabled = true

func loading_decks_done():
	disabled = false

func toggle_enabled(on: bool):
	disabled = !on
