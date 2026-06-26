class_name SpecialEvent extends Resource

@export var event_name: TextTranslation = null
@export var event_text: TextTranslation = null
@export_group("Valid Date")
@export_enum("January:1",
			"February:2",
			"March:3",
			"April:4",
			"Mai:5",
			"June:6",
			"July:7",
			"August:8",
			"September:9",
			"October:10",
			"November:11",
			"December:12") var valid_month: int = 1
@export_range(1, 31, 1.0) var valid_day: int = 1
## This value is getting used to calculate the difference between the current year and the year provided
@export var year: int = 2026


func is_valid_today(day: int, month: int ) -> bool:
	var content_present: bool = event_name != null and event_text != null
	return content_present and valid_month == month and valid_day == day 

func get_text() -> String:
	var text: String = tr(event_text.key)
	text = text.replace("%DATE%", _get_date_template())
	text = text.replace("%DIFFERENCE%", str(Time.get_date_dict_from_system()["year"] - year))
	return "[center]%s[/center][hr][br]%s" % [_get_headline(), text]

func _get_headline() -> String:
	return tr(event_name.key)

func _get_date_template() -> String:
	return "%02d.%02d" % [valid_day, valid_month]
