
class_name ColorResource extends Resource

@export var color: Color

func get_color() -> Color:
	return color

func get_color_bb_code() -> String:
	return "[color=#" + get_color().to_html() + "]"
