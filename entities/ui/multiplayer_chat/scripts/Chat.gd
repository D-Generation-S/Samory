extends VBoxContainer

signal new_player_joined(name: String, id: int)
signal player_was_disconnected(id: int)
signal message_requested(message: String)
signal update_player_list(players: Array[PlayerResource])

func player_joined(player_name: String, id: int) -> void:
	new_player_joined.emit(player_name, id)

func player_disconnected(id: int) -> void:
	player_was_disconnected.emit(id)

func sync_player_list(players: Array[PlayerResource]) -> void:
	update_player_list.emit(players)

func request_message(message: String) -> void:
	message_requested.emit(message)