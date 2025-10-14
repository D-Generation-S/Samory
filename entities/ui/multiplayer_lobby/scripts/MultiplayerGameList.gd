extends VBoxContainer

signal request_player_list()
signal player_kicked(id: int)
signal resync_player_order(players: Array[PlayerResource])

@export var player_template: PackedScene = null

func _ready() -> void:
	if player_template == null:
		printerr("Missing proper player template")
		queue_free()
	request_player_list.emit()

func player_added(new_name: String, id: int) -> void:
	var player: PlayerResource = PlayerResource.new()
	player.name = new_name
	player.id = id
	player.order_number = get_next_order_number()
	player.ai_difficulty = null
	_add_player_resource(player)

func get_next_order_number() -> int:
	return _get_last_order_number() + 1

func _get_last_order_number() -> int:
	var order_number: int = 0
	for player: PlayerCard in get_children():
		order_number = maxi(order_number, player.player_card.order_number)

	return order_number

func _get_smallest_order_number() -> int:
	var order_number: int = 1000
	for player: PlayerCard in get_children():
		order_number = mini(order_number, player.player_card.order_number)

	return order_number

func _move_player(entry_number: int, direction: int) -> void:
	direction = clampi(direction, -1, 1)
	var source: PlayerCard = _get_player_card_by_order_number(entry_number)
	var target: PlayerCard = _get_player_card_by_order_number(entry_number + direction)
	if source == null or target == null:
		return
	source.player_card.order_number = source.player_card.order_number + direction
	target.player_card.order_number = target.player_card.order_number - direction

	_rebuild_list()
	_rebuild_order_numbers()

func _rebuild_order_numbers() -> void:
	var order_number: int = 0
	for player: PlayerCard in get_children():
		var player_resource: PlayerResource = player.player_card
		player_resource.order_number = order_number
		order_number += 1

func _rebuild_list() -> void:
	var cards: Array[PlayerCard] = []
	for player: PlayerCard in get_children():
		cards.append(player)
		remove_child(player)

	cards.sort_custom(func(a: PlayerCard, b: PlayerCard) -> bool: return a.player_card.order_number < b.player_card.order_number)
	
	var player_resources: Array[PlayerResource] = []
	for player_resource: PlayerResource in cards.map(func(card: PlayerCard) -> PlayerResource: return card.player_card):
		player_resources.append(player_resource)
	resync_player_order.emit(player_resources)

	for card: PlayerCard in cards:
		add_child(card)

func _get_player_card_by_order_number(order_number: int) -> PlayerCard:
	var return_card: PlayerCard = null
	for player: PlayerCard in get_children():
		if player.player_card.order_number == order_number:
			return_card = player
			break

	return return_card

func _add_player_resource(player: PlayerResource) -> void:
	var instance: PlayerCard = player_template.instantiate() as PlayerCard
	instance.getting_deleted.connect(player_card_delete)
	instance.move_down_request.connect(func(id: int) -> void: _move_player(id, 1))
	instance.move_up_request.connect(func(id: int) -> void: _move_player(id, -1))
	instance.can_delete = player.id != multiplayer.get_unique_id()
	if !multiplayer.is_server():
		instance.can_delete = false
		instance.can_move = false
	instance.player_card = player
	add_child(instance)

func player_card_delete() -> void:
	for child: PlayerCard in get_children():
		if child is PlayerCard and child.delete_queued:
			var player: PlayerResource = child.player_card
			player_kicked.emit(player.id)

func clear_player_list() -> void:
	for child: PlayerCard in get_children():
		if child is PlayerCard:
			child.queue_free()

func player_disconnected(id: int) -> void:
	var player_found: bool = false
	for child: PlayerCard in get_children():
		if child is PlayerCard:
			if child.player_card.id == id:
				child.queue_free()
				player_found = true
	if not player_found:
		return
	_rebuild_order_numbers()
	_rebuild_list()