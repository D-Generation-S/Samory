extends ClickableToggle

func settings_loaded(settings: SettingsResource) -> void:
	button_pressed = settings.vsync_active
	starts_ready = true