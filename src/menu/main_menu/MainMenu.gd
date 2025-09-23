extends CanvasLayer

class_name MainMenu

@export var game_buttons: Array[Button] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSystemDeckManager.loading_system_decks.connect(loading_cards)
	GlobalSystemDeckManager.loading_system_decks.connect(loading_cards_done)
	change_button_state(GlobalSystemDeckManager.is_loading())
	get_tree().paused = false

func loading_cards():
	change_button_state(true)

func loading_cards_done():
	change_button_state(false)

func change_button_state(new_disable_state: bool):
	for button in game_buttons:
		button.disabled = new_disable_state
