extends ClickableToggle

func _ready() -> void:
	super()
	if OS.has_feature("web"):
		visible = false
	starts_ready = true

func signal_activated() -> void:
	button_pressed = true

func loading_decks() -> void:
	disabled = true

func loading_decks_done() -> void:
	disabled = false

func toggle_enabled(on: bool) -> void:
	disabled = !on
