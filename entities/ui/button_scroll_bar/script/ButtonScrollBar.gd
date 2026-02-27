@tool
extends HBoxContainer

signal min_value_changed(new_value: float)
signal max_value_changed(new_value: float)
signal step_size_changed(new_value: float)
signal value_changed(new_value: float)
signal force_set_value(new_value: float)
signal drag_ended(value_changed: bool)

@export var initial_value: float = 1;

@export_range(0.1, 5) var min_value: float = 0.3:
	set(value):
		min_value = value
		min_value_changed.emit(value)
@export_range(0.1, 5) var max_value: float = 3:
	set(value):
		max_value = value
		max_value_changed.emit(value)
@export_range(0.05, 10, 0.05) var step_size: float = 0.05:
	set(value):
		step_size = value
		step_size_changed.emit(value)

func reset() -> void:
	set_value(initial_value)

func set_value(new_value: float) -> void:
	force_set_value.emit(new_value)

func change_value(value: float) -> void:
	value_changed.emit(value)

func drag_has_ended(value: bool) -> void:
	drag_ended.emit(value)