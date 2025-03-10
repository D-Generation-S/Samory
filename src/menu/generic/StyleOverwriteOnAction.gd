extends Control

@export var style_to_use: StyleBoxTexture

var initial_style: StyleBoxTexture

func _ready():
	initial_style = get("theme_override_styles/panel")

func is_active():
	set_style(style_to_use)

func is_inactive():
	set_style(initial_style)

func set_style(new_style: StyleBoxTexture):
	if new_style == null:
		return
	set("theme_override_styles/panel", new_style)
