extends ClickableToggle

func settings_loaded(settings: SettingsResource) -> void:
	button_pressed = settings.animate_card_matches
	toggled.emit(button_pressed)
	starts_ready = true
