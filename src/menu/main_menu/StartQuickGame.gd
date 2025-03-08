extends ClickableButton

@export var is_ai_game: bool = false
@export var possible_ai_difficulties: Array[AiDifficultyResource] = []

func _pressed():
	super()
	var game_manager = GlobalGameManagerAccess.get_game_manager()
	var selected_deck_index = randi() % game_manager.get_available_decks().size()
	var deck = game_manager.get_available_decks()[selected_deck_index]

	var player_one = create_ai_player(0, false)
	var player_two = create_ai_player(1, is_ai_game)

	game_manager.play_game([player_one, player_two], deck)

func create_ai_player(order_number: int, is_ai: bool) -> PlayerResource:
	var new_player = PlayerResource.new()
	new_player.name = "Player " + str(order_number + 1)
	new_player.order_number = order_number
	new_player.score = 0
	if is_ai:
		var loot = LootTable.new()
		for ai in possible_ai_difficulties:
			loot.add_to_table(ai, 1)
		new_player.ai_difficulty = loot.get_loot()
		new_player.name = new_player.ai_difficulty.get_translated_name()

	return new_player
