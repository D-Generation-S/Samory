
class_name ColorResource extends Resource

@export_color_no_alpha var color: Color

func get_color() -> Color:
	return color

func get_color_bb_code() -> String:
	return "[color=#" + get_color().to_html() + "]"
