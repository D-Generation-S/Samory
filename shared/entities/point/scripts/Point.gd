## This whole class is not needed, as there is already something which can be used as a point.
## As this calls is used all over the code, it was refactored to extend the Vector2i class instead.
## This is therefore a wrapper, more or less.
class_name Point extends Node

var position: Vector2i = Vector2i.ZERO

func _init(x: int , y: int) -> void:
	set_x_pos(x)
	set_y_pos(y)

func get_x_pos()  -> int:
	return position.x

func get_y_pos() -> int:
	return position.y

func set_x_pos(x: int) -> void:
	position.x = x

func set_y_pos(y: int) -> void:
	position.y = y

func is_identical(other_point: Point) -> bool:
	return other_point.get_x_pos() == get_x_pos() and other_point.get_y_pos() == get_y_pos()

func get_distance(other_point: Point) -> float:
	return sqrt(pow(get_x_pos() - other_point.get_x_pos(), 2) + pow(get_y_pos() - other_point.get_y_pos(), 2))

func get_network_data() -> Dictionary:
	return {
		"x": position.x,
		"y": position.y
	}