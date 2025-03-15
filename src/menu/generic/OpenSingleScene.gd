extends ClickableButton

@export var scene_template: PackedScene

func _pressed():
	super()
	ScreenTransitionManager.transit_screen(scene_template)
	#GlobalGameManagerAccess.get_game_manager().open_menu(scene_template)
