class_name PlayerLobbyManager extends VBoxContainer

signal player_list_changed()
signal player_adding()

@export var player_card_template: PackedScene

func add_player(new_player: PlayerResource):
	var player_card = player_card_template.instantiate() as PlayerCard
	player_card.player_card = new_player
	add_child(player_card)
	player_card.getting_deleted.connect(player_was_removed)
	player_list_changed.emit()

func player_was_removed():
	player_list_changed.emit()
