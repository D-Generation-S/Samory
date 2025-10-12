extends ClickableButton

@export var finish_game_node: GameFinished

func _ready() -> void:
	await get_tree().physics_frame
	if finish_game_node.played_deck == null:
		queue_free()

func _pressed() -> void:
	super()
	get_tree().paused = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		GlobalGameManagerAccess.get_game_manager().play_network_game(finish_game_node.manager.get_players(), finish_game_node.played_deck, get_screen_position())
		return
	GlobalGameManagerAccess.get_game_manager().play_game_with_position(finish_game_node.manager.get_players(), finish_game_node.played_deck, get_screen_position())
