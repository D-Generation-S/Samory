class_name NthDayInMonth extends SpecialEventValidation

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

@export_enum("Sunday:0",
			"Monday:1",
			"Tuesday:2",
			"Wednesday:3",
			"Thursday:4",
			"Friday:5",
			"Saturday:6") var target_weekday: int = 0

@export_range(1, 5, 1) var nth_occurrence: int = 1

func validate(year: int, month: int, day: int) -> bool:
	if month != valid_month:
		return false
	var unix_time: int = Time.get_unix_time_from_datetime_dict({
		"year": year,
		"month": month,
		"day": day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	var current_data: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	var current_weekday: int = current_data["weekday"]

	if current_weekday != target_weekday:
		return false
	var calculated_offset: int = int(ceilf(day / 7.0))
	return calculated_offset == nth_occurrence

func _process_text(translated_text: String, year: int, month: int, day: int) -> String:
	translated_text = translated_text.replace("%DATE%", _get_date_template(year, month, day))
	translated_text = translated_text.replace("%CURRENT_YEAR%", str(year))
	return translated_text

