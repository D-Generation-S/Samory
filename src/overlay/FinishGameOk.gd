extends ClickableButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	super()
	var root_node = get_tree().root.get_child(0) as GameManager
	root_node.close_game()
