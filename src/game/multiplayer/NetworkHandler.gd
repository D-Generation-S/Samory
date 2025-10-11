extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 8000

signal player_has_changed(player_id: int)
signal player_has_scored(player_id: int, new_score: int)
signal card_was_clicked(position: Point)
signal remove_card(position: Point)
signal game_state_has_changed(new_state: int)
signal game_has_been_finished()
signal request_popup(window: PopupWindow)

@export var finished_game_template: PackedScene
@export var player_node: PlayerManager

var peer: ENetMultiplayerPeer
var is_started: bool = false

func _ready():
	if multiplayer == null or multiplayer.multiplayer_peer == null:
		queue_free()
	if multiplayer.get_peers().size() == 0:
		queue_free()
	
	if !multiplayer.is_server():
		multiplayer.server_disconnected.connect(server_gone)
		return
	multiplayer.peer_disconnected.connect(peer_gone)

func server_gone():
	GlobalGameManagerAccess.game_manager.close_game_with_position(Vector2.ZERO)

func peer_gone(_id: int):
	server_gone()
	multiplayer.multiplayer_peer.close()

func card_clicked(_game_state: int, clicked_cards: Array[CardTemplate]):
	for card in clicked_cards:
		_rpc_card_clicked.rpc(card.grid_position.get_network_data())

@rpc("any_peer", "reliable")
func _rpc_card_clicked(position: Dictionary):
	print(multiplayer.get_remote_sender_id())
	print(multiplayer.get_unique_id())
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		return
	var point:Point = Point.new(position["x"], position["y"])

	card_was_clicked.emit(point)

func game_state_changed(state: int):
	if multiplayer.is_server():
		_rpc_game_state_changed.rpc({"state-id": state})

@rpc("authority", "reliable")
func _rpc_game_state_changed(state: Dictionary):
	var state_id: int = state["state-id"]
	if state_id == GameState.ROUND_FREEZE:
		game_state_has_changed.emit(state_id)
	if state_id == GameState.ROUND_END:
		game_state_has_changed.emit(state_id)

func player_changed(player: PlayerResource):
	if !multiplayer.is_server():
		return
	
	_rpc_player_changed.rpc({
		"name": player.name,
		"score": player.score,
		"id": player.id
	})

	if player.id != multiplayer.get_unique_id():
		print("freeze")
		game_state_has_changed.emit(GameState.ROUND_FREEZE)
		return

	game_state_has_changed.emit(GameState.ROUND_START)

@rpc("authority", "reliable")
func _rpc_player_changed(player: Dictionary):
	var player_id = player["id"]
	player_has_changed.emit(player_id)
	print("compare")
	print(player_id)
	print(multiplayer.get_unique_id())
	if player_id != multiplayer.get_unique_id():
		print("freeze")
		game_state_has_changed.emit(GameState.ROUND_FREEZE)
		return

	game_state_has_changed.emit(GameState.ROUND_START)

func player_scored(player: PlayerResource):
	if !multiplayer.is_server():
		return
	_rpc_player_scored.rpc({
		"name": player.name,
		"score": player.score,
		"id": player.id
	})

@rpc("authority", "reliable")
func _rpc_player_scored(player: Dictionary):
	player_has_scored.emit(player["id"], player["score"])

func matching_pair(first: Point, second: Point):
	if !multiplayer.is_server():
		return
	var card_data: Array[Dictionary] = [first.get_network_data(), second.get_network_data()]

	var dict: Dictionary = {"cards": card_data}
	_rpc_remove_cards.rpc(dict)

@rpc("authority", "reliable")
func _rpc_remove_cards(array_data: Dictionary):
	var data: Array[Dictionary] = array_data.get_or_add("cards", []);
	for card in data:
		var point: Point = Point.new(card["x"], card["y"])
		remove_card.emit(point)
	
func end_game():
	rpc_game_ended.rpc()

@rpc("authority", "reliable")
func rpc_game_ended():
	if multiplayer.is_server():
		return
	game_has_been_finished.emit()
	
	var finish_node = finished_game_template.instantiate() as GameFinished
	finish_node.high_priority = true
	finish_node.set_player_manager(player_node)
	request_popup.emit(finish_node)