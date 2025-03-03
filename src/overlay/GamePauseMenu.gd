class_name GamePauseMenu extends PopupWindow

#signal close_pause_menu()

func close_menu():
	popup_closed.emit()
	
	#close_pause_menu.emit()