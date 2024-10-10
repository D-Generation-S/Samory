extends Node

class_name Point

var x_pos: int = 0
var y_pos: int = 0

func _init(x: int , y: int):
    x_pos = x
    y_pos = y

func get_x_pos():
    return x_pos

func get_y_pos():
    return y_pos

func set_x_pos(x: int):
    x_pos = x

func set_y_pos(y: int):
    y_pos = y

func is_identical(other_point: Point) -> bool:
    return other_point.get_x_pos() == x_pos and other_point.get_y_pos() == y_pos