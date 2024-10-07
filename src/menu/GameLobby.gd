extends CanvasLayer

class_name GameLobby

signal block_buttons()
signal enable_buttons()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func block_all_buttons():
	block_buttons.emit()

func enable_all_buttons():
	enable_buttons.emit()
