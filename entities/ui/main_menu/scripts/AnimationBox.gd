class_name AnimationBox extends Control

var controls: Dictionary[Control, Control.MouseFilter] = {}

func _ready() -> void:
	for child: Node in get_children():
		if child is Control:
			controls.set(child, child.mouse_filter)
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_mouse_input() -> void:
	for control: Control in controls.keys():
		if controls.has(control):
			control.mouse_filter = controls.get(control)