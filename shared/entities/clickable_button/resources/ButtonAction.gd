class_name ButtonAction extends Resource


@warning_ignore("UNUSED_SIGNAL")
signal can_execute_changed()

func execute(_base: ClickableButton) -> void:
	pass

func stop() -> void:
	pass

func can_execute() -> bool:
	return true