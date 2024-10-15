extends ClickableButton

func _pressed():
	super()
	var game_manager = get_tree().root.get_child(0) as GameManager
	var selected_deck_index = randi() % game_manager.get_available_decks().size()
	var deck = game_manager.get_available_decks()[selected_deck_index]

	var player_one = PlayerResource.new()
	player_one.name = "Player 1"
	player_one.age = 1
	player_one.score = 0

	var player_two = PlayerResource.new()
	player_two.name = "Player 2"
	player_two.age = 2
	player_two.score = 0

	game_manager.play_game([player_one, player_two], deck)
	
