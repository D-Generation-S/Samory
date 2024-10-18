extends ClickableButton


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_done)
	GlobalSystemDeckManager.loading_system_decks.connect(load_decks)

func _pressed():
	GlobalSystemDeckManager.reload_system_decks()

func loading_done():
	disabled = false

func load_decks():
	disabled = true