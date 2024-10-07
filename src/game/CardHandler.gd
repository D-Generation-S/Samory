extends Area2D

signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()
	
