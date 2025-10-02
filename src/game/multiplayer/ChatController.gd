class_name ChatController extends Node

signal message_received(message: String)

@export var edit_field: LineEdit = null
@export var send_button: Button = null
@export var message_end: String = "\n"

func _ready():
	if edit_field == null or send_button == null:
		printerr("Missing button or edit field")
		queue_free()
		return
	send_button.pressed.connect(_pressed)
	edit_field.text_submitted.connect(_send_text)


func _pressed():
	_send_text(edit_field.text)
	pass

func _send_text(text: String):
	rpc_send_message.rpc(text)
	edit_field.text = ""

var _players: Dictionary = {}

func player_added(player_name: String, id: int):
	_players[id] = player_name

func player_deleted(id: int):
	if _players.has(id):
		_players.erase(id)

@rpc("any_peer", "call_local")
func rpc_send_message(message: String):
	var sender_id = multiplayer.get_remote_sender_id()
	var player_name = _players.get_or_add(sender_id, "UNKNOWN")

	message_received.emit("%s: %s%s" % [player_name, message, message_end])
	pass
