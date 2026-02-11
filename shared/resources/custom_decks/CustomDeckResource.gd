class_name CustomDeckResource extends Resource

var _id: int = 0
var _is_deck: bool = false
var _file_name: String = ""
var _name: String = ""
var _description: String = ""
var _image_path: String = ""

var loaded_texture: Texture2D = null

func _init(id: int, is_deck: bool, entity_name: String, description: String, image_path: String) -> void:
	_id = id
	_is_deck = is_deck
	set_deck_name(entity_name)
	set_description(description)
	set_image(image_path)
	if _file_name == "" and is_deck:
		_file_name = entity_name

func set_id(id: int) -> void:
	_id = id

func set_deck_name(name: String) -> void:
	_name = name
	print(_name)

func set_description(description: String) -> void:
	_description = description

func set_image(path: String) -> void:
	_image_path = path

func update_file_name(new_file_name: String) -> void:
	_file_name = new_file_name

func get_resource_name() -> String:
	return _name

func get_file_name() -> String:
	return _file_name

func get_description() -> String:
	return _description

func get_image_path() -> String:
	return _image_path

func get_is_deck() -> bool:
	return _is_deck

func get_id() -> int:
	return _id