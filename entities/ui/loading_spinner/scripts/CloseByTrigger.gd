extends Control

func set_visibility(visibility: bool) -> void:
	visible = visibility

func remove() -> void:
	queue_free()

func set_active() -> void:
	set_visibility(true)

func set_inactive() -> void:
	set_visibility(false)