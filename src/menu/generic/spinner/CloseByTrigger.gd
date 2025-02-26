extends Control


func set_visibility(visibility: bool):
	visible = visibility

func remove():
	queue_free()