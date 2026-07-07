class_name FixedDateValidation extends SpecialEventValidation

@export_group("Valid year")
## If this is set to true, you need to enter a year. This event will only be active if the provided year is set
@export var single_event: bool = false
## The time this event appear the first time, if single event is set the event will only be shown in that year and never again
## This will also be used to calculate the difference between the actual year and this value
@export_range(2000, 3000, 1) var valid_year: int = 2000
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

func validate(year: int, month: int, day: int) -> bool:
	var year_check: bool = not single_event or year == valid_year
	return year_check and month == valid_month and valid_day == day

func _process_text(translated_text: String, year: int, month: int, day: int) -> String:
	translated_text = translated_text.replace("%DATE%", _get_date_template(year, month, day))
	translated_text = translated_text.replace("%DIFFERENCE%", str(year - valid_year))
	return translated_text
	

func _get_date_template(year: int, month: int, day: int) -> String:
	return "%02d.%02d.%04d" % [day, month, year]