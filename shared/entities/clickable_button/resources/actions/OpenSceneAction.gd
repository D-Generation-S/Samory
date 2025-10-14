class_name OpenSceneAction extends ButtonAction

@export var scene_template: PackedScene
@export var transmit_click_position: bool = false

func execute(base: ClickableButton) -> void:
	if transmit_click_position:
		ScreenTransitionManager.transit_screen_with_position(scene_template, base.get_global_center_position())
		return
	ScreenTransitionManager.transit_screen(scene_template)
