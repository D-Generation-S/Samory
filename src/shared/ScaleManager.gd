extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var game_manager: GameManager = GlobalGameManagerAccess.get_game_manager()
	await game_manager.ready

	get_window().content_scale_factor = game_manager.get_ui_scale()

	queue_free()

