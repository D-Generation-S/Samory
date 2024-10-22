extends CheckButton

var initial_load_state: bool = false


func settings_loaded(settings: SettingsResource):
	button_pressed = settings.load_custom_decks