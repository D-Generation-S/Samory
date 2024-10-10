extends ClickableButton

@export var finish_game_node: GameFinished

func _pressed():
	var root_node = get_tree().root.get_child(0) as GameManager
	root_node.play_game(finish_game_node.manager.get_players(), finish_game_node.played_deck)
	pass
