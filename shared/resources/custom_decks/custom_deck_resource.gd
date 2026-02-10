class_name CustomDeckResource extends Resource

var _is_deck: bool = false
var _name: String = ""
var _description: String = ""
var _image_path: String = ""

func _init(is_deck: bool, entity_name: String, description: String, image_path: String) -> void:
	_is_deck = is_deck
	set_deck_name(entity_name)
	set_description(description)
	set_image(image_path)

func set_deck_name(name: String) -> void:
	_name = name

func set_description(description: String) -> void:
	_description = description

func set_image(path: String) -> void:
	_image_path = path

func get_deck_name() -> String:
	return _name

func get_description() -> String:
	return _description

func get_image_path() -> String:
	return _image_path

func get_is_deck() -> bool:
	return _is_deck