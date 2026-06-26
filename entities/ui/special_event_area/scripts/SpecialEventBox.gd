class_name SpecialEventBox extends PanelContainer

signal text_changed(new_text: String)

var _event: SpecialEvent = null

func set_event(event: SpecialEvent) -> void:
	_event = event

func _ready() -> void:
	if _event == null:
		queue_free()
	
	text_changed.emit(_event.get_text())