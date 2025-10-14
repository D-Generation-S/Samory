class_name OpenMainMenu extends ButtonAction

func execute(base: ClickableButton) -> void:
	if base.multiplayer.multiplayer_peer != null:
		base.multiplayer.multiplayer_peer.close()
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(base.get_global_center_position())
