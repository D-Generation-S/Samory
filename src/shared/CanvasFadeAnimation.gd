extends ColorRect

@export var fade_color: Color = Color.BLACK

func _ready() -> void:
	color = fade_color
	mouse_filter = MOUSE_FILTER_STOP
	color.a = 0

func transition_step(step_number: float) -> void:
	if step_number == 1:
		print("ignore")
		mouse_filter = MOUSE_FILTER_IGNORE
	color.a = step_number
