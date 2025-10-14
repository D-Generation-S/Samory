extends Node

class_name NameGenerator

const FIRST_NAME_FEMALE_LIST: String = "res://shared/entities/name_generator/assets/names/first_names.female.txt"
const FIRST_NAME_MALE_LIST: String =   "res://shared/entities/name_generator/assets/names/first_names.male.txt"

var first_female_names: Array[String] = []
var first_male_names: Array[String] = []
var last_names: Array[String] = []

func _init() -> void:
	load_name_list()

func get_random_name() -> String:
	var loot_table: LootTable = LootTable.new()
	loot_table.add_to_table(true, 10)
	loot_table.add_to_table(false, 10)
	var is_male: bool = loot_table.get_loot() as bool
	
	if is_male:
		return first_male_names.pick_random()
	
	return first_female_names.pick_random()

func load_name_list() -> void:
	if first_female_names.size() > 0 and last_names.size() > 0 and first_male_names.size() > 0:
		return
	first_female_names = read_file_content(FIRST_NAME_FEMALE_LIST)
	first_male_names = read_file_content(FIRST_NAME_MALE_LIST)
	
func read_file_content(path: String) -> Array[String]:
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file_access == null or file_access.get_error() != OK:
		return []
	var reading: bool = true
	var return_names: Array[String] = []
	while reading:
		var line: String = file_access.get_line()
		if line == null or line == "":
			reading = false
		return_names.append(line)

	file_access.close()
	return return_names
