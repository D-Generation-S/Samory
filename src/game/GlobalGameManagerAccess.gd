extends Node

var game_manager: GameManager = null
var sound_bridge: SoundBridge = null

func get_game_manager() -> GameManager:
	if game_manager != null:
		return game_manager

	for child in get_tree().root.get_children():
		if child is GameManager:
			game_manager = child

	return get_game_manager()

func get_sound_bridge() -> SoundBridge:
	if sound_bridge != null:
		return sound_bridge

	for child_node in get_game_manager().get_children():
		if child_node.is_in_group("static") and child_node is SoundBridge:
			sound_bridge = child_node

	return get_sound_bridge()
