extends ClickableButton


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	GlobalSystemDeckManager.loading_system_decks.connect(loading_decks)
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_decks_done)
	
func _pressed():
	super()
	GlobalGameManagerAccess.get_game_manager().close_game()

func loading_decks():
	disabled = true

func loading_decks_done():
	disabled = false

