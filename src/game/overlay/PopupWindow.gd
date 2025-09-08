class_name PopupWindow extends Control

@warning_ignore("unused_signal")
signal popup_closed()

var id: int = -1
var should_pause: bool = true
var high_priority: bool = false
var was_activated: bool = false

func get_id() -> int:
	return id

func set_id(new_id: int):
	id = new_id

func popup_active():
	pass

func popup_paused():
	pass