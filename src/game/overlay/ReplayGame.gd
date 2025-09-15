extends ClickableButton

@export var finish_game_node: GameFinished

func _pressed():
	super()
	get_tree().paused = false
	GlobalGameManagerAccess.get_game_manager().play_game_with_position(finish_game_node.manager.get_players(), finish_game_node.played_deck, get_screen_position())
