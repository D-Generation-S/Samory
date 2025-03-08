extends ClickableButton

@export var node_to_close: Node

func _pressed():
	super()
	if node_to_close != null:
		queue_free()

