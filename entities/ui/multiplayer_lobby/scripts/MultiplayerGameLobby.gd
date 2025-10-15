class_name MultiplayerGameLobby extends CanvasLayer

signal set_player_namer(player_name: String)
signal start_server()
signal connect_server(ip: String)

var _local_user_name: String = ""
var _connect_ip: String = ""
var _is_host: bool = false

func _ready() -> void:
	set_player_namer.emit(_local_user_name)
	if _is_host:
		start_server.emit()
		return
	connect_server.emit(_connect_ip)

func set_player_name(local_player_name: String) -> void:
	_local_user_name = local_player_name

func set_connect_endpoint(ip: String) -> void:
	_connect_ip = ip
	_is_host = false

func start_as_host() -> void:
	_is_host = true