extends Button

@export var scene_template: PackedScene

func _pressed():
	var game_manager = get_tree().root.get_child(0) as GameManager
	game_manager.open_menu(scene_template)
