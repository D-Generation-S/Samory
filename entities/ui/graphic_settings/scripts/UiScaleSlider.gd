extends HSlider

func decrease() -> void:
	_set_value(value - step)

func increase() -> void:
	_set_value(value + step)

func reset_scaling() -> void:
	_set_value(1)

func _set_value(new_value: float) -> void:
	value = clampf(new_value, min_value, max_value)
	drag_ended.emit(true)