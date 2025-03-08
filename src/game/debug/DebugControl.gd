extends Control

func _ready():
	GlobalGameManagerAccess.game_manager.debug_mode.connect(toggle_debug)
	visible = false

func toggle_debug(on: bool):
	if !OS.is_debug_build():
		return
	visible = on
