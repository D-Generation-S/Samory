class_name StartGameAction extends ButtonAction

@export var players: Array[PlayerResource] = []

func execute(base: ClickableButton) -> void:
	var order_number: int = 0
	for player: PlayerResource in players:
		player.order_number = order_number
		if player.ai_difficulty != null:
			player.name = player.ai_difficulty.get_translated_name()
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	game_manager.play_game_with_position(players, game_manager.get_available_decks().pick_random(), base.get_global_center_position())