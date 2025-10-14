class_name MultiplayerNameInputValidator extends LineEditValidation

func _ready() -> void:
	super()
	text = _get_player_name()
	text_changed.emit(text)

func _get_player_name() -> String:
	var settings: SettingsResource = SettingsRepository.load_settings()
	if settings.default_multiplayer_name != "":
		return settings.default_multiplayer_name
	var name_generator: NameGenerator= NameGenerator.new()
	return name_generator.get_random_name()

func _validate(_new_text: String) -> bool:
	
	var settings: SettingsResource = SettingsRepository.load_settings()
	settings.default_multiplayer_name = text
	return true