class_name PopupManager extends Control

signal pause_game()
signal continue_game()

var popupQueue: Array[PopupWindow] = []
var current_popup_id: int = 0

func add_and_show_popup(popup: PopupWindow):
	if !popup.popup_closed.is_connected(popup_closed):
		popup.popup_closed.connect(popup_closed)
	
	check_and_add_id(popup)
	popupQueue.append(popup)
	show_next_popup()

func show_next_popup():
	if popupQueue.size() == 0:
		for child in get_children():
			if child is Control:
				child.visible = false
				remove_child(child)
		unpause()
		return
	var active_popup = false
	for child in get_children():
		if child is PopupWindow:
			if child.visible:
				active_popup = true
				break
	
	if active_popup and !is_high_priority_popup_requested():
		return
	unpause()
	var popup = popupQueue.pop_front()
	check_and_add_id(popup)
	
	if popup.should_pause:
		pause_game.emit()
		mouse_filter = MOUSE_FILTER_STOP
	add_child(popup)
	popup.show()
	popup.popup_active()

func check_and_add_id(popup: PopupWindow):
	if popup.get_id() == -1:
		popup.set_id(current_popup_id)
		current_popup_id += 1

func is_high_priority_popup_requested() -> bool:
	var is_requested: bool = false
	var high_priority_popup = popupQueue.filter(func(popup: PopupWindow): return popup.high_priority and popup.should_pause)
	if high_priority_popup.size() > 0:
		handle_high_priority_popup()
		is_requested = true
	return is_requested

func handle_high_priority_popup():
	for child in get_children():
		if child is PopupWindow:
			child.popup_paused()
			remove_child(child)
			popupQueue.append(child)
	for child in popupQueue:
		if child.high_priority and child.should_pause:
			popupQueue.erase(child)
			popupQueue.insert(0, child)
	
func close_current_popup():
	for child in get_children():
		if child is PopupWindow:
			child.close_popup()
			break

func force_close_popup_with_id(id: int):
	for child in get_children():
		if child is PopupWindow:
			if child.get_id() == id:
				child.visible = false
				child.close_popup()
				break
	for child in popupQueue:
		if child.get_id() == id:
			popupQueue.erase(child)
			break

func unpause():
	mouse_filter = MOUSE_FILTER_IGNORE
	continue_game.emit()

func popup_closed():
	show_next_popup()
