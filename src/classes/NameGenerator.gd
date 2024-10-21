extends Node

class_name NameGenerator

const FIRST_NAME_FEMALE_LIST = "res://assets/names/first_names.female.txt"
const FIRST_NAME_MALE_LIST =   "res://assets/names/first_names.male.txt"

var first_female_names: Array[String] = []
var first_male_names: Array[String] = []
var last_names: Array[String] = []

func get_random_name() -> String:
    load_name_list()
    var is_male = false
    var male_random = randi() % 20
    if male_random < 9:
        is_male = true
    
    if is_male:
        var m_index = randi() % first_male_names.size()
        return first_male_names[m_index]
    
    var f_index = randi() % first_female_names.size()
    return first_female_names[f_index]

func load_name_list():
    if first_female_names.size() > 0 and last_names.size() > 0 and first_male_names.size() > 0:
        return
    first_female_names = read_file_content(FIRST_NAME_FEMALE_LIST)
    first_male_names = read_file_content(FIRST_NAME_MALE_LIST)
    
func read_file_content(path: String) -> Array[String]:
    var f = FileAccess.open(path, FileAccess.READ)
    if f == null or f.get_error() != OK:
        return []
    var reading = true
    var return_names: Array[String] = []
    while reading:
        var line = f.get_line()
        if line == null or line == "":
            reading = false
        return_names.append(line)

    f.close()
    return return_names
