extends ClickableButton

signal decks_loading()

var is_locked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_done)
	GlobalSystemDeckManager.loading_system_decks.connect(load_decks)

	var settings: SettingsResource = SettingsRepository.load_settings()
	if OS.has_feature("web") or !settings.load_custom_decks:
		is_locked = true
		disabled = true
		queue_free()

func enable_button() -> void:
	if is_locked:
		return
	super()

func _pressed() -> void:
	GlobalSystemDeckManager.reload_system_decks()

func loading_done() -> void:
	disabled = false

func load_decks() -> void:
	decks_loading.emit()
	disabled = true
