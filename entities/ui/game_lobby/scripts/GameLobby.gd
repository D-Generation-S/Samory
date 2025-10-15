extends CanvasLayer

class_name GameLobby

signal toggle_buttons(on: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func block_all_buttons() -> void:
	toggle_all_buttons(false)

func enable_all_buttons() -> void:
	toggle_all_buttons(true)

func toggle_all_buttons(on: bool) -> void:
	toggle_buttons.emit(on)
