extends CheckButton

func _ready():
	GlobalSystemDeckManager.loading_system_decks.connect(loading_decks)
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_decks_done)

func signal_activated():
	button_pressed = true

func loading_decks():
	disabled = true

func loading_decks_done():
	disabled = false

