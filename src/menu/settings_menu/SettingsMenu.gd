extends CanvasLayer

signal settings_loaded(settings: SettingsResource)

# Called when the node enters the scene tree for the first time.
func _ready():
	settings_loaded.emit(SettingsRepository.load_settings())

