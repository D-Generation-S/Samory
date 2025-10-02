class_name MultiplayerChat extends Node

var show_if_no_peer_available: bool = false

func _ready() -> void:
	if show_if_no_peer_available:
		return
	await get_tree().physics_frame
	if multiplayer.multiplayer_peer == null:
		queue_free()
