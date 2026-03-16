extends ClickableToggle

func settings_loaded(settings: SettingsResource) -> void:
	button_pressed = settings.enter_animate_controls
	toggled.emit(button_pressed)
	starts_ready = true
