extends ClickableButton

@export var finish_game_node: GameFinished

func _ready() -> void:
	await get_tree().physics_frame
	if finish_game_node.played_deck == null or was_multiplayer_game():
		queue_free()

func _pressed() -> void:
	get_tree().paused = false
	var players: Array[PlayerResource] = finish_game_node.manager.get_players()
	players.sort_custom(sort_by_id)
	GlobalGameManagerAccess.get_game_manager().play_game_with_position(players, finish_game_node.played_deck, get_screen_position())

func sort_by_id(a: PlayerResource, b: PlayerResource) -> bool:
	return a.id < b.id

func was_multiplayer_game() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer