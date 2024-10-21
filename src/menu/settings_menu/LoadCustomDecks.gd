extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func settings_loaded(settings: SettingsResource):
	button_pressed = settings.load_custom_decks