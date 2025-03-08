extends ClickableToggle


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus() 
	connect("toggled", was_toggled)

func settings_loaded(settings: SettingsResource):
	button_pressed = settings.fullscreen
	starts_ready = true

func was_toggled(toggled_on: bool):
	if !toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		return
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
