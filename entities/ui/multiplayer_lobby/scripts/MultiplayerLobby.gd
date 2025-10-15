class_name MultiplayerLobby extends Node

const PORT: int = 8000

signal player_joined(name: String, id: int)
signal clear_players()
signal player_disconnected(id: int)

signal announce_error_message(message: String)
signal show_error_popup(popup: PopupWindow)
signal send_chat_message(message: String)

signal connection_established()

@export_group("Error messages")
@export var error_reason_group: String = "disconnect_reason"
@export var popup_window_template: PackedScene = null
@export var wrong_version_translation: TextTranslation = null
@export var kicked_by_server: TextTranslation = null
@export var connection_failed: TextTranslation = null

@export_group("Chat messages")
@export var player_joined_message: TextTranslation = null
@export var player_left_message: TextTranslation = null
@export var player_kicked_message: TextTranslation = null
@export var deck_has_been_changed: TextTranslation = null

var _peer: ENetMultiplayerPeer
var _is_started: bool = false
var _players: Array[PlayerResource] = []
var _local_player: PlayerResource = null
var _deck: MemoryDeckResource = null

var _player_name: String = ""
var _local_id: int = -1

func _ready() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)

func player_name_changed(new_name: String) -> void:
	_player_name = new_name

func _get_player_name() -> String:
	if _player_name != "":
		return _player_name
	var name_generator: NameGenerator = NameGenerator.new()
	return name_generator.get_random_name()

func _player_connected(_id: int) -> void:
	announce_name.rpc({
		"name": _get_player_name(),
		"id": _local_id
	})
	_rpc_announce_game_version.rpc(ProjectSettings.get_setting("application/config/version"))

@rpc("any_peer", "reliable")
func _rpc_announce_game_version(version: String) -> void:
	if !multiplayer.is_server():
		return

	var server_version: Variant = ProjectSettings.get_setting("application/config/version")
	if server_version != version:
		_communicate_disconnect_reason.rpc(multiplayer.get_remote_sender_id(), tr(wrong_version_translation.key) % [version, server_version])
		_rpc_enforce_disconnect.rpc(multiplayer.get_remote_sender_id())

@rpc("authority", "reliable")
func _communicate_disconnect_reason(id: int, reason: String) -> void:
	if multiplayer.is_server() or multiplayer.get_unique_id() != id:
		return
	_close_with_error(reason)

func _player_disconnected(id: int, sync_requested: bool = true) -> void:
	player_disconnected.emit(id)
	var index: int = _players.find_custom(func(data: PlayerResource) -> bool: return data.id == id)
	if index > 0:
		send_chat_message.emit(tr(player_left_message.key) % _players[index].get_display_name())
		_players.remove_at(index)
		if sync_requested:
			sync_player_list()

func start_server() -> void:
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

func connect_to_server(ip: String) -> void:
	if _is_started:
		return
	_peer = ENetMultiplayerPeer.new()
	multiplayer.connection_failed.connect(func() -> void: _close_with_error(tr(connection_failed.key) % ip, true))
	multiplayer.connected_to_server.connect(func() -> void: connection_established.emit())
	if _peer.create_client(ip, PORT) != OK or ip == "":
		_close_with_error(tr(connection_failed.key) % "non provided", true)
		return
	multiplayer.multiplayer_peer = _peer

	_is_started = true
	_local_id = multiplayer.get_unique_id()
	
	multiplayer.server_disconnected.connect(_server_closed_connection)

func _close_with_error(error: String, autoclose: bool = false) -> void:
		_show_error_popup(error)
		announce_error_message.emit(error)
		if autoclose and multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.close()

func _server_closed_connection() -> void:
	if get_tree().get_node_count_in_group(error_reason_group) > 0:
		return
	#GlobalGameManagerAccess.game_manager.close_game()

@rpc("any_peer", "reliable")
func announce_name(data: Dictionary) -> void:
	if !multiplayer.is_server():
		return

	var id: int = data["id"]
	var player_name: String = data["name"]
	if _players.any(func(player: PlayerResource) -> bool: return player.id == id):
		return
	player_joined.emit(player_name, id)
	if id == multiplayer.get_unique_id():
		return


	var new_player: PlayerResource = PlayerResource.new()
	new_player.name = player_name
	new_player.id = id
	new_player.score = 0
	new_player.order_number = 0
	_players.append(new_player)

	send_chat_message.emit(tr(player_joined_message.key) % player_name)

	sync_player_list()
	
func sync_player_list() -> void:
	if !multiplayer.is_server():
		return
	var player_data: Array[Dictionary] = []

	for player: PlayerResource in _players:
		_validate_and_disconnect_player(player)
		player_data.append(player.get_network_data_set())

	rpc_sync_player_list.rpc({"players": player_data})

func _cleanup_player_list(sync_requested: bool = true) -> void:
	for player: PlayerResource in _players:
		_validate_and_disconnect_player(player, sync_requested)

func _validate_and_disconnect_player(player: PlayerResource, sync_requested: bool = true) -> void:
	if player.id != multiplayer.get_unique_id() and !_peer_id_is_connected(player.id):
		_player_disconnected(player.id, sync_requested)

func _peer_id_is_connected(id: int) -> bool:
	for current_peer: int in multiplayer.get_peers():
		if current_peer == id:
			return true

	return false

@rpc("authority", "reliable")
func rpc_sync_player_list(data: Dictionary) -> void:
	if multiplayer.is_server():
		return
	var players_to_sync: Array = data.get_or_add("players", [])
	if players_to_sync.size() > 0:
		_players.clear()
		clear_players.emit()
	for player: Dictionary in players_to_sync:
		var new_player: PlayerResource= PlayerResource.from_network_data(player)
		
		player_joined.emit(new_player.name, new_player.id)
		_players.append(new_player)

func set_deck(deck: MemoryDeckResource) -> void:
	_deck = deck
	if _deck != null:
		send_chat_message.emit(tr(deck_has_been_changed.key) % _deck.name)

func start_game(click_position: Vector2 = Vector2.ZERO) -> void:
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.refuse_new_connections = true
		GlobalGameManagerAccess.get_game_manager().play_network_game(_players, _deck, click_position)

func announce_player_list() -> void:
	for player: PlayerResource in _players:
		player_joined.emit(player.name, player.id)

func kick_player(id: int) -> void:
	if !multiplayer.is_server():
		return
	_communicate_disconnect_reason.rpc(id, tr(kicked_by_server.key))
	_rpc_enforce_disconnect.rpc(id)
	var index: int = _players.find_custom(func(item: PlayerResource) -> bool: return item.id == id)
	if index > 0:
		send_chat_message.emit(tr(player_kicked_message.key) % _players[index].get_display_name())
		_player_disconnected(id)

@rpc("authority", "reliable")
func _rpc_enforce_disconnect(id: int) -> void:
	if id != multiplayer.get_unique_id():
		return
	multiplayer.multiplayer_peer.close()

func _show_error_popup(text: String) -> void:
	if popup_window_template == null or text == null or text == "":
		return
	var template: PopupWindow = popup_window_template.instantiate() as PopupWindow
	if template == null:
		return
	template.popup_closed.connect(func() -> void: GlobalGameManagerAccess.game_manager.close_game())
	template.add_to_group(error_reason_group)
	show_error_popup.emit(template)
	template.show_window("title", text, false)

func player_list_order_changed(players: Array[PlayerResource]) -> void:
	_cleanup_player_list(false)
	if _players.size() != players.size():
		return
	_players = players
	sync_player_list()
