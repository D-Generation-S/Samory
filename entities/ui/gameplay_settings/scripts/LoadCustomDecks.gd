extends ClickableToggle

var initial_load_state: bool = false

func _ready() -> void:
	super()
	if OS.has_feature("web"):
		visible = false


func settings_loaded(settings: SettingsResource) -> void:
	button_pressed = settings.load_custom_decks
	starts_ready = true