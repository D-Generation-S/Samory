extends HBoxContainer

signal min_value_changed(new_value: float)
signal max_value_changed(new_value: float)
signal value_changed(new_value: float)

@export_range(0.1, 5) var min_value: float = 0.3
@export_range(0.1, 5) var max_value: float = 3

var _current_value: float = 1

func _ready() -> void:
	if min_value > max_value:
		printerr("Min value cannot be larger than max value!")
		for child: Node in get_children():
			child.queue_free()
		queue_free()

func settings_changed(new_settings: SettingsResource) -> void:
	min_value_changed.emit(min_value)
	max_value_changed.emit(max_value)
	value_changed.emit(new_settings.ui_scale_factor)

func update_preview(_changed: bool) -> void:
	ScaleManager.update_ui_scale(_current_value)

func value_was_changed(new_value: float) -> void:
	_current_value = new_value
