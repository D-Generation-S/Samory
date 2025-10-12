extends ClickableButton

@export var is_ai_game: bool = false
@export var possible_ai_difficulties: Array[AiDifficultyResource] = []

func _pressed() -> void:
	super()
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	var selected_deck_index: int = randi() % game_manager.get_available_decks().size()
	var deck: MemoryDeckResource = game_manager.get_available_decks()[selected_deck_index]

	var player_one: PlayerResource = create_ai_player(0, false)
	var player_two: PlayerResource = create_ai_player(1, is_ai_game)

	game_manager.play_game_with_position([player_one, player_two], deck, get_global_center_position())

func create_ai_player(order_number: int, is_ai: bool) -> PlayerResource:
	var new_player: PlayerResource = PlayerResource.new()
	new_player.name = "Player " + str(order_number + 1)
	new_player.order_number = order_number
	new_player.score = 0
	if is_ai:
		var loot: LootTable = LootTable.new()
		for ai: AiDifficultyResource in possible_ai_difficulties:
			loot.add_to_table(ai, 1)
		new_player.ai_difficulty = loot.get_loot()
		new_player.name = new_player.ai_difficulty.get_translated_name()

	return new_player
