class_name GamePauseMenu extends PopupWindow

signal close_pause_menu()

func close_menu():
	visible = false
	popup_closed.emit()
	queue_free()