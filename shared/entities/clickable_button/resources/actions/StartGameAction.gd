class_name StartGameAction extends ButtonAction

@export var players: Array[PlayerResource] = []

func execute(base: ClickableButton) -> void:
	var order_number: int = 0
	var player_templates: Array[PlayerResource] = []
	for player: PlayerResource in players:
		var template: PlayerResource = player.duplicate_deep()
		template.order_number = order_number
		if template.ai_difficulty != null:
			template.name = template.ai_difficulty.get_translated_name()
		player_templates.append(template)
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	var decks: Array[MemoryDeckResource] = game_manager.get_available_decks()
	game_manager.play_game_with_position(player_templates, decks.pick_random(), base.get_global_center_position())