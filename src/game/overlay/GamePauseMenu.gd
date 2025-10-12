class_name GamePauseMenu extends PopupWindow

@warning_ignore("unused_signal")
signal close_pause_menu()

func close_menu() -> void:
	visible = false
	popup_closed.emit()
	queue_free()