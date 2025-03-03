extends CheckButton

func settings_loaded(settings: SettingsResource):
	button_pressed = settings.auto_close_round
	toggled.emit(button_pressed)
