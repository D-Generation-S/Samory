class_name ServerInformation extends Resource

var _id: int = -1
var _ip: String = ""
var _version: String = ""
var _date_time: float = 0.0

func _init(ip: String, version: String)-> void:
	_ip = ip
	_version = version
	update_date_time()

func set_unique_id(id: int) -> void:
	_id = id

func get_unique_id() -> int:
	return _id

func get_ip() -> String:
	return _ip

func get_version() -> String:
	return _version

func get_creation_date_unix() -> float:
	return _date_time

func update_date_time() -> void:
	_date_time = Time.get_unix_time_from_system()

func get_age_in_seconds() -> float:
	var current_time_stamp: float = Time.get_unix_time_from_system()
	var difference: float = (current_time_stamp - _date_time)
	return difference

func to_dictionary() -> Dictionary:
	return {
		"ip": _ip,
		"version": _version
	}

func is_identical(other: ServerInformation) -> bool:
	return _ip == other.get_ip() and _version == other.get_version()

static func from_dictionary(data: Dictionary) -> ServerInformation:
	var ip: String = data.get_or_add("ip", "")
	var version: String = data.get_or_add("version", "")
	var return_data: ServerInformation = ServerInformation.new(ip, version)
	return return_data
