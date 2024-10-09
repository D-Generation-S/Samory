extends CanvasLayer

class_name MainMenu

@export var game_buttons: Array[Button] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var game_manager = get_tree().root.get_child(0) as GameManager
	game_manager.system_deck_manager.connect("loading_system_decks", loading_cards)
	game_manager.system_deck_manager.connect("loading_system_decks_done", loading_cards_done)
	change_button_state(game_manager.system_deck_manager.is_loading())

func loading_cards():
	change_button_state(true)

func loading_cards_done():
	change_button_state(false)

func change_button_state(new_disable_state: bool):
	for button in game_buttons:
		button.disabled = new_disable_state
