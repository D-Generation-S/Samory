@tool
extends Node

signal append_new_text(new_value: String)
signal initial_text_changed(new_text: String)
signal animation_playing()
signal animation_done()

@export var initial_text: String = "":
	set(value):
		initial_text = value
		initial_text_changed.emit(value)

func add_new_text(new_value: String) -> void:
	append_new_text.emit(new_value)

func animation_state_changed(new_state: bool) -> void:
	if new_state:
		animation_playing.emit()
		return

	animation_done.emit()
