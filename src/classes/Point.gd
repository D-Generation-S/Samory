extends Node

class_name Point

var x_pos: int = 0
var y_pos: int = 0

func _init(x: int , y: int):
    x_pos = x
    y_pos = y

func get_x_pos()  -> int:
    return x_pos

func get_y_pos() -> int:
    return y_pos

func set_x_pos(x: int) -> void:
    x_pos = x

func set_y_pos(y: int) -> void:
    y_pos = y

func is_identical(other_point: Point) -> bool:
    return other_point.get_x_pos() == x_pos and other_point.get_y_pos() == y_pos

func get_distance(other_point: Point) -> float:
    return sqrt(pow(x_pos - other_point.x_pos, 2) + pow(y_pos - other_point.y_pos, 2))

