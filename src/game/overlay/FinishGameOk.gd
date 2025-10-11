extends ClickableButton


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func _pressed():
	super()
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	GlobalGameManagerAccess.get_game_manager().close_game_with_position(get_global_center_position())
