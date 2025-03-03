class_name PopupManager extends Control

signal pause_game()
signal continue_game()

var popupQueue: Array[PopupWindow] = []

func add_and_show_popup_unpaused(popup: PopupWindow):
	if !popup.popup_closed.is_connected(popup_closed):
		popup.popup_closed.connect(popup_closed)
	popupQueue.append(popup)
	show_next_popup(false)

func add_and_show_popup(popup: PopupWindow):
	if !popup.popup_closed.is_connected(popup_closed):
		popup.popup_closed.connect(popup_closed)
	popupQueue.append(popup)
	show_next_popup()

func show_next_popup(should_pause: bool = true):
	if popupQueue.size() == 0:
		for child in get_children():
			if child is Control:
				remove_child(child)
		unpause()
		return
	var popup = popupQueue.pop_front()
	if should_pause:
		pause_game.emit()
		mouse_filter = MOUSE_FILTER_STOP
	add_child(popup)
	popup.show()

func unpause():
	mouse_filter = MOUSE_FILTER_IGNORE
	continue_game.emit()

func popup_closed():
	show_next_popup()
