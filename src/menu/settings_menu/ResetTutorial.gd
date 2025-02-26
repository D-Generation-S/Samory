extends Button

func _pressed():
	var settings = SettingsRepository.load_settings() as SettingsResource
	settings.tutorial = TutorialResource.new()
	SettingsRepository.save_settings(settings)
