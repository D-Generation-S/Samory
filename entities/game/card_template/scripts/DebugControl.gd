extends Control

func _ready() -> void:
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	if game_manager == null:
		queue_free()
		return
	game_manager.debug_mode.connect(toggle_debug)
	visible = false

func toggle_debug(on: bool) -> void:
	if !OS.is_debug_build():
		return
	visible = on
