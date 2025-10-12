extends Control

class_name NewPlayer

signal new_player_dialog_closed()
signal new_player_added(player: PlayerResource)

func modal_getting_closed() -> void:
	new_player_dialog_closed.emit()
	queue_free()

func player_was_added(player: PlayerResource) -> void:
	new_player_added.emit(player)
	modal_getting_closed()
