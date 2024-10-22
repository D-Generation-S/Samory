extends CheckButton

func settings_loaded(settings: SettingsResource):
	button_pressed = settings.vsync_active