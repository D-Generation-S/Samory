extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func settings_loaded(settings: SettingsResource):
	toggle_mode = settings.fullscreen