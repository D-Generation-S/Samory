class_name CloseLobbyButton extends ClickableButton

func _pressed() -> void:
	super()
	multiplayer.multiplayer_peer.close()
	GlobalGameManagerAccess.game_manager.close_game_with_position(get_global_center_position())

	
