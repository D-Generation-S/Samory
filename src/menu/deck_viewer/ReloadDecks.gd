extends ClickableButton

signal decks_loading()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_done)
	GlobalSystemDeckManager.loading_system_decks.connect(load_decks)

	var settings: SettingsResource = SettingsRepository.load_settings()
	if OS.has_feature("web") or !settings.load_custom_decks:
		disabled = true

func _pressed():
	GlobalSystemDeckManager.reload_system_decks()

func loading_done():
	disabled = false

func load_decks():
	decks_loading.emit()
	disabled = true