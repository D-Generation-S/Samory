class_name SpecialEventBox extends PanelContainer

signal text_changed(new_text: String)

var _event: SpecialEvent = null

func set_event(event: SpecialEvent) -> void:
	_event = event

func _ready() -> void:
	if _event == null:
		queue_free()
	var date_dictionary: Dictionary = Time.get_date_dict_from_system()
	var year: int = date_dictionary.get("year")
	var month: int = date_dictionary.get("month")
	var day: int = date_dictionary.get("day")
	text_changed.emit(_event.get_text(year, month, day))