class_name MultiplayerLobby extends Node

const PORT: int = 8000

signal player_joined(name: String, id: int)
signal player_disconnected(id: int)

@export var debug_deck: MemoryDeckResource = null

var _peer: ENetMultiplayerPeer
var _is_started: bool = false
var _players: Array[PlayerResource] = []
var _local_player: PlayerResource = null
var _deck: MemoryDeckResource = null

var _player_name: String = ""

func _ready():
	print(_deck)
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	

func player_name_changed(new_name: String):
	_player_name = new_name

func _get_player_name() -> String:
	if _player_name != "":
		return _player_name
	var name_generator := NameGenerator.new()
	return name_generator.get_random_name()

func _player_connected(id: int):
	announce_name.rpc({
		"name": _local_player.name,
		"id": _local_player.id
	})

func _player_disconnected(id: int):
	player_disconnected.emit(id)
	var index = _players.find_custom(func(data: PlayerResource): return data.id == id)
	if index > 0:
		_players.remove_at(index)


func start_server():
	if _is_started:
		return
	_peer = ENetMultiplayerPeer.new()
	_peer.create_server(PORT)
	multiplayer.multiplayer_peer = _peer
	_is_started = true

	_local_player = PlayerResource.new()
	_local_player.name = _get_player_name()
	_local_player.id = multiplayer.get_unique_id()
	_local_player.score = 0
	_local_player.order_number = 0

	_players.append(_local_player)
	player_joined.emit(_local_player.name, _local_player.id)


func connect_to_server(ip: String):
	if _is_started:
		return
	_peer = ENetMultiplayerPeer.new()
	_peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = _peer
	_is_started = true

	_local_player = PlayerResource.new()
	_local_player.name = _get_player_name()
	_local_player.id = multiplayer.get_unique_id()
	_local_player.score = 0
	_local_player.order_number = 0
	_players.append(_local_player)
	player_joined.emit(_local_player.name, _local_player.id)
	multiplayer.server_disconnected.connect(func(): GlobalGameManagerAccess.game_manager.close_game())



@rpc("any_peer", "reliable")
func announce_name(data: Dictionary):
	var id: int = data["id"]
	var player_name: String = data["name"]
	player_joined.emit(player_name, id)
	if id == multiplayer.get_unique_id():
		return

	var new_player: PlayerResource = PlayerResource.new()
	new_player.name = player_name
	new_player.id = id
	new_player.score = 0
	new_player.order_number = 0
	_players.append(new_player)

func set_deck(deck: MemoryDeckResource):
	_deck = deck

func start_game(click_position: Vector2 = Vector2.ZERO):
	print(_deck)
	print("let's go!")
	if multiplayer.is_server():
		GlobalGameManagerAccess.get_game_manager().play_network_game(_players, _deck, click_position)

func announce_player_list():
	for player in _players:
		player_joined.emit(player.name, player.id)

func kick_player(id: int):
	if !multiplayer.is_server():
		pass
	multiplayer.multiplayer_peer.disconnect_peer(id)