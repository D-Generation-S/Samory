class_name MultiplayerValidateIpAddress extends LineEditValidation

@export var ip_regex_to_use: String = "^(((?!25?[6-9])[12]\\d|[1-9])?\\d\\.?\\b){4}$"

var _regex: RegEx

func _ready() -> void:
	super()
	_regex = RegEx.new()
	_regex.compile(ip_regex_to_use)
	var settings: SettingsResource = SettingsRepository.load_settings()
	text = settings.last_used_ip
	text_changed.emit(text)

func _validate(_new_text: String) -> bool:
	var is_valid_data: bool = _regex.search(_new_text) != null
	if is_valid_data:
		var settings: SettingsResource = SettingsRepository.load_settings()
		settings.last_used_ip = _new_text
	return is_valid_data
	
	