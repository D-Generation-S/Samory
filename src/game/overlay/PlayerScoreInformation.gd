class_name PlayerScoreInformation extends Label

@export var inactive_color: ColorResource = null
@export var active_color: ColorResource = null
@export var animation_duration: float = 0.4

func _ready():
	set("theme_override_colors/font_color", inactive_color.color)

func is_now_active():
	var tween_animation = create_tween()
	tween_animation.tween_property(self, "theme_override_colors/font_color", active_color.color, animation_duration)

func is_now_inactive():
	var tween_animation = create_tween()
	tween_animation.tween_property(self, "theme_override_colors/font_color", inactive_color.color, animation_duration)