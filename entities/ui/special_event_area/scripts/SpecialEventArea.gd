class_name SpecialEventArea extends Control

signal single_event()
signal add_event(event: SpecialEventBox)

@export var all_events: Array[SpecialEvent] = []

var _valid_events: Array[SpecialEvent] = []

func _ready() -> void:
	_valid_events = get_valid_events()
	if _valid_events.size() == 0:
		queue_free()
	if _valid_events.size() == 1:
		single_event.emit()
	
	for event: SpecialEvent in _valid_events:
		add_event.emit(event)

func get_valid_events() -> Array[SpecialEvent]:
	var valid: Array[SpecialEvent] = []
	var date_dictionary: Dictionary = Time.get_date_dict_from_system()
	var year: int = date_dictionary.get("year")
	var month: int = date_dictionary.get("month")
	var day: int = date_dictionary.get("day")
	for event: SpecialEvent in all_events:
		if event.is_valid_today(year, month, day):
			valid.append(event)

	return valid

