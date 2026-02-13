extends HBoxContainer

func disable_buttons() -> void:
	for child: Control in get_children():
		if child is Button:
			child.disabled = true

func enable_buttons() -> void:
	for child: Control in get_children():
		if child is Button:
			child.disabled = false