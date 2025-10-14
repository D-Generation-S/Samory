extends ClickableToggle

func settings_loaded(settings: SettingsResource) -> void:
	button_pressed = settings.auto_close_round
	toggled.emit(button_pressed)
	starts_ready = true
