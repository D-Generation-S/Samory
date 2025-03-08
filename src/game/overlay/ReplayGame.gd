extends ClickableButton

@export var finish_game_node: GameFinished

func _pressed():
	super()
	GlobalGameManagerAccess.get_game_manager().play_game(finish_game_node.manager.get_players(), finish_game_node.played_deck)
