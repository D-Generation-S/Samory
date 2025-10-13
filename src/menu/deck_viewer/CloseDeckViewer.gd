extends ClickableButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GlobalSystemDeckManager.loading_system_decks.connect(loading_decks)
	GlobalSystemDeckManager.loading_system_decks_done.connect(loading_decks_done)
	
func _pressed() -> void:
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(global_position)

func loading_decks() -> void:
	disabled = true

func loading_decks_done() -> void:
	disabled = false
