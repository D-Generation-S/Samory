class_name EasternDateValidation extends SpecialEventValidation
## Calculation is based on https://www.scientificamerican.com/article/the-mathematical-formula-that-reveals-when-easter-is-every-year/

const MARCH_MONTH_NUMBER: int = 3
const MARCH_NUMBER_OF_DAYS: int = 31

func validate(year: int, month: int, day: int) -> bool:
	var a: int = year % 19
	var b: int = year % 4
	var c: int = year % 7

	var k: int = floori(year / 100)
	var p: int = floori(k / 3)
	var q: int = floori(k / 4)

	var m: int = 15 + k - p - q
	var d: int = (m + 19 * a) % 30

	var n: int = (4 + k - q) % 7
	var e: int = (2 * b +4 * c + 6 * d + n) % 7
	var day_of_month: int = 22 + d + e
	if d == 29 and e == 6:
		day_of_month = 50
	if d == 28 and e == 6 and a > 10:
		day_of_month = 49
	
	var eastern_month: int = MARCH_MONTH_NUMBER
	if day_of_month > MARCH_NUMBER_OF_DAYS:
		day_of_month -= MARCH_NUMBER_OF_DAYS
		eastern_month += 1
	
	return eastern_month == month and day_of_month == day

func _process_text(translated_text: String, year: int, _month: int, _day: int) -> String:
	return translated_text.replace("%YEAR%", str(year))