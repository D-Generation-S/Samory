extends Control


func set_visibility(visibility: bool) -> void:
	visible = visibility

func remove() -> void:
	queue_free()