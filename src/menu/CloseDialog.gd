extends Button

@export var node_to_close: Node

func _pressed():
	if node_to_close != null:
		queue_free()

