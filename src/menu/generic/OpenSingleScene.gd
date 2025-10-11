extends ClickableButton

@export var scene_template: PackedScene
@export var transmit_click_position: bool = false
@export var available_on_mobile_and_web: bool = true

func _ready():
	if !available_on_mobile_and_web:
		if OS.has_feature("web") or OS.has_feature("web_ios") or OS.has_feature("web_android"):
			queue_free()

func _pressed():
	super()
	if transmit_click_position:
		ScreenTransitionManager.transit_screen_with_position(scene_template, get_global_center_position())
		return
	ScreenTransitionManager.transit_screen(scene_template)
