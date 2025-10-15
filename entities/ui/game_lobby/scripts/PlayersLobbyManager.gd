class_name PlayerLobbyManager extends VBoxContainer

signal player_list_changed()
signal regain_focus()
signal request_focus_element()

@export var player_card_template: PackedScene

var adding_locked: bool = false

func add_player(new_player: PlayerResource) -> void:
	if adding_locked:
		return
	var player_card: PlayerCard = player_card_template.instantiate() as PlayerCard
	new_player.order_number = get_next_player_number()
	player_card.player_card = new_player

	add_child(player_card)
	player_card.getting_deleted.connect(player_was_removed)
	player_card.move_up_request.connect(move_entry_up)
	player_card.move_down_request.connect(move_entry_down)
	regain_focus.connect(player_card.regain_focus)
	player_list_changed.emit()

func get_next_player_number() -> int:
	var current_order_number: int = -1
	for child: PlayerCard in _get_player_cards():
		if child.player_card.order_number > current_order_number:
			current_order_number = child.player_card.order_number

	return current_order_number + 1

func player_was_removed() -> void:
	player_list_changed.emit()
	reorder()
	request_focus_element.emit()

func reorder() -> void:
	var current_number: int = 0
	for child: PlayerCard in _get_player_cards():
		child.player_card.order_number = current_number
		current_number = current_number + 1

func add_special_control(control_to_add: Control) -> void:
	if control_to_add == null or adding_locked:
		return
	add_child(control_to_add)
	adding_locked = true

func move_entry_up(order_number: int) -> void:
	if order_number == 0:
		return
	rebuild_list(order_number - 1, order_number)

func rebuild_list(upper_child_number: int, lower_child_number: int) -> void:
	var upper_child: Node = get_child(upper_child_number)
	var current_child: Node = get_child(lower_child_number)
	var child_entries: Array[Node] = [current_child, upper_child]
	var other_children: Array[Node] = get_children().slice(lower_child_number + 1)
	child_entries.append_array(other_children)

	for child: Node in child_entries:
		remove_child(child)
		add_child(child)

	reorder()
	regain_focus.emit()

func move_entry_down(order_number: int) -> void:
	var max_number: int = get_next_player_number() - 1
	if order_number == max_number:
		return
	rebuild_list(order_number, order_number + 1)

func unlock_special_control() -> void:
	adding_locked = false

func _get_player_cards() -> Array[PlayerCard]:
	var return_data: Array[PlayerCard] = []
	for card: PlayerCard in get_children().filter(func(node: Node) -> bool: return node is PlayerCard):
		return_data.append(card)
	return return_data