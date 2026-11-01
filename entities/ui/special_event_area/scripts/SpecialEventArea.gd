class_name SpecialEventArea extends Control

signal single_event()
signal add_event(event: SpecialEventBox)

## If autoload is enabled, all the events entered will be removed automatically.
## You should keep this disabled if you want to set the events by yourself
@export var autoload: bool = false
@export var autoload_path: String = "res://entities/ui/special_event_area/events/"
@export var all_events: Array[SpecialEvent] = []

var _valid_events: Array[SpecialEvent] = []

func _ready() -> void:
	_autoload_events()
	_valid_events = get_valid_events()
	if _valid_events.size() == 0:
		queue_free()
	if _valid_events.size() == 1:
		single_event.emit()
	
	for event: SpecialEvent in _valid_events:
		add_event.emit(event)

func _autoload_events() -> void:
	if not autoload:
		print_debug("Event autoload is disabled")
		return
	all_events.clear()
	for file: String in ResourceLoader.list_directory(autoload_path):
		if not file.ends_with(".tres"):
			continue
		var full_path: String = autoload_path + file
		var data: SpecialEvent = load(full_path)
		if data == null or not data is SpecialEvent:
			print_debug("Could not load %s because resource is not of type SpecialEvent" % full_path)
			continue
		all_events.append(data)

	print_debug("Loaded %d events to database" % all_events.size())

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

