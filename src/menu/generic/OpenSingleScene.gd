extends ClickableButton

@export var scene_template: PackedScene
@export var transmit_click_position: bool = false

func _pressed():
	super()
	if transmit_click_position:
		
		ScreenTransitionManager.transit_screen_with_position(scene_template, get_global_center_position())
		return
	ScreenTransitionManager.transit_screen(scene_template)
	#GlobalGameManagerAccess.get_game_manager().open_menu(scene_template)
