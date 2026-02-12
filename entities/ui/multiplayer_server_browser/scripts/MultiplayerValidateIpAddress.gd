class_name MultiplayerValidateIpAddress extends LineEditValidation

func _ready() -> void:
	super()
	var settings: SettingsResource = SettingsRepository.load_settings()
	text = settings.last_used_ip
	text_changed.emit(text)
	