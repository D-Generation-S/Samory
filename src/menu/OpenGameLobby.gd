extends Button

@export var game_lobby_template: PackedScene

func _pressed():
	var game_manager = get_tree().root.get_child(0) as GameManager
	game_manager.open_menu(game_lobby_template)
