class_name ChatController extends Node

signal message_received(message: String)

@export var edit_field: LineEdit = null
@export var send_button: Button = null
@export var message_end: String = "\n"

func _ready() -> void:
	if edit_field == null or send_button == null:
		printerr("Missing button or edit field")
		queue_free()
		return
	send_button.pressed.connect(_pressed)
	edit_field.text_submitted.connect(_send_text)


func _pressed() -> void:
	_send_text(edit_field.text)
	pass

func _send_text(text: String) -> void:
	rpc_send_message.rpc(text)
	edit_field.text = ""

var _players: Dictionary = {}

func player_added(player_name: String, id: int) -> void:
	_players[id] = player_name

func player_deleted(id: int) -> void:
	if _players.has(id):
		_players.erase(id)

func players_updated(players: Array[PlayerResource]) -> void:
	_players.clear()
	for player: PlayerResource in players:
		player_added(player.name, player.id)

@rpc("any_peer", "call_local")
func rpc_send_message(message: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	var player_name: String = _players.get_or_add(sender_id, "UNKNOWN")

	message_received.emit("%s: %s%s" % [player_name, message, message_end])
