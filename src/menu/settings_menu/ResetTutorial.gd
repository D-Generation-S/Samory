extends ClickableButton

func _pressed():
	super()
	var settings = SettingsRepository.load_settings() as SettingsResource
	settings.tutorials = {}
	settings.tutorial_aborted = false
	settings.auto_close_popup_shown = false
	SettingsRepository.save_settings(settings)
